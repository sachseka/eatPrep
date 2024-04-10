checkData <- function (dat, datnam, values, subunits, units, ID=NULL, verbose = TRUE) {

  checkmate::assert_character(datnam, len = 1)
  lapply(list(values, subunits, units), checkmate::assert_data_frame)
  checkmate::assert_character(ID, len = 1, null.ok = TRUE)
  checkmate::assert_logical(verbose, len = 1)

  # funVersion <- "checkData: "
	varinfo <- makeInputCheckData (values, subunits, units)

	if(verbose) message("\nChecking dataset ", datnam)

	if (!inherits(dat, "data.frame")) {
		stop ("dat must be a data.frame.")
	}

	# ID-Check <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  # find ID - stop if ID cannot be found
	#	eatTools:::sunk(paste(funVersion, "Checking IDs", sep =""))
	if(is.null(ID)) {
    idvarname <- getID(varinfo)
	} else {
	  idvarname <- ID
	}

	checkID (dat, idvarname, verbose)

	# Variables-Check <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  #	eatTools:::sunk(paste(funVersion, "Checking variables", sep = ""))
  checkVars(dat, varinfo, verbose)

	# check missing values
  checkMissings(dat, varinfo, idvarname, verbose)

  # check for invalid codes
  checkCodes(dat, varinfo, idvarname, verbose)

}



#-----------------------------------------------------------------------------------------

getID <- function(varinfo) {
  # erkennt am Typ in Varinfo, welche Variable die ID ist
  # gibt String mit Name dieser Variable zurueck

# funVersion <- "getID: "

  if (missing(varinfo)) {
    stop("Found no information about variables.")
  }
  # Typen extrahieren
  type <- which ( sapply(varinfo, "[[", "type") == "ID")
  if (length(type) == 0) {
    stop("No ID variable specified. Please check input 'units' for variable with 'unitType' = 'ID'.")
  } else {
  # find name of id variable
    nameID <- names(varinfo)[type]
    if ( length(nameID) > 1) {
      stop("Found more than one ID variable.")
    }
  }

  return(nameID)

}

#-----------------------------------------------------------------------------------------


checkID <- function(dat, idvarname, verbose) {
  # funVersion <- "checkID: "
  # check dat for specified id variable
	if (is.na(match(idvarname, colnames(dat)))) {
		stop("ID variable ", idvarname, "not found in dataset.")
	} else {
		emptyID <- which(nchar(dat[, idvarname]) == 0 | is.na(dat[, idvarname]))
		if (length(emptyID > 0)) {
		  stop("ID variable has empty cells in line(s) ", paste(emptyID, collapse = ", "))
		} else {
		  if(verbose) message("Only valid codes in ID variable.")
		}
		if (length(na.omit(dat[, idvarname])) != length(na.omit(unique(dat[, idvarname])))) {
		  duplicatedID <- na.omit(unique(dat[, idvarname][duplicated(dat[, idvarname])]))
		  stop("ID variable has ", length(duplicatedID),
					  " duplicated entries for IDs: ", paste(duplicatedID, collapse = ", "))
		} else {
		  if(verbose) message("No duplicated entries in ID variable.")
		}
	}
}

#-----------------------------------------------------------------------------------------

checkVars <- function(dat, varinfo, verbose) {

  # funVersion <- "checkVars: "

	if (length(colnames(dat)) != length(unique(colnames(dat)))) {
		duplicatedVarnames <- colnames(dat)
		duplicatedVarnames <- unique(duplicatedVarnames[duplicated(duplicatedVarnames)])
		stop("Found duplicated variable names for ", length(duplicatedVarnames), " variables.")
	} else {
		if(verbose) message("No duplicated variable names.")
	}

	varsWithoutVarinfo <- setdiff(colnames(dat), names(varinfo))
	if (length(varsWithoutVarinfo) > 0) {
		if(verbose) message("Found no variable information about variable(s) ", paste(varsWithoutVarinfo, collapse = ", "),
			". This/These variables will not be checked for missings and invalid codes.")
	}
}
#-----------------------------------------------------------------------------------------

