### Voraussetzung: Datensatz im Long-Format, wie ihn das Codiertool ausgibt
### idCol: Nummer oder Name der ID
### varCol: Nummer oder Name der Variablenspalte
### codCol: Nummer oder Name der Kodiererspalte
### n.pseudo: wieviele Pseudocodierer?
### randomize.order: soll die Reihenfolge der Pseudocodes nach Zufall bestimmt werden?
make.pseudo <- function(datLong, idCol, varCol, codCol, alwaysPrefer = NULL, alwaysNeglect = NULL, valueCol, n.pseudo, item.groups = NULL, randomize.order = TRUE, verbose = FALSE)   {
      info   <- NULL                                                            ### initialisieren
      datLong<- eatTools::makeDataFrame(datLong)
      allVars<- list(idCol = idCol, varCol = varCol, codCol = codCol, valueCol=valueCol)
      allNams<- lapply(allVars, FUN=function(ii) {eatTools::existsBackgroundVariables(dat = datLong, variable=ii)})
      add    <- setdiff(colnames(datLong), unlist(allNams))
      stopifnot(all(unlist(lapply(list(alwaysPrefer, alwaysNeglect),FUN = function (x) {
           ret <- checkmate::test_character(x, len=1, null.ok = TRUE, any.missing = FALSE) || checkmate::test_numeric(x, len=1, null.ok = TRUE, any.missing = FALSE)
           if(!is.null(x)) {if(!x %in% datLong[,allNams[["codCol"]]]) {stop(paste0("Rater with name '",x,"' does not occur in column '",allNams[["codCol"]],"'."))}}
           return(ret)}))))
      if ( length(add)>0) {if(verbose) {cat(paste0("   Found ",length(add)," additional variables in long format data.frame: '",paste(add, collapse="', '"),"'. If these variable(s) vary between raters (within examinees and items), only the value according to the chosen rater will be kept.\n"))}}
      if(length(allNams) != length(unique(allNams)) ) {stop("'idCol', 'varCol', 'codCol' and 'valueCol' overlap.\n")}
      if(!is.null(alwaysPrefer) && !is.null(alwaysNeglect)) {stopifnot (alwaysPrefer != alwaysNeglect)}
      if(!is.null(item.groups)) {                                               ### checks
        checkmate::assert_character(unlist(item.groups), unique=TRUE, any.missing = FALSE)
        lapply(item.groups,checkmate::assert_character, min.len = 2)
        nichtDrin <- setdiff(unlist(item.groups), datLong[,allNams[["varCol"]]])
        if(length(nichtDrin)>0) {warning(paste0("Following ", length(nichtDrin), " items of 'item.groups' not included in data: '",paste(nichtDrin, collapse = "', '"), "'."))}
      }                                                                         ### untere zeilen "only for the sake of speed": wir sortieren alle Faelle VORHER aus, wo nichts gesampelt werden kann!
      datLong[,"index"] <- paste( datLong[,unlist(allNams[c("idCol")])], datLong[,unlist(allNams[c("varCol")])], sep="_")
      index  <- table(datLong[,"index"])
      datWeg <- datLong[ which ( datLong[,"index"] %in% names(index)[which ( index <= n.pseudo )] ) , ]
      datSamp<- datLong[ which ( datLong[,"index"] %in% names(index)[which ( index > n.pseudo )] ) , ]
  ### Variableninformationen geben
      if(isTRUE(verbose)) {
         cat(paste0("                         N.persons: ",length(unique(datLong[,allNams[["idCol"]]]))  ,
           "\n                            N.vars: ", length(unique(datLong[,allNams[["varCol"]]]))  ,
           "\n                           N.coder: ", length(unique(datLong[,allNams[["codCol"]]])) ,
           "\n               coders per response: minimum ", min(index), ", maximum ",max(index) ,
           "\n   responses with multiple ratings: ", length(which(index > 1)) , " of ",length(index) , " (",round(100*length(which(index > 1)) / length(index), digits = 1) , " %)\n"))
      }
      if(nrow(datSamp)>0) {
        allVars <- unique(datSamp[,allNams[["varCol"]]])
        if(!is.null(item.groups)) {allVars <- c(setdiff(allVars, unlist(item.groups)), item.groups)}
        datPseu <- lapply(allVars, FUN = function (vars) {
                   datVar <- datSamp[which(datSamp[,allNams[["varCol"]]] %in% vars),]
                   datVar <- by(data = datVar, INDICES = datVar[, allNams[["idCol"]]], FUN = function ( sub.dat) {
                             stopifnot(nrow(sub.dat)>n.pseudo)                  ### wenn die Rater mit unterschiedlicher Haeufigkeit geratet haben, soll der haeufigste genommen werden
                             nrat <- table(sub.dat[,allNams[["codCol"]]])       ### wenn der haeufigste weniger als die Haelfte der Codierungen bewertet hat, kann ggf. nicht ein einheitlicher Rater fuer paarweise verbundene Variablen genommen werden
                             if(!is.null(alwaysPrefer) && alwaysPrefer %in% sub.dat[,allNams[["codCol"]]]) {
                                nrat <- nrat[which(names(nrat) == alwaysPrefer)]
                             } else {
                                if(!is.null(alwaysNeglect) && alwaysNeglect %in% sub.dat[,allNams[["codCol"]]]) {nrat <- nrat[which(names(nrat) != alwaysNeglect)]}
                             }
                             if(!is.null(item.groups) && max(nrat) < nrow(sub.dat)/2)  {
                                info    <- rbind(info, data.frame ( variable.bundle = paste(vars, collapse= ", "), examinee = unique(sub.dat[,allNams[["idCol"]]]),stringsAsFactors = FALSE))
                                auswahl <- do.call("rbind", by(data = sub.dat, INDICES = sub.dat[,allNams[["varCol"]]], FUN = function (sub.var.dat ) {
                                           stopifnot(nrow(sub.var.dat)>n.pseudo)
                                           ausw <- sample(unique(sub.var.dat[,allNams[["codCol"]]]), size = n.pseudo, replace=FALSE)
                                           ausw <- sub.var.dat[which(sub.var.dat[,allNams[["codCol"]]] == ausw),]
                                           return(ausw)}))
                             } else {
                                auswahl <- sample(names(nrat[which(nrat == max(nrat))]), size = n.pseudo, replace=FALSE)
                                auswahl <- sub.dat[which(sub.dat[,allNams[["codCol"]]] %in% auswahl),]
                             }
                             if(!randomize.order) {auswahl <- data.frame(auswahl[sort(auswahl[,allNams[["codCol"]]],decreasing=FALSE,index.return=TRUE)$ix,])}
                             return(list(auswahl=auswahl, info=info))})
                   return(datVar)})
        info    <- do.call("rbind", lapply(datPseu, FUN=function (x) {do.call("rbind", lapply(x, FUN = function (y) {return(y[["info"]])}))}))
        datPseu <- do.call("rbind", lapply(datPseu, FUN=function (x) {do.call("rbind", lapply(x, FUN = function (y) {return(y[["auswahl"]])}))}))
        datWeg  <- rbind(datWeg, datPseu)
      }
      if(n.pseudo>1) { datWeg[,unlist(allNams[c("codCol")])] <- paste("Cod",multiseq(datWeg[,"index"]),sep="_") }
      if(!is.null(info)) {
         cat("No common raters for some paired variables found. See attribute 'info' of the returned object for more information.\n")
         attr(datWeg, "info") <- info
      }
      return(datWeg)}

