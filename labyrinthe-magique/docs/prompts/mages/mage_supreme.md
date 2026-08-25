# Regénérer la planche du Sorcier Suprême — prompt à donner à ChatGPT

## Pourquoi

Mesuré sur les huit mages (hauteur du personnage à l'écran, tous normalisés sur
la même case) :

| mage | à l'écran | | mage | à l'écran |
|---|---:|---|---|---:|
| Foudre | 40,9 px | | Ténèbres | 38,3 px |
| Air | 40,9 px | | **Suprême** | **37,8 px** |
| Terre | 36,8 px | | Eau | 35,7 px |
| Invocateur | 36,8 px | | Feu | 34,2 px |

Le Suprême n'est donc **pas** le plus petit en chiffres — mais il le paraît, et
c'est ce qui compte. Sa figure est une silhouette fine et sombre au milieu d'une
grande aura : à 38 px de haut dans un labyrinthe, on voit la lueur, pas le mage.
Les autres sont des corps compacts au contour net.

Ce que la nouvelle planche doit corriger, dans l'ordre :
1. **un corps compact et lisible**, pas une silhouette noyée ;
2. **l'aura serrée contre le corps** — elle ne doit pas doubler la boîte ;
3. le personnage **remplit sa case** (≈ 80 % de sa hauteur).

---

## Prompt 1 — la planche de mouvements (l'essentiel)

> Copier-coller tel quel. La version anglaise en dessous marche souvent mieux
> avec les générateurs d'images ; les deux disent la même chose.

```
Feuille de sprites pour un jeu 2D vu de dessus, style pixel-art cartoon coloré,
même facture que des sprites de RPG mobile.

PERSONNAGE : le Sorcier Suprême, maître des quatre éléments. Robe sombre à
liserés d'or, capuchon, quatre orbes élémentaires (rouge feu, bleu eau, vert
terre, violet ténèbres) tournant autour de lui. Corps COMPACT et TRAPU, tête
large, silhouette lisible en très petit. L'aura reste COLLÉE au corps : pas de
halo large, pas de nuage de particules autour.

FORMAT DE LA FEUILLE, à respecter exactement :
- image de 1536 x 1024 pixels
- une grille RÉGULIÈRE de 6 colonnes x 4 rangées, soit 24 cases de 256 x 256
- fond UNI, gris très foncé, sans dégradé, sans texture, sans cadre
- aucun texte, aucune étiquette, aucun numéro, aucune bordure dessinée

RANGÉES (orientation du personnage) :
- rangée 1 : vu de FACE, il regarde le spectateur
- rangée 2 : vu de DOS
- rangée 3 : de PROFIL vers la GAUCHE
- rangée 4 : de PROFIL vers la DROITE

COLONNES (la même suite dans chaque rangée) :
- colonne 1 : au repos, immobile
- colonnes 2 à 5 : quatre images d'un cycle de MARCHE (jambe gauche, passage,
  jambe droite, passage)
- colonne 6 : pose d'ATTAQUE, bras tendu, les quatre orbes réunies en un trait
  de lumière dorée

RÈGLES IMPORTANTES :
- le personnage occupe environ 80 % de la hauteur de sa case, PIEDS près du bas
- exactement la MÊME taille, les mêmes couleurs et le même style dans les 24
  cases ; seule la pose change
- chaque personnage reste ENTIÈREMENT dans sa case : rien ne dépasse sur la case
  voisine, ni cape, ni bâton, ni lueur
- une marge vide d'au moins 10 pixels tout autour de chaque case
```

<details>
<summary>Version anglaise</summary>

