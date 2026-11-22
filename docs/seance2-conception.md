# Séance 2 : dossier de conception v1

## 1. Persona

**Amina Ouédraogo, 22 ans, Master 1 Informatique à Ouagadougou.**

- **Appareil :** téléphone Android d'entrée de gamme (écran de 6,5 pouces, 3 Go de mémoire, Android 12), forfait internet de 2 Go par mois. Elle travaille aussi sur un PC portable partagé.
- **Contexte :** six cours ce semestre, des devoirs annoncés à l'oral, sur le groupe WhatsApp de la promotion ou par e-mail. Elle se déplace en moto entre le campus et un petit emploi le soir.
- **Difficultés :** les consignes sont noyées dans des centaines de messages, elle note les dates sur un cahier qu'elle n'a pas toujours avec elle, et elle a déjà rendu un TP en retard faute de rappel. Le réseau coupe souvent et elle évite les applications lourdes.
- **Objectif :** savoir chaque matin ce qu'elle doit rendre dans la semaine, sans y passer plus d'une minute.

## 2. Job stories

1. **Quand** un enseignant annonce un devoir en fin de cours, **je veux** l'enregistrer en moins de 30 secondes avec sa date et son cours, **pour** ne plus dépendre de ma mémoire ni du fil WhatsApp.
2. **Quand** je commence ma journée, **je veux** voir d'un coup d'œil les échéances des sept prochains jours et celles qui sont en retard, **pour** décider dans quel ordre travailler.

## 3. Parcours « suivre mes échéances »

| Étape | Action d'Amina | Friction | Opportunité pour CampusFlow |
| --- | --- | --- | --- |
| 1. Planifier | Elle reçoit le plan de cours et les dates d'examen en début de semestre. | Les dates sont dans plusieurs PDF et messages. | Une liste « Mes cours » avec les tâches de chaque cours et leur avancement. |
| 2. Consulter | Le matin, elle veut savoir ce qui arrive. | Elle doit relire son cahier et le groupe WhatsApp. | Écran Échéances : résumé de la semaine, bande des 7 prochains jours, tâches groupées par jour. |
| 3. Ajouter | Un devoir est annoncé en fin de cours. | Elle n'a pas le temps de tout noter, elle oublie le cours concerné. | Bouton « Nouvelle tâche » toujours visible, titre obligatoire, cours et date préremplis, rappel d'un jour par défaut. |
| 4. Être rappelée | La veille d'un rendu. | Aucun rappel, ou un rappel trop tard. | Bandeau de rappel en haut de la liste et filtre « En retard ». |
| 5. Rendre | Elle dépose son travail. | Elle ne sait plus ce qui est fait ou non. | « Marquer comme fait » en un geste (bouton, case ou balayage), avec possibilité d'annuler. |

## 4. Wireframes

Cinq écrans dessinés en basse fidélité (fichiers SVG dans [`wireframes/`](wireframes/)) :

