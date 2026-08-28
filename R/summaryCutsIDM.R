.null_chr_idm <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }
  as.character(x)
}

.count_unique_idm <- function(x) {
  if (is.null(x)) {
    return(NA_integer_)
  }
  length(unique(x[!is.na(x)]))
}

.level_label_idm <- function(level, rating_labels) {
  if (
    !is.null(rating_labels) &&
      is.finite(level) &&
      level >= 1 &&
      level <= length(rating_labels)
  ) {
    return(as.character(rating_labels[level]))
  }

  as.character(level)
}

.make_boundary_summary_idm <- function(object) {
  boundaries <- object$boundaries
  if (is.null(boundaries)) {
    return(tibble::tibble(
      cut = character(),
      boundary = numeric(),
      lower_level = character(),
      upper_level = character()
    ))
  }

  cut_labels <- object$cut_labels
  if (is.null(cut_labels) || length(cut_labels) != length(boundaries)) {
    cut_labels <- paste0("cut", seq_along(boundaries))
  }

  lower_level <- floor(boundaries)
  upper_level <- ceiling(boundaries)
  rating_labels <- object$rating_labels

  tibble::tibble(
    cut = cut_labels,
    boundary = boundaries,
    lower_level = vapply(lower_level, .level_label_idm, character(1),
                         rating_labels = rating_labels),
    upper_level = vapply(upper_level, .level_label_idm, character(1),
                         rating_labels = rating_labels)
  )
}

.round_numeric_columns_idm <- function(x, digits) {
  if (!is.data.frame(x)) {
    return(x)
  }

  out <- x
  numeric_cols <- vapply(out, is.double, logical(1))
  out[numeric_cols] <- lapply(out[numeric_cols], round, digits = digits)
  out
}

.print_idm_summary_table <- function(title, x, digits, ...) {
  if (is.null(x)) {
    return(invisible(NULL))
  }

  cat("\n", title, "\n", sep = "")
  print(as.data.frame(.round_numeric_columns_idm(x, digits = digits)),
        row.names = FALSE, ...)
  invisible(NULL)
}

summary.cutsIDM <- function(object, digits = NULL, ...) {
  checkmate::assert_class(object, "cutsIDM")
  if (!is.null(digits)) {
    checkmate::assert_integerish(digits, len = 1, lower = 0, any.missing = FALSE)
    digits <- as.integer(digits)
  }

  settings <- tibble::tibble(
    input_format = .null_chr_idm(object$input_format),
    missing = .null_chr_idm(object$missing),
    est_col = .null_chr_idm(object$est_col),
    n_raters = .count_unique_idm(object$cuts_per_person$person),
    n_items = .count_unique_idm(object$plot_data$item_position),
    n_cuts = length(object$boundaries)
  )

  out <- list(
    settings = settings,
    boundaries = .make_boundary_summary_idm(object),
    cuts_summary = object$cuts_summary,
    cut_statistics = object$cut_statistics,
    level_statistics = object$level_statistics
  )
  class(out) <- c("summary.cutsIDM", "list")
  attr(out, "digits") <- digits
  out
}

print.summary.cutsIDM <- function(x, digits = NULL, ...) {
  checkmate::assert_list(x)
  if (is.null(digits)) {
    digits <- attr(x, "digits", exact = TRUE)
  }
  if (is.null(digits)) {
    digits <- 2L
  }
  checkmate::assert_integerish(digits, len = 1, lower = 0, any.missing = FALSE)
  digits <- as.integer(digits)

  cat("IDM cut-score summary\n")
  .print_idm_summary_table("Settings", x$settings, digits = digits, ...)
  .print_idm_summary_table("Boundaries", x$boundaries, digits = digits, ...)
  .print_idm_summary_table("Mean cuts on difficulty scale", x$cuts_summary,
                           digits = digits, ...)
  .print_idm_summary_table("Cut statistics", x$cut_statistics,
                           digits = digits, ...)
  .print_idm_summary_table("Level statistics", x$level_statistics,
                           digits = digits, ...)

  invisible(x)
}
