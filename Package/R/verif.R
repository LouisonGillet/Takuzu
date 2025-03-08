#' @title Vérification de la validité d'une grille
#'
#' @description
#' Vérifie que les règles du Takuzu sont respectées :
#' - Règle 1 : Chaque case de la grille doit être remplie avec un 0 ou un 1.
#' - Règle 2 : Chaque ligne et chaque colonne doivent contenir autant de 0 que de 1.
#' - Règle 3 : Il est interdit d’avoir trois 0 ou trois 1 consécutifs dans une ligne ou une colonne.
#' - Règle 4 : Deux lignes ou deux colonnes identiques sont interdites dans la même grille.
#'
#' @param grille Une matrice représentant la grille du jeu.
#' @return TRUE si la grille est valide, FALSE sinon.
#' @export

verifier_grille <- function(grille) {
  N <- ncol(grille)

  # Règle 1 : Chaque case de la grille doit être un 0 ou un 1
  if (any(!grille %in% c(0, 1))) {
    return(FALSE)
  }

  # Règle 2 : Chaque ligne et colonne contient autant de 0 que de 1
  if (any(rowSums(grille) != N / 2) || any(colSums(grille) != N / 2)) {
    return(FALSE)
  }

  # Règle 3 : Pas plus de deux 0 ou 1 consécutifs
  if (any(apply(grille, 1, function(x) any(rle(x)$lengths > 2))) ||
      any(apply(grille, 2, function(x) any(rle(x)$lengths > 2)))) {
    return(FALSE)
  }

  # Règle 4 : Aucune ligne ou colonne identique
  lignes_uniques <- unique(apply(grille, 1, paste, collapse = ""))
  colonnes_uniques <- unique(apply(grille, 2, paste, collapse = ""))
  if (length(lignes_uniques) != N || length(colonnes_uniques) != N) {
    return(FALSE)
  }

  return(TRUE)
}
