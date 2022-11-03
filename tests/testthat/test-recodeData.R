test_that("recoded data contains only 0, 1, missings", {
  tempdatR <- recodeData(inputDat[[1]][ , -c(1,2)], inputList$values, inputList$subunits)
  expect_setequal(unique(unlist(tempdatR)), c("0", "1","mbi", "mir"))
})

test_that("recoded data preserves all rows and columns", {
  tempdatR <- recodeData(inputDat[[1]][ , -c(1,2)], values = inputList$values, subunits = inputList$subunits)
  expect_equal(dim(inputDat[[1]][ , -c(1,2)]), dim(tempdatR))
})

test_that("throws warning if a data point value has no recode value", {
  tempdat <- inputDat[[1]][ , -c(1,2)]
  tempdat$I06[10] <- 5
  expect_message(recodeData(tempdat, values = inputList$values, subunits = inputList$subunits),
                 "Incomplete recode information for variable(s): \nI06 (Value/s: 5).\n-- This/These value(s) occuring in data but WITHOUT recode info will not be recoded.", fixed=TRUE )
})

test_that("throws message if a variable cannot be recoded", {
  tempdat <- inputDat[[1]][ , -1]
  test <- capture_messages(recodeData(tempdat, inputList$values, inputList$subunits, verbose=TRUE))
  expect_equal(test[1],"\nFound no recode information for variable(s): \nhisei. \nThis/These variable(s) will not be recoded.\n")
  expect_equal(test[2],"\nVariables... I01, I02, I03, I04, I05, I06, I07, I08, I09, I10, I11, I12a, I12b, I12c, I13, I14, I15, I16, I17, I18, I19, I20, I21\n...have been recoded.\n")
})

test_that("recode works without subunits sheet, colnames are not recoded", {
  tempdatR <- recodeData(inputDat[[1]][ , -c(1,2)], values = inputList$values)
  expect_setequal(unique(unlist(tempdatR)), c("0", "1","mbi", "mir"))
  expect_false("I06R" %in% colnames(tempdatR))
  expect_true("I06" %in% colnames(tempdatR))
})

test_that("checkValuesSubunits is called from recodeData", {
  subs <- inputList$subunits[ -which(inputList$subunits == "I07"), ]
  suppressMessages(tempdatR <- recodeData(inputDat[[1]][ , -c(1,2)], values = inputList$values, subunits = subs))
  expect_true("I07" %in% colnames(tempdatR))
  expect_setequal(unique(unlist(tempdatR$I07)), c("0", "1","mbi"))
})
