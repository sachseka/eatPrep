.validate_population_moments_idm <- function(show_population_stats, population_stats_digits) {
  checkmate::assert_flag(show_population_stats)
  checkmate::assert_integerish(population_stats_digits, len = 1, lower = 0, upper = 10,
                              any.missing = FALSE)
}

.population_moments_idm <- function(dat) {
  if (!".population" %in% names(dat)) dat$.population <- "Population"
  populations <- unique(as.character(dat$.population))
  rows <- lapply(populations, function(population) {
    sample <- dat[as.character(dat$.population) == population, , drop = FALSE]
    per_pv <- vapply(split(sample, sample$.pv), function(draw) {
      w <- draw$.weight / max(draw$.weight)
      w <- w / sum(w)
      # Center and scale before squaring to retain small spreads at large score
      # offsets and avoid overflow. Weights describe a population distribution.
      origin <- draw$.value[1]
      centered <- draw$.value - origin
      scale <- max(abs(centered))
      if (scale == 0) return(c(M = origin, SD = 0))
      z <- centered / scale
      m <- sum(w * z)
      # Preparation retains at least two valid, positive-weight observations
      # per PV and population. Apply the correction before pooling variances.
      n <- nrow(draw)
      c(M = origin + scale * m, SD = scale * sqrt(n / (n - 1) * sum(w * (z - m)^2)))
    }, numeric(2))
    # Pool variances, then take the square root. Scale the SDs first to avoid
    # overflow when the variances exceed the numeric range but the SD does not.
    sd_scale <- max(per_pv[2, ])
    pooled_sd <- if (sd_scale == 0) 0 else sd_scale * sqrt(mean((per_pv[2, ] / sd_scale)^2))
    data.frame(.population = population, .mean = mean(per_pv[1, ]),
                .sd = pooled_sd)
  })
  do.call(rbind, rows)
}

.population_moment_labels_idm <- function(moments, digits) {
  formatted <- function(x) {
    x <- round(x, digits = as.integer(digits))
    x[x == 0] <- 0 # Avoid displaying negative zero after rounding.
    formatC(x, format = "f", digits = as.integer(digits))
  }
  stats::setNames(paste0("M = ", formatted(moments$.mean),
                         "; SD = ", formatted(moments$.sd)), moments$.population)
}

.add_population_moments_idm <- function(pp, dat, colors, show_population_stats,
                                        population_stats_digits) {
  if (!show_population_stats || is.null(dat)) return(pp)
  labels <- .population_moment_labels_idm(.population_moments_idm(dat), population_stats_digits)
  if (!is.null(colors)) {
    fill_scale <- pp$scales$get_scales("fill")
    fill_scale$labels <- stats::setNames(paste0(names(colors), "\n", labels[names(colors)]),
                                         names(colors))
    pp <- pp + ggplot2::guides(fill = ggplot2::guide_legend(
      theme = ggplot2::theme(legend.key.spacing.y = grid::unit(1.5, "mm"))
    ))
  }
  pp + ggplot2::labs(
    subtitle = if (is.null(colors)) unname(labels) else NULL,
    caption = paste(pp$labels$caption,
                     "M and SD: PV means averaged; SD = square root of average PV variance.", sep = "\n")
  )
}
