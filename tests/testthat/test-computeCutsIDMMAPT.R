.mapt_test_wide <- function() {
  counts_a <- rbind(c(4, 2, 2, 1, 1), c(3, 3, 2, 1, 1),
                    c(2, 2, 3, 2, 1), c(1, 2, 2, 3, 2),
                    c(1, 1, 2, 2, 4))
  counts_b <- rbind(c(5, 2, 1, 1, 1), c(4, 2, 2, 1, 1),
                    c(3, 2, 2, 2, 1), c(2, 2, 2, 2, 2),
                    c(1, 2, 2, 2, 3))
  data.frame(
    item = sprintf("item%02d", 1:50),
    est = rep(-2:2, each = 10),
    RaterA = unlist(lapply(seq_len(5), function(i) rep(1:5, counts_a[i, ]))),
    RaterB = unlist(lapply(seq_len(5), function(i) rep(1:5, counts_b[i, ])))
  )
}

.mapt_test_long <- function(wide = .mapt_test_wide()) {
  rbind(
    data.frame(item = wide$item, est = wide$est, person = "RaterA",
               rating = wide$RaterA),
    data.frame(item = wide$item, est = wide$est, person = "RaterB",
               rating = wide$RaterB)
  )
}

.mapt_test_fit_long <- function(dat, ...) {
  # This deliberately overlapping fixture has some extrapolated outer cuts.
  suppressWarnings(computeCutsIDMMAPT(
    dat, item_id_col = "item", rater_id_col = "person",
    rating_col = "rating", input_format = "long", ...
  ))
}

.mapt_test_glm_cut <- function(est, rating, boundary) {
  model <- stats::glm(I(rating > boundary) ~ est, family = stats::binomial())
  unname(-stats::coef(model)[1] / stats::coef(model)[2])
}

test_that("large numeric item identifiers remain distinct in both input formats", {
  wide <- .mapt_test_wide()
  expected <- .mapt_test_fit_long(.mapt_test_long(wide))
  wide$item <- 1e15 + seq_len(nrow(wide)) - 1
  long_result <- .mapt_test_fit_long(.mapt_test_long(wide))
  wide_result <- suppressWarnings(computeCutsIDMMAPT(wide, item_id_col = "item"))
  for (result in list(long_result, wide_result)) {
    expect_equal(length(unique(result$data_used$item_id)), nrow(wide))
    expect_equal(sort(unique(as.numeric(result$data_used$item_id))), wide$item)
    expect_equal(result$cuts_summary, expected$cuts_summary)
    expect_equal(result$cuts_per_person, expected$cuts_per_person)
  }
})

test_that("large numeric raters sharing items are not rejected as duplicates", {
  dat <- .mapt_test_long()
  expected <- .mapt_test_fit_long(dat)
  ids <- c(1e15, 1e15 + 1)
  dat$person <- rep(ids, each = 50)
  result <- .mapt_test_fit_long(dat)
  expect_equal(nrow(result$cuts_per_person), 2L)
  index <- match(ids, as.numeric(result$cuts_per_person$person))
  expect_false(anyNA(index))
  expect_equal(result$cuts_per_person[index, result$cut_labels],
               expected$cuts_per_person[expected$cut_labels])
  expect_length(result$models_per_person, 2L)
})

test_that("ambiguous class-specific MAPT identifier labels are rejected", {
  dat <- .mapt_test_long()
  # Fractional dates have different underlying values but identical labels.
  dat$person <- as.Date(rep(c(1, 1.1), each = 50), origin = "1970-01-01")
  expect_error(.mapt_test_fit_long(dat), "Distinct identifiers")
})

