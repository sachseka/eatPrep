### Voraussetzung: Datensatz im Long-Format, wie ihn das Codiertool ausgibt
### idCol: Nummer oder Name der ID
### varCol: Nummer oder Name der Variablenspalte
### codCol: Nummer oder Name der Kodiererspalte
### n.pseudo: wieviele Pseudocodierer?
### randomize.order: soll die Reihenfolge der Pseudocodes nach Zufall bestimmt werden?
make.pseudo <- function(datLong, idCol, varCol, codCol, valueCol, n.pseudo, randomize.order = TRUE, verbose = FALSE)   {
      datLong     <- eatTools::makeDataFrame(datLong)
      lapply(c(idCol, varCol, codCol), checkmate::assert_scalar)
      checkmate::assert_vector(valueCol)
      checkmate::assert_numeric(n.pseudo, len = 1)
      lapply(c(randomize.order, verbose), checkmate::assert_logical, len = 1)

      allVars     <- list(idCol = idCol, varCol = varCol, codCol = codCol, valueCol=valueCol)
      all.Names   <- lapply(allVars, FUN=function(ii) {existsBackgroundVariables(dat = datLong, variable=ii)})
      if(length(all.Names) != length(unique(all.Names)) ) {stop("'idCol', 'varCol', 'codCol' and 'valueCol' overlap.\n")}
      dat.i       <- datLong[,unlist(all.Names), drop = FALSE]                  ### untere zeilen "only for the sake of speed": wir sortieren alle Faelle VORHER aus, wo nichts gesampelt werden kann!
      dat.i[,"index"] <- paste( dat.i[,unlist(all.Names[c("idCol")])], dat.i[,unlist(all.Names[c("varCol")])], sep="_")
      index       <- table(dat.i[,"index"])
      datWeg      <- dat.i[ which ( dat.i[,"index"] %in% names(index)[which ( index <= n.pseudo )] ) , ]
      datSample   <- dat.i[ which ( dat.i[,"index"] %in% names(index)[which ( index > n.pseudo )] ) , ]
  ### Variableninformationen geben
      if ( isTRUE(verbose)) {
           cpr <- ### coder per response
           cat(paste0("                      N.persons: ",length(unique(datLong[,all.Names[["idCol"]]]))  ,
               "\n                         N.vars: ", length(unique(datLong[,all.Names[["varCol"]]]))  ,
               "\n                        N.coder: ", length(unique(datLong[,all.Names[["codCol"]]])) ,
               "\n            coders per response: minimum ", min(index), ", maximum ",max(index) ,
               "\nresponses with multiple ratings: ", length(which(index > 1)) , " of ",length(index) , " (",round(100*length(which(index > 1)) / length(index), digits = 1) , " %)\n"))
      }
      if(nrow(datSample)>0) {
        datPseudo   <- do.call("rbind", by(data = datSample, INDICES = datSample[, unlist(all.Names[c("idCol", "varCol")])], FUN = function ( sub.dat) {
          stopifnot(nrow(sub.dat)>n.pseudo)
          auswahl     <- sample(1:nrow(sub.dat), n.pseudo, replace = FALSE )
          if(!randomize.order) { auswahl <- sort(auswahl) }
          sub.dat     <- sub.dat[auswahl,]
          return(sub.dat)}))
        datWeg   <- rbind(datWeg, datPseudo)
      }
      if(n.pseudo>1) { datWeg[,unlist(all.Names[c("codCol")])] <- paste("Cod",multiseq(datWeg[,"index"]),sep="_") }
      return(datWeg)}

