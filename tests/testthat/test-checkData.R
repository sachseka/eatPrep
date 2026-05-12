test_that("getID validates ID variable metadata", {
  varinfo <- list(ID = list(type = "ID"), item = list(type = ""))

  expect_identical(getID(varinfo), "ID")
  expect_error(getID(), "Found no information about variables", fixed = TRUE)
  expect_error(getID(list(item = list(type = ""))), "No ID variable specified", fixed = TRUE)
  expect_error(
    getID(list(ID1 = list(type = "ID"), ID2 = list(type = "ID"))),
    "Found more than one ID variable",
    fixed = TRUE
  )
})

test_that("checkID rejects missing, empty, and duplicated IDs", {
  expect_error(checkID(data.frame(ID = "1"), "missing", verbose = FALSE), "not found", fixed = TRUE)
  expect_error(checkID(data.frame(ID = c("1", "")), "ID", verbose = FALSE), "empty cells", fixed = TRUE)
  expect_error(checkID(data.frame(ID = c("1", "1")), "ID", verbose = FALSE), "duplicated entries", fixed = TRUE)

  expect_message(checkID(data.frame(ID = c("1", "2")), "ID", verbose = TRUE), "Only valid codes")
})

test_that("checkVars reports duplicated and undocumented variables", {
  dat <- data.frame(ID = "1", ID2 = "2", check.names = FALSE)
  names(dat) <- c("ID", "ID")
  expect_error(checkVars(dat, list(ID = list()), verbose = FALSE), "duplicated variable names", fixed = TRUE)

  expect_message(
    checkVars(data.frame(ID = "1", extra = "x"), list(ID = list()), verbose = TRUE),
    "Found no variable information about variable\\(s\\) extra"
  )
})

test_that("checkData reports missing-only cases and invalid codes", {
  values <- data.frame(
    subunit = "item",
    value = c("1", "8", "9"),
    valueRecode = c("1", "mir", "mbi"),
    valueLabel = c("one", "invalid", "intention"),
    valueLabelRecoded = c("one", "invalid", "intention"),
    valueDescription = c("valid", "missing - invalid response", "missing - by intention"),
    valueType = c("vc", "mir", "mbi"),
    stringsAsFactors = FALSE
  )
  subunits <- data.frame(
    unit = "item",
    subunit = "item",
    subunitType = "",
    subunitLabel = "Item",
    subunitDescription = "Item",
    subunitPosition = "1",
    subunitRecoded = "itemR",
    subunitLabelRecoded = "Recoded Item",
    stringsAsFactors = FALSE
  )
  units <- data.frame(
    unit = c("ID", "item"),
    unitLabel = c("ID", "Item"),
    unitDescription = c("ID", "Item"),
    unitType = c("ID", ""),
    unitAggregateRule = c("", ""),
    stringsAsFactors = FALSE
  )
  dat <- data.frame(ID = c("P1", "P2"), item = c("8", "bad"), stringsAsFactors = FALSE)

  expect_message(
    checkData(dat, "minimal", values, subunits, units, verbose = TRUE),
    "Found invalid codes in variable item"
  )
  expect_silent(checkData(dat, "minimal", values, subunits, units, ID = "ID", verbose = FALSE))
})
