# Joint cumulative-logit IDM cuts. Random intercepts model differences in
# ratings, not uncertainty in the supplied item-difficulty estimates.

.ordinal_control_idm <- function(control, mixed) {
  checkmate::assert_list(control, names = "unique")
  if (length(control) && (is.null(names(control)) || any(!nzchar(names(control))))) {
    stop("control must be a named list with unique non-empty names.", call. = FALSE)
  }
  common <- c("trace", "maxIter", "gradTol", "maxLineIter")
  allowed <- if (mixed) {
    c(common, "innerCtrl", "useMatrix", "checkRanef", "iter.max", "eval.max",
      "rel.tol", "abs.tol", "x.tol", "xf.tol", "step.min", "step.max", "sing.tol", "diff.g")
  } else {
    c(common, "relTol", "tol", "maxModIter", "convergence")
  }
  if (length(setdiff(names(control), allowed))) {
    stop("Unsupported control option(s): ", paste(setdiff(names(control), allowed), collapse = ", "),
         ". The optimizer is nlminb for mixed models and Newton otherwise.", call. = FALSE)
  }
  defaults <- if (mixed) {
    list(method = "nlminb", useMatrix = TRUE, maxIter = 100L, innerCtrl = "giveError",
         iter.max = 200L, eval.max = 400L, rel.tol = 1e-10)
  } else {
    list(method = "Newton")
  }
  defaults[names(control)] <- control
  do.call(if (mixed) ordinal::clmm.control else ordinal::clm.control, defaults)
}

