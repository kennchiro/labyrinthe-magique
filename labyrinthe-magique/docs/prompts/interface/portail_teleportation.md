# Le portail de téléportation, refait — prompt

## Pourquoi

Trois défauts, mesurés en capture dans le labyrinthe :

1. **il déborde du couloir.** Réglé à 1,6 case de haut (`Portal.TARGET_HEIGHT_TILES`)
   alors qu'un couloir en fait UNE : l'anneau monte sur les haies des deux côtés
   et l'on ne voit plus où l'on peut marcher ;
2. **il se délave.** Rendu en additif, un anneau blanc posé sur le sable clair du
   stage 3 devient une tache pâle. L'additif ne sait qu'éclaircir : sur un sol
   déjà clair, il n'a plus rien à ajouter ;
3. **huit couleurs, aucune cohérence.** L'idée était bonne — « le portail vert »
   est un repère mémorisable — mais huit teintes tirées de huit rangées d'une
   même planche ne font pas une famille, elles font huit sorts différents.

⚠️ **On perd donc le repère de couleur**, et c'est un vrai choix : on ne pourra
plus dire « celui d'à côté du dragon est le violet ». C'est le prix de la
cohérence, et il est assumé.

## Ce que la nouvelle planche doit être

**Huit images d'un SEUL TOUR**, dans une seule couleur. Les six ÉTATS du portail
— repos, ouverture, ouvert, actif, saut, fermeture — ne seront plus dessinés :
le jeu les exprimera sur cette boucle unique, par la vitesse de rotation, la
taille et l'éclat. C'est ce qui les rendra enfin cohérents entre eux, et ça
supprime trente-six dessins pour huit.

---

## Le prompt

```
Feuille d'animation pour un jeu 2D vu de DESSUS, style cartoon coloré de jeu de
rôle mobile, contours nets.

SUJET — un PORTAIL DE TÉLÉPORTATION posé À PLAT SUR LE SOL, vu de dessus en
légère plongée : un anneau de runes qui tourne. Deux cercles concentriques de
glyphes anciens, un cœur de lumière plus clair au centre, quelques éclats qui
montent du bord. Il est ÉCRASÉ en ellipse — plus large que haut, dans un rapport
d'environ 3 pour 2 — parce qu'on le regarde d'en haut et non de face.

COULEUR — UNE SEULE, un CYAN TURQUOISE lumineux (#3fe0e8) : glyphes cyan clair,
cœur presque blanc, halo turquoise sombre au bord. Aucune autre teinte, pas de
dégradé vers le violet ni vers le vert.

FORMAT DE LA PLANCHE — impératif :
- fond MAGENTA UNI #FF00FF partout, aucun dégradé, aucune transparence ;
- grille RÉGULIÈRE de 4 colonnes sur 2 rangées, cases de 256 x 256 pixels
  exactement, image finale 1024 x 512 ;
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte ;
- l'anneau, HALO COMPRIS, occupe environ 70 % de la largeur de sa case et laisse
  au moins 30 pixels de vide magenta tout autour. Il ne doit rien toucher ;
- il a exactement la MÊME TAILLE et le MÊME CENTRE dans les huit cases.

CONTENU — huit images d'UN TOUR COMPLET, lues de gauche à droite puis rangée du
bas. Les deux anneaux de runes tournent d'un huitième de tour à chaque image,
TOUJOURS DANS LE MÊME SENS, l'anneau intérieur un peu plus vite que l'extérieur.
L'image 8 doit enchaîner sur l'image 1 sans saut. Le cœur de lumière respire
légèrement, les éclats du bord changent de place à chaque image.

À NE PAS FAIRE : pas d'arrière-plan, pas de sol dessiné, pas d'ombre portée, pas
de cadre, pas de personnage, pas de flèche ni de symbole de direction, aucune
case vide, aucun anneau vu de FACE — il est posé au sol.
```

---

## Où la déposer, et ce que je fais ensuite

    assets/peso&cover/sorts/portail_unique.png

Puis me le dire. Je m'occupe du reste :

1. découpage en huit images calées sur un centre commun — c'est la même règle
   que l'onde du Grand souffle : le jeu pose ce sprite CENTRÉ sur la case, donc
   ce qui n'est pas au milieu de l'image n'est pas au milieu de la case ;
2. `Portal` cesse de charger une couleur par index et joue la boucle. Les six
   états deviennent des RÉGLAGES de cette boucle — au repos elle tourne
   lentement et sombre, à l'approche du mage elle s'anime et s'éclaire, au saut
   elle éclate une demi-seconde ;
3. la taille passe de **1,6 case à environ 0,95** : contenu entre deux murs, ce
   qui était la demande de départ ;
4. le rendu additif est revu — sur le sable du stage 3, un anneau clair en
   additif n'a plus rien à éclaircir. Probablement un mélange normal avec un
   noyau additif, comme la flaque d'ombre de l'Implosion ;
5. contrôle en capture sur un stage CLAIR (le 3, sable) et un stage SOMBRE (le
   5), parce que c'est là que les deux erreurs opposées se voient.

Les huit anciennes couleurs restent sur le disque le temps de la bascule : elles
sont la seule source tant que la nouvelle boucle n'est pas en place.