```
Top-down 2D game sprite sheet, colorful cartoon pixel-art style, mobile RPG look.

CHARACTER: the Supreme Sorcerer, master of the four elements. Dark robe with gold
trim, hood, four elemental orbs (red fire, blue water, green earth, purple shadow)
orbiting him. STOCKY, COMPACT body, large head, silhouette readable at very small
size. The aura stays TIGHT to the body: no wide halo, no particle cloud around him.

SHEET FORMAT, follow exactly:
- 1536 x 1024 pixel image
- a REGULAR grid of 6 columns x 4 rows, i.e. 24 cells of 256 x 256
- PLAIN very dark grey background, no gradient, no texture, no frame
- no text, no labels, no numbers, no drawn borders

ROWS (character facing):
- row 1: FRONT view, facing the viewer
- row 2: BACK view
- row 3: side view facing LEFT
- row 4: side view facing RIGHT

COLUMNS (same sequence in every row):
- column 1: idle, standing still
- columns 2 to 5: four frames of a WALK cycle
- column 6: ATTACK pose, arm extended, the four orbs merging into a golden beam

IMPORTANT RULES:
- the character fills about 80% of the cell height, FEET near the bottom
- exactly the SAME size, colors and style in all 24 cells; only the pose changes
- each character stays ENTIRELY inside its cell: nothing crosses into the
  neighbouring cell, no cape, no staff, no glow
- at least 10 pixels of empty margin around each cell
```
</details>

---

## Prompt 2 — la planche d'effets (ses sorts)

Le jeu découpe aussi quatre effets dessinés par mage. Demander une **seconde
image**, séparée : mélangée à la première, elle brouille la détection de grille.

```
Feuille d'effets magiques pour un jeu 2D, même style que la feuille du Sorcier
Suprême, fond UNI gris très foncé, aucun texte.

Image de 1024 x 1024 pixels, grille RÉGULIÈRE de 2 colonnes x 2 rangées
(4 cases de 512 x 512), un effet par case, centré, sans rien qui dépasse :

- case 1 : un PROJECTILE — un trait de lumière prismatique qui file vers la
  DROITE, mêlant rouge, bleu, vert et violet, avec une traînée derrière lui
- case 2 : un IMPACT — l'explosion de ce trait, une étoile de lumière dorée aux
  quatre couleurs élémentaires
- case 3 : une ZONE au sol — un grand cercle runique doré vu de dessus, comme
  gravé sur le sol, avec quatre segments élémentaires
- case 4 : une TÉLÉPORTATION — une colonne de lumière dorée verticale, fine,
  avec des éclats prismatiques
```

---

## Ce que je fais quand les images arrivent

Déposer les deux images dans **`assets/peso&cover/refonte/`** sous ces noms :

    refonte/supreme.png       la planche de mouvements
    refonte/supreme_fx.png    la planche d'effets

⚠️ **Ne pas écraser la planche actuelle du mage.** Elle ne sert pas qu'au
personnage : `build_spell_fx.py` y découpe son orbe, son impact et sa zone, et
`build_warps.py` sa colonne de téléportation — à des coordonnées relevées à la
main DANS la planche. L'écraser remplacerait le mage et ses quatre effets par un
découpage au hasard, sans le moindre message d'erreur. Le mage ne bascule que
quand ses DEUX planches sont là. Voir `assets/peso&cover/refonte/LISEZ-MOI.md`.

Ensuite je m'occupe du reste :

1. `tools/build_characters.py` — la grille de 256 px sort de la fenêtre de
   détection automatique (calibrée sur 70-220 px) : je l'**imposerai** dans la
   table `SHEETS` avec `"grid": (256, 256, 0, 0)`, comme c'est déjà fait pour le
   dragonnet et le minotaure. C'est justement pour ça que le prompt exige une
   grille régulière et des marges — c'est vérifiable et imposable.
2. `tools/build_spell_fx.py` — quatre boîtes relevées à la main sur la feuille
   d'effets, comme pour les sept autres mages.
3. Contrôle à l'image : les 24 poses sur fond magenta (aucune coupe, aucun
   débris), puis une capture en jeu à côté d'un autre mage pour comparer les
   tailles pour de vrai.

**Si le résultat n'est pas bon**, le plus utile à me dire est *lequel* des trois
défauts revient : personnage trop petit dans sa case, poses qui débordent sur la
case voisine, ou taille qui change d'une case à l'autre. Ce sont les trois seuls
qui coûtent un redécoupage.
