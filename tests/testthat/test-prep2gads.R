
data(inputList)
data(inputDat)

dat <- lapply(inputDat, function(hh) hh[1:2,c(1:3,7:10)])
preparedData <- automateDataPreparation(inputList = inputList,
                                        datList = dat,	path = getwd(),
                                        readSpss = FALSE, checkData = TRUE,	mergeData = TRUE,
                                        recodeData = TRUE, recodeMnr = TRUE, breaks = 1,
                                        aggregateData = TRUE, scoreData = TRUE, addMbd = TRUE,
                                        writeSpss = FALSE, verbose = TRUE)
preparedData2 <- automateDataPreparation(inputList = inputList,
                                        datList = dat,	path = getwd(),
                                        readSpss = FALSE, checkData = TRUE,	mergeData = TRUE,
                                        recodeData = FALSE, recodeMnr = FALSE, breaks = 1,
                                        aggregateData = FALSE, scoreData = FALSE, addMbd = FALSE,
                                        writeSpss = FALSE, verbose = TRUE)


test_that_cli("checks for normal output and missing meta data info when scored", {

  expect_snapshot(prep2GADS(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
                                verbose=TRUE))
})

# their meta data will be set to NA: `booklet` and `hisei`?
# --> but contain standard missings? rethink!

# test_that("check for stop when raw", {
#
#  expect_error(prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "raw",
#                             verbose=TRUE), "Sorry, raw data export isn't implemented yet")
# })

test_that_cli("checks for normal output and missing meta data info when raw", {

  expect_snapshot(prep2GADS(dat = preparedData2, inputList = inputList[1:3], trafoType = "raw",
                            verbose=TRUE))
})


test_that_cli("check whether mbd-specification via misTypes works (when no info in in values-sheet)", {
  inputList1 <- inputList
  inputList1[[3]] <- inputList[[3]][!grepl("mbd",inputList[[3]]$valueRecode),]
  expect_snapshot(prep2GADS(dat = preparedData2, inputList = inputList1[1:3], trafoType = "raw",
                            verbose=TRUE))
})

test_that_cli("check whether no mbd-specification gives message", {
  inputList1 <- inputList
  inputList1[[3]] <- inputList[[3]][!grepl("mbd",inputList[[3]]$valueRecode),]
  expect_snapshot(prep2GADS(dat = preparedData, inputList = inputList1[1:3], trafoType = "raw",
                            misTypes = list(mci = -97),
                            verbose=TRUE))
})


