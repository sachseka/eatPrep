visualSubsetRecode <- function(dat, subsetInfo, ID="ID", toRecodeVal="mci") {

  lapply(list(dat, subsetInfo), checkmate::assert_data_frame, min.rows = 1)
  checkmate::assert_scalar(ID)

  subsetInfo <- unique(na.omit(subsetInfo))
  datM <- dat

  captureInteraction <- NULL
  for(ll in unique(subsetInfo$ID)) {
    res1 <- 0
    vars <- subsetInfo$datCols[subsetInfo$ID %in% ll]
    sdat <- datM[datM[,ID] %in% ll, vars]
    cli::cli_inform("Display subset: {ll} (case{?s}) x {vars} (variable{?s}):", wrap = TRUE)
    print(sdat)
    res1 <- menu(c("yes", "no", "flag, maybe later"),
                title = paste0("\nDo you want to recode this subset to '", toRecodeVal, "'?"))
    if(res1==1) {
      datM[datM[,ID] %in% ll, subsetInfo$datCols[subsetInfo$ID %in% ll]] <- "mci"
    }
    captureInteraction <- rbind(captureInteraction, data.frame(ID=ll, choice = res1))
  }

  res <- list(datM, captureInteraction)
  return(res)
}
