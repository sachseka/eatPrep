makeInputAggregateData <- function (subunits, units, recodedData = TRUE) {

  checkedInput <- checkSubunitsUnits(subunits, units)
  aggregateunits <- unique ( names(table(subunits$unit))[ table(subunits$unit) > 1] )
  if(length(aggregateunits) == 0) stop("No units to aggregate in input.")
  if (recodedData == TRUE){
    aggregateSubunits <- lapply( aggregateunits, function(ll) { subunits$subunitRecoded [subunits$unit == ll ] } )
  } else {
    aggregateSubunits <- lapply( aggregateunits, function(ll) { subunits$subunit [subunits$unit == ll ] } )
  }
  arule <- units$unitAggregateRule [ match(aggregateunits, units$unit) ]
  aggregateinfo <- mapply(list, arule = arule,
                          subunits=aggregateSubunits, SIMPLIFY=FALSE, USE.NAMES=FALSE)
  names(aggregateinfo) <- aggregateunits

  return (aggregateinfo)
}



aggregateData <- function (dat, subunits, units, aggregatemissings = NULL, rename = FALSE,
                        recodedData = TRUE, suppressErr = FALSE, recodeErr = "mci", verbose = FALSE) {

  if (!is.data.frame(dat)) stop ("'dat' must be a data.frame.")

  if(suppressErr == TRUE){
    if(length(recodeErr) != 1){
      message("recodeErr does not have a length of 1. err will be recoded to 'mci'.")
      recodeErr <- "mci"
    }
  }

  # define missing aggregation
  if ((is.null(aggregatemissings)|is.data.frame(aggregatemissings)|is.matrix(aggregatemissings)) == FALSE){
    stop("aggregatemissings is neither NULL nor a matrix nor a data.frame.")
  }

  if ( is.null(aggregatemissings)) {
    am <- matrix(c(
      "vc" , "mvi", "vc" , "mci", "err", "vc" , "vc" , "err",
      "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
      "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
      "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
      "err", "err", "err", "err", "mbd", "err", "err", "err",
      "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
      "vc" , "err", "mnr", "mci", "err", "mir", "mbi", "err",
      "err", "err", "err", "err", "err", "err", "err", "err" ),
      nrow = 8, ncol = 8, byrow = TRUE)

    dimnames(am) <-
      list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
           c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))
  }

  if(is.data.frame(aggregatemissings)) {
    am <- as.matrix(aggregatemissings[-1])
    dimnames(am) <- list(aggregatemissings[, 1], colnames(aggregatemissings)[-1])
  }

  if(is.matrix(aggregatemissings)){
    am <- aggregatemissings
  }

  if(!isSymmetric(am)){
    stop("Matrix used for missing aggregation is not symmetrical.")
  }

  # add recode values for err: always recode combinations with err to err
  am <- cbind(am, err = "err") ;  am <- rbind(am, err = "err")

  # check aggregatemissings against standard codes
  standard_codes <- c("vc", "mvi", "mnr", "mci", "mbd", "mir", "mbi", "err")
  am_codes <- unique(c(unlist(dimnames(am)), unlist(am)))

  if (any(am_codes %in% standard_codes == FALSE)) {
    stop("Found nonstandard missing value code(s) in 'aggregatemissings':", paste(setdiff(am_codes, standard_codes), collapse = ", "), ". Only the following codes are supported:", paste(standard_codes, collapse = ", "))
  }
  if (any(standard_codes %in% am_codes == FALSE)) {
    warning("Standard missing code(s)", paste(setdiff(standard_codes, am_codes), collapse = ", "), "are not specified in  'aggregatemissings'. Please check whether this is desired.")
  }

  # make aggregateinfo
  aggregateinfo <- makeInputAggregateData(subunits, units, recodedData = recodedData)
  nSubunitsInDat <- lapply(lapply(aggregateinfo, "[[", "subunits"), function(ll) { sum( ll %in% colnames(dat)) })
  aggregateinfo <- aggregateinfo[ which(nSubunitsInDat > 0) ]

  if (length(aggregateinfo) == 0)	stop("Found none of the specified subitems to aggregate in dataset.")

  # which subunits should be aggregated?
  unitsToAggregate    <- names(aggregateinfo)
  subunitsToAggregate <- unname(unlist(lapply(aggregateinfo, "[[", "subunits")))
  subunitsToKeep      <- setdiff(colnames(dat), subunitsToAggregate)

  # initialize aggregated dataset with subunits to keep
  datAggregated <- dat[ , subunitsToKeep ]

  # check data against standard codes
  data_codes <- unique(gsub("[[:digit:]]", "vc", unlist(dat[ , subunitsToAggregate])))

  if (any(data_codes %in% standard_codes == FALSE)) {
    stop("Found nonstandard missing value code(s) in 'dat':", paste(setdiff(data_codes, standard_codes), collapse = ", "), ". Only the following codes are supported:", paste(standard_codes[-length(standard_codes)], collapse = ", "))
  }

  if (rename == TRUE) {
  	if (recodedData == TRUE) {
  		oneSubunitUnits <- subunits[subunits$subunitRecoded %in% subunitsToKeep, c("unit", "subunitRecoded")]
  		oneSubunitUnits <- oneSubunitUnits [na.omit(match(colnames(dat), oneSubunitUnits$subunitRecoded)), ]
  		colnames(datAggregated)[ match(oneSubunitUnits$subunitRecoded, colnames(datAggregated) )] <- oneSubunitUnits$unit
  	} else {
  		oneSubunitUnits <- subunits[subunits$subunit %in% subunitsToKeep, c("unit", "subunit")]
  		oneSubunitUnits <- oneSubunitUnits [na.omit(match(colnames(dat), oneSubunitUnits$subunit)), ]
  		colnames(datAggregated)[ match(oneSubunitUnits$subunit, colnames(datAggregated) )] <- oneSubunitUnits$unit
  	}

	  if(verbose){message(paste0("Found ", nrow(oneSubunitUnits), " unit(s) with only one subunit in 'dat'. This/these subunit(s) will be renamed to their respective unit name(s).\nUnits ",
                              paste(oneSubunitUnits$unit, collapse = ", ")))  }
  }

  # aggregate units
  unitsAggregated <- mapply(aggregateData.aggregate, unitsToAggregate, aggregateinfo,
                            MoreArgs = list(am, dat, verbose = verbose, suppressErr = suppressErr, recodeErr = recodeErr), SIMPLIFY = T)

 if(!missing(unitsAggregated)){
	datAggregated <- cbind(datAggregated, unitsAggregated, stringsAsFactors = FALSE)
  }

  return(datAggregated)
}

