.population_identifier_labels_idm <- function(x) {
  labels <- as.character(x)
  if (is.numeric(x)) {
    # Default numeric formatting can merge distinct, exactly representable IDs.
    # Repair only default labels; preserve class-specific representations such
    # as integer64, whose underlying doubles do not contain the identifier value.
    raw <- unclass(x)
    ordinary <- is.finite(raw) & labels == as.character(raw)
    loses_precision <- rep(FALSE, length(raw))
    loses_precision[ordinary] <- as.numeric(labels[ordinary]) != raw[ordinary]
    labels[loses_precision] <- sprintf("%.17g", raw[loses_precision])
  }
  if (anyDuplicated(labels[!duplicated(x)])) {
    stop("Distinct identifiers must have distinct character labels; supply explicit character identifiers.",
         call. = FALSE)
  }
  labels
}

.prepare_population_idm <- function(pv_data, pv_cols = NULL,
                                    respondent_id_col = NULL,
                                    pv_id_col = NULL, pv_value_col = NULL,
                                    weight_col = NULL,
                                    input_format = c("auto", "long", "wide"),
                                    pv_missing = c("error", "drop"),
                                    population_col = NULL) {
  checkmate::assert_data_frame(pv_data, min.rows = 1)
  input_format <- match.arg(input_format)
  pv_missing <- match.arg(pv_missing)
  checkmate::assert_string(population_col, null.ok = TRUE)
  if (!is.null(population_col)) {
    checkmate::assert_names(population_col, subset.of = names(pv_data))
    if (population_col %in% c(pv_cols, respondent_id_col, pv_id_col, pv_value_col, weight_col)) {
      stop("population_col must be distinct from PV, respondent ID, and weight columns.", call. = FALSE)
    }
    population <- pv_data[[population_col]]
    if (!(is.character(population) || is.factor(population) || is.numeric(population)) ||
        anyNA(population) || any(!nzchar(trimws(as.character(population)))) ||
        (is.numeric(population) && any(!is.finite(population)))) {
      stop("Population labels must be non-missing, non-empty finite identifiers.", call. = FALSE)
    }
    population <- .population_identifier_labels_idm(population)
    population_names <- unique(population)
    groups <- lapply(population_names, function(label) {
      # Validate IDs, PV completeness, and weights within each population.
      prepared <- tryCatch(
        withCallingHandlers(
          .prepare_population_idm(
            pv_data[population == label, , drop = FALSE], pv_cols,
            respondent_id_col, pv_id_col, pv_value_col, weight_col,
            input_format, pv_missing
          ),
          warning = function(w) {
            warning(sprintf("Population '%s': %s", label, conditionMessage(w)), call. = FALSE)
            invokeRestart("muffleWarning")
          }
        ),
        error = function(e) {
          stop(sprintf("Population '%s': %s", label, conditionMessage(e)), call. = FALSE)
        }
      )
      prepared$.population <- factor(label, levels = population_names)
      prepared
    })
    return(do.call(rbind, groups))
  }
  checkmate::assert_character(pv_cols, min.len = 1, any.missing = FALSE,
                             unique = TRUE, null.ok = TRUE)
  for (col in list(respondent_id_col, pv_id_col, pv_value_col, weight_col)) {
    checkmate::assert_string(col, null.ok = TRUE)
  }
  long_args <- !is.null(pv_id_col) || !is.null(pv_value_col)
  if (input_format == "auto") {
    input_format <- if (long_args) "long" else "wide"
  }
  if (input_format == "long" &&
      (is.null(respondent_id_col) || is.null(pv_id_col) || is.null(pv_value_col))) {
    stop("Long PV input requires respondent_id_col, pv_id_col, and pv_value_col.",
         call. = FALSE)
  }
  if ((input_format == "long" && !is.null(pv_cols)) ||
      (input_format == "wide" && long_args)) {
    stop("Use pv_cols for wide input or pv_id_col and pv_value_col for long input.",
         call. = FALSE)
  }
  if (input_format == "wide" && is.null(pv_cols)) {
    stop("Wide PV input requires explicit pv_cols.", call. = FALSE)
  }
  cols <- c(pv_cols, respondent_id_col, pv_id_col, pv_value_col, weight_col)
  checkmate::assert_names(cols, subset.of = names(pv_data))
  if (anyDuplicated(cols)) {
    stop("PV, respondent ID, and weight columns must be distinct.", call. = FALSE)
  }
  for (col in c(pv_cols, pv_value_col)) {
    checkmate::assert_numeric(pv_data[[col]], .var.name = col)
    if (any(is.infinite(pv_data[[col]]))) {
      stop("PV values must be finite or missing.", call. = FALSE)
    }
  }
  id <- if (is.null(respondent_id_col)) seq_len(nrow(pv_data)) else pv_data[[respondent_id_col]]
  valid_id <- function(x) {
    (is.character(x) || is.numeric(x) || is.factor(x)) &&
      !anyNA(x) && all(nzchar(as.character(x))) &&
      (!is.numeric(x) || all(is.finite(x)))
  }
  if (!valid_id(id)) {
    stop("Respondent IDs must be non-missing, non-empty finite identifiers.", call. = FALSE)
  }
  weights <- if (is.null(weight_col)) rep(1, nrow(pv_data)) else pv_data[[weight_col]]
  checkmate::assert_numeric(weights, lower = 0, finite = TRUE, any.missing = FALSE,
                           .var.name = "population weights")
  if (input_format == "wide") {
    if (anyDuplicated(id)) {
      stop("Wide PV input requires one row per respondent.", call. = FALSE)
    }
    dat <- do.call(rbind, lapply(pv_cols, function(col) {
      data.frame(.id = .population_identifier_labels_idm(id), .pv = col,
                 .value = pv_data[[col]], .weight = weights)
    }))
  } else {
    pv_id <- pv_data[[pv_id_col]]
    if (!valid_id(pv_id)) {
      stop("PV identifiers must be non-missing, non-empty finite identifiers.", call. = FALSE)
    }
    dat <- data.frame(.id = .population_identifier_labels_idm(id),
                      .pv = .population_identifier_labels_idm(pv_id),
                      .value = pv_data[[pv_value_col]], .weight = weights)
    if (anyDuplicated(dat[c(".id", ".pv")])) {
      stop("Long PV input requires at most one row per respondent and PV.", call. = FALSE)
    }
    inconsistent <- vapply(split(dat$.weight, dat$.id), function(w) {
      length(unique(w)) != 1L
    }, logical(1))
    if (any(inconsistent)) {
      stop("Each respondent must have the same weight across PVs.", call. = FALSE)
    }
  }
  pv_names <- unique(dat$.pv)
  missing_cells <- length(unique(dat$.id)) * length(pv_names) - nrow(dat)
  missing_values <- sum(is.na(dat$.value))
  if (missing_cells + missing_values > 0) {
    if (pv_missing == "error") {
      stop("Missing PV values or respondent-PV rows; use pv_missing = 'drop' to omit them.",
           call. = FALSE)
    }
    warning(sprintf("Omitting %s missing respondent-PV values; weights are renormalized within each PV.",
                    missing_cells + missing_values), call. = FALSE)
  }
  dat <- dat[!is.na(dat$.value) & dat$.weight > 0, , drop = FALSE]
  counts <- table(factor(dat$.pv, levels = pv_names))
  if (any(counts < 2L)) {
    stop("Each PV requires at least two observed respondents with positive weights.", call. = FALSE)
  }
  dat
}

