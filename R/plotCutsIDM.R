plotCutsIDM <- function(res_list) {

  checkmate::assert_list(res_list)

  # Determine axis limits dynamically
  max_lv <- res_list$max_val

  cuts_long <- res_list$cuts_per_person %>%
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
    ggplot2::scale_y_continuous(breaks = 1:max_lv, limits = c(1, max_lv)) +
    ggplot2::labs(
      x = "Itemschwierigkeit (est)",
      y = "Stufe",
      color = "Cut Score"
    ) +
    ggplot2::theme_minimal()

  return(pp)
}
