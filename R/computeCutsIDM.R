computeCutsIDM <- function(dat, boundaries = c(1.5, 2.5, 3.5, 4.5)) {

  # 1. Input Checks
  checkmate::assert_data_frame(dat)
  checkmate::assert_numeric(dat$est, any.missing = FALSE)
  checkmate::assert_numeric(boundaries, min.len = 1)

  # Determine number of levels
  n_cuts <- length(boundaries)
  max_val <- n_cuts + 1

  # Identify Rater columns
  person_cols <- grep("Rater", names(dat), value = TRUE)
  if (length(person_cols) == 0) {
    stop("No columns found containing 'Rater' in the name.")
  }

  # --- Internal Helper Functions ---
  # Dynamic padding based on max_val
  smooth_ma1 <- function(x, max_lv) {
    x <- as.numeric(x)
    n <- length(x)
    if (n < 3) return(x)
    x_ext <- c(1, x, max_lv) # Pad with 1 at start, max_val at end
    out <- vapply(seq_len(n), function(i) {
      mean(x_ext[i:(i + 2)], na.rm = TRUE)
    }, numeric(1))
    out
  }

  get_cut_scores <- function(x, y, b_vals) {
    ok <- is.finite(x) & is.finite(y)
    x_ok <- x[ok]
    y_ok <- y[ok]
    if (length(x_ok) < 2) return(rep(NA_real_, length(b_vals)))

    iso <- isoreg(x_ok, y_ok)
    y_iso <- iso$yf
    vapply(b_vals, function(b) {
      idx <- which(y_iso >= b)[1]
      if (is.na(idx)) return(NA_real_)
      x_ok[idx]
    }, numeric(1))
  }
  # ---------------------------------

  # 2. Preparation and Smoothing
  dat_sm <- dat %>%
    dplyr::arrange(est) %>%
    dplyr::mutate(dplyr::across(
      dplyr::all_of(person_cols),
      ~smooth_ma1(.x, max_lv = max_val),
      .names = "{.col}_sm"
    ))

  # 3. Calculate Cut Scores per Person
  cuts_per_person <- purrr::map_dfr(person_cols, function(p) {
    sm_col <- paste0(p, "_sm")
    df_sm <- dat_sm %>%
      dplyr::select(est, y_sm = dplyr::all_of(sm_col)) %>%
      tidyr::drop_na()

    cuts <- get_cut_scores(df_sm$est, df_sm$y_sm, boundaries)

    # Create dynamic column names (cut12, cut23, etc.)
    cut_names <- paste0("cut", 1:n_cuts, (1:n_cuts) + 1)
    res <- as.list(cuts)
    names(res) <- cut_names

    dplyr::bind_cols(tibble::tibble(person = p), tibble::as_tibble(res))
  })

  # 4. Summary
  cuts_summary <- cuts_per_person %>%
    dplyr::summarise(dplyr::across(dplyr::starts_with("cut"), ~mean(.x, na.rm = TRUE)))

  # 5. Prepare Long Data for Plotting
  iso_df <- dat_sm %>%
    dplyr::select(est, dplyr::all_of(person_cols), dplyr::ends_with("_sm")) %>%
    tidyr::pivot_longer(
      cols = dplyr::all_of(person_cols),
      names_to = "person",
      values_to = "stage_raw"
    ) %>%
    dplyr::left_join(
      dat_sm %>%
        dplyr::select(est, dplyr::ends_with("_sm")) %>%
        tidyr::pivot_longer(
          cols = dplyr::ends_with("_sm"),
          names_to = "person_sm",
          values_to = "stage_sm"
        ) %>%
        dplyr::mutate(person = gsub("_sm", "", person_sm)) %>%
        dplyr::select(-person_sm),
      by = c("est", "person")
    ) %>%
    dplyr::group_by(person) %>%
    dplyr::arrange(est) %>%
    dplyr::mutate(
      stage_iso = {
        ok <- is.finite(est) & is.finite(stage_sm)
        if (sum(ok) < 2) {
          rep(NA_real_, length(stage_sm))
        } else {
          iso <- isoreg(est[ok], stage_sm[ok])
          out <- rep(NA_real_, length(stage_sm))
          out[ok] <- iso$yf
          out
        }
      }
    ) %>%
    dplyr::ungroup()

  return(list(
    cuts_per_person = cuts_per_person,
    cuts_summary = cuts_summary,
    plot_data = iso_df,
    boundaries = boundaries,
    max_val = max_val
  ))
}