test_that("large numeric raters with disjoint items are not silently pooled", {
  dat <- .mapt_test_long()
  expected <- .mapt_test_fit_long(dat)
  ids <- c(1e15, 1e15 + 1)
  dat$item <- seq_len(nrow(dat))
  dat$person <- rep(ids, each = 50)
  result <- .mapt_test_fit_long(dat)
  expect_equal(nrow(result$cuts_per_person), 2L)
  index <- match(ids, as.numeric(result$cuts_per_person$person))
  expect_false(anyNA(index))
  expect_equal(result$cuts_per_person[index, result$cut_labels],
               expected$cuts_per_person[expected$cut_labels])
  expect_true(all(result$diagnostics_per_person$n == 50L))
  expect_equal(length(unique(result$data_used$person)), 2L)
})

test_that("MAPT summaries expose pooled cuts and diagnostics without model dumps", {
  result <- .mapt_test_fit_long(.mapt_test_long())
  overview <- summary(result)
  expect_s3_class(overview, "summary.cutsIDMMAPT")
  expect_equal(overview$cuts_summary, result$cuts_summary)
  expect_equal(overview$cut_diagnostics, result$cut_diagnostics)
  expect_equal(overview$n_ratings, 100L)
  expect_equal(overview$n_items, 50L)
  expect_equal(overview$n_raters, 2L)
  expect_null(overview$cuts_per_person)
  expect_false(any(c("models", "data_used") %in% names(overview)))
  expect_setequal(overview$issues$scope, c("pooled", "rater"))
  expect_true(all(overview$issues$extrapolated))
  details <- summary(result, per_rater = TRUE)
  expect_equal(details$cuts_per_person, result$cuts_per_person)
  expect_equal(details$diagnostics_per_person, result$diagnostics_per_person)
  output <- capture.output(returned <- withVisible(print(result)))
  expect_match(paste(output, collapse = "\n"), "Pooled cuts")
  expect_match(paste(output, collapse = "\n"), "Flagged fits")
  expect_false(returned$visible)
  expect_identical(returned$value, result)
  expect_output(print(details), "Individual rater cuts")
  expect_output(print(overview, digits = 1), "-2.3")
  expect_error(summary(result, per_rater = NA), "per_rater")
  expect_error(print(result, digits = -1), "digits")
})

test_that("MAPT summaries explain unavailable fits and missing individual results", {
  dat <- data.frame(est = 1:8, RaterA = rep(1, 8))
  result <- suppressWarnings(computeCutsIDMMAPT(dat, boundaries = 1.5, per_rater = FALSE))
  overview <- summary(result, per_rater = TRUE)
  expect_equal(overview$issues$status, "one_class")
  expect_null(overview$cuts_per_person)
  expect_false(overview$per_rater_available)
  expect_output(print(overview), "Cut order cannot be checked")
  expect_output(print(overview), "Individual fits unavailable")
  invisible(capture.output(returned <- withVisible(print(overview))))
  expect_identical(returned$value, overview)
  expect_false(returned$visible)

  valid <- .mapt_test_fit_long(.mapt_test_long(), boundaries = 2.5, per_rater = FALSE)
  expect_equal(nrow(summary(valid)$issues), 0L)
  expect_output(print(valid), "No flagged fits")
  valid$cuts_ordered <- FALSE
  expect_output(print(valid), "not strictly increasing")
})

test_that("MAPT summaries retain no-data diagnostics while counting used ratings", {
  dat <- .mapt_test_long()
  dat$rating[dat$person == "RaterB"] <- NA
  result <- .mapt_test_fit_long(dat, boundaries = 2.5)
  overview <- summary(result)
  expect_equal(overview$n_dropped, 50L)
  expect_equal(overview$n_ratings, 50L)
  expect_equal(overview$n_raters, 1L)
  expect_equal(overview$issues$person, "RaterB")
  expect_equal(overview$issues$status, "no_data")
})

