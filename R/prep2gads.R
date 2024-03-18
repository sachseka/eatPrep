prep2gads <- function (dat, inputList, verbose = TRUE) {

  checkmate::assert_data_frame(dat)
  checkmate::assert_list(inputList, min.len = 3)
  checkmate::assert_data_frame(inputList$units)
  checkmate::assert_data_frame(inputList$subunits)
  checkmate::assert_data_frame(inputList$values)

  # if(any(sapply(dat, is.factor))) stop("At least one of the variables in df is a factor. This is unusual in eatPrep and therefore handling is not implemented.")
  units <- inputList$units
  subunits <- inputList$subunits
  values <- inputList$values

  if(all(names(dat) %in%  units$unit)) {
    labels1 <- data.frame(varName= names(dat), varLabel= units$unitLabel[match(names(dat), units$unit)], format=NA, display_width=NA, labeled=NA)
  } else {
    if(verbose) {
      ntoOmitDat <- length(setdiff(names(dat), units$unit))
      toOmitDat <- setdiff(names(dat), units$unit)
      cli_h3("{.strong Check:} Variables without info")
      cli_alert_info("The following {ntoOmitDat} variable{?s}
                     {?is/are} not in units ({.envvar units}
                     in {.field unit}) but in dataset.
                     {?Its/Their} meta data will be set to NA:
                     {.envvar {toOmitDat}}",
                     wrap = TRUE)
    }
  }

  # add unit names to values-df
  values$unit <- sapply(seq(along=values$subunit), function(i) unique(subunits$unit[subunits$subunit == values$subunit[i]]))

  subs <- unique(subunits$unit[which(subunits$unit != subunits$subunit)])

  values2 <- values[!duplicated(paste0(values$subunit,values$valueRecode)),]
  values2 <- data.frame(varName=values2$subunit, value=values2$valueRecode, valLabel=values2$valueLabel, missings=ifelse(grepl("^m",values2$valueType),"miss","valid"))
  values2$valLabel[values2$value=="0"] <- "other"
  values2$valLabel[values2$value=="1" & values2$varName %in% subs] <- "right answer"


  labels2 <- dplyr::full_join(labels1, values2, by="varName")

  prepGADS <- new_GADSdat(dat = dat, labels = labels2)

  return(prepGADS)
}


# re-use some internal eatGADS-Checks
new_GADSdat <- function(dat, labels) {
  stopifnot(is.data.frame(dat) && is.data.frame(labels))
  structure(list(dat = dat, labels = labels), class = c("GADSdat", "list"))
}
# GADSdat validator (allow data_table column for trend compatibility)
check_GADSdat <- function(GADSdat) {
  if(!"GADSdat" %in% class(GADSdat)) stop("All input objects have to be of class GADSdat", call. = FALSE)
  if(!is.list(GADSdat) && length(GADSdat) == 2) stop("GADSdat has to be a list with length two", call. = FALSE)
  if(!identical(names(GADSdat), c("dat", "labels"))) stop("List elements of a GADSdat object have to be 'dat' and 'labels'", call. = FALSE)
  if(!is.data.frame(GADSdat$dat)) stop("dat element has to be a data frame", call. = FALSE)
  if(tibble::is_tibble(GADSdat$dat)) stop("dat element has to be a data frame and can not be a tibble.", call. = FALSE)
  if(!is.data.frame(GADSdat$labels)) stop("labels element has to be a data frame", call. = FALSE)
  if(!(identical(names(GADSdat$labels), c("varName", "varLabel", "format", "display_width", "labeled", "value", "valLabel", "missings")) ||
       identical(names(GADSdat$labels), c("varName", "varLabel", "format", "display_width", "labeled", "value", "valLabel", "missings", "data_table")))) {
    stop("Illegal column names in labels data frame.")
  }

  # internals
  only_in_labels <- setdiff(unique(GADSdat$labels$varName), names(GADSdat$dat))
  only_in_dat <- setdiff(names(GADSdat$dat), unique(GADSdat$labels$varName))
  if(length(only_in_labels) > 0) stop("The following variables have meta data but are not in the actual data: ", only_in_labels, call. = FALSE)
  if(length(only_in_dat) > 0) stop("The following variables are in the data but do not have meta data: ", only_in_dat, call. = FALSE)

  if(!is.numeric(GADSdat$labels$value)) stop("Column 'value' in the meta data is not numeric.")

  unlabeled_labels <- GADSdat$labels[GADSdat$labels$labeled == "no", ]
  if(nrow(unlabeled_labels) > 0) {
    by(unlabeled_labels, unlabeled_labels$varName, function(labels) {
      if(any(!is.na(labels$value))) stop("The following variable has value labels but is not marked as labeled: ", unique(labels$varName))
      if(any(!is.na(labels$valLabel))) stop("The following variable has value labels but is not marked as labeled: ", unique(labels$varName))
    })
  }

}

check_GADSdat_varLevel_meta <- function(GADSdat) {
  # maybe later remove these tests due to performance?
  by(GADSdat$labels, GADSdat$labels$varName, function(labels) {
    if(any(duplicated(labels$value[!is.na(labels$value)]))) {
      stop("The following variable has duplicate values rows in its meta data: ", labels$varName[1])
    }
    unique_lengthes <- length(unique(labels$varLabel)) + length(unique(labels$format)) + length(unique(labels$labeled))
    if(unique_lengthes != 3) {
      stop("The following variable has inconsistent meta information on variable level: ", labels$varName[1])
    }

  })
}
