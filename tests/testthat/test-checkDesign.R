# dat = prepDat;
# booklets = inputList$booklets;
# blocks = inputList$blocks;
# rotation = inputList$rotation;
# sysMis = "mbd";
# id = "ID";
# subunits = inputList$subunits;
# verbose = TRUE

data(inputDat)
data(inputList)

prepDat <-
  automateDataPreparation(
    inputList = inputList,
    datList = inputDat,
    readSpss = FALSE,
    checkData = FALSE,
    mergeData = TRUE,
    recodeData = TRUE,
    aggregateData = FALSE,
    scoreData = FALSE,
    writeSpss = FALSE,
    verbose = FALSE
  )

# Function with defaults to expose arguments for manipulation
checkDesignTest <- function(
    dat = prepDat,
    booklets = inputList$booklets,
    blocks = inputList$blocks,
    rotation = inputList$rotation,
    sysMis = "mbd",
    id = "ID",
    subunits = inputList$subunits,
    verbose = TRUE
) {
  checkDesign(
    dat = dat,
    booklets = booklets,
    blocks = blocks,
    rotation = rotation,
    sysMis = sysMis,
    id = id,
    subunits = subunits,
    verbose = verbose
  )
}

test_that_cli("returns nothing with no problems or only success messages on verbose mode", {
  expect_snapshot(checkDesignTest(verbose = FALSE))
  expect_snapshot(checkDesignTest(verbose = TRUE))
})


test_that_cli("identifies ID variables that cannot be found in the dataset", {
  expect_snapshot(
    error = TRUE,
    checkDesignTest(id = "FalseID")
  )
})

test_that_cli("returns an error if missing variable names in blocks", {
  expect_error(
    checkDesignTest(blocks = within(inputList$blocks, subunit <- NULL))
  )
})

test_that_cli("returns an error if missing variable names in booklets", {
  # Missing booklet column
  expect_error(
    checkDesignTest(booklets = within(inputList$booklets, booklet <- NULL))
  )

  # Missing "block[0-9*]" pattern
  test_booklets <- inputList$booklets
  names(test_booklets) <- c("booklet", "block1", "block2", "part3")
  expect_error(
    checkDesignTest(booklets = test_booklets)
  )

  # Should also throw an error?
  # test_booklets <- inputList$booklets
  # names(test_booklets) <- c("booklet", "block1", "block2", "block__3")
  # expect_error(
  #   checkDesignTest(booklets = test_booklets)
  # )
})

test_that_cli("returns an error if missing variable names in rotation", {
  # Missing booklet column
  expect_error(
    checkDesignTest(rotation = within(inputList$rotation, booklet <- NULL))
  )
})

test_that_cli("returns an error if missing variable names in rotation", {
  # Missing booklet column
  expect_error(
    checkDesignTest(rotation = within(inputList$rotation, booklet <- NULL))
  )
})

test_that_cli("throws danger messages when block names in blocks do not equal those in booklets", {
  # Manipulation: add block in blocks
  test_block_block <- rbind.data.frame(
    inputList$blocks,
    data.frame(
      subunit = "I99",
      block = "bl9",
      subunitBlockPosition = 1
    )
  )
  expect_snapshot(
    checkDesignTest(blocks = test_block_block)
  )

  # Manipulation: block names in blocks
  test_block_block <- within(inputList$blocks, {
    block <- ifelse(block == "bl1", "bl9", block)
  })
  expect_snapshot(
    checkDesignTest(blocks = test_block_block)
  )

  # Manipulation: block names in booklets
  test_booklet_block <- rbind.data.frame(
    inputList$booklets,
    data.frame(
      booklet = "booklet4",
      block1 = "bl2",
      block2 = "bl4",
      block3 = "bl1"
    )
  )
  expect_snapshot(
    checkDesignTest(booklets = test_booklet_block)
  )

  # Manipulation: block names in booklets
  test_booklet_block <- within(inputList$booklets, {
    block1 <- ifelse(block1 == "bl1", "bl8", block1)
  })
  expect_snapshot(
    checkDesignTest(booklets = test_booklet_block)
  )
})

test_that_cli("throws danger messages when booklet names in booklets do not equal those in rotation", {
  # Manipulation: block names in blocks
  test_booklet_booklet <- within(inputList$booklets, {
    booklet <- ifelse(booklet == "booklet1", "booklet9", booklet)
  })
  expect_snapshot(
    checkDesignTest(booklets = test_booklet_booklet)
  )

  # Manipulation: block names in booklets
  test_rotation_booklet <- within(inputList$rotation, {
    booklet <- ifelse(booklet == "booklet1", "booklet8", booklet)
  })
  expect_snapshot(
    checkDesignTest(rotation = test_rotation_booklet)
  )
})

test_that_cli("throws warning when more variables in dataset available than in blocks$subunit", {
  # Manipulation: delete hisei (default in dataset)
  expect_snapshot(
    checkDesignTest(dat = within(prepDat, hisei <- NULL))
  )

  # Manipulation: add two other variables (hisei is available per default)
  expect_snapshot(
    checkDesignTest(dat = within(prepDat, {
      hisei <- NULL
      testB <- 2
      testA <- 1
    }))
  )
})


test_that_cli("throws warning when more variables in blocks$subunit than in dataset", {
  # Manipulation: delete hisei (default in dataset)
  expect_snapshot(
    checkDesignTest(dat = within(prepDat, hisei <- NULL))
  )

  # Manipulation: add two other variables (hisei is available per default)
  expect_snapshot(
    checkDesignTest(dat = prepDat[,-c(2,7)])
  )
})


test_that_cli("identifies incorrect sysMis codes and allows for user-defined sysMis", {
  # Change vc to sysMis for item I01R
  expect_snapshot(
    checkDesignTest(dat = within(prepDat, I01R <- ifelse(I01R == "mbi", "mbd", I01R)), sysMis = "mbd")
  )

  # Change vc to user-defined sysMis for I01R
  userDefinedSysMis <- as.data.frame(lapply(prepDat, FUN = function(x) ifelse(x == "mbd", NA, x)))
  # Change vc to sysMis for item I01R
  expect_snapshot(
    checkDesignTest(dat = within(userDefinedSysMis, I01R <- ifelse(I01R == "mbi", NA, I01R)),
                    sysMis = "NA")
  )
})

test_that_cli("identifies incorrect vc codes", {
  # Change sysMis to vc for item I22R
  expect_snapshot(
    checkDesignTest(dat = within(prepDat, I22R <- ifelse(I22R == "mbd", "mbi", I22R)), sysMis = "mbd")
  )

  # Change vc to user-defined sysMis for I01R
  userDefinedSysMis <- as.data.frame(lapply(prepDat, FUN = function(x) ifelse(x == "mbd", NA, x)))
  # Change sysMis to vc for item I22R
  expect_snapshot(
    checkDesignTest(dat = within(userDefinedSysMis, I22R <- ifelse(is.na(I22R), "mbi", I22R)),
                    sysMis = "NA")
  )
})
