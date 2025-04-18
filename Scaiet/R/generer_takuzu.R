#' Génération d'une grille de Takuzu valide
#'
#' Cette fonction génère une grille de Takuzu (aussi appelé Binairo) valide de dimension `taille` x `taille`.
#' La grille respecte toutes les règles du jeu : 
#' - Pas plus de deux chiffres identiques consécutifs (horizontalement ou verticalement)
#' - Autant de 0 que de 1 par ligne et colonne
#' - Aucune ligne ou colonne identique à une autre
#'
#' La grille est d'abord générée complètement par backtracking, puis un certain nombre de cases sont supprimées selon le niveau de difficulté spécifié.
#'
#' @param taille Un entier pair représentant la taille de la grille (ex. 6, 8, 10).
#' @param niveau Une chaîne de caractères indiquant le niveau de difficulté : "facile", "moyen", "difficile" ou "Einstein".
#'
#'
#' @return Une matrice de taille `taille` x `taille` contenant des 0, 1 et `NA` pour les cases à remplir par le joueur.
#'
#'
#' @export
generer_takuzu <- function(taille, niveau) {
  nb_cases_prepremplies = choisir_difficulte(taille,niveau)

  # Fonction interne pour valider une ligne/colonne
  est_valide_vec <- function(vec) {
    if (sum(vec == 0, na.rm = TRUE) > length(vec) / 2 ||
        sum(vec == 1, na.rm = TRUE) > length(vec) / 2) return(FALSE)
    if (any(rle(vec)$lengths > 2, na.rm = TRUE)) return(FALSE)
    return(TRUE)
  }
  
  # Vérifie s'il y a des doublons complets dans les lignes/colonnes
  aucun_duplicate <- function(grille) {
    lignes <- apply(grille, 1, paste, collapse = "")
    colonnes <- apply(grille, 2, paste, collapse = "")
    if (any(duplicated(lignes[!grepl("NA", lignes)]))) return(FALSE)
    if (any(duplicated(colonnes[!grepl("NA", colonnes)]))) return(FALSE)
    return(TRUE)
  }
  
  # Vérifie la validité actuelle de la grille
  est_valide_grille <- function(grille) {
    taille <- nrow(grille)
    for (i in 1:taille) {
      if (!est_valide_vec(grille[i, ]) || !est_valide_vec(grille[, i])) return(FALSE)
    }
    return(aucun_duplicate(grille))
  }
  
  # Générer une grille valide par backtracking
  grille <- matrix(NA, nrow = taille, ncol = taille)
  
  remplir <- function(i, j) {
    if (i > taille) return(TRUE)
    next_i <- if (j == taille) i + 1 else i
    next_j <- if (j == taille) 1 else j + 1
    for (val in sample(c(0, 1))) {
      grille[i, j] <<- val
      if (est_valide_vec(grille[i, ]) &&
          est_valide_vec(grille[, j]) &&
          aucun_duplicate(grille)) {
        if (remplir(next_i, next_j)) return(TRUE)
      }
      grille[i, j] <<- NA
    }
    return(FALSE)
  }
  
  remplir(1, 1)
  
  # Supprimer des cases aléatoirement
  total_cases <- taille * taille
  nb_a_supprimer <- total_cases - nb_cases_prepremplies
  indices <- sample(1:total_cases, nb_a_supprimer)
  grille[indices] <- NA
  
  return(grille)
}
