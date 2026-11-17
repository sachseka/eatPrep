# Restrict design validation to the people and positions actually requested.
# Keep all members of selected units, since single-subunit aliases depend on
# their full membership even when only one component is reported.
.subset_incident_scope <- function(dat, persons, classes, positions, booklets,
                                    blocks, rotation, subunits, ID, classID) {
  key_values <- function(x, key, label) {
    checkmate::assert_data_frame(x, .var.name = label)
    if (!key %in% names(x)) stop(label, " needs columns: ", key, ".", call. = FALSE)
    if (!is.atomic(x[[key]]) || is.matrix(x[[key]])) stop(label, "$", key, " must be a vector.", call. = FALSE)
    .population_identifier_labels_idm(x[[key]])
  }
  members <- lapply(seq_along(persons), function(i) {
    if (!is.na(persons[i])) return(intersect(persons[i], dat[[ID]]))
    if (is.null(classID) || is.na(classes[i])) return(character())
    dat[[ID]][dat[[classID]] == classes[i]]
  })
  rotation_ids <- key_values(rotation, ID, "rotation")
  rotation <- as.data.frame(rotation)[rotation_ids %in% unlist(members, use.names = FALSE), , drop = FALSE]
  rotation_booklets <- key_values(rotation, "booklet", "rotation")
  booklet_ids <- key_values(booklets, "booklet", "booklets")
  booklets <- as.data.frame(booklets)[booklet_ids %in% rotation_booklets, , drop = FALSE]
  booklet_ids <- key_values(booklets, "booklet", "booklets")
  block_columns <- grep("^block[0-9]+$", names(booklets), value = TRUE)
  column_positions <- suppressWarnings(as.numeric(sub("^block", "", block_columns)))
  relevant_columns <- block_columns[column_positions %in% positions]
  needed_blocks <- character()
  for (i in seq_along(persons)) {
    column <- block_columns[which(column_positions == positions[i])]
    if (!length(column) || !length(members[[i]])) next
    assigned <- rotation_booklets[key_values(rotation, ID, "rotation") %in% members[[i]]]
    values <- unlist(booklets[booklet_ids %in% assigned, column, drop = FALSE], use.names = FALSE)
    needed_blocks <- c(needed_blocks, .population_identifier_labels_idm(values))
  }
  # Keep a usable schema when an incident requests an unavailable position.
  if (length(relevant_columns)) booklets <- booklets[c("booklet", relevant_columns)]
  block_ids <- key_values(blocks, "block", "blocks")
  blocks <- as.data.frame(blocks)[block_ids %in% needed_blocks, , drop = FALSE]
  needed_subunits <- key_values(blocks, "subunit", "blocks")
  if (!is.null(subunits)) {
    subunit_ids <- key_values(subunits, "subunit", "subunits")
    keep <- subunit_ids %in% needed_subunits
    if ("unit" %in% names(subunits)) {
      units <- key_values(subunits, "unit", "subunits")
      selected_units <- units[keep & !is.na(units) & nzchar(trimws(units))]
      keep <- keep | units %in% selected_units
    }
    subunits <- as.data.frame(subunits)[keep, , drop = FALSE]
  }
  list(booklets = booklets, blocks = blocks, rotation = rotation, subunits = subunits)
}
