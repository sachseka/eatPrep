
makeInputLists <- function (values, subunits, units, recodedData = TRUE) {

  checkedInput  <- checkInput(values, subunits, units)

  # make lists
  varinfoRaw        <- .makeVarinfoRaw(checkedInput$values, checkedInput$subunits)
  varinfoRecoded    <- .makeVarinfoRecoded(checkedInput$values, checkedInput$subunits)
  varinfoAggregated <- .makeVarinfoAggregated(checkedInput$units)
  recodeinfo        <- .makeRecodeinfo(checkedInput$values, checkedInput$subunits)
  aggregateinfo     <- .makeAggregateinfo(checkedInput$subunits, checkedInput$units, recodedData = recodedData)

  return (list(varinfoRaw = varinfoRaw, varinfoRecoded = varinfoRecoded,
            varinfoAggregated = varinfoAggregated,
            recodeinfo = recodeinfo, aggregateinfo = aggregateinfo ))
}

#-----------------------------------------------------------------------------------------
## fuer checkData benoetigte Inputs erstellen: alle Varinfos, die es gibt
## doppelte Eintraege fliegen raus

makeInputCheckData <- function (values, subunits, units) {

  checkedInput  <- checkInput(values = values, subunits = subunits, units = units)

  # make varinfo
  varinfoRaw        <- .makeVarinfoRaw(checkedInput$values, checkedInput$subunits)
  varinfoRecoded    <- .makeVarinfoRecoded(checkedInput$values, checkedInput$subunits)
  varinfoAggregated <- .makeVarinfoAggregated(checkedInput$units)

  varinfoAll <- c(varinfoRaw, varinfoRecoded, varinfoAggregated)
  if (any(duplicated(names(varinfoAll)))){
    varinfoAll <- varinfoAll [ - which(duplicated(names(varinfoAll))) ]
  }

  return(varinfoAll)
}

#-----------------------------------------------------------------------------------------
## fuer recodeData benoetigte Inputs erstellen
### ACHTUNG: HOTFIX!!!

makeInputRecodeData <- function (values, subunits) {

 nSubunits <- length(grep("subunit", colnames(subunits)))

 if (nSubunits == 0 ) {

   subunits <- subunits [ subunits$unit %in% values$unit , ]
   subunits <- data.frame ( subunit = subunits$unit, subunitLabel = subunits$unitLabel,
        subunitDescription = subunits$unitDescription, subunitType = subunits$unitType,
        subunitRecoded = subunits$unit, subunitLabelRecoded = subunits$unitLabel,
        stringsAsFactors = FALSE)

   colnames(values) [ which (colnames(values) == "unit") ] <- "subunit"

 }

  checkedInput  <- checkInput(values = values, subunits = subunits, checkUnits = FALSE)
  # make lists
  recodeinfo        <- .makeRecodeinfo(checkedInput$values, checkedInput$subunits)

  return (recodeinfo)
}

#-----------------------------------------------------------------------------------------
## fuer aggregateData benoetigte Inputs erstellen

makeInputAggregateData <- function (subunits, units, recodedData = TRUE) {
  checkedInput  <- checkInput(subunits = subunits, units = units, checkValues = FALSE)

  # make lists
  aggregateinfo     <- .makeAggregateinfo(checkedInput$subunits, checkedInput$units, recodedData = recodedData)

  return (aggregateinfo)
}

