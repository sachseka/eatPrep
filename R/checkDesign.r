checkDesign <- function(dat, booklets, blocks, rotation, sysMis = "NA", id = "ID", subunits = NULL, verbose = TRUE) {
  checkmate::assert_data_frame(dat)
  lapply(c(booklet, blocks, rotation), checkmate::assert_data_frame)
  lapply(c(sysMis, id), checkmate::assert_character, len = 1)
  checkmate::assert_data_frame(subunits, null.ok = TRUE)
  checkmate::assert_logical(verbose, len = 1)

  cli_setting()

  # ID check
  if (is.na(match(id, colnames(dat)))) {
    cli_abort("ID variable {.envvar {id}} not found in dataset.",
              wrap = TRUE)
  }

  # Set all column types to character
  blocks <- set.col.type(blocks, col.type = list("character" = names(blocks)))
  booklets <- set.col.type(booklets, col.type = list("character" = names(booklets)))
  rotation <- set.col.type(rotation, col.type = list("character" = names(rotation)))

  # Check for sub-elements
  stopifnot(all(c("subunit", "block", "subunitBlockPosition") %in% names(blocks)))
  stopifnot("booklet" %in% names(booklets))
  stopifnot(all(sapply(names(booklets)[-grep("booklet", names(booklets))], function(jj) grepl("^block",jj))))
  stopifnot(all(c(id, "booklet") %in% names(rotation)))

  # Identify block name equality in `booklets` and `block`
  bl1 <- unique(unlist(booklets[, -match("booklet", names(booklets))]))
  bl2 <- unique(blocks$block)

  # Deviations (needed later, therefore external to if clause)
  bl1Vs2 <- setdiff(bl1, bl2)
  bl2Vs1 <- setdiff(bl2, bl1)

  # Quantities of deviations
  nBl1Vs2 <- length(bl1Vs2)
  nBl2Vs1 <- length(bl2Vs1)

  if (!setequal(bl1,bl2)) {
    # Generic danger message
    cli_h3("{.strong Check:} Block names")
    cli_alert_danger("Block names set in {.field blocks}
                     does not equal block names set in
                     {.field booklets}. Please check.",
                     wrap = TRUE)
    if (verbose) {
      # Messages for deviations
      if(nBl1Vs2 > 0) {
        cli_alert("The following {nBl1Vs2} block{?s} {?is/are} in
                  {.field booklets} but not in {.field blocks}:
                  {.envvar {bl1Vs2}}",
                  wrap = TRUE)
        cli_alert("No check for valid and missing codes will be available.",
                  wrap = TRUE)
      }
      if(nBl2Vs1 > 0) {
        cli_alert("The following {nBl2Vs1} block{?s} {?is/are}
                  in {.field blocks} but not in {.field booklets}:
                  {.envvar {bl2Vs1}}",
                  wrap = TRUE)
      }
    }
  }

  # Identify booklet name equality in rotation and booklet
  th1 <- unique(rotation$booklet)
  th2 <- unique(booklets$booklet)

  if (!setequal(th1,th2))  {
    # Generic danger message
    cli_h3("{.strong Check:} Booklet names")
    cli_alert_danger("Booklet names set in {.field rotation}
                     does not equal booklet names set in {.field booklets}.
                     Please check.",
                     wrap = TRUE)

    if(verbose) {
      # Deviations
      th1Vs2 <- setdiff(th1,th2)
      th2Vs1 <- setdiff(th2, th1)

      # Quantities of deviations
      nTh1Vs2 <- length(th1Vs2)
      nTh2Vs1 <- length(th2Vs1)

      # Messages for deviations
      if(nTh1Vs2 > 0) {
        cli_alert("The following {nTh1Vs2} booklet{?s} {?is/are}
                  in {.field rotation} but not in {.field booklets}:
                  {.envvar {th1Vs2}}",
                  wrap = TRUE)
      }

      if(nTh2Vs1 > 0) {
        cli_alert("The following {nTh2Vs1} booklet{?s} {?is/are}
                  in {.field booklets} but not in {.field rotation}:
                  {.envvar {th2Vs1}}",
                  wrap = TRUE)
      }
    }
  }

  # Check for subunit recoding
  if (!is.null(subunits)) {
    if (verbose) {
      cli_h3("{.strong Check:} Subunit recoding")
      cli_alert_info("Use names for recoded subunits.")
    }
    devSub <- blocks$subunit[which(is.na(match(blocks$subunit, subunits$subunit)))]
    nDevSub <- length(devSub)

    if (nDevSub > 0) {
      if(verbose) {
        cli_alert_warning("Found no names to recode {nDevSub} subunit{?s}: {.envvar {devSub}}
                          {?This/Those} subunit{?s} will be ignored in determining 'mnr'.",
                          wrap = TRUE)
      }
      blocks <- blocks[! blocks$subunit %in% devSub, ]
    }

    blocks$subunit[na.omit(match(subunits$subunit, blocks$subunit))] <-
      subunits$subunitRecoded[match(blocks$subunit, subunits$subunit)]
  }

  # Check for variables in `dat` that are not in the info (`blocks$subunit`)
  toOmitDat <- setdiff(names(dat), c(id, blocks$subunit))
  ntoOmitDat <- length(toOmitDat)
  if (ntoOmitDat > 0) {
    if(verbose) {
      cli_h3("{.strong Check:} Variables in the dataset")
      cli_alert_info("The following {ntoOmitDat} variable{?s}
                     {?is/are} not in info ({.envvar subunit}
                     in {.field blocks}) but in dataset.
                     {?It/They} will be ignored during check:
                     {.envvar {toOmitDat}}",
                     wrap = TRUE)
    }
    dat <- dat[,-c(which( names(dat) %in% toOmitDat))]
  }

  # Check for variables in the info (`blocks$subunit`) that are not in `dat`
  toOmitBlocks <- setdiff(c(id, blocks$subunit), names(dat))
  ntoOmitBlocks <- length(toOmitBlocks)
  if (ntoOmitBlocks > 0) {
    if(verbose) {
      cli_h3("{.strong Check:} Variables in Info")
      cli_alert_info("The following {ntoOmitBlocks} variable{?s}
                     {?is/are} not in dataset but in info ({.envvar subunit}
                     in {.field blocks}).
                     {?It/They} will be ignored during check:
                     {.envvar {toOmitBlocks}}",
                     wrap = TRUE)
    }
    blocks <- blocks[-c(which(blocks$subunit %in% toOmitBlocks)),]
  }

  .bookletPatternCheck <- function(TH) {
    # Sanity check
    stopifnot(id %in% names(rotation))

    # Cases worked on the given booklet
    cases <- rotation[,id][rotation$booklet == TH]

    # Subunit names in the given booklet (should only contain valid codes)
    subInBooklet <- unname(unlist(sapply(
      booklets[which(booklets$booklet == TH), grep("block", names(booklets))],
      function(BL) subset(blocks, blocks$block == BL)$subunit
    )))

    # Subunit names not in the given booklet (should only contain system missing codes)
    subOffBooklet <- setdiff(names(dat), c(subInBooklet, id))

    # Data to match, differs based on subunits in vs. off booklet
    subPattern <- function(subunit) { dat[match(cases, dat[,id]), match(subunit, names(dat))] }

    # Pattern check based on system missing definition (NA vs. other)
    if (sysMis == "NA") {
      subInPattern <- is.na(subPattern(subInBooklet))
      subOffPattern <- ! is.na(subPattern(subOffBooklet))
    } else {
      subInPattern <- subPattern(subInBooklet) == sysMis
      subOffPattern <- ! subPattern(subOffBooklet) == sysMis
    }

    # Function to flag cases
    flagCases <- function(subunits) {
      lapply(as.data.frame(subunits), function(subunit) {
        cases[which(subunit)]
      })
    }

    # Function to flag subunits
    flagSubunits <- function(subunits) names(subunits[which(subunits != 0)])

    # List all case and subunit flags as well as the respective counts per scenario
    generateResList <- function(scenario) {
      if (scenario == "sysMisInBooklet") {
        subunit <- subInPattern
      } else if (scenario == "vcOffBooklet") {
        subunit <- subOffPattern
      }

      caseFlag <- flagCases(subunit)
      caseCount <- sapply(caseFlag, length)
      subunitFlag <- flagSubunits(caseCount)
      subunitCount <- length(subunitFlag)

      generatedList <- NULL
      generatedList[[scenario]] <-
        list( # Structure of scenario list
          case =
            list(
              flag = caseFlag,
              count = caseCount
            ),
          subunit =
            list(
              flag = subunitFlag,
              count = subunitCount
            )
        )
    }

    # Call for both scenarios - generates two lists (one for each scenario)
    scenarios <- c("sysMisInBooklet", "vcOffBooklet")
    resList <- lapply(scenarios, generateResList)
    names(resList) <- scenarios

    # Number of total problems
    resList$total <- sum(
      resList$sysMisInBooklet$subunit$count,
      resList$vcOffBooklet$subunit$count
    )

    return(resList)
  }

  # Loop over booklets with pattern check algorithm
  checkedBooklets <- lapply(booklets$booklet, .bookletPatternCheck)
  bookletNames <- booklets$booklet
  names(checkedBooklets) <- bookletNames

  scenarios <- c("sysMisInBooklet", "vcOffBooklet")

  # Check for any problems
  totalCheck <- sum(sapply(checkedBooklets, function(x) x$total))

  cli_h3("{.strong Check:} Valid and missing codes")

  if(nBl1Vs2 > 0) {
    cli_alert_danger("Not available as there {qty(nBl1Vs2)}{?is/are} {nBl1Vs2} block{?s} in booklets that {?is/are} not in blocks!")
  }  else {
    if (totalCheck == 0) {
      if (verbose) cli_alert_success("No deviations from design detected!")
    } else {
      if (verbose) cli_alert_info("Deviations from design detected!")

      # Function to report (scenario-wise), if any problems arrive
      .reportProblems <- function(scenario) {
        # Check for any problems for the scenario
        nScenarioProblems <- sum(sapply(checkedBooklets, function(x) x[[scenario]]$subunit$count))
        if (nScenarioProblems != 0) {
          # Check for booklet-wise problems
          for (bkl in bookletNames) {
            currentBooklet <- checkedBooklets[[bkl]][[scenario]]
            nProblematicSubunits <- currentBooklet$subunit$count
            # Check for subunit-wise problems (per booklet)
            if (nProblematicSubunits > 0) {

              problematicSubunits <- currentBooklet$subunit$flag
              snippet <- ifelse(scenario == "sysMisInBooklet",
                                "sysMis instead of valid codes",
                                "valid codes instead of sysMis")

              cli_alert_danger("Found for {nProblematicSubunits} subunit{?s}
                             {snippet} for booklet {.envvar {bkl}}:
                             {problematicSubunits}",
                             wrap = TRUE)
              if(verbose) {
                # Check for case-wise scenarios (per subunit)
                for (sub in problematicSubunits) {
                  problematicCases <- currentBooklet$case$flag[[sub]]
                  nProblematicCases <- currentBooklet$case$count[[sub]]
                  cli_alert_info("{sub} ({nProblematicCases} case{?s}: {problematicCases})")
                }
              }
            }
          }
        }
      }

      for (s in scenarios) .reportProblems(s)

    }
  }
}
