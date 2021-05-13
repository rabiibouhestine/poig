# Define server logic required to draw a histogram ----
server <- function(input, output, session) {

  # INITIALISE GAME MANAGER
  game_manager <- gameManager$new(data = wow)

  # INITIALISE GAME LOGIC TRIGGERS
  game_events <- utils$GameEventReactiveTrigger()

  # INITIALISE GAME STATE VARIABLES
  wonders <- reactiveVal(game_manager$wonders)
  life <- reactiveVal(game_manager$life)
  score <- reactiveVal(game_manager$score)
  level_score <- reactiveVal(game_manager$level_score)
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
      div(class = "image-panel",
          div(class = "image-panel-title",
            "Locate the wonder shown in this image on the map"
          ),
          div(class = "image-panel-picture",
            img(height = 247, width = "100%", src = current_wonder_image())
          ),
          div(class = "image-panel-buttons",
            Stack(
              PrimaryButton.shinyInput(
                "help.btn",
                text = paste0("Tips (", help()," )"),
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
            )
          )
      )
    } else {
      div(class = "image-panel",
          img(height = 347, width = "100%", src = "wonder_guesser.png")
      )
    }
  })

  # SCORE TEXT
  output$score <- renderText({
    paste0("Score: ", score())
  })

  # UPDATE WONDERS PLAYED PROGRESS BAR
  observeEvent(wonders(), {
    updateProgressBar(
      session = session,
      id = "wonders",
      value = wonders(),
      total = 38
      )
  })

  # UPDATE REMAINING DISTANCE PROGRESS BAR
  observeEvent(life(), {
    if (life() < 5000) {
      status <- "danger"
    } else if (life() >= 5000 & life() < 10000) {
      status <- "warning"
    } else if (life() >= 10000 & life() < 15000) {
      status <- "info"
    } else {
      status <- "success"
    }
    updateProgressBar(
      session = session,
      id = "life",
      value = life(),
      total = 20000,
      status = status
    )
  })

  # TIPS BUTTON LOGIC
  observeEvent(input$help.btn, {
    is_help_button_disabled(TRUE)
    game_manager$use_help()
    help(game_manager$help)
    map$show_help()
  })

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

  # NEXT LEVEL BUTTON LOGIC
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
    level_score(game_manager$level_score)
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
  
  # MAP CLICK EVENT
  observeEvent(map$click(), {
    if (is_level_in_progress()) {
      # update game session variables
      game_manager$update_state(map$click()$lng, map$click()$lat)
      score(game_manager$score)
      level_score(game_manager$level_score)
      wonders(game_manager$wonders)
      life(game_manager$life)
      distance(game_manager$distance)
      map$show_distance(distance(), level_score())
      is_level_in_progress(FALSE)
      is_help_button_disabled(TRUE)
      # TRIGGER GAME OVER MODAL
      if(life() == 0 || wonders() == 38) {
        is_game_over_modal_open(TRUE)
      }
    }
  })

  # RENDER GAME OVER MODAL
  output$game_over_modal <- renderReact({
    Dialog(
      hidden = !is_game_over_modal_open(),
      type = 0,
      title = 'GAME OVER',
      closeButtonAriaLabel = 'Close',
      div(
        paste0("Wonders played: ", wonders(), "/38"),
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
      title = 'WondeR GuesseR',
      closeButtonAriaLabel = 'Close',
      div(
        h4("Wonder Guesser is a game that tests your knowledge of 38 curated wonders of the world."),
        h4("These range from natural wonders to industrial achievements. Try to locate each wonder on the map."),
        h3("How to play:"),
        tags$ol(
          tags$li("Click on the start button to start the game."),
          tags$li("A wonder image will be displayed in the top right corner."),
          tags$li("Try to locate the wonder on the map (click on where you think it is)."),
          tags$li("After clicking, the correct location will be displayed."),
          tags$li("Your score will increase dependeing on the distance of your click from the correct location."),
          tags$li("The distance of your click from the correct location will be substracted from 'Remaining distance'."),
          tags$li("click on the Next button to move to the next wonder"),
          tags$li("keep playing untill you either run out of 'Remaining distance' or finish playing all 38 wonders")
        ),
        h3("Rules:"),
        tags$ul(
          tags$li("'Remaining distance' starts at 20000 km."),
          tags$li("You can use tips up to 3 times"),
          tags$li("Tips will highlight possible areas where the wonder might be located")
        ),
        p(strong("Note: "), "Clicking on a wonder icon on the map will display information (name, location and a wikipedia link).")
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
  

}
