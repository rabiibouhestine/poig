# Define server logic required to draw a histogram ----
server <- function(input, output, session) {

  # INITIALISE GAME MANAGER
  game_manager <- gameManager$new(wow, default_image)

  # INITIALISE GAME LOGIC TRIGGERS
  game_events <- GameEventReactiveTrigger()

  # INITIALISE GAME STATE VARIABLES
  wonders <- reactiveVal(game_manager$wonders)
  life <- reactiveVal(game_manager$life)
  score <- reactiveVal(game_manager$score)
  help <- reactiveVal(game_manager$help)
  distance <- reactiveVal(game_manager$distance)
  current_wonder_image <- reactiveVal(game_manager$picture)
  current_wonder <- reactiveVal(game_manager$wonder_id)
  game_in_progress <- reactiveVal(FALSE)

  # RENDER MAP
  map <- mapServer("map", wow, reactive(game_in_progress()), reactive(current_wonder()))

  # WONDER IMAGE
  output$wonder_image <- renderUI({
    DocumentCard(
      DocumentCardPreview(
        previewImages = list(
          list(
            previewImageSrc = current_wonder_image(),
            width = "100%",
            height = 240
          )
        )
      ),
      DocumentCardActivity(
        activity = "Created a few minutes ago",
        people = list(list(name = "Wonder Full Name"))
      )
    )
  })

  # SCORE TEXT
  output$score <- renderText({
    paste0("Score: ", score())
  })

  # LIFE INDICATOR
  observeEvent(wonders(), {
    updateProgressBar(
      session = session,
      id = "wonders",
      value = wonders(),
      total = 50
      )
  })

  # LIFE INDICATOR
  observeEvent(life(), {
    if (life() < 25000) {
      status <- "danger"
    } else if (life() >= 25000 & life() < 50000) {
      status <- "warning"
    } else if (life() >= 50000 & life() < 75000) {
      status <- "info"
    } else {
      status <- "success"
    }
    updateProgressBar(
      session = session,
      id = "life",
      value = life(),
      total = 100000,
      status = status
    )
  })

  # HELP BUTTON LOGIC
  observeEvent(input$help.btn, {
    game_manager$use_help()
    help(game_manager$help)
    map$show_help()
  })

  # UPDATE HELP BUTTON LABEL
  observe({
    updateActionButton(
      inputId = "help.btn",
      label = paste0("Help (", help(), ")")
    )
    if(help() == 0 || !game_in_progress()) {
      shinyjs::disable('help.btn')
    } else {
      shinyjs::enable('help.btn')
    }
  })

  # RULES MODAL
  session$onFlushed( function() rules_modal(), once = TRUE )
  observeEvent(input$rules.btn, {
    rules_modal()
  })

  # START/RESET BUTTON LOGIC
  observeEvent(input$start.btn,{
    if (game_in_progress()) {
      game_events$trigger_reset_game()
    } else {
      game_events$trigger_next_level()
    }
  })

  # NEXT LEVEL BUTTON LOGIC (IN POST CLICK MODAL)
  observeEvent(input$next_level,{
    game_events$trigger_next_level()
  })

  # RESET BUTTON LOGIC (IN END GAME MODAL)
  observeEvent(input$reset_game,{
    game_events$trigger_reset_game()
  })

  # TRIGGER NEXT LEVEL
  observe({
    game_events$next_level()  # Triggers this observer
    removeModal()
    game_manager$make_level()
    current_wonder(game_manager$wonder_id)
    current_wonder_image(game_manager$picture)
    map$start_level()
    game_in_progress(TRUE)
    updateActionButton(
      inputId = "start.btn",
      label = "Reset"
    )
  })

  # TRIGGER RESET GAME
  observe({
    game_events$reset_game() # Triggers this observer
    removeModal()
    game_manager$reset()
    score(game_manager$score)
    wonders(game_manager$wonders)
    life(game_manager$life)
    help(game_manager$help)
    current_wonder_image(game_manager$picture)
    map$initialise()
    game_in_progress(FALSE)
    updateActionButton(
      inputId = "start.btn",
      label = "Start"
    )
  })
  
  # GAMEPLAY LOGIC
  observeEvent(map$click(), {
    if (game_in_progress()) {
      
      game_manager$update_state(
        map$click()$lng,
        map$click()$lat
      )
      
      score(game_manager$score)
      wonders(game_manager$wonders)
      life(game_manager$life)
      distance(game_manager$distance)
      
      if(life() == 0 || wonders() == 50) {
        showModal(
          modalDialog(
            title = "Game Over",
            paste0("Score: ", score()),
            easyClose = FALSE,
            size = "m",
            footer = tagList(
              actionButton("reset_game", "Restart")
            )
          )
        )
      } else {
        showModal(
          modalDialog(
            title = paste0("Distance: ", distance()),
            easyClose = FALSE,
            size = "m",
            footer = tagList(
              actionButton("next_level", "Next >")
            )
          )
        )
      }
      
    }
  })
  
}