1. [Connexion](wireframes/wf-1-connexion.svg)
2. [Échéances, variante A](wireframes/wf-2-echeances-A.svg)
3. [Détail d'une tâche](wireframes/wf-3-detail.svg)
4. [Nouvelle tâche](wireframes/wf-4-formulaire.svg)
5. [Cours](wireframes/wf-5-cours.svg)

Trois variantes de l'écran Échéances :

- **A. Liste groupée par jour** ([wf-2-echeances-A](wireframes/wf-2-echeances-A.svg)) : résumé de la semaine, trois filtres, tâches groupées par jour.
- **B. Calendrier mensuel** ([wf-2-echeances-B](wireframes/wf-2-echeances-B.svg)) : grille du mois avec des points sur les jours chargés.
- **C. Tableau par statut** ([wf-2-echeances-C](wireframes/wf-2-echeances-C.svg)) : trois colonnes À faire, En retard, Faites.

### Choix de la variante (grille du cours)

| Critère | A. Liste par jour | B. Calendrier | C. Tableau par statut |
| --- | --- | --- | --- |
| Besoin (job story 2) | Répond directement : ce qui arrive, dans l'ordre. | Montre le mois, mais il faut toucher chaque jour pour voir les tâches. | Montre le statut, pas l'ordre des dates. |
| Parcours (étapes 2 à 5) | Consulter, ajouter et cocher depuis le même écran. | Une étape de plus pour voir une tâche. | Cocher revient à déplacer une carte, peu naturel au pouce. |
| Accessibilité | Grandes cibles tactiles, texte lisible, ordre de lecture simple pour un lecteur d'écran. | Cases petites sur 360 dp, chiffres difficiles à toucher. | Colonnes de 100 dp, texte tronqué. |
| Faisabilité | ListView.builder et ListTile, vus en séance 5. | Composant calendrier à écrire ou à ajouter. | Défilement horizontal et glisser-déposer plus complexes. |

**Variante retenue : A.** Elle sert le mieux le besoin principal d'Amina et elle est la plus simple à réaliser et à rendre accessible. La variante C est réutilisée sous forme de trois filtres (À faire, En retard, Faites) et la variante B sous forme d'une bande des 7 prochains jours.

Les captures de l'application réalisée sont dans [`captures/`](captures/).

## 5. Design system v1

### Couleurs

Une couleur de marque, le rouge CampusFlow `#EC3013`. Le thème Material 3 est généré à partir de cette couleur (`ColorScheme.fromSeed`, variante fidelity), en clair et en sombre. Les contrastes du texte sont vérifiés par le test automatique `campusflow_app/test/contraste_test.dart` (minimum 4,5:1) :

| Usage | Thème clair | Contraste | Thème sombre | Contraste |
| --- | --- | --- | --- | --- |
| Texte sur bouton principal | `#FFFFFF` sur `#B71800` | 6,68:1 | `#660800` sur `#FFB4A6` | 7,71:1 |
| Texte sur fond de page | `#291714` sur `#F5F5F7` | 15,72:1 | `#FDDBD5` sur `#1F0F0C` | 14,37:1 |
| Texte sur carte | `#291714` sur `#FFFFFF` | 17,12:1 | `#FDDBD5` sur `#2D1B17` | 12,70:1 |
| Texte secondaire sur carte | `#5D3F3A` sur `#FFFFFF` | 9,39:1 | `#E7BDB5` sur `#2D1B17` | 9,64:1 |
| Erreur, « En retard » | `#BA1A1A` sur `#FFFFFF` | 6,46:1 | `#FFB4AB` sur `#2D1B17` | 9,66:1 |

Le rouge de marque `#EC3013` n'atteint que 4,2:1 avec du texte blanc : il sert aux aplats et aux dégradés, jamais comme fond de texte courant.

### Typographie

Police système de Material 3 (Roboto sur Android). Titres en gras : `headlineMedium` (28) pour les titres de page, `titleLarge` (22) pour la barre d'application, `titleMedium` (16, demi-gras) pour le titre d'une tâche, `bodyMedium` (14) pour le texte courant, `labelMedium` (12) pour les métadonnées. Les tailles suivent le réglage de taille de texte du téléphone.

### Espacements, formes et cibles tactiles

- Espacements sur une grille de 4 : 4, 8, 12, 16, 20, 24, 32.
- Rayons : 12 (petits éléments), 16 (champs, puces), 24 (cartes).
- Cible tactile minimale : 48 × 48 dp.

### Trois composants

1. **Bouton principal** (`FilledButton`) : pleine largeur en bas de l'écran, à portée du pouce, un seul par écran (« Se connecter », « Enregistrer », « Marquer comme fait »).
2. **Carte de tâche** (`Card` + `ListTile`) : pastille du cours à gauche, titre, date relative et heure, nom du cours, badge « En retard » en rouge, case à cocher à droite. Balayer vers la droite coche la tâche.
3. **Champ de saisie** (`TextFormField`) : libellé au-dessus, exemple en indication, message d'erreur sous le champ (« Le titre est obligatoire »).

### Tailles de fenêtre visées

| Classe | Largeur | Navigation | Mise en page |
| --- | --- | --- | --- |
| Compacte (téléphone) | moins de 600 dp | `NavigationBar` en bas | Liste seule, le détail s'ouvre par-dessus |
| Moyenne (petite tablette, téléphone à l'horizontale) | 600 à 839 dp | `NavigationRail` à gauche | Liste seule |
| Étendue (tablette) | 840 dp et plus | `NavigationRail` à gauche | Liste et détail côte à côte (`LayoutBuilder`) |
