mergeData <- function ( newID="ID", datList, oldIDs=NULL, addMbd = FALSE, verbose=TRUE) {
  versNr <- "0.8.0"
  mReturn <- NULL

  stopifnot(is.list(datList))
  stopifnot(is.character(newID))

  if(is.null(oldIDs)) {oldIDs <- rep(newID, length(datList))}
  stopifnot(is.numeric(oldIDs) | is.character(oldIDs))

  stopifnot(length(datList) == length(oldIDs))


  if ( length(datList) > 0 ) {

    fkNam <- list()
    for ( i in seq(along = datList)) {

      stopifnot(is.data.frame(datList[[i]]))

      if(any(unlist(lapply(datList[[i]], class)) == "factor")) {
        fkNam[[i]] <- names(which(unlist(lapply(datList[[i]], class)) == "factor"))
        datList[[i]] <- set.col.type(datList[[i]], col.type = list ( "character" = fkNam[[i]] ))
      }

		  if(verbose) {cat(paste ( "mergeData_", versNr, ": Start merging of dataset ", i, ".\n", sep=""))}

			if(i==1) {

				if(is.character(oldIDs)) {IDname1 <- oldIDs[i]}
				if(is.numeric(oldIDs)) {IDname1 <- colnames(datList[[i]])[oldIDs[i]]}

			  if ( is.character(IDname1) & IDname1 %in% names(datList[[i]])) {
			    if(any(is.na(datList[[i]][,IDname1]))) {
			      warning(paste0("mergeData_", versNr, ": Found missing value in ID variable in dataset ", i, ". Output may not be as desired."))
			    }
  				if(length(na.omit(datList[[i]][,IDname1])) != length(na.omit(unique(datList[[i]][,IDname1])))) {
  							doppelt <- na.omit(unique(datList[[i]][,IDname1][duplicated(datList[[i]][,IDname1])]))
  							cat(paste("mergeData_",versNr, ": Multiple IDs in dataset ", i, " in " ,length(doppelt)," cases. \n",sep=""))
  							stop(cat(paste("Multiple IDs: ", paste( doppelt, collapse = ", "), "\n" )))}
					names(datList[[i]])[names(datList[[i]]) == IDname1] <- newID
					mergedData <- datList[[i]]
				} else {
					stop(paste0( "mergeData_", versNr, ": Did not find ID variable in dataset ", i, "\n"))
					mReturn <- FALSE
				}

			} else {

        if(is.character(oldIDs)) {IDname2 <- oldIDs[i]}
        if(is.numeric(oldIDs)) {IDname2 <- colnames(datList[[i]])[oldIDs[i]]}

				if(is.character(IDname2) & IDname2 %in% names(datList[[i]])) {
				  if(any(is.na(datList[[i]][,IDname2]))) {
				    warning(paste0("mergeData_", versNr, ": Found missing values in ID variable in dataset ", i, ". Output may not be as desired."))
				  }
				  if(length(na.omit(datList[[i]][,IDname2])) != length(na.omit(unique(datList[[i]][,IDname2])))) {
				    doppelt <- na.omit(unique(datList[[i]][,IDname2][duplicated(datList[[i]][,IDname2])]))
				    cat(paste("mergeData_",versNr, ": Multiple IDs in dataset ", i, " in " ,length(doppelt)," cases. \n",sep=""))
				    stop(cat(paste("Multiple IDs: ", paste( doppelt, collapse = ", "), "\n" )))}

					names(datList[[i]])[names(datList[[i]]) == IDname2] <- newID

					dat2 <- dplyr::full_join(mergedData, datList[[i]], by=newID)

					srtn <- unique(gsub(".[x|y]$","",names(dat2)))
					compar <- gsub(".[x|y]$","",names(dat2)[which(duplicated(gsub(".[x|y]$", "", names(dat2))))])
					if(length(compar) > 0) {
					  ncompar <- setdiff(gsub(".[x|y]$","",names(dat2)),compar)
					  bb <- data.frame(lapply(compar, function(gg)   {
					    x <- dat2[,grep(gg, names(dat2))[1]]
					    y <- dat2[,grep(gg, names(dat2))[2]]
					    z <- ifelse(is.na(x),y,x)
					    b <- which(x[!is.na(x) & !is.na(y)] != y[!is.na(x) & !is.na(y)])
					    a <- cbind(x[!is.na(x) & !is.na(y)],y[!is.na(x) & !is.na(y)])[b,]
					    if(verbose & length(a) > 0) {
					      ab <- paste(apply(data.frame(a),1, function(vv) paste(vv, collapse=("&"))),collapse=", ")
					      cat(paste0("Multiple different valid codes in variable: ",gg,": \n The first value has been kept. \n Rows: ", paste(b,collapse=", "),"\n Values: ", ab, "\n"))
					    }
					    return(z)
					  }))
					  names(bb) <- compar
					  partialdata <- cbind(dat2[,ncompar, drop=FALSE], bb)
					} else {
					  partialdata <- dat2
					}
					mergedData  <- partialdata[,srtn]

				} else {
				  stop(paste0( "mergeData_", versNr, ": Did not find ID variable in dataset ", i, "\n"))
				  mReturn <- FALSE
				}
			}
     }

		  mReturn <- mergedData

		  if(addMbd == TRUE) {mReturn[is.na(mReturn)] <- "mbd"}

		} else {
	  	warning(paste("mergeData_", versNr, ": Found no datasets."), "\n")
	  	mReturn <- FALSE
	  }

  	if(is.data.frame(mReturn)) {
  		if(!is.null(unlist(fkNam))) {
  			mReturn <- set.col.type(mReturn, col.type = list ( "factor" = unique(unlist(fkNam))))
  		}
  	}

	return (mReturn)
}
