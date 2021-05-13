

# Define the UI for the map module
mapUI <- function(id) {
  ns <- NS(id)
  leafletOutput(ns("map"), height = 600)
}

# Define the server logic for the map module
mapServer <- function(id, data, is_level_in_progress = FALSE, wonder = NULL) {
  moduleServer(
    id,
    function(input, output, session) {

      # RENDER MAP
      output$map <- renderLeaflet({
        data %>%
          leaflet(options = leafletOptions(minZoom = 2, maxZoom = 10)) %>%
          addProviderTiles(providers$CartoDB.Positron) %>%
          fitBounds(
            lng1 = -178.9398,
            lat1 = 80.2385,
            lng2 = 201.0992,
            lat2 = -53.33087
          )
      })

      # INITIALISE MAP
      initialise <- function() {
        leafletProxy("map", session, data) %>%
          clearMarkers() %>%
          clearPopups() %>%
          clearControls() %>%
          clearShapes() %>%
          addMarkers(
            lng = ~longitude,
            lat = ~latitude,
            icon = leaflet::makeIcon(
              iconUrl = ~Picture.link,
              iconWidth = 50, iconHeight = 50,
              className = "wonder-icon"
            ),
            popup = paste0(
              "<b>Wonder: </b>"
              , data$Name
              , "<br>"
              , "<b>Location: </b>"
              , data$Location
              , "<br>"
              , "<a href='"
              , data$Wikipedia.link
              , "' target='_blank'>"
              , "Click Here to View Wiki</a>"
            )
          ) %>%
          flyToBounds(
            lng1 = -178.9398,
            lat1 = 80.2385,
            lng2 = 201.0992,
            lat2 = -53.33087,
            options = list(duration = 0.5)
          )
      }

      # START LEVEL
      start_level <- function() {
        leafletProxy("map", session) %>%
          clearMarkers() %>%
          clearPopups() %>%
          clearControls() %>%
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
          addCircles(
            lng = ~longitude,
            lat = ~latitude,
            radius = 1000000,
            options = pathOptions(interactive = FALSE),
            color = "#0078d4",
            weight = 0,
            opacity = 0.4,
            fill = TRUE,
            fillColor = "#0078d4",
            fillOpacity = 0.4
          )
      }

      # SHOW DISTANCE
      show_distance <- function(distance, level_score) {
        leafletProxy("map", session) %>%
          addControl(
            html = tags$div(
              HTML(
                paste0("Distance: ", distance, "<br> Score: + ", level_score)
                )
            ),
            position = "bottomleft")
      }

      # MAP CLICK EVENT
      observeEvent(input$map_click, {
        if(isTRUE(is_level_in_progress())){
          wonder_data <- data[wonder(),]
          leafletProxy("map", session) %>%
            clearShapes() %>%
            addMarkers(
              data = wonder_data,
              lng = ~longitude,
              lat = ~latitude,
              icon =  leaflet::makeIcon(
                iconUrl = ~Picture.link,
                iconWidth = 50, iconHeight = 50,
                className = "wonder-icon"
              ),
              popup = paste0(
                "<b>Wonder: </b>"
                , wonder_data$Name
                , "<br>"
                , "<b>Location: </b>"
                , wonder_data$Location
                , "<br>"
                , "<a href='"
                , wonder_data$Wikipedia.link
                , "' target='_blank'>"
                , "Click Here to View Wiki</a>"
              )
            ) %>%
            addPopups(
              data = wonder_data,
              lng = ~longitude,
              lat = ~latitude,
              popup = paste0(
                "<b>Wonder: </b>"
                , wonder_data$Name
                , "<br>"
                , "<b>Location: </b>"
                , wonder_data$Location
                , "<br>"
                , "<a href='"
                , wonder_data$Wikipedia.link
                , "' target='_blank'>"
                , "Click Here to View Wiki</a>"
              ),
              options = popupOptions(closeButton = FALSE)
            ) %>%
            addMarkers(
              lng = input$map_click$lng,
              lat = input$map_click$lat,
              icon = leaflet::makeIcon(
                iconUrl = "http://simpleicon.com/wp-content/uploads/cross.png",
                iconWidth = 50, iconHeight = 50
              )
            ) %>%
            flyToBounds(
              lng1 = input$map_click$lng,
              lat1 = input$map_click$lat,
              lng2 = wonder_data$longitude,
              lat2 = wonder_data$latitude,
              options = list(duration = 0.8, padding = c(100, 100))
            )
        }
      })

      return(
        list(
          initialise = initialise,
          start_level = start_level,
          show_help = show_help,
          show_distance = show_distance,
          click = reactive(input$map_click)
        )
      )
    }
  )
}