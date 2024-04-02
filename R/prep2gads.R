prep2GADS <- function (dat, inputList, trafoType = c("scored", "raw"),
                       misTypes = list(mvi = -95, mnr = -96, mci = -97,
                       mbd = -94, mir = -98, mbi = -99), verbose = TRUE) {

  checkmate::assert_data_frame(dat)
  checkmate::assert_list(inputList, min.len = 3)
  checkmate::assert_data_frame(inputList$units)
  checkmate::assert_data_frame(inputList$subunits)
  checkmate::assert_data_frame(inputList$values)
  checkmate::assert_list(misTypes, min.len = 1)
  checkmate::assert_character(trafoType, pattern ="^(scored|raw)$", len=1)
  checkmate::assert_logical(verbose, len=1)

  trafoType <- match.arg(trafoType)
  if(trafoType == "raw") {
    cli_abort("Sorry, raw data export isn't implemented yet")
    }

  # if(any(sapply(dat, is.factor))) stop("At least one of the variables in df is a factor. This is unusual in eatPrep and therefore handling is not implemented.")
  units <- inputList$units
  subunits <- inputList$subunits
  values <- inputList$values

  labels1 <- data.frame(varName= names(dat), varLabel= units$unitLabel[match(names(dat), units$unit)], format=NA, display_width=NA, labeled=NA)

  if(!all(names(dat) %in%  units$unit) & verbose) {
      ntoOmitDat <- length(setdiff(names(dat), units$unit))
      toOmitDat <- setdiff(names(dat), units$unit)
      cli_h3("{.strong Check:} Variables without info")
      cli_alert_info("The following {ntoOmitDat} variable{?s}
                     {?is/are} not
                     in inputList ({.field $units$unit}) but in dataset,
                     {?its/their} meta data will be set to NA:
                     {.envvar {toOmitDat}}",
                     wrap = TRUE)
    }

  # add unit names to values-df
  values$unit <- sapply(seq(along=values$subunit), function(i) unique(subunits$unit[subunits$subunit == values$subunit[i]]))

  # units with subunits
  # subs <- unique(subunits$unit[which(subunits$unit != subunits$subunit)])

  # reduce values info
  # values2$valLabel[values2$value=="0"] <- "other"
  # values2$valLabel[values2$value=="1" & values2$varName %in% subs] <- "right answer"
  if(trafoType == "scored") {
    for(uu in unique(values$unit)) {
      unitsFilter <- values$unit == uu
      unitsRecodeFilterFun <- function(x) unitsFilter & values$valueRecode == x
      unitsRelabelFun <- function(x) if(x == 0) "wrong answer (aggregated)" else "right answer (aggregated)"
      for(i in 0:1) {
        if(nrow(values[unitsRecodeFilterFun(i), ]) > 1) {
          unitsRecodeFilter <- unitsRecodeFilterFun(i)
          unitsRelabel <- unitsRelabelFun(i)
          if(!all(values$subunit[unitsFilter] == uu)) {
            values$valueLabel[unitsRecodeFilter] <- unitsRelabel
          } else {
            values$valueLabel[unitsRecodeFilter] <- paste(values$valueLabel[unitsRecodeFilter], collapse= "', or '")
          }
        }
      }
    }
    values2 <- values[!duplicated(paste0(values$unit,values$valueRecode)),]
  } else {
    values2 <- values[!duplicated(paste0(values$unit,values$value)),]
  }

  # restructure
  if(trafoType == "scored") {
    valueRecode <- values2$valueRecode
  } else {
    valueRecode <- values2$value
  }
  values3 <- data.frame(varName = values2$unit, value = valueRecode, valLabel = values2$valueLabel, missings = ifelse(grepl("^m",values2$valueType, ignore.case=TRUE), "miss", "valid"))

  labels2 <- dplyr::full_join(values3, labels1, by="varName")
  labels2 <- labels2[,c("varName", "varLabel", "format", "display_width", "labeled", "value", "valLabel", "missings")]
  labels2$labeled <- ifelse(!is.na(labels2$varLabel) | !is.na(labels2$valLabel), "yes", "no")
  suppressWarnings(labels2 <- collapseMissings(labels2, missing.rule = misTypes, standard=FALSE))

  dat2 <- collapseMissings(dat, missing.rule = misTypes, standard=FALSE)
  suppressWarnings(dat2 <- eatTools::asNumericIfPossible(dat2, force.string=FALSE))

  labels2 <- labels2[labels2$varName %in% names(dat2),]

  prepGADS <-list(dat = dat2, labels = labels2)

  return(prepGADS)
}

