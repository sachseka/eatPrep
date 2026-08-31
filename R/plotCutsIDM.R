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

.aggregate_rater_colors_idm <- function(persons) {
  persons <- as.character(persons)
  if (length(persons) == 0) {
    return(stats::setNames(character(), character()))
  }

  stats::setNames(
    grDevices::hcl.colors(length(persons), palette = "Dark 3"),
    persons
  )
}

.add_aggregate_colors_idm <- function(dat, colors) {
  dat$.aggregate_color <- unname(colors[as.character(dat$person)])
  dat
}

.spread_label_positions_idm <- function(y, lower, upper) {
  n <- length(y)
  if (n <= 1 || !is.finite(lower) || !is.finite(upper) || lower >= upper) {
    return(y)
  }

  span <- upper - lower
  min_gap <- min(span * 0.055, span / (n - 1))
  ord <- order(y, seq_along(y))
  sorted <- y[ord]

  for (i in seq.int(2L, n)) {
    sorted[i] <- max(sorted[i], sorted[i - 1L] + min_gap)
  }

  overflow <- sorted[n] - upper
  if (overflow > 0) {
    sorted <- sorted - overflow
  }
  underflow <- lower - sorted[1L]
  if (underflow > 0) {
    sorted <- sorted + underflow
  }

  out <- y
  out[ord] <- sorted
  out
}

.aggregate_line_label_data_idm <- function(dat, y_limits) {
  dat <- dat |>
    dplyr::filter(is.finite(est), is.finite(stage_iso)) |>
    dplyr::arrange(person, est)

  if ("item_position" %in% names(dat)) {
    dat <- dat |>
      dplyr::arrange(person, est, item_position)
  }

  out <- dat |>
    dplyr::group_by(person) |>
    dplyr::slice_tail(n = 1) |>
    dplyr::ungroup()

  out$.label_y <- .spread_label_positions_idm(
    y = out$stage_iso,
    lower = y_limits[1],
    upper = y_limits[2]
  )
  out
}

.format_cut_values_idm <- function(cuts, digits = 0L) {
  vapply(cuts, function(value) {
    if (!is.finite(value)) {
      return(NA_character_)
    }

    label <- format(
      round(value, digits = digits),
      nsmall = digits,
      trim = TRUE,
      scientific = FALSE
    )
    if (digits > 0L) {
      label <- sub("0+$", "", label)
      label <- sub("\\.$", "", label)
    }
    label
  }, character(1))
}

.cut_value_label_data_idm <- function(dat, y, panel = NULL,
                                      panel_levels = NULL,
                                      digits = 0L) {
  dat <- dat |>
    dplyr::filter(is.finite(cut)) |>
    dplyr::mutate(
      .cut_value_label = .format_cut_values_idm(cut, digits = digits),
      .cut_value_y = y
    )

  if (!is.null(panel)) {
    dat <- dat |>
      dplyr::mutate(.panel = factor(panel, levels = panel_levels))
  }

  dat
}

.item_number_label_data_idm <- function(dat) {
  if (!"item_position" %in% names(dat)) {
    return(dat[FALSE, , drop = FALSE])
  }

  dat |>
    dplyr::filter(
      is.finite(est),
      is.finite(stage_raw),
      !is.na(item_position)
    ) |>
    dplyr::mutate(.item_number_label = as.character(item_position))
}

.x_expansion_idm <- function(show_aggregate, show_aggregate_labels,
                             show_raw, show_item_numbers) {
  right <- 0.05
  if (show_aggregate && show_aggregate_labels) {
    right <- max(right, 0.18)
  }
  if (show_raw && show_item_numbers) {
    right <- max(right, 0.08)
  }

  ggplot2::expansion(mult = c(0.05, right))
}

.needs_x_expansion_idm <- function(show_aggregate, show_aggregate_labels,
                                   show_raw, show_item_numbers) {
  (show_aggregate && show_aggregate_labels) || (show_raw && show_item_numbers)
}