#-----------------------------------------------------------------------------------------
checkInput <- function ( values, subunits, units, checkValues = TRUE, checkUnits = TRUE ) {

  if (checkValues == FALSE & checkUnits == FALSE) {
    stop("Please specify whether values, units or both should be checked.")
  }

  # check arguments
  if (checkValues == TRUE) {
    if (missing(values)){
      stop("Missing argument: values")
    } else {
      if (class(values) != "data.frame"){
        stop("Argument values is not a data frame.")
      }
    }

    # if subunit input is missing: use default values for subitems
    if (missing(subunits)) {
      subunit  <- unique(values$subunit)
      subunitRecoded <- paste(subunit, "R", sep = "")
      subunitLabelRecoded <- paste("Recoded", subunit)
      subunits <- data.frame(unit = subunit, subunit = subunit, subunitType = "", subunitLabel = subunit,# subunitDescription = "",
                subunitPosition = "", #subunitTransniveau = "",
				subunitRecoded = subunitRecoded,
                subunitLabelRecoded = subunitLabelRecoded, stringsAsFactors = FALSE)
      cat("Found no subunits input. All subunit labels will be defaulted to subunit name.\n")
  #    stop("Missing argument: subunits")
    } else {
      if (class(subunits) != "data.frame"){
        stop("Argument subunits is not a data frame.")
      }
    }
  }

  # check subunit labels
  if (any(is.na(subunits$subunitLabel) | subunits$subunitLabel == "" )) {
   emptyLabels <- which(is.na(subunits$subunitLabel) |subunits$subunitLabel == "")
   cat("Found no subunit label for subunit(s)", emptyLabels, "\nSubunit label will be defaulted to subunit name.\n")
   subunits$subunitLabel[ emptyLabels ] <- subunits$subunit [ emptyLabels ]
  }

  if (checkUnits == TRUE) {
    # if unit input is missing: use default values for units
    if (missing(units)) {
      units <- data.frame(unit = subunits$unit, unitType = "", unitLabel = subunits$unit,
              unitDescription = subunits$subunitDescription, unitAggregateRule = "",
              unitScoreRule = "", stringsAsFactors = FALSE )
      units <- units [ !duplicated(units) , ]
      cat("Found no units input. Use unit names from subunit input. Unit labels will be defaulted to unit names.\n")
    } else {
      if (class(units) != "data.frame"){
        stop("Argument units is not a data frame.")
      }
    }
  }

 # consistency checks
  if (checkValues == TRUE) {
     checkedValuesSubunits <- .checkValuesSubunits (values, subunits)
     values   <- checkedValuesSubunits$values
     subunits <- checkedValuesSubunits$subunits
  }
  if (checkUnits == TRUE) {
    checkedSubunitsUnits  <- .checkSubunitsUnits(subunits, units)
    subunits <- checkedSubunitsUnits$subunits
    units    <- checkedSubunitsUnits$units
  }

  # make return list
  if (checkUnits == TRUE) {
    if (checkValues == TRUE ) {
      returnList <- list(values = values, subunits = subunits, units = units)
    } else {
      returnList <- list(subunits = subunits, units = units)
    }
  } else {
    if (checkValues == TRUE) {
      returnList <- list(values = values, subunits = subunits)
    }
  }


 return (returnList)
}

#-----------------------------------------------------------------------------------------

.checkValuesSubunits <- function(values, subunits) {
  # check consistency of subunit names in subunits & values
  subunitsWithoutValues <- setdiff(subunits$subunit, values$subunit)
  if (length(subunitsWithoutValues) > 0 ) {
    cat("Found no values for subunit(s)", subunitsWithoutValues,
        "\nNo varinfo and/or recodeinfo will be written for this/these subunit(s).\n")
    subunits <- subunits[ - which(subunits$subunit %in% subunitsWithoutValues) , ]
  }

  valuesWithoutSubunits <- setdiff(values$subunit, subunits$subunit)
  if (length(valuesWithoutSubunits) > 0 ) {
    cat("Found only values for subunit(s)", valuesWithoutSubunits,
        "\nSubunit label will be defaulted to subunit name for this/these subunit(s).\n")
  missingSubunits <- data.frame ( unit = valuesWithoutSubunits, subunit = valuesWithoutSubunits,
              subunitType = "", subunitLabel = valuesWithoutSubunits, subunitDescription = "",
              subunitPosition = "", #subunitTransniveau = "",
			  subunitRecoded = paste(valuesWithoutSubunits, "R", sep = ""),
              subunitLabelRecoded = paste("Recoded", valuesWithoutSubunits), stringsAsFactors = FALSE)
  subunits <- rbind(subunits, missingSubunits)
  }

  return(list(values = values, subunits = subunits))
}

