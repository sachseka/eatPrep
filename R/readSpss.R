readSpss <- function (file, addLeadingZeros=FALSE, truncateSpaceChar = TRUE) {

  if(file.exists(file) != TRUE) {
    stop("Could not find file.\n")
  }

dat <- data.frame(haven::read_sav(file=file.path(file), user_na = TRUE))

dat <- set.col.type(dat)

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

