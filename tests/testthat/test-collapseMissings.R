
test_that("throws warning if missings are recoded to values other than 0 and NA", {
  suppressMessages(tempdat <- recodeData(inputDat[[1]], values = inputList$values, subunits = inputList$subunits))
  misrule = list(mvi = 0, mci = NA, mbd = NA, mir = -98, mbi = -99, mnr = 0)
  expect_warning(collapseMissings(tempdat, misrule), "Found unexpected recode value\\(s\\): mir -98, mbi -99" )
})

test_that("throws warning if not all zkd missing types are specified in missing.rule", {
  suppressMessages(tempdat <- recodeData(inputDat[[1]], values = inputList$values, subunits = inputList$subunits))
  misrule = list(mvi = 0, mci = NA, mbd = NA, mir = 0, mbi = 0)
  expect_warning(collapseMissings(tempdat, misrule), "Found no recode information for missing type\\(s\\) mnr" )
})


test_that("throws warning if non-zkd missing types are specified in missing.rule", {
  suppressMessages(tempdat <- recodeData(inputDat[[1]], values = inputList$values, subunits = inputList$subunits))
  misrule = list(mvi = 0, mci = NA, mbd = NA, mir = 0, mbi = 0, mnr = 0, other = 0)
  expect_warning(collapseMissings(tempdat, misrule), "Found unexpected missing type\\(s\\) other" )
})


test_that("default missing.rule is correct", {
  tempdat <- data.frame(item = c(0, 1, "mbd", "mbi", "mci", "mir", "mnr", "mvi"), stringsAsFactors = F)
  expect_identical(collapseMissings(tempdat),
                   data.frame(item = as.character(c(0, 1, NA, 0, NA, 0, 0, 0), stringsAsFactors = F)))
})

