#' Générer une grille de Takuzu avec un niveau de difficulté donné
#'
#' Cette fonction crée une grille de Takuzu de taille `taille x taille` en remplissant
#' un certain nombre de cases en fonction du niveau de difficulté choisi.
#'
#' @param niveau Un caractère indiquant le niveau de difficulté. Doit être l'un des suivants :
#'   - `"facile"` (50% des cases remplies)
#'   - `"moyen"` (40% des cases remplies)
#'   - `"difficile"` (30% des cases remplies)
#'   - `"Einstein"` (10% des cases remplies, très difficile)
#' @param taille Un entier représentant la taille de la grille (doit être un multiple de 2 entre 4 et 100).
#'
#' @return Une matrice `taille x taille` contenant des valeurs `0`, `1` et `NA` (cases vides).
#' @export
#'
generer_takuzu <- function(niveau, taille) {
  # Vérifier que la taille est valide
  if (!(taille %in% seq(4, 100, 2))) {
    stop("La taille de la grille doit être un multiple de 2 entre 4 et 100.")
  }
  nb_cases <- choisir_difficulte(taille, niveau) #Nombre cases préremplies

  # Créer une matrice vide
  grid <- matrix(NA, nrow = taille, ncol = taille)

  # Sélectionner aléatoirement les positions à remplir
  positions <- sample(1:(taille * taille), nb_cases, replace = FALSE)

  # Générer autant de 0 que de 1
  valeurs <- sample(rep(c(0, 1), length.out = nb_cases))

  # Remplir la grille avec ces valeurs
  grid[positions] <- valeurs

  return(grid)
}
