# Define server logic required to draw a histogram ----
server <- function(input, output, session) {

  # GAME STAT VARIABLES
  score <- reactiveVal(0)
  state <- reactiveVal()
  new_level <- reactiveVal()
  distance <- reactiveVal()
  current_wonder <- reactiveVal()
  current_wonder_image <- reactiveVal(
    "http://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/%E5%B8%83%E8%BE%BE%E6%8B%89%E5%AE%AB.jpg/220px-%E5%B8%83%E8%BE%BE%E6%8B%89%E5%AE%AB.jpg"
  )

  # SHOW WONDER IMAGE
  output$wonder_image <- renderUI({
    tags$img(height = 400, width = 400, src = current_wonder_image())
  })

  # RENDER MAP
  output$map <- renderLeaflet({
    wow %>%
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addMarkers(group = "all_wonders")
  })

  # SCORE TEXT
  output$score <- renderText({
    paste0("Score: ", score())
  })
observe(print((new_level())))
  # START LEVEL EVENT
  observeEvent(new_level(), {

    leafletProxy("map", session) %>%
      clearMarkers() %>%
      clearGroup("connecting_line")

    random_wonder <- sample(1:50, 1)
    current_wonder(
      wow[random_wonder,]
    )

    current_wonder_image(
      current_wonder()$Picture.link
    )
  })

  # MAP CLICK EVENT
  observeEvent(input$map_click, {
    
    leafletProxy("map", session) %>%
      addMarkers(data = current_wonder(), group = "current_wonder") %>%
      addMarkers(lng = input$map_click$lng, lat = input$map_click$lat, group = "player_click") %>%
      addPolylines(
        lng = c(input$map_click$lng, current_wonder()$Longitude),
        lat = c(input$map_click$lat, current_wonder()$Latitude),
        group = "connecting_line"
      )

    distance(
      pointDistance(
        p1 = c(input$map_click$lng, input$map_click$lat),
        p2 = c(current_wonder()$Longitude, current_wonder()$Latitude),
        lonlat = TRUE
      )
    )

    showModal(
      modalDialog(
        title = paste0("Distance: ", distance()),
        easyClose = FALSE,
        size = "m",
        footer = tagList(
          actionButton("new_level", "Next >")
        )
      )
    )
  })

  # NEW LEVEL EVENTS
  observeEvent(input$start.btn,{
      new_level(runif(1, 0, 1))
  }, ignoreInit = TRUE)

  observeEvent(input$new_level,{
    removeModal()
    new_level(runif(1, 0, 1))
  }, ignoreInit = TRUE)

}
