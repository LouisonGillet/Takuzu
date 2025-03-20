library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyalert)
library(shinyjs)

ui <- fluidPage(
  
  useShinyjs(), 
  
  theme = shinytheme("sandstone"),
  
  tags$style(HTML("
    @import url('https://fonts.googleapis.com/css2?family=Pacifico&display=swap'); 
      .title { font-size: 36px; font-weight: bold; margin-top: 30px; }
      .subtext { font-size: 18px; color: #aaa; margin-bottom: 20px; }
      .button-container { display: flex; justify-content: center; gap: 20px; margin-top: 20px; }
      .btn-custom { width: 250px; height: 60px; font-size: 20px; font-weight: bold; border: none; border-radius: 10px; cursor: pointer; transition: 0.3s; }
      .btn-play { background-color: #4CAF50; color: white; }
      .btn-play:hover { background-color: #3e8e41; }
      .btn-about { background-color: #444; color: white; }
      .btn-about:hover { background-color: #666; }
      .img-container { display: flex; justify-content: center; margin-top: 50px; }
      .game-img { width: 500px; border-radius: 10px; box-shadow: 0px 4px 10px rgba(0,0,0,0.5); }
      .title-text {font-family: 'Pacifico', cursive;font-size: 100px;color: #784212;text-align: center;}
    ")),
  
  # Ajouter la musique de fond
  tags$audio(id = "musique", src = "musique2.mp3", type = "audio/mp3", autoplay = TRUE, loop = TRUE, style = "display: none;"),
  
  # Écran d'accueil
  div(id = "accueil",
      div(style = "display: flex; align-items: center; justify-content: center; margin-top: 150px;",
          # Colonne gauche : Titre + boutons
          div(style = "text-align: left; margin-right: 50px;",
              h1("Jeu du Takuzu", class = "title-text"),
              div(class = "subtext", "Un jeu de logique captivant"),
              div(style = "margin-top: 30px;", 
                  actionButton("start_game", "Commencer le jeu", class = "custom-button")
              ),
              div(style = "margin-top: 15px;", 
                  actionButton("show_about", "À propos", class = "btn btn-info btn-lg")
              )
          ),
          # Colonne droite : Image du jeu
          div(
            img(src = "www/image1.png", class = "game-img", style = "max-width: 400px; height: auto;")
          )
      )
  ),
  
  # Interface de jeu (cachée au départ)
  hidden(
    div(id = "jeu",
        titlePanel(h1("Jeu du Takuzu", class = "title-text")),
        
        sidebarLayout(
          sidebarPanel(
            selectInput("grid_size", "Taille de la grille", choices = c(4, 6, 8), selected = 8),
            selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
            actionButton("new_game", "Nouvelle Partie"),
            actionButton("check_grid", "Vérifier"),
            actionButton("back_home", "Retour"),
            textOutput("result"),
            br(),
            div(
              style = "border: 1px solid #ccc; padding: 10px; margin-top: 20px; background-color: #f9f9f9; text-align: center;",
              h4("Contrôle de la musique"),
              actionButton("toggle_music", "⏸️ Stopper la musique", style = "width: 100%;"),
              br(), br(),
              selectInput("select_music", "Choisir une musique :",
                          choices = c("Lofi" = "musique1.mp3", "Traditionnel" = "musique2.mp3"))
            )
          ),
          mainPanel(
            h1(tableOutput("grille_boutons")),
            h2(textOutput("timer"))
          )
        )
    )
  ),
  
  # Pour la page apropos
  hidden(
    div(id = "apropos",
        h1("À Propos", class = "title-text"),
        p("Ce jeu a été créé pour l'UE HAX815X"),
        p("Règles du Takuzu :"),
        tags$ul(
          tags$li("Chaque ligne et colonne contient autant de 0 que de 1."),
          tags$li("Pas plus de deux chiffres identiques à la suite."),
          tags$li("Les lignes/colonnes identiques sont interdites.")
        ),
        actionButton("back_home", "Retour", class = "btn btn-secondary"),
    )
  )
  
)


server <- function(input, output, session) {
  
  observeEvent(input$start_game, {
    shinyjs::hide("accueil")
    shinyjs::show("jeu")
  })
  
  observeEvent(input$show_about, {
    shinyjs::hide("accueil")
    shinyjs::show("apropos")
  })
  
  observeEvent(input$back_home, {
    shinyjs::hide("apropos")
    shinyjs::hide("jeu")
    shinyjs::show("accueil")
  })
  
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
    
    temps_ecoule <- as.integer(difftime(Sys.time(), debut_temps(), units = "secs"))
    heures <- temps_ecoule %/% 3600
    minutes <- (temps_ecoule %% 3600) %/% 60
    secondes <- temps_ecoule %% 60
    
    sprintf("%02d:%02d:%02d", heures, minutes, secondes)
  })
  
  # Affichage des boutons de la grille avec coordonnées
  output$grille_boutons <- renderUI({
    
    # Générer les étiquettes de colonnes (A, B, C, ...)
    lettres_colonnes <- LETTERS[1:nCols()]
    
    # Style CSS uniforme pour alignement et apparence
    css_case <-
      
      "width: 50px;
        height: 50px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        font-weight: bold;
        border: 1px solid black;
        margin: 2px;"
    
    css_coord <-
      
      "width: 50px;
        height: 50px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        font-weight: bold;
        border: 1px solid black;
        margin: 2px;
        color : black;
        background-color : white"
    
    # Ligne des en-têtes de colonnes
    header_row <- div(
      style = "display: flex; flex-direction: row; align-items: center;",
      div(style = "width: 54px;"),  # Case vide pour aligner avec les numéros de ligne
      lapply(1:nCols(), function(j) {
        div(lettres_colonnes[j], style = css_coord)
      })
    )
    
    # Générer les lignes de la grille avec les étiquettes de lignes
    boutons <- lapply(1:nRows(), function(i) {
      div(
        style = "display: flex; flex-direction: row; align-items: center;",
        div(strong(i), style = css_coord),  # Étiquette de ligne
        lapply(1:nCols(), function(j) {
          actionButton(inputId = paste("bouton", i, j, sep = "_"),
                       label = ifelse(is.na(rv$grille[i, j]), "", as.character(rv$grille[i, j])),
                       style = paste0(css_case, "border-radius: 0;"),  # Suppression des bords arrondis
                       disabled = rv$verrouillees[i, j])
        })
      )
    })
    
    # Affichage complet (en-têtes + boutons)
    tagList(header_row, boutons)
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

