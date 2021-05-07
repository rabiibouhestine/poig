library(leaflet)
library(leaflet.providers)
library(raster)
library(modules)
library(shinyjs)
library(shinyWidgets)

source("modules/map.R")

wow <- read.csv("data/wonders_of_world.csv")


gameManager <- use("objects/game_manager.R")$gameManager

default_image <- "data:image/png;base64,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"


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


rules_modal <- function() {
  showModal(
    modalDialog(
      title = "Game RULES",
      easyClose = TRUE,
      size = "l",
      footer = tagList(
      )
    )
  )
}