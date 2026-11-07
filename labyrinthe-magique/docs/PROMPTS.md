# Les prompts d'images — index

> Les prompts vivent dans **`docs/prompts/`**, rangés par nature :
> `mages/` (les huit planches de personnage), `sorts/` (les sorts et créatures),
> et les `terrain_*` à la racine du dossier avec leurs références dans `ref/`.
> Seule cette page reste au niveau de `docs/` : c'est la porte d'entrée.

Chaque planche du jeu est **commandée** avec un prompt écrit, puis découpée par
un outil. Les deux vont ensemble : le prompt impose ce que l'outil sait vérifier
(grille régulière, marges, une taille unique, un côté de profil annoncé), et
l'outil refuse en silence tout ce que le prompt n'a pas exigé.

## Aël, l'Enfant sans élément — le héros principal

Quatre formes, de l'Apprenti au Prisme. La planche de concept du joueur (`refonte/ael_concept.png`) est
jointe aux modèles : [mages/heros_ael](prompts/mages/heros_ael.md), puis
[mages_animes/ael](prompts/mages_animes/ael.md). Le plan de jeu : [HEROS_PRINCIPAL](HEROS_PRINCIPAL.md).
Toutes les images qui restent, en une seule commande : [mages/ael_commande_complete](prompts/mages/ael_commande_complete.md).
Sa forme du niveau 80, le Dragon d'or : [mages/ael_dragon](prompts/mages/ael_dragon.md).

## Le Héros d'essai — le gabarit d'animation

Pour régler un mouvement très dynamique sans toucher aux personnages existants. Cinq images,
dont une course et une attaque guidées : [template/heros_test](prompts/template/heros_test.md).

## Mages animés — 8 pas et 8 images d'attaque

`docs/prompts/mages_animes/` : une fiche par mage, deux prompts par fiche, générés
par `tools/build_prompts_mages.py`. Même gabarit que le bestiaire. Déposer les
planches dans `assets/peso&cover/mages/<mage>_{marche,attaque}.png`.

Découpage : `tools/build_enemies.py <mage>`, après l'avoir ajouté à `MAGES` dans cet
outil et à `MAGES_ANIMES` dans `build_characters.py`. **Les huit sont branchés.**

## La marche de profil du Chronomancien, pour tous les mages

Le déplacement horizontal préféré du joueur. Un prompt par mage, à commencer par le Démon du Pacte :
[mages_animes/marche_chronomancien](prompts/mages_animes/marche_chronomancien.md).

## Les créatures neuves — quatre fiches, toutes en jeu

Dans `docs/prompts/ennemis/`, générées par `tools/build_prompts_enemies.py` :
[Rat Chapardeur](prompts/ennemis/rat_chapardeur.md),
[Gelée des Marées](prompts/ennemis/gelee_marees.md),
[Vesse-de-Loup](prompts/ennemis/vesse_de_loup.md),
[Raie des Ruines](prompts/ennemis/raie_ruines.md).
Leurs planches sont dans `assets/peso&cover/creatures/`.

## Le Chronomancien — le neuvième mage

La commande complète, dans l'ordre : [mages/chronomancien](prompts/mages/chronomancien.md).

## Le Mage de la Peste — le dixième mage

La commande complète, dans l'ordre, et le détail de chaque effet visuel :
[mages/mage_peste](prompts/mages/mage_peste.md).

## Le Porte-Lumière — le onzième mage

La commande complète, dans l'ordre, et le détail de chaque effet visuel :
[mages/mage_lumiere](prompts/mages/mage_lumiere.md).

## L'Ange de la Mort — le douzième personnage

La commande complète, dans l'ordre, et le détail de chaque effet visuel :
[mages/mage_mort](prompts/mages/mage_mort.md).

## L'Ange des Étoiles — le treizième personnage

La commande complète, dans l'ordre, et le détail de chaque effet visuel :
[mages/mage_etoiles](prompts/mages/mage_etoiles.md).

