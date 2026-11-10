summary.cutsIDMOrdinal <- function(object, per_rater = FALSE, ...) {
  checkmate::assert_flag(per_rater)
  structure(list(
    cuts_summary = object$cuts_summary, cut_diagnostics = object$cut_diagnostics,
    model_diagnostics = object$model_diagnostics,
    variance_components = object$variance_components,
    n_ratings = nrow(object$data_used), n_items = length(unique(object$data_used$item_id)),
    n_raters = length(unique(object$data_used$person)), n_dropped = object$n_dropped,
    cuts_ordered = object$cuts_ordered, random_effects = object$random_effects,
    per_rater_available = !is.null(object$cuts_per_person), per_rater = per_rater,
    cuts_per_person = if (per_rater) object$cuts_per_person else NULL,
    diagnostics_per_person = if (per_rater) object$diagnostics_per_person else NULL,
    method = object$method
  ), class = "summary.cutsIDMOrdinal")
}

print.cutsIDMOrdinal <- function(x, digits = 3, ...) {
  print(summary(x), digits = digits, ...)
  invisible(x)
}

print.summary.cutsIDMOrdinal <- function(x, digits = 3, ...) {
  checkmate::assert_int(digits, lower = 0, upper = 15)
  print_table <- function(dat) {
    dat <- as.data.frame(dat)
    numeric <- vapply(dat, is.numeric, logical(1))
    dat[numeric] <- lapply(dat[numeric], round, digits = digits)
    print(dat, row.names = FALSE)
  }
  cat("Joint ordinal IDM cuts (cumulative logit)\n")
  cat(x$n_ratings, "ratings from", x$n_raters, "raters on", x$n_items,
      "items;", x$n_dropped, "missing ratings dropped.\n")
  cat("Random intercepts:", if (length(x$random_effects)) paste(x$random_effects, collapse = ", ") else "none", "\n")
  cat("\nReference cuts (rater and item effects set to zero):\n")
  print_table(x$cut_diagnostics[c("cut_name", "cut", "status", "extrapolated")])
  cat("\nModel diagnostics:\n")
  print_table(x$model_diagnostics[c("status", "converged", "max_gradient", "max_scaled_gradient",
                                    "hessian_positive_definite", "singular", "warning")])
  if (nrow(x$variance_components)) {
    cat("\nRandom-intercept variance components (logit scale):\n")
    print_table(x$variance_components)
  }
  if (x$per_rater && x$per_rater_available) {
    cat("\nConditional rater cuts (joint fit, item effect set to zero):\n")
    print_table(x$cuts_per_person)
  } else if (x$per_rater) {
    cat("\nRater cuts unavailable: compute with per_rater = TRUE.\n")
  } else if (x$per_rater_available) {
    cat("\nConditional rater cuts: summary(x, per_rater = TRUE).\n")
  }
  cat("Reference cuts are not the mean of rater cuts. No cut confidence intervals are computed.\n")
  cat("Model, effects and ratings remain in the original result: $model, $rater_effects, $item_effects, $data_used.\n")
  invisible(x)
}
