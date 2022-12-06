checkInputList <- function(inputList, mistypes = c("mnr", "mbd", "mir", "mbi")) {

  inL <- inputList
  sheetNameVec <- c("units", "subunits", "values", "unitRecodings", "savFiles", "newID", "aggrMiss", "booklets", "blocks")
  ret <- TRUE

  if(!setequal(names(inL),sheetNameVec)) {
    if(length(ab <- setdiff(sheetNameVec, names(inL))) > 0) message(paste0("Did not find sheet(s): ", paste0(ab, collapse= ", ")))
  }

  if(!is.null(inL$units) & !all(c("unit", "unitType", "unitAggregateRule") %in% colnames(inL$units))) {
    message("'units' sheet does not contain all expected columns. Expected: unit, unitType, unitAggregateRule. Found: ", paste0(names(inL$units),collapse = ", "))
  }
  if(!is.null(inL$subunits) & !all(c("unit", "subunit", "subunitRecoded") %in% colnames(inL$subunits))) {
    message("'subunits' sheet does not contain all expected columns. Expected: unit, subunit, subunitRecoded. Found: ", paste0(names(inL$subunits),collapse = ", "))
  }
  if(!is.null(inL$values) & !all(c("subunit", "value", "valueRecode", "valueType") %in% colnames(inL$values))) {
    message("'values' sheet does not contain all expected columns. Expected: subunit, value, valueRecode, valueType. Found: ", paste0(names(inL$values),collapse = ", "))
  }
  if(!is.null(inL$unitRecodings) & !all(c("unit", "value", "valueRecode") %in% colnames(inL$unitRecodings))) {
    message("'unitRecodings' sheet does not contain all expected columns. Expected: unit, value, valueRecode. Found: ", paste0(names(inL$unitRecodings),collapse = ", "))
  }
  if(!is.null(inL[["savFiles"]]) & !all(c("filename", "case.id", "fullname") %in% colnames(inL[["savFiles"]]))) {
    message("'savFiles' sheet does not contain all expected columns. Expected: filename, case.id, fullname. Found: ", paste0(names(inL$savFiles),collapse = ", "))
  }
  if(!is.null(inL$newID) & !all(c("key", "value") %in% colnames(inL$newID))) {
    message("'newID' sheet does not contain all expected columns. Expected: key, value. Found: ", paste0(names(inL$newID),collapse = ", "))
  }
  if(!is.null(inL[["aggrMiss"]]) & !all(c("vc", "mbd") %in% colnames(inL[["aggrMiss"]]))) {
    message("'aggrMiss' sheet does not contain all expected columns. Expected at least: vc, mbd. Found: ", paste0(names(inL$aggrMiss),collapse = ", "))
  }
  if(!is.null(inL[["booklets"]]) & !all(c("booklet", "block1") %in% colnames(inL[["booklets"]]))) {
    message("'booklets' sheet does not contain all expected columns. Expected: booklet, block1. Found: ", paste0(names(inL$booklets),collapse = ", "))
  }
  if(!is.null(inL[["blocks"]]) & !all(c("subunit", "block") %in% colnames(inL[["blocks"]]))) {
    message("'blocks' sheet does not contain all expected columns. Expected: subunit, block. Found: ", paste0(names(inL$blocks),collapse = ", "))
  }


  if(!setequal(inL$values$subunit, inL$values$subunit[inL$values$valueRecode == 1])) {
    message(paste0("Not all items in 'values' sheet contain at least one correct score in valueRecode: ", paste0(setdiff(inL$values$subunit, inL$values$subunit[inL$values$valueRecode == 1]), collapse=", ")))
      ret <- FALSE
  }

  if(!setequal(inL$values$subunit, inL$values$subunit[inL$values$valueRecode == 0])) {
    message(paste0("Not all items in 'values' sheet contain at least one 'false' score in valueRecode: ", paste0(setdiff(inL$values$subunit, inL$values$subunit[inL$values$valueRecode == 0]), collapse=", ")))
    ret <- FALSE
  }

  if(!is.null(mistypes)) {
    for(mm in mistypes) {
      if(setequal(inL$values$subunit, inL$values$subunit[inL$values$valueRecode == mm])) {
        message("Missing type '", mm, "' is defined for all items in valueRecode.")
      } else {
        message(paste0("Missing type '", mm, "' is not defined as valueRecode for items: ", paste0(setdiff(inL$values$subunit, inL$values$subunit[inL$values$valueRecode == mm]), collapse=", ")))
        ret <- FALSE
      }
    }
  }

  message("'value' contains the following values over all items: ", paste0(unique(inL$values$value)[order(unique(inL$values$value))], collapse = ", "))

  if(setequal(c(0,1,mistypes), unique(inL$values$valueRecode))) {
    message("'valueRecode' contains only 0, 1 and the mistypes: ", paste0(unique(inL$values$valueRecode)[order(unique(inL$values$valueRecode))], collapse = ", "))
  } else {
    message("'valueRecode' contains other values than 0, 1 and the mistypes:")
    if(length(setdiff(unique(inL$values$valueRecode), c(0,1,mistypes))) > 0) message("Other value(s): ", setdiff(unique(inL$values$valueRecode), c(0,1,mistypes)))
    ret <- FALSE
  }

  if(!setequal(unique(inL$values$valueType), c("vc",mistypes))) {
    if(length(setdiff(unique(inL$values$valueType), c("vc",mistypes))) > 0) message("Unexpected values other than 'vc' and the mistypes in 'valueType': ", setdiff(unique(inL$values$valueType), c("vc",mistypes)))
    ret <- FALSE
  }

  if(!setequal(inL$units$unit[inL$units$unitType == "TI"], inL$subunits$unit)) {
    ret <- FALSE
    if(length(setdiff(inL$units$unit[inL$units$unitType == "TI"], inL$subunits$unit)) > 0) message("More units in 'units' sheet than in 'subunits' sheet: ", setdiff(inL$units$unit[inL$units$unitType == "TI"], inL$subunits$unit))
    if(length(setdiff(inL$subunits$unit, inL$units$unit[inL$units$unitType == "TI"])) > 0) message("More units in 'subunits' sheet than in 'units' sheet: ", setdiff(inL$subunits$unit, inL$units$unit[inL$units$unitType == "TI"]))
  } else {
    message("All units in 'units' sheet are also defined in 'subunits': ", length(unique(inL$subunits$unit)))
  }

  if(!setequal(inL$values$subunit, inL$subunits$subunit)) {
    ret <- FALSE
    if(length(setdiff(inL$values$subunit, inL$subunits$subunit)) > 0) message("More units in 'subunits' sheet than in 'values' sheet: ", setdiff(inL$values$subunit, inL$subunits$subunit))
    if(length(setdiff(inL$subunits$subunit, inL$values$subunit)) > 0) message("More units in 'subunits' sheet than in 'units' sheet: ", setdiff(inL$subunits$subunit, inL$values$subunit))
  } else {
    message("All subunits in 'subunits' sheet are also defined in 'values': ", length(unique(inL$subunits$subunit)))
  }

  message("Units with only one subunit: ", sum(ifelse(table(inL$subunits$unit) == 1, 1, 0)))
  ad <- names(table(inL$subunits$unit))[table(inL$subunits$unit) > 1]
  message("Units with more than one subunit: ", sum(ifelse(table(inL$subunits$unit) > 1, 1, 0)), " (", paste0(ad, collapse=", "), ").")

  if(all(ad %in% inL$unitRecodings$unit)) {
    message("All units with more than one subunit are defined in 'unitRecodings' sheet.")
  } else {
    message("Not all units with more than one subunit are defined in 'unitRecodings' sheet: ", setdiff(ad, inL$unitRecodings$unit))
    ret <- FALSE
  }

return(ret)
}
