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
      .subtext { font-size: 18px; color: #aaa; margin-bottom: 40px; }
      .button-container { display: flex; justify-content: center; gap: 20px; margin-top: 20px; }
      .btn-custom { width: 350px; height: 100px; font-size: 20px; font-weight: bold; border: none; border-radius: 10px; cursor: pointer; transition: 0.3s; }
      .btn-custom2 { width: 250px; height: 60px; font-size: 20px; font-weight: bold; border: none; border-radius: 10px; cursor: pointer; transition: 0.3s; }
      .btn-play { background-color: #4CAF50; color: white; }
      .btn-play:hover { background-color: #3e8e41; }
      .btn-about { background-color: #444; color: white; }
      .btn-about:hover { background-color: #666; }
      .img-container { display: flex; justify-content: center; margin-top: 50px; }
      .game-img { width: 500px; border-radius: 10px; box-shadow: 0px 4px 10px rgba(0,0,0,0.5); }
      .title-text {font-family: 'Pacifico', cursive;font-size: 70px;color: #784212;text-align: center;}
    ")),

  # Ajouter la balise audio pour jouer la musique en arrière-plan
  tags$audio(id = "musique", src = "musique2.mp3", type = "audio/mp3", autoplay = TRUE, loop = TRUE, style = "display: none;"),

  div(id = "accueil",
      div(style = "display: flex; align-items: center; justify-content: center; margin-top: 150px;",
          # Colonne gauche
          div(style = "text-align: center; margin-right: 50px; display: flex; flex-direction: column; align-items: center;",
              h1("Jeu du Takuzu", class = "title-text"),
              div(style = "margin-top: 10px;", class = "subtext", "Un jeu de logique captivant"),
              div(style = "margin-top: 30px; width: 100%; display: flex; flex-direction: column; align-items: center;",
                  actionButton("start_game", "Commencer le jeu", class = "btn-custom"),
                  actionButton("show_about", "À propos", class = "btn-custom2", style = "margin-top: 15px;"))
          ),
          # Colonne droite
          div(img(src = "image1.png", class = "game-img", style = "max-width: 400px; height: auto;"))
      )
  ),
  
  
  # Interface de jeu (cachée au départ)
  hidden(
    div(id = "jeu",
        titlePanel(h1("Jeu du Takuzu", class = "title-text")),
        div(style = "position: absolute; bottom: 20px; right: 20px;",actionButton("back_home", "Retour")),
        sidebarLayout(
          sidebarPanel(
            selectInput("grid_size", "Taille de la grille", choices = c(4, 6, 8), selected = 8),
            selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
            actionButton("new_game", "Nouvelle Partie"),
            actionButton("check_grid", "Vérifier"),
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
        h1("À Propos", style = "font-size: 50px; font-weight: bold; text-align: center; color: #333;"),
        p("Ce jeu a été créé pour l'UE HAX815X", style = "font-size: 30px; text-align: center; margin-bottom: 20px;"),
        p("Règles du Takuzu :", style = "font-size: 24px; font-weight: bold; text-decoration: underline; margin-top: 30px;"),
        tags$ul(
          tags$li("Chaque ligne et colonne contient autant de 0 que de 1.", style = "font-size: 18px; margin-bottom: 10px;"),
          tags$li("Pas plus de deux chiffres identiques à la suite.", style = "font-size: 18px; margin-bottom: 10px;"),
          tags$li("Les lignes/colonnes identiques sont interdites.", style = "font-size: 18px;")
        ),
        p("Auteurs :", style = "font-size: 24px; font-weight: bold; text-decoration: underline; margin-top: 30px;"),
        tags$ul(
          tags$li("GILLET LOUISON : louison.gillet@etu.umontpellier.fr", style = "font-size: 18px; margin-bottom: 10px;"),
          tags$li("SCAIA MATTEO : matteo.scaia@etu.umontpellier.fr", style = "font-size: 18px; margin-bottom: 10px;")
        ),
        
        # Bouton Retour en bas à droite
        div(style = "position: fixed; bottom: 20px; right: 20px;",
            actionButton("back_home", "Retour")
        )
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

  # Gestion musique
  musique_en_pause <- reactiveVal(FALSE)

  observeEvent(input$toggle_music, {
    if (musique_en_pause()) {
      runjs("
      var audio = document.getElementById('musique');
      audio.play();
    ")
      updateActionButton(session, "toggle_music", label = "⏸️ Stopper la musique")
      musique_en_pause(FALSE)
    } else {
      runjs("
      var audio = document.getElementById('musique');
      audio.pause();
    ")
      updateActionButton(session, "toggle_music", label = "▶️ Reprendre la musique")
      musique_en_pause(TRUE)
    }
  })


  observeEvent(input$select_music, {
    runjs(sprintf("
    var audio = document.getElementById('musique');
    audio.src = '%s';
    audio.load();
  ", input$select_music))

    # Si la musique était en lecture avant le changement, elle doit reprendre
    if (!musique_en_pause()) {
      runjs("document.getElementById('musique').play();")
      updateActionButton(session, "toggle_music", label = "⏸️ Stopper la musique")
    } else {
      # Sinon, on s'assure que la musique reste en pause après le changement
      runjs("document.getElementById('musique').pause();")
      updateActionButton(session, "toggle_music", label = "▶️ Reprendre la musique")
    }
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
