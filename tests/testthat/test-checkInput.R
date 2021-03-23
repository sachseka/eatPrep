test_that("subunits without values are removed from subunits sheet", {
  vals <- inputList$values[ -which(inputList$values$subunit == "I01"), ]
  checked <- suppressMessages(checkValuesSubunits(values = vals, subunits = inputList$subunits))
  expect_false("I01" %in% checked$subunits$subunit)
  expect_message(checkValuesSubunits(values = vals, subunits = inputList$subunits),
  "Found no values for subunit\\(s\\) I01\\.\nThis/these subunit\\(s\\) will be removed from input")
})

test_that("subunits only found in values sheet will be appended to subunit sheet", {
  subs <- inputList$subunits[ -which(inputList$subunits == "I04"), ]
  checked <- suppressMessages(checkValuesSubunits(values = inputList$values, subunits = subs))
  expect_true("I04" %in% checked$subunits$subunit)
  expect_message(checkValuesSubunits(values = inputList$values, subunits = subs),
                 "Found only values for subunit\\(s\\) I04\\.\nThis/these subunit\\(s\\) will be appended to subunits sheet")
})

test_that("units without subunits are removed from units sheet", {
  subs <- inputList$subunits[ -which(inputList$subunits == "I04"), ]
  checked <- suppressMessages(checkSubunitsUnits(subunits = subs, units = inputList$units))
  expect_false("I04" %in% checked$units$unit)
  expect_message(checkSubunitsUnits(subunits = subs, units = inputList$units),
                 "Found no subunits for unit\\(s\\) I04\\.\nThis/these unit\\(s\\) will be removed from input")
})

test_that("subunits only found in subunits sheet will be appended to unit sheet", {
  subs <- dplyr::add_row(inputList$subunits, data.frame(unit = "I30", subunit = "I30", subunitRecoded = "I30R"))
#  subs <- dplyr::add_row(subs, data.frame(unit = "I31", subunit = "I31", subunitRecoded = "I31R"))
  checked <- suppressMessages(checkSubunitsUnits(subunits = subs, units = inputList$units))
  expect_true("I30" %in% checked$units$unit)
  expect_message(checkSubunitsUnits(subunits = subs, units = inputList$units),
                 "Found only subunits for unit\\(s\\) I30\\.\nThis/these unit\\(s\\) will be appended to units sheet")
})

#test_that("checkValuesSubunits works for unit recodings", {
#  expect_true(
#    checkValuesSubunits(values = inputList$unitRecodings, subunits = inputList$units)
#
#
#    )
#})
