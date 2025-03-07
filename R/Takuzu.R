library(shiny)

ui <- fluidPage(
  titlePanel("Jeu Takuzu 5x5"),
  fluidRow(
    lapply(1:5, function(i) {
      column(2,
             lapply(1:5, function(j) {
               actionButton(inputId = paste("cell_", i, j, sep = "_"),
                            label = "",
                            width = "50px",
                            style = "height: 50px; font-size: 18px")
             })
      )
    })
  ),
  actionButton("Commencer", "Commencer une nouvelle partie"),
  actionButton("Verification", "Vérifier la solution"),
  textOutput("status")
)


server <- function(input, output, session) {

  grid <- reactiveVal(matrix(NA, nrow = 5, ncol = 5))  # Une matrice 5x5 vide
  observeEvent(input$Commencer, {
    grid(matrix(NA, nrow = 5, ncol = 5))  # Réinitialisation de la matrice
  })

}


# Lancer l'application
shinyApp(ui = ui, server = server)

