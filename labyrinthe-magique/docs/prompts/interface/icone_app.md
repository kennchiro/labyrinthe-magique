# icone_app — l'icône de l'application

## Pourquoi on la refait

L'icône actuelle est **composée à partir des assets du jeu** par
`build_app_icon()` (`tools/build_assets.py`) : la planche de haies floutée en
fond, le sprite `player.png` agrandi, une gemme posée à côté. Trois défauts qui
ne se corrigent pas au réglage :

| | |
|---|---|
| **flou** | `player.png` fait ~64 px et occupe 66 % d'une image de 1024. Aucun rééchantillonnage ne rend un détail qui n'a jamais été dessiné |
| **hors palette** | vert-brun, alors que toute l'identité — `couverture.png`, l'écran de sélection, les cadres — est bleu nuit et or |
| **muet à 60 px** | c'est la taille réelle sur un écran d'accueil. Le mage n'y est plus qu'une tache, et rien ne dit ni « labyrinthe » ni « éléments » |

Le sujet ne peut donc **pas** être un personnage : à 60 px un chibi de trois
cases n'a plus de visage. Ce qui se lit à cette taille, c'est une FORME —
et la forme de ce jeu est le plan du labyrinthe, avec au centre la gemme qui en
est l'objectif (« la maison est une serrure, pas une ligne d'arrivée » : c'est la
gemme qu'on ramasse, pas la porte qu'on franchit).

---

## Le prompt

> Copier-coller tel quel. **Joins `couverture.png`** (`assets/peso&cover/interface/`)
> et dis « la même palette et la même facture que cette image ».

```
Icône d'application pour un jeu de rôle mobile, style cartoon coloré à contours
nets rehaussé d'or, même palette et même facture que l'image de référence jointe.

FORMAT : une seule image CARRÉE de 1024 x 1024 pixels, entièrement OPAQUE,
remplie jusqu'aux quatre bords. Pas de transparence, pas de coins arrondis, pas
de cadre blanc, pas d'ombre portée hors de l'image : le système d'exploitation
applique lui-même son masque arrondi.

SUJET : le PLAN D'UN LABYRINTHE DE PIERRE vu de DESSUS, à la verticale, en
légère plongée. Un carré de couloirs et de murs, dessiné en gros traits : sept à
neuf couloirs de large au maximum, jamais plus. Les murs sont des blocs de
pierre gris-bleu couverts de mousse sombre, éclairés par le haut ; les couloirs
sont plus clairs, dallés.

AU CENTRE EXACT, dans une petite place ouverte, une GRANDE GEMME DE CRISTAL
BLEU-CYAN taillée à facettes, dressée et LUMINEUSE : elle éclaire les murs
autour d'elle, projette un halo cyan et quelques éclats d'étincelles. C'est le
point le plus clair de toute l'image, et de loin.

DANS LES COULOIRS, six petites lueurs élémentaires posées autour du centre, une
par direction, chacune d'une couleur franche : orange de feu, bleu d'eau, vert
de terre, violet d'ombre, jaune d'éclair, blanc d'air. Ce sont des points de
lumière avec leur reflet au sol, PAS des personnages, PAS des objets détaillés.

BORDURE : les quatre bords de l'image sont ASSOMBRIS en vignette bleu nuit très
sombre (#0a1428), pour que le labyrinthe se détache. Un fin liseré d'or peut
courir sur le mur extérieur du labyrinthe, rien de plus.

PALETTE : bleu nuit profond (#0b1730), pierre gris-bleu (#4a5b78), or chaud
(#e8b44a) pour les rehauts, cyan lumineux (#7fd8ff) pour la gemme et son halo.

RÈGLES ABSOLUES :
- AUCUN TEXTE, aucune lettre, aucun chiffre, aucun logo, aucune signature. Le
  nom du jeu s'affiche déjà SOUS l'icône sur l'écran d'accueil
- AUCUN PERSONNAGE, aucun mage, aucune créature, aucune main
- le labyrinthe est CENTRÉ et occupe environ 75 % de la largeur : il reste une
  marge vide d'un huitième de l'image sur les quatre côtés, parce que le masque
  arrondi du téléphone mange les angles
- GROSSES FORMES, peu de détails : l'image sera regardée à 60 pixels de côté.
  Pas de petites pierres, pas de lierre fin, pas de texture bruitée, pas de
  trame de dalles serrée
- contraste FRANC entre les murs et les couloirs : c'est lui, et lui seul, qui
  fait qu'on reconnaît un labyrinthe une fois l'image réduite
- vue de DESSUS à la verticale, jamais en perspective à hauteur d'œil : une
  perspective écrase le plan et le labyrinthe redevient un tas de murs
```

