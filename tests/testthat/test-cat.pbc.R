data(inputDat)
data(inputList)

datRaw <- mergeData(newID = "ID", datList = inputDat, addMbd = TRUE)
datRec <- recodeData(datRaw, values = inputList$values,
                     subunits=inputList$subunits)

test_that("normal functioning", {
  expect_snapshot(pbcs   <- catPbc(datRaw, datRec, idRaw = "ID", idRec = "ID",
                                   context.vars = "hisei", values = inputList$values,
                                   subunits = inputList$subunits))
})
