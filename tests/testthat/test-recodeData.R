test_that("recoded data contains only 0, 1, missings", {
  tempitems <- c("I06", "I07")
  tempdat <- inputDat[[1]][ , c("ID", "hisei", tempitems)]
  tempvalues <- inputList$values[inputList$values$subunit %in% tempitems, ]
  tempsubunits <- inputList$subunits[inputList$subunits$subunit %in% tempitems, ]
  tempdatR <- recodeData(tempdat, tempvalues, tempsubunits)
  tempsubunitsR <- inputList$subunits$subunitRecoded[inputList$subunits$subunit %in% tempitems ]

# gehört eigentlich nicht hierher
#  expect_equal(nrow(tempdat), nrow(tempdatR))
#  expect_equal(ncol(tempdat), ncol(tempdatR))
#  expect_equal(as.character(tempdat$hisei), tempdatR$hisei)

  expect_setequal(unique(unlist(tempdatR[ , tempsubunitsR])), c("0", "1","mbi"))
})
