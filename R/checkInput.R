
#' Title
#'
#' @param values
#' @param subunits
#'
#' @return
#' @export
#'
#' @examples
#'
#'

checkValuesSubunits <- function(values, subunits) {
  if (!inherits(values, "data.frame"))  stop("values must be a data frame.")
  if (!inherits(subunits, "data.frame")) stop("subunits must be a data frame.")

  # make unitrecodings and units adhere to naming conventions
  nSubunits <- length(grep("subunit", colnames(subunits)))
  if (nSubunits == 0 ) {
    subunits <- subunits [ subunits$unit %in% values$unit , ]
    subunits <- data.frame ( subunit = subunits$unit, subunitRecoded = subunits$unit, stringsAsFactors = FALSE)
    colnames(values) [ which (colnames(values) == "unit") ] <- "subunit"
  }

  if (any( ! c("value", "valueRecode") %in% colnames(values))) stop("values needs to respect naming conventions. See help(inputList) for details.")
  if (! "subunit" %in% colnames(subunits)) stop("subunits needs to respect naming conventions. See help(inputList) for details.")

  subunitsWithoutValues <- setdiff(subunits$subunit, values$subunit)
  if (length(subunitsWithoutValues) > 0 ) {
    message("Found no values for subunit(s) ", paste(subunitsWithoutValues, collapse = ", "),  ".",
        "\nThis/these subunit(s) will be removed from input.")
    subunits <- subunits[ - which(subunits$subunit %in% subunitsWithoutValues) , ]
  }

  valuesWithoutSubunits <- setdiff(values$subunit, subunits$subunit)
  if (length(valuesWithoutSubunits) > 0 ) {
    message("Found only values for subunit(s) ", paste(valuesWithoutSubunits, collapse = ", "),  ".",
        "\nThis/these subunit(s) will be appended to subunits sheet.")
    missingSubunits <- data.frame(unit = valuesWithoutSubunits, subunit = valuesWithoutSubunits,
                                    subunitRecoded = paste(valuesWithoutSubunits, "R", sep = ""),
                                    stringsAsFactors = FALSE)

    subunits <- dplyr::add_row(subunits, missingSubunits)
  }

  return(list(values = values, subunits = subunits))
}



#' Title
#'
#' @param subunits
#' @param units
#'
#' @return
#' @export
#'
#' @examples


checkSubunitsUnits <- function(subunits, units) {

  if (!inherits(subunits, "data.frame")) stop("subunits must be a data frame.")
  if (any( ! c("unit", "subunit") %in% colnames(subunits))) stop("subunits needs to respect naming conventions. See help(inputList) for details.")
  if (!inherits(units, "data.frame")) stop("units must be a data frame.")


    # check consistency of unit names in units & subunits
  unitsWithoutSubunits <- setdiff(units$unit, subunits$unit)
  if (any(units[ units$unit %in% unitsWithoutSubunits, "unitType"] == "ID")){
    idName <- units [units$unitType == "ID", "unit"]
    unitsWithoutSubunits <- setdiff(unitsWithoutSubunits, idName)
  }
  if (length(unitsWithoutSubunits) > 0 ) {
    message("Found no subunits for unit(s) ", paste(unitsWithoutSubunits, collapse = ", "), ".",
           "\nThis/these unit(s) will be removed from input.")
    units <- units[ - which(units$unit %in% unitsWithoutSubunits) , ]
  }

  SubunitsWithoutUnits <- setdiff(subunits$unit, units$unit)
  if (length(SubunitsWithoutUnits) > 0 ) {
    message("Found only subunits for unit(s) ", paste(SubunitsWithoutUnits, collapse = ", "), ".",
           "\nThis/these unit(s) will be appended to units sheet.")
    missingunits <- data.frame ( unit = SubunitsWithoutUnits, unitAggregateRule = "", stringsAsFactors = F)
    units <- dplyr::add_row(units, missingunits)
  }

  return(list(subunits = subunits, units = units))
}
