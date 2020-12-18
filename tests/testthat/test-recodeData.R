test_that("recoded data contains only 0, 1, missings", {
# könnte man im Prinzip auch mit komplettem Datensatz machen

#  tempitems <- c("I06", "I07")
#  tempdat <- inputDat[[1]][ , c("ID", "hisei", tempitems)]
#  tempvalues <- inputList$values[inputList$values$subunit %in% tempitems, ]
#  tempsubunits <- inputList$subunits[inputList$subunits$subunit %in% tempitems, ]
#  tempdatR <- recodeData(tempdat, tempvalues, tempsubunits)
#  tempsubunitsR <- inputList$subunits$subunitRecoded[inputList$subunits$subunit %in% tempitems ]

# gehört eigentlich nicht hierher
#  expect_equal(as.character(tempdat$hisei), tempdatR$hisei)

  tempdatR <- recodeData(inputDat[[1]], inputList$values, inputList$subunits)

  expect_setequal(unique(unlist(tempdatR[ , -c(1,2)])), c("0", "1","mbi", "mir"))
})

test_that("recoded data preserves all rows and columns", {

  tempdatR <- recodeData(inputDat[[1]], inputList$values, inputList$subunits)

  expect_equal(nrow(inputDat[[1]]), nrow(tempdatR))
  expect_equal(ncol(inputDat[[1]]), ncol(tempdatR))
})