### function by Alexander Robitzsch calculates mean agreement among raters
meanAgree <- function(dat, tolerance = 0, weight.mean = TRUE){
  # INPUT:
  # dat       ... dataframe
  # tolerance ... see function agree
  # weight.mean ... = T, if agreement is weighted by number of rater subjects,
  #            = F, if it is averaged among all rater pairs
  dat  <- eatTools::makeDataFrame(dat)
  checkmate::assert_numeric(tolerance, len = 1)
  checkmate::assert_logical(weight.mean, len = 1)

  pairs<- combn(1:ncol(dat),2, simplify=FALSE)
  dfr  <- do.call("rbind", lapply(pairs, FUN = function(comb) {
          dat.ij <- na.omit(dat[,comb])
          if(nrow(dat.ij) == 0){return(NULL)}
          agr <- agree2(dat.ij, tolerance)
          ret <- data.frame(Coder1 = colnames(dat.ij)[1], Coder2 = colnames(dat.ij)[2], N=agr[["subjects"]], agree = agr[["value"]]/100, stringsAsFactors = FALSE)
          return(ret)}))
  meanagree <- ifelse(weight.mean == TRUE, weighted.mean(dfr$agree, dfr$N), mean(dfr$agree, na.rm=TRUE))
  list(agree.pairwise = dfr, meanagree = meanagree)   }

