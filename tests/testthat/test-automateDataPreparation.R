
# test readSpss module:
data(inputList)
data(inputDat)
preparedData <- automateDataPreparation(inputList = inputList,
                                        datList = inputDat,	path = getwd(),
                                        readSpss = FALSE, checkData = TRUE,	mergeData = FALSE,
                                        recodeData = FALSE, recodeMnr = FALSE,
                                        aggregateData = FALSE, scoreData = FALSE,
                                        writeSpss = FALSE, verbose = TRUE)


test_that("load sav", {
  expect_error(automateDataPreparation(inputList = inputList,
                                       datList = NULL,	path = "none",
                                       readSpss = TRUE, checkData = FALSE,	mergeData = FALSE,
                                       recodeData = FALSE, recodeMnr = FALSE,
                                       aggregateData = FALSE, scoreData = FALSE,
                                       writeSpss = FALSE, verbose = TRUE),
               "All file(s) not found in:  : booklet1.sav, booklet2.sav, booklet3.sav", fixed=TRUE)
  expect_error(automateDataPreparation(inputList = NULL,
                                       datList = NULL,	path = "none",
                                       readSpss = TRUE, checkData = FALSE,	mergeData = FALSE,
                                       recodeData = FALSE, recodeMnr = FALSE,
                                       aggregateData = FALSE, scoreData = FALSE,
                                       writeSpss = FALSE, verbose = TRUE),
               "No .sav-files found in none", fixed=TRUE)
  path <- gsub("forcedChoice.sav", "", system.file("extdata", "forcedChoice.sav", package = "eatPrep"))
  expect_error(automateDataPreparation(inputList = inputList[1:3],
                                       datList = NULL,	path = path,
                                       readSpss = TRUE, checkData = FALSE,	mergeData = FALSE,
                                       recodeData = FALSE, recodeMnr = FALSE,
                                       aggregateData = FALSE, scoreData = FALSE,
                                       writeSpss = FALSE, verbose = TRUE),
               "Please specify oldIDs. Case ID in inputList$savFiles$case.id seems to be empty.", fixed=TRUE)
  expect_message(automateDataPreparation(inputList = inputList[1:3], oldIDs = c("ID", "ID"),
                                       datList = NULL,	path = path,
                                       readSpss = TRUE, checkData = FALSE,	mergeData = FALSE,
                                       recodeData = FALSE, recodeMnr = FALSE,
                                       aggregateData = FALSE, scoreData = FALSE,
                                       writeSpss = FALSE, verbose = TRUE),
               "Successfully read in: forcedChoice.sav, forcedChoice_missings.sav")
})



test_that("merge", {
  path <- gsub("forcedChoice.sav", "", system.file("extdata", "forcedChoice.sav", package = "eatPrep"))
  expect_message(ati <- automateDataPreparation(inputList = inputList[1:3], oldIDs = c("ID", "ID"),newID="idstud",
                                         datList = NULL,	path = path,
                                         readSpss = TRUE, checkData = FALSE,	mergeData = TRUE,
                                         recodeData = FALSE, recodeMnr = FALSE,
                                         aggregateData = FALSE, scoreData = FALSE,
                                         writeSpss = FALSE, verbose = TRUE),
                 "Start merging.")
  expect_equal(ati[1,], data.frame(idstud="1", mcvar="3", stringvar="", mc="2", string="new valid", stringsAsFactors=FALSE))
  expect_equal(dim(ati), c(12, 5))
  expect_message(ati2 <- automateDataPreparation(inputList = inputList[1:3], oldIDs = c("ID", "ID"),newID="idstud",
                                                datList = NULL,	path = path,
                                                readSpss = TRUE, checkData = FALSE,	mergeData = FALSE,
                                                recodeData = FALSE, recodeMnr = FALSE,
                                                aggregateData = FALSE, scoreData = FALSE,
                                                writeSpss = FALSE, verbose = TRUE),
                 "Merge has been skipped, but more than one dataset has been loaded. A list of datasets will be returned.")
  expect_warning(ati3 <- automateDataPreparation(inputList = inputList,
                                                 datList = inputDat,
                                                 readSpss = FALSE, checkData = FALSE,	mergeData = FALSE,
                                                 recodeData = TRUE, recodeMnr = FALSE,
                                                 aggregateData = FALSE, scoreData = FALSE,
                                                 writeSpss = FALSE, verbose = TRUE),
                 "Merge has been skipped. Only the first dataset in datList will be considered for the following steps.")
})
