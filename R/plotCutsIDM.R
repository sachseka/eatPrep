plotCutsIDM <- function(res_list, est_col = NULL,
                        show_raw = TRUE, show_smoothed = TRUE) {

  checkmate::assert_list(res_list)
  checkmate::assert_string(est_col, null.ok = TRUE)
  checkmate::assert_flag(show_raw)
  checkmate::assert_flag(show_smoothed)

  # Determine axis limits dynamically
  max_lv <- res_list$max_val
  x_label <- est_col
  if (is.null(x_label)) {
    x_label <- res_list$est_col
  }
  if (is.null(x_label)) {
    x_label <- "est"
  }
  y_vals <- res_list$plot_data$stage_raw
  y_vals <- y_vals[is.finite(y_vals)]
  if (length(y_vals) == 0) {
    y_limits <- c(1, max_lv)
  } else {
    y_limits <- range(y_vals)
  }
  if (y_limits[1] == y_limits[2]) {
    y_limits <- y_limits + c(-0.5, 0.5)
  }
  y_breaks <- seq(floor(y_limits[1]), ceiling(y_limits[2]), by = 1)
  y_labels <- ggplot2::waiver()
  if (!is.null(res_list$rating_labels)) {
    y_breaks <- y_breaks[y_breaks >= 1 & y_breaks <= length(res_list$rating_labels)]
    y_labels <- res_list$rating_labels[y_breaks]
  }

  cuts_long <- res_list$cuts_per_person |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("cut"),
      names_to = "cut_type",
      values_to = "cut"
    )

  pp <- ggplot2::ggplot(res_list$plot_data, ggplot2::aes(x = est))

  if (show_raw) {
    pp <- pp +
      ggplot2::geom_line(
        ggplot2::aes(y = stage_raw, group = person),
        linewidth = 0.3,
        color = "grey45",
        alpha = 0.7,
        na.rm = TRUE
      ) +
      ggplot2::geom_point(ggplot2::aes(y = stage_raw), alpha = 0.35, size = 1, na.rm = TRUE)
  }

  if (show_smoothed) {
    pp <- pp +
      ggplot2::geom_line(
        ggplot2::aes(y = stage_sm, group = person),
        linewidth = 0.45,
        color = "blue",
        alpha = 0.8,
        na.rm = TRUE
      )
  }

  pp <- pp +
    ggplot2::geom_line(
      ggplot2::aes(y = stage_iso, group = person),
      linewidth = 0.9,
      color = "red",
      linetype = "solid",
      na.rm = TRUE
    ) +
    ggplot2::geom_hline(yintercept = res_list$boundaries, linetype = 2, color = "grey60") +
    ggplot2::geom_vline(
      data = cuts_long,
      ggplot2::aes(xintercept = cut, color = cut_type),
      linewidth = .8,
      alpha = 0.8,
      linetype = "solid"
    ) +
    ggplot2::facet_wrap(~ person, ncol = 2) +
    ggplot2::scale_y_continuous(breaks = y_breaks, labels = y_labels, limits = y_limits) +
    ggplot2::labs(
      x = paste0("Itemschwierigkeit (", x_label, ")"),
      y = "Stufe",
      color = "Cut Score"
    ) +
    ggplot2::theme_minimal()

  return(pp)
}