test_that("MAPT cuts reproduce separate pooled binary logistic regressions", {
  dat <- .mapt_test_long()
  result <- .mapt_test_fit_long(dat)
  boundaries <- c(1.5, 2.5, 3.5, 4.5)
  expected <- vapply(boundaries, function(b) {
    .mapt_test_glm_cut(dat$est, dat$rating, b)
  }, numeric(1))

  expect_s3_class(result$cuts_summary, "tbl_df")
  expect_equal(nrow(result$cuts_summary), 1L)
  expect_equal(unname(unlist(result$cuts_summary)), expected, tolerance = 1e-7)
  expect_equal(result$cut_diagnostics$cut, expected, tolerance = 1e-7)
  expect_equal(result$cut_diagnostics$boundary, boundaries)
  expect_true(all(result$cut_diagnostics$status == "ok"))
  expect_equal(result$cut_diagnostics$n, rep(nrow(dat), length(boundaries)))
  expect_equal(result$cut_diagnostics$n_lower,
               vapply(boundaries, function(b) sum(dat$rating < b), integer(1)))
  expect_equal(result$cut_diagnostics$n_upper,
               vapply(boundaries, function(b) sum(dat$rating > b), integer(1)))
  expect_equal(result$cut_diagnostics$cut,
               -result$cut_diagnostics$intercept / result$cut_diagnostics$slope)
  expect_identical(names(result$models), result$cut_diagnostics$cut_name)
  expect_true(all(vapply(result$models, inherits, logical(1), what = "glm")))
  expect_true(all(vapply(result$models, function(model) {
    identical(model$family$family, "binomial") && identical(model$family$link, "logit")
  }, logical(1))))
  probabilities <- vapply(seq_along(result$models), function(i) {
    model <- result$models[[i]]
    at_cut <- data.frame(difficulty =
      (result$cut_diagnostics$cut[i] - model$est_center) / model$est_scale)
    unname(stats::predict(model, newdata = at_cut, type = "response"))
  }, numeric(1))
  expect_equal(probabilities, rep(0.5, length(boundaries)), tolerance = 1e-12)
})

test_that("the pooled MAPT estimate is distinguished from a mean of rater cuts", {
  dat <- .mapt_test_long()
  result <- .mapt_test_fit_long(dat)
  boundaries <- result$cut_diagnostics$boundary
  cut_names <- result$cut_diagnostics$cut_name
  expected <- vapply(boundaries, function(b) {
    vapply(c("RaterA", "RaterB"), function(person) {
      rows <- dat$person == person
      .mapt_test_glm_cut(dat$est[rows], dat$rating[rows], b)
    }, numeric(1))
  }, numeric(2))

  actual <- result$cuts_per_person[
    match(c("RaterA", "RaterB"), result$cuts_per_person$person), cut_names
  ]
  expect_equal(unname(as.matrix(actual)), unname(expected), tolerance = 1e-7)
  expect_equal(unname(unlist(result$cuts_summary_per_person)),
               unname(colMeans(expected)), tolerance = 1e-7)
  expect_gt(max(abs(unlist(result$cuts_summary) - colMeans(expected))), 0.01)
  expect_equal(nrow(result$diagnostics_per_person), 8L)
  expect_identical(names(result$models_per_person), result$cuts_per_person$person)
  for (person in names(result$models_per_person)) {
    models <- result$models_per_person[[person]]
    expect_identical(names(models), cut_names)
    cuts <- unlist(result$cuts_per_person[result$cuts_per_person$person == person, cut_names])
    at_cuts <- vapply(seq_along(models), function(i) {
      model <- models[[i]]
      unname(stats::predict(model, data.frame(difficulty =
        (cuts[i] - model$est_center) / model$est_scale), type = "response"))
    }, numeric(1))
    expect_equal(at_cuts, rep(0.5, length(boundaries)), tolerance = 1e-12)
  }
})

test_that("ties and arbitrary row order leave MAPT cuts unchanged", {
  dat <- .mapt_test_long()
  original <- .mapt_test_fit_long(dat)
  # Distinct items share estimates and have different ratings at every estimate.
  # This deterministic permutation moves both tied and untied observations.
  rows <- c(seq(2L, nrow(dat), by = 2L), seq(1L, nrow(dat), by = 2L))
  shuffled <- .mapt_test_fit_long(dat[rev(rows), ])

  expect_equal(shuffled$cuts_summary, original$cuts_summary, tolerance = 1e-12)
  expect_equal(shuffled$cuts_per_person, original$cuts_per_person, tolerance = 1e-12)
  expect_equal(shuffled$cut_diagnostics, original$cut_diagnostics, tolerance = 1e-12)
  expect_equal(shuffled$diagnostics_per_person, original$diagnostics_per_person,
               tolerance = 1e-12)
  expect_equal(original$cut_diagnostics$n, rep(nrow(dat), 4))
})

