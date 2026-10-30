test_that("ordinal mixed cuts agree with an independently fitted crossed model", {
  dat <- .ordinal_test_long()
  result <- .ordinal_test_fit(dat)
  direct_dat <- transform(dat, rating = ordered(rating),
                          person = factor(person), item = factor(item))
  direct <- ordinal::clmm(rating ~ est + (1 | person) + (1 | item),
                          data = direct_dat, link = "logit", Hess = TRUE,
                          control = ordinal::clmm.control(
                            rel.tol = 1e-10, iter.max = 200, eval.max = 400))
  expected <- unname(direct$alpha / direct$beta["est"])
  expect_s3_class(result, "cutsIDMOrdinal")
  expect_s3_class(result$model, "clmm")
  expect_equal(unname(unlist(result$cuts_summary)), expected, tolerance = 2e-4)
  expect_true(all(result$cut_diagnostics$status == "ok"))
  expect_true(result$cuts_ordered)
  expect_equal(nrow(result$data_used), 600L)
  expect_equal(length(result$model$ST), 2L)

  # These are conditional modes of a shared fit, not ten separately fitted
  # models. Their sign must move a high-rating rater's cut downwards.
  modes <- ordinal::ranef(direct)$person[, 1L]
  names(modes) <- rownames(ordinal::ranef(direct)$person)
  for (i in seq_len(nrow(result$cuts_per_person))) {
    person <- result$cuts_per_person$person[i]
    expected_person <- unname((direct$alpha - modes[person]) / direct$beta["est"])
    expect_equal(unname(unlist(result$cuts_per_person[i, result$cut_labels])),
                 expected_person, tolerance = 2e-4)
  }
  expect_equal(result$rater_effects$effect[match(names(modes), result$rater_effects$person)],
               unname(modes), tolerance = 2e-4)
  item_modes <- ordinal::ranef(direct)$item[, 1L]
  item_ids <- rownames(ordinal::ranef(direct)$item)
  expect_equal(result$item_effects$effect[match(item_ids, result$item_effects$item_id)],
               unname(item_modes), tolerance = 2e-4)
})

test_that("ordinal estimates are equivalent for long, wide and permuted input", {
  dat <- .ordinal_test_long()
  long <- .ordinal_test_fit(dat)
  expect_warning(wide <- computeCutsIDMOrdinal(.ordinal_test_wide(dat), item_id_col = "item"),
                  "some cuts lie outside")
  reordered <- .ordinal_test_fit(dat[rev(seq_len(nrow(dat))), ])
  expect_equal(wide$cuts_summary, long$cuts_summary, tolerance = 1e-7)
  expect_equal(reordered$cuts_summary, long$cuts_summary, tolerance = 1e-7)
  expect_equal(wide$cuts_per_person, long$cuts_per_person, tolerance = 1e-7)
  expect_equal(reordered$cuts_per_person, long$cuts_per_person, tolerance = 1e-7)
  expect_equal(wide$input_format, "wide")
  expect_equal(long$input_format, "long")
})

test_that("ordinal cuts transform back to the original difficulty scale", {
  dat <- .ordinal_test_long()
  base <- .ordinal_test_fit(dat)
  dat$est <- 500 + 100 * dat$est
  scaled <- .ordinal_test_fit(dat)
  # Assess optimizer tolerance on the original scale, not the shifted scale.
  expect_equal((unname(unlist(scaled$cuts_summary)) - 500) / 100,
               unname(unlist(base$cuts_summary)), tolerance = 2e-4)
  expect_equal((as.matrix(scaled$cuts_per_person[scaled$cut_labels]) - 500) / 100,
               as.matrix(base$cuts_per_person[base$cut_labels]), tolerance = 2e-4)
  expect_equal(scaled$rater_effects, base$rater_effects, tolerance = 2e-4)
  expect_equal(scaled$item_effects, base$item_effects, tolerance = 2e-4)
})

