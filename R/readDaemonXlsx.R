readDaemonXlsx <- function(filename) {

  inL <- list()

  sheetNameVec <- c("units", "subunits", "values", "unitrecoding", "sav-files", "params", "aggregate-missings", "booklets", "blocks")

  for(pp in sheetNameVec) {
    if(inherits(try( inL[[pp]] <-data.frame(read_excel(filename, sheet=pp, col_names=TRUE, na = "", col_types="text")), silent=TRUE)	, "try-error")) {
      cat(paste("No .xlsx sheet '", pp, "' available. InputList will be created without '", pp, "'.\n", sep = ""))
    } else {
      cat(paste("Reading sheet '", pp, "'.\n", sep = ""))
    }
  }
  #fileS <- system.file("tests", "test_import.xlsx", package = "xlsx")
  #res <- read.xlsx(fileS, 1)

  if(!is.null(inL$units) & !all(c("unit", "unitType", "unitAggregateRule") %in% colnames(inL$units))) {
    cat("Something seems to be wrong with your 'units' sheet. Please check columns! \n")
  }
  if(!is.null(inL$subunits) & !all(c("unit", "subunit", "subunitRecoded") %in% colnames(inL$subunits))) {
    cat("Something seems to be wrong with your 'subunits' sheet. Please check columns! \n")
  }
  if(!is.null(inL$values) & !all(c("subunit", "value", "valueRecode", "valueType") %in% colnames(inL$values))) {
    cat("Something seems to be wrong with your 'values' sheet. Please check columns! \n")
  }
  if(!is.null(inL$unitrecoding) & !all(c("unit", "value", "valueRecode") %in% colnames(inL$unitrecoding))) {
    cat("Something seems to be wrong with your 'unitrecoding' sheet. Please check columns! \n")
  }
  if(!is.null(inL[["sav-files"]]) & !all(c("filename", "case.id", "fullname") %in% colnames(inL[["sav-files"]]))) {
    cat("Something seems to be wrong with your 'sav-files' sheet. Please check columns! \n")
  }
  if(!is.null(inL$params) & !all(c("key", "value") %in% colnames(inL$params))) {
    cat("Something seems to be wrong with your 'params' sheet. Please check columns! \n")
  }
  if(!is.null(inL[["aggregate-missings"]]) & !all(c("vc", "mbd") %in% colnames(inL[["aggregate-missings"]]))) {
    cat("Something seems to be wrong with your 'aggregate-missings' sheet. Please check columns! \n")
  }
  if(!is.null(inL[["booklets"]]) & !all(c("booklet", "block1") %in% colnames(inL[["booklets"]]))) {
    cat("Something seems to be wrong with your 'booklets' sheet. Please check columns! \n")
  }
  if(!is.null(inL[["blocks"]]) & !all(c("subunit", "block") %in% colnames(inL[["blocks"]]))) {
    cat("Something seems to be wrong with your 'blocks' sheet. Please check columns! \n")
  }


  # paar ueberfluessige Umbenennungen für Folgefunktionen
  names(inL)[which(names(inL) == "sav-files")] <- "savFiles"
  names(inL)[which(names(inL) == "params")] <- "newID"
  names(inL)[which(names(inL) == "aggregate-missings")] <- "aggrMiss"
  names(inL)[which(names(inL) == "unitrecoding")] <- "unitRecodings"

  removeEmptyR <- function(dfr) {
    if(length(which(apply(dfr,1,function(pp) all(pp %in% ""))))> 0) dfr <- dfr[-which(apply(dfr,1,function(pp) all(pp %in% ""))),]
    ##if(length(which(apply(dfr,2,function(pp) all(pp %in% ""))))> 0) dfr <- dfr[,-which(apply(dfr,2,function(pp) all(pp %in% "")))]
    return(dfr)
  }

  inL <- lapply(inL, removeEmptyR)

  for(ii in names(inL)) {
    if(all(dim(inL[[ii]]) == c(0,0))) cat(ii, "is empty. \n")
  }

  return(inL)
}

