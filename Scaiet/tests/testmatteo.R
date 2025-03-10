library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyalert)

ui <- fluidPage(
  theme = shinytheme("sandstone"),

  titlePanel(
    h1(
      strong(
        em(
          HTML("<p style='color: #784212;
                   text-align: center;
                   font-family: Monaco;'>Takuzu</p>")
        )
      ),
    ),
    windowTitle = "Jeu du Takuzu"
  ),

  sidebarLayout(
    sidebarPanel(
      selectInput("grid_size", "Taille de la grille", choices = c(4, 6, 8), selected = 6),
      selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
      actionButton("new_game", "Nouvelle Partie"),
      actionButton("check_grid", "Vérifier"),
      textOutput("result")
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

  rv = reactiveValues(grille = NULL, verrouillees = NULL)

  # Observer la nouvelle partie
  observeEvent(input$new_game, {
    showNotification(paste("Nouvelle partie - Niveau :", niveau(), "- Taille :", nRows(), "x", nCols()), type = "message")
    grille_init = generer_takuzu(nRows(),niveau())
    rv$grille = grille_init
    rv$verrouillees = !is.na(grille_init)
    output$result = renderText("Nouvelle partie commencée ! Bonne chance ")
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
      output$result = renderText(" 🎉 Bravo, vous avez réussi !")
    }
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)