.population_density_idm <- function(dat, density_bw = NULL, density_adjust = 1) {
  checkmate::assert_number(density_bw, lower = 0, finite = TRUE, null.ok = TRUE)
  checkmate::assert_number(density_adjust, lower = 0, finite = TRUE)
  if ((!is.null(density_bw) && density_bw == 0) || density_adjust == 0) {
    stop("density_bw and density_adjust must be positive.", call. = FALSE)
  }
  grouped <- ".population" %in% names(dat)
  population_names <- if (grouped) unique(as.character(dat$.population)) else "Population"
  populations <- if (grouped) lapply(population_names, function(label) {
    dat[as.character(dat$.population) == label, , drop = FALSE]
  }) else list(dat)
  draws <- lapply(populations, function(d) split(d, d$.pv))
  # Choose bandwidths per imputation, never using the stacked PV sample size.
  # bw.nrd0 is unweighted; sampling weights enter the density estimates below.
  if (is.null(density_bw)) {
    # Equal weight for populations, and then for PVs within each population.
    density_bw <- mean(vapply(draws, function(population) {
      mean(vapply(population, function(d) stats::bw.nrd0(d$.value), numeric(1)))
    }, numeric(1)))
  }
  bw <- density_bw * density_adjust
  checkmate::assert_number(bw, lower = .Machine$double.xmin, finite = TRUE)
  limits <- range(dat$.value) + c(-3, 3) * bw
  if (any(!is.finite(limits)) || !is.finite(diff(limits)) || diff(limits) <= 0) {
    stop("PV range and density bandwidth must define distinct finite density limits.",
         call. = FALSE)
  }
  # Resolve each kernel on the shared grid, including density()'s four-bandwidth
  # internal padding at either end. Keep the original grid for ordinary inputs.
  grid_points <- 8 * (diff(limits) / bw + 8) + 1
  max_grid_points <- 262144L
  if (!is.finite(grid_points) || grid_points > max_grid_points) {
    stop(paste0("Density bandwidth is too small for the PV range; increase density_bw ",
                "or density_adjust (maximum density grid size is ", max_grid_points, ")."),
         call. = FALSE)
  }
  grid_points <- max(512L, 2^ceiling(log2(grid_points)))
  out <- lapply(seq_along(draws), function(i) {
    densities <- lapply(draws[[i]], function(d) {
      w <- d$.weight / max(d$.weight)
      stats::density(d$.value, weights = w / sum(w), bw = bw,
                     from = limits[1], to = limits[2], n = grid_points)
    })
    result <- data.frame(
      .population_x = densities[[1]]$x,
      .population_density = Reduce(`+`, lapply(densities, `[[`, "y")) / length(densities)
    )
    if (grouped) result$.population <- factor(population_names[i], levels = population_names)
    result
  })
  do.call(rbind, out)
}

