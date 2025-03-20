library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyalert)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),  # Activation de shinyjs pour exécuter du JavaScript

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
