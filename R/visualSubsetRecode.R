visualSubsetRecode <- function(dat, subsetInfo, ID="ID", toRecodeVal="mci", useGroups=NULL) {

  lapply(list(dat, subsetInfo), checkmate::assert_data_frame, min.rows = 1)
  checkmate::assert_scalar(ID)
  stopifnot(ID %in% names(dat))
  stopifnot(ID %in% names(subsetInfo))
  checkmate::assert_character(toRecodeVal, len=1)
  checkmate::assert_character(useGroups, len=1, null.ok=TRUE)
  if(!is.null(useGroups)) stopifnot(useGroups %in% names(subsetInfo))

  if(any(is.na(subsetInfo))) cli::cli_alert_danger("subsetInfo contains NA values.
                                              Every subsetInfo row
                                              containing only a single NA will be
                                              omitted.", wrap = TRUE)
  cli::cli_text("")
  cli::cli_text(paste("--- Begin visual Inspection", Sys.time(), "---"))
  cli::cli_text("")

  subsetInfo <- unique(na.omit(subsetInfo))
  datM <- dat

  captureInteraction <- NULL

  i <- 1
  if(is.null(useGroups)) {
    ll <- unique(subsetInfo[,ID])[i]
    nn <- length(unique(subsetInfo[,ID]))
  } else {
    pp <- unique(subsetInfo[,useGroups])[i]
    ll <- unique(subsetInfo[,ID][subsetInfo[,useGroups] %in% pp])
    nn <- length(unique(subsetInfo[,useGroups]))
  }
  res1 <- 0

  while(i <= nn+1) {

    vars <- unique(subsetInfo$datCols[subsetInfo[,ID] %in% ll])
    sdat <- datM[datM[,ID] %in% ll, vars]
    cli::cli_inform("Display subset ({i} of {nn}): {ll} (case{?s}) x {vars} (variable{?s}):", wrap = TRUE)
    print(sdat)
   # res1 <- menu(c("yes", "no", "flag, maybe later", paste0("go back (already set '", toRecodeVal,"' cannot be undone)")),
   res1 <- menu(c("yes", "no", "flag, maybe later", "go back", "reset to original values"),
                 title = paste0("\nDo you want to recode this subset to '", toRecodeVal, "'?"))
    if(res1==1) {
      datM[datM[,ID] %in% ll, vars] <- "mci"
      cli::cli_alert_success(paste0("Subset successfully recoded to '", toRecodeVal,"'!"))
      cli::cli_text("")
    } else {
      if(res1==5) {
        datM[datM[,ID] %in% ll, vars] <- dat[dat[,ID] %in% ll, vars]
        cli::cli_alert_success("Subset successfully recoded to original values!")
        cli::cli_text("")
      } else {
        cli::cli_alert_info(paste0("No recoding action was undertaken this time."))
        cli::cli_text("")
      }
    }

    if(is.null(useGroups)) {
      captureInteraction <- rbind(captureInteraction, data.frame(ID=ll, choice = res1, timeStamp=Sys.time()))
    } else {
      captureInteraction <- rbind(captureInteraction, data.frame(IDgroup=pp, choice = res1, timeStamp=Sys.time()))
    }

    if(res1==4) {
      if(i == 1) {
        #return(list(datM, captureInteraction))
        cli::cli_alert_danger("--- No previous subset to go back to. ---", wrap = TRUE)
        cli::cli_text("")
      } else {
        i <- i-1
        if(is.null(useGroups)) {
          ll <- unique(subsetInfo[,ID])[i]
        } else {
          pp <- unique(subsetInfo[,useGroups])[i]
          ll <- unique(subsetInfo[,ID][subsetInfo[,useGroups] %in% pp])
        }
      }
    } else {
    i <- i+1
    if(i==nn+1) {
      cli::cli_alert_danger("--- This was the last subset. ---", wrap = TRUE)
      cli::cli_text("")
      res2 <- menu(c("yes", "go back"),
                   title = paste0("\nDo you want to end visualRecoding now?"))
      if(res2==1) {
       i <- nn+2
      } else {
        i <- nn
      }
    }
    if(is.null(useGroups)) {
      ll <- unique(subsetInfo[,ID])[i]
    } else {
      pp <- unique(subsetInfo[,useGroups])[i]
      ll <- unique(subsetInfo[,ID][subsetInfo[,useGroups] %in% pp])
    }
    }
  }

  subsetInfoM <- merge(subsetInfo, captureInteraction, by.x=ID, by.y="ID", all=TRUE)
  # if(any(subsetInfoM$choice==4)) subsetInfoM <- subsetInfoM[subsetInfoM$choice != 4,]

  res <- list(datM, subsetInfoM)
  return(res)
}

# old snippet without the possibility to go back
# for(ll in unique(subsetInfo$ID)) {
#   res1 <- 0
#   vars <- subsetInfo$datCols[subsetInfo$ID %in% ll]
#   sdat <- datM[datM[,ID] %in% ll, vars]
#   cli::cli_inform("Display subset: {ll} (case{?s}) x {vars} (variable{?s}):", wrap = TRUE)
#   print(sdat)
#   res1 <- menu(c("yes", "no", "flag, maybe later", "go back"),
#                title = paste0("\nDo you want to recode this subset to '", toRecodeVal, "'?"))
#   if(res1==1) {
#     datM[datM[,ID] %in% ll, subsetInfo$datCols[subsetInfo$ID %in% ll]] <- "mci"
#   }
#   captureInteraction <- rbind(captureInteraction, data.frame(ID=ll, choice = res1))
# }
