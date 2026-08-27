.smooth_ma1_idm <- function(x, min_lv, max_lv, na_rm = TRUE) {
  x <- as.numeric(x)
  n <- length(x)
  if (n < 3) {
    return(x)
  }

  x_ext <- c(min_lv, x, max_lv)
  vapply(seq_len(n), function(i) {
    out <- mean(x_ext[i:(i + 2)], na.rm = na_rm)
    if (is.nan(out)) {
      NA_real_
    } else {
      out
    }
  }, numeric(1))
}

.smooth_group_idm <- function(x, min_lv, max_lv, missing) {
  if (missing == "smooth") {
    return(.smooth_ma1_idm(x, min_lv = min_lv, max_lv = max_lv, na_rm = TRUE))
  }

  out <- rep(NA_real_, length(x))
  ok <- is.finite(x)
  out[ok] <- .smooth_ma1_idm(x[ok], min_lv = min_lv, max_lv = max_lv, na_rm = FALSE)
  out
}

.get_cut_scores_idm <- function(x, y, b_vals) {
  ok <- is.finite(x) & is.finite(y)
  x_ok <- x[ok]
  y_ok <- y[ok]
  if (length(x_ok) < 2) {
    return(rep(NA_real_, length(b_vals)))
  }

  iso <- isoreg(x_ok, y_ok)
  y_iso <- iso$yf
  vapply(b_vals, function(b) {
    idx <- which(y_iso >= b)[1]
    if (is.na(idx)) {
      return(NA_real_)
    }
    x_ok[idx]
  }, numeric(1))
}

.get_stage_iso_idm <- function(est, stage_sm) {
  ok <- is.finite(est) & is.finite(stage_sm)
  if (sum(ok) < 2) {
    return(rep(NA_real_, length(stage_sm)))
  }

  iso <- isoreg(est[ok], stage_sm[ok])
  out <- rep(NA_real_, length(stage_sm))
  out[ok] <- iso$yf
  out
}

.mean_idm <- function(x) {
  if (all(is.na(x))) {
    return(NA_real_)
  }
  mean(x, na.rm = TRUE)
}

.sanitize_cut_label_idm <- function(x) {
  out <- gsub("[^A-Za-z0-9]+", "_", as.character(x))
  out <- gsub("^_+|_+$", "", out)
  out[out == ""] <- "x"
  out
}

.format_boundary_idm <- function(x) {
  .sanitize_cut_label_idm(format(x, trim = TRUE, scientific = FALSE))
}

.is_canonical_boundary_idm <- function(x) {
  lower <- floor(x)
  upper <- ceiling(x)
  upper == lower + 1 && abs(x - (lower + 0.5)) < 1e-8
}

.make_cut_names_idm <- function(boundaries, rating_labels = NULL, cut_labels = NULL) {
  if (!is.null(cut_labels)) {
    checkmate::assert_character(cut_labels, len = length(boundaries), any.missing = FALSE)
    if (anyDuplicated(cut_labels)) {
      stop("cut_labels must be unique.", call. = FALSE)
    }
    if (any(!startsWith(cut_labels, "cut"))) {
      stop("All cut_labels must start with 'cut' for plotCutsIDM() compatibility.", call. = FALSE)
    }
    return(cut_labels)
  }

  use_rating_labels <- !is.null(rating_labels)
  out <- vapply(boundaries, function(boundary) {
    lower <- floor(boundary)
    upper <- ceiling(boundary)
    canonical <- .is_canonical_boundary_idm(boundary)

    if (upper == lower + 1) {
      if (use_rating_labels && lower >= 1 && upper <= length(rating_labels)) {
        base <- paste0(
          "cut_",
          .sanitize_cut_label_idm(rating_labels[lower]),
          "_",
          .sanitize_cut_label_idm(rating_labels[upper])
        )
      } else {
        base <- paste0("cut", lower, upper)
      }

      if (canonical) {
        return(base)
      }
      return(paste0(base, "_bound", .format_boundary_idm(boundary)))
    }

    paste0("cut_b", .format_boundary_idm(boundary))
  }, character(1))

  if (anyDuplicated(out)) {
    stop("Cut labels are not unique. Please provide explicit cut_labels.", call. = FALSE)
  }
  out
}

.resolve_input_format_idm <- function(input_format, rater_id_col, rating_col) {
  has_rater_id <- !is.null(rater_id_col)
  has_rating <- !is.null(rating_col)

  if (input_format == "auto") {
    if (has_rater_id && has_rating) {
      return("long")
    }
    if (!has_rater_id && !has_rating) {
      return("wide")
    }
    stop("For long-format input, both rater_id_col and rating_col must be supplied.", call. = FALSE)
  }

  if (input_format == "long" && (!has_rater_id || !has_rating)) {
    stop("input_format = 'long' requires both rater_id_col and rating_col.", call. = FALSE)
  }

  if (input_format == "wide" && (has_rater_id || has_rating)) {
    stop("input_format = 'wide' cannot be combined with rater_id_col or rating_col.", call. = FALSE)
  }

  input_format
}