.population_colors_idm <- function(density, population_colors = NULL) {
  if (!".population" %in% names(density)) {
    if (!is.null(population_colors)) {
      stop("population_colors requires population_col.", call. = FALSE)
    }
    return(NULL)
  }
  labels <- unique(as.character(density$.population))
  if (is.null(population_colors)) {
    colors <- if (length(labels) <= 2L) c("#0072B2", "#E69F00")[seq_along(labels)] else
      grDevices::hcl.colors(length(labels), palette = "Dark 3")
    return(stats::setNames(colors, labels))
  }
  checkmate::assert_character(population_colors, any.missing = FALSE)
  checkmate::assert_names(names(population_colors), permutation.of = labels)
  tryCatch(grDevices::col2rgb(population_colors), error = function(e) {
    stop("population_colors must contain valid colors.", call. = FALSE)
  })
  population_colors[labels]
}

.population_fill_scale_idm <- function(colors) {
  ggplot2::scale_fill_manual(name = "Population", values = colors,
                             limits = names(colors), breaks = names(colors))
}

.validate_population_style_idm <- function(population_fill, population_alpha) {
  checkmate::assert_string(population_fill)
  tryCatch(grDevices::col2rgb(population_fill), error = function(e) {
    stop("population_fill must be a valid color.", call. = FALSE)
  })
  checkmate::assert_number(population_alpha, lower = 0, upper = 1, finite = TRUE)
  invisible(NULL)
}

.population_background_idm <- function(density, y_limits, show_residuals,
                                       population_height, population_fill,
                                       population_alpha, population_colors = NULL) {
  # ggplot2 evaluates these names within the layer data.
  .population_x <- .population_base <- .population_top <- .population <- NULL
  density$.population_base <- y_limits[1]
  density$.population_top <- y_limits[1] + diff(y_limits) * population_height *
    density$.population_density / max(density$.population_density)
  if (show_residuals) {
    density$.panel <- factor("Ratings", levels = c("Ratings", "Residuals"))
  }
  # No rater facet column: ggplot repeats the same silhouette in every rating facet.
  if (!is.null(population_colors)) {
    return(list(
      ggplot2::geom_ribbon(
        data = density,
        ggplot2::aes(x = .population_x, ymin = .population_base, ymax = .population_top,
                     fill = .population, group = .population),
        alpha = population_alpha, colour = NA, inherit.aes = FALSE
      ),
      .population_fill_scale_idm(population_colors)
    ))
  }
  ggplot2::geom_ribbon(
    data = density,
    ggplot2::aes(x = .population_x, ymin = .population_base, ymax = .population_top),
    fill = population_fill, alpha = population_alpha, colour = NA,
    inherit.aes = FALSE, show.legend = FALSE
  )
}

.population_shape_caption_idm <- function(multiple = FALSE) {
  if (multiple) {
    return(paste0("Population silhouettes show distribution shape only.\n",
                  "Their shared display height does not represent rating stages or density-axis values."))
  }
  paste0("Population silhouette shows distribution shape only.\n",
         "Its height is scaled for display and does not represent rating stages or density-axis values.")
}

