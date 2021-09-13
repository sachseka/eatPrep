readMerkmalXlsx <- function(filename, tolcl = FALSE, alleM = TRUE) {

  meL <- list()

  sheetNameVec <- c("Aufgabenmerkmale", "Itemmerkmale")

  for(pp in sheetNameVec) {
    if(pp=="Aufgabenmerkmale") {
      if(inherits(try( meL[[pp]] <- data.frame(suppressMessages(read_excel(filename, sheet=pp, col_names=TRUE, na = "", col_types="text"))), silent=TRUE)	, "try-error")) {
        message("No .xlsx sheet '", pp, "' available. Merkmalsauszug will be created without '", pp, "'.")
      } else {
        message("Reading sheet '", pp, "'.")
        if(meL[[pp]][1,1]!="Aufgabe") {
          aa <- which(meL[[pp]] == "Aufgabe")-1
          if(inherits(try( meL[[pp]] <- data.frame(suppressMessages(read_excel(filename, sheet=pp, col_names=TRUE, na = "", skip=aa, col_types="text"))), silent=TRUE)	, "try-error")) {
            message("No .xlsx sheet '", pp, "' available. Merkmalsauszug will be created without '", pp, "'.")
          }
        }
      }
    } else {
      if(inherits(try( meL[[pp]] <- data.frame(suppressMessages(read_excel(filename, sheet=pp, col_names=TRUE, na = "", col_types="text"))), silent=TRUE)	, "try-error")) {
        message("No .xlsx sheet '", pp, "' available. Merkmalsauszug will be created without '", pp, "'.")
      } else {
        message("Reading sheet '", pp, "'.")
      }
    }
  }

   removeEmptyR <- function(dfr) {
     if(length(which(apply(dfr,1,function(pp) all(pp %in% ""))))> 0) dfr <- dfr[-which(apply(dfr,1,function(pp) all(pp %in% ""))),]
     return(dfr)
   }

   meL <- lapply(meL, removeEmptyR)

   for(ii in names(meL)) {
     if(all(dim(meL[[ii]]) == c(0,0))) message(ii, "is empty.")
   }

   meL[["Aufgabenmerkmale"]]$AufgID <- unlist(lapply(strsplit(meL[["Aufgabenmerkmale"]]$Aufgabe,"_"), function(ii) ii[[1]]))
   meL[["Aufgabenmerkmale"]]$AufgTitel <- unlist(lapply(strsplit(meL[["Aufgabenmerkmale"]]$Aufgabe,"_"), function(ii) if(inherits(try(ii[[2]], silent=TRUE), "try-error")) return(NA)))

   for(j in seq(along=meL[["Itemmerkmale"]]$Aufgabe)) {
     if(is.na(meL[["Itemmerkmale"]]$Aufgabe[j])) {
       meL[["Itemmerkmale"]]$Aufgabe[j] <- meL[["Itemmerkmale"]]$Aufgabe[j-1]
     }
   }

   meL[["Itemmerkmale"]]$AufgID <- unlist(lapply(strsplit(meL[["Itemmerkmale"]]$Aufgabe,"_"), function(ii) ii[[1]]))
   meL[["Itemmerkmale"]]$AufgTitel <- unlist(lapply(strsplit(meL[["Itemmerkmale"]]$Aufgabe,"_"), function(ii) { if(inherits(try(ii[[2]], silent=TRUE), "try-error")) return(NA)}))

   if(tolcl) {
     cc <- paste0(meL[["Itemmerkmale"]]$AufgID,c(letters,LETTERS)[asNumericIfPossible(meL[["Itemmerkmale"]]$Item)])
    ifelse(is.na(asNumericIfPossible(meL[["Itemmerkmale"]]$Item)),meL[["Itemmerkmale"]]$Item,cc)
   } else {
     meL[["Itemmerkmale"]]$ItemID <- paste0(meL[["Itemmerkmale"]]$AufgID,meL[["Itemmerkmale"]]$Item)
   }

   if(alleM & dim(meL[["Itemmerkmale"]])[1]>0 & dim(meL[["Aufgabenmerkmale"]])[1]>0) {

     if(any(nchar(setdiff(intersect(names(meL[["Itemmerkmale"]]),names(meL[["Aufgabenmerkmale"]])),c("AufgID", "AufgTitel", "Aufgabe"))) > 0)) {
       for(pp in setdiff(intersect(names(meL[["Itemmerkmale"]]),names(meL[["Aufgabenmerkmale"]])),c("AufgID", "AufgTitel", "Aufgabe"))) {
         names(meL[["Itemmerkmale"]])[grep(pp,names(meL[["Itemmerkmale"]]))] <- paste0(names(meL[["Itemmerkmale"]])[grep(pp,names(meL[["Itemmerkmale"]]))],".I")
         names(meL[["Aufgabenmerkmale"]])[grep(pp,names(meL[["Aufgabenmerkmale"]]))] <- paste0(names(meL[["Aufgabenmerkmale"]])[grep(pp,names(meL[["Aufgabenmerkmale"]]))],".A")
       }
     }

      if(!all(is.na(c(meL[["Aufgabenmerkmale"]]$AufgTitel,meL[["Itemmerkmale"]]$AufgTitel)))) {
     meL[["AlleMerkmale"]] <- merge(x= meL[["Itemmerkmale"]], y=meL[["Aufgabenmerkmale"]], by=c("AufgID", "AufgTitel", "Aufgabe"))
      } else {
        meL[["AlleMerkmale"]] <- merge(x= meL[["Itemmerkmale"]][,-which(names(meL[["Itemmerkmale"]]) %in% "AufgTitel")], y=meL[["Aufgabenmerkmale"]][,-which(names(meL[["Aufgabenmerkmale"]]) %in% "AufgTitel")], by=c("AufgID", "Aufgabe"))
      }
     meL[["AlleMerkmale"]] <- eatTools::insert.col(meL[["AlleMerkmale"]],"ItemID", "Item")

     #if(any(grepl("Zeit",names(meL[["AlleMerkmale"]])))){
    #   for(i in grep("Zeit",names(meL[["AlleMerkmale"]]))) {
     #    meL[["AlleMerkmale"]][,paste0(names(meL[["AlleMerkmale"]][i]),"lu")] <- lubridate::ms( meL[["AlleMerkmale"]][,i])
    #   }
     #  ee <- grep("Zeit",names(meL[["AlleMerkmale"]]))
    #   ff <- which(names(meL[["AlleMerkmale"]]) == "ItemID")
     #  meL[["AlleMerkmale"]] <- eatTools::reinsort.col(meL[["AlleMerkmale"]],ee, ff)
     #}
     message("Data frame 'AlleMerkmale' has been created.")# (Use lubridate::as.duration for addition of times.) \n")
   }




  return(meL)

}
