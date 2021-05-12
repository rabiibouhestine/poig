import("R6")
import("raster")
export("gameManager")

#' R6 Class for the game manager
#'
#' the game manager controls the state of the game
gameManager <- R6Class("gameManager",
                        private = list(
                          state = NULL
                        ),
                        public = list(
                          data = NULL,
                          wonder_ids = NULL,
                          wonder_id = NULL,
                          score = 0,
                          level_score = 0,
                          wonders = 0,
                          life = 100000,
                          help = 3,
                          distance = NULL,
                          picture = NULL,
                          default_picture = NULL,

                          #' @description
                          #' Resets fields.
                          reset = function() {
                            self$score <- 0
                            self$level_score <- 0
                            self$wonders <- 0
                            self$life <- 100000
                            self$help <- 3
                            self$distance <- NULL
                            self$picture <- self$default_picture
                            self$wonder_ids <- seq(1:nrow(self$data))
                          },

                          #' @description
                          #' Creates a new data provider object.
                          #' @param config app.yml config file.
                          #' @return A new `stateManager` object.
                          use_help = function() {
                            if(self$help > 0) {
                              self$help <- self$help - 1
                            }
                          },

                          #' @description
                          #' updates game state
                          update_state = function(click_longitude, click_latitude) {
                            raw_distance_km <- pointDistance(
                              p1 = c(click_longitude, click_latitude),
                              p2 = c(self$data[self$wonder_id,]$longitude, self$data[self$wonder_id,]$latitude),
                              lonlat = TRUE
                            )

                            self$wonders <- self$wonders + 1
                            self$life <- max(0, self$life - (raw_distance_km/1000))

                            if(raw_distance_km < 1000) {
                              self$distance <- paste0(round(raw_distance_km, 0), " m")
                            } else {
                              self$distance <- paste0(round(raw_distance_km/1000, 0), " km")
                            }

                            self$level_score <- round(max(0, (5000 - (raw_distance_km %/% 1000))/100), 0)
                            self$score <- self$score + self$level_score
                          },

                          #' @description
                          #' Creates a new data provider object.
                          #' @param config app.yml config file.
                          #' @return A new `stateManager` object.
                          make_level = function() {
                            self$wonder_id <- sample(self$wonder_ids, 1)
                            self$wonder_ids <- setdiff(self$wonder_ids, self$wonder_id)
                            self$picture <- self$data[self$wonder_id,]$Picture.link
                          },

                          #' @description
                          #' Creates a new data provider object.
                          #' @param config app.yml config file.
                          #' @return A new `stateManager` object.
                          initialize = function(data, default_picture) {
                            self$data <- data
                            self$wonder_ids <- seq(1:nrow(data))
                            self$picture <- default_picture
                            self$default_picture <- default_picture
                          }
                        )
)
