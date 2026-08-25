# Le Cyclone du Mage de l'Air — prompt pour la planche animée

## Ce qui existe déjà côté jeu

L'ultime est **fini et vérifié en headless**. Il ne reste que le dessin.

| | |
|---|---|
| **120 s** | il se lève et reste |
| **20 dégâts toutes les 1,6 s** | 75 décharges en tout, portée 4 cases |
| **traverse les haies** | seule chose du kit de l'Air qui le fasse |
| **il TRAÎNE** | 2,5 cases/s contre 4,9 au mage |

Ce dernier point est tout le sort : **on ne l'emporte pas, on le promène.** Il
reste en arrière dès qu'on court, il rattrape quand on s'arrête, et un mage qui
fuit en ligne droite le sème. Chaque décharge déclenche la bourrasque de l'Air —
le cyclone projette ce qu'il touche, et se prive lui-même de sa cible.

En attendant la planche, il emprunte le nuage d'orage du mage de la Foudre
(`StormCloud`, procédural). C'est jouable, ce n'est pas son visage.

---

## Ce que la planche doit dire, et que le code ne peut pas

Trois choses, dans l'ordre où elles comptent :

1. **une COLONNE, pas un nuage.** Le sort frappe à travers les haies, et la
   règle du projet est qu'un ultime n'a le droit de casser une règle *que si ça
   se voit*. C'est la hauteur qui le dit : la colonne doit visiblement monter
   plus haut que les murs du labyrinthe ;
2. **du vent ET de la foudre.** Le vent donne la forme, la foudre donne la
   menace. Une tornade grise se lirait comme un décor ;
3. **un sens de rotation lisible**, toujours le même. C'est ce qui distingue une
   colonne qui tourne d'une colonne qui vibre.

---

## Prompt 1 — la rotation (l'essentiel)

> Copier-coller tel quel. Fond MAGENTA : les modèles tiennent mal la
> transparence, et aucune palette du jeu ne contient de magenta.

```
Feuille d'animation pour un jeu 2D vu de DESSUS en légère plongée, style cartoon
coloré de jeu de rôle mobile, contours nets.

SUJET — un CYCLONE DE VENT ET DE FOUDRE, vu de trois quarts : une colonne
tourbillonnante haute et étroite, large en haut, effilée en bas là où elle
touche le sol. Le vent est fait de bandes blanc bleuté translucides qui
s'enroulent en spirale ; des ARCS ÉLECTRIQUES jaunes et blancs courent le long
de la colonne, entre les bandes, et quelques éclats crépitent à sa base. Des
débris clairs — feuilles, poussière, éclats de pierre — tournent avec elle.
Palette : blanc bleuté (#cfe9ff), bleu pâle, jaune électrique (#ffd93a) pour les
arcs, gris très clair pour les débris.

IMPORTANT — la colonne est PLUS HAUTE QUE LARGE, environ trois fois : elle doit
paraître dépasser un mur. Sa base est étroite et nette, son sommet s'évase.

FORMAT DE LA PLANCHE — impératif :
- fond MAGENTA UNI #FF00FF partout, aucun dégradé, aucune transparence ;
- grille RÉGULIÈRE de 4 colonnes sur 2 rangées, cases de 384x512 pixels
  exactement, image finale 1536x1024 ;
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte ;
- chaque dessin RESTE ENTIÈREMENT dans sa case, avec au moins 30 pixels de vide
  magenta tout autour ;
- la colonne a la MÊME TAILLE et la MÊME POSITION dans les huit cases : c'est un
  cycle de ROTATION, rien d'autre ne bouge ;
- sa base touche toujours la même hauteur, aux quatre cinquièmes de la case.

CONTENU — huit images d'un TOUR COMPLET, lues de gauche à droite puis rangée du
bas. Les bandes de vent tournent d'un huitième de tour à chaque image, TOUJOURS
DANS LE MÊME SENS (vers la droite quand elles passent devant). L'image 8 doit
enchaîner sur l'image 1 sans saut. Les arcs électriques changent de place et de
forme à chaque image — ils ne tournent pas, ils CLAQUENT.

À NE PAS FAIRE : pas d'arrière-plan, pas de sol dessiné, pas d'ombre portée, pas
de cadre, pas de texte, pas de flou, aucune case vide, aucun personnage.
```

---

## Prompt 2 — la décharge

Le cyclone foudroie soixante-quinze fois : il lui faut un éclair à lui, sinon
c'est celui du mage de la Foudre qu'on verra tomber.

```
Feuille d'effets pour un jeu 2D, même style et même palette que le cyclone,
fond MAGENTA UNI #FF00FF, aucun texte.

Image de 1024 x 256 pixels, grille RÉGULIÈRE de 4 colonnes sur 1 rangée
(4 cases de 256 x 256), une image par case, centrée, rien qui dépasse :

- case 1 : l'AMORCE — un halo bleu pâle qui se resserre, deux ou trois filaments
  électriques courts qui hésitent
- case 2 : LA DÉCHARGE — un éclair jaune-blanc épais, vertical, du haut de la
  case au bas, avec deux ramifications
- case 3 : L'IMPACT — une couronne de vent et d'étincelles qui s'ouvre au sol,
  vue de dessus, plus large que haute
- case 4 : LA RETOMBÉE — la couronne se disperse, quelques étincelles et un
  souffle de poussière
```

---

## Où les déposer

    assets/peso&cover/sorts/cyclone_spin.png     la rotation, 4 x 2
    assets/peso&cover/sorts/cyclone_bolt.png     la décharge, 4 x 1

Puis me le dire. `tools/build_spike_anim.py` sait déjà découper ce genre de
planche — grille imposée, détourage magenta, boîte commune — et il faudra
sûrement lui demander la découpe par GOUTTIÈRES et l'ancrage sur la BASE de la
colonne : c'est la base qui se pose sur la case du labyrinthe, comme la pointe
du cône du Grand souffle se pose sur le mage.

⚠️ Leçon des planches précédentes, à vérifier dès l'arrivée : le générateur
respecte rarement la grille au pixel près quand les dessins GRANDISSENT. Ici
rien ne grandit — c'est une rotation — donc la grille devrait tenir. Si elle ne
tient pas, ce sont les gouttières qui feront foi, pas les lignes.
