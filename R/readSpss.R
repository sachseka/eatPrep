readSpss <- function (file, oldID = NULL, newID = NULL, addLeadingZeros=FALSE, truncateSpaceChar = TRUE) {

  if(file.exists(file) != TRUE) {
    stop("Could not find file.\n")
  }

dat <- data.frame(haven::read_sav(file=file.path(file), user_na = TRUE))

dat <- set.col.type(dat)

	if (!is.null(newID)){
		if(length(newID)!=1) {
			stop("'newID' has to be of length 1.")
		}

		if (!is.null(oldID)){
			idCol  <- na.omit(match(oldID, colnames(dat)))
			if(length(na.omit(match(colnames(dat), oldID)))<1) {
				stop("Specified 'oldID' wasn't found in dataset.")
			}
			if(length(na.omit(match(colnames(dat), oldID)))>1) {
				stop("Specified 'oldID' was found more than once in dataset.")
			}
			colnames(dat)[idCol] <- newID
		}
	}

  ### Leerzeichen abschnipseln
  if(isTRUE(truncateSpaceChar))  {
    dat <- do.call("data.frame", list(lapply(dat, crop), stringsAsFactors = FALSE ) )
  }

  # Check auf alles character
  stopifnot(all(sapply(dat, is.character )))

  ### Stelligkeitskorrektur
  if(isTRUE(addLeadingZeros)) {
    dat <- eatTools::addLeadingZerosToCharInt(dat)
  }

  return(dat)
}

