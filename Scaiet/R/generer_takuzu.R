#' Génère une grille Takuzu valide avec un niveau de difficulté donné
#'
#' @param taille Un entier pair représentant la taille de la grille (ex: 6, 8, 10).
#' @param niveau Un caractère indiquant le niveau de difficulté : "facile", "moyen", ou "difficile".
#' @return Une matrice de taille x taille contenant la grille Takuzu avec certaines cases vides.
#' @export
generer_takuzu <- function(taille, niveau) {
  nb_cases_prepremplies = choisir_difficulte(taille,niveau)

  # Initialisation d'une grille vide
  grille = matrix(NA, nrow = taille, ncol = taille)

  # Fonction pour vérifier si une ligne ou une colonne est valide
  est_valide_partiel <- function(vec) {
    if (sum(vec == 0, na.rm = TRUE) > length(vec) / 2 ||
        sum(vec == 1, na.rm = TRUE) > length(vec) / 2) {
      return(FALSE)
    }
    if (any(rle(vec)$lengths > 2, na.rm = TRUE)) {
      return(FALSE)
    }
    return(TRUE)
  }

  # Génération progressive d'une grille valide
  for (i in 1:taille) {
    for (j in 1:taille) {
      candidats = sample(c(0, 1))
      for (val in candidats) {
        grille[i, j] <- val
        if (est_valide_partiel(grille[i, ]) && est_valide_partiel(grille[, j])) {
          break
        }
        grille[i, j] = NA
      }
    }
  }

  # Suppression de cases pour correspondre au niveau de difficulté
  indices = sample(1:(taille^2), taille^2 - nb_cases_prepremplies)
  grille[indices] <- NA

  return(grille)
}