.prepare_long_idm <- function(dat, est_col, rater_cols, rater_pattern,
                              rater_id_col, rating_col, rating_levels,
                              input_format) {
  if (input_format == "wide") {
    person_cols <- rater_cols
    if (is.null(person_cols)) {
      person_cols <- grep(rater_pattern, names(dat), value = TRUE)
      person_cols <- setdiff(person_cols, est_col)
    } else {
      checkmate::assert_names(person_cols, subset.of = names(dat))
    }

    if (length(person_cols) == 0) {
      stop("No rater columns found.", call. = FALSE)
    }

    if (is.null(rating_levels)) {
      purrr::walk(person_cols, function(person_col) {
        checkmate::assert_numeric(dat[[person_col]])
      })
    }

    wide_dat <- tibble::tibble(est = dat[[est_col]])
    wide_dat[person_cols] <- dat[person_cols]
    if (!is.null(rating_levels)) {
      wide_dat <- wide_dat |>
        dplyr::mutate(dplyr::across(dplyr::all_of(person_cols), as.character))
    }

    dat_long <- wide_dat |>
      tidyr::pivot_longer(
        cols = dplyr::all_of(person_cols),
        names_to = "person",
        values_to = "stage_value"
      )
    rater_out <- person_cols
    names(rater_out) <- rater_out
    person_order <- person_cols
  } else {
    checkmate::assert_names(c(rater_id_col, rating_col), subset.of = names(dat))
    if (!is.atomic(dat[[rater_id_col]])) {
      stop("rater_id_col must identify an atomic vector.", call. = FALSE)
    }
    if (anyNA(dat[[rater_id_col]])) {
      stop("rater_id_col must not contain missing values.", call. = FALSE)
    }
    if (is.null(rating_levels)) {
      checkmate::assert_numeric(dat[[rating_col]])
    }

    dat_long <- tibble::tibble(
      est = dat[[est_col]],
      person = as.character(dat[[rater_id_col]]),
      stage_value = dat[[rating_col]]
    )
    person_order <- unique(dat_long$person)
    rater_out <- person_order
    names(rater_out) <- rater_out
  }

  list(
    dat_long = dat_long,
    person_order = person_order,
    rater_cols = rater_out
  )
}

.encode_ratings_idm <- function(stage_value, rating_levels) {
  if (is.null(rating_levels)) {
    stage_raw <- as.numeric(stage_value)
    if (any(!is.na(stage_raw) & !is.finite(stage_raw))) {
      stop("Rating values must be finite or missing.", call. = FALSE)
    }
    return(list(
      stage_raw = stage_raw,
      stage_label = as.character(stage_value),
      rating_labels = NULL,
      cut_rating_labels = NULL
    ))
  }

  if (!is.atomic(rating_levels) || length(rating_levels) < 2) {
    stop("rating_levels must be an atomic vector with at least two levels.", call. = FALSE)
  }
  if (anyNA(rating_levels)) {
    stop("rating_levels must not contain missing values.", call. = FALSE)
  }
  rating_labels <- as.character(rating_levels)
  if (anyDuplicated(rating_labels)) {
    stop("rating_levels must be unique after conversion to character.", call. = FALSE)
  }

  stage_chr <- as.character(stage_value)
  stage_raw <- match(stage_chr, rating_labels)
  stage_raw[is.na(stage_value)] <- NA_integer_
  unmatched <- is.na(stage_raw) & !is.na(stage_value)
  if (any(unmatched)) {
    bad_values <- unique(stage_chr[unmatched])
    stop(
      "Rating values not found in rating_levels: ",
      paste(bad_values, collapse = ", "),
      call. = FALSE
    )
  }

  cut_rating_labels <- rating_labels
  if (is.numeric(rating_levels) && identical(rating_levels, seq_along(rating_levels))) {
    cut_rating_labels <- NULL
  }

  list(
    stage_raw = as.numeric(stage_raw),
    stage_label = ifelse(is.na(stage_raw), NA_character_, rating_labels[stage_raw]),
    rating_labels = rating_labels,
    cut_rating_labels = cut_rating_labels
  )
}

