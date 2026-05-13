test_that("makeCodebookInput converts codebook rows into input sheets", {
  codebook <- data.frame(
    Unit = c("U1", "U1", "U2", ""),
    Variable = c("I1", "I1", "I2", ""),
    Value = c("1", "8", "9", ""),
    X.Score. = c("1", "", "", ""),
    Label.Short = c("correct", "invalid", "intention", ""),
    Label.Long = c("valid response", "missing - invalid response", "missing - by intention", ""),
    anf. = c("", "", "", ""),
    Variablen.Label = c("Item 1", "Item 1", "Item 2", ""),
    Position = c("1", "1", "2", ""),
    stringsAsFactors = FALSE
  )

  input <- makeCodebookInput(codebook)

  expect_named(input, c("values", "subunits", "units"))
  expect_equal(input$values$valueType, c("vc", "mir", "mbi", "vc"))
  expect_equal(input$values$valueRecode[2:3], c("mir", "mbi"))
  expect_equal(input$subunits$subunitRecoded, c("I1R", "I1R", "I2R"))
  expect_equal(input$units$unit, c("U1", "U2"))
})

test_that("codebook helper creates score rules", {
  expect_equal(.makeSrule("2:5; 1:3"), "'5':hi='2';'3':'5'='1';lo:'3'='0'")
  expect_equal(.makeSrule(""), "")
})
