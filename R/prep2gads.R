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

  # if(any(sapply(dat, is.factor))) stop("At least one of the variables in df is a factor. This is unusual in eatPrep and therefore handling is not implemented.")
  units <- inputList$units
  subunits <- inputList$subunits
  values <- inputList$values

  if(trafoType == "raw") {

    if(any(dat[!is.na(dat)] == "mbd")) {
      mbdRec <- "mbd"
      if(!any(unique(values$value) %in% "mbd")) { # if values$value contains 'mbd' occurence is not judged as unintended
        if(any(values$valueRecode == "mbd")) { #specification in values-sheet is prioritized over setting in misTypes
          if(length(unique(values$value[values$valueRecode == "mbd"])) ==1) {
            mbdRec <- unique(values$value[values$valueRecode == "mbd"])
            dat[dat == "mbd"] <- mbdRec
          }
        } else {
          if("mbd" %in% names(misTypes)) {
            mbdRec <- misTypes[["mbd"]]
            dat[dat == "mbd"] <- mbdRec
          } else {
            cli_alert_info("Data contains 'mbd' but no clear backtransformation raw value could be identified (please specify via misTypes). Thus 'mbd' will be kept as string.", wrap = TRUE)
          }
        }
       }
      }

    labels1 <- data.frame(varName = names(dat),
                          varLabel = subunits$subunitLabel[match(names(dat), subunits$subunit)],
                          format = NA, display_width = NA, labeled = NA)
    varInfoInUnit <- match(setdiff(units$unit, subunits$subunit), names(dat))
    if(any(!is.na(varInfoInUnit))) {
      for(i in na.omit(varInfoInUnit)) {
         labels1[labels1$varName==names(dat)[i],] <- c(names(dat)[i],
                                                       varLabel = units$unitLabel[match(names(dat)[i], units$unit)],
                                                       format = NA, display_width = NA, labeled = NA)
      }
    }

    if(!all(names(dat) %in%  c(subunits$subunit, units$unit)) & verbose) {
      toOmitDat <- setdiff(names(dat), c(subunits$subunit, units$unit))
      ntoOmitDat <- length(toOmitDat)
      cli_h3("{.strong Check:} Variables without info")
      cli_alert_info("The following {ntoOmitDat} variable{?s}
                     {?is/are} not
                     in inputList ({.field $subunits$subunit} or {.field $units$unit}) but in dataset,
                     {?its/their} meta data will be set to NA:
                     {.envvar {toOmitDat}}",
                     wrap = TRUE)
    }

    # create values2, 3 and valueRecode

    values2 <- values[!duplicated(paste0(values$subunit,values$value)),]

    values3 <- data.frame(varName = values2$subunit,
                          value = values2$value,
                          valLabel = values2$valueLabel,
                          missings = ifelse(grepl("^m",values2$valueType, ignore.case=TRUE), "miss", "valid"))

    dat2 <- dat

    } else {

      labels1 <- data.frame(varName= names(dat),
                            varLabel= units$unitLabel[match(names(dat), units$unit)],
                            format=NA, display_width=NA, labeled=NA)
      if(!all(names(dat) %in%  units$unit) & verbose) {
        toOmitDat <- setdiff(names(dat), units$unit)
        ntoOmitDat <- length(toOmitDat)
        cli_h3("{.strong Check:} Variables without info")
        cli_alert_info("The following {ntoOmitDat} variable{?s}
                     {?is/are} not
                     in inputList ({.field $units$unit}) but in dataset,
                     {?its/their} meta data will be set to NA:
                     {.envvar {toOmitDat}}",
                     wrap = TRUE)
      }

      values$unit <- sapply(seq(along=values$subunit), function(i) unique(subunits$unit[subunits$subunit == values$subunit[i]]))

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

      values3 <- data.frame(varName = values2$unit,
                            value = values2$valueRecode,
                            valLabel = values2$valueLabel,
                            missings = ifelse(grepl("^m",values2$valueType, ignore.case=TRUE), "miss", "valid"))

      dat2 <- collapseMissings(dat, missing.rule = misTypes, standard=FALSE)

    }


  labels2 <- dplyr::full_join(values3, labels1, by="varName")
  labels2 <- labels2[,c("varName", "varLabel", "format", "display_width", "labeled", "value", "valLabel", "missings")]
  labels2$labeled <- ifelse(!is.na(labels2$varLabel) | !is.na(labels2$valLabel), "yes", "no")

  if(trafoType=="scored") {
    suppressWarnings(labels2 <- collapseMissings(labels2, missing.rule = misTypes, standard=FALSE))
  }

  suppressWarnings(dat2 <- eatTools::asNumericIfPossible(dat2, force.string=FALSE))

  labels2 <- labels2[labels2$varName %in% names(dat2),]

  GADSobj <- eatGADS::import_raw2(dat = dat2, labels = labels2)

  return(GADSobj)
}