### function by Alexander Robitzsch calculates mean Cohen's kappa among raters
meanKappa <- function(dat, type = c("Cohen", "BrennanPrediger"), weight = "unweighted", weight.mean = TRUE){
  # INPUT:
  # dat       ... dataframe with at least 2 columns
  # weight    ... see function kappa2 in irr
  # weight.mean ... = T, if agreement is weighted by number of rater subjects,
  #            = F, if it is averaged among all rater pairs
  dat  <- eatTools::makeDataFrame(dat)
  checkmate::assert_character(weight, len = 1)
  checkmate::assert_logical(weight.mean, len = 1)
  type <- match.arg(type)

  pairs<- combn(1:ncol(dat),2, simplify=FALSE)
  dfr  <- do.call("rbind", lapply(pairs, FUN = function(comb) {
          dat.ij <- na.omit(dat[,comb])
          if(nrow(dat.ij) == 0){return(NULL)}
          if(type == "Cohen") {
                if(inherits(weight, "character")){ wgt <- match.arg(weight, choices = c("unweighted", "equal", "squared"))}
                kap <- irr::kappa2(dat.ij, wgt)
                if(is.na(kap[["value"]])) {
                  if(identical(dat.ij[,1],dat.ij[,2])) {
                    kap[["value"]] <- 1
                  }
                }
                ret <- data.frame(Coder1 = colnames(dat.ij)[1], Coder2 = colnames(dat.ij)[2], N=kap[["subjects"]], kappa = kap[["value"]], stringsAsFactors = FALSE)
          }  else  {
                if(inherits(weight, "character")){ wgt <- match.arg(weight, choices = c("quadratic","linear", "ordinal", "radical","ratio", "circular", "bipolar", "unweighted"))}
                kap <- irrCAC::bp.coeff.raw(ratings = dat.ij, weights=wgt)
                if(is.na(kap$est$coeff.val)) {
                  if(identical(dat.ij[,1],dat.ij[,2])) {
                    kap$est$coeff.val <- 1
                  }
                }
                ret <- data.frame(Coder1 = colnames(dat.ij)[1], Coder2 = colnames(dat.ij)[2], N=nrow(dat.ij), agree = kap[["est"]][["pa"]], kappa = kap[["est"]][["coeff.val"]], SE = kap[["est"]][["coeff.se"]], stringsAsFactors = FALSE)
          }
          return(ret)}))
  meankappa <- ifelse(weight.mean == TRUE, weighted.mean(dfr$kappa, dfr$N), mean(dfr$kappa, na.rm = TRUE))
  list(agree.pairwise = dfr, meankappa = meankappa)     }

rbind_common <- function(...) {
  dfs <- list(...)
  if(length(dfs) == 0) {return()}
  if(is.list(dfs[[1]]) && !is.data.frame(dfs[[1]])) { dfs <- dfs[[1]] }
  #dfs <- plyr::compact(dfs)
  dfs[sapply(dfs, is.null)] <- NULL
  if(length(dfs) == 0) {return()}
  if(length(dfs) == 1) {return(dfs[[1]])}
  isdf<- vapply(dfs, is.data.frame, logical(1))                             ### Check that all inputs are data frames
  if(any(!isdf)) {stop("All inputs to rbind_common must be data.frames.") }
  cols<- Reduce(intersect, lapply(dfs, colnames))                           ### find common cols
  if(length(cols) == 0) {
    warning("No common column names found.")
    return()
  }
  dat <- do.call(rbind, lapply(dfs, `[`, cols))
  return(dat)}

agree2 <- function(ratings, tolerance = 0)
{
  ratings <- as.matrix(na.omit(ratings))
  ns <- nrow(ratings)
  nr <- ncol(ratings)
  if (is.numeric(ratings)) {
    rangetab <- apply(ratings, 1, max) - apply(ratings,
                                               1, min)
    coeff <- 100 * sum(rangetab <= tolerance)/ns
  }
  else {
    # rangetab <- as.numeric(sapply(apply(ratings, 1, table),
    #                       length))
    rangetab <- apply(ratings, 1, function(x) length(unique(x)))  ## Vorschlag BB
    coeff <- 100 * (sum(rangetab == 1)/ns)
    tolerance <- 0
  }
  rval <- structure(list(method = paste("Percentage agreement (Tolerance=",
                                        tolerance, ")", sep = ""), subjects = ns, raters = nr,
                         irr.name = "%-agree", value = coeff), class = "irrlist")
  return(rval)
}
