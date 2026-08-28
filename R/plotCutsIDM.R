.aggregate_panel_label_idm <- function(persons) {
  label <- "Mean"
  if (!label %in% persons) {
    return(label)
  }

  idx <- 1L
  repeat {
    candidate <- paste0("Mean_", idx)
    if (!candidate %in% persons) {
      return(candidate)
    }
    idx <- idx + 1L
  }
}

.aggregate_line_label_data_idm <- function(dat) {
  dat |>
    dplyr::filter(is.finite(est), is.finite(stage_iso)) |>
    dplyr::arrange(person, est, item_position) |>
    dplyr::group_by(person) |>
    dplyr::slice_tail(n = 1) |>
    dplyr::ungroup()
}

plotCutsIDM <- function(res_list, est_col = NULL,
                        show_raw = TRUE, show_smoothed = TRUE,
                        show_residuals = FALSE,
                        show_aggregate = FALSE,
                        show_aggregate_labels = TRUE) {

  checkmate::assert_list(res_list)
  checkmate::assert_string(est_col, null.ok = TRUE)
  checkmate::assert_flag(show_raw)
  checkmate::assert_flag(show_smoothed)
  checkmate::assert_flag(show_residuals)
  checkmate::assert_flag(show_aggregate)
  checkmate::assert_flag(show_aggregate_labels)

  # Determine axis limits dynamically
  max_lv <- res_list$max_val
  plot_data <- res_list$plot_data
  if (!"stage_resid" %in% names(plot_data)) {
    plot_data$stage_resid <- plot_data$stage_raw - plot_data$stage_sm
  }
  x_label <- est_col
  if (is.null(x_label)) {
    x_label <- res_list$est_col
  }
  if (is.null(x_label)) {
    x_label <- "est"
  }
  y_vals <- plot_data$stage_raw
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

  person_order <- as.character(unique(plot_data$person))
  aggregate_label <- NULL
  facet_levels <- person_order
  if (show_aggregate) {
    aggregate_label <- .aggregate_panel_label_idm(person_order)
    facet_levels <- c(facet_levels, aggregate_label)
  }

  cuts_long <- res_list$cuts_per_person |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("cut"),
      names_to = "cut_type",
      values_to = "cut"
    ) |>
    dplyr::mutate(
      .facet_person = factor(person, levels = facet_levels)
    )
  mean_cuts_long <- NULL
  if (show_aggregate) {
    mean_cuts_long <- res_list$cuts_summary |>
      tidyr::pivot_longer(
        cols = dplyr::starts_with("cut"),
        names_to = "cut_type",
        values_to = "cut"
      ) |>
      dplyr::mutate(
        person = aggregate_label,
        .facet_person = factor(aggregate_label, levels = facet_levels)
      )
  }

  if (show_residuals) {
    panel_levels <- c("Ratings", "Residuals")
    rating_data <- plot_data |>
      dplyr::mutate(
        .panel = factor("Ratings", levels = panel_levels),
        .facet_person = factor(person, levels = facet_levels)
      )
    residual_data <- plot_data |>
      dplyr::mutate(
        .panel = factor("Residuals", levels = panel_levels),
        .facet_person = factor(person, levels = facet_levels)
      )
    aggregate_rating_data <- NULL
    aggregate_label_data <- NULL
    if (show_aggregate) {
      aggregate_rating_data <- plot_data |>
        dplyr::mutate(
          .panel = factor("Ratings", levels = panel_levels),
          .facet_person = factor(aggregate_label, levels = facet_levels)
        )
      if (show_aggregate_labels) {
        aggregate_label_data <- .aggregate_line_label_data_idm(aggregate_rating_data)
      }
    }
    boundary_data <- tibble::tibble(
      .panel = factor("Ratings", levels = panel_levels),
      boundary = res_list$boundaries
    )
    zero_data <- tibble::tibble(
      .panel = factor("Residuals", levels = panel_levels),
      zero = 0
    )

    pp <- ggplot2::ggplot()

    if (show_raw) {
      pp <- pp +
        ggplot2::geom_line(
          data = rating_data,
          ggplot2::aes(x = est, y = stage_raw, group = person),
          linewidth = 0.3,
          color = "grey45",
          alpha = 0.7,
          na.rm = TRUE
        ) +
        ggplot2::geom_point(
          data = rating_data,
          ggplot2::aes(x = est, y = stage_raw),
          alpha = 0.35,
          size = 1,
          na.rm = TRUE
        )
    }

    pp <- pp +
      ggplot2::geom_line(
        data = rating_data,
        ggplot2::aes(x = est, y = stage_iso, group = person),
        linewidth = 0.9,
        color = "red",
        linetype = "solid",
        na.rm = TRUE
      )

    if (show_aggregate) {
      pp <- pp +
        ggplot2::geom_line(
          data = aggregate_rating_data,
          ggplot2::aes(x = est, y = stage_iso, group = person),
          linewidth = 0.45,
          color = "red",
          alpha = 0.55,
          linetype = "solid",
          na.rm = TRUE
        )

      if (show_aggregate_labels) {
        pp <- pp +
          ggplot2::geom_text(
            data = aggregate_label_data,
            ggplot2::aes(x = est, y = stage_iso, label = person),
            color = "red",
            alpha = 0.9,
            hjust = -0.05,
            size = 3,
            check_overlap = TRUE,
            na.rm = TRUE
          )
      }
    }

    if (show_smoothed) {
      pp <- pp +
        ggplot2::geom_line(
          data = rating_data,
          ggplot2::aes(x = est, y = stage_sm, group = person),
          linewidth = 0.45,
          color = "blue",
          alpha = 0.8,
          linetype = "dashed",
          na.rm = TRUE
        )
    }

    pp <- pp +
      ggplot2::geom_hline(
        data = boundary_data,
        ggplot2::aes(yintercept = boundary),
        linetype = 2,
        color = "grey60"
      ) +
      ggplot2::geom_hline(
        data = zero_data,
        ggplot2::aes(yintercept = zero),
        linewidth = 0.4,
        color = "grey60"
      ) +
      ggplot2::geom_segment(
        data = residual_data,
        ggplot2::aes(x = est, xend = est, y = 0, yend = stage_resid),
        linewidth = 0.35,
        color = "grey35",
        alpha = 0.8,
        na.rm = TRUE
      ) +
      ggplot2::geom_vline(
        data = cuts_long,
        ggplot2::aes(xintercept = cut, color = cut_type),
        linewidth = .8,
        alpha = 0.8,
        linetype = "solid",
        na.rm = TRUE
      )

    if (show_aggregate) {
      pp <- pp +
        ggplot2::geom_vline(
          data = mean_cuts_long,
          ggplot2::aes(xintercept = cut, color = cut_type),
          linewidth = .9,
          alpha = 0.9,
          linetype = "solid",
          na.rm = TRUE
        )
    }

    if (show_aggregate && show_aggregate_labels) {
      pp <- pp +
        ggplot2::scale_x_continuous(
          expand = ggplot2::expansion(mult = c(0.05, 0.18))
        )
    }

    pp <- pp +
      ggplot2::facet_grid(.panel ~ .facet_person, scales = "free_y") +
      ggplot2::labs(
        x = paste0("Itemschwierigkeit (", x_label, ")"),
        y = "Stufe / Residuum",
        color = "Cut Score"
      ) +
      ggplot2::theme_minimal()

    return(pp)
  }

  plot_data <- plot_data |>
    dplyr::mutate(.facet_person = factor(person, levels = facet_levels))
  aggregate_plot_data <- NULL
  aggregate_label_data <- NULL
  if (show_aggregate) {
    aggregate_plot_data <- plot_data |>
      dplyr::mutate(.facet_person = factor(aggregate_label, levels = facet_levels))
    if (show_aggregate_labels) {
      aggregate_label_data <- .aggregate_line_label_data_idm(aggregate_plot_data)
    }
  }

  pp <- ggplot2::ggplot(plot_data, ggplot2::aes(x = est))

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

  pp <- pp +
    ggplot2::geom_line(
      ggplot2::aes(y = stage_iso, group = person),
      linewidth = 0.9,
      color = "red",
      linetype = "solid",
      na.rm = TRUE
    )

  if (show_aggregate) {
    pp <- pp +
      ggplot2::geom_line(
        data = aggregate_plot_data,
        ggplot2::aes(y = stage_iso, group = person),
        linewidth = 0.45,
        color = "red",
        alpha = 0.55,
        linetype = "solid",
        na.rm = TRUE
      )

    if (show_aggregate_labels) {
      pp <- pp +
        ggplot2::geom_text(
          data = aggregate_label_data,
          ggplot2::aes(y = stage_iso, label = person),
          color = "red",
          alpha = 0.9,
          hjust = -0.05,
          size = 3,
          check_overlap = TRUE,
          na.rm = TRUE
        )
    }
  }

  if (show_smoothed) {
    pp <- pp +
      ggplot2::geom_line(
        ggplot2::aes(y = stage_sm, group = person),
        linewidth = 0.45,
        color = "blue",
        alpha = 0.8,
        linetype = "dashed",
        na.rm = TRUE
      )
  }

  pp <- pp +
    ggplot2::geom_hline(yintercept = res_list$boundaries, linetype = 2, color = "grey60") +
    ggplot2::geom_vline(
      data = cuts_long,
      ggplot2::aes(xintercept = cut, color = cut_type),
      linewidth = .8,
      alpha = 0.8,
      linetype = "solid",
      na.rm = TRUE
    )

  if (show_aggregate) {
    pp <- pp +
      ggplot2::geom_vline(
        data = mean_cuts_long,
        ggplot2::aes(xintercept = cut, color = cut_type),
        linewidth = .9,
        alpha = 0.9,
        linetype = "solid",
        na.rm = TRUE
      )
  }

  if (show_aggregate && show_aggregate_labels) {
    pp <- pp +
      ggplot2::scale_x_continuous(
        expand = ggplot2::expansion(mult = c(0.05, 0.18))
      )
  }

  pp <- pp +
    ggplot2::facet_wrap(~ .facet_person, ncol = 2) +
    ggplot2::scale_y_continuous(breaks = y_breaks, labels = y_labels, limits = y_limits) +
    ggplot2::labs(
      x = paste0("Itemschwierigkeit (", x_label, ")"),
      y = "Stufe",
      color = "Cut Score"
    ) +
    ggplot2::theme_minimal()

  return(pp)
}
