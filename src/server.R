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

  is_game_in_progress <- reactiveVal(FALSE)
  is_level_in_progress <- reactiveVal(FALSE)
  is_rules_modal_open <- reactiveVal(TRUE)
  is_game_over_modal_open <- reactiveVal(FALSE)
  is_help_button_disabled <- reactiveVal(FALSE)

  start_button_text <- reactiveVal("Start")
  start_button_icon <- reactiveVal("play")

  # RENDER MAP
  map <- mapServer("map", wow, reactive(is_level_in_progress()), reactive(current_wonder()))

  # WONDER IMAGE
  output$wonder_image <- renderUI({
    if(is_game_in_progress()){
      Stack(
        h6("Locate this wonder on the map"),
        img(height = 240, width = "100%", src = current_wonder_image()),
        Stack(
          PrimaryButton.shinyInput(
            "help.btn",
            text = paste0("Help (", help()," )"),
            disabled = is_help_button_disabled(),
            iconProps = list("iconName" = "Nav2DMapView")
          ),
          PrimaryButton.shinyInput(
            "next_level",
            text = "Next Wonder >",
            disabled = is_level_in_progress()
          ),
          horizontal = TRUE,
          tokens = list(childrenGap = 20)
        ),
        horizontal = FALSE,
        tokens = list(childrenGap = 20)
      )
    } else {
      h1("WondeR GuesseR")
    }
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
    is_help_button_disabled(TRUE)
    game_manager$use_help()
    help(game_manager$help)
    map$show_help()
  })

  # RENDER GAME OVER MODAL
  output$game_over_modal <- renderReact({
    Dialog(
      hidden = !is_game_over_modal_open(),
      type = 0,
      title = 'GAME OVER',
      closeButtonAriaLabel = 'Close',
      div(
        paste0("Wonders played: ", wonders(), "/50"),
        br(),
        paste0("Score: ", score())
      ),
      DialogFooter(
        PrimaryButton.shinyInput("reset_game", text = "Restart")
      )
    )
  })

  # SHOW/HIDE GAME OVER MODAL
  observeEvent(input$reset_game, is_game_over_modal_open(FALSE))

  # RENDER RULES MODAL
  output$rules_modal <- renderReact({
    Dialog(
      type = 0,
      title = 'WondeR GuesseR Rules',
      closeButtonAriaLabel = 'Close',
      div(
        "Locate the wonder in the top right image is on the map"
      ),
      hidden = !is_rules_modal_open(),
      DialogFooter(
        PrimaryButton.shinyInput("rules_ok", text = "Got it!")
      )
    )
  })

  # SHOW/HIDE RULES MODAL
  observeEvent(input$rules.btn, is_rules_modal_open(TRUE))
  observeEvent(input$rules_ok, is_rules_modal_open(FALSE))

  # RENDER RULES BUTTON
  output$rules_btn <- renderReact({
    PrimaryButton.shinyInput(
      "rules.btn",
      text = "Rules",
      iconProps = list("iconName" = "TextDocument")
    )
  })

  # RENDER START BUTTON
  output$start_btn <- renderReact({
    PrimaryButton.shinyInput(
      "start.btn",
      text = start_button_text(),
      iconProps = list("iconName" = start_button_icon())
    )
  })

  # START/RESET BUTTON LOGIC
  observeEvent(input$start.btn,{
    if (is_game_in_progress()) {
      is_game_in_progress(FALSE)
      game_events$trigger_reset_game()
    } else {
      is_game_in_progress(TRUE)
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
    game_manager$make_level()
    current_wonder(game_manager$wonder_id)
    current_wonder_image(game_manager$picture)
    map$start_level()
    is_level_in_progress(TRUE)
    start_button_text("Reset")
    start_button_icon("PlaybackRate1x")
    if(isolate(help()) > 0) {
      is_help_button_disabled(FALSE)
    }
  })

  # TRIGGER RESET GAME
  observe({
    game_events$reset_game() # Triggers this observer
    game_manager$reset()
    score(game_manager$score)
    wonders(game_manager$wonders)
    life(game_manager$life)
    help(game_manager$help)
    current_wonder_image(game_manager$picture)
    map$initialise()
    is_game_in_progress(FALSE)
    is_level_in_progress(FALSE)
    start_button_text("Start")
    start_button_icon("Play")
  })
  
  # GAMEPLAY LOGIC
  observeEvent(map$click(), {
    if (is_level_in_progress()) {
      # update game session variables
      game_manager$update_state(map$click()$lng, map$click()$lat)
      score(game_manager$score)
      wonders(game_manager$wonders)
      life(game_manager$life)
      distance(game_manager$distance)
      is_level_in_progress(FALSE)
      is_help_button_disabled(TRUE)
      # show/hide modals
      if(life() == 0 || wonders() == 50) {
        is_game_over_modal_open(TRUE)
      }
    }
  })
  
  

}
