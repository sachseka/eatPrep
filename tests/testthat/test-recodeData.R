test_that("recoded data contains only 0, 1, missings", {
  tempdatR <- recodeData(inputDat[[1]][ , -c(1,2)], inputList$values, inputList$subunits)
  expect_setequal(unique(unlist(tempdatR)), c("0", "1","mbi", "mir"))
})

test_that("recoded data preserves all rows and columns", {
  tempdatR <- recodeData(inputDat[[1]][ , -c(1,2)], inputList$values, inputList$subunits)
  expect_equal(dim(inputDat[[1]][ , -c(1,2)]), dim(tempdatR))
})

test_that("throws warning if a data point value has no recode value", {
  tempdat <- inputDat[[1]][ , -c(1,2)]
  tempdat$I06[10] <- 5
  expect_warning(recodeData(tempdat, inputList$values, inputList$subunits), "Incomplete recode information" )
})

test_that("throws message if a variable cannot be recoded", {
  tempdat <- inputDat[[1]]
  expect_message(recodeData(tempdat, inputList$values, inputList$subunits), "Found no recode information" )
})
