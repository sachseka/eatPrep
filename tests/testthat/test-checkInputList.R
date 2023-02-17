data(inputList)

# Prepare inputList
unitsDefault <- data.frame(
  unit = c("I01", "I02", "I03", "I04", "ID"),
  unitType = c("TI", "TI", "TI", "TI", "ID"),
  unitAggregateRule = c("", "", "SUM", "", "")
)

subunitsDefault = data.frame(
  unit = c("I01", "I02", "I03", "I03", "I03", "I04"),
  subunit = c("I01", "I02", "I03a", "I03b", "I03c", "I04"),
  subunitRecoded = c("I01R", "I02R", "I03aR", "I03bR", "I03cR", "I04R"))

mistypes <- c("mnr", "mbd", "mir", "mbi")
valuesDefault <- data.frame(
  subunit = c(rep("I01", 3 + 4),
              rep("I02", 4 + 4),
              rep("I03a", 2 + 4),
              rep("I03b", 2 + 4),
              rep("I03c", 2 + 4),
              rep("I04", 4 + 4)),
  value = c(c(1:3, 6:9), c(1:4, 6:9), rep(c(0:1, 6:9), 3), c(1:4, 6:9)),
  # first option always correct
  valueRecode = c(c(1, 0, 0, mistypes),
                  c(1, 0, 0, 0, mistypes),
                  rep(c(1, 0, mistypes), 3),
                  c(1, 0, 0, 0, mistypes)),
  valueType = c(c(rep("vc", 3), mistypes),
                c(rep("vc", 4), mistypes),
                rep(c(rep("vc", 2), mistypes), 3),
                c(rep("vc", 4), mistypes))
)

unitRecodingsDefault <- data.frame(
  unit = rep("I03", 4 + 4), # why is mnr missing from the examplary dataset??
  value = c(0:3, mistypes),
  valueRecode = c(rep(0, 3), 1, mistypes),
  valueType = c(rep("vc", 4), mistypes)
)

savFilesDefault <- data.frame(
  filename = c("booklet1.sav", "booklet2.sav", "booklet3.sav"),
  case.id = rep("ID", 3),
  fullname = rep("", 3)
)

newIDDefault <- data.frame(
  key = "master-id",
  value = "ID"
)

aggrMissDefault <- data.frame(
  c..vc....mvi....mnr....mci....mbd....mir....mbi.. = c("vc", "mvi", "mnr", "mci", "mbd", "mir", "mbi"),
  vc = c("vc", "mvi", "vc", "mci", "err", "vc", "vc"),
  mbd = c(rep("err", 4), "mbd", rep("err", 2))
)

bookletsDefault <- data.frame(
  booklet = c("booklet1", "booklet2", "booklet3"),
  block1 = c("bl1", "bl2", "bl3"),
  block2 = c("bl2", "bl3", "bl4"),
  block3 = c("bl3", "bl4", "bl1")
)

blocksDefault <- data.frame(
  subunit = c("I01", "I02", "I03a", "I03b", "I03c", "I04"),
  # every item = block
  block = c("bl1", "bl2", rep("bl3", 3), "bl4")
)

checkInputListTest <- function(
    units = unitsDefault,
    subunits = subunitsDefault,
    values = valuesDefault,
    unitRecodings = unitRecodingsDefault,
    savFiles = savFilesDefault,
    newID = newIDDefault,
    aggrMiss = aggrMissDefault,
    blocks = blocksDefault,
    booklets = bookletsDefault

) {
  list(
    units = units,
    subunits = subunits,
    values = values,
    unitRecodings = unitRecodings,
    savFiles = savFiles,
    newID = newID,
    aggrMiss = aggrMiss,
    blocks = blocks,
    booklets = booklets
  )
}

# checkInputList(checkInputListTest())
# checkInputListTest()

test_that_cli("returns default messages and TRUE when everything is okay", {
  prepList <- checkInputListTest()

  expect_equal(checkInputList(prepList), TRUE)
  expect_snapshot(checkInputList(prepList))
})

test_that_cli("identifies and flags missing sheets with consequences for checks", {
  prepList <- checkInputListTest()

  test_set <- function(column) {
    prepList[[column]] <- NULL
    expect_equal(checkInputList(prepList), FALSE) # ?? should return FALSE ?? (at all instances)
    expect_snapshot(checkInputList(prepList))
  }

  for (i in names(prepList)) {
    test_set(i)
  }
})