## L'Archange d'Acier — le quatorzième personnage

La commande complète, dans l'ordre, et le détail de chaque effet visuel :
[mages/mage_acier](prompts/mages/mage_acier.md).

## L'Archange du Ciel — le vingtième personnage

La fiche et la commande complète, dans l'ordre : [mages/mage_ciel](prompts/mages/mage_ciel.md). Ses coups
passent par-dessus les haies, et sa fuite l'emmène au-dessus des murs.

## Le Démon du Pacte — le quinzième personnage

La fiche et la commande complète, dans l'ordre : [mages/mage_demon](prompts/mages/mage_demon.md).

## La Démone de la Discorde — le seizième personnage

La fiche et la commande complète, dans l'ordre : [mages/mage_discorde](prompts/mages/mage_discorde.md).

## Le Geôlier — le dix-neuvième personnage

La fiche et la commande complète, dans l'ordre : [mages/mage_geolier](prompts/mages/mage_geolier.md). L'apparence
voulue est `prompts/ref/geolier_concept.png`.

## Le Roi de Braise et le Chevalier Écarlate — dix-septième et dix-huitième personnages

La fiche et la commande complète, dans l'ordre : [mages/mage_braise](prompts/mages/mage_braise.md),
[mages/mage_ecarlate](prompts/mages/mage_ecarlate.md).

## Le Dragon des Abysses — le vingt et unième personnage

La fiche et la commande complète, dans l'ordre : [mages/mage_dragon](prompts/mages/mage_dragon.md). Un dragon-démon
debout, pas chibi, qui brûle le terrain. Il est jouable.

## Le Chérubin — le vingt-deuxième personnage

La fiche et la commande complète, dans l'ordre : [mages/mage_cherubin](prompts/mages/mage_cherubin.md). Le gardien
d'Éden de la Bible, à quatre ailes, avec une épée de flamme saphir et une roue d'or à yeux. Il punit ce qui
l'approche, et son extra ferme un cercle où aucun ennemi n'entre. Pas encore jouable : les images sont à commander.

## Le Croupier des Enfers — démon humain

La fiche et la commande complète, dans l'ordre : [mages/mage_croupier](prompts/mages/mage_croupier.md). Un homme
élégant, démon joueur, chibi comme les autres démons humains : cartes, dés, pièce et roulette. Il est jouable.

## L'Avide, Démon de la Faim — démon pur sang

La fiche et la commande complète, dans l'ordre : [mages/mage_avide](prompts/mages/mage_avide.md). Un démon sans rien
d'humain, pas chibi, à la gueule fendant le ventre : plus il dévore, plus il grandit. Il est jouable.

## L'Éveil des mages — le Phénix et l'Esprit des Marées

Chaque mage aura un ÉVEIL : une minute sous une forme transformée, avec ses six sorts changés, puis 10 s
d'épuisement, et une charge de 6 kills avant le suivant. Le Mage du Feu devient le Phénix ; le Mage de l'Eau,
l'Esprit des Marées. Fiches, règles et prompts : [mages/eveil_feu](prompts/mages/eveil_feu.md) et
[mages/eveil_eau](prompts/mages/eveil_eau.md). Leurs visuels et leurs sorts éveillés sont intégrés.

## Les anges — refaire le sprite comme les mages

Ils étaient élancés, à côté de mages chibi, et ils glissaient de profil. Les images 1, 2 et 3 sont à
refaire : [Lumière](prompts/mages/mage_lumiere.md), [Mort](prompts/mages/mage_mort.md),
[Étoiles](prompts/mages/mage_etoiles.md), [Acier](prompts/mages/mage_acier.md). En secours, si un
profil glisse encore : [mages_animes/profil_anges](prompts/mages_animes/profil_anges.md).

## Refonte des huit mages — uniformiser les tailles

