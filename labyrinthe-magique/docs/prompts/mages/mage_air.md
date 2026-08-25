# Regénérer la planche du Mage de l'Air — prompt à donner à ChatGPT

> Fiche : **4 PV, repousse et ralentit · il gagne les combats qu'il refuse de livrer** · élément **Air** · teinte du jeu `#cfe9ff`

## Pourquoi

Les huit mages ont été dessinés séparément, et ça se voit. La case est commune à
tous — c'est elle que le moteur met à l'échelle — mais chacun l'occupe comme il
veut :

| mage | remplissage | | mage | remplissage |
|---|---:|---|---|---:|
| Invocateur | 93 % | | Ténèbres | 66 % |
| Terre | 77 % | | Eau | 62 % |
| Foudre | 71 % | | **Feu** | **60 %** |
| Air | 70 % | | Suprême | 68 % |

*(part de la hauteur de la case commune — 192 x 112 — réellement occupée par le
dessin, mesurée sur la pose de repos de chaque planche.)*

D'un mage à l'autre, l'écart va donc **du simple au tiers en plus** : le Feu
paraît petit et l'Invocateur énorme, sans qu'aucune règle du jeu ne le dise.
C'est un accident de dessin, pas un choix.

La refonte vise **une seule chose** : que les huit remplissent leur case de la
même façon (≈ 80 % de la hauteur, pieds près du bas). Le reste — mise à
l'échelle commune, calage sur les pieds, case symétrique — est déjà fait par
l'outil ; il ne peut simplement pas rattraper un personnage dessiné petit dans
sa case.

Trois défauts à éviter, dans l'ordre où ils coûtent cher :
1. **le personnage flotte au milieu d'une grande case** — il paraîtra minuscule ;
2. **une pose déborde sur la case voisine** — l'outil devra l'amputer ou la
   rendre à sa voisine ;
3. **la taille change d'une case à l'autre** — le mage enfle et rétrécit en
   marchant.

---

## Prompt 1 — la planche de mouvements (l'essentiel)

> Copier-coller tel quel. La version anglaise en dessous marche souvent mieux
> avec les générateurs d'images ; les deux disent la même chose.

```
Feuille de sprites pour un jeu 2D vu de dessus, style pixel-art cartoon coloré,
même facture que des sprites de RPG mobile.

PERSONNAGE : Mage de l'Air. Robe blanche et bleu très pâle, longues écharpes qui flottent derrière lui, capuche souple. Il tient un BÂTON MAGIQUE fin de la main droite : une hampe claire surmontée d'un ANNEAU OUVERT dans lequel le vent siffle. Corps COMPACT, tête
un peu large, silhouette lisible en très petit. L'aura et les effets restent
COLLÉS au corps : pas de halo large, pas de nuage de particules autour.

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
- colonne 6 : pose d'ATTAQUE — bâton décrivant un arc devant lui, une lame de vent qui part de l'anneau

RÈGLES IMPORTANTES :
- le personnage occupe environ 80 % de la hauteur de sa case, PIEDS près du bas
- exactement la MÊME taille, les mêmes couleurs et le même style dans les 24
  cases ; seule la pose change
- chaque personnage reste ENTIÈREMENT dans sa case : rien ne dépasse sur la case
  voisine, ni cape, ni écharpe, ni bâton, ni lueur
- une marge vide d'au moins 10 pixels tout autour de chaque case
- de PROFIL, il regarde vraiment du côté demandé : son visage, sa main d'attaque
  et sa pointe de pied vont du même côté, et ce qui traîne (cape, écharpe,
  poussière) reste DERRIÈRE lui
- son BÂTON est tenu de la main droite dans les quatre orientations, et il
  reste À L'INTÉRIEUR de la case : ni la hampe ni l'anneau ouvert ne dépassent
```

<details>
<summary>Version anglaise</summary>