#-----------------------------------------------------------------------------------------

.checkSubunitsUnits <- function(subunits, units) {
  # check consistency of unit names in units & subunits
  unitsWithoutSubunits <- setdiff(units$unit, subunits$unit)
  if (any(units[ units$unit %in% unitsWithoutSubunits, "unitType"] == "ID")){
    idName <- units [units$unitType == "ID", "unit"]
    unitsWithoutSubunits <- setdiff(unitsWithoutSubunits, idName)
  }
  if (length(unitsWithoutSubunits) > 0 ) {
    cat("Found no subunits for unit(s)", unitsWithoutSubunits, "\n")
 #       "\nNo varinfo and recodeinfo will be written for this/these unit(s).\n")
 #   units <- units[ - which(units$unit %in% unitsWithoutSubunits) , ]
  }

  SubunitsWithoutUnits <- setdiff(subunits$unit, units$unit)
  if (length(SubunitsWithoutUnits) > 0 ) {
    cat(paste("Found only subunits for unit(s)", paste(SubunitsWithoutUnits, collapse = ", "), ".\n",
        "Unit label will be defaulted to unit name for this/these unit(s). Unit type, aggregate rule and score rule will be empty.\n"))
		if("unitScoreRule" %in% colnames(units)){
 		    missingunits <- data.frame ( unit = SubunitsWithoutUnits, unitLabel = SubunitsWithoutUnits,
              unitDescription = "", unitType = "",
              unitAggregateRule = "", # unitScoreRule = "",
			  stringsAsFactors = FALSE)
		} else {
		missingunits <- data.frame ( unit = SubunitsWithoutUnits, unitLabel = SubunitsWithoutUnits,
              unitDescription = "", unitType = "",
              unitAggregateRule = "", stringsAsFactors = FALSE)
		}
  units <- rbind(units, missingunits)
  }

  return(list(subunits = subunits, units = units))
}

#-----------------------------------------------------------------------------------------

.makeVarinfoRawValues <- function(subunitName, values) {

  if ( ! subunitName %in% values$subunit ) {
    stop(paste("Found no values for subunit" , subunitName, "."))
  }

  subValues <- values [ values$subunit == subunitName , ]
  varinfoValues <- mapply(list, label = subValues$valueLabel, description = subValues$valueDescription,
                        type = subValues$valueType, SIMPLIFY=FALSE, USE.NAMES = FALSE)
  names(varinfoValues) <- subValues$value
  return(varinfoValues)
}

#-----------------------------------------------------------------------------------------

.makeVarinfoRecodedValues <- function(subunitName, values) {

  if ( ! subunitName %in% values$subunit ) {
    stop(paste("Found no values for subunit" , subunitName, "."))
  }

  subValues <- values [ values$subunit == subunitName , ]
  subValues <- subValues [ ! duplicated(subValues$valueRecode) , ]
  varinfoValues <- mapply(list, label = subValues$valueLabelRecoded, #description = subValues$valueDescriptionRecoded,
                        type = subValues$valueType, SIMPLIFY=FALSE, USE.NAMES = FALSE)
  names(varinfoValues) <- subValues$valueRecode
  return(varinfoValues)
}

#-----------------------------------------------------------------------------------------

