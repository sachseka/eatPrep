automateDataPreparation <- function(datList = NULL, inputList, path = NULL,
						readSpss, checkData,  mergeData , recodeData, recodeMnr = FALSE,
						aggregateData, scoreData, writeSpss, collapseMissings = FALSE,
						filedat = "mydata.txt", filesps = "readmydata.sps", breaks=NULL, nMbi = 2,
						rotation.id = NULL, suppressErr = FALSE, recodeErr = "mci",
						aggregatemissings = NULL, rename = TRUE, recodedData = TRUE,
						addLeadingZeros=FALSE, truncateSpaceChar = TRUE, newID = NULL, oldIDs = NULL,
            missing.rule = list(mvi = 0, mnr = 0, mci = NA, mbd = NA, mir = 0, mbi = 0), verbose=FALSE) {

		###folder erstellen
		if(is.null(path)) {
		  folder.e <- getwd()
		  } else {
		    folder.e <- file.path(path)
		  }

		### Begruessung
		if(verbose) message("Starting automateDataPreparation ", Sys.time())

		### Checks
	newID2 <- newID
  if(!is.null(newID)) {
			stopifnot(is.character(newID))
			stopifnot(length(newID) == 1)
			}
		stopifnot(is.logical(readSpss))
		stopifnot(is.logical(checkData))
		stopifnot(is.logical(mergeData))
		stopifnot(is.logical(recodeData))
		stopifnot(is.logical(recodeMnr))
		stopifnot(is.logical(aggregateData))
		stopifnot(is.logical(scoreData))
		stopifnot(is.logical(writeSpss))
		stopifnot(is.logical(collapseMissings))
		stopifnot(is.logical(addLeadingZeros))
		stopifnot(is.logical(truncateSpaceChar))
		stopifnot(is.logical(verbose))

		if(is.null(datList)) {
			stopifnot(readSpss)
			if(class(inputList$savFiles) != "data.frame") {
			  if(verbose) {
			    if(is.null(path)) {
			      message("No appropriate inputList$savFiles data.frame provided. I will try to read .sav-files from getwd().")
			    } else {
			      message("No appropriate inputList$savFiles data.frame provided. I will read .sav-files from path = ", path)
			    }
			  }
			  }
		} else {
			stopifnot(class(datList) == "data.frame" || class(datList) == "list")
			if(class(datList) == "data.frame") {
			  datList <- list(datList)
			  names(datList) <- "dat"
			}
		}

		### ggf. sav-files einlesen
		if(readSpss) {
			if(verbose) message("\nLoad .sav-files.")
			if(!is.null(datList)) {
				warning("If readSpss == TRUE, datList will be ignored.")
			}

		  if(class(inputList$savFiles) != "data.frame") {
        # if no savFiles sheet, then take all .sav files in path or getwd
		    savFiles <- grep(".sav$",dir(folder.e),value=TRUE)
        if(!length(savFiles) > 0) stop("No .sav-files found in ", folder.e)
        fulln <- file.path(folder.e, savFiles)
        names(fulln) <- basename(savFiles)
		  } else {
  			savFiles <- inputList$savFiles$filename
  			fulln <- inputList$savFiles$fullname
  			names(fulln) <- inputList$savFiles$filename
  			ex <- !sapply(fulln, file.exists)
  			folders.e <- unique(sapply(inputList$savFiles$fullname, function(jj) gsub(basename(jj),"",jj)))
  			if(all(ex)) stop("All file(s) not found in: ", paste(folders.e, collapse=", "), " : ", paste(names(ex)[ex], collapse=", "))
  			if(any(ex)) warning("Some file(s) not found in: ", paste(folders.e, collapse=", "), " : ", paste(names(ex)[ex], collapse=", "))
		  }
		dat <- datList <- mapply(readSpss, file = fulln,
						MoreArgs = list(addLeadingZeros=addLeadingZeros, truncateSpaceChar = truncateSpaceChar),
						SIMPLIFY=FALSE)
		  if(verbose) message("Successfully read in: ", paste(names(datList),collapse=", "))
			}

		# Checks
		stopifnot(class(datList) == "list")
		stopifnot(class(inputList) == "list")
		if(is.null(oldIDs)) {oldIDs <- inputList$savFiles$case.id}
		if(is.null(oldIDs)) stop("Please specify oldIDs. Case ID in inputList$savFiles$case.id seems to be empty.")

		if(checkData) {
			if(verbose) message("\nCheck data...")
			mapply(checkData, dat=datList, datnam=names(datList), ID=oldIDs, MoreArgs = list(values=inputList$values, subunits=inputList$subunits, units=inputList$units, verbose=verbose))
		} else {if(verbose) message("\nCheck has been skipped." )}

		if(mergeData) {
			if(verbose) message("\nStart merging.")
			if(is.null(newID)) {
			  if(is.null(inputList$newID)) {
			    newID <- "ID"
			  } else {
			    newID <- inputList$newID$value
			  }
			}
			dat <- mergeData(newID = newID, datList = datList, oldIDs = oldIDs, addMbd=TRUE, verbose=verbose)
			idname <- newID
		} else {
		  if(!is.null(newID2) & verbose) message("Argument 'newID' will be ignored, because merge has been skipped.")
			if(recodeData|recodeMnr|aggregateData|scoreData|writeSpss)  {
			  warning("Merge has been skipped. Only the first dataset in datList will be considered for the following steps.")
			  dat <- datList[[1]]
			  idname <- oldIDs[1]
			}
			if(length(datList) > 1 & !(recodeData|recodeMnr|aggregateData|scoreData|writeSpss) & verbose) {
			  message("Merge has been skipped, but more than one dataset has been loaded. A list of datasets will be returned." )
			  dat <- datList
			  } else {
			  message("\nMerge has been skipped." )
			}
		}

		if(recodeData) {
			if(verbose) message("\nStart recoding.")
  		if(is.data.frame(dat)) {
  					if(nrow(dat) == 0 | ncol(dat) == 0) dat <- NULL
  			}
  	  if (!is.data.frame(dat)) {
  	    stop("internal error: 'dat' is not a data.frame or empty")
  	  }
			dat <- recodeData(dat=dat, values=inputList$values, subunits=inputList$subunits, verbose=verbose)
		} else {
		  if(verbose) message("\nRecode has been skipped.")
    }

		if(recodeMnr) {
			if(verbose) message("\nStart recoding Mbi to Mnr.")
			if(is.null(inputList$booklets)) stop("Recoding Mnr in automateDataPreparation requires inputList$booklets. Data frame not available.")
			if(is.null(inputList$blocks)) stop("Recoding Mnr in automateDataPreparation requires inputList$blocks. Data frame not available.")
  		if(is.null(inputList$rotation)) {
  				if(is.character(rotation.id)) {
  						if(rotation.id %in% colnames(dat)) {
  								if(idname %in% colnames(dat)) {
  									inputList$rotation <- dat[,c(idname,rotation.id),drop=FALSE]
  								}
  						}
  				}
		}

		if(is.null(inputList$rotation) & is.null(rotation.id)) {
				stop("Recoding Mnr in automateDataPreparation requires inputList$rotation or rotation.id. These are not available.")
		}

		if(is.null(breaks)) stop("Recoding Mnr in automateDataPreparation requires 'breaks'.")

		if(is.null(rotation.id)) {
				dat <- mergeData(newID, list(dat, inputList$rotation), verbose=FALSE)
				rotation.id <- names(inputList$rotation)[2]
			}
			dat <- mnrCoding(dat = dat , pid = newID , rotation.id = rotation.id , blocks = inputList$blocks , booklets = inputList$booklets , breaks = breaks , subunits = inputList$subunits , nMbi = nMbi  , mbiCode = "mbi" , mnrCode = "mnr" , invalidCodes = c ( "mbd", "mir", "mci" ) , verbose = verbose )


		} else {
		  if(verbose) message("\nRecodeMnr has been skipped.")
		  }


		if(aggregateData) {
			if(verbose) message("\nStart aggregating" )
			if ( length(aggregatemissings) > 0 && aggregatemissings == "seeInputList" ) {
				stopifnot(!is.null(inputList$aggrMiss))
				aMiss <- unname(inputList$aggrMiss[,-1])
				aMiss[,8] <- rep("err", 7)
				aMiss[8,] <- rep("err", 8)
				aggregatemissings <- unname(as.matrix(aMiss, nrow=8, ncol=8))
				dimnames(aggregatemissings) <-
                list(c(names(inputList$aggrMiss)[-1], "err"),
										c(names(inputList$aggrMiss)[-1], "err"))
			}
			dat <- aggregateData (dat=dat, subunits=inputList$subunits, units=inputList$units,
            aggregatemissings = aggregatemissings, rename = rename, recodedData = recodedData, verbose = verbose, suppressErr = suppressErr, recodeErr = recodeErr)
		} else {
		if(verbose) message("\nAggregate has been skipped." )
		  }

		if(scoreData) {
			if(verbose) message("\nStart scoring.")
				dat <- scoreData (dat= dat, unitrecodings=inputList$unitRecodings, units=inputList$units, subunits=inputList$subunits, verbose = verbose)
		} else {
		if(verbose) message("\nScoring has been skipped." )
		  }

		if(writeSpss) {
			if(verbose) message("\nWriting dataset in last transformation status to disk" )
			if (class(dat) != "data.frame") {
				warning ("Data is no data frame (data frames probably need to be merged)." )
			}
			if(inherits(try( writeSpss (dat=dat , values=inputList$values, subunits=inputList$subunits, units=inputList$units,
					filedat = filedat, filesps = filesps, missing.rule = missing.rule,
					path = folder.e, # path = folder.aDP,
					sep = "\t", dec = ",", verbose = verbose)  ),"try-error")) {
				if(verbose)
				warning ("No SPSS-File could be written.")
			}
		} else {
		if(verbose) message("\nNo SPSS-File has been written." ) }

		if(collapseMissings) {
			if(verbose) message("\nCollapsing missings.")
			dat <- collapseMissings(dat=dat, missing.rule = missing.rule)
		} else {
		if(verbose) message("\nMissings are UNcollapsed.")
		  }

		# finale Ausgabe
		if(verbose) message("automateDataPreparation terminated successfully! ", Sys.time(), "\n")

		return(dat)
}

# data(inputList)
# data(inputDat)
# test <- automateDataPreparation(inputList = inputList, datList = inputDat,
        # path = "c:/temp/test_eat", readSpss = FALSE, checkData=TRUE,
        # mergeData = TRUE, recodeData=TRUE, recodeMnr = TRUE, breaks = c(1,2),
		    # aggregateData=TRUE, scoreData= TRUE, writeSpss=TRUE, verbose=TRUE)


