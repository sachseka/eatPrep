test_that("subunits without values are removed from subunits sheet", {
  vals <- inputList$values[ -which(inputList$values$subunit == "I01"), ]
  expect_false("I01" %in% checkValuesSubunits(values = vals, subunits = inputList$subunits)$subunits$subunit)
  # I01 nicht in subunits-Sheet
})

test_that("subunits only found in values sheet will be appended to subunit sheet", {
  subs <- inputList$subunits[ -which(inputList$subunits == "I04"), ]
  expect_true("I04" %in% checkValuesSubunits(values = inputList$values, subunits = subs)$subunits$subunit)
})

test_that("units without subunits are removed from units sheet", {
  subs <- inputList$subunits[ -which(inputList$subunits == "I04"), ]
  expect_false("I04" %in% checkSubunitsUnits(subunits = subs, units = inputList$units)$units$unit)
  # I01 nicht in subunits-Sheet
})

test_that("subunits only found in subunits sheet will be appended to unit sheet", {
  subs <- dplyr::add_row(inputList$subunits, data.frame(unit = "I30", subunit = "I30", subunitRecoded = "I30R"))
  expect_true("I30" %in% checkSubunitsUnits(subunits = subs, units = inputList$units)$units$unit)
})

#test_that("checkValuesSubunits works for unit recodings", {
#  expect_true(
#    checkValuesSubunits(values = inputList$unitRecodings, subunits = inputList$units)
#
#
#    )
#})
