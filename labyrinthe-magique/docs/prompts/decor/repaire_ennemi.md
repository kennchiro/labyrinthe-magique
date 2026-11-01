# Le repaire des ennemis, refait — prompt

## Pourquoi

Défauts relevés sur `assets/lairs/` et en capture :

1. **les poses débordent de leur case** : le dessin touche les deux bords sur les six
   poses, sans aucune marge ;
2. **une frange blanche** entoure l'éruption, reste du détourage sur fond blanc ;
3. **des créatures sont dessinées dans la dernière pose**, alors que le jeu fait sortir
   le vrai ennemi : on voit un monstre qui n'est pas le bon, en double ;
4. **le bâtiment bouge d'une pose à l'autre**, et se lit mal à sa taille réelle.

## Les dimensions du jeu

| Mesure | Valeur |
|---|---|
| Case de la planche | 256 x 320, même rapport que la case actuelle (105 x 132) |
| Planche | 6 colonnes x 4 rangées, soit 1536 x 1280 |
| Rangées | rouge, violet, vert, cyan (`COLORS` de `build_lairs.py`) |
| Colonnes | fermé, lueur, portail, ouvert, plein, éruption |
| Pied du bâtiment | y = 269 sur 320, soit 84 % : c'est lui qui tombe sur la case du labyrinthe |
| Taille en jeu | 2,6 cases de haut (`EnemyLair.TARGET_HEIGHT_TILES`), environ 90 px à l'écran |
| Barre de vie | à 1,55 case au-dessus du pied, dessinée par le jeu |

---

## Le prompt

```
Feuille d'animation pour un jeu 2D de labyrinthe, style cartoon coloré de jeu de rôle
mobile, contours sombres nets et épais, grandes formes simples. L'image sera affichée
très petite, environ 90 pixels de haut : la silhouette doit se lire au premier regard,
sans petits détails.

SUJET — LE REPAIRE DES MONSTRES : une petite chapelle maudite en pierre sombre et bois
noirci, toit pentu à deux pans et grande porte en arc au centre de la façade, surmontée
d'un seul grand crâne cornu. Un socle de pierre bas et compact, sans sol autour. Le
bâtiment est trapu, presque aussi large que haut.

VUE — de FACE, en légère plongée d'environ 30 degrés : la façade et la porte regardent
droit vers le bas de l'image, le bâtiment est parfaitement symétrique. On voit un peu le
dessus du toit. Pas de vue de trois quarts, pas de vue de côté.

FORMAT DE LA PLANCHE — impératif :
- image finale de 1536 x 1280 pixels ;
- fond MAGENTA UNI #FF00FF partout, aucun dégradé, aucune transparence ;
- grille RÉGULIÈRE de 6 colonnes sur 4 rangées, cases de 256 x 320 pixels exactement ;
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte ;
- dans CHAQUE case, le bâtiment occupe 200 pixels de large et 200 pixels de haut,
  centré en largeur, le bas de son socle à 51 pixels du bas de la case ;
- le bâtiment a exactement la MÊME TAILLE et la MÊME POSITION dans les 24 cases : seules
  les lumières changent, jamais une pierre ni une planche ;
- rien ne touche le bord d'une case, pas même la lumière : au moins 20 pixels de magenta
  tout autour. Aucune pose ne touche sa voisine.

LES QUATRE RANGÉES — le MÊME bâtiment, seule la couleur de la magie change :
1. rouge #FF3B2E
2. violet bleuté #8A5CFF
3. vert #6DFF3A
4. cyan #3FE0E8
La pierre et le bois restent gris-brun très sombres dans les quatre rangées, sans mousse,
sans sable, sans neige : le repaire doit aller sur tous les décors.

LES SIX COLONNES — l'ouverture du repaire, de gauche à droite :
1. FERMÉ : la porte de bois est close, les yeux du crâne à peine allumés.
2. LUEUR : porte encore close, une lumière filtre sous la porte et les yeux brillent.
3. PORTAIL : les battants ont disparu, une nappe de lumière vibre dans l'arche.
4. OUVERT : un tourbillon de magie net remplit l'arche.
5. PLEIN : le tourbillon est au plus vif, et trois courts traits de lumière montent du
   toit, sans sortir de la case.
6. ÉRUPTION : l'arche est grande ouverte sur un fond noir cerné de lumière, et un éclat
   de magie s'étale devant le seuil. Aucune créature : le jeu fera sortir le vrai monstre.

LA LUMIÈRE — à bords nets, en aplats : pas de halo flou, pas de lueur diffuse, pas
d'étincelles isolées autour du bâtiment. Le fond magenta doit rester parfaitement pur
jusqu'au contour.

À NE PAS FAIRE : aucun personnage, aucun monstre, aucune silhouette dans la porte, pas de
sol, pas d'ombre portée, pas d'herbe ni de cailloux autour du socle, aucune case vide, pas
de texte, pas de grand portrait du bâtiment à côté de la grille.
```

---

## Où la déposer

    assets/peso&cover/decor/repaire_ennemi.png

C'est la planche branchée depuis le 2026-11-01 : `build_lairs.py` la découpe en cases de
128 x 160, et lit la grille annoncée. Elle est sortie fidèle : le bâtiment ne bouge pas
d'une pose à l'autre, à 1 px près hors traits de lumière. Son socle est à 42 px du bas au
lieu de 51, et elle fait 213 x 228 au lieu de 200 x 200 : `frames.json` porte donc `feet_y`,
et `EnemyLair` règle sa taille sur cette mesure.