test_that("wide and long formats give the same MAPT estimates", {
  wide <- .mapt_test_wide()
  long_result <- .mapt_test_fit_long(.mapt_test_long(wide))
  wide_result <- suppressWarnings(computeCutsIDMMAPT(
    wide, item_id_col = "item", input_format = "wide"
  ))
  auto_result <- suppressWarnings(computeCutsIDMMAPT(
    wide, rater_cols = c("RaterA", "RaterB")
  ))

  expect_equal(wide_result$cuts_summary, long_result$cuts_summary)
  expect_equal(wide_result$cuts_per_person, long_result$cuts_per_person)
  expect_equal(wide_result$cut_diagnostics, long_result$cut_diagnostics)
  expect_equal(auto_result$cuts_summary, long_result$cuts_summary)
})

test_that("omitting individual fits leaves the pooled estimate unchanged", {
  dat <- .mapt_test_long()
  full <- .mapt_test_fit_long(dat)
  pooled_only <- .mapt_test_fit_long(dat, per_rater = FALSE)

  expect_equal(pooled_only$cuts_summary, full$cuts_summary)
  expect_equal(pooled_only$cut_diagnostics, full$cut_diagnostics)
  expect_null(pooled_only$cuts_per_person)
  expect_null(pooled_only$cuts_summary_per_person)
  expect_null(pooled_only$diagnostics_per_person)
  expect_null(pooled_only$models_per_person)
})

test_that("MAPT cuts follow positive affine changes of the difficulty scale", {
  dat <- .mapt_test_long()
  original <- .mapt_test_fit_long(dat)
  dat$est <- 500 + 100 * dat$est
  transformed <- .mapt_test_fit_long(dat)

  expect_equal(unlist(transformed$cuts_summary),
               500 + 100 * unlist(original$cuts_summary), tolerance = 1e-6)
  names <- original$cut_diagnostics$cut_name
  expect_equal(as.matrix(transformed$cuts_per_person[, names]),
               500 + 100 * as.matrix(original$cuts_per_person[, names]), tolerance = 1e-6)
  expect_identical(transformed$cut_diagnostics$extrapolated,
                   original$cut_diagnostics$extrapolated)
})

test_that("explicit category order supports labels and factors", {
  dat <- .mapt_test_long()
  reference <- .mapt_test_fit_long(dat)
  levels <- c("1a", "1b", "2", "3", "4")
  dat$rating <- factor(levels[dat$rating], levels = rev(levels))
  labelled <- .mapt_test_fit_long(dat, rating_levels = levels)

  expect_identical(names(labelled$cuts_summary),
                   c("cut_1a_1b", "cut_1b_2", "cut_2_3", "cut_3_4"))
  expect_equal(unname(unlist(labelled$cuts_summary)),
               unname(unlist(reference$cuts_summary)))
  expect_equal(labelled$cuts_per_person$person, reference$cuts_per_person$person)
  expect_equal(unname(as.matrix(labelled$cuts_per_person[, -1])),
               unname(as.matrix(reference$cuts_per_person[, -1])))
  dat$rating <- as.character(dat$rating)
  expect_equal(.mapt_test_fit_long(dat, rating_levels = levels)$cuts_summary,
               labelled$cuts_summary)
})

test_that("omitted boundaries adapt to declared category count", {
  dat <- .mapt_test_long()
  dat$rating <- ifelse(dat$rating <= 2, "lower", "upper")
  result <- .mapt_test_fit_long(dat, rating_levels = c("lower", "upper"))

  expect_equal(result$cut_diagnostics$boundary, 1.5)
  expect_equal(ncol(result$cuts_summary), 1L)
  expect_equal(result$cut_diagnostics$cut,
               .mapt_test_glm_cut(dat$est, as.integer(dat$rating == "upper") + 1L, 1.5),
               tolerance = 1e-7)
})

