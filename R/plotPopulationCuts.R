plotPopulationCuts <- function(cuts, pv_data, pv_cols = NULL,
                               respondent_id_col = NULL,
                               pv_id_col = NULL, pv_value_col = NULL,
                               weight_col = NULL,
                               input_format = c("auto", "long", "wide"),
                               pv_missing = c("error", "drop"),
                               density_bw = NULL, density_adjust = 1,
                               cut_labels = NULL, est_col = NULL,
                               show_cut_values = TRUE,
                               cut_value_digits = 0L, cut_value_size = 2.6,
                               population_fill = "grey50", population_alpha = 0.25,
                               population_col = NULL, population_colors = NULL,
                               show_percentages = TRUE, percentage_digits = 1L,
                               percentage_size = 3,
                               show_population_stats = TRUE, population_stats_digits = 2L,
                               show_caption = FALSE) {
  checkmate::assert_numeric(cuts, min.len = 1, finite = TRUE, any.missing = FALSE)
  if (!is.null(dim(cuts))) {
    stop("cuts must be a numeric vector.", call. = FALSE)
  }
  if (is.unsorted(cuts, strictly = TRUE)) {
    stop("cuts must be strictly increasing.", call. = FALSE)
  }
  if (is.null(cut_labels)) cut_labels <- paste0("cut", seq_along(cuts))
  checkmate::assert_character(cut_labels, len = length(cuts), any.missing = FALSE,
                             unique = TRUE)
  if (any(!nzchar(trimws(cut_labels)))) {
    stop("cut_labels must not contain empty labels.", call. = FALSE)
  }
  checkmate::assert_string(est_col, null.ok = TRUE)
  checkmate::assert_flag(show_cut_values)
  checkmate::assert_integerish(cut_value_digits, len = 1, lower = 0, any.missing = FALSE)
  checkmate::assert_number(cut_value_size, lower = 0, finite = TRUE)
  checkmate::assert_flag(show_caption)
  .validate_percentages_idm(show_percentages, percentage_digits, percentage_size)
  .validate_population_moments_idm(show_population_stats, population_stats_digits)
  .validate_population_style_idm(population_fill, population_alpha)

  dat <- .prepare_population_idm(
    pv_data, pv_cols, respondent_id_col, pv_id_col, pv_value_col,
    weight_col, input_format, pv_missing, population_col
  )
  density <- .population_density_idm(dat, density_bw, density_adjust)
  style <- .population_style_idm(
    density, if (missing(population_fill)) NULL else population_fill, population_colors
  )
  cut_table <- data.frame(
    cut = unname(cuts), cut_type = factor(cut_labels, levels = cut_labels),
    .facet_person = factor("Cuts", levels = "Cuts")
  )
  pp <- .plot_population_cuts_idm(
    dat, density, cut_table, style$colors, style$fill, population_alpha,
    x_label = if (is.null(est_col)) "Score" else paste0("Score (", est_col, ")"),
    show_cut_values, cut_value_digits, cut_value_size,
    show_percentages, percentage_digits, percentage_size,
    show_population_stats, population_stats_digits, show_caption
  ) + ggplot2::theme(strip.text = ggplot2::element_blank(),
                     strip.background = ggplot2::element_blank())

  # Keep unrounded estimates accessible even when their display is switched off.
  values <- .population_percentages_idm(dat, cut_table)$values
  attr(pp, "population_percentages") <- data.frame(
    population = as.character(values$.population), interval = values$.interval,
    lower = values$.lower, upper = values$.upper, percentage = values$.percentage
  )
  pp
}
