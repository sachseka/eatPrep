checkDesign <- function(dat, booklets, blocks, rotation, sysMis = "NA", id = "ID", subunits = NULL, verbose = TRUE) {
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
  # ??? Should the tests be inverted (a is element of b instead of b is element of a)
  #   - minimum pattern should be defined on the left (min is element of / %in% max)?
  # ??? Error messages?
  stopifnot(all(c("subunit", "block", "subunitBlockPosition") %in% names(blocks)))
  stopifnot("booklet" %in% names(booklets))
  stopifnot(all(sapply(names(booklets)[-grep("booklet", names(booklets))], function(jj) grepl("^block",jj))))
  stopifnot(all(c(id, "booklet") %in% names(rotation)))

  # Identify block name equality in `booklets` and `block`
  bl1 <- unique(unlist(booklets[, -match("booklet", names(booklets))]))
  bl2 <- unique(blocks$block)

  if (!setequal(bl1,bl2)) {
    # Generic danger message
    cli_h3("{.strong Check:} Block names")
    cli_alert_danger("Block names set in {.field blocks}
                     does not equal block names set in
                     {.field booklets}. Please check.",
                     wrap = TRUE)
    if (verbose) {
      # Deviations
      bl1Vs2 <- setdiff(bl1, bl2)
      bl2Vs1 <- setdiff(bl2, bl1)

      # Quantities of deviations
      nBl1Vs2 <- length(bl1Vs2)
      nBl2Vs1 <- length(bl2Vs1)

      # Messages for deviations
      if(nBl1Vs2 > 0) {
        cli_alert("The following {nBl1Vs2} block{?s} {?is/are} in
                  {.field booklets} but not in {.field blocks}:
                  {.envvar {bl1Vs2}}",
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
  toOmit <- setdiff(names(dat), c(id, blocks$subunit))
  nToOmit <- length(toOmit)
  if (nToOmit > 0) {
    if(verbose) {
      cli_h3("{.strong Check:} Variables in the dataset")
      cli_alert_info("The following {nToOmit} variable{?s}
                     {?is/are} not in info ({.envvar subunit}
                     in {.field blocks}) but in dataset.
                     {?It/They} will be ignored during check:
                     {.envvar {toOmit}}",
                     wrap = TRUE)
    }
    dat <- dat[, -match(toOmit, names(dat))]
  }

  # Identify items in a given booklet
  .subunitsInBooklet <- function(TH) {
    unname(unlist(sapply(
      booklets[which(booklets$booklet == TH), grep("block", names(booklets))],
      function(BL) {
        subset(blocks, blocks$block == BL)$subunit
      }
    )))
  }

  if (sysMis == "NA") {
    # sysMis instead of vc (M)
    .patternCheckM <- function(subunit, TH, cases) {
      cc <- cases[which(is.na(dat[match(cases, dat[,id]),match(subunit, names(dat))]))]
      if(length(cc) > 0) {return(cc)} else {return(FALSE)}
    }
    # vc instead of sysMis (P)
    .patternCheckP <- function(subunitN, TH, cases) {
      dd <- cases[which(!is.na(dat[match(cases, dat[,id]),match(subunitN, names(dat))]))]
      if(length(dd) > 0) {return(dd)} else {return(FALSE)}
    }
  } else {
    # sysMis instead of vc (M)
    .patternCheckM <- function(subunit, TH, cases) {
      cc <- cases[which(dat[match(cases, dat[,id]),match(subunit, names(dat))] == sysMis)]
      if(length(cc) > 0) {return(cc)} else {return(FALSE)}
    }
    # vc instead of sysMis (P)
    .patternCheckP <- function(subunitN, TH, cases) {
      dd <- cases[which(dat[match(cases, dat[,id]),match(subunitN, names(dat))] != sysMis)]
      if(length(dd) > 0) {return(dd)} else {return(FALSE)}
    }
  }

  # Check sysMis pattern for every booklet
  .bookletPatternCheck <- function(TH) {
    subInBooklet <- .subunitsInBooklet(TH)
    subNotInBooklet <- setdiff(names(dat), c(subInBooklet, id))
    stopifnot(id %in% names(rotation))
    cases <- rotation[,id][rotation$booklet == TH]
    resList <- list()
    resList[["M"]] <- sapply(subInBooklet, .patternCheckM, TH=TH, cases=cases)
    resList[["P"]] <- sapply(subNotInBooklet, .patternCheckP, TH=TH, cases=cases)
    return(resList)
  }

  resL <- lapply(booklets$booklet, .bookletPatternCheck)
  names(resL) <- booklets$booklet

  if (all(unlist(resL) == FALSE)) {
    if (verbose) cli_alert_success("No deviations from design detected!")
  } else {
    if (verbose) cli_alert_info("Deviations from design detected!")

    ## CUT
    # sysMis instead of vc
    if (!all(unlist(resM <- lapply(resL, function (iz) {iz[["M"]]})) == FALSE)) {
      for(ll in names(resL)) {
        if (any(tt <- unlist(lapply(resM[[ll]], function(gg) gg[1])) != FALSE)) {
          nTt <- sum(tt)
          cli_alert_info("Found for {sum(tt)} variable{?s}
                         sysMis instead of valid codes for booklet {.envvar {ll}}: ")
          for(pp in names(resM[[ll]])) {
            if (resM[[ll]][[pp]][1] != FALSE) {
              nPp <- length(resM[[ll]][[pp]])
              if(verbose) cli_alert_info("{pp} ({nPp} case{?s}: {resM[[ll]][[pp]]})")
            }
          }
        }
      }
    }

    # vc instead of sysMis
    if (!all(unlist(resP <- lapply(resL, function(iz) { iz[["P"]] })) == FALSE)) {
      for(ll in names(resL)) {
        if (any(tt <- unlist(lapply(resP[[ll]], function(gg) gg[1])) != FALSE)) {
          nTt <- sum(tt)
          if(verbose) cli_alert_info("Found for {sum(tt)} variable{?s}
                                     valid codes instead of sysMis for booklet {.envvar {ll}}: ")
          for(pp in names(resP[[ll]])) {
            if (resP[[ll]][[pp]][1] != FALSE) {
              nPp <- length(resP[[ll]][[pp]])
              if(verbose) cli_alert_info("{pp} ({nPp} case{?s}: {resP[[ll]][[pp]]})")
            }
          }
        }
      }
    }
    ## CUT
  }
}

