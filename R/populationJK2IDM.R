.validate_population_jk2_idm <- function(jk2, pv_data, other_cols) {
  if (is.null(jk2)) return(invisible(NULL))
  if (!is.list(jk2) || length(jk2) != 2L ||
      !setequal(names(jk2), c("PSU", "repInd"))) {
    stop("jk2 must be NULL or a list with exactly PSU and repInd column names.", call. = FALSE)
  }
  for (col in jk2) checkmate::assert_string(col, min.chars = 1)
  cols <- unlist(jk2, use.names = FALSE)
  checkmate::assert_names(cols, subset.of = names(pv_data))
  if (anyDuplicated(c(cols, other_cols))) {
    stop("JK2 design columns must be distinct from each other and all other input columns.",
         call. = FALSE)
  }
  zone <- pv_data[[jk2$PSU]]
  if (!(is.character(zone) || is.factor(zone) || is.numeric(zone)) ||
      anyNA(zone) || any(!nzchar(trimws(as.character(zone)))) ||
      (is.numeric(zone) && any(!is.finite(zone)))) {
    stop("JK2 zones must be non-missing, non-empty finite identifiers.", call. = FALSE)
  }
  rep <- pv_data[[jk2$repInd]]
  if (!is.numeric(rep) || anyNA(rep) || any(!rep %in% c(0, 1))) {
    stop("JK2 repInd must contain numeric 0/1 indicators without missing values.", call. = FALSE)
  }
  if (!requireNamespace("eatRep", quietly = TRUE)) {
    stop("Package 'eatRep' is required when jk2 is supplied; install it with install.packages('eatRep').",
         call. = FALSE)
  }
  invisible(NULL)
}

.population_jk2_panel_idm <- function(dat, boundaries, populations) {
  # Numeric internal identifiers avoid eatRep's delimiters and allow respondent
  # IDs to repeat between populations without merging distinct respondents.
  group <- match(as.character(dat$.population), populations)
  ids <- interaction(group, dat$.id, drop = TRUE, lex.order = TRUE)
  d <- data.frame(id = as.integer(ids), pv = match(dat$.pv, unique(dat$.pv)),
                  weight = dat$.weight,
                  zone = match(dat$.jk_zone, unique(dat$.jk_zone)),
                  replicate = dat$.jk_rep, population = group,
                  interval = factor(findInterval(dat$.value, boundaries) + 1L,
                                    levels = seq_len(length(boundaries) + 1L)))
  # Missing-PV dropping must not silently remove one half of a JK2 zone.
  for (draw in split(d, d$pv)) {
    paired <- vapply(split(draw$replicate, draw$zone), function(x) {
      setequal(x, c(0, 1))
    }, logical(1))
    if (!all(paired)) {
      stop("JK2 requires both repInd values (0 and 1) in every zone of each retained PV.",
           call. = FALSE)
    }
  }
  result <- eatRep::repTable(
    datL = d, ID = "id", wgt = "weight", type = "JK2",
    PSU = "zone", repInd = "replicate",
    imp = if (length(unique(d$pv)) > 1L) "pv" else NULL,
    groups = "population", group.splits = 1L,
    dependent = "interval", expected.values = levels(d$interval),
    engine = "survey", verbose = FALSE, progress = FALSE
  )
  estimates <- eatRep::report2(result, round = FALSE)$plain
  out <- lapply(seq_along(populations), function(i) {
    values <- estimates[as.character(estimates$population) == as.character(i), , drop = FALSE]
    index <- match(levels(d$interval), as.character(values$parameter))
    if (anyNA(index) || any(!is.finite(values$est[index])) ||
        any(!is.finite(values$se[index]))) {
      stop(sprintf("eatRep could not estimate all JK2 interval percentages and standard errors for population '%s'.",
                   populations[i]), call. = FALSE)
    }
    data.frame(.percentage = 100 * values$est[index], .se = 100 * values$se[index])
  })
  do.call(rbind, out)
}

.population_percentage_attribute_idm <- function(values, include_panel = TRUE) {
  result <- data.frame(
    population = as.character(values$.population), interval = values$.interval,
    lower = values$.lower, upper = values$.upper, percentage = values$.percentage
  )
  if (include_panel) result <- cbind(panel = as.character(values$.facet_person), result)
  if (".se" %in% names(values)) result$se <- values$.se
  result
}