.ordinal_fit_idm <- function(dat, n_levels, random_effects, control) {
  center <- mean(dat$est)
  scale <- stats::sd(dat$est)
  diagnostic <- data.frame(
    status = "ok", converged = NA, max_gradient = NA_real_,
    max_scaled_gradient = NA_real_, hessian_positive_definite = NA,
    condition_number = NA_real_, singular = NA, warning = "",
    est_center = center, est_scale = scale,
    n_ratings = nrow(dat), n_items = length(unique(dat$item_id)),
    n_raters = length(unique(dat$person)), stringsAsFactors = FALSE
  )
  finish <- function(status, model = NULL, variance = NULL, effects = NULL) {
    diagnostic$status <- status
    list(model = model, diagnostic = diagnostic, variance = variance, effects = effects)
  }
  observed <- sort(unique(dat$stage_raw))
  if (length(observed) < 2L) return(finish("one_class"))
  if (!identical(as.integer(observed), seq_len(n_levels))) {
    diagnostic$warning <- paste0("Unobserved rating levels: ",
      paste(setdiff(seq_len(n_levels), observed), collapse = ", "),
      ". Categories were not collapsed.")
    return(finish("missing_categories"))
  }
  if (length(unique(dat$est)) < 2L) return(finish("constant_est"))
  if (!is.finite(center) || !is.finite(scale) || scale <= 0) return(finish("non_finite"))

  # A completely ordered sequence permits an infinite common slope. Detect
  # this directly rather than trusting an optimizer's finite stopping point.
  ranges <- lapply(seq_len(n_levels), function(k) range(dat$est[dat$stage_raw == k]))
  if (all(vapply(seq_len(n_levels - 1L), function(k) {
    ranges[[k]][2] <= ranges[[k + 1L]][1]
  }, logical(1)))) return(finish("separation"))

  frame <- data.frame(
    rating = ordered(dat$stage_raw, levels = seq_len(n_levels)),
    difficulty = (dat$est - center) / scale,
    person = factor(dat$person, levels = sort(unique(dat$person), method = "radix")),
    item_id = factor(dat$item_id, levels = sort(unique(dat$item_id), method = "radix"))
  )
  terms <- c("difficulty", if ("rater" %in% random_effects) "(1 | person)",
             if ("item" %in% random_effects) "(1 | item_id)")
  formula <- stats::as.formula(paste("rating ~", paste(terms, collapse = " + ")), env = baseenv())
  fit_warnings <- character()
  fit <- tryCatch(withCallingHandlers({
    if (length(random_effects)) {
      ordinal::clmm(formula, data = frame, link = "logit", threshold = "flexible",
                    Hess = TRUE, nAGQ = 1L, control = control)
    } else {
      ordinal::clm(formula, data = frame, link = "logit", threshold = "flexible",
                   control = control)
    }
  }, warning = function(w) {
    fit_warnings <<- c(fit_warnings, conditionMessage(w))
    invokeRestart("muffleWarning")
  }), error = function(e) e)
  diagnostic$warning <- paste(unique(fit_warnings), collapse = "; ")
  if (inherits(fit, "error")) {
    diagnostic$warning <- paste(c(fit_warnings, conditionMessage(fit)), collapse = "; ")
    return(finish("fit_error"))
  }
  fit$est_center <- center
  fit$est_scale <- scale
  diagnostic$converged <- if (length(random_effects)) {
    isTRUE(fit$optRes$convergence == 0L)
  } else {
    isTRUE(fit$convergence$code == 0L)
  }
  variance <- data.frame(group = character(), variance = numeric(), sd = numeric(),
                         n_levels = integer())
  effects <- list()
  if (length(random_effects)) {
    vc <- ordinal::VarCorr(fit)
    effects <- ordinal::ranef(fit)
    variance <- do.call(rbind, lapply(random_effects, function(group) {
      field <- if (group == "rater") "person" else "item_id"
      value <- unname(vc[[field]][1, 1])
      data.frame(group = group, variance = value, sd = sqrt(value),
                 n_levels = nlevels(frame[[field]]))
    }))
  }
  diagnostic$singular <- any(variance$sd < 1e-4)
  coefficients <- c(fit$alpha, fit$beta)
  if (length(fit$alpha) != n_levels - 1L || length(fit$beta) != 1L ||
      any(!is.finite(coefficients)) || any(!is.finite(variance$sd))) {
    return(finish("non_finite", fit, variance, effects))
  }
  if (!diagnostic$converged) return(finish("non_convergence", fit, variance, effects))
  if (unname(fit$beta) <= sqrt(.Machine$double.eps)) {
    return(finish("nonpositive_slope", fit, variance, effects))
  }
  if (any(diff(fit$alpha) <= 0)) return(finish("unordered_thresholds", fit, variance, effects))

  hessian <- fit$Hessian
  gradient <- fit$gradient
  if (is.null(hessian) || any(!is.finite(hessian)) || !length(gradient) ||
      any(!is.finite(gradient))) return(finish("non_finite", fit, variance, effects))
  diagnostic$max_gradient <- max(abs(gradient))
  eigenvalues <- eigen(hessian, symmetric = TRUE, only.values = TRUE)$values
  diagnostic$hessian_positive_definite <- min(eigenvalues) > 0
  diagnostic$condition_number <- if (min(eigenvalues) > 0) max(eigenvalues) / min(eigenvalues) else Inf
  hessian_ok <- min(eigenvalues) > 1e-8 && diagnostic$condition_number < 1e10
  # A variance estimated at zero is a legitimate boundary solution. Exclude
  # only its boundary dimension if necessary, retaining all fixed parameters
  # AND any other, positive variance parameter in the convergence check.
  if (!hessian_ok && diagnostic$singular) {
    at_boundary <- vapply(fit$ST, function(st) st[1, 1] < 1e-4, logical(1))
    if (nrow(hessian) == length(coefficients) + length(at_boundary)) {
      keep <- c(seq_along(coefficients), length(coefficients) + which(!at_boundary))
      hessian <- hessian[keep, keep, drop = FALSE]
      gradient <- gradient[keep]
      eigenvalues <- eigen(hessian, symmetric = TRUE, only.values = TRUE)$values
      hessian_ok <- min(eigenvalues) > 1e-8 && max(eigenvalues) / min(eigenvalues) < 1e10
    }
  }
  if (!hessian_ok) return(finish("ill_conditioned", fit, variance, effects))
  diagnostic$max_scaled_gradient <- max(abs(backsolve(chol(hessian), gradient, transpose = TRUE)))
  if (diagnostic$max_scaled_gradient > 1e-3) {
    diagnostic$converged <- FALSE
    return(finish("non_convergence", fit, variance, effects))
  }
  finish("ok", fit, variance, effects)
}

