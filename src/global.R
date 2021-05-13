library(leaflet)
library(leaflet.providers)
library(raster)
library(modules)
library(shinyjs)
library(shinyWidgets)
library(shiny.fluent)

source("modules/map.R")

wow <- read.csv("data/wonders.csv")

gameManager <- use("objects/game_manager.R")$gameManager

utils <- use("utils/utils.R")
