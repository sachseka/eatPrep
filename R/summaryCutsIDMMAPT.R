# Compact views; the original result retains models and rating-level data.
summary.cutsIDMMAPT <- function(object, per_rater = FALSE, ...) {
  checkmate::assert_flag(per_rater)
  pooled <- object$cut_diagnostics
  pooled$scope <- "pooled"
  pooled$person <- NA_character_
  individual <- object$diagnostics_per_person
  if (!is.null(individual)) individual$scope <- "rater"
  diagnostics <- dplyr::bind_rows(pooled, individual)
  flagged <- diagnostics$status != "ok" |
    diagnostics$extrapolated %in% TRUE |
    (!is.na(diagnostics$warning) & nzchar(diagnostics$warning))
  issues <- diagnostics[flagged, c("scope", "person", "cut_name", "status",
                                  "extrapolated", "warning")]
  structure(list(
    cuts_summary = object$cuts_summary,
    cut_diagnostics = object$cut_diagnostics,
    issues = issues,
    n_ratings = nrow(object$data_used),
    n_items = length(unique(object$data_used$item_id)),
    n_raters = length(unique(object$data_used$person)),
    n_dropped = object$n_dropped,
    cuts_ordered = object$cuts_ordered,
    per_rater_available = !is.null(object$cuts_per_person),
    per_rater = per_rater,
    cuts_per_person = if (per_rater) object$cuts_per_person else NULL,
    diagnostics_per_person = if (per_rater) object$diagnostics_per_person else NULL,
    method = object$method
  ), class = "summary.cutsIDMMAPT")
}

print.cutsIDMMAPT <- function(x, digits = 3, ...) {
  print(summary(x), digits = digits, ...)
  invisible(x)
}

print.summary.cutsIDMMAPT <- function(x, digits = 3, ...) {
  checkmate::assert_int(digits, lower = 0, upper = 15)
  print_table <- function(dat) {
    dat <- as.data.frame(dat)
    numeric <- vapply(dat, is.numeric, logical(1))
    dat[numeric] <- lapply(dat[numeric], round, digits = digits)
    print(dat, row.names = FALSE)
  }
  cat("MAPT pooled binary logistic cuts (no rating trimming)\n")
  cat(x$n_ratings, "ratings from", x$n_raters, "raters on", x$n_items,
      "items;", x$n_dropped, "missing ratings dropped.\n")
  cat("\nPooled cuts (all raters fitted together):\n")
  print_table(x$cut_diagnostics[c("cut_name", "cut", "status", "extrapolated")])
  if (is.na(x$cuts_ordered)) {
    cat("Cut order cannot be checked: at least one pooled cut is unavailable.\n")
  } else if (!x$cuts_ordered) {
    cat("ATTENTION: pooled cuts are not strictly increasing in boundary order.\n")
  }
  if (nrow(x$issues)) {
    cat("\nFlagged fits (pooled and available individual fits):", nrow(x$issues), "\n")
    print_table(utils::head(x$issues, 20L))
    if (nrow(x$issues) > 20L) cat("Only the first 20 are printed; all are in summary(x)$issues.\n")
  } else {
    cat("\nNo flagged fits.\n")
  }
  cat("Extrapolated = cut outside the observed item difficulty range.\n")
  if (x$per_rater) {
    if (x$per_rater_available) {
      cat("\nIndividual rater cuts (comparison results):\n")
      print_table(x$cuts_per_person)
    } else {
      cat("\nIndividual fits unavailable: compute with per_rater = TRUE.\n")
    }
  } else if (x$per_rater_available) {
    cat("Individual cuts: summary(x, per_rater = TRUE).\n")
  }
  cat("Models and ratings remain in the original result: $models, $models_per_person, $data_used.\n")
  invisible(x)
}
