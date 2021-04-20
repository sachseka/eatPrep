scoreData <- function (dat, unitrecodings, units, verbose = FALSE) {
  if (!is.data.frame(dat)) stop ("'dat' must be a data.frame.\n")

  scoreinfo <- dplyr::inner_join(units, unitrecodings, by = "unit")
  dontcheck <- c("mbd","mvi", "mnr", "mci", "mbd", "mir", "mbi")

  if(length(setdiff(colnames(dat), names(scoreinfo))) > 0) {
	message(paste("Found no recode information for variable(s) ",
		paste(setdiff(colnames(dat), names(scoreinfo)), collapse = ", "),
			". \nThis/These variable(s) will not be recoded.\n", sep =""))
  }

  # make scored data.frame
  datS <- data.frame(mapply(.recodeData.recode, dat,
  colnames(dat), MoreArgs = list(scoreinfo, verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)

#  colnames(datS) <- sapply(colnames(datS), .recodeData.renameIDs, scoreinfo, USE.NAMES = FALSE)

  return(datS)
}

