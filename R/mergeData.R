mergeData <- function(newID, datList, oldIDs=NULL, addMbd = FALSE, verbose=TRUE) {
  checkmate::assert_character(newID, len = 1)
  if (checkmate::test_list(datList)){
    checkmate::assert_list(datList, types = "data.frame", null.ok = TRUE)
  } else {
    checkmate::assert_data_frame(datList, null.ok = TRUE)}
  checkmate::assert_vector(oldIDs, null.ok = TRUE, len = length(datList))
  lapply(c(addMbd, verbose), checkmate::assert_logical, len = 1)

  #stopifnot(is.list(datList))
  #stopifnot(is.character(newID))

  if(is.null(oldIDs)) {oldIDs <- rep(newID, length(datList))}
  stopifnot(is.numeric(oldIDs) | is.character(oldIDs))

  stopifnot(length(datList) == length(oldIDs))


  if(length(datList) > 0) {

    fkNam <- list()
    for(i in seq(along = datList)) {
      fkNam[[i]] <- NULL
      stopifnot(is.data.frame(datList[[i]]))

      if(any(unlist(lapply(datList[[i]], class)) == "factor")) {
        fkNam[[i]] <- names(which(unlist(lapply(lapply(datList[[i]], class), function(hh) "factor" %in% hh))))
        datList[[i]] <- set.col.type(datList[[i]], col.type = list ( "character" = fkNam[[i]] ))
      }

		  if(verbose) message("Start merging of dataset ", i, ".")

			if(i==1) {

				if(is.character(oldIDs)) {IDname1 <- oldIDs[i]}
				if(is.numeric(oldIDs)) {IDname1 <- colnames(datList[[i]])[oldIDs[i]]}

			  if(is.character(IDname1) & IDname1 %in% names(datList[[i]])) {
			    if(any(is.na(datList[[i]][,IDname1]))) {
			      warning("Found missing value in ID variable in dataset ", i, ". Output may not be as desired.")
			    }
  				if(length(na.omit(datList[[i]][,IDname1])) != length(na.omit(unique(datList[[i]][,IDname1])))) {
  							doppelt <- na.omit(unique(datList[[i]][,IDname1][duplicated(datList[[i]][,IDname1])]))
  							message("Multiple IDs in dataset ", i, " in " ,length(doppelt)," cases.")
  							stop("Multiple IDs: ", paste(doppelt, collapse = ", "))
  							}
					names(datList[[i]])[names(datList[[i]]) == IDname1] <- newID
					mergedData <- datList[[i]]
				} else {
					stop("Did not find ID variable in dataset ", i)
				}

			} else {

        if(is.character(oldIDs)) {IDname2 <- oldIDs[i]}
        if(is.numeric(oldIDs)) {IDname2 <- colnames(datList[[i]])[oldIDs[i]]}

				if(is.character(IDname2) & IDname2 %in% names(datList[[i]])) {
				  if(any(is.na(datList[[i]][,IDname2]))) {
				    warning("Found missing values in ID variable in dataset ", i, ". Output may not be as desired.")
				  }
				  if(length(na.omit(datList[[i]][,IDname2])) != length(na.omit(unique(datList[[i]][,IDname2])))) {
				    doppelt <- na.omit(unique(datList[[i]][,IDname2][duplicated(datList[[i]][,IDname2])]))
				    message("Multiple IDs in dataset ", i, " in " ,length(doppelt)," cases.")
				    stop("Multiple IDs: ", paste(doppelt, collapse = ", "))
				    }

					names(datList[[i]])[names(datList[[i]]) == IDname2] <- newID

					dat2 <- dplyr::full_join(mergedData, datList[[i]], by=newID)
					srtn <- unique(gsub("\\.[x|y]$","",names(dat2)))
					compar <- gsub("\\.[x|y]$","",names(dat2)[which(duplicated(gsub("\\.[x|y]$", "", names(dat2))))])
					if(length(compar) > 0) {
					  ncompar <- setdiff(gsub("\\.[x|y]$","",names(dat2)),compar)
					  bb <- data.frame(lapply(compar, function(gg)   {
					    x <- dat2[,paste0(gg, ".x")]
					    y <- dat2[,paste0(gg, ".y")]
					    z <- ifelse(is.na(x),y,x)
					    b <- which(x[!is.na(x) & !is.na(y)] != y[!is.na(x) & !is.na(y)])
					    a <- cbind(x[!is.na(x) & !is.na(y)],y[!is.na(x) & !is.na(y)])[b,]
					    b <- which(x!=y)
					    if(verbose & length(a) > 0) {
					      if(dim(data.frame(a))[2] == 1) {
					        ab <- paste(a,collapse="&")
					      } else {
					        ab <- paste(apply(data.frame(a),1, function(vv) paste(vv, collapse=("&"))),collapse=", ")
					      }
					      message("Multiple different valid codes in variable: '",gg,"' in 'dataset ",i,"': \n The first value has been kept. \n IDs: ", paste(dat2[,newID][b],collapse=", "),"\n Values: ", ab)
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
				  stop("Did not find ID variable in dataset ", i)
				}
			}
     }

		  mReturn <- mergedData

		  if(addMbd == TRUE) {mReturn[is.na(mReturn)] <- "mbd"}

		} else {
	  	stop("Found no datasets.")
	  }

  	if(is.data.frame(mReturn)) {
  		if(!is.null(unlist(fkNam))) {
  			mReturn <- set.col.type(mReturn, col.type = list ( "factor" = unique(unlist(fkNam))))
  		}
  	}

	return(mReturn)
}
