# Vector print modification (other cli class definitions go here)
cli_setting <- function(.envir = parent.frame()) {
  start_app(
    .auto_close = TRUE,
    .envir = .envir,
    theme = list(
      "body" = list("vec-trunc" = Inf),
      # Unit
      ".unit-id" = list("color" = "#f87171"),
      ".unit-key" = list("color" = "#c9677a"),
      ".unit-label" = list("color" = "#fca5a5"),
      # Booklet
      ".booklet-id" = list("color" = "#bef264"),
      ".booklet-label" = list("color" = "#8BE836"),
      # Testtaker
      ".testtaker-id" = list("color" = "#fde047"),
      ".testtaker-label" = list("color" = "#FFC142"),
      # Testtaker Group
      ".testtakergroup-id" = list("color" = "#7dd3fc"),
      ".testtakergroup-label" = list("color" = "#38bdf8"),
      # Info
      ".comment" = list("color" = "#4a30db")
    )
  )
}
