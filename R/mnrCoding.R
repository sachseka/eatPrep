mnrCoding <- function ( dat , pid , rotation.id , blocks , booklets , breaks , subunits = NULL , nMbi = 2 , mbiCode = "mbi" , mnrCode = "mnr" , invalidCodes = c ( "mbd", "mir", "mci" ) , verbose = FALSE ) {
  checkmate::assert_data_frame(dat)
  checkmate::assert_scalar(pid)
  checkmate::assert_character(rotation.id, len = 1)
  lapply(list(blocks, booklets), checkmate::assert_data_frame)
  checkmate::assert_subset(colnames(blocks), choices = c("subunit", "block", "subunitBlockPosition"), .var.name = "column names of 'blocks' data frame (long format)")

  checkmate::assert_numeric(breaks)
  checkmate::assert_data_frame(subunits, null.ok = TRUE)
  checkmate::assert_numeric(nMbi, lower = 1, len = 1)
  lapply(c(mbiCode, mnrCode), checkmate::assert_character, len = 1)
  checkmate::assert_character(invalidCodes)
  checkmate::assert_logical(verbose, len = 1)

		# Startzeit
		st <- Sys.time()

		# Identifizieren der Items im Datensatz
		# mit ggf. Abgleich der rekodierten Namen aus subunits
		if ( verbose ) {
				message( "...identifying items in data (reference is blocks$subunit)" )
		}
		# colnames
		cn <- colnames ( dat )
		cn1 <- cn %in% blocks$subunit
		check1 <- all ( cn1 )
		if ( !check1 ) {
				# geht natuerlich nur wenn subunits da ist
				if ( !is.null ( subunits ) ) {
						cn2 <- cn[! cn %in% blocks$subunits]

						# jetzt versuchen, herauszufinden ob das rekodierte Variablen sind
						check2 <- any ( cn2 %in% subunits$subunitRecoded )
						# fuer diese in blocks den Rekodierungsnamen setzen
						if ( check2 ) {
								cn3 <- cn2[cn2 %in% subunits$subunitRecoded]
								# Rekodierungsnamen
								rn <- subunits$subunitRecoded[subunits$subunitRecoded %in% cn3]
								names(rn) <- subunits$subunit[subunits$subunitRecoded %in% cn3]

								# check ob in blocks$subunit
								check4 <- any ( blocks$subunit %in% names(rn) )
								if ( check4 ) {
										cn4 <- blocks$subunit[blocks$subunit %in% names(rn)]
										# die koennen jetzt gesetzt werden
										blocks$subunit[blocks$subunit %in% cn4] <- unname ( rn[cn4] )
								}
						}
				}
		}

		# Ausgabe, welche Variablen im Datensatz nicht gefunden wurden
		items <- colnames(dat)[ colnames(dat) %in% blocks$subunit]
		not.items <- colnames(dat)[! colnames(dat) %in% blocks$subunit]
		if ( verbose ) {
				check5 <- length(not.items) > 0
				if ( check5 ) {
						message( "Variables in data not recognized as items:\n" , paste ( not.items , collapse = ", " ))
				  message( "If some of these excluded variables should have been identified as items (and thus be used for mnr coding) check 'blocks', 'subunits', 'dat'." )
				}
		}

		# wenn keine Items, dann auch nicht weiter machen
		if ( identical ( items , character(0) ) ) {
				if ( verbose ) {
				  message( "No items in data. nothing recoded. data is returned unchanged." )
				}
		} else {

				# zur convenience noch Items identifizieren die gar kein mbiCode haben
				if ( verbose ) {
				  message( "...identifying items with no mbi-codes ('" , mbiCode , "'):")
						f1 <- function ( sp , mbiCode ) {
								if ( !any(sp %in% mbiCode ) ) TRUE else FALSE
						}
						nombi <- sapply ( dat[,items] , f1 , mbiCode )
						if ( any ( nombi ) ) {
						  message( paste ( items[nombi] , collapse = ", " ))
						  message( "If you expect mbi-codes on these variables check your data and option 'mbiCode'" )
						} else {
						  message( "none" )
						}
				}

				# Blocks
				# blocks$subunit reduzieren auf colnames des Datensatzes
				blocks <- blocks[ blocks$subunit %in% colnames(dat) , , drop = FALSE ]
				blocks$subunitBlockPosition <- as.integer ( blocks$subunitBlockPosition )

				# booklet long
				bookl.long <- reshape2::melt (booklets, id.vars = "booklet", na.rm = FALSE )
				colnames(bookl.long) <- c("booklet","block.wide.name","block")
				bookl.long$booklet <- as.character ( bookl.long$booklet )
				bookl.long$block.wide.name <- as.character ( bookl.long$block.wide.name )
				bookl.long$block <- as.character ( bookl.long$block )
				bookl.long <- bookl.long [ order ( bookl.long$booklet ) , ]
				bookl.long$blockpos <- as.integer ( multiseq ( bookl.long$booklet ) )
				bookl.long <- bookl.long [ !bookl.long$block=="" , ]
				rownames(bookl.long) <- seq ( along = rownames(bookl.long) )

				# Abschnitte
				names(breaks) <- seq ( along = breaks ) + 1
				bookl.long$abschnitt <- rep ( as.character(1) , nrow ( bookl.long ) )
				breaks.sorted <- sort ( breaks , decreasing = FALSE )
				do <- paste ( "bookl.long [ bookl.long$blockpos > " , breaks.sorted , " , \"abschnitt\" ] <- ", names(breaks.sorted) , sep = "" )
				eval ( parse ( text = do ) )
				bookl.long$abschnitt <- as.integer ( bookl.long$abschnitt )
				# bookl.long <- bookl.long[ order ( bookl.long$booklet , bookl.long$abschnitt , bookl.long$blockpos ) , ]

				# neue ID bilden aus booklet und abschnitt, das sind dann jeweils die units ueber deren Items mnr bestimmt werden muss
				bookl.long$ba <- paste ( bookl.long$booklet , bookl.long$abschnitt , sep = "_" )
				bookl.long <- bookl.long[ order ( bookl.long$ba , bookl.long$blockpos ) , ]

				# Items ranmergen
				bookl.long2 <- merge ( bookl.long , blocks , by = "block" , sort = FALSE )

				# !!! richtige Reihenfolge muss hersgestellt werden !!!
				bookl.long2 <- bookl.long2 [ order ( bookl.long2$ba , bookl.long2$blockpos , bookl.long2$subunitBlockPosition ) , ]

				# Abschnittsliste
				abschn <- split ( bookl.long2 , bookl.long2$ba )

				# identifizieren der Zellen, die zu "mnr" kodiert werden sollen
				fun <- function ( abschn , dat , rotation.id , nMbi , mbiCode , pid , verbose , invalidCodes ) {

						# Teildaten
						d <- dat[ dat[,rotation.id] == unique ( abschn$booklet ) , c ( pid , abschn$subunit ) ]

						# Zeilenweise ueber Teildaten
						fun2 <- function ( z , nMbi , mbiCode , invalidCodes ) {

								# reversen, also alles von vorn
								# (is leichter zu verstehen)
								z2 <- rev ( z )

								# bestimmen welche Werte alles mbi
								z2.mbi <- z2 %in% mbiCode
								# %in% loescht die names (== nicht)
								names(z2.mbi) <- names ( z2 )

								# bestimmen ob alles mbi oder invalid
								z2.invalid <- all ( z2 %in% c ( mbiCode , invalidCodes ) )

								# wenn alles mbi oder alle Codes mbi+invalid, dann nix machen
								if ( all ( z2.mbi ) | z2.invalid ) {
										ret <- NULL
								} else {
								# ansonsten mnr bestimmen
										# erstes nicht mbi
										notmbi <- min ( which ( !z2.mbi ) )

										# wenn nMbi kleiner als notmbi
										# dann muss alles bis notmbi als mnr
										if ( nMbi < notmbi ) {
												ret <- names(z2.mbi) [ 1:(notmbi-1) ]
										} else {
												ret <- NULL
										}
								}
								return ( ret )

						}
						x <- apply ( d , 1 , fun2 , nMbi , mbiCode , invalidCodes )

						if ( !is.null ( x ) ) {
								names ( x ) <- d[,pid]
								x <- x [ ! sapply ( x , is.null ) ]

								# MH 14.01.2013: zu viel Muell :-)
								# if ( verbose ) {
										# l <- sapply ( x , length )
										# cat ( paste ( paste ( paste ( "  " , l , " items for case " , names ( l ) , sep = "" ) , collapse = "\n" ) ) , "\n" , sep = "" )
										# flush.console()
								# }

								fun3 <- function ( items , id , durchgang , pid , abschnitt.name , booklet.name ) {
										da <- data.frame ( "item" = items , stringsAsFactors = FALSE )
										da$pid <- id
										colnames(da)[2] <- pid
										da$booklet <- booklet.name
										da$booklet.section <- abschnitt.name
										return ( da )
								}
								da <- mapply ( fun3 , x , names ( x ) , seq(along=x) , MoreArgs = list ( pid , unique ( abschn$abschnitt ) , unique ( abschn$booklet ) ) , SIMPLIFY = FALSE )
								da <- da[!sapply ( da , is.null)]
								da <- do.call ( "rbind" , da )
						} else {
								da <- NULL
						}
						return ( da )
				}

				da <- mapply ( fun , abschn , MoreArgs = list ( dat , rotation.id , nMbi , mbiCode , pid , verbose , invalidCodes ) , SIMPLIFY = FALSE )
				da <- da[!sapply ( da , is.null)]
				da <- do.call ( "rbind" , da )

				# da gruendlich checken, nur weiter wenn valide bzw. Zeilen im Data.frame
				# hier koennte man auch noch nen bisschen verbosieren/warnen
				weiter <- FALSE
				if ( ! ( is.null ( da ) | identical ( da , list() ) ) ) {
						if ( is.data.frame ( da ) ) {
								if ( nrow ( da ) > 0 ) {
										weiter <- TRUE
								}
						}
				}

				if ( weiter ) {

						# da aufhuebschen
						da <- da [ order ( da$item ) , ]
						rownames(da) <- seq ( along = rownames ( da ) )

						# uniqe Items und Personen bestimmen
						unpid <- da[!duplicated(da[,pid]),pid]
						unitems <- da[!duplicated(da[,"item"]),"item"]

						# Zellen/Personen/Items ausgeben
						if ( verbose ) {
						  message( "mnr statistics:" )
						  message( "     mnr cells: ", nrow(da))
						  message( "     unique cases with at least one mnr code: ", length(unpid) )
						  message( "     unique items with at least one mnr code: ", length(unitems) , "\n" )
						}

						# Ausgabe von Deskriptives von TH/Abschnitt (auf Wunsch einzelner)
						if ( verbose ) {
								# erstmal th/abschn/person : Nitem
								da.agg1 <- aggregate ( da , by = list ( da$booklet , da$booklet.section , da[,pid] ) , FUN = length )
								da.agg1 <- da.agg1 [ , c(1,2,3) ]
								colnames ( da.agg1 ) <- c ( "booklet" , "booklet.section" , pid )
								# jetzt daraus th/abschn : Nperson
								da.agg2 <- aggregate ( da.agg1 , by = list ( da.agg1$booklet , da.agg1$booklet.section ) , FUN = length )
								da.agg2 <- da.agg2 [ , c(1,2,3) ]
								colnames ( da.agg2 ) <- c ( "booklet" , "booklet.section" , paste ( "N." , pid , sep = "" ) )
								da.agg2 <- da.agg2[order(da.agg2$booklet,da.agg2$booklet.section),]
								rownames ( da.agg2 ) <- seq ( along = rownames ( da.agg2 ) )

								# ausgeben
								message( "unique cases ('" , pid , "') per booklet and booklet section (0s omitted):")
								print ( da.agg2 )
								cat ( "\n" )
						}

						# Manipulationsstring bauen
						fun4 <- function ( item , da , pid , mnrCode ) {
								pids <- da[da$item %in% item, pid]
								paste ( "dat[dat[,'",pid,"'] %in% c(", paste(paste("'",pids,"'",sep=""),collapse=",") , "),'",item,"']<-'",mnrCode,"'" , sep ="" )
						}
						do <- unname ( mapply ( fun4 , unitems , MoreArgs = list ( da , pid , mnrCode ) , SIMPLIFY = TRUE ) )

						# wenn verbose noch Fortschrittszahlen zu do adden
						if ( verbose ) {

								fun5 <- function ( durchgang ) {
										zufall <- runif ( 10 )
										if ( zufall[5] > 0.90 ) lb <- "\n" else lb <- ""
									#	z <- paste ( "cat('",durchgang," ');cat('", lb ,"');flush.console()", sep = "" )
								}
								z <- sapply ( seq(along=do) , fun5 )
								names(z) <- seq(along=z)
								names(do) <- seq(along=do)
								do <- c ( do , z )
								do <- do [ order ( as.numeric ( names ( do ) ) ) ]
								do <- unname ( do )
						}

						# Rekodierung durchfuehren
						if ( verbose ) {
							 message( "start recoding (item-wise)" )
						}

						eval ( parse ( text = do ) )

						# Ausgabe gebrauchte Zeit
						if ( verbose ) {
								message( "done" )
								et <- Sys.time() - st
								einh <- attributes ( et )$units
								et <- unclass ( et )
								message( "elapsed time: " , formatC ( et , digits = 1 , format = "f" ) , " " ,  einh)
						}

				} else {
						# wenn keine identifizierte Zellen vorliegen oder bei internem Fehler (kein data.frame)
						if ( verbose ) {
						  message( "no mnr identified for any case. nothing recoded." )
						}
				}
		}

		if ( verbose ) flush.console()

		return ( dat )
}
