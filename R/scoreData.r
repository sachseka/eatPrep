scoreData <- function (dat, unitrecodings, units, subunits, verbose = FALSE) {
  if (!is.data.frame(dat)) stop ("'dat' must be a data.frame.\n")

  scoreinfo <- dplyr::inner_join(units, unitrecodings, by = "unit")
  dontcheck <- c("mbd","mvi", "mnr", "mci", "mbd", "mir", "mbi")

  unitsToScore <- unique(subunits$unit[duplicated(subunits$unit)])

   if(length(setdiff(unitsToScore, unique(unitrecodings$unit))) > 0) {
   warning(paste("Found no scoring information for variable(s) ",
   paste(setdiff(unitsToScore, unique(unitrecodings$unit)), collapse = ", "),
   		". \nThis/These variable(s) will not be scored.\n", sep =""))
   }

  # make scored data.frame
  datS <- data.frame(mapply(.recodeData.recode, dat,
  colnames(dat), MoreArgs = list(scoreinfo, dontcheck = dontcheck,
                                 mode = "score", verbose = verbose), USE.NAMES = TRUE),
  stringsAsFactors = FALSE)

  if(verbose) message(length(unitsToScore), " units were scored: ", paste(unitsToScore, collapse=", "), ".")

#  colnames(datS) <- sapply(colnames(datS), .recodeData.renameIDs, scoreinfo, USE.NAMES = FALSE)

  return(datS)
}

