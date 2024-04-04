collapseMissings <- function(dat, missing.rule = list(mvi = 0, mnr = 0, mci = NA,
                                                      mbd = NA, mir = 0, mbi = 0),
                             items = NULL){

  checkmate::assert_list(missing.rule)
  checkmate::assert_data_frame(dat)
  checkmate::assert_character(items, null.ok = TRUE)

  if(! all(unlist(missing.rule) %in% c(0, NA))){
    unexp_rec <- which( ! unlist(missing.rule) %in% c(0, NA))
    warning(paste0("Found unexpected recode value(s): ",
                  paste(names(missing.rule)[unexp_rec], missing.rule[unexp_rec], collapse = ", "),
                  ". Recoding missings to values other than 0 and NA is not recommended. Please check if this is intended."))
  }
  missruleCheck1 <- (names(missing.rule) %in% c("mbd", "mbi", "mci", "mir", "mnr", "mvi"))
  if (!all(missruleCheck1 == TRUE)) {
    warning(paste("Found unexpected missing type(s) ",
                  paste(sort(names(missing.rule)[!missruleCheck1]), collapse = ", "),
                  " in missing.rule. Please check if this is intended.\n", sep =""))
  }

    missruleCheck2 <- (c("mbd", "mbi", "mci", "mir", "mnr", "mvi") %in% names(missing.rule))
  if (!all(missruleCheck2 == TRUE)) {
    warning(paste("Found no recode information for missing type(s) ",
                  paste(c("mbd", "mbi", "mci", "mir", "mnr", "mvi")[!missruleCheck2], collapse = ", "),
                  " in missing.rule. Please check if this is intended.\n", sep =""))
  }

	if (is.null(items)) {items <- colnames(dat)}

  lookup <- data.frame(old = names(unlist(missing.rule)), new = unlist(missing.rule), stringsAsFactors = FALSE)
  dat <- data.frame(mapply(collapseMissings.collapse, dat, colnames(dat), MoreArgs = list(items = items, lookup = lookup), SIMPLIFY = FALSE), stringsAsFactors=FALSE )
	return(dat)
 }

collapseMissings.collapse <- function(variable, name, items, lookup) {
  if(! name %in% items){
    variableCollapsed <- as.character(variable)
  } else {
    if(all(is.na(match(lookup[, 1], variable)))) {
      variableCollapsed <- as.character(variable)
    } else {
      variableCollapsed <- eatTools::recodeLookup(variable, lookup)
    }
  }
  return(variableCollapsed)
}
