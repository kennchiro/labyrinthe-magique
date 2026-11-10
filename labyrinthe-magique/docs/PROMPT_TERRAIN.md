# Le terrain des dix stages — index des prompts

⚠️ Les trente fichiers de `docs/prompts/` sont **GÉNÉRÉS** par
`tools/build_prompts.py`. Ne pas les éditer à la main.

Trois planches par stage, à demander une par une, chacune avec son image de
référence en pièce jointe. Dépose les résultats dans
**`assets/peso&cover/terrain/`** sous les noms indiqués dans chaque fichier.

| # | Stage | Le mur, c'est | Prompts |
|---|---|---|---|
| 1 | La Forêt | haie de buis taillée | [sol](prompts/terrain_1_sol.md) · [mur](prompts/terrain_1_mur.md) · [decor](prompts/terrain_1_decor.md) |
| 2 | Le Canyon de la Foudre | roche violette empilée | [sol](prompts/terrain_2_sol.md) · [mur](prompts/terrain_2_mur.md) · [decor](prompts/terrain_2_decor.md) |
| 3 | Les Dunes de Feu | BLOCS DE GRÈS taillés et empilés | [sol](prompts/terrain_3_sol.md) · [mur](prompts/terrain_3_mur.md) · [decor](prompts/terrain_3_decor.md) |
| 4 | Les Rivages Océaniques | GALETS RONDS beiges et roses assemblés | [sol](prompts/terrain_4_sol.md) · [mur](prompts/terrain_4_mur.md) · [decor](prompts/terrain_4_decor.md) |
| 5 | Les Cavernes de Cristal | roche violette sur lequel sont plantés de GROS CRISTAUX bleus et roses lumineux | [sol](prompts/terrain_5_sol.md) · [mur](prompts/terrain_5_mur.md) · [decor](prompts/terrain_5_decor.md) |
| 6 | Les Montagnes Glacées | BLOCS DE GLACE et de neige tassée | [sol](prompts/terrain_6_sol.md) · [mur](prompts/terrain_6_mur.md) · [decor](prompts/terrain_6_decor.md) |
| 7 | Le Bois d'Épine | pierre entièrement mangé par un LIERRE ÉPINEUX vert olive | [sol](prompts/terrain_7_sol.md) · [mur](prompts/terrain_7_mur.md) · [decor](prompts/terrain_7_decor.md) |
| 8 | Les Ruines Anciennes | BLOCS DE PIERRE CLAIRE fissurés | [sol](prompts/terrain_8_sol.md) · [mur](prompts/terrain_8_mur.md) · [decor](prompts/terrain_8_decor.md) |
| 9 | Le Sanctuaire Déchu | BLOCS DE PIERRE VERT-DE-GRIS fissurée | [sol](prompts/terrain_9_sol.md) · [mur](prompts/terrain_9_mur.md) · [decor](prompts/terrain_9_decor.md) |
| 10 | Le Château du Ciel | MARBRE BLANC à bordure dorée | [sol](prompts/terrain_10_sol.md) · [mur](prompts/terrain_10_mur.md) · [decor](prompts/terrain_10_decor.md) |

## Arène

Le [mur de l’arène](prompts/arene_mur.md) reprend les mêmes seize raccords,
en pierre de colisée. Résultat : `assets/peso&cover/terrain/arene_mur.png`.

## Pourquoi les prompts n'imposent PAS lequel est le plus clair

Le jeu impose 52 de luminance d'écart entre sol et mur (`MIN_CONTRAST`) : c'est
ce qui fait qu'on LIT le chemin. Mais le SENS de cet écart n'est écrit nulle
part dans les prompts, et c'est délibéré.

Deux façons de le mesurer sur ces planches ont été essayées, et elles se
contredisent sur les dix : les regrouper en deux familles de couleurs suit les
REFLETS — veines d'éclair du Canyon, fleurs des haies — et rend le mur
systématiquement plus clair ; prendre « ce qui est le plus loin de la couleur du
sol » suit les CONTOURS NOIRS et rend le mur systématiquement plus sombre.
Inscrire dans vingt fichiers une direction qu'on ne sait pas mesurer serait pire
que de ne rien écrire.

Les prompts demandent donc un **écart franc sans en imposer le sens** —
l'image de référence jointe porte déjà le rapport réel bien mieux qu'une phrase.
Je mesure ensuite sur la planche LIVRÉE, et `MIN_CONTRAST` écarte les deux
valeurs dans le sens que le dessin a choisi, sans jamais l'inverser.

---

## Ce qu'on demande, et pourquoi ce n'est pas la même chose selon la planche

**Le SOL est une MATIÈRE.** On ne demande jamais un tileset : les modèles
d'image ne savent pas faire une tuile raccordable — ils rendent une jolie image
carrée dont les bords ne se rejoignent pas, et répétée elle affiche une grille de
coutures. On a d'ailleurs déjà échoué à découper des tuiles dans ces planches, et
le constat est dans `build_stage_tiles.py` : le plus grand carré inscriptible
dans un mur d'une case fait quelques pixels. Donc on demande une grande plaque
uniforme, et **le raccord, c'est moi qui le fabrique** — décalage torique et
fondu sur la couture. Ne demande jamais « seamless » : le modèle dessinera un
cadre pour faire semblant.

**Le MUR est un JEU DE 16 PIÈCES.** Parce que les planches en contiennent déjà
l'essentiel, et que c'est ça qui fait « un vrai labyrinthe » : une matière ne
peut produire ni un bout arrondi ni un angle. La contrainte de raccord y est
faible et vérifiable à l'œil — même largeur de tronçon, toujours centré, et qui
remplit le bord de case qu'il touche.

**Le DÉCOR est un semis d'objets isolés**, sur magenta comme les icônes de sorts.
Les deux derniers de chaque planche sont toujours les objets LUMINEUX : ils
partent dans la liste `GLOWING` de `DecorLayer`, qui leur accroche une lumière.

---

## Ce que je fais quand les planches arrivent

1. **Raccord fabriqué, pas demandé** — décalage torique d'une demi-image, fondu
   sur la couture, réduction. Une plaque uniforme y survit sans qu'on voie rien :
   c'est pour ça que les prompts insistent sur « éclairage plat » et « aucun
   élément dominant ».
2. **Période portée de 3 à 6 cases** — planches de 192 x 192 au lieu de 96, et
   `MazeRenderer` lira la période dans la LARGEUR de la texture au lieu de la
   coder en dur.
3. **L'autotile dans le moteur** — `_draw_hedge` calculera le masque des 4
   voisins et prendra la pièce correspondante dans la planche 4 x 4. Les blocs
   2 x 2 se résolvent en quatre coins, dont l'union donne un carré arrondi.
4. **Le contraste est vérifié et forcé** — `MIN_CONTRAST` impose 52 de luminance
   d'écart, dans le sens que le décor a choisi ; l'outil ne l'inverse jamais.
5. **Contrôle à l'image** : `--stage N --overview` avant / après, et un aplat de
   8 x 4 cases pour traquer les coutures.

Un stage peut avancer seul : rien n'oblige à fournir les trente planches d'un
coup, et les stages sans planche gardent leur terrain teinté actuel.
