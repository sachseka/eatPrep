
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

  if (class(values) != "data.frame")  stop("Argument values is not a data frame.")
  if (class(subunits) != "data.frame") stop("Argument subunits is not a data frame.")

  subunitsWithoutValues <- setdiff(subunits$subunit, values$subunit)
  if (length(subunitsWithoutValues) > 0 ) {
    cat("Found no values for subunit(s)", subunitsWithoutValues,
        "\nThis/these subunit(s) will be removed from input.\n")
    subunits <- subunits[ - which(subunits$subunit %in% subunitsWithoutValues) , ]
  }

  valuesWithoutSubunits <- setdiff(values$subunit, subunits$subunit)
  if (length(valuesWithoutSubunits) > 0 ) {
    cat("Found only values for subunit(s)", valuesWithoutSubunits,  ".",
        "\nThis/these subunits(s) will be appended to subunits sheet.\n")
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

  if (class(subunits) != "data.frame") stop("Argument subunits is not a data frame.")
  if (class(units) != "data.frame") stop("Argument units is not a data frame.")


    # check consistency of unit names in units & subunits
  unitsWithoutSubunits <- setdiff(units$unit, subunits$unit)
  if (any(units[ units$unit %in% unitsWithoutSubunits, "unitType"] == "ID")){
    idName <- units [units$unitType == "ID", "unit"]
    unitsWithoutSubunits <- setdiff(unitsWithoutSubunits, idName)
  }
  if (length(unitsWithoutSubunits) > 0 ) {
    cat("Found no subunits for unit(s)", unitsWithoutSubunits,
           "\nThis/these unit(s) will be removed from input.\n")
    units <- units[ - which(units$unit %in% unitsWithoutSubunits) , ]
  }

  SubunitsWithoutUnits <- setdiff(subunits$unit, units$unit)
  if (length(SubunitsWithoutUnits) > 0 ) {
    cat(paste("Found only subunits for unit(s)", paste(SubunitsWithoutUnits, collapse = ", "), ".",
           "\nThis/these unit(s) will be appended to units sheet.\n"))
    missingunits <- data.frame ( unit = SubunitsWithoutUnits, unitLabel = SubunitsWithoutUnits, stringsAsFactors = F)
    units <- dplyr::add_row(units, missingunits)
  }

  return(list(subunits = subunits, units = units))
}
