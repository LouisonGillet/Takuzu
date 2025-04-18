
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

```r
install.packages(c("devtools", "shiny", "shinyjs", "shinythemes", "shinyWidgets", "shinyalert"))
```

## 💡 Pré-requis 

L'installation du package nécessite le package `devtools`. De la même manière, rentrez la commande suivante dans votre console pour l'installer : 

```r
install.packages("devtools")  
```

Ensuite, vous pouvez cloner notre GitHub :

```bash
git clone https://github.com/LouisonGillet/Takuzu.git
```

## 💻 Installation

Après avoir cloné le dépôt, vous pouvez installer le package localement avec devtools::install_local(). Cela permet d'installer la version locale du package Scaiet directement à partir du dossier cloné.

Dans la console R, entrez la commande suivante :

```r
devtools::install_local("./Takuzu/Scaiet", force = TRUE)
```
Le paramètre force = TRUE garantit que l'installation se fait même si une version antérieure est déjà installée.

Maintenant que le package est installé, changez de répertoire de travail pour le dossier où le projet a été cloné. Cela garantit que les chemins relatifs fonctionnent correctement.

```r
setwd("./Takuzu")
```

Une fois que vous êtes dans le bon répertoire, chargez le package Scaiet en utilisant la fonction library().

```r
library(Scaiet)
```

## 🧠 Lancer l'application Shiny

Une fois le package installé, vous pouvez lancer l'application Takuzu avec la fonction `run_app()` :

```r
run_app()
```

ou

```r
Scaiet::run_app()
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

