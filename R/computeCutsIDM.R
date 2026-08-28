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

.get_cut_scores_idm <- function(x, y, b_vals, position = seq_along(x)) {
  ok <- is.finite(x) & is.finite(y)
  x_ok <- x[ok]
  y_ok <- y[ok]
  position_ok <- position[ok]
  if (length(x_ok) < 2) {
    return(list(
      cut = rep(NA_real_, length(b_vals)),
      position = rep(NA_real_, length(b_vals))
    ))
  }

  ord <- order(x_ok)
  x_ok <- x_ok[ord]
  y_ok <- y_ok[ord]
  position_ok <- position_ok[ord]

  cut_mat <- vapply(b_vals, function(b) {
    idx <- which(y_ok >= b)[1]
    if (is.na(idx)) {
      return(c(cut = NA_real_, position = NA_real_))
    }
    if (idx == 1) {
      return(c(cut = x_ok[1], position = position_ok[1]))
    }

    x0 <- x_ok[idx - 1]
    x1 <- x_ok[idx]
    y0 <- y_ok[idx - 1]
    y1 <- y_ok[idx]
    position0 <- position_ok[idx - 1]
    position1 <- position_ok[idx]
    if (y1 == y0) {
      return(c(cut = x1, position = position1))
    }

    ratio <- (b - y0) / (y1 - y0)
    c(
      cut = x0 + ratio * (x1 - x0),
      position = position0 + ratio * (position1 - position0)
    )
  }, numeric(2))

  list(
    cut = unname(cut_mat["cut", ]),
    position = unname(cut_mat["position", ])
  )
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

.cut_stats_idm <- function(x) {
  x <- x[is.finite(x)]
  if (length(x) == 0) {
    return(c(Mean = NA_real_, SD = NA_real_, SE = NA_real_))
  }
  if (length(x) == 1) {
    return(c(Mean = mean(x), SD = NA_real_, SE = NA_real_))
  }

  sd_x <- stats::sd(x)
  c(Mean = mean(x), SD = sd_x, SE = sd_x / sqrt(length(x)))
}

.make_cut_statistics_idm <- function(cuts_per_person, cut_positions_per_person,
                                     cut_names) {
  out <- data.frame(statistic = c("Mean", "SD", "SE"), check.names = FALSE)

  for (cut_name in cut_names) {
    out[[paste0("page_", cut_name)]] <-
      .cut_stats_idm(cut_positions_per_person[[paste0("page_", cut_name)]])
  }
  for (cut_name in cut_names) {
    out[[paste0("diff_", cut_name)]] <-
      .cut_stats_idm(cuts_per_person[[cut_name]])
  }

  tibble::as_tibble(out)
}

.format_interval_value_idm <- function(x) {
  format(round(x, 2), trim = TRUE, scientific = FALSE)
}

.make_level_statistics_idm <- function(item_difficulties, cut_values) {
  item_difficulties <- item_difficulties[is.finite(item_difficulties)]
  cut_values <- cut_values[is.finite(cut_values)]

  if (length(item_difficulties) == 0) {
    return(tibble::tibble(
      level = integer(),
      interval = character(),
      n_items = integer(),
      mean_itemdiff = numeric(),
      sd_itemdiff = numeric()
    ))
  }

  break_values <- c(min(item_difficulties), cut_values, max(item_difficulties))
  n_levels <- length(break_values) - 1

  purrr::map_dfr(seq_len(n_levels), function(level) {
    lower <- break_values[level]
    upper <- break_values[level + 1]
    if (level == n_levels) {
      in_level <- item_difficulties >= lower & item_difficulties <= upper
    } else {
      in_level <- item_difficulties >= lower & item_difficulties < upper
    }
    values <- item_difficulties[in_level]

    tibble::tibble(
      level = level,
      interval = paste0(
        "[",
        .format_interval_value_idm(lower),
        ",",
        .format_interval_value_idm(upper),
        if (level == n_levels) "]" else ")"
      ),
      n_items = length(values),
      mean_itemdiff = if (length(values) == 0) NA_real_ else mean(values),
      sd_itemdiff = if (length(values) < 2) NA_real_ else stats::sd(values)
    )
  })
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

.make_item_table_idm <- function(dat_long) {
  item_est <- dat_long |>
    dplyr::distinct(item_id, est)
  ambiguous_items <- item_est |>
    dplyr::count(item_id, name = "n_est") |>
    dplyr::filter(n_est > 1)
  if (nrow(ambiguous_items) > 0) {
    stop("Each item_id_col value must map to exactly one est_col value.", call. = FALSE)
  }

  item_order <- unique(dat_long$item_id)
  item_est |>
    dplyr::mutate(.item_order = match(item_id, item_order)) |>
    dplyr::arrange(est, .item_order) |>
    dplyr::mutate(item_position = dplyr::row_number()) |>
    dplyr::select(item_id, est, item_position)
}

.assert_unique_long_cells_idm <- function(dat_long, item_id_col) {
  duplicate_cell <- duplicated(dat_long[c("person", "item_id")])
  if (!any(duplicate_cell)) {
    return(invisible(NULL))
  }

  if (is.null(item_id_col)) {
    stop(
      "Long-format input without item_id_col requires at most one rating per ",
      "rater and est_col value. Provide item_id_col when different items can ",
      "share the same difficulty estimate.",
      call. = FALSE
    )
  }

  stop(
    "Long-format input must contain at most one rating per rater and item_id_col value.",
    call. = FALSE
  )
}

.complete_long_grid_idm <- function(dat_long, person_order, item_table) {
  tidyr::expand_grid(
    person = person_order,
    item_id = item_table$item_id
  ) |>
    dplyr::left_join(
      dat_long |> dplyr::select(person, item_id, stage_value),
      by = c("person", "item_id")
    ) |>
    dplyr::left_join(item_table, by = "item_id") |>
    dplyr::mutate(person = factor(person, levels = person_order)) |>
    dplyr::arrange(person, item_position) |>
    dplyr::mutate(person = as.character(person))
}

.prepare_long_idm <- function(dat, est_col, rater_cols, rater_pattern,
                              item_id_col, rater_id_col, rating_col,
                              rating_levels, input_format) {
  if (input_format == "wide") {
    person_cols <- rater_cols
    if (is.null(person_cols)) {
      person_cols <- grep(rater_pattern, names(dat), value = TRUE)
      person_cols <- setdiff(person_cols, c(est_col, item_id_col))
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
    if (!is.null(item_id_col)) {
      checkmate::assert_names(item_id_col, subset.of = names(dat))
      if (!is.atomic(dat[[item_id_col]])) {
        stop("item_id_col must identify an atomic vector.", call. = FALSE)
      }
      if (anyNA(dat[[item_id_col]])) {
        stop("item_id_col must not contain missing values.", call. = FALSE)
      }
      item_id <- as.character(dat[[item_id_col]])
      if (anyDuplicated(item_id)) {
        stop("item_id_col must identify unique items in wide-format input.", call. = FALSE)
      }
    } else {
      item_id <- as.character(seq_len(nrow(dat)))
    }

    wide_dat <- tibble::tibble(item_id = item_id, est = dat[[est_col]])
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
    item_table <- .make_item_table_idm(dat_long)
    dat_long <- dat_long |>
      dplyr::left_join(
        item_table |> dplyr::select(item_id, item_position),
        by = "item_id"
      )
    rater_out <- person_cols
    names(rater_out) <- rater_out
    person_order <- person_cols
  } else {
    long_cols <- c(rater_id_col, rating_col, item_id_col)
    checkmate::assert_names(long_cols, subset.of = names(dat))
    if (!is.atomic(dat[[rater_id_col]])) {
      stop("rater_id_col must identify an atomic vector.", call. = FALSE)
    }
    if (anyNA(dat[[rater_id_col]])) {
      stop("rater_id_col must not contain missing values.", call. = FALSE)
    }
    if (is.null(rating_levels)) {
      checkmate::assert_numeric(dat[[rating_col]])
    }
    if (!is.null(item_id_col)) {
      if (!is.atomic(dat[[item_id_col]])) {
        stop("item_id_col must identify an atomic vector.", call. = FALSE)
      }
      if (anyNA(dat[[item_id_col]])) {
        stop("item_id_col must not contain missing values.", call. = FALSE)
      }
      item_id <- as.character(dat[[item_id_col]])
    } else {
      item_id <- as.character(dat[[est_col]])
    }

    dat_long <- tibble::tibble(
      item_id = item_id,
      est = dat[[est_col]],
      person = as.character(dat[[rater_id_col]]),
      stage_value = dat[[rating_col]]
    )
    person_order <- unique(dat_long$person)
    .assert_unique_long_cells_idm(dat_long, item_id_col = item_id_col)
    item_table <- .make_item_table_idm(dat_long)
    dat_long <- .complete_long_grid_idm(
      dat_long = dat_long,
      person_order = person_order,
      item_table = item_table
    )
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
                           est_col = "est", item_id_col = NULL,
                           rater_cols = NULL, rater_pattern = "Rater",
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
  checkmate::assert_string(item_id_col, null.ok = TRUE)
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
    item_id_col = item_id_col,
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
    dplyr::arrange(person, item_position) |>
    dplyr::group_by(person) |>
    dplyr::mutate(
      stage_sm = .smooth_group_idm(
        stage_raw,
        min_lv = min_val,
        max_lv = max_val,
        missing = missing
      ),
      stage_iso = .get_stage_iso_idm(est, stage_sm),
      stage_resid = stage_raw - stage_sm
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(person = as.character(person))

  # 3. Calculate Cut Scores per Person
  cuts_per_person_list <- purrr::map(prepared$person_order, function(p) {
    df_sm <- dat_sm |>
      dplyr::filter(person == p) |>
      dplyr::select(est, item_position, y_iso = stage_iso)

    cuts <- .get_cut_scores_idm(
      x = df_sm$est,
      y = df_sm$y_iso,
      b_vals = boundaries,
      position = df_sm$item_position
    )

    list(person = p, cut = cuts$cut, position = cuts$position)
  })

  cuts_per_person <- purrr::map_dfr(cuts_per_person_list, function(cuts) {
    res <- as.list(cuts$cut)
    names(res) <- cut_names

    dplyr::bind_cols(tibble::tibble(person = cuts$person), tibble::as_tibble(res))
  })

  cut_positions_per_person <- purrr::map_dfr(cuts_per_person_list, function(cuts) {
    res <- as.list(cuts$position)
    names(res) <- paste0("page_", cut_names)

    dplyr::bind_cols(tibble::tibble(person = cuts$person), tibble::as_tibble(res))
  })

  # 4. Summary
  cuts_summary <- cuts_per_person |>
    dplyr::summarise(dplyr::across(dplyr::starts_with("cut"), .mean_idm))
  cut_statistics <- .make_cut_statistics_idm(
    cuts_per_person = cuts_per_person,
    cut_positions_per_person = cut_positions_per_person,
    cut_names = cut_names
  )
  item_difficulties <- dat_sm |>
    dplyr::distinct(item_position, item_id, est) |>
    dplyr::arrange(item_position) |>
    dplyr::pull(est)
  level_statistics <- .make_level_statistics_idm(
    item_difficulties = item_difficulties,
    cut_values = as.numeric(cuts_summary[1, cut_names])
  )

  # 5. Prepare Long Data for Plotting
  iso_df <- dat_sm |>
    dplyr::select(
      item_id, est, person, item_position, stage_raw, stage_sm, stage_iso,
      stage_resid, stage_label
    )

  structure(list(
    cuts_per_person = cuts_per_person,
    cut_positions_per_person = cut_positions_per_person,
    cuts_summary = cuts_summary,
    cut_statistics = cut_statistics,
    level_statistics = level_statistics,
    plot_data = iso_df,
    boundaries = boundaries,
    cut_labels = cut_names,
    min_val = min_val,
    max_val = max_val,
    est_col = est_col,
    item_id_col = item_id_col,
    rater_cols = prepared$rater_cols,
    rater_id_col = rater_id_col,
    rating_col = rating_col,
    rating_levels = rating_levels,
    rating_labels = encoded$rating_labels,
    input_format = input_format,
    missing = missing
  ), class = c("cutsIDM", "list"))
}