.makeVarinfoRaw <- function(values, subunits) {
 # values: ZKD-Input-Dataframe values
 # subunits: ZKD-Input-Dataframe subunits

  # make varinfo
  varinfoValues <- mapply(.makeVarinfoRawValues, subunits$subunit, MoreArgs = list(values), SIMPLIFY=FALSE)
  varinfoList <- mapply(list, label = subunits$subunitLabel, #description = subunits$subunitDescription,
  type = subunits$subunitType, #transniveau=subunits$subunitTransniveau,
  values = varinfoValues, SIMPLIFY=FALSE, USE.NAMES = FALSE)

  names(varinfoList) <- subunits$subunit

  return(varinfoList)
}

#-----------------------------------------------------------------------------------------

.makeVarinfoRecoded <- function(values, subunits) {
 # values: ZKD-Input-Dataframe values
 # subunits: ZKD-Input-Dataframe subunits

  # make varinfo
  varinfoValues <- mapply(.makeVarinfoRecodedValues, subunits$subunit, MoreArgs = list(values), SIMPLIFY=FALSE)
  varinfoList <- mapply(list, label = subunits$subunitLabelRecoded,# description = subunits$subunitDescriptionRecoded,
  type = subunits$subunitType, values = varinfoValues, SIMPLIFY=FALSE, USE.NAMES = FALSE)

  names(varinfoList) <- subunits$subunitRecoded

  return(varinfoList)
}

#-----------------------------------------------------------------------------------------

.makeVarinfoAggregated <- function(units) {

  # make varinfo
 # varinfoValues <- mapply(.makeVarinfoRecodedValues, subunits$subunit, MoreArgs = list(values), SIMPLIFY=FALSE)
  varinfoList <- mapply(list, label = units$unitLabel, description = units$unitDescription,
  type = units$unitType, # values = varinfoValues,
  SIMPLIFY=FALSE, USE.NAMES = FALSE)

  names(varinfoList) <- units$unit

  return(varinfoList)
}

#-----------------------------------------------------------------------------------------

.makeRecodeinfoValues <- function(subunitName, values) {

  if ( ! subunitName %in% values$subunit ) {
    stop(paste("Found no values for subunit" , subunitName, "."))
  }
  subValues <- values [ values$subunit == subunitName , ]
  recodeinfoValues <- as.list(subValues$valueRecode)
  names(recodeinfoValues) <- subValues$value
  return(recodeinfoValues)
}

#-----------------------------------------------------------------------------------------

.makeRecodeinfo <- function(values, subunits) {
 # values: ZKD-Input-Dataframe values
 # subunits: ZKD-Input-Dataframe subunits

 # make recodeinfo
  recodeinfoValues <- mapply(.makeRecodeinfoValues, subunits$subunit, MoreArgs = list(values), SIMPLIFY=FALSE)
  recodeinfoList   <- mapply(list, label = subunits$subunitLabelRecoded, newID = subunits$subunitRecoded,
     values = recodeinfoValues, SIMPLIFY=FALSE, USE.NAMES = FALSE)
  names(recodeinfoList) <- subunits$subunit

  return(recodeinfoList)
}

#-----------------------------------------------------------------------------------------
.makeAggregateinfo <- function (subunits, units, recodedData = TRUE) {

  # welche units bestehen aus mehr als einem Subunit?
  aggregateunits <- unique ( names(table(subunits$unit))[ table(subunits$unit) > 1] )
  if (recodedData == TRUE){
    aggregateSubunits <- lapply( aggregateunits, function(ll) { subunits$subunitRecoded [subunits$unit == ll ] } )
  } else {
    aggregateSubunits <- lapply( aggregateunits, function(ll) { subunits$subunit [subunits$unit == ll ] } )
  }
  arule <- units$unitAggregateRule [ match(aggregateunits, units$unit) ]
#  srule <- units$unitScoreRule [ match(aggregateunits, units$unit) ]

  # aggregateinfo erstellen
  aggregateinfo <- mapply(list, arule = arule, #srule = srule,
			subunits=aggregateSubunits, SIMPLIFY=FALSE, USE.NAMES=FALSE)
  names(aggregateinfo) <- aggregateunits
  return(aggregateinfo)
}

