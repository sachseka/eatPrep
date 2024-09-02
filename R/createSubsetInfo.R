createSubsetInfo <- function(tsp, booklets=NULL, blocks=NULL) {

  checkmate::assert_data_frame(tsp, min.rows = 1)
  lapply(list(booklets, blocks), checkmate::assert_data_frame, min.rows = 1, null.ok=TRUE)




}
