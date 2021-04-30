<<<<<<< HEAD
# # tests:
#
# # checken, ob alle in den daten vorhandenen missingcodes in aggregatemissings abgedeckt sind!
# # checken, ob alle in aggregatemissings vorhandenen rekodierungen zulässig sind (= in den spaltennamen von aggregatemmissings spezifiziert)
#
# # was passiert, wenn in aggregatemissings spalten fehlen oder doppelt sind?
# # prüfen, ob in Daten NA enthalten sind --> sollen in mbd umgewandelt werden
# # was passiert, wenn keine vc enthalten sind
#
#
#
# # Problem: in Beispieldaten sind gar keine Zweifelsfälle für aggregateData enthalten --> kommt immer vc raus
# #  --> nur bei mci und mvi werden in aggregierten Daten Missings erzeugt, im Datensatz sind aber nur mbi
# #  --> Alternative: aggregatemissings so spezifizieren, dass mbi + vc mbi ergibt
#
# # Inputdatensatz: mehr zu aggregierende Items einfügen, in den ersten fünf Items
#
#
#
# # err wenn vc auf mbi trifft
# am <- matrix(c(
#   "vc" , "mvi", "vc" , "mci", "err", "vc" , "err", "err",
#   "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
#   "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
#   "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
#   "err", "err", "err", "err", "mbd", "err", "err", "err",
#   "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
#   "err", "err", "mnr", "mci", "err", "mir", "mbi", "err",
#   "err", "err", "err", "err", "err", "err", "err", "err" ),
#   nrow = 8, ncol = 8, byrow = TRUE)
#
# dimnames(am) <-
#   list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
#        c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))
#
#
# # mehr zu aggregierende subitems
#
# subunits$unit[1:3] <- "I01"
#
#
# # aggregate units
# unitsAggregated <- mapply(aggregateData.aggregate, unitsToAggregate, aggregateinfo, MoreArgs = list(am, dat, verbose = verbose, suppressErr = suppressErr, recodeErr = recodeErr))
#
# if(!missing(unitsAggregated)){
#   datAggregated <- cbind(datAggregated, unitsAggregated, stringsAsFactors = FALSE)
# }
#
# --> kann das missing(unitsAggregated) hier überhaupt eintreten?
=======
# tests:

# checken, ob alle in den daten vorhandenen missingcodes in aggregatemissings abgedeckt sind!
# checken, ob alle in aggregatemissings vorhandenen rekodierungen zulässig sind (= in den spaltennamen von aggregatemmissings spezifiziert)

# was passiert, wenn in aggregatemissings spalten fehlen oder doppelt sind?
# prüfen, ob in Daten NA enthalten sind --> sollen in mbd umgewandelt werden
# was passiert, wenn keine vc enthalten sind



# Problem: in Beispieldaten sind gar keine Zweifelsfälle für aggregateData enthalten --> kommt immer vc raus
#  --> nur bei mci und mvi werden in aggregierten Daten Missings erzeugt, im Datensatz sind aber nur mbi
#  --> Alternative: aggregatemissings so spezifizieren, dass mbi + vc mbi ergibt

# Inputdatensatz: mehr zu aggregierende Items einfügen, in den ersten fünf Items



# err wenn vc auf mbi trifft
am <- matrix(c(
  "vc" , "mvi", "vc" , "mci", "err", "vc" , "err", "err",
  "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
  "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
  "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
  "err", "err", "err", "err", "mbd", "err", "err", "err",
  "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
  "err", "err", "mnr", "mci", "err", "mir", "mbi", "err",
  "err", "err", "err", "err", "err", "err", "err", "err" ),
  nrow = 8, ncol = 8, byrow = TRUE)

dimnames(am) <-
  list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
       c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))


# mehr zu aggregierende subitems

subunits$unit[1:3] <- "I01"


# aggregate units
unitsAggregated <- mapply(aggregateData.aggregate, unitsToAggregate, aggregateinfo, MoreArgs = list(am, dat, verbose = verbose, suppressErr = suppressErr, recodeErr = recodeErr))

if(!missing(unitsAggregated)){
  datAggregated <- cbind(datAggregated, unitsAggregated, stringsAsFactors = FALSE)
}

--> kann das missing(unitsAggregated) hier überhaupt eintreten?
>>>>>>> e0eb2e942a0e7c0028f7de6e06967a5ab731ac25
