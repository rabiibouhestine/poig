import("shiny")
export("GameEventReactiveTrigger")

GameEventReactiveTrigger <- function() {
  rv <- reactiveValues(a = 0, b = 0)
  list(
    next_level = function() {
      rv$a
      invisible()
    },
    reset_game = function() {
      rv$b
      invisible()
    },
    trigger_next_level = function() {
      rv$a <- isolate(rv$a + 1)
    },
    trigger_reset_game = function() {
      rv$b <- isolate(rv$b + 1)
    }
  )
}
