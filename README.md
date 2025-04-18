
# 📦 Takuzu

Bienvenue dans le package **Scaiet**, une application Shiny ludique pour jouer au jeu de logique Takuzu, avec plusieurs niveaux de difficulté et différentes tailles de grilles.

# 🚀 Installation

## 🔧 Dépendances

Ce package dépend principalement de :
- `shiny`
- `shinyjs`
- `shinythemes`
- `shinyWidgets`
- `shinyalert`

Avant l'installation de notre package **Scaiet**, assurez vous d'avoir installé les dépendances nécessaires. 
Pour cela, rentrez la commande suivante dans votre console: 

````r
install.packages(c("devtools", "shiny", "shinyjs", "shinythemes", "shinyWidgets", "shinyalert"))
```

## 💡 Pré-requis 

L'installation du package nécessite le package `devtools`. De la même manière, rentrez la commande suivante dans votre console pour l'installer : 

```r
install.packages("devtools")  
```

Ensuite, vous pouvez installer notre package **Scaiet** directement depuis GitHub :

```r
devtools::install_github("https://github.com/LouisonGillet/Takuzu")
```

## 🧠 Lancer l'application Shiny

Une fois le package installé, vous pouvez lancer l'application Takuzu avec la fonction `run_app()` :

```r
library(takuzu)
run_app()
```

Cela ouvrira automatiquement l’interface depuis RStudio.

# 📚 Documentation

Une documentation complète des fonctions exportées du package est disponible. Par exemple :

```r
?generer_takuzu
```

Vous pouvez également parcourir la documentation générée dans l’onglet **Help** de RStudio après avoir chargé le package.

# 👥 Auteurs

Ce package a été développé dans le cadre de l'UE HAX815X - Programmation R de l'université de Montpellier, par : 
- **Scaia Matteo** : matteo.scaia@etu.umontpellier.fr
- **Gillet Louison** : louison.gillet@etu.umontpellier.fr

---

