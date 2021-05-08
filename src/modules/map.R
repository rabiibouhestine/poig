

# Define the UI for a module
mapUI <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = 600)
}

# Define the server logic for a module
mapServer <- function(id, data, game_in_progress = FALSE, wonder = NULL) {
  moduleServer(
    id,
    function(input, output, session) {

      # ICONS
      crossIcon <- leaflet::makeIcon(
        iconUrl = "http://simpleicon.com/wp-content/uploads/cross.png",
        iconWidth = 50, iconHeight = 50
      )
      wonderIcon <- leaflet::makeIcon(
        iconUrl = "https://static.thenounproject.com/png/7224-200.png",
        iconWidth = 50, iconHeight = 50
      )
      helpIcon <- leaflet::makeIcon(
        iconUrl = "https://toppng.com/uploads/preview/question-mark-icon-png-1155224288245ptwi4q2v.png",
        iconWidth = 50, iconHeight = 50
      )
      
      # RENDER MAP
      output$map <- renderLeaflet({
        data %>%
          leaflet() %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          fitBounds(
            lng1 = 55.9933127,
            lat1 = -19.6848415,
            lng2 = 2.3194052,
            lat2 = 104.416721
          )
      })

      # INITIALISE MAP
      initialise <- function() {
        leafletProxy("map", session, data) %>%
          clearMarkers() %>%
          clearShapes() %>%
          addMarkers(
            lng = ~longitude,
            lat = ~latitude,
            icon = leaflet::makeIcon(
              iconUrl = ~Picture.link,
              iconWidth = 50, iconHeight = 50
            )
          ) %>%
          flyToBounds(
            lng1 = 55.9933127,
            lat1 = -19.6848415,
            lng2 = 2.3194052,
            lat2 = 104.416721,
            options = list(duration = 0.5)
          )
      }

      # START LEVEL
      start_level <- function() {
        leafletProxy("map", session) %>%
          clearMarkers() %>%
          clearShapes() %>%
          flyToBounds(
            lng1 = 55.9933127,
            lat1 = -19.6848415,
            lng2 = 2.3194052,
            lat2 = 104.416721,
            options = list(duration = 0.5)
          )
      }

      # SHOW HELP
      show_help <- function() {
        n_wonders <- nrow(data)
        wrong_wonders <- setdiff(seq(1:n_wonders), wonder())
        help_wonders <- c(wonder(), sample(wrong_wonders, 5))
        help_data <- data[help_wonders,]
        leafletProxy("map", session, help_data) %>%
          addMarkers(
            lng = ~longitude,
            lat = ~latitude,
            icon = helpIcon
          )
      }

      # MAP CLICK EVENT
      observeEvent(input$map_click, {
        if(isTRUE(game_in_progress())){
          wonder_data <- data[wonder(),]
          leafletProxy("map", session) %>%
            addMarkers(
              data = wonder_data,
              lng = ~longitude,
              lat = ~latitude,
              icon =  leaflet::makeIcon(
                iconUrl = ~Picture.link,
                iconWidth = 50, iconHeight = 50
              )
            ) %>%
            addMarkers(
              lng = input$map_click$lng,
              lat = input$map_click$lat,
              icon = crossIcon
            ) %>%
            addPolylines(
              lng = c(input$map_click$lng, wonder_data$longitude),
              lat = c(input$map_click$lat, wonder_data$latitude)
            ) %>%
            flyToBounds(
              lng1 = input$map_click$lng,
              lat1 = input$map_click$lat,
              lng2 = wonder_data$longitude,
              lat2 = wonder_data$latitude,
              options = list(duration = 0.8)
            )
        }
      })

      return(
        list(
          initialise = initialise,
          start_level = start_level,
          show_help = show_help,
          click = reactive(input$map_click)
        )
      )
    }
  )
}