plotCutsIDM <- function(res_list, est_col = NULL,
                        show_raw = TRUE, show_smoothed = TRUE,
                        show_residuals = FALSE,
                        show_aggregate = FALSE,
                        show_aggregate_labels = TRUE,
                        show_cut_values = TRUE,
                        show_item_numbers = TRUE,
                        cut_value_digits = 0L) {

  checkmate::assert_list(res_list)
  checkmate::assert_string(est_col, null.ok = TRUE)
  checkmate::assert_flag(show_raw)
  checkmate::assert_flag(show_smoothed)
  checkmate::assert_flag(show_residuals)
  checkmate::assert_flag(show_aggregate)
  checkmate::assert_flag(show_aggregate_labels)
  checkmate::assert_flag(show_cut_values)
  checkmate::assert_flag(show_item_numbers)
  checkmate::assert_integerish(
    cut_value_digits,
    len = 1,
    lower = 0,
    any.missing = FALSE
  )
  cut_value_digits <- as.integer(cut_value_digits)

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
  aggregate_colors <- NULL
  if (show_aggregate) {
    aggregate_label <- .aggregate_panel_label_idm(person_order)
    facet_levels <- c(facet_levels, aggregate_label)
    aggregate_colors <- .aggregate_rater_colors_idm(person_order)
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
    item_number_data <- NULL
    if (show_raw && show_item_numbers) {
      item_number_data <- .item_number_label_data_idm(rating_data)
    }
    aggregate_rating_data <- NULL
    aggregate_label_data <- NULL
    if (show_aggregate) {
      aggregate_rating_data <- plot_data |>
        dplyr::mutate(
          .panel = factor("Ratings", levels = panel_levels),
          .facet_person = factor(aggregate_label, levels = facet_levels)
        ) |>
        .add_aggregate_colors_idm(aggregate_colors)
      if (show_aggregate_labels) {
        aggregate_label_data <- .aggregate_line_label_data_idm(
          dat = aggregate_rating_data,
          y_limits = y_limits
        )
      }
    }
    cut_value_data <- NULL
    mean_cut_value_data <- NULL
    if (show_cut_values) {
      cut_value_data <- .cut_value_label_data_idm(
        dat = cuts_long,
        y = y_limits[2],
        panel = "Ratings",
        panel_levels = panel_levels,
        digits = cut_value_digits
      )
      if (show_aggregate) {
        mean_cut_value_data <- .cut_value_label_data_idm(
          dat = mean_cuts_long,
          y = y_limits[2],
          panel = "Ratings",
          panel_levels = panel_levels,
          digits = cut_value_digits
        )
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
      if (show_item_numbers) {
        pp <- pp +
          ggplot2::geom_text(
            data = item_number_data,
            ggplot2::aes(
              x = est,
              y = stage_raw,
              label = .item_number_label
            ),
            hjust = -0.45,
            vjust = 0.5,
            size = 2,
            color = "grey25",
            alpha = 0.65,
            fontface = "bold",
            show.legend = FALSE,
            na.rm = TRUE,
            inherit.aes = FALSE
          )
      }
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
          ggplot2::aes(
            x = est,
            y = stage_iso,
            group = person,
            color = I(.aggregate_color)
          ),
          linewidth = 0.45,
          alpha = 0.85,
          linetype = "solid",
          show.legend = FALSE,
          na.rm = TRUE
        )

      if (show_aggregate_labels) {
        pp <- pp +
          ggplot2::geom_text(
            data = aggregate_label_data,
            ggplot2::aes(
              x = est,
              y = .label_y,
              label = person,
              color = I(.aggregate_color)
            ),
            alpha = 0.95,
            hjust = 0,
            size = 3,
            show.legend = FALSE,
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

    if (show_cut_values) {
      pp <- pp +
        ggplot2::geom_text(
          data = cut_value_data,
          ggplot2::aes(
            x = cut,
            y = .cut_value_y,
            label = .cut_value_label,
            color = cut_type
          ),
          angle = 90,
          hjust = 1.1,
          vjust = -0.25,
          size = 2.6,
          fontface = "bold",
          show.legend = FALSE,
          na.rm = TRUE,
          inherit.aes = FALSE
        )
      if (show_aggregate) {
        pp <- pp +
          ggplot2::geom_text(
            data = mean_cut_value_data,
            ggplot2::aes(
              x = cut,
              y = .cut_value_y,
              label = .cut_value_label,
              color = cut_type
            ),
            angle = 90,
            hjust = 1.1,
            vjust = -0.25,
            size = 2.6,
            fontface = "bold",
            show.legend = FALSE,
            na.rm = TRUE,
            inherit.aes = FALSE
          )
      }
    }

    if (.needs_x_expansion_idm(
      show_aggregate = show_aggregate,
      show_aggregate_labels = show_aggregate_labels,
      show_raw = show_raw,
      show_item_numbers = show_item_numbers
    )) {
      pp <- pp +
        ggplot2::scale_x_continuous(
          expand = .x_expansion_idm(
            show_aggregate = show_aggregate,
            show_aggregate_labels = show_aggregate_labels,
            show_raw = show_raw,
            show_item_numbers = show_item_numbers
          )
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
  item_number_data <- NULL
  if (show_raw && show_item_numbers) {
    item_number_data <- .item_number_label_data_idm(plot_data)
  }
  aggregate_plot_data <- NULL
  aggregate_label_data <- NULL
  if (show_aggregate) {
    aggregate_plot_data <- plot_data |>
      dplyr::mutate(.facet_person = factor(aggregate_label, levels = facet_levels)) |>
      .add_aggregate_colors_idm(aggregate_colors)
    if (show_aggregate_labels) {
      aggregate_label_data <- .aggregate_line_label_data_idm(
        dat = aggregate_plot_data,
        y_limits = y_limits
      )
    }
  }
  cut_value_data <- NULL
  mean_cut_value_data <- NULL
  if (show_cut_values) {
    cut_value_data <- .cut_value_label_data_idm(
      dat = cuts_long,
      y = y_limits[2],
      digits = cut_value_digits
    )
    if (show_aggregate) {
      mean_cut_value_data <- .cut_value_label_data_idm(
        dat = mean_cuts_long,
        y = y_limits[2],
        digits = cut_value_digits
      )
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
    if (show_item_numbers) {
      pp <- pp +
        ggplot2::geom_text(
          data = item_number_data,
          ggplot2::aes(
            x = est,
            y = stage_raw,
            label = .item_number_label
          ),
          hjust = -0.45,
          vjust = 0.5,
          size = 2,
          color = "grey25",
          alpha = 0.65,
          fontface = "bold",
          show.legend = FALSE,
          na.rm = TRUE,
          inherit.aes = FALSE
        )
    }
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
        ggplot2::aes(
          x = est,
          y = stage_iso,
          group = person,
          color = I(.aggregate_color)
        ),
        linewidth = 0.45,
        alpha = 0.85,
        linetype = "solid",
        show.legend = FALSE,
        na.rm = TRUE
      )

    if (show_aggregate_labels) {
      pp <- pp +
        ggplot2::geom_text(
          data = aggregate_label_data,
          ggplot2::aes(
            x = est,
            y = .label_y,
            label = person,
            color = I(.aggregate_color)
          ),
          alpha = 0.95,
          hjust = 0,
          size = 3,
          show.legend = FALSE,
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

  if (show_cut_values) {
    pp <- pp +
      ggplot2::geom_text(
        data = cut_value_data,
        ggplot2::aes(
          x = cut,
          y = .cut_value_y,
          label = .cut_value_label,
          color = cut_type
        ),
        angle = 90,
        hjust = 1.1,
        vjust = -0.25,
        size = 2.6,
        fontface = "bold",
        show.legend = FALSE,
        na.rm = TRUE,
        inherit.aes = FALSE
      )
    if (show_aggregate) {
      pp <- pp +
        ggplot2::geom_text(
          data = mean_cut_value_data,
          ggplot2::aes(
            x = cut,
            y = .cut_value_y,
            label = .cut_value_label,
            color = cut_type
          ),
          angle = 90,
          hjust = 1.1,
          vjust = -0.25,
          size = 2.6,
          fontface = "bold",
          show.legend = FALSE,
          na.rm = TRUE,
          inherit.aes = FALSE
        )
    }
  }

  if (.needs_x_expansion_idm(
    show_aggregate = show_aggregate,
    show_aggregate_labels = show_aggregate_labels,
    show_raw = show_raw,
    show_item_numbers = show_item_numbers
  )) {
    pp <- pp +
      ggplot2::scale_x_continuous(
        expand = .x_expansion_idm(
          show_aggregate = show_aggregate,
          show_aggregate_labels = show_aggregate_labels,
          show_raw = show_raw,
          show_item_numbers = show_item_numbers
        )
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