test_that("ordinal rating labels preserve order without assuming label spacing", {
  dat <- .ordinal_test_long()
  plain <- .ordinal_test_fit(dat)
  labels <- c("A1", "A2", "B1", "B2", "C1")
  dat$rating <- labels[dat$rating]
  labelled <- .ordinal_test_fit(dat, rating_levels = labels)
  expect_equal(unname(unlist(labelled$cuts_summary)),
               unname(unlist(plain$cuts_summary)), tolerance = 1e-7)
  expect_equal(labelled$rating_levels, labels)
  expect_equal(labelled$boundaries, c(1.5, 2.5, 3.5, 4.5))
  expect_equal(labelled$cut_labels, paste0("cut_", labels[1:4], "_", labels[2:5]))
  dat$rating[1] <- "unknown"
  expect_error(.ordinal_test_fit(dat, rating_levels = labels), "rating_levels")
})

test_that("requested boundaries select thresholds from the same joint ordinal fit", {
  dat <- .ordinal_test_long()
  full <- .ordinal_test_fit(dat)
  subset <- .ordinal_test_fit(dat, boundaries = c(2.5, 4.5),
                              cut_labels = c("middle", "high"))
  expect_equal(unname(unlist(subset$cuts_summary)),
               unname(unlist(full$cuts_summary[c("cut23", "cut45")])),
               tolerance = 1e-7)
  expect_equal(subset$cut_labels, c("middle", "high"))
  expect_equal(length(subset$model$alpha), 4L)
})

test_that("ordinal no-random-effect comparison agrees with ordinary ordinal regression", {
  dat <- .ordinal_test_long()
  result <- .ordinal_test_fit(dat, random_effects = character())
  direct <- ordinal::clm(ordered(rating) ~ est, data = dat, link = "logit")
  expect_s3_class(result$model, "clm")
  expect_equal(unname(unlist(result$cuts_summary)),
               unname(direct$alpha / direct$beta["est"]), tolerance = 1e-6)
  for (i in seq_len(nrow(result$cuts_per_person))) {
    expect_equal(result$cuts_per_person[i, result$cut_labels], result$cuts_summary)
  }
})

test_that("each ordinal random-intercept component can be selected explicitly", {
  dat <- .ordinal_test_long()
  for (component in c("rater", "item")) {
    result <- .ordinal_test_fit(dat, random_effects = component)
    expect_s3_class(result$model, "clmm")
    expect_equal(length(result$model$ST), 1L)
    expect_true(all(result$cut_diagnostics$status == "ok"))
    expect_true(result$cuts_ordered)
  }
})

test_that("omitting ordinal rater output does not change reference estimates", {
  dat <- .ordinal_test_long()
  full <- .ordinal_test_fit(dat)
  reference <- .ordinal_test_fit(dat, per_rater = FALSE)
  expect_null(reference$cuts_per_person)
  expect_null(reference$diagnostics_per_person)
  expect_equal(reference$cuts_summary, full$cuts_summary)
  expect_equal(reference$rater_effects, full$rater_effects)
})

test_that("ordinal missing ratings are dropped without discarding other item ratings", {
  dat <- .ordinal_test_long()
  dat$rating[c(1, 70, 140)] <- NA_integer_
  dropped <- .ordinal_test_fit(dat)
  explicit <- .ordinal_test_fit(dat[!is.na(dat$rating), ])
  expect_equal(dropped$n_dropped, 3L)
  expect_equal(nrow(dropped$data_used), 597L)
  expect_equal(length(unique(dropped$data_used$item_id)), 60L)
  expect_equal(dropped$cuts_summary, explicit$cuts_summary)
  expect_error(.ordinal_test_fit(dat, missing = "error"), "missing")
  dat$rating[] <- NA_integer_
  expect_error(.ordinal_test_fit(dat), "observed ratings")
})

