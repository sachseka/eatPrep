# merge

    Code
      ati4 <- automateDataPreparation(inputList = inputList, datList = singleDat,
        readSpss = FALSE, checkData = FALSE, mergeData = FALSE, recodeData = TRUE,
        recodeMnr = FALSE, aggregateData = FALSE, scoreData = FALSE, writeSpss = FALSE,
        verbose = FALSE)
    Condition
      Warning in `automateDataPreparation()`:
      Merge has been skipped. Only the first dataset in datList has been considered for the following steps.
    Message
      
      Merge has been skipped.

# almost all steps mbi

    Code
      ati5 <- automateDataPreparation(inputList = inputList, datList = inputDat,
        readSpss = FALSE, checkData = TRUE, mergeData = TRUE, recodeData = TRUE,
        recodeMnr = FALSE, aggregateData = TRUE, scoreData = TRUE, writeSpss = FALSE,
        verbose = FALSE)
    Message
      1 units were aggregated: I12.

# almost all steps mbo

    Code
      ati6 <- automateDataPreparation(inputList = iL2, datList = inputDat, readSpss = FALSE,
        checkData = TRUE, mergeData = TRUE, recodeData = TRUE, recodeMnr = FALSE,
        aggregateData = TRUE, scoreData = TRUE, writeSpss = FALSE, verbose = FALSE)
    Message
      1 units were aggregated: I12.

