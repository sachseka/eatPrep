recodeData <- function (dat, values, subunits, verbose = FALSE) {

  if (!is.data.frame(dat)) stop ("'dat' must be a data.frame.\n")

  recodeinfo <- dplyr::inner_join(subunits, values, by = "subunit")

  # make recoded data.frame
  datR <- data.frame(mapply(.recodeData.recode, dat,
  colnames(dat), MoreArgs = list(recodeinfo = recodeinfo, verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)

  return(datR)
}

#-----------------------------------------------------------------------------------------

.recodeData.recode <- function (variable, variableName, recodeinfo, dontcheck = "mbd", verbose = TRUE) {
  variableRecoded <- NULL

  if (!is.character(variable)) {
    variable <- as.character(variable)
  }

  if(any(colnames(recodeinfo) == "subunit")) {
    recinfoVar <- recodeinfo[which(recodeinfo$subunit == variableName), ]
  } else {
    recinfoVar <- recodeinfo[which(recodeinfo$unit == variableName), ]
  }

  if (nrow(recinfoVar) == 0) {
    variableRecoded <- variable
    message(paste("Found no recode information for variable ", variableName, ". This variable will not be recoded.\n", sep =""))
  } else {
    variable.unique <- na.omit(unique(variable[which(!variable %in% dontcheck)]))
    recodeinfoCheck <- (variable.unique %in% recinfoVar$value)
    if (!all(recodeinfoCheck == TRUE)) {
      warning(paste("Incomplete recode information for variable ",
      variableName, ". Value(s) ",
      paste(sort(variable.unique[!recodeinfoCheck]), collapse = ", "), " will not be recoded.\n", sep = ""))
    }

    lookupVar <- recinfoVar[ , c("value", "valueRecode") ]
    variableRecoded <- eatTools::recodeLookup(variable, lookupVar)
	if (verbose) message(paste(variableName, " has been recoded.\n", sep =""))
  }
  return(variableRecoded)
}
