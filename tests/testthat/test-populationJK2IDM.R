jk2_population_fixture <- function(grouped = FALSE) {
  d <- data.frame(
    id = 1:12,
    PV1 = c(-1, -1, 0, 10, 0, -1, 10, 0, 10, 10, -1, 0),
    PV2 = c(0, -1, 0, 10, -1, -1, 10, 0, 0, 10, -1, 10),
    weight = rep(1:3, 4), zone = rep(1:3, each = 4),
    replicate = rep(c(0, 0, 1, 1), 3)
  )
  if (grouped) {
    d$population <- "A_with_under_scores"
    b <- d
    b$population <- "B"
    b$weight <- rev(b$weight)
    b$PV1 <- b$PV1 + 1
    d <- rbind(d, b)
  }
  d
}

jk2_config <- function() list(PSU = "zone", repInd = "replicate")

jk2_cuts_fixture <- function() {
  computeCutsIDM(data.frame(est = seq(-2, 2, length.out = 8),
                            Rater1 = c(1, 1, 2, 2, 3, 3, 4, 5),
                            Rater2 = c(1, 2, 2, 3, 3, 4, 4, 5)),
                 boundaries = c(1.5, 2.5))
}

test_that("JK2 estimates and pooled SEs match a direct eatRep analysis", {
  skip_if_not_installed("eatRep", "0.15.0")
  pop <- jk2_population_fixture(TRUE)
  p <- plotPopulationCuts(c(0, 10), pop, pv_cols = c("PV1", "PV2"),
                          respondent_id_col = "id", weight_col = "weight",
                          population_col = "population", jk2 = jk2_config())
  actual <- attr(p, "population_percentages")
  # Independent long input, with globally unique IDs for the direct analysis.
  pop$id <- seq_len(nrow(pop))
  pop$population <- match(pop$population, unique(pop$population))
  long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long$level <- factor(ifelse(long$score < 0, 1, ifelse(long$score < 10, 2, 3)))
  direct <- eatRep::repTable(
    datL = as.data.frame(long), ID = "id", wgt = "weight", type = "JK2",
    PSU = "zone", repInd = "replicate", imp = "pv", groups = "population",
    dependent = "level", verbose = FALSE, progress = FALSE
  )
  expected <- eatRep::report2(direct, round = FALSE)$plain
  for (group in unique(actual$population)) {
    e <- expected[expected$population == match(group, unique(actual$population)), ]
    e <- e[match(as.character(1:3), e$parameter), ]
    expect_equal(actual$percentage[actual$population == group], 100 * e$est)
    expect_equal(actual$se[actual$population == group], 100 * e$se)
  }
  expect_true(all(actual$se > 0))
  # Explicit replicate weights plus Rubin pooling provide a second reference.
  d <- jk2_population_fixture()
  estimates <- variances <- numeric(2)
  for (pv in 1:2) {
    indicator <- as.numeric(d[[paste0("PV", pv)]] < 0)
    estimates[pv] <- weighted.mean(indicator, d$weight)
    replicates <- vapply(1:3, function(zone) {
      w <- d$weight * ifelse(d$zone == zone, 2 * (1 - d$replicate), 1)
      weighted.mean(indicator, w)
    }, numeric(1))
    variances[pv] <- sum((replicates - estimates[pv])^2)
  }
  expect_equal(actual$percentage[1], 100 * mean(estimates))
  expect_equal(actual$se[1], 100 * sqrt(mean(variances) + 1.5 * stats::var(estimates)))
})

test_that("all three plots return JK2 tables even when labels are hidden", {
  skip_if_not_installed("eatRep", "0.15.0")
  for (fun in list(plotPopulationCuts, plotPopulationCutsIDM, plotCutsIDM)) {
    args <- list(pv_data = jk2_population_fixture(TRUE), pv_cols = c("PV1", "PV2"),
                 respondent_id_col = "id", weight_col = "weight", population_col = "population",
                 jk2 = jk2_config(), show_caption = TRUE)
    if (identical(fun, plotPopulationCuts)) args$cuts <- c(0, 10) else args$res_list <- jk2_cuts_fixture()
    if (identical(fun, plotPopulationCutsIDM)) args$cut_selection <- "both"
    if (identical(fun, plotCutsIDM)) {
      args$show_aggregate <- TRUE
      args$show_residuals <- TRUE
    }
    shown <- do.call(fun, args)
    args$show_percentages <- FALSE
    hidden <- do.call(fun, args)
    result <- attr(shown, "population_percentages")
    expect_equal(result, attr(hidden, "population_percentages"))
    expect_true(all(is.finite(result$se)))
    expect_match(shown$labels$caption, "eatRep JK2")
    expect_false(grepl("eatRep JK2", hidden$labels$caption))
    expect_s3_class(ggplot2::ggplotGrob(shown), "gtable")
    if (!identical(fun, plotPopulationCuts)) expect_length(unique(result$panel), 3L)
  }
})