test_that("custom column and cut names are respected", {
  dat <- .mapt_test_long()
  names(dat) <- c("item_cat", "theta", "Name", "Kategorie")
  result <- suppressWarnings(computeCutsIDMMAPT(
    dat, item_id_col = "item_cat", est_col = "theta", rater_id_col = "Name",
    rating_col = "Kategorie", input_format = "auto", boundaries = c(2.5, 3.5),
    cut_labels = c("middle", "upper")
  ))

  expect_identical(names(result$cuts_summary), c("middle", "upper"))
  expect_identical(result$cut_diagnostics$cut_name, c("middle", "upper"))
  expect_true(all(c("person", "middle", "upper") %in% names(result$cuts_per_person)))
})

test_that("missing ratings are dropped without changing remaining observations", {
  dat <- .mapt_test_long()
  dat$rating[c(1, 20, 66)] <- NA
  dropped <- .mapt_test_fit_long(dat, missing = "drop")
  reference <- .mapt_test_fit_long(dat[!is.na(dat$rating), ])

  expect_equal(dropped$cuts_summary, reference$cuts_summary)
  expect_equal(dropped$cuts_per_person, reference$cuts_per_person)
  expect_equal(dropped$cut_diagnostics$n, rep(97L, 4L))
  expect_equal(dropped$n_dropped, 3L)
  expect_error(.mapt_test_fit_long(dat, missing = "error"))
  dat$est[1] <- NA_real_
  expect_error(.mapt_test_fit_long(dat, missing = "drop"))
})

test_that("unidentifiable binary fits expose diagnostics and no numerical cut", {
  cases <- list(
    one_class = data.frame(est = 1:4, RaterA = rep(1, 4)),
    constant_est = data.frame(est = rep(1, 4), RaterA = c(1, 2, 1, 2)),
    separation = data.frame(est = 1:4, RaterA = c(1, 1, 2, 2))
  )

  for (status in names(cases)) {
    result <- suppressWarnings(computeCutsIDMMAPT(cases[[status]], boundaries = 1.5))
    expect_identical(result$cut_diagnostics$status, status, info = status)
    expect_true(is.na(result$cut_diagnostics$cut), info = status)
    expect_true(is.na(result$cuts_summary[[1]]), info = status)
    expect_true(is.na(result$cuts_summary_per_person[[1]]), info = status)
    expect_false(is.nan(result$cuts_summary_per_person[[1]]), info = status)
  }
})

test_that("a rater with no observations is retained with a no-data diagnostic", {
  dat <- .mapt_test_wide()
  dat$RaterB <- NA_real_
  result <- suppressWarnings(computeCutsIDMMAPT(dat))

  absent <- result$diagnostics_per_person$person == "RaterB"
  expect_true(all(result$diagnostics_per_person$status[absent] == "no_data"))
  expect_true(all(is.na(result$diagnostics_per_person$cut[absent])))
  expect_equal(result$cut_diagnostics$n, rep(50L, 4L))
  expect_equal(result$n_dropped, 50L)
  expect_equal(result$cuts_summary, result$cuts_summary_per_person)
  dat$RaterA <- NA_real_
  expect_error(computeCutsIDMMAPT(dat))
})

test_that("quasi separation at a shared estimate is detected", {
  dat <- data.frame(est = c(1, 2, 2, 3), RaterA = c(1, 1, 2, 2))
  result <- suppressWarnings(computeCutsIDMMAPT(dat, boundaries = 1.5))

  expect_identical(result$cut_diagnostics$status, "separation")
  expect_true(is.na(result$cut_diagnostics$cut))
})

