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

  uiOutput("grille_boutons")
)



server <- function(input, output, session) {
  nRows <- 6
  nCols <- 6
  niveau = "moyen"

  rv <- reactiveValues(grille = generer_takuzu(niveau, nRows))

  # Générer la grille initiale
  rv <- reactiveValues(
    grille = generer_takuzu(niveau, nRows),  # Matrice de la grille
    disabled = matrix(FALSE, nrow = nRows, ncol = nCols)  # Matrice pour désactiver les boutons
  )

  # Désactiver les boutons préremplis initialement

  observe({
    cases_preremplies <- which(!is.na(rv$grille), arr.ind = TRUE)
    for (k in 1:nrow(cases_preremplies)) {
      i <- cases_preremplies[k, 1]
      j <- cases_preremplies[k, 2]
      rv$disabled[i, j] <- TRUE  # Désactiver les boutons préremplis
    }
  })

  output$grille_boutons <- renderUI({
    boutons <- lapply(1:nRows, function(i) {
      fluidRow(
        lapply(1:nCols, function(j) {
          actionButton(inputId = paste("bouton", i, j, sep = "_"),
                       label = ifelse(is.na(rv$grille[i, j]), "", as.character(rv$grille[i, j])),
                       style = "width: 100px; height: 100px; font-size: 18px; margin: 5px;",
                       disabled = rv$disabled[i, j])  # Désactive le bouton si la case est préremplie initialement
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
        if (is.na(valeur_actuelle)) {
          valeur_nouvelle <- 0  # Si la case est vide, on la remplit avec 0
        } else if (valeur_actuelle == 0) {
          valeur_nouvelle <- 1  # Si la case est 0, on la change en 1
        } else {
          valeur_nouvelle <- NA  # Si la case est 1, on la change en NA
        }
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
}

# Lancer l'application
shinyApp(ui = ui, server = server)



grille = generer_takuzu("moyen", 8)
rv = reactiveValues(grille = generer_takuzu("moyen", 8))
cases_premplies <- which(!is.na(rv$grille), arr.ind = TRUE)