computeCutsIDM <- function(dat, boundaries = c(1.5, 2.5, 3.5, 4.5),
                           est_col = "est", rater_cols = NULL,
                           rater_pattern = "Rater",
                           rater_id_col = NULL, rating_col = NULL,
                           input_format = c("auto", "long", "wide"),
                           rating_levels = NULL,
                           missing = c("drop", "smooth", "error"),
                           cut_labels = NULL) {

  boundaries_was_missing <- base::missing(boundaries)

  # 1. Input Checks
  checkmate::assert_data_frame(dat)
  checkmate::assert_string(est_col)
  checkmate::assert_names(est_col, subset.of = names(dat))
  checkmate::assert_numeric(dat[[est_col]], any.missing = FALSE)
  if (any(!is.finite(dat[[est_col]]))) {
    stop("est_col must contain only finite values.", call. = FALSE)
  }
  checkmate::assert_numeric(boundaries, min.len = 1, any.missing = FALSE)
  if (any(!is.finite(boundaries))) {
    stop("boundaries must contain only finite values.", call. = FALSE)
  }
  if (is.unsorted(boundaries, strictly = TRUE)) {
    stop("boundaries must be strictly increasing.", call. = FALSE)
  }
  checkmate::assert_character(rater_cols, any.missing = FALSE, null.ok = TRUE)
  checkmate::assert_string(rater_pattern)
  checkmate::assert_string(rater_id_col, null.ok = TRUE)
  checkmate::assert_string(rating_col, null.ok = TRUE)
  if (!is.null(rating_levels)) {
    if (!is.atomic(rating_levels) || length(rating_levels) < 2) {
      stop("rating_levels must be an atomic vector with at least two levels.", call. = FALSE)
    }
    if (anyNA(rating_levels)) {
      stop("rating_levels must not contain missing values.", call. = FALSE)
    }
  }
  missing <- match.arg(missing)
  input_format <- match.arg(input_format)
  input_format <- .resolve_input_format_idm(input_format, rater_id_col, rating_col)

  if (!is.null(rater_cols) && input_format == "long") {
    stop("rater_cols is only used for wide-format input.", call. = FALSE)
  }

  if (!is.null(rating_levels) && boundaries_was_missing) {
    boundaries <- seq_len(length(rating_levels) - 1) + 0.5
  }

  prepared <- .prepare_long_idm(
    dat = dat,
    est_col = est_col,
    rater_cols = rater_cols,
    rater_pattern = rater_pattern,
    rater_id_col = rater_id_col,
    rating_col = rating_col,
    rating_levels = rating_levels,
    input_format = input_format
  )
  dat_long <- prepared$dat_long

  encoded <- .encode_ratings_idm(dat_long$stage_value, rating_levels)
  dat_long$stage_raw <- encoded$stage_raw
  dat_long$stage_label <- encoded$stage_label

  if (missing == "error" && anyNA(dat_long$stage_raw)) {
    stop("Rating values must not contain missing values when missing = 'error'.", call. = FALSE)
  }

  finite_ratings <- dat_long$stage_raw[is.finite(dat_long$stage_raw)]
  if (length(finite_ratings) == 0) {
    stop("No finite rating values found.", call. = FALSE)
  }

  min_val <- min(c(finite_ratings, floor(min(boundaries))))
  max_val <- max(c(finite_ratings, ceiling(max(boundaries))))
  cut_names <- .make_cut_names_idm(
    boundaries = boundaries,
    rating_labels = encoded$cut_rating_labels,
    cut_labels = cut_labels
  )

  # 2. Preparation and Smoothing
  dat_sm <- dat_long |>
    dplyr::mutate(person = factor(person, levels = prepared$person_order)) |>
    dplyr::arrange(person, est) |>
    dplyr::group_by(person) |>
    dplyr::mutate(
      stage_sm = .smooth_group_idm(
        stage_raw,
        min_lv = min_val,
        max_lv = max_val,
        missing = missing
      ),
      stage_iso = .get_stage_iso_idm(est, stage_sm)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(person = as.character(person))

  # 3. Calculate Cut Scores per Person
  cuts_per_person <- purrr::map_dfr(prepared$person_order, function(p) {
    df_sm <- dat_sm |>
      dplyr::filter(person == p) |>
      dplyr::select(est, y_sm = stage_sm)

    cuts <- .get_cut_scores_idm(df_sm$est, df_sm$y_sm, boundaries)
    res <- as.list(cuts)
    names(res) <- cut_names

    dplyr::bind_cols(tibble::tibble(person = p), tibble::as_tibble(res))
  })

  # 4. Summary
  cuts_summary <- cuts_per_person |>
    dplyr::summarise(dplyr::across(dplyr::starts_with("cut"), .mean_idm))

  # 5. Prepare Long Data for Plotting
  iso_df <- dat_sm |>
    dplyr::select(est, person, stage_raw, stage_sm, stage_iso, stage_label)

  return(list(
    cuts_per_person = cuts_per_person,
    cuts_summary = cuts_summary,
    plot_data = iso_df,
    boundaries = boundaries,
    cut_labels = cut_names,
    min_val = min_val,
    max_val = max_val,
    est_col = est_col,
    rater_cols = prepared$rater_cols,
    rater_id_col = rater_id_col,
    rating_col = rating_col,
    rating_levels = rating_levels,
    rating_labels = encoded$rating_labels,
    input_format = input_format,
    missing = missing
  ))
}