---

## Où déposer l'image, et ensuite

Résultat attendu : **`assets/peso&cover/interface/icone.png`**.

```bash
tools/.venv/bin/python tools/build_assets.py   # aplatit, met à 1024, écrit assets/icon.png
godot --headless --path . --import
```

`build_app_icon()` lit cette planche **en priorité** et ne retombe sur l'ancienne
composition que si le fichier n'existe pas. L'outil se charge de trois choses que
le modèle rate régulièrement : il **aplatit l'alpha** sur le bleu nuit (iOS refuse
un canal alpha sur l'icône de l'App Store, et l'export échoue tard, au moment de
la soumission), il recadre au carré, et il ramène à 1024.

⚠️ Ne PAS écrire directement dans `assets/icon.png` : ce fichier est GÉNÉRÉ, et
le prochain passage de `build_assets.py` l'écraserait **sans un message**.

---

## Vérifier avant d'accepter

Le seul test qui compte est la réduction. Une icône se juge à 60 px, pas à 1024 :

```bash
tools/.venv/bin/python -c "
from PIL import Image
im = Image.open('assets/icon.png')
print(im.size, im.mode)          # (1024, 1024) RGB — pas RGBA
im.resize((60, 60), Image.LANCZOS).resize((240, 240), Image.NEAREST).save('/tmp/icone_60.png')
"
```

À 60 px on doit encore distinguer **le carré du labyrinthe** et **le point clair
au centre**. Si les deux ont fondu en une tache, c'est que les couloirs sont trop
étroits ou le contraste trop faible — c'est le défaut le plus fréquent, et il ne
se voit jamais sur la grande image.

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le labyrinthe a vingt couloirs de large | « sept à neuf couloirs AU MAXIMUM, gros traits » — c'est le défaut n° 1, le modèle dessine toujours trop fin |
| Vue en perspective, murs vus de côté | rappeler « vu de DESSUS À LA VERTICALE, comme un plan » |
| Un mage, une main ou un dragon apparaît | rappeler « AUCUN PERSONNAGE » ; le mot « jeu de rôle » en appelle un tout seul |
| Du texte est écrit dessus | relancer en insistant : « AUCUN TEXTE, aucune lettre » |
| La gemme ne se voit plus une fois réduit | demander la gemme « deux fois plus grande, et le SEUL point clair de l'image » |
| Fond transparent | l'outil l'aplatit, mais vérifier que le modèle n'a pas dessiné une ombre portée hors du carré |
| L'image déborde jusqu'aux angles | rappeler la marge « d'un huitième sur les quatre côtés » : le masque arrondi coupe les angles |

---

## Variante, si le plan de labyrinthe ne prend pas

Second sujet possible, à ne tenter que si trois relances du premier échouent :
**la gemme de cristal seule**, dressée sur un socle de pierre, six petites
flammes élémentaires en couronne autour d'elle, même fond bleu nuit. Ça se lit
encore mieux à 60 px — mais ça ne dit plus « labyrinthe », et le titre du jeu
commence par ce mot. C'est un repli, pas un choix.
