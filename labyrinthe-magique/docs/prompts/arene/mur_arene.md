# mur_arene — les MURS de l'arène

Le MÊME gabarit de seize pièces que les `terrain_N_mur` : l'outil de découpage
(`build_terrain.py`) ne garde que la croix et les deux barres, et fabrique les seize pièces
à partir d'elles. Ce sont les piliers, les haies du nord et du sud, et les quatre bornes de la
Gemme-Cœur.

Résultat attendu : `arene_mur.png` dans `assets/peso&cover/terrain/`.

Joins `sol_arene.png` une fois qu'il existe : le mur doit se détacher de CE sol.

```
Planche de tuiles pour un jeu 2D vu de DESSUS, style cartoon coloré, contour
marqué, même facture et même palette que l'image de référence jointe.

SUJET : un MURET d'arène en pierre de taille claire, coiffé d'une margelle de pierre plus pâle cerclée de bronze, avec de rares runes bleues gravées sur le dessus, vu de dessus. Le mur a une ÉPAISSEUR : on voit une fine
tranche plus sombre le long de son bord BAS, et une ombre douce portée sur le sol
sous ce bord.

FORMAT, à respecter exactement :
- image de 1024 x 1024 pixels
- grille RÉGULIÈRE de 4 colonnes x 4 rangées, soit 16 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
- aucun texte, aucun chiffre, aucune bordure dessinée, aucun trait de grille

LA RÈGLE QUI COMPTE PLUS QUE TOUT — LE RACCORD :
chaque pièce est un tronçon de mur de MÊME LARGEUR, toujours CENTRÉ dans sa case.
Quand un tronçon rejoint un bord de case, il doit TOUCHER ce bord et le remplir
sur toute sa largeur, sans arrondi et sans magenta résiduel : deux cases posées
côte à côte dans le jeu doivent former un mur continu, sans décrochement ni
bosse. Là où un tronçon NE rejoint PAS un bord, il se termine par un bout
ARRONDI, et le magenta reste visible jusqu'au bord.

LES 16 CASES, de gauche à droite puis de haut en bas. « ouvert vers X » = le
tronçon touche ce bord de la case.

Rangée 1
1. bloc ISOLÉ : une masse ronde au centre, qui ne touche AUCUN bord
2. cul-de-sac ouvert vers le HAUT (arrondi en bas)
3. cul-de-sac ouvert vers la DROITE (arrondi à gauche)
4. cul-de-sac ouvert vers le BAS (arrondi en haut)

Rangée 2
5. cul-de-sac ouvert vers la GAUCHE (arrondi à droite)
6. tronçon DROIT vertical : ouvert vers le haut ET vers le bas
7. tronçon DROIT horizontal : ouvert vers la gauche ET vers la droite
8. COIN ouvert vers le HAUT et vers la DROITE

Rangée 3
9.  COIN ouvert vers la DROITE et vers le BAS
10. COIN ouvert vers le BAS et vers la GAUCHE
11. COIN ouvert vers la GAUCHE et vers le HAUT
12. T ouvert vers le HAUT, la DROITE et le BAS (fermé à gauche)

Rangée 4
13. T ouvert vers la DROITE, le BAS et la GAUCHE (fermé en haut)
14. T ouvert vers le BAS, la GAUCHE et le HAUT (fermé à droite)
15. T ouvert vers la GAUCHE, le HAUT et la DROITE (fermé en bas)
16. CROIX : ouvert vers les QUATRE bords

COULEURS : pierre claire gris-beige, margelle presque blanche, bronze chaud sur les bords, runes bleu pâle. Le mur doit se DÉTACHER franchement du sol de
la référence : c'est derrière lui que les héros se cachent des tirs, on doit le voir d'un coup d'œil. Donne-
lui une LUMINOSITÉ nettement différente de celle du sol — plus claire ou plus
sombre, peu importe, mais jamais la même valeur.

AUTRES RÈGLES :
- exactement la MÊME largeur de tronçon, la MÊME matière et le MÊME niveau de
  détail dans les 16 cases. Une pièce plus épaisse que sa voisine se verrait à
  chaque jonction du labyrinthe
- la lumière vient toujours du HAUT, jamais de côté : le dessus est clair, la
  tranche du bas est plus sombre. Ne fais pas tourner cet éclairage d'une pièce
  à l'autre
- les détails (runes, fissures, éclats de bronze) sont ÉPARS et jamais aux mêmes
  endroits d'une case à l'autre
- rien ne dépasse sur la case voisine
- aucun personnage, aucun sol, aucun décor, aucun objet posé
```

Si ça revient mal : mêmes corrections que pour les murs des stages
(voir la fin de [terrain_1_mur](../terrain_1_mur.md)).
