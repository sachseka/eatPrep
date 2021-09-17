checkDesign <- function(dat, booklets, blocks, rotation, sysMis="NA", id="ID", subunits = NULL, verbose = TRUE) {

	if (is.na(match(id, colnames(dat)))) {
		stop("ID variable '", id, "' not found in dataset.")}

	blocks <- set.col.type(blocks, col.type = list ("character" = names(blocks)))
	booklets <- set.col.type(booklets, col.type = list("character" = names(booklets)))
	rotation <- set.col.type(rotation, col.type = list("character" = names(rotation)))

  stopifnot(all(names(blocks) %in% c("subunit", "block", "subunitBlockPosition")))
  stopifnot(any(names(booklets) %in% "booklet"))
  stopifnot(all(sapply(names(booklets)[-grep("booklet",names(booklets))], function(jj) grepl("^block",jj))))
  stopifnot(all(names(rotation) %in% c(id, "booklet")))

  bl1 <- unique(unlist(booklets[,-match("booklet",names(booklets))]))
  bl2 <- unique(blocks$block)
  if(!setequal(bl1,bl2)) {
    warning("Block names set in 'blocks' does not equal block names set in 'booklets'. Please check.")
    if(verbose) {
      if(length(setdiff(bl1,bl2)) > 0) message("The following blocks are in 'booklets' but not in 'blocks': ", paste(setdiff(bl1,bl2),collapse=", "))
      if(length(setdiff(bl2,bl1)) > 0) message("The following blocks are in 'blocks' but not in 'booklets': ", paste(setdiff(bl2,bl1),collapse=", "))
    }
  }

  th1 <- unique(rotation$booklet)
  th2 <- unique(booklets$booklet)
  if(!setequal(th1,th2))  {
    warning("Booklet names set in 'rotation' does not equal booklet names set in 'booklets'. Please check.")
    if(verbose) {
      if(length(setdiff(th1,th2)) > 0) message("The following blocks are in 'rotation' but not in 'booklets': ",setdiff(th1,th2))
      if(length(setdiff(th2,th1)) > 0) message("The following blocks are in 'booklets' but not in 'rotation': ", setdiff(th2,th1))
    }
  }

	if(!is.null(subunits)){
		if(verbose) message("Use names for recoded subunits.")
		if (any(is.na(match(blocks$subunit, subunits$subunit)))){
		  if(verbose) message("Found no names for recoded subunit(s) for subunit(s)" , blocks$subunit[which(is.na(match(blocks$subunit, subunits$subunit)))],
				"\nThis/Those subunit(s) will be ignored in determining 'mnr'.")
		  blocks <- blocks[-which(is.na(match(blocks$subunit, subunits$subunit))), ]
		}
		blocks$subunit[na.omit(match(subunits$subunit, blocks$subunit))] <- subunits$subunitRecoded[match(blocks$subunit, subunits$subunit)]
	}

	gibsNich <- setdiff(names(dat),c(id,blocks$subunit))
	if (length(gibsNich) > 0) {
		if(verbose) message("The following variables are not in info (subunits in blocks) but in dataset. They will be ignored during check: \n", paste(gibsNich, collapse = ", "))
		dat <- dat[,-match(gibsNich, names(dat))]
	}

	# Welche Items sind in Booklet?
	.subunitsInBooklet <- function(TH) {
		return(unname(unlist(sapply(booklets[which(booklets$booklet == TH),grep("block", names(booklets))], function(BL) {
			return(subset(blocks, blocks$block == BL)$subunit)
		}))))
	}

	if(sysMis=="NA") {
		# sysMis instead of vc (M)
		.patternCheckM <- function(subunit, TH, cases) {
			cc <- cases[which(is.na(dat[match(cases, dat[,id]),match(subunit, names(dat))]))]
			if(length(cc) > 0) {return(cc)} else {return(FALSE)}
		}
		# vc instead of sysMis (P)
		.patternCheckP <- function(subunitN, TH, cases) {
			dd <- cases[which(!is.na(dat[match(cases, dat[,id]),match(subunitN, names(dat))]))]
			if(length(dd) > 0) {return(dd)} else {return(FALSE)}
		}
	} else {
		# sysMis instead of vc (M)
		.patternCheckM <- function(subunit, TH, cases) {
			cc <- cases[which(dat[match(cases, dat[,id]),match(subunit, names(dat))] == sysMis)]
			if(length(cc) > 0) {return(cc)} else {return(FALSE)}
		}
		# vc instead of sysMis (P)
		.patternCheckP <- function(subunitN, TH, cases) {
			dd <- cases[which(dat[match(cases, dat[,id]),match(subunitN, names(dat))] != sysMis)]
			if(length(dd) > 0) {return(dd)} else {return(FALSE)}
		}
	}

	# Fuer jedes TH SysmisPattern checken
	.bookletPatternCheck <- function(TH) {
		subunits <- .subunitsInBooklet(TH)
		subunitsN <- setdiff(names(dat), c(subunits, id))
		stopifnot(id %in% names(rotation))
		cases <- rotation[,id][rotation$booklet == TH]
		resList <- list()
		resList[["M"]] <- sapply(subunits, .patternCheckM, TH=TH, cases=cases)
		resList[["P"]] <- sapply(subunitsN, .patternCheckP, TH=TH, cases=cases)
		return(resList)
	}

	resL <- lapply(booklets$booklet, .bookletPatternCheck)
	names(resL) <- booklets$booklet

	if(all(unlist(resL) == FALSE)) {
		if(verbose) message("No deviations from design detected!")
	} else {
		if(verbose) message("Deviations from design detected!")
		if(!all(unlist(resM <- lapply(resL, function(iz) {iz[["M"]]})) == FALSE)) {
			for(ll in names(resL)) {
				if (any(tt <- unlist(lapply(resM[[ll]], function(gg) gg[1])) != FALSE)) {
					if(verbose) message("Found for ", sum(tt)," variable(s) sysMis instead of valid codes for booklet ", ll, ": ")
						for(pp in names(resM[[ll]])) {
							if (resM[[ll]][[pp]][1] != FALSE) {
								if(verbose) message(pp, " (", length(resM[[ll]][[pp]])," case(s): ", paste(resM[[ll]][[pp]], collapse = ", "), ")")
							}
						}
				}
			}
		}
		if(!all(unlist(resP <- lapply(resL, function(iz) {iz[["P"]]})) == FALSE)) {
			for(ll in names(resL)) {
				if (any(tt <- unlist(lapply(resP[[ll]], function(gg) gg[1])) != FALSE)) {
					if(verbose) message("Found for ", sum(tt)," variable(s) valid codes instead of sysMis for booklet ", ll, ": ")
						for(pp in names(resP[[ll]])) {
							if (resP[[ll]][[pp]][1] != FALSE) {
								if(verbose) message(pp, " (", length(resP[[ll]][[pp]])," case(s): ", paste(resP[[ll]][[pp]], collapse = ", "), ")")
							}
						}
				}
			}
		}
	}
}
