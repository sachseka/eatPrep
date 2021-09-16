recodeData <- function (dat, values, subunits = NULL, verbose = FALSE) {

  if (!is.data.frame(dat)) stop ("'dat' must be a data.frame.\n")
  if(!is.null(subunits)) {
    inp <- checkValuesSubunits(values, subunits)
    recodeinfo <- dplyr::inner_join(inp$subunits, inp$values, by = "subunit")
  } else {
    recodeinfo <- values
  }

    datR <- data.frame(mapply(.recodeData.recode, dat,
  colnames(dat), MoreArgs = list(recodeinfo = recodeinfo, mode = "recode", verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)
  if(!is.null(subunits))
    colnames(datR) <- eatTools::recodeLookup(colnames(datR), subunits[ , c("subunit", "subunitRecoded")])

  return(datR)
}

#-----------------------------------------------------------------------------------------

.recodeData.recode <- function (variable, variableName, recodeinfo, dontcheck = "mbd", mode = c("recode", "score"), verbose = TRUE) {
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
    if (mode == "recode"){
      message(paste("Found no recode information for variable ", variableName, ". This variable will not be recoded.", sep =""))
    }
  } else {
    variable.unique <- na.omit(unique(variable[which(!variable %in% dontcheck)]))
    recodeinfoCheck <- (variable.unique %in% recinfoVar$value)
    if (!all(recodeinfoCheck == TRUE)) {
      warning(paste("Incomplete recode information for variable ",
      variableName, ". Value(s) ",
      paste(sort(variable.unique[!recodeinfoCheck]), collapse = ", "), " will not be recoded.", sep = ""))
    }

    lookupVar <- recinfoVar[ , c("value", "valueRecode") ]
    variableRecoded <- eatTools::recodeLookup(variable, lookupVar)
	if (verbose) message(paste(variableName, " has been recoded.", sep =""))
  }
  return(variableRecoded)
}
