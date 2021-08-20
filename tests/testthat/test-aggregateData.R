test_that("aggregateData aggregates data", {
  datRec <- recodeData(inputDat[[1]][ , -c(1,2)], inputList$values, inputList$subunits)
  datRec <- datRec[1:5, colnames(datRec) %in% c("I12aR", "I12bR", "I12cR")]

  am <- matrix(c(
    "vc" , "mvi", "vc" , "mci", "err", "vc" , "mbi", "err",
    "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
    "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
    "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
    "err", "err", "err", "err", "mbd", "err", "err", "err",
    "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
    "mbi", "err", "mnr", "mci", "err", "mir", "mbi", "err",
    "err", "err", "err", "err", "err", "err", "err", "err" ),
    nrow = 8, ncol = 8, byrow = TRUE)

  dimnames(am) <-
    list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
         c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))

  subunits <- inputList$subunits
  datAgg <- aggregateData(datRec, subunits, inputList$units, am)
  expect_equal(datAgg, data.frame(I12 = c(2, "mbi", 1, 2, 3)))})

test_that("aggregateData recognizes unsupported missing types in data", {
  datRec <- recodeData(inputDat[[1]][ , -c(1,2)], inputList$values, inputList$subunits)
  datRec <- datRec[ , colnames(datRec) %in% c("I12aR", "I12bR", "I12cR")]
  datRec[1, 1] <- "fim"

  am <- matrix(c(
    "vc" , "mvi", "vc" , "mci", "err", "vc" , "mbi", "err",
    "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
    "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
    "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
    "err", "err", "err", "err", "mbd", "err", "err", "err",
    "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
    "mbi", "err", "mnr", "mci", "err", "mir", "mbi", "err",
    "err", "err", "err", "err", "err", "err", "err", "err" ),
    nrow = 8, ncol = 8, byrow = TRUE)

  dimnames(am) <-
    list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
         c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))

  subunits <- inputList$subunits
  expect_error(aggregateData(datRec, subunits, inputList$units, am))
})


test_that("aggregateData recognizes unsupported missing types in aggregatemissings", {
  datRec <- recodeData(inputDat[[1]][ , -c(1,2)], inputList$values, inputList$subunits)
  datRec <- datRec[ , colnames(datRec) %in% c("I12aR", "I12bR", "I12cR")]

  am <- matrix(c(
    "fom" , "mvi", "vc" , "mci", "err", "vc" , "mbi", "err",
    "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
    "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
    "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
    "err", "err", "err", "err", "mbd", "err", "err", "err",
    "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
    "mbi", "err", "mnr", "mci", "err", "mir", "mbi", "err",
    "err", "err", "err", "err", "err", "err", "err", "err" ),
    nrow = 8, ncol = 8, byrow = TRUE)

  dimnames(am) <-
    list(c("fam" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
         c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))

  subunits <- inputList$subunits
  expect_error(aggregateData(datRec, subunits, inputList$units, am))
})
