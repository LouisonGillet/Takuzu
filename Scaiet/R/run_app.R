#' @title Lancer l'application Shiny du package Takuzu
#'
#' @description
#' Cette fonction permet de lancer l'application Shiny embarquée dans le package.
#' L'exécute via `shiny::runApp()`. Elle est destinée à être utilisée par l'utilisateur
#' final du package.
#'
#' @return Aucune valeur de retour. Cette fonction a pour effet de démarrer une session Shiny.
#'
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#'
#' @export

run_app <- function() {
  appDir <- "./Scaiet/app/app.R"
  
  if (!file.exists(appDir)) {
    stop("Le fichier de l'application est introuvable : ", appDir)
  }
  
  shiny::runApp(dirname(appDir), display.mode = "normal")
}

