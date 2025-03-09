library(shiny)

# Fonction pour générer une grille Takuzu de base (partiellement remplie)
generate_takuzu <- function(size) {
  grid <- matrix(sample(c(0, 1, NA), size * size, replace = TRUE, prob = c(0.4, 0.4, 0.2)), nrow = size)
  return(grid)
}

# Vérification des règles du Takuzu
check_takuzu <- function(grid) {
  size <- nrow(grid)

  # Vérifier l'équilibre des 0 et 1 dans chaque ligne et colonne
  for (i in 1:size) {
    if (sum(grid[i, ] == 0, na.rm = TRUE) > size / 2 || sum(grid[i, ] == 1, na.rm = TRUE) > size / 2) {
      return(FALSE)
    }
    if (sum(grid[, i] == 0, na.rm = TRUE) > size / 2 || sum(grid[, i] == 1, na.rm = TRUE) > size / 2) {
      return(FALSE)
    }
  }

  # Vérifier qu'il n'y a pas plus de deux 0 ou 1 consécutifs
  for (i in 1:size) {
    if (any(rle(grid[i, ])$lengths > 2, na.rm = TRUE) || any(rle(grid[, i])$lengths > 2, na.rm = TRUE)) {
      return(FALSE)
    }
  }

  return(TRUE)
}

# Interface utilisateur
ui <- fluidPage(
  titlePanel("Jeu du Takuzu"),
  sidebarLayout(
    sidebarPanel(
      selectInput("grid_size", "Taille de la grille", choices = c(4, 6, 8), selected = 4),
      actionButton("new_game", "Nouvelle Partie"),
      actionButton("check_grid", "Vérifier"),
      textOutput("result")
    ),
    mainPanel(
      tableOutput("takuzu_grid")
    )
  )
)

# Serveur
server <- function(input, output, session) {
  grid <- reactiveVal(generate_takuzu(4))

  observeEvent(input$new_game, {
    grid(generate_takuzu(as.numeric(input$grid_size)))
  })

  output$takuzu_grid <- renderTable({
    grid()
  }, rownames = TRUE, colnames = TRUE)

  observeEvent(input$check_grid, {
    result <- if (check_takuzu(grid())) "Grille correcte !" else "Erreur dans la grille."
    output$result <- renderText({ result })
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)
