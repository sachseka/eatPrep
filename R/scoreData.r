scoreData <- function(
    dat,
    unitrecodings,
    # TODO: This column is not necessary for any operation here?
    # It would also be irrelevant to recodeData
    # units,
    subunits,
    verbose = FALSE,
    ... # for the deprecated units argument
) {
  lapply(c(unitrecodings, subunits), checkmate::assert_data_frame)
  checkmate::assert_logical(verbose, len = 1)

  cli_setting()

  if (!is.data.frame(dat)) cli_abort("{.field dat} must be a {.envvar data.frame}.")

  # TODO: This should not be necessary
  # scoreinfo <- dplyr::inner_join(units, unitrecodings, by = "unit")
  dontcheck <- c("mbd","mvi", "mnr", "mci", "mbd", "mir", "mbi")

  # Check for columns that actually have to be scored
  unitsInDat <- unique(names(dat))
  unitsWithSubunits <- unique(subunits$unit[duplicated(subunits$unit)])
  unitsToScore <- intersect(unitsInDat, unitsWithSubunits)

  # Check for units that can be recoded
  unitRecodes <- unique(unitrecodings$unit)

  notScorable <- setdiff(unitsToScore, unitRecodes)
  nNotScorable <- length(notScorable)

  scorable <- intersect(unitsToScore, unitRecodes)
  nScorable <- length(scorable)

  if(nNotScorable > 0) {
    cli_alert_warning("Found no scoring information for {nNotScorable} variable{?s}:
                      {.envvar {notScorable}}.
                      {?This/These} variable{?s} will not be scored.",
                      wrap = TRUE)
  }

  # Make scored data.frame
  prepScore <-
    mapply(.recodeData.recode,
           dat,
           colnames(dat),
           MoreArgs = list(
             unitrecodings, # instead of scoreinfo, as this does not provide any further information
             dontcheck = dontcheck,
             mode = "score",
             verbose = verbose),
           USE.NAMES = TRUE)

  datS <- data.frame(prepScore,
                     stringsAsFactors = FALSE)

  if(verbose) cli_alert_success("{nScorable} unit{?s} {?was/were} scored: {.envvar {scorable}}.")
  #  colnames(datS) <- sapply(colnames(datS), .recodeData.renameIDs, scoreinfo, USE.NAMES = FALSE)
  return(datS)
}
