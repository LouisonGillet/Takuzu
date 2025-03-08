#' Choisir le nombre de cases préremplies en fonction de la difficulté
#'
#' Cette fonction détermine combien de cases doivent être préremplies dans une
#' grille de Takuzu en fonction de la taille et du niveau de difficulté choisi.
#'
#' @param taille Un entier représentant la taille de la grille (doit être un multiple de 2 entre 4 et 100).
#' @param niveau Un caractère indiquant le niveau de difficulté. Doit être l'un des suivants :
#'   - `"facile"` (50% des cases remplies)
#'   - `"moyen"` (40% des cases remplies)
#'   - `"difficile"` (30% des cases remplies)
#'   - `"Einstein"` (10% des cases remplies, très difficile)
#'
#' @return Un entier correspondant au nombre de cases à préremplir.
#' @examples
#' choisir_difficulte(8, "moyen") # Retourne environ 26 cases pour une grille 8x8
#' @export
#'
choisir_difficulte <- function(taille, niveau) {
  # Vérifie que la taille est valide (parcours les tailles possibles de 4 a 100)
  if (!(taille %in% seq(4,100,2))) {
    stop("La taille de la grille doit être de taille 2n*2n")
  }
  # Configuration des niveaux en foncion du pourcentage de cases remplies
  niveaux <- list("facile" = 0.5, "moyen" = 0.4,   "difficile" = 0.3, "Einstein" = 0.1)
  if (!(niveau %in% names(niveaux))) {
    stop("Choisissez un niveau parmi : facile, moyen, difficile, Einstein")
  }
  # Calcul du nombre de cases à remplir
  nb_cases <- round(taille * taille * niveaux[[niveau]])
  return(nb_cases)
}
