#' Vérifie si une grille de Takuzu est valide
#'
#' @param grille Une matrice représentant la grille de jeu (0 et 1).
#' @return TRUE si la grille est valide, FALSE sinon.
#' @export
verifier_grille <- function(grille) {
  N = ncol(grille)
  V1 = rowSums(grille)
  V2 = colSums(grille)

  # Règle 1 : Chaque ligne et colonne contient autant de 0 que de 1
  if (any(V1 != N / 2) | any(V2 != N / 2)) {
    return(FALSE) # Si une ligne ou une colonne a un nombre incorrect de "1", retourne FALSE
  }

  # Règle 2 : Pas plus de deux 0 ou 1 consécutifs
  if (any(apply(grille, 1, function(x) any(rle(x)$lengths > 2))) ||
      any(apply(grille, 2, function(x) any(rle(x)$lengths > 2)))) {
    return(FALSE)
  }

  # Règle 3 : Aucune ligne ou colonne identique
  lignes_uniques <- unique(apply(grille, 1, paste, collapse = ""))
  colonnes_uniques <- unique(apply(grille, 2, paste, collapse = ""))
  if (length(lignes_uniques) != N || length(colonnes_uniques) != N) {
    return(FALSE)
  }

  return(TRUE)
}
