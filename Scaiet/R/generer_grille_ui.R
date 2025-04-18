#' Génère une grille interactive sous forme d'interface utilisateur Shiny
#'
#' Cette fonction crée une interface utilisateur en grille utilisant des boutons 
#' interactifs (`actionButton`) disposés selon un nombre de lignes et de colonnes spécifié. 
#' Elle inclut également les étiquettes de lignes (numéros) et de colonnes (lettres).
#'
#' Chaque bouton affiche une valeur provenant d'une matrice réactive et peut être désactivé 
#' selon une matrice de verrouillage. Elle est conçue pour être utilisée dans une application 
#' Shiny, notamment pour des jeux ou interfaces de saisie.
#'
#' @param nRows Integer. Le nombre de lignes de la grille.
#' @param nCols Integer. Le nombre de colonnes de la grille.
#' @param rv ReactiveValues. Un objet réactif contenant au minimum :
#' \describe{
#'   \item{\code{grille}}{Une matrice de caractères ou de valeurs à afficher sur les boutons.}
#'   \item{\code{verrouillees}}{Une matrice booléenne de même dimension que \code{grille}, 
#'   indiquant quelles cases sont désactivées (\code{TRUE} pour désactivé).}
#' }
#'
#' @return Un objet UI Shiny (`tagList`) contenant la grille complète, prête à être insérée 
#' dans l'UI d'une application Shiny.
#'
#' @import shiny
#' @export
#'
generer_grille_ui <- function(nRows, nCols, rv) {
  # Générer les étiquettes de colonnes (A, B, C, ...)
  lettres_colonnes <- LETTERS[1:nCols]
  
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
      color: black;
      background-color: white"
  
  # Ligne des en-têtes de colonnes
  header_row <- div(
    style = "display: flex; flex-direction: row; align-items: center;",
    div(style = "width: 54px;"),  # Case vide pour aligner avec les numéros de ligne
    lapply(1:nCols, function(j) {
      div(lettres_colonnes[j], style = css_coord)
    })
  )
  
  # Générer les lignes de la grille avec les étiquettes de lignes
  boutons <- lapply(1:nRows, function(i) {
    div(
      style = "display: flex; flex-direction: row; align-items: center;",
      div(strong(i), style = css_coord),  # Étiquette de ligne
      lapply(1:nCols, function(j) {
        actionButton(inputId = paste("bouton", i, j, sep = "_"),
                     label = ifelse(is.na(rv$grille[i, j]), "", as.character(rv$grille[i, j])),
                     style = paste0(css_case, "border-radius: 0;"),  # Suppression des bords arrondis
                     disabled = rv$verrouillees[i, j])
      })
    )
  })
  
  # Affichage complet (en-têtes + boutons)
  tagList(header_row, boutons)
}