test_that("absent ordinal categories do not silently collapse the requested scale", {
  dat <- .ordinal_test_long()
  dat$rating[dat$rating == 3L] <- 2L
  expect_warning(result <- .ordinal_test_fit(dat, rating_levels = 1:5),
                  "missing_categories")
  expect_true(all(is.na(unlist(result$cuts_summary))))
  expect_true(all(result$cut_diagnostics$status == "missing_categories"))
  expect_equal(result$rating_levels, as.character(1:5))
  expect_equal(result$boundaries, c(1.5, 2.5, 3.5, 4.5))
  dat <- .ordinal_test_long()
  dat$rating[dat$rating == 5L] <- 4L
  expect_warning(outer <- .ordinal_test_fit(dat, rating_levels = 1:5),
                  "missing_categories")
  expect_true(all(is.na(unlist(outer$cuts_summary))))
  expect_match(outer$model_diagnostics$warning, "5")
})

test_that("decreasing ordinal ratings do not produce misleading ordered cuts", {
  dat <- .ordinal_test_long()
  dat$rating <- 6L - dat$rating
  expect_warning(result <- .ordinal_test_fit(dat, random_effects = character()),
                  "nonpositive_slope")
  expect_true(all(is.na(unlist(result$cuts_summary))))
  expect_true(all(result$cut_diagnostics$status == "nonpositive_slope"))
})

test_that("degenerate ordinal data retain unavailable cuts and diagnostic reasons", {
  dat <- .ordinal_test_long()
  constant <- dat
  constant$est <- 0
  expect_warning(constant_result <- .ordinal_test_fit(constant), "constant_est")
  expect_true(all(is.na(unlist(constant_result$cuts_summary))))
  expect_null(constant_result$model)

  single_class <- dat
  single_class$rating <- 1L
  expect_warning(single_result <- .ordinal_test_fit(single_class), "one_class")
  expect_true(all(is.na(unlist(single_result$cuts_summary))))

  separated <- dat
  separated$rating <- findInterval(separated$est, c(-1.5, -0.5, 0.5, 1.5)) + 1L
  expect_warning(separated_result <- .ordinal_test_fit(separated, random_effects = character()),
                  "separation")
  expect_true(all(is.na(unlist(separated_result$cuts_summary))))
  expect_null(separated_result$model)
})

test_that("ordinal optimizer failures do not expose tentative estimates as cuts", {
  dat <- .ordinal_test_long()
  expect_warning(result <- .ordinal_test_fit(dat, control = list(iter.max = 1L)),
                  "non_convergence")
  expect_false(result$model_diagnostics$converged)
  expect_s3_class(result$model, "clmm")
  expect_true(all(is.na(unlist(result$cuts_summary))))
  expect_true(all(is.na(unlist(result$cuts_per_person[result$cut_labels]))))
  expect_error(.ordinal_test_fit(dat, control = list(method = "ucminf")),
                "Unsupported control")
})

test_that("raters and items with only missing ordinal ratings retain their identities", {
  dat <- .ordinal_test_long()
  person <- dat$person[1]
  item <- dat$item[1]
  dat$rating[dat$person == person | dat$item == item] <- NA_integer_
  result <- .ordinal_test_fit(dat)
  person_row <- match(person, result$cuts_per_person$person)
  expect_false(is.na(person_row))
  expect_true(all(is.na(unlist(result$cuts_per_person[person_row, result$cut_labels]))))
  expect_true(all(result$diagnostics_per_person$status[
    result$diagnostics_per_person$person == person] == "no_data"))
  expect_true(is.na(result$rater_effects$effect[match(person, result$rater_effects$person)]))
  expect_true(is.na(result$item_effects$effect[match(item, result$item_effects$item_id)]))
  expect_equal(result$n_dropped, 69L)
})