La case est commune à tous, mais chacun l'occupe comme il veut : de **60 %**
(Feu) à **93 %** (Invocateur) de sa hauteur. Un mage paraît donc plus petit
qu'un autre sans qu'aucune règle du jeu ne le dise. Les sept prompts ci-dessous
demandent tous **la même chose** — 6 x 4 cases de 256, personnage à 80 % de la
hauteur, pieds près du bas — et c'est cette uniformité qui est le but.

| mage | prompt | remplissage actuel | bâton |
|---|---|---:|:--:|
| Mage du Feu | [mage_feu](prompts/mages/mage_feu.md) | 60 % | — |
| Mage de l'Eau | [mage_eau](prompts/mages/mage_eau.md) | 62 % | oui |
| Mage de la Terre | [mage_terre](prompts/mages/mage_terre.md) | 77 % | oui |
| Mage de la Foudre | [mage_foudre](prompts/mages/mage_foudre.md) | 71 % | oui |
| Mage de l'Air | [mage_air](prompts/mages/mage_air.md) | 70 % | oui |
| Sorcier des Ténèbres | [mage_tenebres](prompts/mages/mage_tenebres.md) | 66 % | — |
| Invocateur | [mage_invocateur](prompts/mages/mage_invocateur.md) | 93 % | oui |
| Sorcier Suprême | [mage_supreme](prompts/mages/mage_supreme.md) | 68 % | — |

### Où déposer les images

**`assets/peso&cover/refonte/`**, sous `feu.png` + `feu_fx.png`, `eau.png` +
`eau_fx.png`, et ainsi de suite — la table complète est dans
`assets/peso&cover/refonte/LISEZ-MOI.md`.

⚠️ **Ne jamais écraser la planche actuelle d'un mage.** Elle ne sert pas qu'au
personnage : `build_spell_fx.py` y découpe son orbe, son impact et sa zone, et
`build_warps.py` sa colonne de téléportation, à des coordonnées relevées à la
main DANS la planche. L'écraser remplacerait les quatre effets par un découpage
au hasard **sans un message d'erreur** — les outils trouveraient un fichier à la
bonne taille et couperaient dedans. Un mage ne bascule que quand ses DEUX
planches sont arrivées.

⚠️ **Les cinq mages à bâton sont les plus risqués.** Mesuré sur les planches
actuelles : les bâtons de la Terre et de la Foudre poussent 61 px hors de leur
case, et c'est ce débordement qui a coûté un `_claim_cell` avec 64 px de marge
dans `build_characters.py`. Les prompts concernés le disent explicitement — le
bâton est tenu à droite dans les quatre orientations et reste dans la case.

## Sorts et créatures

