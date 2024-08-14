recodeData <- function (dat, values, subunits = NULL, verbose = FALSE) {
  lapply(list(dat, values), checkmate::assert_data_frame)
  checkmate::assert_data_frame(subunits, null.ok = TRUE)
  checkmate::assert_logical(verbose, len = 1)

  if(!is.null(subunits)) {
    inp <- checkValuesSubunits(values, subunits)
    recodeinfo <- dplyr::inner_join(inp$subunits, inp$values, by = "subunit")
  } else {
    recodeinfo <- values
  }


  info <- data.frame(mapply(.recodeData.info, dat,
  colnames(dat), MoreArgs = list(recodeinfo = recodeinfo, mode = "recode", verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)

 info2 <- lapply(info, data.frame)
  info2 <- rbind_common(info2)

  if(sum(!is.na(info2$incomplRecInfo))>0) {
    message(paste0("Incomplete recode information for variable(s): \n",
          paste0(info2[!is.na(info2$incomplRecInfo),"incomplRecInfo"], collapse = ",\n"),".\n-- This/These value(s) occuring in data but WITHOUT recode info will not be recoded."))
  }

  if(verbose) {
    if(sum(!is.na(info2$noRecInfo))>0) {
      message(paste0("\nFound no recode information for variable(s): \n", paste(info2[!is.na(info2$noRecInfo),"noRecInfo"], collapse = ", "), ". \nThis/These variable(s) will not be recoded."))
    }
    if(sum(!is.na(info2$recoded))>0) {
      message(paste0("\nVariables... ", paste(info2[!is.na(info2$recoded),"recoded"], collapse = ", "), "\n...have been recoded."))
    }
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
  } else {
    lookupVar <- unique(recinfoVar[ , c("value", "valueRecode") ])
    variableRecoded <- eatTools::recodeLookup(variable, lookupVar)
  }
  return(variableRecoded)
}

#-----------------------------------------------------------------------------------------

.recodeData.info <- function (variable, variableName, recodeinfo, dontcheck = "mbd", mode = c("recode", "score"), verbose = TRUE) {
  variableRecoded <- NULL

  if (!is.character(variable)) {
    variable <- as.character(variable)
  }

  if(any(colnames(recodeinfo) == "subunit")) {
    recinfoVar <- recodeinfo[which(recodeinfo$subunit == variableName), ]
  } else {
    recinfoVar <- recodeinfo[which(recodeinfo$unit == variableName), ]
  }
  retList <- data.frame(noRecInfo = NA, incomplRecInfo = NA, recoded = NA)
  if (nrow(recinfoVar) == 0) {
    variableRecoded <- variable
    if (mode == "recode"){
      retList[1,"noRecInfo"] <- variableName
      #message(paste("Found no recode information for variable ", variableName, ". This variable will not be recoded.", sep =""))
    }
  } else {
    variable.unique <- na.omit(unique(variable[which(!variable %in% dontcheck)]))
    recodeinfoCheck <- (variable.unique %in% recinfoVar$value)
    if (!all(recodeinfoCheck == TRUE)) {
      if(length(variable.unique[!recodeinfoCheck]) > 10) {
        b1 <- length(variable.unique[!recodeinfoCheck]) - 10
        a1 <- paste0(variableName, " (Value/s: ", paste(sort(variable.unique[!recodeinfoCheck])[1:10], collapse = ", "), " ...and ", b1, " more.)")
      } else {
        a1 <- paste0(variableName, " (Value/s: ", paste(sort(variable.unique[!recodeinfoCheck]), collapse = ", "), ")")
      }
      retList[1,"incomplRecInfo"] <- a1
      #warning(paste("Incomplete recode information for variable ",
             #       variableName, ". Value(s) ",
            #        paste(sort(variable.unique[!recodeinfoCheck]), collapse = ", "), " will not be recoded.", sep = ""))
    }
    retList[1,"recoded"] <- variableName
    #if (verbose) message(paste(variableName, " has been recoded.", sep =""))
  }

  return(retList)
}
