test_that("readDaemonXlsx reads bundled input workbook", {
  path <- system.file("extdata", "inputList.xlsx", package = "eatPrep")
  expect_true(nzchar(path))

  expect_message(input <- readDaemonXlsx(path), "Reading sheet 'units'")
  expect_named(
    input,
    c("units", "subunits", "values", "unitRecodings", "savFiles", "newID", "aggrMiss", "booklets", "blocks")
  )
  expect_true(all(c("unit", "unitType", "unitAggregateRule") %in% names(input$units)))
  expect_true(all(c("subunit", "value", "valueRecode", "valueType") %in% names(input$values)))
  expect_true(all(c("nam", "vc") %in% names(input$aggrMiss)))
})

test_that("readMerkmalXlsx reads bundled item features workbook", {
  path <- system.file("extdata", "itemmerkmale.xlsx", package = "eatPrep")
  expect_true(nzchar(path))

  expect_message(features <- readMerkmalXlsx(path), "AlleMerkmale")
  expect_named(features, c("Aufgabenmerkmale", "Itemmerkmale", "AlleMerkmale"))
  expect_true(all(c("AufgID", "AufgTitel") %in% names(features$Aufgabenmerkmale)))
  expect_true("ItemID" %in% names(features$Itemmerkmale))
  expect_gt(nrow(features$AlleMerkmale), 0)
})
