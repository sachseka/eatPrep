# Input list for the scoring ----------------------------------------------
mistypes <- c("mnr", "mbd", "mir", "mbi")

unitRecodingsPrep <- data.frame(
  unit = rep("I03", 4 + 4),
  value = c(0:3, mistypes),
  valueRecode = c(rep(0, 3), 1, mistypes),
  valueType = c(rep("vc", 4), mistypes)
)

unitRecodingsDefault <- rbind.data.frame(
  within(unitRecodingsPrep, {
    unit = "I02"
  }), unitRecodingsPrep)

unitsDefault <- data.frame(
  unit = c("I01", "I02", "I03", "I04", "ID"),
  unitType = c("TI", "TI", "TI", "TI", "ID"),
  unitAggregateRule = c("", "SUM", "SUM", "", "")
)

subunitsDefault <- data.frame(
  unit = c("I01", rep(c("I02", "I03"), each = 3), "I04"),
  subunit = c("I01", paste0("I02", c("a", "b", "c")), paste0("I03", c("a", "b", "c")), "I04"),
  subunitRecoded = paste0(
    c("I01", paste0("I02", c("a", "b", "c")), paste0("I03", c("a", "b", "c")), "I04"),
    "R")
)

scoreDataTest <- function(
    dat = dat,
    unitrecodings = unitRecodingsDefault,
    units = unitsDefault,
    subunits = subunitsDefault,
    verbose = TRUE
) {
  scoreData(
    dat = dat,
    unitrecodings = unitrecodings,
    units = units,
    subunits = subunits,
    verbose = verbose)
}

# Data to be scored
generateData <- function() {
  data.frame(
    ID = paste0("person", 100:105),
    I01 = c(0, 1, 1, "mbi", "mir", "mbd"),
    I02 = c(0, 1, 2, 3, "mbd", "mir"),
    I03 = c(0, 1, 2, 3, "mbd", "mbd"),
    I04 = c(0, 1, 0, 1, "mbi", "mbd")
  )
}

test_that_cli("returns no errors if everything is correct", {
  testScore <- generateData()

  expect_snapshot(scoreDataTest(testScore))
})

test_that_cli("checks for data.frame", {
  testScore <- list(x = 1)

  expect_snapshot(scoreDataTest(testScore), error = TRUE)
})

test_that_cli("throws no error if there are less items to score in the data.frame", {
  testScore <- generateData()
  testScore$I02 <- NULL

  # expect_error(scoreDataTest(testScore))
  expect_snapshot(scoreDataTest(testScore))
})

test_that_cli("throws an error if there are less items to score in the unitrecodings", {
  testScore <- generateData()
  falseUnitRecodings <- subset(unitRecodingsDefault, unit != "I02")

  expect_snapshot(scoreDataTest(testScore, unitrecodings = falseUnitRecodings))
})

# Probably irrelevant test
test_that_cli("throws an error if there are less items to score in the units", {
  testScore <- generateData()
  falseUnits <- subset(unitsDefault, unit != "I02")

  # TODO: units seems to be irrelevant here!
  # Could the `units` element be eliminated?
  # TODO: Should return an error?
  expect_snapshot(scoreDataTest(testScore, units = falseUnits))
})

test_that_cli("throws an error if the item codes items to score in the unitrecodings", {
  testScore <- generateData()
  falseSubunits <- subset(subunitsDefault, unit != "I02")

  # TODO: does not throw the appropriate message ... I02 was correctly recoded, but
  # was actually not in the subunit (therefore, the message is falsy)
  expect_snapshot(scoreDataTest(testScore, subunits = falseSubunits))
})
