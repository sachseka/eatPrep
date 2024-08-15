subsetInfoMin <- data.frame(ID=c("person100", "person101", "person102", "person103", "person101",
                                 "person100", "person101", "person102", "person103", "person101",
                                 "person101"),
                            datCols=c("I01R", "I02R", "I01R", "I01R", "I02R", "I03R",
                                      "I04R", NA, "I02R", "I03R", "I04R"))
data(inputList)
data(inputDat)

prepDat <- automateDataPreparation (inputList = inputList, datList = inputDat,
                                    readSpss = FALSE, checkData = FALSE, mergeData = TRUE, recodeData = TRUE,
                                    aggregateData = FALSE, scoreData = FALSE, writeSpss = FALSE, verbose = TRUE)


visualSubsetRecode(dat=prepDat, subsetInfo=subsetInfoMin, ID="ID", toRecodeVal="mci")

subsetInfoMax <- data.frame(ID=c("person100", "person101", "person102", "person103", "person101",
                                 "person100", "person101", "person102", "person103", "person101",
                                 "person101"),
                            IDgroup=c(1,1,1,1,1,2,2,2,2,2,2),
                            datCols=c("I01R", "I02R", "I01R", "I01R", "I02R", "I03R",
                                      "I04R", NA, "I02R", "I03R", "I04R"))
