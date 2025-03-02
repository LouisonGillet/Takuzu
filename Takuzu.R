library(shiny)

ui <- fluidPage(
  titlePanel("Matrice de Boutons avec Shiny"),
  uiOutput("matrice_boutons")
)

server <- function(input, output) {
  output$matrice_boutons <- renderUI({
    nRows <- 8    # Définir le nombre de lignes
    nCols <- 8    # Définir le nombre de colonnes
    
    # Créer une matrice de boutons
    boutons <- lapply(1:(nRows * nCols), function(i) {
      actionButton(inputId = paste(" ", i, sep = "_"), label = "")
    })
    
    # Organiser les boutons en grille
    tagList(div(class = "btn-grid",
                lapply(split(boutons, ceiling(seq_along(boutons) / nCols)), div, class = "button-row")))
  })
}

shinyApp(ui = ui, server = server)