| sujet | prompt |
|---|---|
| la Rune du Sorcier des Ténèbres | [sorts/shadow_rune](prompts/sorts/shadow_rune.md) |
| l'Ombre maléfique de la Faille (+ son souffle) | [sorts/ombre_malefique](prompts/sorts/ombre_malefique.md) |
| le Cyclone du Mage de l'Air | [sorts/air_cyclone](prompts/sorts/air_cyclone.md) |
| les icônes de sorts du Suprême | [sorts/icones_supreme](prompts/sorts/icones_supreme.md) |
| les icônes de sorts du Chronomancien | [sorts/icones_chrono](prompts/sorts/icones_chrono.md) |
| les icônes de sorts du Mage de la Peste | [sorts/icones_peste](prompts/sorts/icones_peste.md) |
| les icônes de sorts du Porte-Lumière | [sorts/icones_lumiere](prompts/sorts/icones_lumiere.md) |
| les icônes de sorts de l'Ange de la Mort | [sorts/icones_mort](prompts/sorts/icones_mort.md) |
| les icônes de sorts de l'Ange des Étoiles | [sorts/icones_etoiles](prompts/sorts/icones_etoiles.md) |
| les icônes de sorts de l'Archange d'Acier | [sorts/icones_acier](prompts/sorts/icones_acier.md) |
| les icônes de sorts du Démon du Pacte | [sorts/icones_demon](prompts/sorts/icones_demon.md) |
| les icônes de sorts de la Démone de la Discorde | [sorts/icones_discorde](prompts/sorts/icones_discorde.md) |
| les icônes de sorts du Roi de Braise | [sorts/icones_braise](prompts/sorts/icones_braise.md) |
| les pièces et la cage du Roi de Braise | [sorts/pieces_braise](prompts/sorts/pieces_braise.md) |
| les icônes de sorts du Chevalier Écarlate | [sorts/icones_ecarlate](prompts/sorts/icones_ecarlate.md) |
| les icônes de sorts du Geôlier | [sorts/icones_geolier](prompts/sorts/icones_geolier.md) |
| les pièces du Geôlier (poing, crochet, maillons) | [sorts/pieces_geolier](prompts/sorts/pieces_geolier.md) |
| les icônes de sorts du Dragon des Abysses | [sorts/icones_dragon](prompts/sorts/icones_dragon.md) |
| les pièces du Dragon des Abysses (magma, écaille, gueule, silhouette) | [sorts/pieces_dragon](prompts/sorts/pieces_dragon.md) |
| les icônes de sorts du Croupier des Enfers | [sorts/icones_croupier](prompts/sorts/icones_croupier.md) |
| les pièces du Croupier (cartes, dé, pièce, jeton, bille) | [sorts/pieces_croupier](prompts/sorts/pieces_croupier.md) |
| la Roulette infernale du Croupier | [sorts/roulette_croupier](prompts/sorts/roulette_croupier.md) |
| les icônes de sorts de l'Avide | [sorts/icones_avide](prompts/sorts/icones_avide.md) |
| les pièces de l'Avide (langue, gouffre, bile, gueule) | [sorts/pieces_avide](prompts/sorts/pieces_avide.md) |
| les terrains de stage | [PROMPT_TERRAIN.md](PROMPT_TERRAIN.md) *(index des 30 pages de `prompts/`)* |

### Les impacts — la frappe au sol

| sujet | prompt | planche à déposer |
|---|---|---|
| l'impact de la Foudre | [sorts/impact_foudre](prompts/sorts/impact_foudre.md) | `impact_thunder.png` |

Le dessin d'impact découpé des planches de personnage est FIXE : le jeu ne peut
que le faire grandir et pâlir. Une frappe demande à se dérouler — le trait
tombe, le sol encaisse, la lumière se retire. La Foudre ouvre la série ; le même
prompt servira aux sept autres en changeant la matière.

### Les huit orbes — le projectile de chaque mage

L'orbe est l'image qui VOYAGE entre le mage et sa cible, pour toute compétence
de forme `PROJECTILE` — l'attaque de base en tête. Sept des huit sont
aujourd'hui une image FIXE que le jeu se contente de faire pivoter ; seule celle
du Feu bat des ailes, en trois images.

Chaque page contient le prompt COMPLET, prêt à copier — rien à assembler.

| mage | prompt | forme voulue | planche à déposer |
|---|---|---|---|
| Mage du Feu | [sorts/orbe_feu](prompts/sorts/orbe_feu.md) | la comète | `orb_fire.png` |
| Mage de l'Eau | [sorts/orbe_eau](prompts/sorts/orbe_eau.md) | la lance | `orb_water.png` |
| Mage de la Terre | [sorts/orbe_terre](prompts/sorts/orbe_terre.md) | le bloc | `orb_earth.png` |
| Mage de la Foudre | [sorts/orbe_foudre](prompts/sorts/orbe_foudre.md) | le dard | `orb_thunder.png` |
| Mage de l'Air | [sorts/orbe_air](prompts/sorts/orbe_air.md) | la lame | `orb_air.png` |
| Sorcier des Ténèbres | [sorts/orbe_tenebres](prompts/sorts/orbe_tenebres.md) | le croc | `orb_shadow.png` |
| Sorcier Suprême | [sorts/orbe_supreme](prompts/sorts/orbe_supreme.md) | la sphère | `orb_supreme.png` |
| Invocateur | [sorts/orbe_invocateur](prompts/sorts/orbe_invocateur.md) | le sceau | `orb_invocateur.png` |

