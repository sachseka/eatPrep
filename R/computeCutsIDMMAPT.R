# The logistic component of MAPT standard setting (Sireci et al., 2006,
# pp. 54-55). Deliberately does not apply the report's rating trimming.
# Self-contained so this file can also be sourced alongside older eatPrep builds.

.mapt_ids <- function(x, label) {
  if (!is.atomic(x) || anyNA(x)) {
    stop(label, " must contain non-missing atomic identifiers.", call. = FALSE)
  }
  out <- as.character(x)
  if (any(!nzchar(out))) {
    stop(label, " must not contain empty identifiers.", call. = FALSE)
  }
  out
}

.mapt_prepare <- function(dat, est_col, item_id_col, rater_cols,
                          rater_pattern, rater_id_col, rating_col,
                          input_format, rating_levels) {
  checkmate::assert_data_frame(dat, min.rows = 1, any.missing = TRUE)
  if (anyDuplicated(names(dat))) {
    stop("dat must have unique column names.", call. = FALSE)
  }
  checkmate::assert_string(est_col)
  checkmate::assert_names(est_col, subset.of = names(dat))
  checkmate::assert_numeric(dat[[est_col]], any.missing = FALSE)
  if (any(!is.finite(dat[[est_col]]))) {
    stop("est_col must contain only finite values.", call. = FALSE)
  }
  checkmate::assert_string(item_id_col, null.ok = TRUE)
  checkmate::assert_string(rater_id_col, null.ok = TRUE)
  checkmate::assert_string(rating_col, null.ok = TRUE)
  checkmate::assert_character(rater_cols, any.missing = FALSE, null.ok = TRUE)
  checkmate::assert_string(rater_pattern)
  if (input_format == "auto") {
    input_format <- if (!is.null(rater_id_col) || !is.null(rating_col)) "long" else "wide"
  }

  if (input_format == "long") {
    if (is.null(item_id_col) || is.null(rater_id_col) || is.null(rating_col)) {
      stop("Long input requires item_id_col, rater_id_col, and rating_col.", call. = FALSE)
    }
    if (!is.null(rater_cols)) {
      stop("rater_cols is only used for wide input.", call. = FALSE)
    }
    roles <- c(est_col, item_id_col, rater_id_col, rating_col)
    checkmate::assert_names(roles, subset.of = names(dat))
    if (anyDuplicated(roles)) {
      stop("Estimate, item, rater, and rating columns must be distinct.", call. = FALSE)
    }
    if (is.null(rating_levels)) {
      checkmate::assert_numeric(dat[[rating_col]])
    }
    if (!is.atomic(dat[[rating_col]])) {
      stop("rating_col must contain an atomic vector.", call. = FALSE)
    }
    out <- data.frame(
      item_id = .mapt_ids(dat[[item_id_col]], "item_id_col"),
      person = .mapt_ids(dat[[rater_id_col]], "rater_id_col"),
      est = dat[[est_col]],
      stage_label = as.character(dat[[rating_col]]),
      stringsAsFactors = FALSE
    )
    out$stage_label[is.na(dat[[rating_col]])] <- NA_character_
  } else {
    if (!is.null(rater_id_col) || !is.null(rating_col)) {
      stop("rater_id_col and rating_col are only used for long input.", call. = FALSE)
    }
    if (!is.null(item_id_col)) {
      checkmate::assert_names(item_id_col, subset.of = names(dat))
      if (identical(item_id_col, est_col)) {
        stop("Item and estimate columns must be distinct.", call. = FALSE)
      }
      item_id <- .mapt_ids(dat[[item_id_col]], "item_id_col")
    } else {
      item_id <- as.character(seq_len(nrow(dat)))
    }
    if (anyDuplicated(item_id)) {
      stop("item_id_col must identify unique items in wide input.", call. = FALSE)
    }
    if (is.null(rater_cols)) {
      rater_cols <- setdiff(grep(rater_pattern, names(dat), value = TRUE),
                            c(est_col, item_id_col))
    }
    if (!length(rater_cols) || anyDuplicated(rater_cols)) {
      stop("Specify at least one unique rater column.", call. = FALSE)
    }
    checkmate::assert_names(rater_cols, subset.of = names(dat))
    if (length(intersect(rater_cols, c(est_col, item_id_col)))) {
      stop("Rater columns must differ from item and estimate columns.", call. = FALSE)
    }
    out <- do.call(rbind, lapply(rater_cols, function(p) {
      if (is.null(rating_levels)) {
        checkmate::assert_numeric(dat[[p]])
      }
      if (!is.atomic(dat[[p]])) {
        stop("Rater columns must contain atomic vectors.", call. = FALSE)
      }
      labels <- as.character(dat[[p]])
      labels[is.na(dat[[p]])] <- NA_character_
      data.frame(item_id = item_id, person = p, est = dat[[est_col]],
                 stage_label = labels, stringsAsFactors = FALSE)
    }))
  }

  if (anyDuplicated(out[c("item_id", "person")])) {
    stop("Each item-rater combination must occur only once.", call. = FALSE)
  }
  estimates <- unique(out[c("item_id", "est")])
  if (anyDuplicated(estimates$item_id)) {
    stop("Each item must map to exactly one estimate.", call. = FALSE)
  }
  list(data = out, persons = sort(unique(out$person), method = "radix"),
       input_format = input_format)
}