plotPopulationCutsIDM <- function(res_list, pv_data, pv_cols = NULL,
                                  respondent_id_col = NULL,
                                  pv_id_col = NULL, pv_value_col = NULL,
                                  weight_col = NULL,
                                  input_format = c("auto", "long", "wide"),
                                  pv_missing = c("error", "drop"),
                                  density_bw = NULL, density_adjust = 1,
                                  cut_selection = c("mean", "individual", "both"),
                                  est_col = NULL, show_cut_values = TRUE,
                                  cut_value_digits = 0L, cut_value_size = 2.6,
                                  population_fill = "grey50", population_alpha = 0.25,
                                  population_col = NULL, population_colors = NULL,
                                  show_percentages = TRUE, percentage_digits = 1L,
                                  percentage_size = 3) {
  # ggplot2 evaluates these names within the layer data.
  .population_x <- .population_density <- cut_type <- .cut_value_y <- .cut_value_label <- NULL
  .population <- .population_color <- NULL
  .validate_percentages_idm(show_percentages, percentage_digits, percentage_size)
  checkmate::assert_list(res_list)
  checkmate::assert_string(est_col, null.ok = TRUE)
  checkmate::assert_flag(show_cut_values)
  checkmate::assert_integerish(cut_value_digits, len = 1, lower = 0, any.missing = FALSE)
  checkmate::assert_number(cut_value_size, lower = 0, finite = TRUE)
  .validate_population_style_idm(population_fill, population_alpha)
  cut_selection <- match.arg(cut_selection)
  dat <- .prepare_population_idm(
    pv_data, pv_cols, respondent_id_col, pv_id_col, pv_value_col,
    weight_col, input_format, pv_missing, population_col
  )
  density <- .population_density_idm(dat, density_bw, density_adjust)
  colors <- .population_colors_idm(density, population_colors)
  persons <- as.character(res_list$cuts_per_person$person)
  mean_label <- .aggregate_panel_label_idm(persons)
  cut_tables <- list()
  if (cut_selection %in% c("individual", "both")) {
    cut_tables[["individual"]] <- res_list$cuts_per_person
  }
  if (cut_selection %in% c("mean", "both")) {
    cut_tables[["mean"]] <- dplyr::mutate(res_list$cuts_summary, person = mean_label)
  }
  cuts <- dplyr::bind_rows(cut_tables) |>
    tidyr::pivot_longer(dplyr::starts_with("cut"), names_to = "cut_type", values_to = "cut")
  panel_levels <- unique(as.character(cuts$person))
  cuts$.facet_person <- factor(cuts$person, levels = panel_levels)
  x_label <- est_col
  if (is.null(x_label)) x_label <- res_list$est_col
  if (is.null(x_label)) x_label <- "est"

  pp <- ggplot2::ggplot()
  if (!is.null(colors)) {
    density$.population_color <- unname(colors[as.character(density$.population)])
    pp <- pp +
      ggplot2::geom_ribbon(
        data = density,
        ggplot2::aes(x = .population_x, ymin = 0, ymax = .population_density,
                     fill = .population, group = .population),
        alpha = population_alpha, colour = NA
      ) +
      ggplot2::geom_line(
        data = density,
        ggplot2::aes(x = .population_x, y = .population_density, group = .population,
                     colour = I(.population_color)),
        linewidth = 0.4, show.legend = FALSE
      ) +
      .population_fill_scale_idm(colors)
  } else {
    pp <- pp +
      ggplot2::geom_ribbon(
        data = density,
        ggplot2::aes(x = .population_x, ymin = 0, ymax = .population_density),
        fill = population_fill, alpha = population_alpha, colour = NA,
        show.legend = FALSE
      ) +
      ggplot2::geom_line(
        data = density, ggplot2::aes(x = .population_x, y = .population_density),
        colour = population_fill, linewidth = 0.4, show.legend = FALSE
      )
  }
  pp <- pp +
    ggplot2::geom_vline(
      data = cuts, ggplot2::aes(xintercept = cut, color = cut_type),
      linewidth = 0.8, na.rm = TRUE
    )
  if (show_cut_values) {
    labels <- .cut_value_label_data_idm(cuts, y = max(density$.population_density),
                                        digits = as.integer(cut_value_digits))
    pp <- pp + ggplot2::geom_text(
      data = labels,
      ggplot2::aes(x = cut, y = .cut_value_y, label = .cut_value_label, color = cut_type),
      angle = 90, hjust = 1.1, vjust = -0.25, size = cut_value_size,
      fontface = "bold", show.legend = FALSE, na.rm = TRUE
    )
  }
  pp <- pp +
    ggplot2::facet_wrap(~ .facet_person, ncol = 2) +
    ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.05))) +
    ggplot2::labs(
      x = paste0("Score (", x_label, ")"), y = "Population density", color = "Cut Score",
      caption = if (is.null(colors)) {
        "Population density averaged across plausible values; descriptive estimate."
      } else {
        "Densities averaged across plausible values within each population; each density has total area one."
      }
    ) +
    ggplot2::theme_minimal()
  if (show_percentages) {
    pp <- .add_population_percentages_idm(
      pp, dat, cuts,
      population_colors = colors, percentage_digits = percentage_digits,
      percentage_size = percentage_size
    )
  }
  pp
}
