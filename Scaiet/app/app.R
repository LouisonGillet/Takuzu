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
      textOutput("result")
    ),

    mainPanel(
      tableOutput("grille_boutons")
    )
  )
)



server <- function(input, output, session) {
  nRows <- 8
  nCols <- 8
  niveau = "Moyen"

  # Générer la grille de départ
  grille_init <- generer_takuzu(niveau, nRows)

  # Stocker la grille et les cases bloquées
  rv <- reactiveValues(grille = grille_init, verrouillees = !is.na(grille_init))

  output$grille_boutons <- renderUI({
    boutons <- lapply(1:nRows, function(i) {
      fluidRow(
        lapply(1:nCols, function(j) {
          valeur_case <- rv$grille[i, j]
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
  lapply(1:nRows, function(i) {
    lapply(1:nCols, function(j) {
      observeEvent(input[[paste("bouton", i, j, sep = "_")]], {
        # Mettre à jour la valeur de la case
        valeur_actuelle <- rv$grille[i, j]
        valeur_nouvelle <- ifelse(is.na(valeur_actuelle), 0, ifelse(valeur_actuelle == 0, 1, NA))
        rv$grille[i, j] <- valeur_nouvelle

        # Mettre à jour l'étiquette du bouton
        updateActionButton(
          session,
          paste("bouton", i, j, sep = "_"),
          label = ifelse(is.na(valeur_nouvelle), "", as.character(valeur_nouvelle))
        )

        # Affichage des messages de débogage
        print(paste("Avant changement: Case (", i, ",", j, ") -> ", valeur_actuelle))
        print(paste("Après changement: Case (", i, ",", j, ") -> ", valeur_nouvelle))
      })
    })
  })
  observeEvent(input$check_grid, {
    message = verifier_grille(rv$grille)
    if(message==FALSE){
      output$result = renderText(" ❌ La grille n'est pas bonne, réessayez !")
    }
    if(message==TRUE){
      output$result = renderText(" 🎉 Bravo, vous avez réussi !")
    }
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)