computeCutsIDMOrdinal <- function(dat, boundaries = c(1.5, 2.5, 3.5, 4.5),
                                  est_col = "est", item_id_col = NULL,
                                  rater_cols = NULL, rater_pattern = "Rater",
                                  rater_id_col = NULL, rating_col = NULL,
                                  input_format = c("auto", "long", "wide"),
                                  rating_levels = NULL, missing = c("drop", "error"),
                                  cut_labels = NULL, per_rater = TRUE,
                                  random_effects = c("rater", "item"), control = list()) {
  boundaries_were_missing <- base::missing(boundaries)
  input_format <- match.arg(input_format)
  missing <- match.arg(missing)
  checkmate::assert_flag(per_rater)
  checkmate::assert_character(random_effects, any.missing = FALSE, unique = TRUE)
  if (length(setdiff(random_effects, c("rater", "item")))) {
    stop("random_effects must be a subset of c('rater', 'item'), or character().", call. = FALSE)
  }
  random_effects <- intersect(c("rater", "item"), random_effects)
  fit_control <- .ordinal_control_idm(control, length(random_effects) > 0L)
  supplied_levels <- !is.null(rating_levels)
  if (supplied_levels) {
    if (!is.atomic(rating_levels) || length(rating_levels) < 2L || anyNA(rating_levels)) {
      stop("rating_levels must contain at least two non-missing ordered labels.", call. = FALSE)
    }
    rating_levels <- as.character(rating_levels)
    if (anyDuplicated(rating_levels) || any(!nzchar(rating_levels))) {
      stop("rating_levels must contain unique non-empty labels.", call. = FALSE)
    }
    if (boundaries_were_missing) boundaries <- seq_len(length(rating_levels) - 1L) + 0.5
  }
  checkmate::assert_numeric(boundaries, min.len = 1, any.missing = FALSE)
  if (any(!is.finite(boundaries)) || any(boundaries < 1.5) ||
      any(boundaries != floor(boundaries) + 0.5) || is.unsorted(boundaries, strictly = TRUE)) {
    stop("boundaries must be strictly increasing half-integers between rating levels.", call. = FALSE)
  }
  # Reuse MAPT's identifier-safe long/wide input contract.
  prepared <- .mapt_prepare(dat, est_col, item_id_col, rater_cols, rater_pattern,
                            rater_id_col, rating_col, input_format, rating_levels)
  long <- prepared$data
  if (supplied_levels) {
    long$stage_raw <- match(long$stage_label, rating_levels)
    unknown <- !is.na(long$stage_label) & is.na(long$stage_raw)
    if (any(unknown)) {
      stop("Ratings not found in rating_levels: ",
           paste(unique(long$stage_label[unknown]), collapse = ", "), call. = FALSE)
    }
  } else {
    long$stage_raw <- as.numeric(long$stage_label)
    valid <- !is.na(long$stage_raw)
    if (any(!is.finite(long$stage_raw[valid])) ||
        any(long$stage_raw[valid] < 1 | long$stage_raw[valid] != floor(long$stage_raw[valid]))) {
      stop("Without rating_levels, ratings must be positive integer level codes.", call. = FALSE)
    }
    rating_levels <- as.character(seq_len(max(c(long$stage_raw[valid], ceiling(boundaries)))))
  }
  if (any(ceiling(boundaries) > length(rating_levels))) {
    stop("boundaries must lie between the supplied rating_levels.", call. = FALSE)
  }
  if (is.null(cut_labels)) {
    lower <- floor(boundaries)
    cut_labels <- if (supplied_levels) {
      paste0("cut_", rating_levels[lower], "_", rating_levels[lower + 1L])
    } else paste0("cut", lower, lower + 1L)
  }
  checkmate::assert_character(cut_labels, len = length(boundaries), any.missing = FALSE,
                              min.chars = 1, unique = TRUE)
  if ("person" %in% cut_labels) stop("cut_labels must not use the reserved name 'person'.", call. = FALSE)
  n_dropped <- sum(is.na(long$stage_raw))
  if (missing == "error" && n_dropped > 0L) {
    stop("Ratings must not contain missing values when missing = 'error'.", call. = FALSE)
  }
  all_items <- sort(unique(long$item_id), method = "radix")
  long <- long[!is.na(long$stage_raw), , drop = FALSE]
  if (!nrow(long)) stop("No observed ratings remain.", call. = FALSE)
  long <- long[order(long$est, long$stage_raw, long$person, long$item_id, method = "radix"), , drop = FALSE]
  rownames(long) <- NULL
  for (group in random_effects) {
    field <- if (group == "rater") "person" else "item_id"
    counts <- table(long[[field]])
    if (length(counts) < 2L || !any(counts > 1L)) {
      stop("The ", group, " random effect requires at least two observed ", group,
           " levels and repeated ratings within at least one level. Adjust random_effects explicitly.",
           call. = FALSE)
    }
  }
  fitted <- .ordinal_fit_idm(long, length(rating_levels), random_effects, fit_control)
  fit <- fitted$model
  model_diagnostics <- fitted$diagnostic
  variance <- fitted$variance
  if (is.null(variance)) variance <- data.frame(group = character(), variance = numeric(),
                                               sd = numeric(), n_levels = integer())
  effect_table <- function(ids, field, group) {
    n <- tabulate(match(long[[field]], ids), nbins = length(ids))
    effect <- rep(if (group %in% random_effects) NA_real_ else 0, length(ids))
    modes <- fitted$effects[[field]]
    if (!is.null(modes)) effect <- as.numeric(modes[match(ids, rownames(modes)), 1])
    effect[n == 0L] <- NA_real_
    stats::setNames(data.frame(ids, effect = effect, n = n, stringsAsFactors = FALSE),
                     c(field, "effect", "n"))
  }
  rater_effects <- effect_table(prepared$persons, "person", "rater")
  item_effects <- effect_table(all_items, "item_id", "item")
  center <- model_diagnostics$est_center
  scale <- model_diagnostics$est_scale
  beta <- if (!is.null(fit) && length(fit$beta) == 1L) unname(fit$beta) else NA_real_
  alpha <- if (!is.null(fit) && length(fit$alpha) == length(rating_levels) - 1L) {
    unname(fit$alpha[floor(boundaries)])
  } else rep(NA_real_, length(boundaries))
  make_diagnostics <- function(d, effect = 0) {
    n <- nrow(d)
    status <- if (!n) "no_data" else model_diagnostics$status
    if (status == "ok" && !is.finite(effect)) status <- "non_finite"
    values <- if (status == "ok") center + scale * (alpha - effect) / beta else rep(NA_real_, length(alpha))
    if (status == "ok" && any(!is.finite(values))) {
      status <- "non_finite"
      values[] <- NA_real_
    }
    lo <- if (n) min(d$est) else NA_real_
    hi <- if (n) max(d$est) else NA_real_
    data.frame(
      cut_name = cut_labels, boundary = boundaries, cut = values, n = n,
      n_lower = vapply(boundaries, function(b) sum(d$stage_raw <= b), integer(1)),
      n_upper = vapply(boundaries, function(b) sum(d$stage_raw > b), integer(1)),
      min_est = lo, max_est = hi, threshold = alpha,
      intercept = effect - alpha - beta * center / scale, slope = beta / scale,
      rater_effect = effect, converged = model_diagnostics$converged,
      extrapolated = ifelse(is.finite(values), values < lo | values > hi, NA),
      status = status, warning = model_diagnostics$warning, stringsAsFactors = FALSE
    )
  }
  cut_diagnostics <- make_diagnostics(long)
  cut_row <- function(values) tibble::as_tibble(stats::setNames(as.list(values), cut_labels))
  cuts_summary <- cut_row(cut_diagnostics$cut)
  cuts_per_person <- diagnostics_per_person <- NULL
  if (per_rater) {
    individual <- lapply(seq_along(prepared$persons), function(j) {
      person <- prepared$persons[j]
      cbind(data.frame(person = person),
            make_diagnostics(long[long$person == person, , drop = FALSE], rater_effects$effect[j]))
    })
    diagnostics_per_person <- tibble::as_tibble(do.call(rbind, individual))
    cuts_per_person <- tibble::as_tibble(do.call(rbind, lapply(seq_along(individual), function(j) {
      cbind(data.frame(person = prepared$persons[j]), as.data.frame(cut_row(individual[[j]]$cut)))
    })))
  }
  notices <- character()
  if (model_diagnostics$status != "ok") notices <- paste0("no usable cuts (", model_diagnostics$status, ")")
  if (isTRUE(model_diagnostics$singular)) notices <- c(notices, "a random-effect SD is near zero")
  if (nzchar(model_diagnostics$warning)) notices <- c(notices, "model messages were recorded")
  if (any(c(cut_diagnostics$extrapolated, diagnostics_per_person$extrapolated) %in% TRUE)) {
    notices <- c(notices, "some cuts lie outside the observed difficulty range")
  }
  if (length(notices)) warning("Ordinal IDM diagnostics: ", paste(notices, collapse = "; "),
                               ". See model_diagnostics and cut_diagnostics.", call. = FALSE)
  structure(list(
    cuts_summary = cuts_summary, cuts_per_person = cuts_per_person,
    cut_diagnostics = tibble::as_tibble(cut_diagnostics), diagnostics_per_person = diagnostics_per_person,
    model = fit, model_diagnostics = tibble::as_tibble(model_diagnostics),
    rater_effects = tibble::as_tibble(rater_effects), item_effects = tibble::as_tibble(item_effects),
    variance_components = tibble::as_tibble(variance), data_used = tibble::as_tibble(long),
    n_dropped = n_dropped, boundaries = boundaries, rating_levels = rating_levels,
    cut_labels = cut_labels, random_effects = random_effects, control = control,
    input_format = prepared$input_format, est_col = est_col, item_id_col = item_id_col,
    rater_id_col = rater_id_col, rating_col = rating_col, missing = missing,
    cuts_ordered = if (anyNA(cut_diagnostics$cut)) NA else all(diff(cut_diagnostics$cut) > 0),
    method = "Joint cumulative logit (reference cuts at zero random effects)"
  ), class = c("cutsIDMOrdinal", "list"))
}
