scoreData <- function (dat, unitrecodings, units, verbose = FALSE) {
  if (class(dat) != "data.frame") stop ("'dat' must be a data.frame.\n")

  scoreinfo <- makeInputRecodeData (values = unitrecodings, subunits = units)

  if(length(setdiff(colnames(dat), names(scoreinfo))) > 0) {
	message(paste("Found no scoring information for variable(s) ",
		paste(setdiff(colnames(dat), names(scoreinfo)), collapse = ", "),
			". \nThis/These variable(s) will not be scored.\n", sep =""))
  }

  # make scored data.frame
  datS <- data.frame(mapply(.scoreData.score, dat,
  colnames(dat), MoreArgs = list(scoreinfo, verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)

  colnames(datS) <- sapply(colnames(datS), .recodeData.renameIDs, scoreinfo, USE.NAMES = FALSE)

  return(datS)
}

#-----------------------------------------------------------------------------------------

.scoreData.score <- function (variable, variableName, scoreinfo, verbose) {
  variableScored <- NULL

  if (!(class(variable) == "character")) {
    variable <- as.character(variable)
  }

  if (is.null(scoreinfo[[variableName]]$values)) {
    variableScored <- variable
  } else {
    dontcheck <- c("mbd","mvi", "mnr", "mci", "mbd", "mir", "mbi")
    variable.unique <- na.omit(unique(variable[which(!variable %in% dontcheck)]))
    scoreinfoCheck <- (variable.unique %in% names(unlist(scoreinfo[[variableName]]$values)))
    if (!all(scoreinfoCheck == TRUE)) {
      message(paste("Incomplete scoring information for variable ",
      variableName, ". Value(s) ",
      paste(sort(variable.unique[!scoreinfoCheck]), collapse = ", "), " will not be scored.\n", sep = ""))
    }

    scoreString <- paste(paste("'", names(unlist(scoreinfo[[variableName]]$values)),
    "'", "=", "'", unlist(scoreinfo[[variableName]]$values), "'",
    sep = ""), collapse = "; ")
    variableScored <- car::recode(variable, scoreString, as.factor = FALSE,
    as.numeric = FALSE)
#	if(verbose) cat(paste(variableName, " has been scored.\n", sep =""))
  }
  return(variableScored)
}