### function by Alexander Robitzsch calculates mean agreement among raters
meanAgree <- function( dat , tolerance = 0 , weight.mean = TRUE ){
  # INPUT:
  # dat       ... dataframe
  # tolerance ... see function agree
  # weight.mean ... = T, if agreement is weighted by number of rater subjects,
  #            = F, if it is averaged among all rater pairs
  dat  <- eatTools::makeDataFrame(dat)
  checkmate::assert_numeric(tolerance, len = 1)
  checkmate::assert_logical(weight.mean, len = 1)

  pairs<- combn(1:ncol(dat),2, simplify=FALSE)
  dfr  <- do.call("rbind", lapply(pairs, FUN = function (comb) {
          dat.ij <- na.omit(dat[,comb])
          if ( nrow(dat.ij) == 0 ){return(NULL)}
          agr <- agree( dat.ij , tolerance )
          ret <- data.frame ( Coder1 = colnames(dat.ij)[1], Coder2 = colnames(dat.ij)[2], N=agr[["subjects"]], agree = agr[["value"]]/100, stringsAsFactors = FALSE)
          return(ret)}))
  meanagree <- ifelse( weight.mean == TRUE , weighted.mean( dfr$agree , dfr$N ) , mean( dfr$agree, na.rm=TRUE ) )
  list( agree.pairwise = dfr , meanagree = meanagree )   }

### function by Alexander Robitzsch calculates mean Cohen's kappa among raters
meanKappa <- function( dat , type = c("Cohen", "BrennanPrediger"), weight = "unweighted" , weight.mean = TRUE ){
  # INPUT:
  # dat       ... dataframe with at least 2 columns
  # weight    ... see function kappa2 in irr
  # weight.mean ... = T, if agreement is weighted by number of rater subjects,
  #            = F, if it is averaged among all rater pairs
  dat  <- eatTools::makeDataFrame(dat)
  type <- match.arg(type)
  pairs<- combn(1:ncol(dat),2, simplify=FALSE)
  dfr  <- do.call("rbind", lapply(pairs, FUN = function (comb) {
          dat.ij <- na.omit(dat[,comb])
          if ( nrow(dat.ij) == 0 ){return(NULL)}
          if ( type == "Cohen") {
                if ( inherits(weight, "character")){ wgt <- match.arg(weight, choices = c("unweighted", "equal", "squared"))}
                kap <- irr::kappa2( dat.ij , wgt )
                if(is.na(kap[["value"]])) {
                  if(identical(dat.ij[,1],dat.ij[,2])) {
                    kap[["value"]] <- 1
                  }
                }
                ret <- data.frame ( Coder1 = colnames(dat.ij)[1], Coder2 = colnames(dat.ij)[2], N=kap[["subjects"]], kappa = kap[["value"]], stringsAsFactors = FALSE)
          }  else  {
                if ( inherits(weight, "character")){ wgt <- match.arg(weight, choices = c("quadratic","linear", "ordinal", "radical","ratio", "circular", "bipolar", "unweighted"))}
                kap <- irrCAC::bp.coeff.raw(ratings = dat.ij, weights=wgt)
                if(is.na(kap$est$coeff.val)) {
                  if(identical(dat.ij[,1],dat.ij[,2])) {
                    kap$est$coeff.val <- 1
                  }
                }
                ret <- data.frame ( Coder1 = colnames(dat.ij)[1], Coder2 = colnames(dat.ij)[2], N=nrow(dat.ij), agree = kap[["est"]][["pa"]], kappa = kap[["est"]][["coeff.val"]], SE = kap[["est"]][["coeff.se"]], stringsAsFactors = FALSE)
          }
          return(ret)}))
  meankappa <- ifelse( weight.mean == TRUE , weighted.mean( dfr$kappa , dfr$N ) , mean( dfr$kappa , na.rm = TRUE) )
  list( agree.pairwise = dfr , meankappa = meankappa )     }

rbind_common <- function(...) {
  dfs <- list(...)
  if (length(dfs) == 0) {return()}
  if (is.list(dfs[[1]]) && !is.data.frame(dfs[[1]])) { dfs <- dfs[[1]] }
  #dfs <- plyr::compact(dfs)
  dfs[sapply(dfs, is.null)] <- NULL
  if (length(dfs) == 0) {return()}
  if (length(dfs) == 1) {return(dfs[[1]])}
  isdf<- vapply(dfs, is.data.frame, logical(1))                             ### Check that all inputs are data frames
  if (any(!isdf)) {stop("All inputs to rbind_common must be data.frames.") }
  cols<- Reduce(intersect, lapply(dfs, colnames))                           ### find common cols
  if ( length(cols) == 0 ) {
    warning("No common column names found.")
    return()
  }
  dat <- do.call(rbind, lapply(dfs, `[`, cols))
  return(dat)}

