as_tibbles <- function(x) {
  lapply(x, tibble::as_tibble)
}

expect_equal_data_frame <- function(object, expected) {
  expect_equal(
    as.data.frame(object),
    as.data.frame(expected),
    ignore_attr = TRUE
  )
}

test_that("checkData accepts tibble data and metadata", {
  data(inputDat)
  data(inputList)

  expect_silent(
    checkData(
      dat = tibble::as_tibble(inputDat[[1]]),
      datnam = "booklet1",
      values = tibble::as_tibble(inputList$values),
      subunits = tibble::as_tibble(inputList$subunits),
      units = tibble::as_tibble(inputList$units),
      ID = "ID",
      verbose = FALSE
    )
  )
})

test_that("automateDataPreparation accepts tibble datList and inputList sheets", {
  data(inputDat)
  data(inputList)

  dat <- lapply(inputDat, function(hh) hh[1:2, c(1:3, 7:10)])
  tibble_dat <- as_tibbles(dat)
  tibble_input <- as_tibbles(inputList)

  res <- suppressMessages(
    automateDataPreparation(
      inputList = tibble_input,
      datList = tibble_dat,
      path = getwd(),
      readSpss = FALSE,
      checkData = TRUE,
      mergeData = TRUE,
      recodeData = TRUE,
      recodeMnr = TRUE,
      breaks = 1,
      aggregateData = TRUE,
      scoreData = TRUE,
      addMbd = TRUE,
      writeSpss = FALSE,
      verbose = FALSE
    )
  )

  expect_s3_class(res, "data.frame")
})

test_that("mergeData detects duplicated IDs in tibble inputs", {
  dat <- list(tibble::tibble(ID = c("1", "1"), x = c("a", "b")))

  expect_error(
    suppressMessages(mergeData(newID = "ID", datList = dat, verbose = FALSE)),
    "Multiple IDs",
    fixed = TRUE
  )
})

test_that("aggregateData accepts tibble aggregatemissings", {
  data(inputDat)
  data(inputList)

  prep_dat <- suppressMessages(
    automateDataPreparation(
      inputList = inputList,
      datList = inputDat,
      readSpss = FALSE,
      checkData = FALSE,
      mergeData = TRUE,
      recodeData = TRUE,
      aggregateData = FALSE,
      scoreData = FALSE,
      writeSpss = FALSE,
      verbose = FALSE
    )
  )

  expected <- suppressMessages(
    aggregateData(
      dat = prep_dat,
      subunits = inputList$subunits,
      units = inputList$units,
      aggregatemissings = inputList$aggrMiss,
      verbose = FALSE
    )
  )
  object <- suppressMessages(
    aggregateData(
      dat = tibble::as_tibble(prep_dat),
      subunits = tibble::as_tibble(inputList$subunits),
      units = tibble::as_tibble(inputList$units),
      aggregatemissings = tibble::as_tibble(inputList$aggrMiss),
      verbose = FALSE
    )
  )

  expect_equal_data_frame(object, expected)
})

test_that("catPbc accepts tibble data and metadata", {
  data(inputDat)
  data(inputList)

  dat_raw <- suppressMessages(mergeData(newID = "ID", datList = inputDat, addMbd = TRUE, verbose = FALSE))
  dat_rec <- suppressMessages(recodeData(dat_raw, values = inputList$values, subunits = inputList$subunits))

  expected <- catPbc(
    dat_raw,
    dat_rec,
    idRaw = "ID",
    idRec = "ID",
    context.vars = "hisei",
    values = inputList$values,
    subunits = inputList$subunits
  )
  object <- catPbc(
    tibble::as_tibble(dat_raw),
    tibble::as_tibble(dat_rec),
    idRaw = "ID",
    idRec = "ID",
    context.vars = "hisei",
    values = tibble::as_tibble(inputList$values),
    subunits = tibble::as_tibble(inputList$subunits)
  )

  expect_equal_data_frame(object, expected)
})

test_that("prep2GADS accepts tibble data and inputList sheets", {
  data(inputDat)
  data(inputList)

  dat <- lapply(inputDat, function(hh) hh[1:2, c(1:3, 7:10)])
  prepared_raw <- suppressMessages(
    automateDataPreparation(
      inputList = inputList,
      datList = dat,
      path = getwd(),
      readSpss = FALSE,
      checkData = FALSE,
      mergeData = TRUE,
      recodeData = FALSE,
      recodeMnr = FALSE,
      aggregateData = FALSE,
      scoreData = FALSE,
      addMbd = FALSE,
      writeSpss = FALSE,
      verbose = FALSE
    )
  )

  out <- suppressMessages(
    prep2GADS(
      dat = tibble::as_tibble(prepared_raw),
      inputList = as_tibbles(inputList[1:3]),
      trafoType = "raw",
      verbose = FALSE
    )
  )

  expect_s3_class(out, "GADSdat")
})
