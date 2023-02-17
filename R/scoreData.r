scoreData <- function(
    dat,
    unitrecodings,
    # TODO: This column is not necessary for any operation here?
    # It would also be irrelevant to recodeData
    units,
    subunits,
    verbose = FALSE
) {
  cli_setting()

  if (!is.data.frame(dat)) cli_abort("{.field dat} must be a {.envvar data.frame}.")

  scoreinfo <- dplyr::inner_join(units, unitrecodings, by = "unit")
  dontcheck <- c("mbd","mvi", "mnr", "mci", "mbd", "mir", "mbi")

  unitsToScore <- unique(subunits$unit[duplicated(subunits$unit)])
  nUnitsToScore <- length(unitsToScore)

  notScored <- setdiff(unitsToScore, unique(unitrecodings$unit))
  nNotScored <- length(notScored)

  finalScored <- setdiff(unitsToScore, notScored)
  nFinalScored <- length(finalScored)

  if(nNotScored > 0) {
    cli_alert_warning("Found no scoring information for {nNotScored} variable{?s}:
                      {.envvar {notScored}}.
                      {?This/These} variable{?s} will not be scored.",
                      wrap = TRUE)
  }

  # make scored data.frame
  prepScore <-
    mapply(.recodeData.recode,
           dat,
           colnames(dat),
           MoreArgs = list(
             scoreinfo,
             dontcheck = dontcheck,
             mode = "score",
             verbose = verbose),
           USE.NAMES = TRUE)

  datS <- data.frame(prepScore,
                     stringsAsFactors = FALSE)

  if(verbose) cli_alert_success("{nFinalScored} unit{?s} {?was/were} scored: {.envvar {finalScored}}.")
  #  colnames(datS) <- sapply(colnames(datS), .recodeData.renameIDs, scoreinfo, USE.NAMES = FALSE)
  return(datS)
}
