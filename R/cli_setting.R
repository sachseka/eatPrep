# Vector print modification (other cli class definitions go here)
cli_setting <- function(.envir = parent.frame()) {
  start_app(
    .auto_close = TRUE,
    .envir = .envir,
    theme = list(
      body = list("vec-trunc" = Inf)
    )
  )
}