#-----------------------------------------------------------------------------------------------------------
# aggregate columns of a data frame according to aggregation rule

aggregateData.aggregate <- function(unitName, aggregateinfo, aggregatemissings, dat,
                                    verbose = FALSE, suppressErr = suppressErr, recodeErr = recodeErr){

  aggRule <- toupper(aggregateinfo$arule)

  if( !exists ("aggRule") | is.na(aggRule) | nchar(aggRule) == 0) {
		aggRule <- "SUM"
		if(verbose) message("Missing aggregation rule for unit " , unitName , " defaulted to SUM.")
  }

#  if(!is.character(aggRule) ) {
#		aggRule <- "SUM"
#		warning(paste0("Unknown agregation rule for unit " , unitName , " defaulted to SUM.\n"))
#  }

  if ( !aggRule %in% c("SUM") ) {
		warning("Aggregation rule (\"" , aggRule , "\") for unit ", unitName , " is currently not supported. Changed aggregation rule to SUM.")
    aggRule <- "SUM"
  }

    unitVars <- aggregateinfo$subunits


  if(verbose) message("Aggregate unit ", unitName, ".")
  if (any((unitVars %in% colnames(dat)) == FALSE)) {
  	stop("Subunits", paste(setdiff(unitVars, colnames(dat)), collapse = ", "), "not in 'dat'.")
  }

  unitDat        <- dat[ , unitVars]

  # rename NA to mbd
  if (any(is.na(unitDat))) {
      message("Data contains NA values. These values will be converted to 'mbd'.")
	    unitDat[ is.na(unitDat) ] <- "mbd"
  }

  agg <- .makeMissingind(unitDat, aggregatemissings)
  unitAggregated <- unname(agg)

  if(any(agg == "err"))  {
    message("Aggregation of missing values for unit ", unitName, " produced 'err' for row(s) ",
                   paste(which(agg == "err"), collapse = ", "))
    if (suppressErr == TRUE) {
      message("'err' in unit ", unitName, " will be recoded to 'mci'.")
      unitAggregated[unitAggregated == "err"] <- recodeErr
    }
  }


  options(warn = -1)

  unitDat.vc <- unitDat[ unitAggregated == "vc", , drop = FALSE ]
  if ( nrow ( unitDat.vc ) > 0 ) {
	  if( aggRule == "SUM" ) {
			unitAggregated[unitAggregated == "vc"] <- as.character(rowSums(apply(unitDat.vc, 2, as.numeric), na.rm = TRUE))
	  }

	  if( aggRule == "MEAN" ) {
			unitAggregated[unitAggregated == "vc"] <- as.character(rowMeans(apply(unitDat.vc, 2, as.numeric), na.rm = TRUE))
	  }
  }

  options(warn = 0)
  return(unitAggregated)
}

#-----------------------------------------------------------------------------------------------------------
# aggregates missings and valid codes of multiple columns in a dataset according to argument aggregatemissings

.makeMissingind <- function ( dat, aggregatemissings ) {
  dat <- data.frame(apply(dat, 2, function (ll) {gsub("[[:digit:]]", "vc", ll)}), stringsAsFactors = FALSE)
  agg <- dat [ , 1]

  for (i in seq(along = dat)) {
    agg <- .aggmiss(dat [ , i] , agg, aggregatemissings)
  }
  return(agg)
}

#-----------------------------------------------------------------------------------------------------------
# aggregates a column with a previously aggregated column according to argument aggregatemissings

.aggmiss <- function ( variable, aggregatedVariable, aggregatemissings) {
  aggregatedVariable <- mapply( function (variable, aggregatedVariable){
    x <- aggregatemissings[ match(aggregatedVariable, rownames(aggregatemissings)) , match(variable, colnames(aggregatemissings))]
    return(x)
  }, variable, aggregatedVariable)
  return (aggregatedVariable)
}

