#' @title Choisir le nombre de cases préremplies en fonction de la difficulté
#'
#' @description
#' Cette fonction détermine combien de cases doivent être préremplies dans une
#' grille de Takuzu en fonction de la taille et du niveau de difficulté choisi.
#'
#' @param taille Un entier représentant la taille de la grille (doit être un multiple de 2 entre 4 et 100).
#' @param niveau Un caractère indiquant le niveau de difficulté. Doit être l'un des suivants :
#'   - `"Facile"` (50% des cases remplies)
#'   - `"Moyen"` (40% des cases remplies)
#'   - `"Difficile"` (30% des cases remplies)
#'   - `"Einstein"` (10% des cases remplies, très difficile)
#'
#' @return Un entier correspondant au nombre de cases à préremplir.
#' @export
#'
choisir_difficulte <- function(taille, niveau) {
  # Configuration des niveaux en foncion du pourcentage de cases remplies
  niveaux <- list("Facile" = 0.5, "Moyen" = 0.4,   "Difficile" = 0.3, "Einstein" = 0.1)
  if (!(niveau %in% names(niveaux))) {
    stop("Choisissez un niveau parmi : Facile, Moyen, Difficile, Einstein")
  }
  # Calcul du nombre de cases à remplir
  nb_cases = round(taille * taille * niveaux[[niveau]])
  return(nb_cases)
}