test_that_cli("identifies and flags missing columns with consequences for checks", {
  prepList <- checkInputListTest()

  # No consequence
  prepList$units$unitAggregateRule <- NULL
  # ?? return FALSE ??
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # No value recoding
  prepList$values$valueRecode <- NULL
  # ?? should return FALSE ??
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # No value type
  prepList$values$valueType <- NULL
  # ?? should return FALSE ??
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # No further consequence (would omit value type)
  prepList$values$value <- NULL
  # ?? should return FALSE ??
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # Refresh
  prepList <- checkInputListTest()

  # No unit equivalence test
  prepList$units$unit <- NULL
  # ?? should return FALSE ??
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # No subunit equivalence test
  prepList$subunits$subunit <- NULL
  # ?? should return FALSE ??
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})

test_that_cli("checks for missing correct and false codes per unit", {
  prepList <- checkInputListTest()

  # omit first correct code (only false vcs for I01)
  prepList$values <- within(prepList$values,{
    valueRecode <- ifelse(subunit == "I01" & valueRecode == 1, 0, valueRecode)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # omit false codes (only true vcs for I01)
  prepList$values <- within(prepList$values,{
    valueRecode <- ifelse(subunit == "I01" & valueRecode == 0, 1, valueRecode)
  })
  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})

test_that("checks for missing mistype codes per unit", {
  prepList <- checkInputListTest()
  # omit first correct code (only false vcs for I01)
  prepList$values <- within(prepList$values,{
    valueRecode <- ifelse(subunit %in% c("I01", "I02") & valueRecode == "mnr", 0, valueRecode)
    valueRecode <- ifelse(subunit == "I02" & valueRecode %in% c("mir", "mbd"), 0, valueRecode)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})

test_that("checks for valueRecodes other than 0, 1, and the mistypes", {
  prepList <- checkInputListTest()
  # omit first correct code (only false vcs for I01)
  prepList$values <- within(prepList$values,{
    valueRecode <- ifelse(subunit == "I01" & valueRecode == "mbd", 2, valueRecode)
  })

  # Changed, as the function could be used for other cases than the intended
  expect_equal(checkInputList(prepList), TRUE)
  expect_snapshot(checkInputList(prepList))
})

test_that("identifies other value types than vc and mistypes", {
  prepList <- checkInputListTest()
  # omit first correct code (only false vcs for I01)
  prepList$values <- within(prepList$values, {
    valueType <- ifelse(subunit == "I01" & valueType == "vc" & value == 1, "test", valueType)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})

test_that("checks for unit inequivalence", {
  prepList <- checkInputListTest()
  # omit first correct code (only false vcs for I01)
  prepList$units <- within(prepList$units, {
    unit <- ifelse(unit == "I01", "I99", unit)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  # Refresh
  prepList <- checkInputListTest()
  # omit first correct code (only false vcs for I01)
  prepList$subunits <- within(prepList$subunits, {
    unit <- ifelse(unit == "I01", "I77", unit)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})

test_that("checks for subunit inequivalence", {
  prepList <- checkInputListTest()
  prepList$subunits <- rbind.data.frame(
    prepList$subunits,
    data.frame(unit = "I03", subunit = "I03d", subunitRecoded = "I03dR")
  )

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  prepList <- checkInputListTest()
  prepList$subunits <- within(prepList$subunits, {
    subunit <- ifelse(subunit == "I03a", "I03z", subunit)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  prepList <- checkInputListTest()
  prepList$values <- rbind.data.frame(
    prepList$values,
    data.frame(
      subunit = rep("I03d", 2 + 4),
      value = rep(c(0:1, 6:9)),
      valueRecode = rep(c(1, 0, mistypes), 3),
      valueType = rep(c(rep("vc", 2), mistypes), 3)
    )
  )

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))

  prepList <- checkInputListTest()
  prepList$values <- within(prepList$values, {
    subunit <- ifelse(subunit == "I03a", "I03x", subunit)
  })

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})

test_that("identifies problems with unit recodings", {
  prepList <- checkInputListTest()
  prepList$subunits <- rbind.data.frame(
    prepList$subunits,
    data.frame(
      unit = rep("I05", 3),
      subunit = c("I05a", "I05b", "I05c"),
      subunitRecoded = c("I05aR", "I05bR", "I05cR")
    )
  )

  expect_equal(checkInputList(prepList), FALSE)
  expect_snapshot(checkInputList(prepList))
})
