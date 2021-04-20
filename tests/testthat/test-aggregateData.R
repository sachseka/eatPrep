# tests:

# checken, ob alle in den daten vorhandenen missingcodes in aggregatemissings abgedeckt sind
# was passiert, wenn in aggregatemissings spalten fehlen oder doppelt sind?
# prüfen, ob in Daten NA enthalten sind


# Problem: in Beispieldaten sind gar keine Zweifelsfälle für aggregateData enthalten --> kommt immer vc raus
#  --> nur bei mci und mvi werden in aggregierten Daten Missings erzeugt, im Datensatz sind aber nur mbi
#  --> Alternative: aggregatemissings so spezifizieren, dass mbi + vc mbi ergibt

# Inputdatensatz: mehr zu aggregierende Items einfügen, in den ersten fünf Items


am <- matrix(c(
  "vc" , "mvi", "vc" , "mci", "err", "vc" , "mbi", "err",
  "mvi", "mvi", "err", "mci", "err", "err", "err", "err",
  "vc" , "err", "mnr", "mci", "err", "mir", "mnr", "err",
  "mci", "mci", "mci", "mci", "err", "mci", "mci", "err",
  "err", "err", "err", "err", "mbd", "err", "err", "err",
  "vc" , "err", "mir", "mci", "err", "mir", "mir", "err",
  "mbi", "err", "mnr", "mci", "err", "mir", "mbi", "err",
  "err", "err", "err", "err", "err", "err", "err", "err" ),
  nrow = 8, ncol = 8, byrow = TRUE)

dimnames(am) <-
  list(c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"),
       c("vc" ,"mvi", "mnr", "mci",  "mbd", "mir", "mbi", "err"))
