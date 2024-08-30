checkInputList <- function(inputList, mistypes = c("mnr", "mbd", "mir", "mbi")) {
  checkmate::assert_list(inputList, types = "data.frame")
  checkmate::assert_vector(mistypes)

  cli_setting()

  # Default return
  ret <- TRUE

  # Abbreviation of input
  inL <- inputList

  # Pattern: Columns of sheets necessary for further checks
  sheetColUseList <-
    list(
      units = list(
        unit = "unit equivalence",
        unitType = "unit equivalence",
        unitAggregateRule = NULL
      ),
      subunits = list(
        unit = "unit equivalence",
        subunit = "subunit equivalence",
        subunitRecoded = NULL
      ),
      values = list(
        subunit = "subunit equivalence",
        value = "value recoding",
        valueRecode = "value recoding",
        valueType = "value types"
      ),
      unitRecodings = list(
        unit = "unit recoding",
        value = NULL,
        valueRecode = NULL
      ),
      savFiles = list(
        filename = NULL,
        case.id = NULL,
        fullname = NULL
      ),
      newID = list(
        key = NULL,
        value = NULL
      ),
      aggrMiss = list(
        vc = NULL,
        mbd = NULL
      ),
      booklets = list(
        booklet = NULL,
        block1 = NULL
      ),
      blocks = list(
        subunit = NULL,
        block = NULL
      )
    )

  # Only names of sheets
  sheetNames <- names(sheetColUseList)

  # Names of sheets and columns
  sheetColList <- lapply(sheetColUseList, names)

  # Filter necessary sheets (with further functions)
  necessarySheets  <- lapply(sheetColUseList, function(x) unname(unlist(x)))

  # Identify missing sheets
  missingSheets <- setdiff(sheetNames, names(inL))
  nMissingSheets <- length(missingSheets)

  # Check for missing sheets / sheet names
  if (! setequal(names(inL), sheetNames)) {
    cli_h3("Checking sheets")
    if (nMissingSheets > 0) {
      ret <- FALSE

      cli_alert_danger("Did not find {nMissingSheets} sheet{?s}: {.envvar {missingSheets}}")

      noChecks <- unique(unlist(necessarySheets[missingSheets]))
      if (length(noChecks) > 0) {
        cli_alert("No checks for {noChecks} available.")
      }
    }
  }

  # Check for missing columns / column names in sheets and report
  checkProblem <- function(sheet) {
    if(! is.null(inL[[sheet]]) &
       ! all(sheetColList[[sheet]] %in% colnames(inL[[sheet]]))) {
      ret <<- FALSE

      expectedColumns <- sheetColList[[sheet]]
      foundColumns <- colnames(inL[[sheet]])
      missingColumns <- setdiff(expectedColumns, foundColumns)

      cli_alert_danger("Sheet {.field {sheet}} does not contain all expected columns.", wrap = TRUE)
      cli_alert("Expected: {.envvar {expectedColumns}}")
      cli_alert("Found:    {.envvar {foundColumns}}")
      cli_alert("Missing:  {.envvar {missingColumns}}")

      noChecks <- unique(unlist(sheetColUseList[[sheet]][missingColumns]))
      if (length(noChecks) > 0) {
        cli_alert("No checks for {noChecks} available.")
      }

      problematicColumns[[sheet]] <<- missingColumns
    }
  }

  problematicColumns <- NULL
  for(sheet in sheetNames) checkProblem(sheet)

  # Check 1: sheet `values`?
  if (! is.null(inL$values)) {
    # Check 1.1: column `valueRecode` of sheet `values`?
    if (! is.null(inL$values$valueRecode)) {
      valueRecode <- inL$values$valueRecode

      cli_h3("Check: Value Recoding")

      # Check 1.1.1: column `subunit` (+ `valueRecode`) of sheet `values`?
      if (! is.null(inL$values$subunit)) {
        subUnit <- inL$values$subunit

        # At least one 1 code
        subUnit1 <- subUnit[valueRecode == 1]
        if (! setequal(subUnit, subUnit1)) {
          ret <- FALSE

          cli_alert_danger("Not all items in {.field values} sheet contain
                       at least one correct score in {.field valueRecode}:
                       {.envvar {setdiff(subUnit, subUnit1)}}",
                       wrap = TRUE)
        }

        # At least one 0 code
        subUnit0 <- subUnit[valueRecode == 0]
        if (! setequal(subUnit, subUnit0)) {
          ret <- FALSE

          cli_alert_danger("Not all items in {.field values} sheet contain
                       at least one 'false' score in {.field valueRecode}:
                       {.envvar {setdiff(subUnit, subUnit0)}}",
                       wrap = TRUE)
        }

        # Missing codes
        if (! is.null(mistypes)) {
          problematicItems <- NULL
          for(mm in mistypes) {
            subUnitMM <- subUnit[valueRecode == mm]
            if(! setequal(subUnit, subUnitMM)) {
              ret <- FALSE

              problematicItems[[mm]] <- setdiff(subUnit, subUnitMM)
            }
          }

          problematicMistypes <- names(problematicItems)
          unproblematicMistypes <- setdiff(mistypes, problematicMistypes)

          if (length(unproblematicMistypes) > 0) {
            cli_alert_success("Missing {qty(length(problematicMistypes))}type{?s}
                              {.envvar {unproblematicMistypes}} {?is/are} defined for
                              all items in {.field valueRecode}.", wrap = TRUE)
          }

          for (pm in problematicMistypes) {
            cli_alert_danger("Missing type {.envvar {pm}} is not defined as
                             {.field valueRecode} for items:
                             {.envvar {problematicItems[[pm]]}}.", wrap = TRUE)

          }
        }
      }


      # Check 1.1.2: column `value` (+ `valueRecode`) of sheet `values`?
      if (! is.null(inL$values$value)) {
        value <- sort(unique(inL$values$value))
        valueRecodeU <- sort(unique(valueRecode))

        # List all values
        cli_alert_info("{.field value} contains the following values over
                     all items: {.envvar {value}}",
                     wrap = TRUE)

        if (setequal(c(0, 1, mistypes), valueRecodeU)) {
          # List all value codes
          cli_alert_success("{.field valueRecode} contains only 0, 1, and the mistypes:
                            {.envvar {valueRecodeU}}",
                            wrap = TRUE)
        } else {
          # Other use cases are possible; therefore, decided to not return FALSE here
          # ret <- FALSE
          # maybe consider checking for user-customized valid codes instead.
          # List all deviating value codes
          cli_alert_danger("{.field valueRecode} contains other values than
                           0, 1, and the mistypes.",
                           wrap = TRUE)

          otherValues <- setdiff(valueRecodeU, c(0, 1, mistypes))
          nOtherValues <- length(otherValues)
          if (nOtherValues > 0) {
            cli_alert("It contains {nOtherValues} other value{?s}:
                      {.envvar {otherValues}}",
                      wrap = TRUE)

          }
        }
      }
    }

    # Check 1.2: column `valueType` of sheet `values`?
    if (! is.null(inL$values[["valueType"]])) {
      cli_h3("Check: Value Types")

      # Evaluate value types (vc or mistypes)
      valueType <- unique(inL$values[["valueType"]])
      if (! setequal(valueType, c("vc", mistypes))) {
        ret <- FALSE

        otherValueType <- setdiff(valueType, c("vc", mistypes))
        nOtherValueType <- length(otherValueType)

        if(nOtherValueType > 0) {
          cli_alert_danger("Unexpected {qty(nOtherValueType)}value{?s}
                             other than `vc` and the mistypes in {.field valueType}:
                             {.envvar {otherValueType}}",
                           wrap = TRUE)
        }
      } else {
        cli_alert_success("No other values than `vc` and the mistypes in
                            {.field valueType}.",
                          wrap = TRUE)
      }
    }
  }

  # Check 2: sheet `subunits`?
  if (! is.null(inL$subunits)) {
    # Check 2.1: column `unit` in sheets `units` and `subunits` (+ `unitType` in sheet `unit`)?
    if (all(! is.null(inL$units[["unit"]]), ! is.null(inL$units[["unitType"]]), ! is.null(inL$subunits[["unit"]]))) {

      unitUnit <- inL$units$unit[inL$units$unitType == "TI"]
      subunitUnit <- inL$subunits$unit

      # Check for unit equivalence in `units` and `subunits` sheet
      cli_h3("Check: Unit Equivalence")
      if (! setequal(unitUnit, subunitUnit)) {
        ret <- FALSE

        unitUnit_subunitUnit <- setdiff(unitUnit, subunitUnit)
        subunitUnit_unitUnit <- setdiff(subunitUnit, unitUnit)

        if (length(unitUnit_subunitUnit) > 0) {
          cli_alert_danger("More units in {.field units} sheet than in
                           {.field subunits} sheet: {.envvar {unitUnit_subunitUnit}}",
                           wrap = TRUE)
        }
        if(length(subunitUnit_unitUnit) > 0) {
          cli_alert_danger("More units in {.field subunits} sheet than in
                           {.field units} sheet: {.envvar {subunitUnit_unitUnit}}",
                           wrap = TRUE)
        }
      } else {
        cli_alert_success("All {length(unique(subunitUnit))} unit{?s} in
                          {.field units} sheet are also defined in {.field subunits}.",
                          wrap = TRUE)
      }
    }

    # Check 2.1: columns `unit` and `unitType` in sheet `units` and column `unit` in sheet `subunits`?
    if (all(! is.null(inL$values[["subunit"]]), ! is.null(inL$subunits[["subunit"]]))) {

      valueSubunit <- inL$values$subunit
      subunitSubunit <- inL$subunits$subunit

      # Check for subunit equivalence in `subunits` and `values` sheet
      cli_h3("Check: Subunit Equivalence")
      if (! setequal(valueSubunit, subunitSubunit)) {
        ret <- FALSE

        valueSubunit_subunitSubunit <- setdiff(valueSubunit, subunitSubunit)
        subunitSubunit_valueSubunit <- setdiff(subunitSubunit, valueSubunit)

        if(length(valueSubunit_subunitSubunit) > 0) {
          cli_alert_danger("More subunits in {.field values} sheet than in
                           {.field subunits} sheet: {.envvar {valueSubunit_subunitSubunit}}",
                           wrap = TRUE)
        }
        if(length(subunitSubunit_valueSubunit) > 0) {
          cli_alert_danger("More subunits in {.field subunits} sheet than in
                           {.field values} sheet: {.envvar {subunitSubunit_valueSubunit}}",
                           wrap = TRUE)
        }
      } else {
        cli_alert_success("All {length(unique(subunitSubunit))} subunit{?s} in
                          {.field subunits} sheet are also defined in {.field values}.",
                          wrap = TRUE)
      }

      # Check for units with multiple subunits
      cli_h3("Check: Unit Recoding")

      countSubUnit <- table(inL$subunits[["unit"]])
      cli_alert_info("Units with only one subunit: {sum(countSubUnit == 1)}",
                     wrap = TRUE)

      countSubUnitGt1 <- names(countSubUnit)[which(countSubUnit > 1)]
      nCountSubUnitGt1 <- length(countSubUnitGt1)
      if (nCountSubUnitGt1 > 0) {
        cli_alert_info("Units with more than one subunit: {nCountSubUnitGt1} ({.envvar {countSubUnitGt1}})",
                       wrap = TRUE)

        unitRecodeUnit <- unique(inL$unitRecodings$unit)
        if (all(countSubUnitGt1 %in% unitRecodeUnit)) {
          cli_alert_success("All units with more than one subunit
                            are defined in {.field unitRecodings} sheet.",
                            wrap = TRUE)
        } else {
          cli_alert_danger("Not all units with more than one subunit
                           are defined in {.field unitRecodings} sheet:
                           {.envvar {setdiff(countSubUnitGt1, unitRecodeUnit)}}",
                           wrap = TRUE)
          ret <- FALSE
        }
      }

    }
  }
  return(ret)
}
