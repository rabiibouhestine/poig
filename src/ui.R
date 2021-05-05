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
                      sliderInput("wonders", label = "wonders", min = 0, max = 50, value = 0)
                    )
             )
           ),
           fluidRow(
             column(12,
                    wellPanel(
                      sliderInput("life", label = "life", min = 0, max = 100000, value = 100000)
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
