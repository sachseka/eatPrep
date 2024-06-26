evalPbc <- function(pbcs, mistypes = c("mnr", "mbd", "mir", "mbi"),
                    minPbcAtt = .05, maxPbcDis = .005, maxPbcMis = .07) {
  cli_setting()

  checkmate::assert_data_frame(pbcs)
  checkmate::assert_vector(mistypes)
  lapply(c(minPbcAtt, maxPbcDis, maxPbcMis), checkmate::assert_numeric, len = 1)

  ret <- NULL

  if(!all(c("item", "cat", "freq", "catPbc", "recodevalue") %in% names(pbcs))) {
    cli_abort("'pbcs' should be a {.pkg data.frame} as generated by {.pkg eatPrep::catPbc()}",
              wrap = TRUE)
  }

  if(length(setdiff(unique(pbcs$recodevalue), c(0, 1, mistypes))) > 0) {
    differingMistypes <- setdiff(unique(pbcs$recodevalue), c(0, 1, mistypes))

    cli_alert_info("{.pkg catPbc} contains other values than 0, 1 and the specified mistypes:
       Other value(s): {.field {sort(differingMistypes)}}",
       wrap = TRUE)
  }

  if(any(pbcs$freq[pbcs$recodevalue==1] == 0)) {
    ret$zeroFreqAtt <- pbcs$item[pbcs$recodevalue==1 & pbcs$freq==0]
    cli_alert_danger("The attractors (score 1) of the following {length(ret$zeroFreqAtt)} item{?s} were chosen with a frequency of zero: {.field {ret$zeroFreqAtt}}. This should not happen. Please check.", wrap = TRUE)
  } else {
    cli_alert_success("Excellent, no attractors (score 1) were chosen with a frequency of zero.",
                      wrap = TRUE)
  }

  if(any(pbcs$freq[pbcs$recodevalue==0] == 0)) {
    ret$zeroFreqDis <- unique(pbcs$item[pbcs$recodevalue==0 & pbcs$freq==0])
    zeroFreqDis <- paste(
      ret$zeroFreqDis,
      pbcs$cat[pbcs$recodevalue==0 & pbcs$freq==0],
      sep = "_"
    )

    cli_alert_warning("The distractors (score 0) of the following {length(ret$zeroFreqDis)} item{?s} were chosen with a frequency of zero: {.field {zeroFreqDis}}.
                      This may happen, but is probably not intended.",
                      wrap = TRUE)
  } else {
    cli_alert_success("Excellent, no distractors (score 0) were chosen with a frequency of zero.",
                      wrap = TRUE)
  }


  ad <- ifelse(pbcs$catPbc[pbcs$recodevalue==1] < minPbcAtt | is.na(pbcs$catPbc[pbcs$recodevalue==1]), TRUE, FALSE)
  if(sum(ad) > 0) {
    ret$lowMisPbcAtt <- pbcs[pbcs$recodevalue==1,][ad,]$item
    lowMisPbcAtt <- paste(
      ret$lowMisPbcAtt,
      round(pbcs[pbcs$recodevalue==1,][ad,]$catPbc, 2),
      sep=":_"
    )

    cli_alert_danger("catPbcs for attractors (score 1) of the following {length(ret$lowMisPbcAtt)} item{?s} are worrisome low (< {format(minPbcAtt, scientific = FALSE)}) or missing: {.field {lowMisPbcAtt}}\n")
  }

  ad <- ifelse(pbcs$catPbc[pbcs$recodevalue==0] > maxPbcDis &
                 !is.na(pbcs$catPbc[pbcs$recodevalue==0]),
               TRUE,
               FALSE)

  if(sum(ad) > 0) {
    # Duplicate item codes included
    allHighPbcDis <- pbcs[pbcs$recodevalue==0,][ad,]$item
    highPbcDis <- paste(
      allHighPbcDis,
      pbcs[pbcs$recodevalue==0,][ad,]$cat,
      round(pbcs[pbcs$recodevalue==0,][ad,]$catPbc, 2),
      sep="_")

    # This has to be made unique after initial flag
    ret$highPbcDis <- unique(allHighPbcDis)

    cli_alert_danger("catPbcs for distractors (score 0) of the following {length(ret$highPbcDis)} item{?s} are unexpectedly high (> {format(maxPbcDis, scientific = FALSE)}): {.field {highPbcDis}}")
  }

  for(mm in mistypes) {
    ad <- ifelse(pbcs$catPbc[pbcs$recodevalue==mm] > maxPbcMis & !is.na(pbcs$catPbc[pbcs$recodevalue==mm]), TRUE, FALSE)
    if(sum(ad) > 0) {
      ret$highPbcMis[[mm]] <- unique(pbcs[pbcs$recodevalue==mm,][ad,]$item)
      highPbcMis <- paste(
        ret$highPbcMis[[mm]],
        pbcs[pbcs$recodevalue==mm,][ad,]$cat,
        round(pbcs[pbcs$recodevalue==mm,][ad,]$catPbc, 2),
        sep="_")

      cli_alert_warning("catPbcs for mistype '{mm}' of the following {length(ret$highPbcMis[[mm]])} item{?s} are relatively high (> {format(maxPbcMis, scientific = FALSE)}): {.field {highPbcMis}}",
                        wrap = TRUE)
    }
  }

  if (is.null(ret)) {
    invisible(ret)
  } else {

    objects <- paste(
      "output",
      names(ret),
      sep = "$"
    )
    if ("highPbcMis" %in% names(ret)) {
      objects_highPbcMis <- paste(
        "output$highPbcMis",
        names(ret$highPbcMis),
        sep = "$"
      )

      objects <- append(objects, objects_highPbcMis, after = which(objects == "output$highPbcMis"))
      objects <- objects[objects != "output$highPbcMis"]

      objects <- paste0("{.envvar ", objects, "}")
    }

    cli_alert_info("For a list of problematic items, save the {.envvar output} of this function and return the item names as a vector:", wrap = TRUE)
    cli_ul(objects)
    invisible(ret)
  }
}
