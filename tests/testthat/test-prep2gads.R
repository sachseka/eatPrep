# devtools::load_all()

data(inputList)
data(inputDat)

dat <- lapply(inputDat, function(hh) hh[1:2,c(1:3,7:10)])
preparedData <- automateDataPreparation(inputList = inputList,
                                        datList = dat,	path = getwd(),
                                        readSpss = FALSE, checkData = TRUE,	mergeData = TRUE,
                                        recodeData = TRUE, recodeMnr = TRUE, breaks = 1,
                                        aggregateData = TRUE, scoreData = TRUE,
                                        writeSpss = FALSE, verbose = TRUE)

#o2 <- prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
#          misTypes = list(mvi = -95, mnr = -96, mci = -97, mbd = -94, mir = -98, mbi = -99), verbose = TRUE)

#o3 <- eatGADS::import_raw2(o2$dat, o2$labels)

test_that_cli("checks for missing correct and false codes per unit", {

  prep2gads(dat = preparedData, inputList = inputList[1:3], trafoType = "scored",
            verbose=TRUE)
  expect_snapshot(prep2gads(prepList))
})
