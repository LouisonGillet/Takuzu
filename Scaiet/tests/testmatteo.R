library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyalert)


ui <- fluidPage(

  theme = shinytheme("sandstone"),

  # Ajouter la balise audio pour jouer la musique en arrière-plan
  tags$audio(id = "musique", src = "musique2.mp3", type = "audio/mp3", autoplay = TRUE, loop = TRUE, style = "display: none;"),

  titlePanel(
    h1(
      strong(
        em(
          HTML("<p style='color: #784212;
                   text-align: center;
                   font-family: Monaco;'>Takuzu</p>")
        )
      )
    ),
    windowTitle = "Jeu du Takuzu"
  ),

  sidebarLayout(
    sidebarPanel(
      selectInput("grid_size", "Taille de la grille", choices = c(4, 6, 8), selected = 8),
      selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
      actionButton("new_game", "Nouvelle Partie"),
      actionButton("check_grid", "Vérifier"),
      textOutput("result"),
      textOutput("timer")

    ),

    mainPanel(
      tableOutput("grille_boutons")
    )
  )
)



server <- function(input, output, session) {
  nRows = reactive({ as.numeric(input$grid_size) })
  nCols = nRows
  niveau = reactive({ input$niveau })
  debut_temps = reactiveVal(NULL)
  depart_chrono = reactiveVal(FALSE)

  rv = reactiveValues(grille = NULL, verrouillees = NULL)

  # Observer la nouvelle partie
  observeEvent(input$new_game, {
    debut_temps(Sys.time())
    depart_chrono(TRUE)
    showNotification(paste("Nouvelle partie - Niveau :", niveau(), "- Taille :", nRows(), "x", nCols()), type = "message")
    grille_init = generer_takuzu(nRows(),niveau())
    rv$grille = grille_init
    rv$verrouillees = !is.na(grille_init)
    output$result = renderText("Nouvelle partie commencée ! Bonne chance ")
  })

  # Affichage du chronomètre en temps réel
  output$timer <- renderText({
    req(debut_temps(), depart_chrono())  # Assure que la partie a commencé et que le chrono tourne
    invalidateLater(1000, session)  # Met à jour chaque seconde
    temps_ecoule = difftime(Sys.time(), debut_temps(), units = "secs")
    paste("Temps écoulé :", round(temps_ecoule), "secondes")
  })

  # Affichage des boutons de la grille
  output$grille_boutons <- renderUI({
    boutons <- lapply(1:nRows(), function(i) {
      fluidRow(
        lapply(1:nCols(), function(j) {
          valeur_case = rv$grille[i, j]
          actionButton(inputId = paste("bouton", i, j, sep = "_"),
                       label = ifelse(is.na(rv$grille[i, j]), "", as.character(rv$grille[i, j])),
                       style = "width: 50px; height: 50px; font-size: 18px; margin: 5px;",
                       disabled = rv$verrouillees[i, j])
        })
      )
    })
    tagList(boutons)
  })

  # Observer les clics sur les boutons pour les mettre à jour
  observe({
    lapply(1:nRows(), function(i) {
      lapply(1:nCols(), function(j) {
        observeEvent(input[[paste("bouton", i, j, sep = "_")]], {
          valeur_actuelle = rv$grille[i, j]
          if (is.na(valeur_actuelle)) {
            valeur_nouvelle = 0
          } else if (valeur_actuelle == 0) {
            valeur_nouvelle = 1
          } else {
            valeur_nouvelle = NA
          }
          rv$grille[i, j] = valeur_nouvelle

          # Mettre à jour le label du bouton
          updateActionButton(
            session,
            paste("bouton", i, j, sep = "_"),
            label = ifelse(is.na(valeur_nouvelle), "", as.character(valeur_nouvelle))
          )
        })
      })
    })
  })

  # Observer pour vérifier la grille
  observeEvent(input$check_grid, {
    message = verifier_grille(rv$grille)
    if (message == FALSE) {
      output$result = renderText(" ❌ La grille n'est pas bonne, réessayez !")
    }
    if (message == TRUE) {
      depart_chrono(FALSE)
      delta_temps = difftime(Sys.time(), debut_temps(), units = "secs")
      output$timer = renderText({paste("Temps écoulé :", round(delta_temps), "secondes")})
      output$result = renderText(" 🎉 Bravo, vous avez réussi !")
      easyClose = TRUE
    }
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)