.mapt_fit <- function(dat, boundary, cut_name) {
  # Canonical order avoids even rounding differences caused by row permutation.
  dat <- dat[order(dat$est, dat$stage_raw, dat$person, dat$item_id), , drop = FALSE]
  x <- dat$est
  response <- as.integer(dat$stage_raw > boundary)
  diagnostic <- data.frame(
    cut_name = cut_name, boundary = boundary, cut = NA_real_,
    n = length(x), n_lower = sum(response == 0L), n_upper = sum(response == 1L),
    min_est = if (length(x)) min(x) else NA_real_,
    max_est = if (length(x)) max(x) else NA_real_,
    intercept = NA_real_, slope = NA_real_, est_center = NA_real_, est_scale = NA_real_,
    converged = NA, extrapolated = NA, status = "ok", warning = "",
    stringsAsFactors = FALSE
  )
  finish <- function(status, model = NULL) {
    diagnostic$status <- status
    list(diagnostic = diagnostic, model = model)
  }
  if (!length(x)) return(finish("no_data"))
  if (length(unique(response)) < 2L) return(finish("one_class"))
  if (length(unique(x)) < 2L) return(finish("constant_est"))

  # Exact complete/quasi-complete separation check for one continuous predictor.
  # Ordinary logistic maximum likelihood then has no finite slope estimate.
  lower <- x[response == 0L]
  upper <- x[response == 1L]
  if (max(lower) <= min(upper) || max(upper) <= min(lower)) {
    return(finish("separation"))
  }

  center <- mean(x)
  scale <- stats::sd(x)
  diagnostic$est_center <- center
  diagnostic$est_scale <- scale
  if (!is.finite(center) || !is.finite(scale) || scale <= 0) {
    return(finish("non_finite"))
  }
  fit_warnings <- character()
  fit <- tryCatch(withCallingHandlers(
    stats::glm(response ~ difficulty,
               data = data.frame(response = response, difficulty = (x - center) / scale),
               family = stats::binomial(link = "logit"),
               control = stats::glm.control(maxit = 100)),
    warning = function(w) {
      fit_warnings <<- c(fit_warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }), error = function(e) e)
  if (inherits(fit, "error")) {
    diagnostic$warning <- conditionMessage(fit)
    return(finish("fit_error"))
  }
  fit$est_center <- center
  fit$est_scale <- scale
  diagnostic$converged <- isTRUE(fit$converged)
  diagnostic$warning <- paste(unique(fit_warnings), collapse = "; ")
  coefficients <- stats::coef(fit)
  if (length(coefficients) != 2L || any(!is.finite(coefficients))) {
    return(finish("non_finite", fit))
  }
  diagnostic$intercept <- unname(coefficients[1] - coefficients[2] * center / scale)
  diagnostic$slope <- unname(coefficients[2] / scale)
  if (!isTRUE(fit$converged) || isTRUE(fit$boundary)) {
    return(finish("non_convergence", fit))
  }
  if (coefficients[2] <= sqrt(.Machine$double.eps)) {
    diagnostic$warning <- paste(c(fit_warnings,
      "Slope is non-positive or numerically flat on the standardized scale."), collapse = "; ")
    return(finish("nonpositive_slope", fit))
  }
  cut <- unname(center - scale * coefficients[1] / coefficients[2])
  if (any(!is.finite(c(cut, diagnostic$intercept, diagnostic$slope)))) {
    return(finish("non_finite", fit))
  }
  diagnostic$cut <- cut
  diagnostic$extrapolated <- cut < min(x) || cut > max(x)
  finish("ok", fit)
}

computeCutsIDMMAPT <- function(dat, boundaries = c(1.5, 2.5, 3.5, 4.5),
                               est_col = "est", item_id_col = NULL,
                               rater_cols = NULL, rater_pattern = "Rater",
                               rater_id_col = NULL, rating_col = NULL,
                               input_format = c("auto", "long", "wide"),
                               rating_levels = NULL, missing = c("drop", "error"),
                               cut_labels = NULL, per_rater = TRUE) {
  boundaries_were_missing <- base::missing(boundaries)
  input_format <- match.arg(input_format)
  missing <- match.arg(missing)
  checkmate::assert_flag(per_rater)
  supplied_levels <- !is.null(rating_levels)
  if (supplied_levels) {
    if (!is.atomic(rating_levels) || length(rating_levels) < 2L || anyNA(rating_levels)) {
      stop("rating_levels must contain at least two non-missing ordered labels.", call. = FALSE)
    }
    rating_levels <- as.character(rating_levels)
    if (anyDuplicated(rating_levels) || any(!nzchar(rating_levels))) {
      stop("rating_levels must contain unique non-empty labels.", call. = FALSE)
    }
    if (boundaries_were_missing) {
      boundaries <- seq_len(length(rating_levels) - 1L) + 0.5
    }
  }
  checkmate::assert_numeric(boundaries, min.len = 1, any.missing = FALSE)
  if (any(!is.finite(boundaries)) || any(boundaries < 1.5) ||
      any(boundaries != floor(boundaries) + 0.5) || is.unsorted(boundaries, strictly = TRUE)) {
    stop("boundaries must be strictly increasing half-integers between rating levels.", call. = FALSE)
  }
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
    max_level <- max(c(long$stage_raw[valid], ceiling(boundaries)))
    rating_levels <- as.character(seq_len(max_level))
  }
  if (any(ceiling(boundaries) > length(rating_levels))) {
    stop("boundaries must lie between the supplied rating_levels.", call. = FALSE)
  }
  if (is.null(cut_labels)) {
    lower <- floor(boundaries)
    cut_labels <- if (supplied_levels) {
      paste0("cut_", rating_levels[lower], "_", rating_levels[lower + 1L])
    } else {
      paste0("cut", lower, lower + 1L)
    }
  }
  checkmate::assert_character(cut_labels, len = length(boundaries), any.missing = FALSE,
                              min.chars = 1, unique = TRUE)
  if ("person" %in% cut_labels) {
    stop("cut_labels must not use the reserved name 'person'.", call. = FALSE)
  }
  n_dropped <- sum(is.na(long$stage_raw))
  if (missing == "error" && n_dropped > 0L) {
    stop("Ratings must not contain missing values when missing = 'error'.", call. = FALSE)
  }
  long <- long[!is.na(long$stage_raw), , drop = FALSE]
  if (!nrow(long)) stop("No observed ratings remain.", call. = FALSE)
  long <- long[order(long$est, long$stage_raw, long$person, long$item_id), , drop = FALSE]
  rownames(long) <- NULL

  fit_cuts <- function(d) {
    results <- lapply(seq_along(boundaries), function(i) {
      .mapt_fit(d, boundaries[i], cut_labels[i])
    })
    list(diagnostics = tibble::as_tibble(do.call(rbind, lapply(results, `[[`, "diagnostic"))),
         models = stats::setNames(lapply(results, `[[`, "model"), cut_labels))
  }
  cut_row <- function(values) tibble::as_tibble(stats::setNames(as.list(values), cut_labels))
  pooled <- fit_cuts(long)
  cuts_summary <- cut_row(pooled$diagnostics$cut)
  cuts_per_person <- cuts_summary_per_person <- diagnostics_per_person <- NULL
  if (per_rater) {
    person_results <- lapply(prepared$persons, function(p) {
      fit_cuts(long[long$person == p, , drop = FALSE])$diagnostics
    })
    cuts_per_person <- tibble::as_tibble(do.call(rbind, lapply(seq_along(prepared$persons), function(i) {
      cbind(data.frame(person = prepared$persons[i]), as.data.frame(cut_row(person_results[[i]]$cut)))
    })))
    diagnostics_per_person <- tibble::as_tibble(do.call(rbind, lapply(seq_along(prepared$persons), function(i) {
      cbind(data.frame(person = prepared$persons[i]), as.data.frame(person_results[[i]]))
    })))
    cuts_summary_per_person <- cut_row(vapply(cuts_per_person[cut_labels], function(x) {
      if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
    }, numeric(1)))
  }
  pooled_cuts <- pooled$diagnostics$cut
  cuts_ordered <- if (anyNA(pooled_cuts)) NA else all(diff(pooled_cuts) > 0)
  all_diagnostics <- pooled$diagnostics
  if (per_rater) {
    all_diagnostics <- rbind(all_diagnostics, diagnostics_per_person[names(all_diagnostics)])
  }
  notices <- character()
  invalid <- all_diagnostics$status != "ok"
  if (any(invalid)) {
    notices <- c(notices, paste0(sum(invalid), " pooled/per-rater fit(s) have no usable cut (",
      paste(unique(all_diagnostics$status[invalid]), collapse = ", "), ")"))
  }
  if (any(all_diagnostics$extrapolated %in% TRUE)) {
    notices <- c(notices, "some cuts lie outside the observed difficulty range")
  }
  if (any(nzchar(all_diagnostics$warning))) {
    notices <- c(notices, "some fits have numerical warnings")
  }
  if (identical(cuts_ordered, FALSE)) {
    notices <- c(notices, "pooled cuts are not strictly increasing; values were not reordered")
  }
  if (length(notices)) {
    warning("MAPT fit diagnostics: ", paste(notices, collapse = "; "),
            ". See cut_diagnostics and diagnostics_per_person.", call. = FALSE)
  }
  structure(list(
    cuts_summary = cuts_summary, cuts_per_person = cuts_per_person,
    cuts_summary_per_person = cuts_summary_per_person,
    cut_diagnostics = pooled$diagnostics, diagnostics_per_person = diagnostics_per_person,
    models = pooled$models, data_used = tibble::as_tibble(long), n_dropped = n_dropped,
    boundaries = boundaries, rating_levels = rating_levels, cut_labels = cut_labels,
    input_format = prepared$input_format, est_col = est_col, item_id_col = item_id_col,
    rater_id_col = rater_id_col, rating_col = rating_col, missing = missing,
    cuts_ordered = cuts_ordered, method = "MAPT pooled binary logistic regression (no rating trimming)"
  ), class = c("cutsIDMMAPT", "list"))
}