Les planches se déposent dans **`assets/peso&cover/`** (et non dans `refonte/` :
ce sont des effets, pas des personnages — elles n'écrasent donc aucune planche
de mage).

**Les trois règles qui comptent**, présentes dans chaque page parce que ce sont
celles dont l'oubli casse le rendu :

1. **La direction.** Le jeu ORIENTE le sprite le long de sa trajectoire, angle
   zéro vers la droite. Une orbe dessinée de trois quarts, ou pointant vers le
   bas, volera de travers dans la moitié des couloirs.
2. **Le calage.** La pointe reste au même endroit d'une image à l'autre et le
   projectile grandit vers l'ARRIÈRE. Si la position bouge, le tir tressaute en
   vol — le même piège que sur l'éruption de la Terre, où la première image
   large et basse et la quatrième haute et étroite faisaient sauter les gerbes.
3. **La progression, pas la boucle.** Image 1 = la naissance du tir, image 4 =
   sa pleine puissance. `MagicOrb` déroule la bande UNE fois en 0,22 s puis
   tient la dernière image (`"mode": "grow"` dans `orb.json`) ; une bande pensée
   en boucle ferait retomber le projectile à son étincelle de départ en plein
   vol.

## L'interface

| sujet | prompt | planche à déposer |
|---|---|---|
| l'icône de l'application | [interface/icone_app](prompts/interface/icone_app.md) | `interface/icone.png` |
| le cadre et le fond de « Choisis ton mage » | [menu/](prompts/menu/) *(générés par `build_prompts_menu.py`)* | `interface/` |
| la DISPOSITION des six sorts sur la fiche | [menu/disposition_sorts](prompts/menu/disposition_sorts.md) | *maquette, rien à déposer* |

L'icône est le seul dessin du jeu qu'on regarde à **60 pixels** : elle se juge
réduite, jamais à 1024. Le sujet n'est donc pas un personnage mais le PLAN du
labyrinthe avec sa gemme allumée au centre — une forme, pas une scène.

## Interface

| sujet | prompt |
|---|---|
| la couverture de l'écran-titre, en PAYSAGE | [interface/couverture_paysage](prompts/interface/couverture_paysage.md) |
| le portail de téléportation, couleur unique | [interface/portail_teleportation](prompts/interface/portail_teleportation.md) |
| le repaire des ennemis, six poses et quatre couleurs | [decor/repaire_ennemi](prompts/decor/repaire_ennemi.md) |

## Ce que dix planches ont appris

À reprendre dans tout nouveau prompt, chacun ayant coûté un redécoupage :

- **le fond est MAGENTA UNI** (#FF00FF) quand il faut détourer, gris très foncé
  quand la planche est une feuille de sprites : les modèles tiennent mal l'alpha,
  et le magenta n'existe dans aucune palette du jeu ;
- **la grille est régulière et annoncée en pixels** — la détection automatique
  est calibrée sur 70-220 px et rate une case de 256 ; annoncée, elle s'impose ;
- **une marge vide autour de chaque case**, sans quoi les poses voisines se
  chevauchent et le découpage sectionne des bâtons ;
- **la même taille dans toutes les cases** : c'est la CASE qu'on met à l'échelle,
  pas le dessin ;
- **le côté du profil se dit à voix haute.** Ne pas le préciser a fait marcher
  sept créatures à reculons pendant des semaines ;
- **aucune case vide** : une case vide passe sous le radar de l'audit quand la
  phase de la grille se décale ;
- **une planche d'appoint n'est jamais à la même échelle** que la première —
  22 % d'écart mesuré sur l'Ombre. Toujours joindre la planche existante en
  référence et la faire passer par le même outil.