checkMissings <- function (dat, varinfo, idvarname, verbose) {
	# check missing values
#  eatTools:::sunk(paste(funVersion, "Checking missing values", sep = ""))

  # funVersion <- "checkMissings: "

  if(length(which(names(varinfo) == idvarname))> 0) {
    vars <- intersect(colnames(dat), names(varinfo)[- which(names(varinfo) == idvarname)])
  } else {
    vars <- intersect(colnames(dat), names(varinfo))
  }

  if (length(vars) == 0){
    if(verbose) message("Found no variable informations for any of the variables in 'dat'. Check for missing values will be skipped.")
  } else {

  	# Indikatordatensatz fuer Missings initialisieren
    missingInd <- matrix(data = NA, nrow = nrow(dat), ncol = length(vars) + 1)

    colnames(missingInd) <- c( idvarname, vars)
  	missingInd[, idvarname] <- dat[, idvarname]

  	# Missing-Codes rausfinden: Welche Code-Typen beginnen mit einem "m"?
    for (var in vars) {
  		CodeTypes <- lapply(varinfo[[var]]$values, "[[", "type")
  		MissingCodes <- names(CodeTypes[substring(CodeTypes, 1, 1) == "m"])
  		if (is.null(MissingCodes) | length(MissingCodes) == 0) {
  			if(verbose) message("Found no missing values definitions for variable ",
  			  var, ". This variable will only be checked for NA values.")
  		}
  		missingInd[, var ] <- 1 * (!dat[, match(var, colnames(dat))] %in% c(NA, "", MissingCodes))
  	}

  	# zuerst missingInd in dataframe umwandeln, damit sie nicht mehr character ist
  	missingInd <- data.frame(missingInd, stringsAsFactors = FALSE)
  	idCol <- which(colnames(missingInd) == idvarname)

  	# check for variables with only missing values
  	missingInd[, - idCol] <- apply(missingInd[, - idCol], 2, as.numeric)
  	varMissing <- colnames(missingInd[, - idCol])[colSums(missingInd[, - idCol]) == 0]
  	if (length(varMissing) > 0) {
  		if(verbose) message("Variable(s) ", paste(varMissing, collapse = ", "),
      " contain(s) only missing values.")
  	}

  	# check cases for cases with only missing values
  	caseMissing <- missingInd[rowSums(missingInd[, - idCol]) == 0, idvarname]
  	if (length(caseMissing) > 0) {
  		if(verbose) message("Case(s) ", paste(caseMissing, collapse = ", "), " contain(s) only missing values.")
  	}
  }
}

#-----------------------------------------------------------------------------------------

checkCodes <- function(dat, varinfo, idvarname, verbose) {
  # funVersion <- "checkCodes: "

  if(length(which(names(varinfo) == idvarname))> 0) {
    vars <- intersect(colnames(dat), names(varinfo)[- which(names(varinfo) == idvarname)])
  } else {
    vars <- intersect(colnames(dat), names(varinfo))
  }

  if (length(vars) == 0){
    if(verbose) message("Found no variable informations for any of the variables in 'dat'. Check for invalid codes will be skipped.")
  } else {
    count <- 0

  	for (v in vars) {
  		if (!varinfo[[v]]$type %in% c("ID", "T1", "T2", "T3")) {
  			validCodes <- names(varinfo[[v]]$values)
  			givenCodes <- names(table(dat[, match(v, colnames(dat))]))
  			givenCodesFreq <- table(dat[, match(v, colnames(dat))])
  			if (length(validCodes > 0)) {
  			  invalidCodes <- setdiff(givenCodes, validCodes)
  			  if (length(invalidCodes > 0)) {
  				invalidCodesFreq <- givenCodesFreq[names(givenCodesFreq) %in% invalidCodes]
  				# warning("Found invalid codes in variable ", v)
  				if(verbose) message("Found invalid codes in variable ", v, ": ", paste(paste(invalidCodesFreq, "cases invalid", names(invalidCodesFreq)), collapse = ", "), paste("-- valid Codes: ", paste(validCodes, collapse = ", ")) )
  				count <- count + 1
  			  }
  			} else {
  			  if(verbose) message("Found no informations about valid codes for variable ",	v, ".")
  			}
  		}
  	}
  	if (count > 0) {
  	}
  	else {
  		if(verbose) message("Found no invalid codes.")
  	}
  }
}

