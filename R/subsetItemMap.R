# Keep the design identifier, aggregation target and response column separate.
.subset_item_mapper <- function(dat, subunits, ID, classID, dataLevel) {
  if (dataLevel == "unit" && is.null(subunits)) {
    stop("dataLevel = 'unit' requires subunits with columns subunit and unit.", call. = FALSE)
  }
  if (!is.null(subunits)) {
    required <- c("subunit", if (dataLevel == "unit") "unit")
    subunits <- .subset_table(subunits, "subunit", "subunits")
    absent <- setdiff(required, names(subunits))
    if (length(absent)) stop("subunits needs columns: ", paste(absent, collapse = ", "), ".", call. = FALSE)
    .subset_unique_key(subunits, "subunit", "subunits")
    for (column in c("subunitRecoded", "unit")) {
      if (!column %in% names(subunits)) subunits[[column]] <- NA_character_
      if (!is.atomic(subunits[[column]]) || is.matrix(subunits[[column]])) {
        stop("subunits$", column, " must be a vector.", call. = FALSE)
      }
      subunits[[column]] <- .population_identifier_labels_idm(subunits[[column]])
      blank <- !is.na(subunits[[column]]) & !nzchar(trimws(subunits[[column]]))
      subunits[[column]][blank] <- NA_character_
    }
  }
  columns <- setdiff(names(dat), c(ID, classID))
  unit_sizes <- if (dataLevel == "unit") table(subunits$unit) else NULL
  map <- function(ids) {
    index <- if (is.null(subunits)) rep(NA_integer_, length(ids)) else match(ids, subunits$subunit)
    recoded <- if (is.null(subunits)) rep(NA_character_, length(ids)) else subunits$subunitRecoded[index]
    units <- if (is.null(subunits)) rep(NA_character_, length(ids)) else subunits$unit[index]
    out <- data.frame(subunit = ids, subunitRecoded = recoded, unit = units,
                      item = if (dataLevel == "unit") units else ids,
                      datCols = NA_character_, itemStatus = NA_character_,
                      mappingIssue = NA_character_, stringsAsFactors = FALSE)
    for (j in seq_along(ids)) {
      if (dataLevel == "unit" && is.na(units[j])) {
        out$itemStatus[j] <- "unmapped"
        out$mappingIssue[j] <- if (is.na(index[j])) "subunit_not_listed" else "unit_not_assigned"
        next
      }
      candidates <- if (dataLevel == "unit") units[j] else c(ids[j], recoded[j])
      # aggregateData(rename = FALSE) retains subunit names for one-subunit
      # units. A single component must never stand in for an aggregated unit.
      if (dataLevel == "unit" && !units[j] %in% columns &&
          unit_sizes[units[j]] == 1L) {
        candidates <- c(candidates, ids[j], recoded[j])
      }
      found <- intersect(unique(candidates[!is.na(candidates)]), columns)
      out$itemStatus[j] <- if (!length(found)) "missing" else if (length(found) > 1L) "ambiguous" else "matched"
      if (length(found) == 1L) out$datCols[j] <- found
    }
    out
  }
  list(map = map, subunits = subunits)
}

.subset_item_problem <- function(row, dataLevel) {
  metadata <- as.list(row[c("subunit", "subunitRecoded", "unit", "item", "datCols", "itemStatus", "mappingIssue", "booklet", "block")])
  if (row$itemStatus == "unmapped") {
    code <- "missing_unit_mapping"
    message <- if (row$mappingIssue == "subunit_not_listed") {
      sprintf("Subunit '%s' is not listed in subunits$subunit.", row$subunit)
    } else sprintf("Subunit '%s' has an empty unit assignment in subunits$unit.", row$subunit)
  } else {
    code <- "unresolved_item"
    label <- if (dataLevel == "unit") "Unit" else "Subunit"
    message <- sprintf("%s '%s' must resolve to exactly one column in dat (%s).", label, row$item,
                       if (row$itemStatus == "missing") "no column found" else "multiple columns found")
  }
  do.call(errorCondition, c(list(message = message, class = "subsetResolutionError", code = code), metadata))
}
