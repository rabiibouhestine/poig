# Define UI for WondeR GuesseR
ui <- fluidPage(
  tags$link(href = "style.css", rel = "stylesheet", type = "text/css"),

  reactOutput("rules_modal"),
  reactOutput("game_over_modal"),

  fluidRow(
    column(7, offset = 1,
           div(class = "map-panel",
             mapUI("map")
           )
    ),
    column(3,
           fluidRow(
             column(12,
                    uiOutput("wonder_image")
             )
           ),
           fluidRow(
             column(12,
                    div(class = "progress-bar-panel",
                      progressBar(
                        id = "wonders",
                        title = "Wonders played",
                        value = 0,
                        total = 50,
                        status = "primary",
                        display_pct = TRUE
                      )
                    )
             )
           ),
           fluidRow(
             column(12,
                    div(class = "progress-bar-panel",
                      progressBar(
                        id = "life",
                        title = "Remaining distance (km)",
                        value = 0,
                        total = 20000,
                        status = "sucess",
                        display_pct = TRUE,
                        striped = TRUE
                      )
                    )
             )
           ),
           fluidRow(
             column(12,
                    div(class = "main-buttons",
                      Stack(
                        div(class = "score-panel",
                            textOutput("score")
                        ),
                        reactOutput("rules_btn"),
                        reactOutput("start_btn"),
                        horizontal = TRUE,
                        tokens = list(childrenGap = 20)
                      )
                    )
             )
           )
    )
  )
)
