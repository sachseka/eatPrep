
data(inputList)
data(inputDat)

dat <- lapply(inputDat, function(hh) hh[1:2,c(1:3,7:10)])
preparedData <- automateDataPreparation(inputList = inputList,
                                        datList = dat,	path = getwd(),
                                        readSpss = FALSE, checkData = TRUE,	mergeData = TRUE,
                                        recodeData = TRUE, recodeMnr = TRUE, breaks = 1,
                                        aggregateData = TRUE, scoreData = TRUE,
                                        writeSpss = FALSE, verbose = TRUE)


test_that_cli("checks for normal output and missing meta data info when scored", {

  expect_snapshot(prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
                                verbose=TRUE))
})

test_that("check for stop when raw", {

 expect_error(prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "raw",
                            verbose=TRUE), "Sorry, raw data export isn't implemented yet")
})