test_that("a reversed difficulty association is not reported as a usable cut", {
  dat <- .mapt_test_wide()
  dat$est <- -dat$est
  result <- suppressWarnings(computeCutsIDMMAPT(dat))

  expect_true(all(result$cut_diagnostics$status == "nonpositive_slope"))
  expect_true(all(is.na(unlist(result$cuts_summary))))
  expect_true(all(result$cut_diagnostics$slope < 0))
})

test_that("finite extrapolated cuts are retained and explicitly flagged", {
  dat <- data.frame(est = rep(0:4, each = 10),
                    RaterA = unlist(lapply(c(1, 1, 1, 2, 2), function(n) {
                      c(rep(1, 10 - n), rep(2, n))
                    })))
  expect_warning(result <- computeCutsIDMMAPT(dat, boundaries = 1.5),
                 "outside the observed difficulty range")

  expect_identical(result$cut_diagnostics$status, "ok")
  expect_true(result$cut_diagnostics$extrapolated)
  expect_gt(result$cut_diagnostics$cut, max(dat$est))
  expect_equal(result$cut_diagnostics$cut,
               .mapt_test_glm_cut(dat$est, dat$RaterA, 1.5), tolerance = 1e-7)
})

test_that("invalid individual fits do not invalidate a usable pooled fit", {
  dat <- .mapt_test_wide()
  dat$RaterB <- 1
  result <- suppressWarnings(computeCutsIDMMAPT(dat, boundaries = 1.5))
  valid <- result$cuts_per_person[result$cuts_per_person$person == "RaterA", -1]

  expect_identical(result$cut_diagnostics$status, "ok")
  expect_true(is.finite(result$cuts_summary[[1]]))
  expect_equal(unname(unlist(result$cuts_summary_per_person)), unname(unlist(valid)))
  expect_true(any(result$diagnostics_per_person$status == "one_class"))
})

test_that("invalid identities and duplicate observations are rejected", {
  dat <- .mapt_test_long()
  expect_error(computeCutsIDMMAPT(dat, rater_id_col = "person", rating_col = "rating",
                                 input_format = "long"))
  expect_error(.mapt_test_fit_long(rbind(dat, dat[1, ])))
  duplicate_missing <- dat[1, ]
  duplicate_missing$rating <- NA_real_
  expect_error(.mapt_test_fit_long(rbind(dat, duplicate_missing), missing = "drop"))

  inconsistent <- dat
  inconsistent$est[51] <- inconsistent$est[51] + 1
  expect_error(.mapt_test_fit_long(inconsistent))
  no_item <- dat
  no_item$item[1] <- NA_character_
  expect_error(.mapt_test_fit_long(no_item))
  no_rater <- dat
  no_rater$person[1] <- NA_character_
  expect_error(.mapt_test_fit_long(no_rater))
})

test_that("invalid difficulty values, categories and boundaries are rejected", {
  dat <- .mapt_test_long()
  for (bad_est in list(NA_real_, Inf, -Inf, "unknown")) {
    invalid <- dat
    invalid$est[1] <- bad_est
    expect_error(.mapt_test_fit_long(invalid))
  }
  for (bad_rating in list(0, -1, 1.2, Inf, "unknown")) {
    invalid <- dat
    invalid$rating[1] <- bad_rating
    expect_error(.mapt_test_fit_long(invalid))
  }
  for (bad_boundaries in list(numeric(), 2, c(2.5, 1.5), c(1.5, 1.5), NA, Inf, 0.5)) {
    expect_error(.mapt_test_fit_long(dat, boundaries = bad_boundaries))
  }
  expect_error(.mapt_test_fit_long(dat, rating_levels = c(1, 2, 3, 4, 4)))
  expect_error(.mapt_test_fit_long(dat, rating_levels = c(1, 2, 3, 4)))
  expect_error(.mapt_test_fit_long(dat, rating_levels = 1:5, boundaries = 5.5))
  expect_error(.mapt_test_fit_long(dat, cut_labels = c("same", "same", "c", "d")))
  expect_error(.mapt_test_fit_long(dat, cut_labels = "one"))
})