test_that("a boundary variance estimate is flagged without discarding estimable cuts", {
  dat <- .ordinal_test_long()
  # Every rater has exactly the same non-monotone profile: no systematic
  # between-rater variation remains. The default matrix optimizer handles the boundary.
  dat$rating <- dat$rating[match(dat$item, dat$item)]
  expect_warning(result <- .ordinal_test_fit(dat, random_effects = "rater"),
                  "near zero")
  expect_true(result$model_diagnostics$singular)
  expect_true(all(result$cut_diagnostics$status == "ok"))
  direct <- ordinal::clm(ordered(rating) ~ est, data = dat, link = "logit")
  expect_equal(unname(unlist(result$cuts_summary)),
               unname(direct$alpha / direct$beta["est"]), tolerance = 2e-4)
})

test_that("ordinal print and summary expose compact diagnostics and conditional results", {
  result <- .ordinal_test_fit()
  overview <- summary(result)
  expect_s3_class(overview, "summary.cutsIDMOrdinal")
  expect_equal(overview$n_ratings, 600L)
  expect_equal(overview$n_items, 60L)
  expect_equal(overview$n_raters, 10L)
  expect_equal(overview$cuts_summary, result$cuts_summary)
  expect_equal(overview$model_diagnostics, result$model_diagnostics)
  expect_equal(overview$variance_components, result$variance_components)
  expect_null(overview$cuts_per_person)
  expect_false(any(c("model", "data_used") %in% names(overview)))
  individual <- summary(result, per_rater = TRUE)
  expect_equal(individual$cuts_per_person, result$cuts_per_person)
  expect_equal(individual$diagnostics_per_person, result$diagnostics_per_person)
  printed <- utils::capture.output(returned <- withVisible(print(result)))
  expect_false(returned$visible)
  expect_identical(returned$value, result)
  expect_match(paste(printed, collapse = "\n"), "Reference cuts")
  expect_false(any(grepl("Cumulative Link Mixed Model fitted", printed, fixed = TRUE)))
  printed_summary <- utils::capture.output(returned_summary <- withVisible(print(individual)))
  expect_false(returned_summary$visible)
  expect_identical(returned_summary$value, individual)
  expect_match(paste(printed_summary, collapse = "\n"), "Conditional rater cuts")
  expect_error(summary(result, per_rater = NA), "per_rater")
  expect_error(print(result, digits = -1), "digits")
})

test_that("ordinal input validation protects identities and random-effect structure", {
  dat <- .ordinal_test_long()
  expect_error(.ordinal_test_fit(rbind(dat, dat[1, ])), "item-rater")
  conflicting <- dat
  conflicting$est[1] <- 99
  expect_error(.ordinal_test_fit(conflicting), "one estimate")
  fractional <- dat
  fractional$rating[1] <- 2.2
  expect_error(.ordinal_test_fit(fractional), "integer")
  expect_error(.ordinal_test_fit(dat, random_effects = "unknown"), "random_effects")
  expect_error(.ordinal_test_fit(dat, boundaries = c(2.5, 1.5)), "boundaries")
  expect_error(.ordinal_test_fit(dat, boundaries = 2), "boundaries")
  expect_error(.ordinal_test_fit(dat, cut_labels = rep("duplicate", 4)), "duplicated")
  expect_error(.ordinal_test_fit(dat, cut_labels = c("person", "a", "b", "c")),
                "person")
  single_rater <- dat[dat$person == dat$person[1], ]
  expect_error(.ordinal_test_fit(single_rater), "rater|group|level")
  unique_items <- dat
  unique_items$item <- seq_len(nrow(dat))
  expect_error(.ordinal_test_fit(unique_items), "item|replicat|observation")
})

test_that("ordinal large numeric item and rater identifiers stay distinct", {
  dat <- .ordinal_test_long()
  base <- .ordinal_test_fit(dat)
  dat$item <- 1e15 + match(dat$item, unique(dat$item))
  dat$person <- 1e15 + match(dat$person, unique(dat$person))
  result <- .ordinal_test_fit(dat)
  expect_equal(length(unique(result$data_used$item_id)), 60L)
  expect_equal(length(unique(result$data_used$person)), 10L)
  expect_equal(result$cuts_summary, base$cuts_summary, tolerance = 2e-4)
})
