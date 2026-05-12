plotCutsIDM <- function(res_list, est_col = NULL) {

  checkmate::assert_list(res_list)
  checkmate::assert_string(est_col, null.ok = TRUE)

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

  cuts_long <- res_list$cuts_per_person |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("cut"),
      names_to = "cut_type",
      values_to = "cut"
    )

  pp <- ggplot2::ggplot(res_list$plot_data, ggplot2::aes(x = est)) +
    ggplot2::geom_point(ggplot2::aes(y = stage_raw), alpha = 0.35, size = 1) +
    ggplot2::geom_line(ggplot2::aes(y = stage_sm), linewidth = 1, color = "blue") +
    ggplot2::geom_line(ggplot2::aes(y = stage_iso), linewidth = 1, color = "red", linetype = "solid") +
    ggplot2::geom_hline(yintercept = res_list$boundaries, linetype = 2, color = "grey60") +
    ggplot2::geom_vline(
      data = cuts_long,
      ggplot2::aes(xintercept = cut, color = cut_type),
      linewidth = .8,
      alpha = 0.8,
      linetype = "solid"
    ) +
    ggplot2::facet_wrap(~ person, ncol = 2) +
    ggplot2::scale_y_continuous(breaks = y_breaks, limits = y_limits) +
    ggplot2::labs(
      x = paste0("Itemschwierigkeit (", x_label, ")"),
      y = "Stufe",
      color = "Cut Score"
    ) +
    ggplot2::theme_minimal()

  return(pp)
}
