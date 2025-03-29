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
