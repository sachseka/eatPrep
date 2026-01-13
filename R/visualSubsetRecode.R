visualSubsetRecode <- function(dat, subsetInfo, ID = "ID", toRecodeVal = -91,
                               useGroups = NULL, positions = FALSE, comments = FALSE) {
  cli_setting()

  lapply(list(dat, subsetInfo), checkmate::assert_data_frame, min.rows = 1)

  checkmate::assert_scalar(ID)
  stopifnot(ID %in% names(dat))
  stopifnot(ID %in% names(subsetInfo))
  stopifnot("datCols" %in% names(subsetInfo))
  # evtl check auf numerische Positionen?

  checkmate::assert_scalar(toRecodeVal)
  checkmate::assert_character(useGroups, len = 1, null.ok = TRUE)
  checkmate::assert_logical(positions, len = 1)

  if(!is.null(useGroups)) {
    stopifnot(useGroups %in% names(subsetInfo))
  }

  if(isTRUE(positions)) {
    stopifnot(all(c("blockPosition", "subunitBlockPosition") %in% names(subsetInfo)))
    if(test_warning(as.numeric, subsetInfo$blockPosition)) {
      cli::cli_alert_danger("blockPosition must be convertible to numeric.", wrap = TRUE)
    }
    if(test_warning(as.numeric, subsetInfo$subunitBlockPosition)) {
      cli::cli_alert_danger("blockPosition must be convertible to numeric.", wrap = TRUE)
    }
  } else {
    cli::cli_alert_danger("If positions are not specified, subgroups won't be separated meaningfully.", wrap = TRUE)
  }

  if(isTRUE(comments)) {
    stopifnot(c("comment") %in% names(subsetInfo))
  }

  if(any(is.na(subsetInfo))) {
    cli::cli_alert_danger("{.arg subsetInfo} contains NA values.
                            Every {.arg subsetInfo} row containing
                            only a single NA will be omitted.",
                          wrap = TRUE)
  }

  a <- setdiff(subsetInfo[[ID]], dat[[ID]])

  if(length(a) > 0) {
    cli::cli_alert_danger("{.arg subsetInfo} contains more IDs than {.arg dat}.
                          The following IDs will not be displayed: {a}", wrap = TRUE)

    subsetInfo <- subsetInfo[-which(subsetInfo[[ID]] %in% a),]
  }

  cli::cli_h1("Begin visual Inspection {Sys.time()}")

  subsetInfo <- unique(na.omit(subsetInfo))
  datM <- dat

  captureInteraction <- NULL

  i <- 1
  if(is.null(useGroups)) {
    ll <- unique(subsetInfo[[ID]])[i]
    nn <- length(unique(subsetInfo[[ID]]))
  } else {
    pp <- unique(subsetInfo[[useGroups]])[i]
    ll <- unique(subsetInfo[[ID]][subsetInfo[[useGroups]] %in% pp])
    nn <- length(unique(subsetInfo[[useGroups]]))
  }
  choice1 <- 0

  while(i <= nn + 1) {
    vars <- unique(subsetInfo$datCols[subsetInfo[[ID]] %in% ll])
    sdat <- datM[datM[[ID]] %in% ll, c(ID, vars)]

    # sdat nach long, mit Block und Posi mergen
    if(isTRUE(positions) & is.null(useGroups)) {
      vars2 <- subsetInfo[subsetInfo[[ID]] %in% ll, c("datCols", "blockPosition", "subunitBlockPosition")]
      vars2 <- set.col.type(vars2)
      vars2 <- vars2[order(as.numeric(vars2$blockPosition), as.numeric(vars2$subunitBlockPosition)),]
      vars_long <- tidyr::pivot_longer(vars2, cols = -datCols, names_to = "variable", values_to = "value")
      vars_transposed <- data.frame(tidyr::pivot_wider(vars_long, names_from = "datCols", values_from = "value"))
      names(vars_transposed)[1] <- ID
      sdat <- rbind(sdat[,match(names(vars_transposed), names(sdat))], vars_transposed)
    }

    if(isTRUE(positions) & !is.null(useGroups)) {
      sdatl <- tidyr::pivot_longer(sdat, cols=vars, names_to = "datCols", values_drop_na = TRUE)
      sI <- subsetInfo[subsetInfo[[ID]] %in% ll, c(ID, "datCols", "blockPosition", "subunitBlockPosition")]
      sI <- set.col.type(sI)
      sI <- sI[order(sI[[ID]], as.numeric(sI$blockPosition), as.numeric(sI$subunitBlockPosition)),]
      sdatl2 <- merge(sdatl, sI, by=c(ID, "datCols"), all.x=TRUE, all.y=FALSE)
      sdatl2 <- sdatl2[!is.na(sdatl2$blockPosition),]
      sdatl2 <- sdatl2[order(sdatl2[[ID]], as.numeric(sdatl2$blockPosition), as.numeric(sdatl2$subunitBlockPosition)),]
      chunks <- split(sdatl2, sdatl2[[ID]])
      extract_cols <- function(df) {
        df[, c("datCols", "blockPosition", "subunitBlockPosition")]  # Extract columns 1, 3, and 4
      }
      standardized <- lapply(chunks, function(df) {
        paste(as.matrix(extract_cols(df)), collapse = ",")  # Convert to a single string
      })
      unique_groups <- unique(standardized)  # Get unique standardized strings
      grouped_indices <- lapply(unique_groups, function(u) {
        which(standardized == u)  # Find indices of matching entries
      })
      merged_dfs <- lapply(grouped_indices, function(index) {
        if(length(index)==1) {
          ret <- chunks[[index]]
          names(ret)[which(names(ret) %in% "value")] <- ret[1,1]
          ret$subunitBlockPosition <- as.numeric(ret$subunitBlockPosition)
          ret <- ret[order(as.numeric(ret$blockPosition), as.numeric(ret$subunitBlockPosition)),]
          #ret$subunitBlockPosition <- NULL
          return(ret[,-1])
        }
        if(length(index)>1) {
          ch2 <- lapply(chunks[index], function(ret) {
            names(ret)[which(names(ret) %in% "value")] <- ret[1,1]
            return(ret[,-1])
            ch2$subunitBlockPosition <- as.numeric(ch2$subunitBlockPosition)
          })
          ret2 <- mergeData("datCols", ch2)
          ret2 <- ret2[order(as.numeric(ret2$blockPosition), as.numeric(ret2$subunitBlockPosition)),]
          ret2 <- ret2[, c("datCols", setdiff(names(ret2), c("datCols", "blockPosition", "subunitBlockPosition")), "blockPosition")]
          return(ret2)
        }
      })
      sdat <- lapply(merged_dfs, function(xx) {
        xx <- data.frame(t(xx))
        names(xx) <- xx[1,]
        xx <- xx[-1,]
        return(xx)
      })
    }


    if(isTRUE(comments)) {
      commt <- unique(subsetInfo$comment[subsetInfo[[ID]] %in% ll])
    }

    cli::cli_h3("Display subset ({i} of {nn})")

    if(!is.null(useGroups)) {
      cli::cli_alert("group {.testtakergroup-label {pp}}", wrap = TRUE)
    }
    cli::cli_alert("{length(ll)} case{?s}: {.testtaker-label {ll}}", wrap = TRUE)
    if (length(vars) > 20) {
      cli::cli_alert("{length(vars)} variable{?s}: {.unit-key {c(head(vars, 20), '...')}}", wrap = TRUE)
    } else {
      cli::cli_alert("{length(vars)} variable{?s}: {.unit-key {vars}}", wrap = TRUE)
    }

    if(isTRUE(comments)) {
      cli::cli_par(); cli::cli_end()

      cli::cli_alert("Issues:")
      cli::cli_ul(id = "comments")
      if(isTRUE(comments)) {
        #cli::cli_alert("{.comment {commt}}", wrap = TRUE)
        cli::cli_li(commt, class = "comment")
      }
      cli::cli_end(id = "comments")

      cli::cli_par(); cli::cli_end()
    }

    # cli::cli_inform("Display subset ({i} of {nn}): {ll} (case{?s}) x {vars} (variable{?s}):", wrap = TRUE)
    #print(sdat)
    if(inherits(sdat, "list")) {
      print(sdat)
    } else {
      print_non_na_chunks(df = sdat, ID = ID)
    }

    cli::cli_par(); cli::cli_end()
    cli::cli_alert("Table of Values and NAs:")
    #count_values(df = sdat, ID = ID)
    if(is.null(useGroups)) {
      print(table(unlist(datM[datM[[ID]] %in% ll, vars])))
    } else {
      print(table(unlist(lapply(sdat, function(hh) hh[-which(row.names(hh) %in% c("blockPosition", "subunitBlockPosition")),]))))
    } #wozu gleich diese Fallunterscheidung hier?

    # res1 <- menu(c("yes", "no", "flag, maybe later", paste0("go back (already set '", toRecodeVal,"' cannot be undone)")),
    #
    #
    if(isTRUE(positions)) {
      choices1 <- c(
        "yes, all values",
        "yes, all non-valid values (-99, -98, -97, -96)",
        "yes, specific blocks (submenu to select blocks follows)",
        "no",
        "flag for later review",
        "go back to previous subset",
        "reset to original values",
        "exit visualSubsetRecode"
      )
    } else {
      choices1 <- c(
        "yes, all values",
        "yes, all non-valid values (-99, -98, -97, -96)",
        "no",
        "flag for later review",
        "go back to previous subset",
        "reset to original values",
        "exit visualSubsetRecode"
      )
    }
    choices2 <- c(
      "yes",
      "go back"
    )

    cli::cli_par(); cli::cli_end()

    cli::cli_alert_info("Do you want to recode this subset to '{toRecodeVal}'?")

    res1 <- menu(choices1)
    choice1 <- choices1[res1]

    if(choice1 == "exit visualSubsetRecode") {
      cli::cli_alert_danger("Are you sure to abort visualSubsetRecode now?")
      res2 <- menu(choices2)
      choice2 <- choices2[res2]

      if(choice2 == "yes") {
        i <- nn + 2
      } else {
        cli::cli_h3("Display subset ({i} of {nn})")

        if(!is.null(useGroups)) {
          cli::cli_alert("group {.testtakergroup-label {pp}}", wrap = TRUE)
        }
        cli::cli_alert("{length(ll)} case{?s}: {.testtaker-label {ll}}", wrap = TRUE)
        if (length(vars) > 20) {
          cli::cli_alert("{length(vars)} variable{?s}: {.unit-key {c(head(vars, 20), '...')}}", wrap = TRUE)
        } else {
          cli::cli_alert("{length(vars)} variable{?s}: {.unit-key {vars}}", wrap = TRUE)
        }


        if(isTRUE(comments)) {
          #cli::cli_alert("{.comment {commt}}", wrap = TRUE)
          cli::cli_li(commt, class = "comment")
        }

        # cli::cli_inform("Display subset ({i} of {nn}): {ll} (case{?s}) x {vars} (variable{?s}):", wrap = TRUE)
        #print(sdat)

        if(inherits(sdat, "list")) {
          print(sdat)
        } else {
          print_non_na_chunks(df = sdat, ID = ID)
        }
        #count_values(df = sdat, ID = ID)
        cli::cli_par(); cli::cli_end()
        cli::cli_alert("Table of Values and NAs:")
        if(is.null(useGroups)) {
          print(table(unlist(datM[datM[[ID]] %in% ll, vars])))
        } else {
          print(table(unlist(datM[datM[[ID]] %in% ll, vars])))
        }
        cli::cli_par(); cli::cli_end()
        # res1 <- menu(c("yes", "no", "flag, maybe later", paste0("go back (already set '", toRecodeVal,"' cannot be undone)")),
        cli::cli_alert_info("Do you want to recode this subset to '{toRecodeVal}'?")
        choice1 <- menu(choices1)
      }
    }

    if(choice1 == "yes, all values") {
      datM[datM[[ID]] %in% ll, vars][!is.na(datM[datM[[ID]] %in% ll, vars])] <- toRecodeVal
      cli::cli_alert_success("Subset successfully recoded to '{toRecodeVal}'!")
    } else {
      if(choice1 == "reset to original values") {
        datM[datM[[ID]] %in% ll, vars] <- dat[dat[[ID]] %in% ll, vars]
        cli::cli_alert_success("Subset successfully recoded to original values!")
      } else {
        if(choice1 == "yes, all non-valid values (-99, -98, -97, -96)") {
          datM[datM[[ID]] %in% ll, vars][(!is.na(datM[datM[[ID]] %in% ll, vars])) & ((datM[datM[[ID]] %in% ll, vars]=="-99")| (datM[datM[[ID]] %in% ll, vars]=="-98")| (datM[datM[[ID]] %in% ll, vars]=="-97") | (datM[datM[[ID]] %in% ll, vars]=="-96") )] <- toRecodeVal
          cli::cli_alert_success("Subsets' non-valid values successfully recoded to '{toRecodeVal}'!")
        } else {
          if(choice1 == "yes, specific blocks (submenu to select blocks follows)") {
            avBlocks <- unique(subsetInfo$blockPosition[subsetInfo[[ID]] %in% ll])
            choiCL <- list()
            for(ii in seq(along=avBlocks)) {
              choicesBL <- paste(c("yes, block", "no, not block "), ii)
              choiCL[[ii]] <- menu(choicesBL)
            }
            recBlocks <- avBlocks[unlist(choiCL) == 1]
            for(llID in ll) {
              vars3 <- unique(subsetInfo$datCols[subsetInfo[[ID]] %in% llID & subsetInfo$blockPosition %in% recBlocks])
              datM[datM[[ID]] %in% llID, vars3][!is.na(datM[datM[[ID]] %in% llID, vars3])] <- toRecodeVal
            }
            cli::cli_alert_success("Blocks '{recBlocks}' successfully recoded to '{toRecodeVal}'!")
          } else {
            if(choice1 != "exit visualSubsetRecode") {
              cli::cli_alert_info(paste0("No recoding action was undertaken this time."))
            }
          }
        }
      }
    }

    if(is.null(useGroups)) {
      newCI <- data.frame(ID=ll, choice = choice1, timeStamp=Sys.time())
      names(newCI)[1] <- ID
      captureInteraction <- rbind(captureInteraction, newCI)
    } else {
      newCIg <- data.frame(IDgroup=pp, choice = choice1, timeStamp=Sys.time())
      names(newCIg)[1] <- useGroups
      captureInteraction <- rbind(captureInteraction, newCIg)
    }

    if(choice1 == "go back to previous subset") {
      if(i == 1) {
        #return(list(datM, captureInteraction))
        cli::cli_alert_danger("--- No previous subset to go back to. ---", wrap = TRUE)
        cli::cli_text("")
      } else {
        i <- i - 1
        if(is.null(useGroups)) {
          ll <- unique(subsetInfo[[ID]])[i]
        } else {
          pp <- unique(subsetInfo[[useGroups]])[i]
          ll <- unique(subsetInfo[[ID]][subsetInfo[[useGroups]] %in% pp])
        }
      }
    } else {
      i <- i + 1
      if(i == nn + 1) {
        cli::cli_alert_success("This was the last subset.")

        cli::cli_alert("Do you want to end visualSubsetRecode now?")
        res2 <- menu(choices2)
        choice2 <- choices2[res2]

        if(choice2 == "yes") {
          i <- nn + 2
        } else {
          i <- nn
        }
      }

      if(is.null(useGroups)) {
        ll <- unique(subsetInfo[[ID]])[i]
        subsetInfoM <- merge(subsetInfo, captureInteraction,
                             by = ID, all = TRUE)
      } else {
        pp <- unique(subsetInfo[[useGroups]])[i]
        ll <- unique(subsetInfo[[ID]][subsetInfo[[useGroups]] %in% pp])
        subsetInfoM <- merge(subsetInfo, captureInteraction,
                             by = useGroups, all = TRUE)
      }
    }
  }

  # if(any(subsetInfoM$choice==4)) subsetInfoM <- subsetInfoM[subsetInfoM$choice != 4,]
  subsetInfoM <- subsetInfoM[!is.na(subsetInfoM$choice),]
  res <- list(datM, subsetInfoM)
  return(res)
}


#maybe add later functionality that NA can be represented by any missing-by-design-code which then should be user-specified via an argument
print_non_na_chunks <- function(df, ID="ID") {
  if(dim(df)[1] == 1) {
    print(df)
  } else {
    non_na_matrix <- !is.na(df[,!(names(df) %in% ID)])
    row_patterns <- apply(non_na_matrix, 1, paste, collapse = "-")
    unique_patterns <- unique(row_patterns)
    for(i in seq(along=unique_patterns)) {
      pattern <- unique_patterns[i]
      matching_rows <- which(row_patterns == pattern)
      non_na_cols <- which(non_na_matrix[matching_rows[1], ])
      if(length(non_na_cols) > 0) {
        cat("\nsubgroup", i, ":\n")
        print(df[matching_rows, which(names(df) %in% c(ID, names(non_na_cols))), drop = FALSE])
      }
    }
  }
}


test_warning <- function(fun, arg) {
  warnings_before <- warnings()
  on.exit(warnings(warnings_before)) # Setzt Warnungen nach dem Test zurück
  result <- withCallingHandlers(
    fun(arg),
    warning = function(w) {
      invokeRestart("muffleWarning")
      return(TRUE)
    }
  )
  FALSE
}

#
# count_values <- function(df, ID = "ID") {
#   if(dim(df)[1] == 1) {
#     prep_df <- df[names(df) != ID]
#     rownames(prep_df) <- df[[ID]]
#
#     tab_df <- apply(prep_df, 1, table, useNA = "always")
#
#     print(tab_df)
#   } else {
#     print("")
#     # Den Fall müsste man noch ergänzen...
#     # prep_df <- df[names(df) != ID]
#     # rownames(prep_df) <- df[[ID]]
#     #
#     # tab_df <- lapply(1:nrow(prep_df),
#     #                  function(row) apply(prep_df[row,], 1, function(x) table(x, useNA = "always")))
#     #
#     # all_rows <- sort(unique(unlist(lapply(tab_df, rownames))))
#     #
#     # df1 <- tab_df[[1]][all_rows, , drop = FALSE]
#     #
#     # cbind(tab_df[[1]],tab_df[[3]])
#   }
# }
