# Define UI for app that draws a histogram ----
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      .btn {
        margin-bottom: 20px !important;
      }"))
  ),
  shinyjs::useShinyjs(),
  titlePanel("WondeR GuesseR"),
  
  fluidRow(
    
    column(9,
           wellPanel(
             mapUI("map")
           )
    ),
    
    column(3,
           fluidRow(
             column(12,
                    wellPanel(
                      uiOutput("wonder_image")
                    )
             )
           ),
           fluidRow(
             column(12,
                    wellPanel(
                      progressBar(
                        id = "wonders",
                        title = "wonders played",
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
                    wellPanel(
                      progressBar(
                        id = "life",
                        title = "distance used (km)",
                        value = 0,
                        total = 100000,
                        status = "sucess",
                        display_pct = TRUE,
                        striped = TRUE
                      )
                    )
             )
           ),
           fluidRow(
             column(12,
                    wellPanel(
                      textOutput("score")
                    )
             )
           ),
           fluidRow(
             column(12,
                    actionButton(
                      inputId = "rules.btn",
                      label = "Rules",
                      icon = NULL,
                      width = "100%"
                    )
             )
           ),
           fluidRow(
             column(12,
                    actionButton(
                      inputId = "help.btn",
                      label = "Help (3)",
                      icon = NULL,
                      width = "100%"
                    )
             )
           ),
           fluidRow(
             column(12,
                    actionButton(
                      inputId = "start.btn",
                      label = "Start",
                      icon = NULL,
                      width = "100%"
                    )
             )
           )
    )
  )
)
