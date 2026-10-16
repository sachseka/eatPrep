.aggregate_panel_label_mapt <- function(persons) {
  label <- "Pooled (MAPT)"
  if (!label %in% persons) return(label)
  suffix <- 1L
  while (paste0(label, "_", suffix) %in% persons) suffix <- suffix + 1L
  paste0(label, "_", suffix)
}

.plot_cuts_mapt <- function(res_list, options, population_data = NULL,
                             population_density = NULL, population_colors = NULL) {
  # plotCutsIDM validates the public options and prepares population inputs.
  # Keep the internal Ratings/Residuals panel names used by the PV helpers.
  est <- probability <- empirical <- residual <- cut <- cut_type <- NULL
  .facet_person <- .panel <- .cut_value_y <- .cut_value_label <- NULL
  .reference <- .label <- .label_x <- .label_y <- .blank_y <- NULL
  .curve_segment <- .extrapolated <- NULL
  panel_levels <- c("Ratings", "Residuals")
  labels <- res_list$cut_labels
  boundaries <- res_list$boundaries
  persons <- as.character(res_list$cuts_per_person$person)
  pooled_label <- .aggregate_panel_label_mapt(persons)
  show_pooled <- options$show_aggregate || !length(persons)
  facet_levels <- c(persons, if (show_pooled) pooled_label)
  observations <- res_list$data_used

  panels <- lapply(persons, function(person) {
    list(
      person = person,
      data = observations[as.character(observations$person) == person, , drop = FALSE],
      diagnostics = res_list$diagnostics_per_person[
        as.character(res_list$diagnostics_per_person$person) == person, , drop = FALSE],
      models = res_list$models_per_person[[person]],
      cuts = res_list$cuts_per_person[
        match(person, as.character(res_list$cuts_per_person$person)), labels, drop = FALSE]
    )
  })
  if (show_pooled) {
    panels[[length(panels) + 1L]] <- list(
      person = pooled_label, data = observations,
      diagnostics = res_list$cut_diagnostics, models = res_list$models,
      cuts = res_list$cuts_summary[labels]
    )
  }

  # The cut table retains failed boundaries as NA so percentage annotations
  # cannot silently collapse categories when a model is unidentifiable.
  cut_tables <- lapply(panels, function(panel) {
    diagnostic <- panel$diagnostics[match(labels, panel$diagnostics$cut_name), , drop = FALSE]
    values <- unname(unlist(panel$cuts[labels], use.names = FALSE))
    values[is.na(diagnostic$status) | diagnostic$status != "ok"] <- NA_real_
    data.frame(cut_type = labels, cut = values,
               .facet_person = panel$person, stringsAsFactors = FALSE)
  })
  cuts <- do.call(rbind, cut_tables)
  cuts$.facet_person <- factor(cuts$.facet_person, levels = facet_levels)
  cuts$cut_type <- factor(cuts$cut_type, levels = labels)
  finite_cuts <- cuts[is.finite(cuts$cut), , drop = FALSE]

  x_values <- c(observations$est, finite_cuts$cut, population_density$.population_x)
  x_limits <- range(x_values[is.finite(x_values)])
  if (x_limits[1] == x_limits[2]) {
    padding <- max(0.5, abs(x_limits[1]) * 0.01)
    x_limits <- x_limits + c(-padding, padding)
  }
  # Include each cut exactly, giving p=.5 on the actual fitted curve rather
  # than relying on a coarse interpolation between plotting grid points.
  grid <- sort(unique(c(seq(x_limits[1], x_limits[2], length.out = 401L),
                        observations$est, finite_cuts$cut)))

  probability_at <- function(x, model, diagnostic) {
    if (inherits(model, "glm") && isTRUE(is.finite(model$est_center)) &&
        isTRUE(is.finite(model$est_scale)) && model$est_scale > 0) {
      return(as.numeric(stats::predict(
        model, newdata = data.frame(difficulty = (x - model$est_center) / model$est_scale),
        type = "response"
      )))
    }
    # Earlier saved MAPT results did not retain individual model objects.
    # Their diagnostic slope and cut define the same fitted logistic curve.
    stats::plogis(diagnostic$slope * (x - diagnostic$cut))
  }

  curve_rows <- empirical_rows <- residual_rows <- list()
  no_cut_panels <- character()
  for (panel in panels) {
    valid_count <- 0L
    difficulty_values <- sort(unique(panel$data$est))
    difficulty_index <- match(panel$data$est, difficulty_values)
    counts <- tabulate(difficulty_index, nbins = length(difficulty_values))
    for (i in seq_along(labels)) {
      diagnostic <- panel$diagnostics[
        match(labels[i], panel$diagnostics$cut_name), , drop = FALSE]
      model <- panel$models[[labels[i]]]
      valid <- isTRUE(diagnostic$status == "ok") && is.finite(diagnostic$cut) &&
        is.finite(diagnostic$slope) && diagnostic$slope > 0
      raw <- data.frame(
        est = difficulty_values,
        empirical = tabulate(difficulty_index[panel$data$stage_raw > boundaries[i]],
                              nbins = length(difficulty_values)) / counts,
        n = counts, cut_type = rep(labels[i], length(counts)),
        .facet_person = rep(panel$person, length(counts)), stringsAsFactors = FALSE
      )
      empirical_rows[[length(empirical_rows) + 1L]] <- raw
      if (!valid) next
      valid_count <- valid_count + 1L
      curve <- data.frame(
        est = grid, probability = probability_at(grid, model, diagnostic),
        cut_type = labels[i], .facet_person = panel$person, stringsAsFactors = FALSE
      )
      observed_range <- range(panel$data$est)
      curve$.curve_segment <- "observed"
      curve$.extrapolated <- FALSE
      curve_rows[[length(curve_rows) + 1L]] <- curve[
        curve$est >= observed_range[1] & curve$est <= observed_range[2], , drop = FALSE]
      # Share the endpoint with the central segment for continuous curves;
      # separate left/right groups must not bridge across the observed region.
      for (side in c("left", "right")) {
        outside <- if (side == "left") grid < observed_range[1] else grid > observed_range[2]
        if (any(outside)) {
          include <- if (side == "left") grid <= observed_range[1] else grid >= observed_range[2]
          extrapolated <- curve[include, , drop = FALSE]
          extrapolated$.curve_segment <- side
          extrapolated$.extrapolated <- TRUE
          curve_rows[[length(curve_rows) + 1L]] <- extrapolated
        }
      }
      if (nrow(raw)) {
        raw$residual <- raw$empirical - probability_at(raw$est, model, diagnostic)
        residual_rows[[length(residual_rows) + 1L]] <- raw
      }
    }
    if (!valid_count) no_cut_panels <- c(no_cut_panels, panel$person)
  }

  bind_plot_rows <- function(rows, columns) {
    if (length(rows)) {
      dat <- do.call(rbind, rows)
    } else {
      dat <- as.data.frame(stats::setNames(rep(list(numeric()), length(columns)), columns))
    }
    dat$.facet_person <- factor(dat$.facet_person, levels = facet_levels)
    dat$cut_type <- factor(dat$cut_type, levels = labels)
    if (options$show_residuals) {
      dat$.panel <- factor(rep("Ratings", nrow(dat)), levels = panel_levels)
    }
    dat
  }
  curves <- bind_plot_rows(curve_rows, c("est", "probability", "cut_type", ".facet_person",
                                        ".curve_segment", ".extrapolated"))
  curves$.extrapolated <- factor(curves$.extrapolated, levels = c(FALSE, TRUE))
  raw_points <- bind_plot_rows(empirical_rows,
                               c("est", "empirical", "n", "cut_type", ".facet_person"))
  residuals <- bind_plot_rows(residual_rows,
                              c("est", "empirical", "n", "cut_type", ".facet_person", "residual"))
  if (options$show_residuals) {
    residuals$.panel <- factor(rep("Residuals", nrow(residuals)), levels = panel_levels)
  }

  # Explicit anchors retain panels for raters with no usable fits or ratings.
  anchors <- data.frame(
    .facet_person = factor(rep(facet_levels, each = 2L), levels = facet_levels),
    est = rep(x_limits, length(facet_levels)), .blank_y = rep(c(0, 1), length(facet_levels))
  )
  half_line <- data.frame(.reference = 0.5)
  if (options$show_residuals) {
    anchors$.panel <- factor("Ratings", levels = panel_levels)
    residual_anchors <- anchors
    residual_anchors$.panel <- factor("Residuals", levels = panel_levels)
    residual_anchors$.blank_y <- rep(c(-1, 1), length(facet_levels))
    anchors <- rbind(anchors, residual_anchors)
    half_line$.panel <- factor("Ratings", levels = panel_levels)
  }
  no_cut_labels <- data.frame(
    .facet_person = factor(no_cut_panels, levels = facet_levels),
    .label_x = rep(mean(x_limits), length(no_cut_panels)),
    .label_y = rep(0.5, length(no_cut_panels)),
    .label = rep("Kein g\u00fcltiger Cut", length(no_cut_panels))
  )
  if (options$show_residuals) {
    no_cut_labels$.panel <- factor(rep("Ratings", nrow(no_cut_labels)), levels = panel_levels)
  }

  pp <- ggplot2::ggplot()
  if (!is.null(population_density)) {
    pp <- pp + .population_background_idm(
      population_density, c(0, 1), options$show_residuals,
      options$population_height, options$population_fill, options$population_alpha,
      population_colors
    ) + ggplot2::labs(caption = sub(
      "rating stages", "probabilities",
      .population_shape_caption_idm(length(population_colors) > 1L), fixed = TRUE
    ))
  }
  pp <- pp +
    ggplot2::geom_blank(data = anchors, ggplot2::aes(x = est, y = .blank_y)) +
    ggplot2::geom_hline(data = half_line, ggplot2::aes(yintercept = .reference),
                        linetype = "dashed", color = "grey55", linewidth = 0.4)
  if (options$show_raw) {
    pp <- pp + ggplot2::geom_point(
      data = raw_points, ggplot2::aes(x = est, y = empirical, color = cut_type),
      alpha = 0.4, size = 1.2, na.rm = TRUE
    )
  }
  pp <- pp +
    ggplot2::geom_line(
      data = curves,
      ggplot2::aes(x = est, y = probability, color = cut_type,
                    linetype = .extrapolated, group = interaction(cut_type, .curve_segment)),
      linewidth = 0.8, na.rm = TRUE
    ) +
    ggplot2::geom_vline(
      data = finite_cuts, ggplot2::aes(xintercept = cut, color = cut_type),
      linewidth = 0.65, alpha = 0.8, na.rm = TRUE
    ) +
    ggplot2::geom_text(
      data = no_cut_labels,
      ggplot2::aes(x = .label_x, y = .label_y, label = .label),
      size = 3.3, color = "grey30", inherit.aes = FALSE
    )
  if (options$show_cut_values) {
    cut_labels <- .cut_value_label_data_idm(
      finite_cuts, y = 1, digits = options$cut_value_digits,
      panel = if (options$show_residuals) "Ratings" else NULL,
      panel_levels = panel_levels
    )
    pp <- pp + ggplot2::geom_text(
      data = cut_labels,
      ggplot2::aes(x = cut, y = .cut_value_y, label = .cut_value_label, color = cut_type),
      angle = 90, hjust = 1.1, vjust = -0.25, size = options$cut_value_size,
      fontface = "bold", show.legend = FALSE, na.rm = TRUE, inherit.aes = FALSE
    )
  }
  if (options$show_residuals) {
    zero_line <- data.frame(.reference = 0, .panel = factor("Residuals", levels = panel_levels))
    pp <- pp +
      ggplot2::geom_hline(data = zero_line, ggplot2::aes(yintercept = .reference),
                          linewidth = 0.4, color = "grey55") +
      ggplot2::geom_segment(
        data = residuals,
        ggplot2::aes(x = est, xend = est, y = 0, yend = residual, color = cut_type),
        linewidth = 0.35, alpha = 0.7, na.rm = TRUE
      ) +
      ggplot2::facet_grid(
        .panel ~ .facet_person, scales = "free_y", drop = FALSE,
        labeller = ggplot2::labeller(.panel = c(Ratings = "Wahrscheinlichkeit", Residuals = "Residuum"))
      ) +
      ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.02))
  } else {
    pp <- pp +
      ggplot2::facet_wrap(~ .facet_person, ncol = 2, drop = FALSE) +
      ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, by = 0.25),
                                  expand = ggplot2::expansion(mult = 0.02))
  }
  x_label <- options$est_col
  if (is.null(x_label)) x_label <- res_list$est_col
  if (is.null(x_label)) x_label <- "est"
  pp <- pp +
    ggplot2::scale_color_discrete(limits = labels, drop = FALSE) +
    ggplot2::scale_linetype_manual(
      name = "Modellbereich", values = c("FALSE" = "solid", "TRUE" = "dotted"),
      breaks = c("FALSE", "TRUE"), labels = c("Im Itembereich", "Au\u00dferhalb des Itembereichs"),
      guide = if (any(curves$.extrapolated == "TRUE")) "legend" else "none"
    ) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.05)) +
    ggplot2::labs(
      x = paste0("Itemschwierigkeit (", x_label, ")"),
      y = if (options$show_residuals) "P(Rating > Grenze) / Residuum" else "P(Rating > Grenze)",
      color = "Cut Score"
    ) + ggplot2::theme_minimal()

  if (!is.null(population_density)) {
    if (options$show_percentages) {
      pp <- .add_population_percentages_idm(
        pp, population_data, cuts, population_colors = population_colors,
        percentage_digits = options$percentage_digits,
        percentage_size = options$percentage_size, show_residuals = options$show_residuals
      )
    }
    pp <- .add_population_moments_idm(
      pp, population_data, population_colors, options$show_population_stats,
      options$population_stats_digits
    )
  }
  if (!options$show_caption) pp <- pp + ggplot2::labs(caption = NULL)
  pp
}
