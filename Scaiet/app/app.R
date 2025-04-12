library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyalert)
library(shinyjs)

ui <- fluidPage(
  useShinyjs(),
  theme = shinytheme("sandstone"),
  # --- HEAD : styles + fonts + FA ---
  tags$head(
    tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css"),
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
      .title-text { font-family: 'Pacifico', cursive; font-size: 70px; color: #784212; text-align: center; }

      /* Icône musique */
      #icone_musique:hover {
        animation: pulse 0.8s;
      }

      @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.2); }
        100% { transform: scale(1); }
      }

      #chrono_page {
      position: fixed;
      top: 300px; /* Ajuster pour placer sous la sidebar */
      left: 16%;
      transform: translateX(-50%);
      background-color: rgba(0, 0, 0, 0.6);
      border-radius: 10px;
      padding: 15px;
      color: white;
      font-size: 32px;
      font-family: 'Courier New', Courier, monospace;
      box-shadow: 0 4px 10px rgba(0, 0, 0, 0.5);
      z-index: 9997;
      }

      #chrono_page:hover {
        background-color: rgba(0, 0, 0, 0.8);
      }

      #chrono_page .timer-text {
        font-size: 36px;
        font-weight: bold;
        color: #ff6f61;
        text-align: center;
      }
      "))
  ),

  # Balise audio
  tags$audio(
    id = "musique",
    src = "musique2.mp3",
    type = "audio/mp3",
    autoplay = TRUE,
    loop = TRUE,
    style = "display: none;"
  ),

  # Icône musique (cliquable)
  div(
    id = "icone_musique",
    style = "position: fixed; top: 20px; right: 20px; z-index: 9999; cursor: pointer;",
    tags$i(class = "fa fa-music fa-2x", style = "color: black;")
  ),

  # Icône règles (cliquable, uniquement sur pages de jeu)
  hidden(
    div(
      id = "icone_regles",
      style = "position: fixed; top: 20px; right: 70px; cursor: pointer; z-index: 9999;",
      tags$i(class = "fa fa-info-circle fa-2x", style = "color: black;")
    )
  ),

  # Panneau de contrôle musique
  hidden(
    div(
      id = "controle_musique_global",
      style = "position: fixed; top: 70px; right: 20px; background-color: #fff; font-family: 'Georgia', serif;
             border: 2px solid black; border-radius: 10px; padding: 20px; z-index: 9998; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);",
      h4("Contrôle de la musique", style = "display: flex; justify-content: center; width: 100%;"),
      actionButton("toggle_music", "⏸️ Stopper", style = "width: 100%;"),
      br(), br(),
      selectInput("select_music", "Choisir une musique :",
                  choices = c("Lofi Beat" = "musique1.mp3", "Ambiant Traditional Japanese" = "musique2.mp3")),
      br(),
      div(
        style = "display: flex; justify-content: center; width: 100%;",
        actionButton("fermer_panneau", "", icon = icon("times"))
      )
    )
  ),

  # Panneau de rappel des règles
  hidden(
    div(
      id = "controle_info_global",
      style = "position: fixed; top: 70px; right: 20px; background-color: #fff; font-family: 'Georgia', serif;
             border: 2px solid black; border-radius: 10px; padding: 20px; z-index: 9998; box-shadow: 2px 2px 8px rgba(0,0,0,0.2);",
      p("Règles du jeu", style = "font-size: 24px; font-weight: bold; text-decoration: underline; margin-top: 30px;"),
      tags$ul(
        tags$li("chaque case de la grille doit être remplie avec un 0 ou un 1 ;", style = "font-size: 18px; margin-bottom: 10px;"),
        tags$li("chaque ligne et chaque colonne doivent contenir autant de 0 que de 1;", style = "font-size: 18px; margin-bottom: 10px;"),
        tags$li("il est interdit d’avoir trois 0 ou trois 1 consécutifs dans une ligne ou une colonne;", style = "font-size: 18px; margin-bottom: 10px;"),
        tags$li("deux lignes ou deux colonnes identiques sont interdites dans la même grille.", style = "font-size: 18px;"),
      ),
      p("Stratégies pour résoudre un Takuzu", style = "font-size: 24px; font-weight: bold; text-decoration: underline; margin-top: 30px;"),
      tags$ul(
        tags$li("détecter les triples : si deux 0 ou deux 1 se suivent, la case suivante doit forcément contenir l’autre chiffre;", style = "font-size: 18px; margin-bottom: 10px;"),
        tags$li("équilibrer les 0 et les 1 : une ligne ou une colonne ne peut pas contenir plus de la moitié des cases d’un même chiffre;", style = "font-size: 18px; margin-bottom: 10px;"),
        tags$li("comparer les lignes et colonnes déjà complétées : si une ligne ou une colonne est presque remplie et qu’une autre est similaire, il faut ajuster les chiffres pour éviter les doublons.", style = "font-size: 18px;"),
      ),
      br(),
      div(
        style = "display: flex; justify-content: center; width: 100%;",
        actionButton("fermer_info", "", icon = icon("times"))
      )
    )
  ),

  # Panneau d'accueil
  div(id = "accueil",
      div(style = "display: flex; align-items: center; justify-content: center; margin-top: 150px;",
          # Colonne gauche
          div(style = "text-align: center; margin-right: 50px; display: flex; flex-direction: column; align-items: center;",
              style = "font-family: 'Georgia', serif;",
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

  # Panneau à propos
  hidden(
    div(id = "apropos",
        style = "font-family: 'Georgia', serif;",
        h1("À Propos", style = "font-size: 50px; font-weight: bold; text-align: center; color: #333;"),
        p("Ce jeu a été créé pour l'UE HAX815X", style = "font-size: 30px; text-align: center; margin-bottom: 20px;"),
        p("Auteurs :", style = "font-size: 24px; font-weight: bold; text-decoration: underline; margin-top: 30px;"),
        tags$ul(
          tags$li("GILLET LOUISON : louison.gillet@etu.umontpellier.fr", style = "font-size: 18px; margin-bottom: 10px;"),
          tags$li("SCAIA MATTEO : matteo.scaia@etu.umontpellier.fr", style = "font-size: 18px; margin-bottom: 10px;")
        ),

        # Section lien vers GitHub
        p("Dépôt GitHub", style = "font-size: 24px; font-weight: bold; margin-top: 30px; text-decoration: underline;"),
        p("Vous pouvez consulter le code source du projet et suivre son évolution sur GitHub :", style = "font-size: 18px;"),
        tags$ul(
          tags$li(a("Takuzu", href = "https://github.com/LouisonGillet/Takuzu", target = "_blank", style = "font-size: 18px;"))
        ),

        # Section musique libre de droits
        p("Musiques", style = "font-size: 24px; font-weight: bold; text-decoration: underline; margin-top: 30px;"),
        p("Les musiques utilisées dans ce projet sont libres de droits. Vous pouvez les écouter et soutenir les créateurs via leurs vidéos YouTube.", style = "font-size: 18px;"),
        tags$ul(
          tags$li(a("Massobeats - rose water (royalty free lofi music)", href = "https://www.youtube.com/watch?v=xakBzg5atsM&list=PLQES5ZkfLYOWFfUW8RyoseVTNpTeIp_cS", target = "_blank", style = " font-size: 18px; margin-bottom: 10px;")),
          tags$li(a("Solas - Traditional Japanese", href = "https://www.youtube.com/watch?v=gtQT5KCH8lo&list=PLQES5ZkfLYOWFfUW8RyoseVTNpTeIp_cS&index=2", target = "_blank", style = "font-size: 18px;"))
        ),

        # Bouton Home en bas à droite
        div(
          style = "position: absolute; bottom: 20px; right: 20px; display: flex; gap: 10px;",
          actionButton("back_lobby", label = tagList(icon("home")))
        ),
    )
  ),


  # Panneau choix grilles
  hidden(
    div(id = "choix_taille",
        style = "font-family: 'Georgia', serif;",
        h1("Choisissez la taille de la grille",
           style = "font-size: 50px; font-weight: bold; text-align: center; color: #333; margin-top: 50px;"),

        # Conteneur des boutons en colonne
        div(style = "display: flex; flex-direction: column; align-items: center; gap: 20px; margin-top: 50px;",
            actionButton("size_4", "4x4", class = "btn-custom"),
            actionButton("size_6", "6x6", class = "btn-custom"),
            actionButton("size_8", "8x8", class = "btn-custom")
        ),

        # Bouton Retour
        div(
          style = "position: absolute; bottom: 20px; right: 20px; display: flex; gap: 10px;",
          actionButton("back_lobby", label = tagList(icon("home")))
        ),
    )
  ),

  # Interface de jeu 8x8
  hidden(
    div(id = "jeu8x8",
        style = "font-family: 'Georgia', serif;",
        titlePanel(h1("Jeu du Takuzu en 8x8", class = "title-text")),
        div(
          style = "position: absolute; bottom: 20px; right: 20px; display: flex; gap: 10px;",
          actionButton("back_lobby", label = tagList(icon("home"))),
          actionButton("back_home", "Retour"),
        ),
        sidebarLayout(
          sidebarPanel(
            selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
            actionButton("new_game", "Nouvelle Partie"),
            actionButton("check_grid", "Vérifier"),
            br(),
          ),
          mainPanel(
            h1(uiOutput("grille_boutons8x8")),
          )
        )
    )
  ),

  # Interface de jeu 6x6
  hidden(
    div(id = "jeu6x6",
        style = "font-family: 'Georgia', serif;",
        titlePanel(h1("Jeu du Takuzu en 6x6", class = "title-text")),
        div(
          style = "position: absolute; bottom: 20px; right: 20px; display: flex; gap: 10px;",
          actionButton("back_lobby", label = tagList(icon("home"))),
          actionButton("back_home", "Retour"),
        ),
        sidebarLayout(
          sidebarPanel(
            selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
            actionButton("new_game", "Nouvelle Partie"),
            actionButton("check_grid", "Vérifier"),
            br(),
          ),
          mainPanel(
            h1(uiOutput("grille_boutons6x6")),
          )
        )
    )
  ),

  # Interface de jeu 4x4
  hidden(
    div(id = "jeu4x4",
        style = "font-family: 'Georgia', serif;",
        titlePanel(h1("Jeu du Takuzu en 4x4", class = "title-text")),
        div(
          style = "position: absolute; bottom: 20px; right: 20px; display: flex; gap: 10px;",
          actionButton("back_lobby", label = tagList(icon("home"))),
          actionButton("back_home", "Retour"),
        ),
        sidebarLayout(
          sidebarPanel(
            selectInput("niveau", "Niveau de difficulté", choices = c("Facile", "Moyen", "Difficile", "Einstein"), selected = "Moyen"),
            actionButton("new_game", "Nouvelle Partie"),
            actionButton("check_grid", "Vérifier"),
            br(),
          ),
          mainPanel(
            h1(uiOutput("grille_boutons4x4")),
          )
        )
    )
  ),

  # Panneau pour le chronomètre
  hidden(
    div(
      id = "chrono_page",
      class = "timer-text",
      textOutput("timer")
    )
  ),

  # Panneau pour le résultat
  hidden(
    div(
      id = "résultat",
      style = "
      font-family: 'Georgia', serif;
      position: fixed;
      bottom: 160px;
      left: 16%;
      transform: translateX(-50%);
      width: 200px;
      height: 150px;
      background-color: #f9f9f9;
      border: 2px solid #ccc;
      border-radius: 10px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
      padding: 20px;
      display: none;
      z-index: 9997;
      display: flex;
      justify-content: center;
      align-items: center;
      text-align: center;
    ",
      textOutput("result")
    )
  )
)


server <- function(input, output, session) {

  observeEvent(input$start_game, {
    hide("accueil")
    show("choix_taille")
  })

  observeEvent(input$show_about, {
    hide("accueil")
    show("apropos")
  })

  observeEvent(input$back_home, {
    hide("jeu6x6")
    hide("jeu8x8")
    hide("jeu4x4")
    hide("icone_regles")
    show("choix_taille")
    hide("chrono_page")
    hide("résultat")
    debut_temps(NULL)
    depart_chrono(FALSE)
    output$timer <- renderText({ "00:00:00" })
  })

  observeEvent(input$back_lobby, {
    hide("apropos")
    hide("jeu6x6")
    hide("jeu8x8")
    hide("jeu4x4")
    hide("choix_taille")
    hide("icone_regles")
    hide("chrono_page")
    hide("résultat")
    debut_temps(NULL)
    depart_chrono(FALSE)
    output$timer <- renderText({ "00:00:00" })
    show("accueil")
  })

  observeEvent(input$size_4, {
    hide("choix_taille")
    hide("jeu6x6")
    hide("jeu8x8")
    show("jeu4x4")
    show("chrono_page")
    show("résultat")
    show("icone_regles")
    nRows(4)
    rv$grille <- NULL
    rv$verrouillees <- NULL
    output$grille_boutons4x4 <- renderUI({
      generer_grille_ui(nRows(), nCols(), rv)
    })
  })

  observeEvent(input$size_6, {
    hide("jeu8x8")
    hide("jeu4x4")
    hide("choix_taille")
    show("jeu6x6")
    show("chrono_page")
    show("résultat")
    show("icone_regles")
    nRows(6)
    rv$grille <- NULL
    rv$verrouillees <- NULL
    output$grille_boutons6x6 <- renderUI({
      generer_grille_ui(nRows(), nCols(), rv)
    })
  })

  observeEvent(input$size_8, {
    hide("jeu6x6")
    hide("jeu4x4")
    hide("choix_taille")
    show("jeu8x8")
    show("chrono_page")
    show("résultat")
    show("icone_regles")
    nRows(8)
    rv$grille <- NULL
    rv$verrouillees <- NULL
    output$grille_boutons8x8 <- renderUI({
      generer_grille_ui(nRows(), nCols(), rv)
    })
  })


  nRows = reactiveVal(8)
  nCols = nRows
  niveau = reactive({ input$niveau })
  debut_temps = reactiveVal(NULL)
  depart_chrono = reactiveVal(FALSE)

  rv = reactiveValues(grille = NULL, verrouillees = NULL)

  # Observer la nouvelle partie
  observeEvent(input$new_game, {
    debut_temps(Sys.time())
    depart_chrono(TRUE)
    grille_init = generer_takuzu(nRows(),niveau())
    rv$grille = grille_init
    rv$verrouillees = !is.na(grille_init)
    output$result = renderText("⏳ Partie en cours... Bonne chance !")
    output$timer <- renderText({
      req(debut_temps(), depart_chrono())  # Assure que la partie a commencé et que le chrono tourne
      invalidateLater(1000, session)  # Met à jour chaque seconde
      temps_ecoule <- as.integer(difftime(Sys.time(), debut_temps(), units = "secs"))
      heures <- temps_ecoule %/% 3600
      minutes <- (temps_ecoule %% 3600) %/% 60
      secondes <- temps_ecoule %% 60
      sprintf("%02d:%02d:%02d", heures, minutes, secondes)
    })
  })

  observeEvent(input$niveau, {
    debut_temps(NULL)
    depart_chrono(FALSE)
    output$timer <- renderText({ "00:00:00" })
    rv$grille <- NULL
    rv$verrouillees <- NULL
  })

  # Gestion musique
  musique_en_pause <- reactiveVal(FALSE)

  observe({
    shinyjs::onclick("icone_musique", {
      shinyjs::toggle(id = "controle_musique_global", anim = TRUE, animType = "slide", time = 0.3)
    })

    shinyjs::onclick("icone_regles", {
      shinyjs::toggle(id = "controle_info_global", anim = TRUE, animType = "slide", time = 0.3)
    })

    shinyjs::onclick("fermer_panneau", {
      shinyjs::hide(id = "controle_musique_global", anim = TRUE, animType = "slide", time = 0.3)
    })

    shinyjs::onclick("fermer_info", {
      shinyjs::hide(id = "controle_info_global", anim = TRUE, animType = "slide", time = 0.3)
    })
  })

  observeEvent(input$fermer_panneau, {
    shinyjs::hide(id = "controle_musique_global", anim = TRUE, animType = "slide", time = 0.3)
  })

  observeEvent(input$fermer_info, {
    shinyjs::hide(id = "controle_info_global", anim = TRUE, animType = "slide", time = 0.3)
  })

  observeEvent(input$toggle_music, {
    if (musique_en_pause()) {
      runjs("
      var audio = document.getElementById('musique');
      audio.play();
    ")
      updateActionButton(session, "toggle_music", label = "⏸️ Stopper")
      musique_en_pause(FALSE)
    } else {
      runjs("
      var audio = document.getElementById('musique');
      audio.pause();
    ")
      updateActionButton(session, "toggle_music", label = "▶️ Reprendre")
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
      updateActionButton(session, "toggle_music", label = "⏸️ Stopper")
    } else {
      # Sinon, on s'assure que la musique reste en pause après le changement
      runjs("document.getElementById('musique').pause();")
      updateActionButton(session, "toggle_music", label = "▶️ Reprendre")
    }
  })



  remove_all_observers <- function() {
    lapply(1:nRows(), function(i) {
      lapply(1:nCols(), function(j) {
        bouton_id <- paste("bouton", i, j, sep = "_")
        removeEventObserver(bouton_id)  # Enlever l'observateur pour chaque bouton
      })
    })
  }
  observe({
    # Suppression des anciens observateurs avant d'en ajouter de nouveaux
    lapply(1:nRows(), function(i) {
      lapply(1:nCols(), function(j) {
        bouton_id <- paste("bouton", i, j, sep = "_")

        # Ajouter un observateur uniquement si ce bouton n'a pas déjà un observateur
        if (is.null(input[[bouton_id]])) {
          observeEvent(input[[bouton_id]], {
            valeur_actuelle <- rv$grille[i, j]
            if (is.na(valeur_actuelle)) {
              valeur_nouvelle <- 0
            } else if (valeur_actuelle == 0) {
              valeur_nouvelle <- 1
            } else {
              valeur_nouvelle <- NA
            }
            rv$grille[i, j] <- valeur_nouvelle
            print(paste("bouton", i, j))

            # Mettre à jour le label du bouton
            updateActionButton(
              session,
              bouton_id,
              label = ifelse(is.na(valeur_nouvelle), "", as.character(valeur_nouvelle))
            )
          })
        }
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
      output$timer <- renderText({
        temps_ecoule <- as.integer(difftime(Sys.time(), debut_temps(), units = "secs"))
        heures <- temps_ecoule %/% 3600
        minutes <- (temps_ecoule %% 3600) %/% 60
        secondes <- temps_ecoule %% 60
        sprintf("%02d:%02d:%02d", heures, minutes, secondes)
      })
      output$result = renderText(" 🎉 Bravo, vous avez réussi !")
    }
  })
}

# Lancer l'application
shinyApp(ui = ui, server = server)
