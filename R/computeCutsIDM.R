.smooth_ma1_idm <- function(x, max_lv) {
  x <- as.numeric(x)
  n <- length(x)
  if (n < 3) {
    return(x)
  }

  x_ext <- c(1, x, max_lv)
  vapply(seq_len(n), function(i) {
    mean(x_ext[i:(i + 2)], na.rm = TRUE)
  }, numeric(1))
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

computeCutsIDM <- function(dat, boundaries = c(1.5, 2.5, 3.5, 4.5),
                           est_col = "est", rater_cols = NULL,
                           rater_pattern = "Rater") {

  # 1. Input Checks
  checkmate::assert_data_frame(dat)
  checkmate::assert_string(est_col)
  checkmate::assert_names(est_col, subset.of = names(dat))
  checkmate::assert_numeric(dat[[est_col]], any.missing = FALSE)
  checkmate::assert_numeric(boundaries, min.len = 1)
  checkmate::assert_character(rater_cols, any.missing = FALSE, null.ok = TRUE)
  checkmate::assert_string(rater_pattern)

  # Determine number of levels
  n_cuts <- length(boundaries)
  max_val <- n_cuts + 1

  # Identify Rater columns
  person_cols <- rater_cols
  if (is.null(person_cols)) {
    person_cols <- grep(rater_pattern, names(dat), value = TRUE)
  } else {
    checkmate::assert_names(person_cols, subset.of = names(dat))
  }

  if (length(person_cols) == 0) {
    stop("No rater columns found.", call. = FALSE)
  }
  purrr::walk(person_cols, function(person_col) {
    checkmate::assert_numeric(dat[[person_col]], any.missing = FALSE)
  })

  dat <- dat |>
    dplyr::rename(est = dplyr::all_of(est_col))
  names(person_cols) <- person_cols
  person_renames <- paste0("rater_", seq_along(person_cols))
  dat <- dat |>
    dplyr::rename(dplyr::all_of(stats::setNames(person_cols, person_renames)))
  person_cols_internal <- person_renames
  person_lookup <- tibble::tibble(
    person = person_cols_internal,
    person_label = unname(person_cols)
  )

  if (length(intersect(person_cols_internal, names(dat))) != length(person_cols_internal)) {
    stop("Rater columns could not be prepared.", call. = FALSE)
  }

  # 2. Preparation and Smoothing
  dat_sm <- dat |>
    dplyr::arrange(est) |>
    dplyr::mutate(dplyr::across(
      dplyr::all_of(person_cols_internal),
      ~.smooth_ma1_idm(.x, max_lv = max_val),
      .names = "{.col}_sm"
    ))

  # 3. Calculate Cut Scores per Person
  cuts_per_person <- purrr::map_dfr(person_cols_internal, function(p) {
    sm_col <- paste0(p, "_sm")
    df_sm <- dat_sm |>
      dplyr::select(est, y_sm = dplyr::all_of(sm_col)) |>
      tidyr::drop_na()

    cuts <- .get_cut_scores_idm(df_sm$est, df_sm$y_sm, boundaries)

    # Create dynamic column names (cut12, cut23, etc.)
    cut_names <- paste0("cut", 1:n_cuts, (1:n_cuts) + 1)
    res <- as.list(cuts)
    names(res) <- cut_names

    dplyr::bind_cols(tibble::tibble(person = p), tibble::as_tibble(res))
  })

  # 4. Summary
  cuts_summary <- cuts_per_person |>
    dplyr::summarise(dplyr::across(dplyr::starts_with("cut"), ~mean(.x, na.rm = TRUE)))

  # 5. Prepare Long Data for Plotting
  iso_df <- dat_sm |>
    dplyr::select(est, dplyr::all_of(person_cols_internal), dplyr::ends_with("_sm")) |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(person_cols_internal),
      names_to = "person",
      values_to = "stage_raw"
    ) |>
    dplyr::left_join(
      dat_sm |>
        dplyr::select(est, dplyr::ends_with("_sm")) |>
        tidyr::pivot_longer(
          cols = dplyr::ends_with("_sm"),
          names_to = "person_sm",
          values_to = "stage_sm"
        ) |>
        dplyr::mutate(person = gsub("_sm", "", person_sm)) |>
        dplyr::select(-person_sm),
      by = c("est", "person")
    ) |>
    dplyr::group_by(person) |>
    dplyr::arrange(est) |>
    dplyr::mutate(stage_iso = .get_stage_iso_idm(est, stage_sm)) |>
    dplyr::ungroup() |>
    dplyr::left_join(person_lookup, by = "person") |>
    dplyr::mutate(person = person_label) |>
    dplyr::select(-person_label)

  cuts_per_person <- cuts_per_person |>
    dplyr::left_join(person_lookup, by = "person") |>
    dplyr::mutate(person = person_label) |>
    dplyr::select(-person_label)

  return(list(
    cuts_per_person = cuts_per_person,
    cuts_summary = cuts_summary,
    plot_data = iso_df,
    boundaries = boundaries,
    max_val = max_val,
    est_col = est_col,
    rater_cols = person_cols
  ))
}
