# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  titlePanel("Point of Interest Guesser"),
  
  fluidRow(
    
    column(9,
           wellPanel(
             leafletOutput("map", height = 800)
           )
    ),
    
    column(3,
           fluidRow(
             column(12,
                    wellPanel(
                      textOutput("score")
                    )
             )
           ),
           fluidRow(
             column(12,
                    wellPanel(
                      actionButton(
                        inputId = "help.btn",
                        label = "Help",
                        icon = NULL,
                        width = "100%"
                        )
                    )
             )
           ),
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
                      actionButton(
                        inputId = "rules.btn",
                        label = "Rules",
                        icon = NULL,
                        width = "100%"
                      )
                    )
             )
           ),
           fluidRow(
             column(12,
                    wellPanel(
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
)
