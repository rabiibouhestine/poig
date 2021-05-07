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
  
  is_level_panel_open <- reactiveVal(FALSE)
  is_help_button_disabled <- reactiveVal(TRUE)
  start_button_text <- reactiveVal("Start")

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

  # HELP BUTTON ENABLE/DISABLE
  observe({
    if(help() == 0 || !game_in_progress()) {
      is_help_button_disabled(TRUE)
    } else {
      is_help_button_disabled(FALSE)
    }
  })

  # RULES MODAL
  session$onFlushed( function() rules_modal(), once = TRUE )
  observeEvent(input$rules.btn, {
    rules_modal()
  })

  # RENDER LEVEL PANEL
  output$level_panel <- renderReact({
    Panel(
      headerText = "Sample panel",
      isOpen = is_level_panel_open(),
      paste0("Distance: ", distance()),
      PrimaryButton.shinyInput("next_level", text = "Next Wonder >"),
      onDismiss = JS("function() { Shiny.setInputValue('next_level', Math.random()); }"),
      customWidth = "400px"
    )
  })

  # RENDER RULES BUTTON
  output$rules_btn <- renderReact({
    PrimaryButton.shinyInput(
      "rules.btn",
      text = "Rules",
      iconProps = list("iconName" = "AddFriend")
    )
  })

  # RENDER HELP BUTTON
  output$help_btn <- renderReact({
    PrimaryButton.shinyInput(
      "help.btn",
      text = paste0("Help (", help()," )"),
      disabled = is_help_button_disabled(),
      iconProps = list("iconName" = "AddFriend")
    )
  })

  # RENDER START BUTTON
  output$start_btn <- renderReact({
    PrimaryButton.shinyInput(
      "start.btn",
      text = start_button_text(),
      iconProps = list("iconName" = "AddFriend")
    )
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
    is_level_panel_open(FALSE)
    removeModal()
    game_manager$make_level()
    current_wonder(game_manager$wonder_id)
    current_wonder_image(game_manager$picture)
    map$start_level()
    game_in_progress(TRUE)
    start_button_text("Reset")
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
    start_button_text("Start")
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
      
      is_level_panel_open(TRUE)
      
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
      } 
    }
  })
  
  

}
