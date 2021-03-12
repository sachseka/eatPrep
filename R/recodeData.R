recodeData <- function (dat, values, subunits, verbose = FALSE) {

  if (class(dat) != "data.frame") stop ("'dat' must be a data.frame.\n")

#  recodeinfo <- makeInputRecodeData (values = values, subunits = subunits)
  recodeinfo <- dplyr::full_join(subunits, values, by = "subunit")

  # make recoded data.frame
  datR <- data.frame(mapply(.recodeData.recode, dat,
  colnames(dat), MoreArgs = list(recodeinfo = recodeinfo, verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)

  colnames(datR) <- sapply(colnames(datR), .recodeData.renameIDs, recodeinfo, USE.NAMES = FALSE)

  return(datR)
}

#-----------------------------------------------------------------------------------------

.recodeData.recode <- function (variable, variableName, recodeinfo, verbose = TRUE) {
  variableRecoded <- NULL

  if (!(class(variable) == "character")) {
    variable <- as.character(variable)
  }

  recinfoVar <- recodeinfo[which(recodeinfo$subunit == variableName), ]

  if (nrow(recinfoVar) == 0) {
    variableRecoded <- variable
    message(paste("Found no recode information for variable ", variableName, ". This variable will not be recoded.\n", sep =""))
  } else {
    dontcheck <- c("mbd")
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

#-----------------------------------------------------------------------------------------

.recodeData.renameIDs <-  function(colname, recodeinfo) {
  newID <- recodeinfo[[colname]]$newID
  if (is.null(newID)) {
   colname
  } else {
    newID
  }
}
