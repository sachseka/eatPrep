aggregateDataOld <- function(all.daten,spalten, unexpected.pattern.as.na = TRUE, printCases = FALSE, printPattern = FALSE, inputList = NULL ) {
        if(missing(spalten)) {spalten <- colnames(all.daten)}
        spalten <- existsBackgroundVariables(dat = all.daten, variable=spalten)
        noAgg <- setdiff(colnames(all.daten), spalten)
        daten <- all.daten[,spalten, drop=FALSE]
        foo   <- table(nchar(colnames(daten)))                                  ### Haben alle Variablennamen die gleiche Anzahl Zeichen?
        if(length(foo)>1) {cat("Variable names with mixed numbers of characters.\n")}
        if (is.null(inputList) ) {
            items  <- unique(substr(colnames(daten),1,nchar(colnames(daten))-1))### wieviele Items wird es geben?
        }  else  {
            nag    <- setdiff ( spalten, inputList[["subunits"]][,"subunit"])   ### no aggregation rule
            if ( length( nag) > 0 ) {
                cat(paste0("Warning: Following ",length(nag), " item(s) without aggregation rule in ZKD input list:\n   '",paste(nag, collapse = "', '"), "'.\nThese item(s) won't be aggregated.\n"))
                noAgg <- c(noAgg, nag)
                daten <- all.daten[,setdiff ( spalten,nag), drop=FALSE]
            }
            items  <- unique(inputList[["subunits"]][which(inputList[["subunits"]][,"subunit"] %in% colnames(daten)),"unit"])
        }
        cat(paste("Aggregate ",ncol(daten)," variable(s) to ",length(items)," item(s).\n",sep="")); flush.console()
        dat.sum <- NULL; dat.agg <- NULL; list.pc <- NULL                       ### erstelle leere Datenobjekte fuer Summendatensatz, aggregierten Datensatz und Liste mit partial-credit-Items
        for (i in 1:length(items))      {
          if ( is.null(inputList)) {
               sub.dat   <- data.frame ( lapply( data.frame(daten[, which(substr(colnames(daten),1,nchar(colnames(daten))-1) %in% items[i]), drop=FALSE ], stringsAsFactors = FALSE), as.numeric), stringsAsFactors = FALSE)
               last.sign <- names(table(substr(colnames(sub.dat),nchar(colnames(sub.dat)),nchar(colnames(sub.dat)))))
               toCheck   <- sum((last.sign)==letters[1:length(last.sign)])==length(last.sign)
    ### Check: Ist das letzte Zeichen des Variablennamens immer ein Buchstabe und aufsteigend?
               if(!toCheck) { cat(paste("Item ",items[i],": last character of variable names does not correspond to assumed alphabetic sequence.\n", sep="")); flush.console()}
          }  else  {
               sub.dat <- data.frame ( lapply( data.frame(daten[,inputList[["subunits"]][which(inputList[["subunits"]][,"unit"] == items[i]),"subunit"], drop = FALSE], stringsAsFactors = FALSE), as.numeric), stringsAsFactors = FALSE)
          }
          ncol.sub.dat <- ncol(sub.dat)
          isNA         <- table(rowSums(is.na(sub.dat)))
          isNA.names   <- as.numeric(names(isNA))
          unexpected   <- setdiff(isNA.names, c(0,ncol.sub.dat))
    # if ( substr(colnames(sub.dat)[1], 1, 8) == "M3621603") {browser()}
          if( length( unexpected ) > 0  )   {
            cases      <- sum(as.numeric(isNA[as.character(unexpected)]))
            cat(paste("Caution! Found unexpected missing pattern in variables for item ",items[i], " in ",cases," cases.\n", sep= "" ) ) ; flush.console()
            whichUnexp <- which( rowSums(is.na(sub.dat)) %in% unexpected)
            if (printCases)   {cat("   Cases in question: "); cat(paste(whichUnexp, collapse=", ")); cat("\n")}
            if (printPattern) {
                patt <- apply(sub.dat[whichUnexp,], MARGIN = 1, FUN = function ( zeile ) { paste(zeile, collapse = "_")})
                print(table(patt))
            }
          }
          if(ncol.sub.dat == 1) {sub.dat[,"summe"] <- sub.dat[,1]}
          if(ncol.sub.dat >  1) {sub.dat[,"summe"] <- apply(sub.dat, 1, FUN = function ( uu ) {ifelse( all(is.na(uu)), NA, sum(uu, na.rm=!unexpected.pattern.as.na))}) }
          if (is.null(inputList)) {
              sub.dat[,"aggregiert"] <- ifelse(sub.dat$summe == ncol.sub.dat,1,0)
          }  else  {                                                            ### 'sl' = selected list
              sl  <- inputList[["unitRecodings"]][which(inputList[["unitRecodings"]][,"unit"] == items[i]),]
              if ( nrow(sl) == 0 ) {
                  stopifnot ( ncol.sub.dat == 1 )
                  sub.dat[,"aggregiert"] <- sub.dat[,1]
              }  else  {
                  recstr <- paste("'",sl[,"value"] , "' = '" , sl[,"valueRecode"],"'",sep="", collapse="; ")
                  sub.dat[,"aggregiert"] <- recode ( sub.dat[,"summe"], recstr)
              }
          }
          if(is.null(dat.sum)) { dat.sum <- sub.dat[,"summe", drop=FALSE] }     else { dat.sum <- cbind(dat.sum,sub.dat[,"summe", drop=FALSE]) }
          if(is.null(dat.agg)) { dat.agg <- sub.dat[,"aggregiert",drop=FALSE] } else { dat.agg <- cbind(dat.agg,sub.dat[,"aggregiert",drop=FALSE]) }
          colnames(dat.sum)[i] <- items[i]
          colnames(dat.agg)[i] <- items[i]
          maximum <- max(dat.sum[,i],na.rm = TRUE)                              ### ist das i-te Item partial credit?
          if(maximum>1) {list.pc <- rbind(list.pc, data.frame(Var=items[i],pc=paste(names(table(dat.sum[,i])),collapse=", "),max=max(as.numeric(names(table(dat.sum[,i])))),stringsAsFactors = FALSE))}}
        if(length(noAgg) > 0) {dat.sum <- data.frame(all.daten[,noAgg, drop=FALSE],dat.sum,stringsAsFactors = FALSE)
        dat.agg <- data.frame(all.daten[,noAgg, drop=FALSE],dat.agg,stringsAsFactors = FALSE)}
        return(list(sum=dat.sum, agg=dat.agg, pc.list=list.pc))}