test_that("JK2 wide and long input agree, including missing PV dropping", {
  skip_if_not_installed("eatRep", "0.15.0")
  for (missing in c(FALSE, TRUE)) {
    pop <- jk2_population_fixture(TRUE)
    if (missing) pop$PV1[1] <- NA_real_
    args <- list(cuts = c(0, 10), respondent_id_col = "id", weight_col = "weight",
                 population_col = "population", jk2 = jk2_config(), pv_missing = "drop")
    run <- function(args) {
      if (missing) expect_warning(
        expect_warning(p <- do.call(plotPopulationCuts, args), "Number of imputations"), "Omitting"
      ) else
        p <- do.call(plotPopulationCuts, args)
      attr(p, "population_percentages")
    }
    wide <- run(c(args, list(pv_data = pop, pv_cols = c("PV1", "PV2"))))
    long <- tidyr::pivot_longer(pop, c("PV1", "PV2"), names_to = "pv", values_to = "score")
    long <- long[!is.na(long$score), ]
    # Row order must not affect matching of design information to respondents.
    long <- long[rev(seq_len(nrow(long))), ]
    result <- run(c(args, list(pv_data = long, pv_id_col = "pv", pv_value_col = "score")))
    key <- function(x) x[order(x$population, x$interval), ]
    expect_equal(unname(as.matrix(key(wide))), unname(as.matrix(key(result))))
  }
})

test_that("JK2 retains empty intervals, tied cuts, and supports a single PV", {
  skip_if_not_installed("eatRep", "0.15.0")
  d <- .prepare_population_idm(jk2_population_fixture(), pv_cols = "PV1", weight_col = "weight", jk2 = jk2_config())
  cuts <- data.frame(cut = c(-100, 0, 0, 10, 100), .facet_person = factor("Cuts"))
  result <- .population_percentages_idm(d, cuts, jk2_config())$values
  expect_equal(result$.percentage, c(0, 100 / 3, 0, 125 / 3, 25, 0))
  expect_equal(result$.se[c(1, 3, 6)], c(0, 0, 0))
  cuts$cut <- c(100, 200, 300, 400, 500)
  constant <- .population_percentages_idm(d, cuts, jk2_config())$values
  expect_equal(constant$.percentage, c(100, rep(0, 5)))
  expect_equal(constant$.se, rep(0, 6))
  cuts$cut[1] <- NA_real_
  incomplete <- .population_percentages_idm(d, cuts, jk2_config())
  expect_identical(incomplete$incomplete, "Cuts")
  expect_equal(nrow(incomplete$values), 0L)
  expect_named(incomplete$values, c(".facet_person", ".population", ".interval", ".lower", ".upper", ".percentage", ".se"))
})

test_that("invalid JK2 inputs fail explicitly", {
  d <- jk2_population_fixture()
  prepare <- function(jk2, data = d) .prepare_population_idm(data, pv_cols = "PV1", jk2 = jk2)
  for (bad in list(TRUE, "JK2", list(), list(PSU = "zone"),
                  list(PSU = "zone", repInd = "replicate", ignored = TRUE))) {
    expect_error(prepare(bad), "jk2 must")
  }
  expect_error(prepare(list(PSU = "absent", repInd = "replicate")), "absent")
  expect_error(prepare(list(PSU = "PV1", repInd = "replicate")), "distinct")
  for (bad in list(NA_real_, 2, "0")) {
    invalid <- d
    invalid$replicate[1] <- bad
    expect_error(prepare(jk2_config(), invalid), "0/1")
  }
  d$zone[1] <- NA
  expect_error(prepare(jk2_config()), "zones")
  expect_error(plotCutsIDM(jk2_cuts_fixture(), jk2 = jk2_config()), "pv_data is required")
})

test_that("JK2 validates respondent consistency and retained replicate pairs", {
  skip_if_not_installed("eatRep", "0.15.0")
  d <- jk2_population_fixture()
  long <- tidyr::pivot_longer(d, c("PV1", "PV2"), names_to = "pv", values_to = "score")
  long$zone[1] <- 2
  expect_error(.prepare_population_idm(long, respondent_id_col = "id", pv_id_col = "pv",
                                       pv_value_col = "score", jk2 = jk2_config()), "same JK2 zone")
  d$PV1[1:2] <- NA_real_
  expect_warning(dat <- .prepare_population_idm(d, pv_cols = c("PV1", "PV2"),
                                                 pv_missing = "drop", jk2 = jk2_config()), "Omitting")
  expect_error(.population_percentages_idm(dat, data.frame(cut = 0, .facet_person = factor("Cuts")),
                                           jk2_config()), "both repInd values")
})

test_that("NULL JK2 preserves existing default arguments, tables, and plot layers", {
  # No eatRep dependency is needed on the default path.
  testthat::local_mocked_bindings(.population_jk2_panel_idm = function(...) stop("JK2 must not run"))
  for (fun in list(plotPopulationCuts, plotPopulationCutsIDM, plotCutsIDM)) {
    expect_identical(tail(names(formals(fun)), 1), "jk2")
    args <- list(pv_data = jk2_population_fixture(), pv_cols = c("PV1", "PV2"), weight_col = "weight")
    if (identical(fun, plotPopulationCuts)) args$cuts <- c(0, 10) else args$res_list <- jk2_cuts_fixture()
    default <- do.call(fun, args)
    explicit <- do.call(fun, c(args, list(jk2 = NULL)))
    expect_equal(ggplot2::ggplot_build(default)$data, ggplot2::ggplot_build(explicit)$data)
    expect_equal(default$labels, explicit$labels)
    expect_equal(attr(default, "population_percentages"), attr(explicit, "population_percentages"))
    if (identical(fun, plotPopulationCuts)) {
      expect_named(attr(default, "population_percentages"),
                   c("population", "interval", "lower", "upper", "percentage"))
      expect_equal(attr(default, "population_percentages")$percentage, c(425 / 12, 475 / 12, 25))
    } else expect_null(attr(default, "population_percentages"))
  }
})
