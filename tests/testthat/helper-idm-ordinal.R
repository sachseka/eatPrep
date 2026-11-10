.ordinal_test_long <- function() {
  # A crossed design with both variance components away from zero. Preserve
  # the calling test's random state so this fixture cannot affect other tests.
  had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get(".Random.seed", envir = .GlobalEnv)
  on.exit({
    if (had_seed) {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      rm(".Random.seed", envir = .GlobalEnv)
    }
  })
  set.seed(4721)
  n_items <- 60L
  n_raters <- 10L
  dat <- expand.grid(item = seq_len(n_items), person = seq_len(n_raters))
  dat$est <- seq(-2.5, 2.5, length.out = n_items)[dat$item]
  rater_effect <- stats::rnorm(n_raters, 0, 0.7)
  item_effect <- stats::rnorm(n_items, 0, 0.65)
  latent <- 1.1 * dat$est + rater_effect[dat$person] +
    item_effect[dat$item] + stats::rlogis(nrow(dat))
  dat$rating <- findInterval(latent, c(-1.5, -0.5, 0.5, 1.5)) + 1L
  dat$item <- sprintf("item%02d", dat$item)
  dat$person <- sprintf("Rater%02d", dat$person)
  dat
}

.ordinal_test_wide <- function(dat = .ordinal_test_long()) {
  items <- unique(dat$item)
  out <- data.frame(item = items, est = dat$est[match(items, dat$item)])
  for (person in unique(dat$person)) {
    person_dat <- dat[dat$person == person, ]
    out[[person]] <- person_dat$rating[match(items, person_dat$item)]
  }
  out
}

.ordinal_test_fit <- function(dat = .ordinal_test_long(), ...) {
  # The strong rater effects deliberately put some individual cuts beyond the
  # item range. Silence only that known notice; unexpected fit warnings remain.
  withCallingHandlers(
    computeCutsIDMOrdinal(dat, item_id_col = "item", rater_id_col = "person",
                          rating_col = "rating", input_format = "long", ...),
    warning = function(w) {
      if (identical(conditionMessage(w), paste0(
        "Ordinal IDM diagnostics: some cuts lie outside the observed difficulty range. ",
        "See model_diagnostics and cut_diagnostics."))) invokeRestart("muffleWarning")
    }
  )
}