```
Top-down 2D game sprite sheet, colorful cartoon pixel-art style, mobile RPG look.

CHARACTER: Mage de l'Air. White and very pale blue robe, long scarves streaming behind him, soft hood. He holds a slender MAGIC STAFF in his right hand: a pale shaft topped by an OPEN RING through which the wind whistles. COMPACT body,
slightly large head, silhouette readable at very small size. Aura and effects stay
TIGHT to the body: no wide halo, no particle cloud around him.

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
- column 6: ATTACK pose — staff sweeping an arc in front of him, a wind blade leaving the ring

IMPORTANT RULES:
- the character fills about 80% of the cell height, FEET near the bottom
- exactly the SAME size, colors and style in all 24 cells; only the pose changes
- each character stays ENTIRELY inside its cell: nothing crosses into the
  neighbouring cell, no cape, no scarf, no staff, no glow
- at least 10 pixels of empty margin around each cell
- in the side views he really faces the requested side: face, attacking hand and
  toes all point the same way, and whatever trails (cape, scarf, dust) stays
  BEHIND him
- his STAFF is held in the right hand in all four facings and stays INSIDE
  the cell: neither shaft nor tip may cross the cell edge
```
</details>

---

## Prompt 2 — la planche d'effets (ses sorts)

Le jeu découpe aussi quatre effets dessinés par mage. Demander une **seconde
image**, séparée : mélangée à la première, elle brouille la détection de grille.

```
Feuille d'effets magiques pour un jeu 2D, même style que la feuille du
Mage de l'Air, fond UNI gris très foncé, aucun texte.

Image de 1024 x 1024 pixels, grille RÉGULIÈRE de 2 colonnes x 2 rangées
(4 cases de 512 x 512), un effet par case, centré, sans rien qui dépasse :

- case 1 : un PROJECTILE — une lame de vent en croissant qui file vers la DROITE, translucide, bord bleu pâle
- case 2 : un IMPACT — un souffle circulaire, anneaux d'air qui s'écartent
- case 3 : une ZONE au sol — un tourbillon vu de DESSUS, spirale de poussière claire
- case 4 : une TÉLÉPORTATION — une colonne de vent verticale, spiralée, presque transparente
```

---

## Ce que je fais quand les images arrivent

Déposer les deux images dans **`assets/peso&cover/refonte/`** sous ces noms :

    refonte/air.png       la planche de mouvements
    refonte/air_fx.png    la planche d'effets

⚠️ **Ne pas écraser la planche actuelle du mage.** Elle ne sert pas qu'au
personnage : `build_spell_fx.py` y découpe son orbe, son impact et sa zone, et
`build_warps.py` sa colonne de téléportation — à des coordonnées relevées à la
main DANS la planche. L'écraser remplacerait le mage et ses quatre effets par un
découpage au hasard, sans le moindre message d'erreur. Le mage ne bascule que
quand ses DEUX planches sont là. Voir `assets/peso&cover/refonte/LISEZ-MOI.md`.

Ensuite je m'occupe du reste :

1. `tools/build_characters.py` — la grille de 256 px sort de la fenêtre de
   détection automatique (calibrée sur 70-220 px) : je l'**imposerai** dans la
   table `SHEETS` avec `"grid": (256, 256, 0, 0)`. C'est pour ça que le prompt
   exige une grille régulière et des marges — c'est vérifiable et imposable ;
2. `tools/build_spell_fx.py` — quatre boîtes relevées à la main sur la feuille
   d'effets, comme pour les mages déjà faits ;
3. contrôle à la MESURE et non à l'œil : hauteur du personnage dans chaque case,
   position des pieds, débordements, puis `tools/check_profiles.py` qui vérifie
   que les vues de gauche regardent bien à gauche.

**Si le résultat n'est pas bon**, le plus utile à me dire est *lequel* des trois
défauts revient : personnage trop petit dans sa case, poses qui débordent sur la
case voisine, ou taille qui change d'une case à l'autre. Ce sont les trois seuls
qui coûtent un redécoupage.
