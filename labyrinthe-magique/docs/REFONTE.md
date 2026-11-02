# Refonte action / RPG — plan et avancement

> Document de suivi. Une case cochée = **fait et vérifié** (capture ou test à l'appui).
> Dernière mise à jour : 2026-08-23.

---

## 0. Analyse de l'existant

Ce qui existe déjà et qu'il ne faut **pas** réécrire :

| Domaine | Fichiers | État |
|---|---|---|
| Labyrinthe | `src/maze/maze_grid.gd`, `maze_generator.gd` (8 passes), `pathfinder.gd` (BFS), `maze_renderer.gd`, `decor_layer.gd` | Solide, testé sur 200 labyrinthes/stage |
| Déplacement | `src/entities/grid_mover.gd` | Verrouillé sur la grille, prouvé sans traversée de mur jusqu'à 2 fps |
| Acteurs | `actor.gd` (base + ombre), `player.gd` (animation par frames), `enemy.gd` + `enemy_ai.gd` (3 états) | Le mage a déjà une vraie planche animée |
| Portails | `src/portals/` — `portal_network.gd` (règle 20/80), `teleport_system.gd` | Mesuré, 17 % de vrai gain |
| Sort | `src/spells/spell_system.gd`, `magic_orb.gd` | Charges, visée, temps de vol, 10 s hors-jeu |
| Objectif | gemmes + potions dans `maze_generator.gd`, `level.gd` | Porte scellée tant qu'il manque une gemme |
| Orchestration | `src/core/game_manager.gd`, `level.gd`, `level_config.gd`, `dev_tools.gd` | Machine à états propre |
| Interface | `src/ui/` — `ui_manager.gd` (façade), `hud.gd`, `result_screen.gd`, `touch_dpad.gd`, `compass.gd` | Tactile calibré pour iPhone |
| Tests | `tests/` — 6 suites headless | maze, portals, grid_mover, spell, victory, balance |
| Assets | `tools/build_assets.py` | Pipeline reproductible (gemmes, potion, orbe, icône, planche du mage) |

**Ce qui manque pour une expérience action/RPG :** aucun écran d'accueil (le jeu démarre
directement dans le labyrinthe), un seul personnage, pas de PV côté ennemis (ils sont
« bannis 10 s » puis reviennent), pas de compteur de kills, pas de compétences, pas de
boutons de combat.

---

## 1. Tensions de design à trancher AVANT d'implémenter

Ces trois points changent le jeu en profondeur ; ils ne sont pas déductibles du code.

### 1.1 Que devient le sort actuel ? — **TRANCHÉ**
L'orbe devient l'**attaque principale du Mage Arcane** et inflige des dégâts au lieu de
bannir. La potion devient une recharge de **mana**, commune à toutes les compétences de
tous les personnages. `SpellSystem` évolue en `AbilitySystem` : on garde sa visée, son
temps de vol et sa trajectoire (déjà testés), on remplace « bannir 10 s » par « infliger
des dégâts ».

### 1.2 Les ennemis meurent — le labyrinthe se vide-t-il ? — **TRANCHÉ**
**TRANCHÉ : par vagues.** Un ennemi mort réapparaît loin du joueur après un délai, mais
le kill est **compté définitivement**. La poursuite ne retombe jamais et le compteur
d'ultime progresse. C'est aussi ce qui sauve le cœur du jeu : un labyrinthe vidé de ses
poursuivants redevient une promenade.

### 1.3 Kills vs gemmes — **TRANCHÉ**
La victoire reste la **collecte des gemmes**. Les kills ne servent qu'à débloquer
l'Extra Power. Le combat est un moyen, pas l'objectif — sinon le labyrinthe devient un
décor.

---

## 2. Fichiers à créer / modifier

### Nouveaux systèmes (aucune dépendance au moteur de scène → testables headless)

```
src/characters/character_stats.gd      Resource : hp, dégâts, vitesses, cooldowns, kills requis
src/characters/character_catalog.gd    Les 5 fabriques statiques (comme LevelConfig)
src/characters/ability.gd              Resource : id, nom, cooldown, portée, dégâts, élément
src/combat/health.gd                   PV, dégâts, mort, signaux — ennemis ET joueur
src/combat/damage.gd                   Montant + élément + source
src/combat/combat_system.gd            Résolution des attaques, cooldowns
src/combat/ability_system.gd           Absorbe SpellSystem : charges, ciblage, projectiles
src/combat/kill_system.gd              Compteur, seuil d'ultime, signaux
src/core/enemy_config.gd               Types d'ennemis : PV, dégâts, vitesse, sprite
```

### Rendu et animation

```
src/anim/animation_set.gd              Descripteur lu depuis <perso>_frames.json
src/anim/sprite_animator.gd            Machine idle/walk/attack/hurt/death + direction
src/fx/effect_system.gd                Spawn d'effets par élément
src/fx/element_effect.gd (+ scène)     Effet générique piloté par descripteur
src/combat/projectile.gd (+ scène)     Généralise magic_orb.gd (élément, dégâts)
src/entities/health_bar.gd (+ scène)   Barre flottante au-dessus de l'ennemi
```

### Écrans et interface

```
scenes/menu/title_screen.tscn          + src/ui/title_screen.gd
scenes/menu/character_select.tscn      + src/ui/character_select.gd
src/core/game_flow.gd                  Routeur titre → sélection → jeu, garde le choix
src/ui/combat_pad.gd (+ scène)         HIT / SKILL 1-3 / EXTRA HIT, cooldowns, états
```

### Fichiers existants à modifier (sans les réécrire)

```
src/entities/player.gd      → SpriteAnimator + CharacterStats au lieu du code en dur
src/entities/actor.gd       → accueille SpriteAnimator pour les ennemis aussi
src/entities/enemy.gd       → Health, animations hurt/death, barre de vie
src/core/level.gd           → branche combat, projectiles, effets, respawn par vagues
src/core/game_manager.gd    → reçoit le personnage choisi, kills, ultime
src/core/level_config.gd    → types et PV d'ennemis, kills requis
src/ui/hud.gd               → PV joueur, kills, icônes de compétences
scenes/main.tscn            → passe sous le routeur GameFlow
tools/build_assets.py       → build_character_sheet() pour le format « grille étiquetée »
```

### Tests

```
tests/test_combat.gd        ✅ 12 vérifications, toutes vertes
tests/test_balance.gd       ✅ réécrit avec le combat
docs/attic/                 ancien SpellSystem + son test, remplacés par CombatSystem
tests/test_characters.gd    NOUVEAU : 5 personnages, stats cohérentes, animations présentes
tests/test_balance.gd       À REPRENDRE : le combat change tout l'équilibrage
```

---

## 3. Format des planches de personnages

La planche du Mage Arcane (`ChatGPT Image 23 août 2026, 11_52_24.png`, 1536×1024) est
**directement exploitable** : son fond violet est transparent (54 % de l'image), seuls
les personnages, les étiquettes et les panneaux d'effets sont opaques.

Structure détectée :

| | IDLE | WALK 1 | WALK 2 | WALK 3 | WALK 4 | ATTACK / CAST (×2) |
|---|---|---|---|---|---|---|
| **DOWN** (face) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ ✓ |
| **UP** (dos) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ ✓ |
| **LEFT** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ ✓ |
| **RIGHT** | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ ✓ |

Panneaux à droite : `ATTACK EFFECTS`, `IDLE EFFECTS`, `HURT`, `DEATH / VANISH`,
`PARTICULES & FX`. Rangée du bas : portrait + poses de présentation.

Sortie attendue du pipeline, par personnage :

```
assets/characters/<id>/
  walk_down.png  walk_up.png  walk_left.png  walk_right.png
  idle_down.png  idle_up.png  idle_left.png  idle_right.png
  attack_down.png  attack_up.png  attack_left.png  attack_right.png
  hurt.png  death.png  portrait.png
  fx_attack.png  fx_idle.png  fx_particles.png
  <id>_frames.json      (taille de case, pieds, nombre de poses par animation)
```

**Attention** : les étiquettes (`DOWN`, `WALK 1`, …) sont opaques elles aussi. Le
découpage doit les exclure explicitement, sinon elles deviennent des « poses ».

---

## 3bis. Deuxième vague (demandée le 2026-08-23 au soir)

- [x] **Sorts acquis DÉFINITIVEMENT** — une potion débloque un sort, sauvegardé
      sur le disque. Le **mana disparaît** : la recharge est la seule limite.
      0 potion au stage 1, 1 au stage 2, 2 au stage 3 → les trois sorts sont
      acquis au terme de la campagne, et le restent.
- [x] **Sort de FUITE pour les sept mages**, coloré par élément (Braise fuyante,
      Courant, Terrier, Pas de l'ombre, Éclair fuyant, Rafale, Glissement).
      Il ne se débloque pas : un jeu de poursuite doit toujours offrir une porte
      de sortie, sinon un couloir bouché est une impasse et non une erreur.
      Barre d'action à **six emplacements** ; touche **F**, gâchette **L1**.
- [x] **Portail** : `tools/build_portals.py` découpe les **8 couleurs × 6 poses**
      (idle, ouverture, ouvert, actif, téléportation, fermeture) vers
      `assets/portals/`. Le portail raconte son état sans un mot d'interface :
      fermé au repos, il s'ouvre à l'approche, bat entre ouvert et actif quand
      il est prêt, lance sa colonne de lumière au saut, se referme derrière.
      **Une couleur par portail** — dans un labyrinthe où l'on revient sur ses
      pas, « le portail vert » est un repère mémorisable, huit portails
      identiques ne s'ancrent pas.

      Note d'outillage : ici la grille est **écrite à la main**, contrairement aux
      planches de mages. Chaque portail est une lueur qui déborde de sa case et
      l'opacité ne retombe jamais à zéro entre deux colonnes — la détection
      automatique ne voyait qu'un seul bloc de 1536×1024.
- [x] **Maisons d'ennemis** : `tools/build_lairs.py` découpe les 4 couleurs × 6
      poses vers `assets/lairs/`. Placées sur la case praticable la plus proche
      de **haut-gauche et bas-droite** ; les ennemis en SORTENT au lieu
      d'apparaître au hasard. La maison s'ouvre **1,1 s avant** de lâcher sa
      créature : c'est l'avertissement qui laisse au joueur le temps de
      s'écarter du coin. Le repaire choisi est le plus ÉLOIGNÉ du mage — le
      renvoyer dans la maison où l'on se tient serait une exécution.
- [x] **Détruire la maison** pour passer le stage — au **dernier épisode des
      stages 3 et 9** (`LevelConfig.must_destroy_lairs`). Les repaires
      deviennent alors des cibles de combat à part entière, dans les MÊMES
      tableaux que les ennemis (`CombatContext.structures_from`) : projectiles,
      portée et zone marchent sur eux sans une ligne en double. Une seule règle
      les distingue — un ennemi à portée passe **toujours** avant une maison.
      Les deux abattues, plus aucune vague ne revient : c'est tout le prix de
      l'avoir fait.
- [x] **2 épisodes par stage** — `LevelConfig.for_stage(stage, épisode)`,
      **10 stages × 2 = 20 niveaux**. Le second épisode ne rejoue pas le premier
      en plus grand (le labyrinthe est déjà neuf à chaque partie) : il resserre.
      Un poursuivant de plus, une gemme de plus, un retour plus rapide.
- [x] **Sélection de stage** au menu — `src/ui/stage_select.gd`, dix cartes
      illustrées, cinq par rangée. Le deuxième bouton de la couverture
      (« COMMENCER », boussole) y mène ; il doublait jusqu'ici le choix du mage.
      Les stages fermés restent **visibles mais éteints** : les masquer donnerait
      un menu qui change de forme à chaque victoire, les montrer éteints dessine
      la route qui reste. Règles dans `Progress` (donc testables, pas dans l'UI) :
      tous les stages bouclés **plus le suivant** ; le second épisode demande que
      le premier ait été gagné.
- [x] **Décors de stage** : `tools/build_stage_art.py` découpe l'illustration
      encadrée de chaque planche vers `assets/stages/thumbs/`. Une seule boîte
      normalisée cadre huit planches sur neuf (deux exceptions notées dans
      l'outil). Les cartes sont **recadrées au centre**, jamais étirées : le
      sujet de ces illustrations est toujours au milieu.
- [x] **Terrain par stage** : `tools/build_stage_tiles.py`. Chaque stage a son
      sol et ses murs, dans `assets/tiles/stage_<N>/` ; `MazeRenderer.set_stage()`
      les charge, et retombe sur la forêt pour un stage sans décor (le 9).
- [x] **Bestiaire cumulatif** : `tools/build_bestiary.py` découpe les **neuf
      planches restantes** (le gobelin et le spectre appartiennent au pipeline
      voisin, on n'y touche pas). Onze créatures au total, distribuées par
      `src/entities/bestiary.gd` : le stage N ajoute UNE espèce et garde toutes
      les précédentes. C'est ce qui fait sentir la progression — non pas
      « d'autres ennemis » mais « les mêmes, plus quelque chose de neuf ».

      Les statistiques sont des RAPPORTS au spectre, qui reste l'unité de
      mesure : le gobelin à 1,37 redonne exactement les 185 PV mesurés au
      stage 2. Le passage d'une constante par espèce à un rapport n'a donc rien
      changé aux stages déjà réglés à la main.

      Les compétences sont **devinées du dessin**, faute d'une fiche : le golem
      encaisse et traîne (1,90 PV / 0,80 vitesse), le serpent file et casse
      (0,82 / 1,16), le minotaure charge (1,60 / 1,10). C'est la lecture qu'un
      joueur fera de la silhouette.
- [ ] **Boss** (`boss.png`) : découpé par aucun outil pour l'instant. Il attend
      un type d'ennemi « unique » que le jeu ne sait pas encore poser.

## 4. Phases

**Ordre retenu** : les phases logiques d'abord (4, 5, 7, 8, 9, 10, 6, 11), qui ne
dépendent d'aucune planche. Les écrans (1, 2) et le pipeline de planches (3) attendent
les fichiers manquants.

- [x] **Phase 0 — Assets** : TROUVÉS dans `assets/peso&cover/` (voir § 6)
- [x] **Phase 1 — Écran d'accueil** : la VRAIE couverture, avec des zones tactiles
      posées sur ses trois boutons peints
- [x] **Phase 2 — Sélection des personnages** : **7 vignettes avec leur vrai
      sprite**, aura élémentaire, fiche complète (élément, étoiles, description,
      stats, 5 compétences)
- [x] **Phase 3 — Pipeline planches** : `tools/build_characters.py` découpe les
      **SEPT** planches, et les sept mages sont **en jeu** avec leur propre
      animation dans les quatre directions
- [x] **Phase 4 — Stats et catalogue** : les 5 personnages réellement différents
      → `src/characters/{ability,character_stats,character_catalog}.gd`, `src/combat/element.gd`
- [x] **Phase 5 — Attaque** : branchée au jeu (projectiles, dégâts, effets)
      → `src/combat/{combat_system,combat_context,damage,health}.gd`
- [x] **Phase 6 — Compétences** *(logique ; boutons à faire)* : 7 formes de sorts,
      recharges, mana, refus sans coût
- [x] **Phase 7 — PV des ennemis** : barre flottante au-dessus, PV par espèce et
      par stage (`LevelConfig.hunter_health` / `goblin_health`)
- [x] **Phase 8 — Dégâts** : éclair blanc à l'impact, barre qui vire au jaune sur
      le dernier souffle, éclat de mort, **vagues de réapparition**
- [x] **Phase 9 — Compteur de kills** : affiché dans le bandeau avec sa jauge crantée
- [x] **Phase 10 — Extra Power** : verrouillé/déverrouillé, annonce à l'écran, dépensé
      seulement si le sort part réellement
- [x] **Phase 11 — HUD et boutons mobiles** : `CombatPad` (frappe contextuelle,
      3 sorts, Extra Hit), secteur de recharge, cadenas, pulsation quand l'ultime
      est prêt. Clavier : ESPACE, 1/2/3, E
- [x] **Phase 12 — Effets visuels** : un éclat par élément + nombres de dégâts
      → `src/fx/{impact_effect,damage_number,zone_effect}.gd`, `--fx` pour les comparer
- [x] **Phase 13 — Équilibrage** : `tests/test_balance.gd` réécrit avec le combat
      (PV des ennemis, vagues, tirs, sorts, ultime). Il mesure aussi la
      **viabilité des cinq personnages**
- [x] **Phase 14 — Réglage fin** : les sept mages mesurés, trois rééquilibrés,
      et une **invariante de non-domination** ajoutée aux tests

---

## 5. Journal

### 2026-08-24 — le SORCIER DES TÉNÈBRES, sort 1 : la Rune

Premier des quatre mages qui restaient à habiller. Choisi parce que c'est le
personnage PAR DÉFAUT (`CharacterCatalog.default_id()`) — celui que la plupart
des joueurs voient en premier — et qu'il était à **0 sort sur 6** avec une
signature propre. Mesure de départ :

| mage | sorts signés |
|---|---|
| Feu, Foudre | 5/6 (la fuite seule reste générique) |
| Eau | 3/6 |
| Terre | 2/6 |
| **Ténèbres, Air, Invocateur, Suprême** | **0/6** |

**Ce que la capture a montré.** La Rune se posait bien au sol et y restait — la
mécanique était bonne. Mais son dessin était l'anneau générique de n'importe
quelle zone : même silhouette que la nappe de feu, à la couleur près. Et sa
description promettait un piège (« le premier ennemi qui passe dessus explose »)
là où le code livrait une flaque : 18 dégâts par seconde pendant 8 s, soit 144 à
qui s'attarde et 9 à qui traverse — l'inverse exact de ce qui était annoncé.

**Deux directions essayées, la seconde retenue.**

1. *Flamme sombre* (violet et noir, 15 s, recharge 1 s). Abandonnée après essai :
   trop bruyante au sol, et le sort devenait un outil qu'on sème sans y penser.
2. *Le PORTAIL du mage, posé au sol* — retenu. La Rune reprend le dessin de sa
   translation (`warp.png`), qui ne servait qu'à elle : c'est le même passage,
   ouvert pour soi ou laissé derrière soi. **Trois charges**, rendues d'un coup
   après 8 s, huit secondes de tenue chacune.

⚠️ **ON NE PEUT PAS DESSINER DU NOIR EN ADDITIF** — leçon de la première
direction, qui vaut pour toutes les suivantes. Les zones se composaient en
`BLEND_MODE_ADD`, hérité du feu, de la glace et de la foudre qui veulent cette
lumière. En additif une cendre noire n'ajoute rien et un violet vif sature en
ROSE : la première version rendait un nuage rose, l'exact opposé du noir demandé.
Il faut le corriger à DEUX endroits — le nœud, mais aussi ses particules, qui
portent leur propre matériau et n'héritent pas de celui du parent
(`FxTextures.flame_emitter` prend désormais un paramètre `additive`).

**Ce qui a demandé une seconde passe sur le portail** : dessiné pour une colonne
verticale vue de face, très lumineux, il NOYAIT le mage debout dessus une fois
posé à plat et composé en additif. Assombri (alpha 0,26 au lieu de 0,55, teinté
de violet), écrasé à 0,66 en hauteur — au sol, un passage est une ellipse basse —
et son cœur brillant remplacé par un ŒIL SOMBRE : c'est un trou, pas une lampe,
et c'est ce qui garde le mage lisible.

**L'ouverture est progressive** (0,42 s, lissage de Hermite adouci aux deux
bouts) : disque qui s'écarte depuis le centre, anneau qui prend son ampleur. Une
zone qui apparaît d'un coup se lit comme un défaut d'affichage ; un passage
s'OUVRE. Deux anneaux tournent en SENS INVERSE — c'est ce qui donne la profondeur
du puits sans avoir à dessiner un puits.

**Vérifié headless** : 3 évocations acceptées d'affilée, la 4e refusée, les trois
charges rendues ensemble 8 s après la dernière.

**LE PÉAGE** (demandé ensuite) : marcher dessus coûte 10 PV et un cinquième de
la vitesse pendant 3 s, UNE FOIS par passage. Nouveau champ `Ability.damage_once`.

La distinction compte, et elle ne se lit pas dans les chiffres : une zone qui
ronge prélève par seconde et punit la PRÉSENCE — 18/s, c'est 144 à qui s'attarde
et 9 à qui traverse. Un péage prélève au franchissement et punit le PASSAGE,
c'est-à-dire exactement le rôle d'un piège posé sur la route qu'on sait que le
poursuivant prendra. Les deux effets sont posés ensemble et sous le même verrou :
les séparer laisserait un ennemi ralenti sans rien avoir perdu, ou saigné sans
ralentir, et le joueur ne comprendrait pas ce que son sort fait.

⚠️ Le verrou se REARME après 3,5 s, comme celui du brasier : un ennemi qui campe
sur le portail est repris. Mesuré : 20 PV en 6 s pour un ennemi immobile, contre
10 pour une traversée. Sans le réarmement, s'installer dessus serait gratuit.

**LA PLANCHE DESSINÉE** (`skill_rune.png`, commandée sur le prompt de
`docs/prompts/sorts/shadow_rune.md`). Six poses du portail vu de dessus — anneau de runes
gravées, puits qui se creuse, éclats violets — découpées par
`tools/build_rune.py` en une bande jouée en `hframes`. Le procédural ne garde
que ce que la bande ne peut pas faire : l'ouverture, dont la durée appartient au
sort.

⚠️ **LE DÉTOURAGE PARTAGÉ DÉTRUIT LE VIOLET.** `build_skill_icons.keyed` corrige
la frange magenta en retirant à chaque pixel « ce qu'il a de rouge ET de bleu en
plus de son vert ». C'est exactement la signature du VIOLET autant que du
magenta : essayé, le portail sortait bleu-gris et son cœur devenait translucide.
La formule avait été validée sur le feu, l'eau et la foudre — trois éléments
dont la couleur est loin du magenta. Elle ne peut pas servir ici.

Le vrai discriminant n'est d'ailleurs pas la teinte : 78 % de la planche est de
teinte magenta, portail compris. C'est la CLARTÉ qui sépare — le fond est un
magenta vif (r,b ≥ 200 avec g ≤ 60, mesuré à 67 % pour un fond qui en occupe
69 %), le portail un violet sombre. `build_rune.py` a donc son propre détourage,
et son dégorgement ne touche que les pixels réellement mêlés au fond.

⚠️ **ALIGNEMENT — la rangée du bas est dessinée 91 px plus haut.** Retour du
terrain, invisible sur la planche et flagrant en jeu : le portail sautait d'un
tiers de case entre la 3e et la 4e image, puis redescendait en bouclant.

Ni la position dans la case (elle porte le décalage) ni la boîte englobante (les
éclats qui s'échappent changent de hauteur à chaque pose) ne peuvent servir de
repère. On aligne sur le **bord avant du corps opaque** — le point où l'ellipse
touche le sol : mesuré à y 462 sur les trois images du haut et y 371 sur les
trois du bas, identique à l'intérieur de chaque rangée. C'est exactement le rôle
que jouent les pieds pour les personnages. Seuil à alpha 200 volontairement
haut : les éclats sont translucides, les inclure ferait dépendre le repère de ce
qui vole autour plutôt que de l'anneau.

⚠️ **SIX POSES ENCHAÎNÉES SÈCHEMENT = SIX SACCADES PAR TOUR.** Chaque pose est un
sixième de tour ; les afficher l'une après l'autre fait voir le SAUT et non la
rotation. Deux calques montrent donc DEUX poses consécutives et se fondent selon
la partie fractionnaire du temps — entre la pose 2 et la 3, on voit
littéralement l'entre-deux. C'est aussi ce qui permet de tourner LENTEMENT
(4,5 images/s, un tour en 1,3 s) sans que ça devienne un diaporama.

Des BRAISES rares montent du puits. Elles ne décorent pas : elles donnent un
mouvement continu entre deux poses dessinées — sans elles, l'œil n'a que le
fondu pour croire que quelque chose tourne.

**Le retour visuel du péage existait déjà** par les chemins partagés : l'ennemi
touché éclaire (`flash_hit`), un « -10 » monte (`_spawn_damage_number`) et la
teinte de trempe s'applique (`Enemy.soak`). Rien à écrire de neuf.

### 2026-08-24 — sept créatures marchaient à reculons

Signalé en jouant : le Golem de Lave avançait de dos. Sa rangée de profil est
dessinée vers la DROITE, et `build_bestiary.py` lisait la rangée 2 comme la
gauche sur les neuf planches. Vérification dessin par dessin : **sept planches
sur neuf** regardent vers la droite (serpent, dragonnet, golem, archer,
minotaure, chevalier, givre). Seuls l'Ombre et le Démon de Cristal regardaient
bien à gauche.

Ce qui rend ce défaut coûteux, c'est qu'**aucun contrôle ne pouvait le voir** :
les fichiers existent, la bande fait `cellule x poses`, `check_characters.py` ne
juge que le cadrage, et les tests headless ne chargent aucune texture. En jeu,
on ne croise une créature de profil que quelques secondes.

Correction : `profile` par planche dans la table de `build_bestiary.py` (défaut
`"right"` — la majorité ; les deux exceptions sont écrites). `config_for()`
bascule alors la rangée et le miroir, et rien d'autre ne change dans le
découpage. Preuve : les nouveaux `left.png` / `right.png` sont **bit à bit** les
anciens `right.png` / `left.png`, et les deux créatures déjà justes n'ont pas
bougé d'un octet.

⚠️ Leçon générale : corriger ce genre de défaut **dans les PNG de sortie ne sert
à rien**, le prochain passage de l'outil les réécrit. La correction va dans la
table.

Garde-fou ajouté : **`tools/check_profiles.py`** pose côte à côte la pose de
foulée des 19 bandes `left.png` (onze créatures et huit mages). Elles doivent
toutes regarder à gauche. Il ne juge rien automatiquement — il n'existe pas
d'invariant commun à la gueule d'un serpent, à la cape d'un chevalier et à la
poussière d'un golem — mais il montre les dix-neuf d'un seul coup d'œil.

### 2026-08-24 — l'Invocateur repasse sur une planche à alpha

`mage_invocateur.png` remplace `mage_invocateur.jpeg`. Ce n'est pas la même
planche redessinée : c'est une **collection**, quatre fois plus fournie, et avec
un vrai canal alpha.

Ce que le remplacement a rendu caduc dans `tools/build_invocateur.py` :
tout le détourage. L'ancienne planche imposait un « pixel neutre connecté au
bord », des seuils de désaturation pour tuer les étiquettes de texte, un flou
d'un demi-pixel contre le crénelage JPEG. Il ne reste **qu'une règle** — dans une
boîte, la forme qui entre par un bord appartient à la voisine — et les boîtes
elles-mêmes ne sont plus relevées à l'œil mais prises comme **boîtes englobantes
des formes connexes**, donc exactes au pixel.

Ce que la nouvelle planche apporte :

| | avant (JPEG) | après (PNG) |
|---|---|---|
| marche | 4 face · 5 dos · 4 gauche · 3 droite | 4 face · 4 dos · 6 gauche · droite en miroir |
| sorts | 3 poses | 6 poses |
| créatures | imp, gargouille, dragon (2 poses/direction) | imp (4+1), démon (2+1), dragon (1+1 × 4 directions) |
| effets | orbe, zone, warp | orbe **animé** (2 images), impact, zone, warp |

Deux conséquences côté moteur :

- `SummonVisual` lit maintenant **`assets/allies/allies.json`** comme `Player`
  lit son `frames.json` : une bande par créature et par direction (`hframes`),
  poses d'inaction puis poses de coup, rien de codé en dur. La **case est commune
  à toutes les directions d'une créature**, et c'est elle qu'on met à l'échelle —
  le dragon qui pique a les ailes rabattues, celui qui monte les a déployées, et
  ce rapport-là doit tenir. La teinte de coup (`modulate` rouge) a disparu : elle
  remplaçait une pose qui existe maintenant pour de bon.
- la « gargouille de pierre » est désormais le **démon rouge** de la planche —
  c'est la seule grosse créature qu'elle dessine, et elle crache le feu. Son nom
  et sa description dans `CharacterCatalog` n'ont PAS été changés : c'est un
  arbitrage de design, pas de découpage.

⚠️ Constat à assumer : la planche **ne dessine pas le bâton dans toutes les poses
de marche** (absent dans 3 des 6 poses de profil, dans 2 des 4 poses de dos). Le
cycle suit malgré tout l'ordre de la planche, donc l'orbe du bâton apparaît et
disparaît pendant la marche. Corriger cela voudrait dire renoncer à la moitié des
poses dessinées — le remède serait pire.

Vérifié par capture : le mage (`--character invocateur`), l'impact du trait
occulte, le cercle d'invocation au sol, et les trois créatures dans leurs quatre
directions via `tools/preview_summons.gd`, écrit pour ça — en jeu, on ne voit
jamais les quatre vues du dragon d'un coup.

### 2026-08-23 — l'instrument de mesure était faux

Épisode à retenir, parce qu'il remet en cause des conclusions antérieures.

Pour corriger un Mage de l'Eau qui gagnait 83 % des parties sans jamais mourir,
son bouclier a été baissé de 45 à 34. Relance de la simulation : **chiffres
rigoureusement identiques**, au caractère près.

Cause : le joueur simulé prenait toujours la **première** compétence utilisable
de la liste. Pour l'Eau, c'est la Vague. Il n'a donc jamais lancé un seul
bouclier de toute la campagne — et par extension, **aucun mur de pierre, aucune
translation, aucun soin, sur aucun mage**. Seule la compétence 1 était testée.
Toutes les conclusions portant sur les compétences 2 et 3 étaient sans fondement.

Deux suites :
1. La baisse du bouclier a été **annulée** — elle visait une cause que la mesure
   n'avait jamais observée.
2. Le bot choisit maintenant comme un joueur : se protéger sous 50 % de vie,
   sinon frapper le plus fort. La réparation a immédiatement déplacé trois
   mesures (Terre 17 → 8 % de morts, Suprême 8 → 0 %, Air 4 → 9 parties bloquées).

**La vraie cause du cas Eau** est apparue ensuite : il n'était pas seulement
protégé, il n'était **jamais touché**. Son allonge de 11 cases lui faisait
abattre ses poursuivants avant qu'ils n'arrivent — aucun réglage défensif ne
pouvait donc rien y faire. Portée ramenée à 9 : 83 % → 67 % de victoires, et le
temps de partie passe de 179 à 165 s.

Il ne meurt toujours pas en simulation. C'est peut-être une propriété du bot,
qui fuit de façon optimale, plus qu'un défaut du personnage — à confirmer à la
main.

**Leçon** : un instrument qui n'observe pas ce qu'on croit qu'il observe est
pire qu'aucun instrument. Le signe qui a mis la puce à l'oreille est un résultat
INCHANGÉ après une modification censée compter.

### 2026-08-23 — PV des ennemis rebaissés (retour du terrain)

Signalé en jouant : au stage 1, les ennemis sont trop longs à abattre. Vrai —
et l'erreur vient de la méthode. Ces PV avaient été RELEVÉS sur la foi de la
simulation, où le bot tire en continu sans jamais reculer, viser ni lâcher le
bouton. Un joueur humain tire par à-coups entre deux virages : au même nombre de
PV, il lui faut deux à trois fois plus longtemps.

| | Avant | Après |
|---|---|---|
| Stage 1 — chasseur | 150 | **100** |
| Stage 2 — chasseur / gobelin | 170 / 230 | **135 / 185** |
| Stage 3 — chasseur / gobelin | 200 / 270 | **165 / 225** |

Abattre un poursuivant au stage 1 : de ~10 coups à **6 ou 7** selon le mage.

**Pas** d'augmentation des dégâts : cela aurait touché les trois stages et les
sept mages d'un coup, et défait l'équilibre entre eux. Baisser les PV d'un stage
ne déplace qu'une chose à la fois.

**Conséquence sur les tests.** La simulation dit maintenant l'inverse : stage 1
gagné à 100 % sans une mort, « aucune tension ». Les deux mesures ne portent pas
sur la même chose — la simulation dit si un niveau est SURVIVABLE, pas s'il est
AGRÉABLE. Plutôt que de faire taire le test ou de durcir le jeu contre l'avis du
joueur, le stage 1 est déclaré `is_tutorial` : la règle « un joueur qui ne meurt
jamais, c'est un jeu sans enjeu » ne s'y applique plus. Le plafond de MORTALITÉ,
lui, continue de s'appliquer partout — un stage 1 qui tuerait la moitié des
joueurs resterait un échec.

**Reste ouvert** : au stage 2, le Mage de l'Eau gagne 83 % sans jamais mourir
quand le Mage du Feu tombe à 17 % avec 50 % de morts. C'est l'écart voulu entre
un survivant et un canon de verre, mais il est large ; à revoir si le jeu à la
main le confirme.

### 2026-08-23 — découpage faux sur deux mages (retour du terrain)

Signalé en jouant : le **Sorcier des Ténèbres** ne regardait pas dans la bonne
direction, et sa bande `right` était illisible. Diagnostic :

`col0 = 1, row0 = 1` sur l'Eau et les Ténèbres partait du principe qu'une colonne
d'étiquettes devait être sautée. Faux : la phase détectée tombait DÉJÀ sur la
première pose. L'ancrage sautait donc la pose **IDLE** et la direction **DOWN**,
et la quatrième direction tombait dans le portrait du bas de planche. D'où la
remarque « il constitue toujours en 5 walks » — il n'y avait effectivement plus
de pose de repos, juste quatre marches et deux attaques.

**Correctif de fond**, au-delà des deux valeurs : les RANGÉES sont désormais
**mesurées sur l'image** au lieu d'être déduites de la phase. Cela corrige aussi
une dérive de ~24 px sur le Feu, dont les cases rognaient les pieds. Les colonnes
restent sur l'autocorrélation — un calage par mesure a été essayé et **rejeté** :
la colonne d'étiquettes est séparée de la première pose par un écart proche du
pas normal, et chaque case se retrouvait avec deux moitiés de mage.

**Nouveau garde-fou** : `tools/check_characters.py` compare la grille calculée
aux rangées réellement mesurées. Il a été validé par l'épreuve du feu — on remet
le mauvais `row0`, le script doit crier, et il crie. Une première version ne
regardait que le contenu des cases (vides ? hauteurs cohérentes ?) et ne
détectait PAS le bug : elle a été jetée. Un garde-fou qui ne se déclenche pas sur
le défaut qu'il vise est pire que rien, il rassure à tort.

Sur trois planches (Terre, Suprême, Foudre) les lueurs se touchent et
l'alignement n'est pas mesurable : le script le **dit** au lieu de faire semblant.

### 2026-08-23 — passage en PAYSAGE (retour du terrain)
Premier essai au pouce sur l'iPhone : en portrait, la croix directionnelle et
les cinq boutons de combat se disputaient la même bande basse et les pouces se
gênaient. Le jeu passe en **paysage** (`orientation=4`, les deux sens).

Trois corrections que seul le passage en paysage a révélées :
- **L'échelle de l'interface ne peut plus être une constante.** Le mode
  d'étirement réduit la mise en page de ~58 % en portrait mais l'agrandit de
  ~163 % en paysage : le facteur 2,4 qui donnait de bonnes touches produisait un
  bandeau occupant la moitié de l'écran. `Platform.apply_ui_scale()` part
  désormais de l'inverse — quelle taille PHYSIQUE doit faire une touche (62
  points), et quel facteur y mène sur cet écran-ci.
- **Les boutons de sorts se chevauchaient** : posés à 118 px du centre avec 37°
  d'écart, soit une corde de 61 px pour des boutons de 66. Et leur arc
  DESCENDAIT — en coordonnées écran l'axe Y va vers le bas, un arc qui monte a
  un sinus négatif. La troisième compétence sortait de l'écran.
- **L'écran de sélection débordait** : ses ancres étaient pensées pour un écran
  vertical, la fiche passait sous les boutons. La mise en page est maintenant
  calculée à partir de la hauteur disponible.

Et les bandes noires de l'écran-titre (la couverture est en 2:3) reçoivent la
couverture elle-même, agrandie et assombrie : l'œil lit un décor continu.

### 2026-08-23 — build iPhone après la refonte
- Installé sur l'iPhone 12 Pro. L'app précédente datait de midi, **avant** le
  combat, les sept mages et les menus.
- **Poids divisé par trois** : le paquet passe de 41,7 à 12,2 Mo, l'app de 67 à
  37,6 Mo. Les planches sources (`assets/raw`, `peso&cover/mage_*`,
  `peso&cover/enemi_*`, `boss.png`) ne servent qu'à la compilation et partaient
  dans l'app. Piège : `exclude_filter` compare le chemin COMPLET, un motif
  `assets/raw/*` ne mord jamais — il faut `*/assets/raw/*`.
- Seule `couverture.png` est chargée à l'exécution.

### 2026-08-23 — équilibrage des sept (phase 14, dernière)

**Le problème.** Écrits en dernier, le Mage de la Foudre et le Mage de l'Air
**dominaient strictement** le Sorcier des Ténèbres et le Mage de l'Eau : au
moins aussi bons sur les quatre axes mesurables (PV, vitesse, dégâts par
seconde, portée) et meilleurs sur au moins un. En simulation ils gagnaient
67 % des parties sans jamais mourir.

**Ce qui n'a pas marché.** La simulation d'équilibrage ne l'a PAS signalé : sur
douze parties, un écart de 30 % de dégâts se noie dans le bruit statistique.

**Le correctif.** Chacun paie désormais sa force :

| Mage | Avant | Après |
|---|---|---|
| Foudre | 3 PV · 5.3 · 46.9 DPS · portée 10 | 3 PV · 5.3 · **31.2** · portée **7** |
| Air | 4 PV · **5.2** · 35.7 DPS · portée 12 | 4 PV · **4.9** · **28.6** · portée 12 |
| Suprême | 4 PV · 5.0 · 44.4 DPS · portée 9 | 4 PV · **4.9** · 44.4 · portée **8** |

**Le garde-fou.** `test_combat.gd` vérifie maintenant qu'**aucun mage n'en
domine un autre** — comparaison exacte des statistiques, instantanée, sans
simulation. Les deux tests sont complémentaires : l'un dit « le jeu est
jouable », l'autre « aucun choix n'est un piège ».

**Résultat, stage 2, explorateur :**

```
Feu       50% de victoires · 50% de morts     Foudre   33% · 42%
Eau       50% ·  8%                            Air      58% ·  8%
Terre     50% · 25%                            Suprême  75% · 25%
Ténèbres  25% · 25%
```

Plus personne n'est intouchable : le Suprême reste le plus fort (c'est son
rôle) mais il meurt désormais une partie sur quatre.

### 2026-08-23 — les sept mages entrent dans le jeu
- Le roster passe de cinq à **sept** : ajout du **Mage de la Foudre** (le plus
  rapide, cadence de tir la plus courte du jeu, 0,32 s) et du **Mage de l'Air**
  (contrôle et bouclier). Deux nouveaux éléments dans `Element`.
- `Player` charge la planche de SON personnage : plus rien n'est écrit en dur.
  La gauche n'est plus un miroir de la droite — l'illustrateur a dessiné les
  deux, et une cape qui se drape du même côté dans les deux sens se remarque.
- Le découpage du **Feu** était décalé d'une case : il tapait dans les
  étiquettes de la planche. Corrigé, vérifié à l'image.
- Les vignettes de sélection montrent la première pose de marche **de face** :
  le mage regarde le joueur, ce qui est tout l'intérêt d'un écran de choix.
- `tests/test_combat.gd` vérifie maintenant que **chaque personnage du catalogue
  a bien sa planche découpée** — un mage choisissable et invisible serait le
  genre de régression qui passe inaperçue jusqu'à la première partie.

### 2026-08-23 — nuit : écrans d'accueil et de sélection
- `GameFlow` : routeur accueil → sélection → jeu, et retour par le bouton Menu
  de l'écran de pause. Il ne tient qu'UNE donnée entre deux écrans, le
  personnage choisi ; le GameManager reste le chef d'orchestre d'UNE partie et
  ignore qu'il existe un menu.
- **Règle de ligne de commande** : dès qu'un argument est passé, on entre
  directement en jeu. Sans elle, chaque capture de développement s'arrêterait
  sur l'écran-titre et tout l'outillage de vérification visuelle serait à
  refaire. `--menu` et `--select` forcent l'écran voulu.
- La capture d'écran passe dans `src/core/screenshot.gd`, partagée par le jeu et
  les menus : elle vivait dans DevTools, qui n'existe qu'en partie, et
  `--screenshot` ne répondait donc plus dès qu'un menu était devant.
- Le fond des menus est un **vrai labyrinthe généré** (graine fixe), pas une
  illustration : il montre ce que le joueur va traverser et suivra toute
  évolution du générateur.
- **Responsive vérifié en portrait** (585x1266) : la rangée de vignettes se
  redimensionne, sinon la cinquième sortait de l'écran et la fiche se faisait
  couper des deux côtés.
- Vérifié : choisir le Mage de Terre donne 5 points de vie en jeu, le Mage de
  Feu 3. Le personnage traverse bien tout le chemin jusqu'à la partie.

### 2026-08-23 — nuit : effets élémentaires
- `ImpactEffect` : cinq éclats qui ne se ressemblent pas, **dessinés et non
  texturés**. Ce n'est pas la couleur qui distingue les mages, c'est le GESTE —
  le feu MONTE (langues de flamme, gravité négative), l'eau RETOMBE (gouttes +
  double onde), la terre est PROJETÉE ET PÈSE (éclats anguleux, gravité forte,
  et surtout **pas d'additif** : de la poussière lumineuse donnerait un feu
  d'artifice beige au lieu d'un éboulement), l'arcane TOURNE (losanges-runes),
  le Suprême emprunte les quatre à la fois.
- L'éclat prend le **rayon réel** de la compétence : le joueur voit jusqu'où son
  sort a porté, sans quoi il ne peut pas apprendre à s'en servir.
- Le semis est déterministe (graine dérivée de la case) : deux captures du même
  impact sont comparables.
- `DamageNumber` : le chiffre qui s'envole. C'est la seule chose qui dit si un
  sort vaut mieux que l'attaque de base — sans lui, choisir entre deux
  compétences revient à deviner. Il grossit avec les gros coups.
- Nouvelle option de dev `--fx` : rejoue les cinq éclats côte à côte, sinon les
  comparer demanderait cinq parties et le bon sort au bon moment devant la caméra.
- **À noter** : choisir un autre mage ne change pas encore son sprite — les
  quatre planches manquent. Seules les statistiques, la portée et les effets
  diffèrent pour l'instant.

### 2026-08-23 — nuit : équilibrage validé

**Verdict final, 6 suites vertes.**

```
Stage 1   EXPERT 100% ·  0% mort     EXPLORATEUR 83% · 17% mort
Stage 2   EXPERT 100% ·  0% mort     EXPLORATEUR 25% · 25% mort
Stage 3   EXPERT 100% ·  0% mort     EXPLORATEUR 17% · 42% mort

Feu      50% victoires · 50% morts     Eau      50% · 8%
Terre    50% victoires · 25% morts     Suprême  75% · 0%
```

Reste ouvert : l'EXPERT ne meurt jamais depuis que l'attaque est gratuite. Ce
n'est pas alarmant — le plafond a toujours été un joueur qui connaît la carte
par cœur ET esquive — mais c'est à re-mesurer quand les sorts auront leurs vrais
effets et que les ennemis riposteront.

### Détail de la séance
- Première mesure après branchement : **le combat rendait le jeu trivial**.
  L'EXPERT gagnait 100 % à tous les stages sans une seule mort, l'EXPLORATEUR
  92 % au stage 1. L'attaque étant gratuite, à 14 cases de portée et à tête
  chercheuse, on abattait des poursuivants jamais vus, deux virages plus loin,
  et le labyrinthe se vidait tout seul.
- Correctifs : PV des ennemis **relevés** (chasseur 150→200, gobelin 230→270),
  réapparition **accélérée** (12 s → 6-8 s), portée de l'attaque **resserrée**
  (Arcane 14 → 10 cases, Terre 6, Feu 8).
- Résultat : taux de mort de l'explorateur 17 % / 25 % / 42 % selon le stage —
  une vraie montée en difficulté. Et les personnages se distinguent enfin à la
  mesure : le Mage de Feu meurt dans 50 % des parties, le Mage d'Eau dans 8 %.
- Le critère du test change : il juge le taux de **MORT**, pas le taux de
  victoire. Une partie « bloqué » est un agent qui s'est perdu, pas un niveau
  injuste — les compter en défaites condamnerait tout grand labyrinthe.
- Bug corrigé dans la simulation elle-même : un `randi_range` imbriqué biaisait
  le tirage de l'explorateur vers les premiers couloirs.
- `SpellSystem` et son test partent dans `docs/attic/` : entièrement remplacés
  par `CombatSystem`, dont les tests couvrent désormais aussi la trajectoire.

### 2026-08-23 — soir : combat branché au jeu
- Le combat tourne **en jeu** : PV et barres de vie sur les ennemis, éclair à
  l'impact, éclat de mort, vagues de réapparition, compteur de kills et Extra
  Power dans le bandeau, barre d'action tactile.
- `LevelConfig` : `player_max_health` devient `player_health_bonus` (le personnage
  apporte sa constitution, le stage sa marge), plus `hunter_health`,
  `goblin_health`, `enemy_respawn_delay`.
- La potion donne du **mana**, l'orbe **inflige des dégâts**.
- ⚠️ **COLLISION DE SESSIONS** : une autre session Claude édite le même projet en
  parallèle (animations du gobelin, `enemy.strike()`). Ma réécriture d'`enemy.gd`
  a effacé son `strike()` — je l'ai réécrit pour que le jeu tourne, mais son
  implémentation d'origine est perdue. **Ne pas travailler à deux sessions sur ce
  dépôt en même temps.**
- ⚠️ `tests/test_balance.gd` ne tourne plus (voir phase 13).

### 2026-08-23 — après-midi : cœur de combat
- **Fait et testé** : `Element`, `Damage`, `Health` (PV, bouclier, soin), `KillSystem`
  (seuil, recharge, total cumulé), `Ability` (7 formes de sorts, tout en données),
  `CharacterStats`, `CharacterCatalog` (les 5 mages), `CombatContext`, `CombatSystem`
  (visée, temps de vol, dégâts, explosions, zones, murs, translation, bouclier, soin).
- `tests/test_combat.gd` : 11 vérifications vertes, dont deux qui protègent des
  promesses non évidentes — une explosion **ne traverse pas une haie** (rayon mesuré en
  distance de chemin), et un geste refusé **ne coûte ni mana ni recharge**.
- Repère d'équilibrage : le Mage Arcane reproduit exactement l'ancien jeu (3 PV, orbe
  à 14 cases, 16 dégâts). Les quatre autres se comparent à lui.
- **Reste à faire pour que ce soit jouable** : brancher tout ça au `Level` (PV des
  ennemis, barres de vie, vagues de réapparition), au `GameManager` (kills, ultime) et
  au HUD (boutons HIT / SKILL / EXTRA HIT).

### 2026-08-25 — `allies.json` effacé : un fichier COMMUN écrit par deux outils

L'ultime des Ténèbres n'invoquait plus rien : la console répétait
« Invocation inconnue dans allies.json : « ombre » ». Les six ombres partaient
bien — le CombatSystem faisait son travail — mais le rendu ne trouvait pas
la créature et n'affichait personne.

**La cause.** `assets/allies/allies.json` est le catalogue de TOUTES les
créatures alliées, et deux outils y écrivent : `build_invocateur.py` pour les
trois bêtes de l'Invocateur, `build_ombre.py` pour l'Ombre maléfique. Le second
FUSIONNE — il relit le fichier et n'ajoute que sa clé. Le premier repartait
d'un dictionnaire VIDE et réécrivait tout : chacun de ses passages effaçait
l'entrée « ombre » posée par l'autre.

Les images, elles, étaient toujours là (03:02) ; seul le descripteur avait été
réécrit (03:37). Un fichier daté d'après ses propres images est le premier
endroit où regarder.

**Le correctif** : `build_invocateur.py` fusionne désormais lui aussi. Un
fichier partagé se relit avant d'être écrit, et chaque outil ne touche qu'à ses
propres clés. `build_ombre.py` a été relancé pour reposer l'entrée ; vérifié à
la sonde, les six invocations trouvent leur créature.

### 2026-08-25 — LES HUIT ORBES

Le projectile — l'image qui voyage entre le mage et sa cible pour toute
compétence de forme `PROJECTILE`, l'attaque de base en tête — était une image
FIXE pour sept mages sur huit, découpée au petit bonheur dans leur planche de
personnage. Seule celle du Feu battait, en trois images.

Huit planches ont été commandées (`docs/prompts/sorts/orbe_*.md`), une par
mage, et découpées par `tools/build_orbs.py` : quatre images qui vont de la
NAISSANCE du tir à sa PLEINE PUISSANCE.

Les huit silhouettes sont volontairement distinctes, pas seulement recolorées —
comète, lance, bloc, dard, lame, croc, sphère, sceau. Trois s'écartent
délibérément du lot : le bloc de Terre est le seul projectile OPAQUE (il ne
brille pas, il pèse), le croc des Ténèbres le seul COURBE, la sphère du Suprême
la seule RONDE.

**Le jeu a dû apprendre la progression.** `MagicOrb` rejouait la bande en
boucle à 12 im/s, ce qui aurait fait retomber le projectile de sa pleine
puissance à son étincelle de départ, en plein vol. Un `"mode": "grow"` dans
`orb.json` fait maintenant dérouler la bande UNE fois en 0,22 s, puis tenir la
dernière image jusqu'à l'impact. Le mode "loop" reste la valeur par défaut.

Trois règles ont été inscrites dans chaque prompt, parce que ce sont celles
dont l'oubli casse le rendu :

- **la direction** — le jeu ORIENTE le sprite le long de sa trajectoire, angle
  zéro vers la droite ; une orbe dessinée autrement volerait de travers dans la
  moitié des couloirs ;
- **le calage** — la pointe reste au même endroit et le tir grandit vers
  l'arrière, sinon il tressaute en vol (le découpage applique en plus une boîte
  COMMUNE aux quatre images, comme pour l'éruption de la Terre) ;
- **les cases égales** — `sprite.hframes = 4` découpe la texture en quatre parts
  exactement égales : une bande aux images inégales montrerait des moitiés
  d'images.

### 2026-08-26 — LE GEYSER DE L'EAU, dessiné

L'ultime de l'Eau faisait trois choses, et deux étaient tracées en code : la
colonne de pression (un dégradé qui monte) et les trente gouttes de pluie, qui
empruntaient l'ORBE du mage faute de mieux — une bille qui tombe.

Une planche a été commandée (`geyser_water.png`, deux rangées de six images) :
la COLONNE qui jaillit, culmine et retombe ; l'ÉCLABOUSSURE d'une goutte qui
touche le sol. Les deux ont leur ancre, relevée sur la dernière image.

Trois branchements, un par moitié du sort :

- la colonne remplace `PressureColumn`, qui reste le repli ;
- l'éclaboussure joue à chaque goutte qui tombe — trente gouttes doivent se
  VOIR tomber, pas seulement compter des dégâts ;
- **ce qui tombe est ce qui éclabousse** : la goutte en vol est la première
  image de l'éclaboussure, celle où elle est encore en l'air. Une comète qui
  tombe convient au Feu, pas à l'Eau.

⚠️ **LA COLONNE SOUS LE MAGE A ÉTÉ ABANDONNÉE**, et c'est l'utilisateur qui a
trouvé la bonne forme.

Posée par-dessus le personnage, elle l'EFFACE : pendant une seconde, au moment
le plus chargé de la partie, le joueur ne sait plus où il est. Posée dessous,
elle n'a plus aucune force. Une version DÉDOUBLÉE — moitié derrière opaque,
moitié devant à 45 %, le truc classique des effets de transformation — le
rendait bien visible « dans » le jet, mais le problème de fond restait : un
effet plein écran centré sur le joueur cache le labyrinthe qu'il doit lire.

**NEUF GEYSERS jaillissent maintenant AU HASARD sur la carte, tous en même
temps**, et frappent ce qui passe dessus. Plus rien ne se superpose au mage, et
l'ultime y gagne une PORTÉE : il ne récompense plus seulement d'être au bon
endroit, il nettoie le labyrinthe. Un test garde la salve — une colonne qui
sortirait plus tard ferait doublon avec la pluie, qui est l'autre moitié du
sort.

**LA FLUIDITÉ VIENT DU FONDU, pas du nombre d'images.** Six images sur une
seconde font cinq images par seconde : un diaporama. On ne peut pas en dessiner
plus, mais on peut faire se RECOUVRIR deux images consécutives — la suivante
monte en opacité pendant que la précédente s'efface — et enfler la taille d'un
cheveu entre les deux. L'œil recompose le mouvement.

**Les gouttes de pluie ont été réduites et rendues liquides.** À une case et
demie — la taille d'une météore du Feu — trente d'entre elles effaçaient le
labyrinthe : ramenées au tiers d'une case. Et elles ne TOURNOIENT plus : un
caillou en chute libre pivote sur lui-même, une goutte garde sa pointe en bas
et ondule. Un shader (`water_drop.gdshader`) lui donne cette ondulation, plus
forte vers la pointe, et fait courir un reflet le long de son flanc.

**LA FRAPPE DE LA FOUDRE EST DEVENUE UNE ANIMATION.** Le dessin d'impact
découpé d'une planche de personnage est FIXE : le jeu ne peut que l'agrandir et
le faire pâlir. Celui de la Foudre a été jugé raté, et une planche a été
commandée (`impact_thunder.png`, six images : le trait qui tombe, le contact,
l'éclat, l'anneau au plus large, la retombée, l'anneau mourant).

⚠️ **Le point d'impact n'est PAS le centre de l'image.** L'éclair tombe du haut
de la case et l'éclat se produit en bas : centrer le dessin posait la frappe une
demi-case trop haut, et le sol s'illuminait à côté de la créature touchée.
L'ANCRE est donc relevée au découpage sur la DERNIÈRE image — celle où il ne
reste que l'anneau au sol, dont le centre est le point d'impact — et écrite dans
le descripteur.

⚠️ **Les étincelles débordaient de leur case** — signalé : chaque image
emportait un morceau de sa voisine. Le prompt exige pourtant des marges ; le
modèle ne les a pas tenues. Le découpage ne coupe donc plus aux lignes
théoriques mais au CREUX : autour de chaque ligne, il cherche dans une fenêtre
de 12 % la colonne la plus vide, c'est-à-dire l'écart entre deux dessins.

Elle est mise à l'échelle sur sa LARGEUR et non sa hauteur : c'est l'anneau au
sol qui doit couvrir la zone touchée, alors que le trait tombant du ciel
écraserait tout le reste.

**Un seul endroit la distribue.** `_spawn_impact` remplace le dessin fixe par
l'animation dès qu'un appel demandait la frappe du personnage — l'attaque de
base, les frappes du Jugement céleste, les relais de la Chaîne. Le test se fait
sur la texture demandée plutôt qu'au cas par cas : un seul endroit à tenir, et
les sept autres mages en hériteront le jour où leur planche arrivera.

⚠️ **L'ÉTAT FINAL D'UN TIR EST SA FRAPPE, pas son projectile.** Signalé sur la
Foudre : à l'arrivée, on voyait le dard et non le dessin d'impact — pourtant le
plus beau du jeu, la frappe au sol avec son anneau.

Deux causes, toutes deux dans le rendu de l'impact :

- **la taille.** Le dessin central est mis à l'échelle du RAYON du sort, or une
  attaque de base n'a pas de rayon : `maxf(0.9, 0.0)` donnait 0,9 case, noyée
  sous la lueur des particules. Les tirs en trait brisé posent désormais leur
  frappe sur 1,7 case ;
- **la rotation.** Le dessin central tourne sur lui-même — juste pour un
  vortex, absurde pour une frappe de foudre, qui a un HAUT et un BAS. La
  vitesse de rotation est devenue un paramètre (`p_spin`), et ces dessins-là
  passent zéro.

C'est la troisième fois qu'un dessin d'impact générique gêne un sort refait —
après la tornade tournoyante du Grand souffle et le blason de l'ultime de la
Foudre. La leçon commune : *un effet générique posé par-dessus un dessin
commandé le contredit plus souvent qu'il ne l'aide.*

**L'orbe de la Foudre sert, elle aussi.** Son attaque de base est tracée en
traits brisés depuis sa refonte, donc son orbe n'aurait rien affiché. Les deux
coexistent désormais, et chacun dit une chose que l'autre ne dit pas : le trait
brisé donne la DÉCHARGE — instantanée, elle relie le mage à sa cible d'un bout
à l'autre du couloir — et le dard dessiné donne le COUP, celui qui met un temps
à arriver et qu'on peut voir venir. Sans le trait, l'élément perd sa signature ;
sans le dard, le joueur ne sait pas à quel instant le coup porte. Vérifié à la
sonde : un tir produit bien le dard de quatre images ET ses arcs.

⚠️ **Deux autres outils écrivaient déjà `orb.png`** — `build_spell_fx.py` pour
les sept mages, `build_invocateur.py` pour le huitième — et les relancer aurait
effacé les orbes commandées **sans un message d'erreur**, exactement le piège
déjà documenté pour les planches de personnage. Les deux savent désormais
reconnaître une orbe commandée à son `"mode": "grow"` et la laissent en place :
« orbe COMMANDÉE, laissée en place ».

### 2026-08-25 — le MAGE DE L'AIR

**L'audit** : quatre problèmes sur cinq sorts. La Tornade était la QUATRIÈME
zone immobile du jeu (après le brasier, le cercle glacé et le champ de foudre)
et sa description — « malmène tout ce qu'elle touche » — ne disait rien. La
Bourrasque annonce « balaie le couloir » et ne pousse rien, en portant en plus
le nom du trait élémentaire de l'Air. Le Voile d'air est le bouclier de l'Eau
avec des chiffres plus petits. Le Cyclone annonce que « le labyrinthe entier est
aspiré » : c'est un cercle de dégâts.

**TORNADE — elle AVANCE, et elle EMPORTE.** Elle remonte le couloir toute seule
sur sept cases, virages compris, et ce qu'elle attrape voyage avec elle : happé,
blessé chaque seconde, puis lâché là où elle meurt — loin, et en tas avec les
autres qu'elle a ramassés.

C'est le pilier de l'Air : le **DÉPLACEMENT**. Rien d'autre dans le jeu ne fait
parcourir des cases à une créature — le trait de l'élément la pousse de deux
cases, une fois. Et ça donne enfin corps à la fiche du personnage : « il gagne
les combats qu'il refuse de livrer ». Ses dégâts sont faibles pour cette raison :
c'est un sort de position.

Le chemin est calculé D'UN COUP au lancement. Recalculé en route, la tornade
changerait d'avis à chaque carrefour et le joueur ne pourrait plus prévoir où
elle emmène ses poursuivants.

Un test interdit que les trois autres zones du jeu se mettent à voyager — sans
quoi l'Air reperdrait son pilier au premier réglage.

⚠️ **La rotation par shader a échoué.** Ce qui tourne à l'œil sur une tornade,
ce sont ses bandes : la première version les faisait défiler en décalant la
texture horizontalement. Raté — un dessin de tornade n'est pas RÉPÉTABLE
horizontalement, donc le bord gauche réapparaissait à droite et le tout
s'étalait en bouillie bleue.

Une planche de huit images a donc été commandée (`tornado_spin.png`,
silhouette identique, seules les bandes qui tournent, la huitième bouclant sur
la première). L'outil de découpe d'animation de la Terre a été généralisé pour
la prendre — même détourage magenta, même boîte commune à toute la rangée.

⚠️ Une largeur de planche n'est pas toujours divisible par son nombre d'images
(1774 pour huit). Le découpage se fait donc par ARRONDI sur la largeur totale et
non par une taille de case fixe : à un pixel près par colonne, l'écart
s'accumule et la dernière image sort décalée.

Le reste du mouvement accompagne le tour : le corps respire en largeur, les
débris happés tournent autour de la base, et la colonne GLISSE d'une case à
l'autre au lieu d'y sauter — sans quoi l'œil perd ce qu'elle emporte.

⚠️ **La colonne de téléportation de l'Air était COUPÉE EN DEUX** — signalé par
l'utilisateur. La boîte de découpe s'arrêtait à x=900 alors que le cercle
magique au sol va jusqu'à 960 : le mage se téléportait dans une demi-colonne
tranchée net. Refaite (804 → 962 ; la colonne voisine, celle AVEC la
silhouette, commence à 965). Les six autres mages ont été vérifiés à la même
occasion : ils sont entiers, l'Air était le seul cassé.

**GRAND SOUFFLE — il projette, et le MUR fait le reste.** Il s'appelait
« Bourrasque », comme le TRAIT élémentaire de l'Air : le joueur lisait le même
mot à deux endroits pour deux choses différentes. Et il annonçait « balaie le
couloir » en ne balayant rien.

Tout ce qui entoure le mage part maintenant de quatre cases, et ce qui PERCUTE
UNE PAROI avant d'avoir fini sa course encaisse le choc. **Le labyrinthe devient
l'arme** : souffler dans un couloir ouvert déplace, souffler contre un
cul-de-sac tue. Le même bouton donne deux résultats selon l'endroit où l'on se
tient — c'est ce qui fait un sort qu'on apprend à jouer.

Il complète la Tornade au lieu de la doubler : elle EMMÈNE (linéaire, longue,
elle range les poursuivants ailleurs), il ÉCARTE (radial, instantané, il dégage
un corps-à-corps). Un test refuse que l'un se mette à faire l'autre.

⚠️ **Le test a trouvé un cumul que je n'avais pas vu** : le trait de l'Air
pousse de deux cases, et il se déclenchait PAR-DESSUS la projection du sort. La
course réelle dépassait donc celle qu'annonce le sort, et le calcul du choc
contre la pierre — « a-t-elle parcouru moins que prévu ? » — se faisait de
travers. Un sort qui pousse ne déclenche plus la poussée de son élément, comme
la Chaîne d'éclairs ne déclenche pas l'arc de la Foudre. `_apply_area` a reçu le
drapeau qui manquait.

⚠️ **Et une épreuve du feu qui ne prouvait rien** (la quatrième de la série) :
elle ne vérifiait la règle du mur que SI le hasard du labyrinthe avait bloqué
la course — ce qu'il n'avait pas fait. Sabotée, elle passait. Le cas est
désormais FABRIQUÉ : on cherche un cul-de-sac dans la grille, on place le mage à
son entrée et la créature au fond. Sabotée, l'épreuve rapporte « plaquée sans
issue, elle n'encaisse que 18 au lieu de 32 ».

**Le rendu a été refait sur retour de l'utilisateur.** La première version
traçait ses anneaux en code : un rond pâle qui ne disait ni la direction ni la
force, avec par-dessus l'éclat générique — lequel plantait une tornade
TOURNOYANTE au centre du mage, là où le sort chasse vers l'extérieur.

Une planche a été commandée (`wind_blast.png`, deux rangées de six images) :
un CÔNE qui souffle vers la droite, pointe à gauche, et une ONDE concentrique.
Le cône est posé pointe sur le mage et orienté par son regard ; l'onde reste
centrée et ne pivote JAMAIS. Les deux jouent ensemble, l'onde une fraction de
seconde après le cône — sinon elles se confondent en une seule tache.

S'y ajoutent une SECOUSSE brève (0,32 s, bien plus faible que le Séisme : le
seul sort qui projette doit faire encaisser la caméra) et l'ÉCLAT BLANC sec au
point de choc — c'est lui, et lui seul, qui apprend au joueur que la pierre
fait mal.

⚠️ **Le bloc d'affichage a d'abord atterri dans la MAUVAISE FONCTION.**
`_on_projectile_hit` et `_on_blast_fired` se terminent toutes deux par le même
`if ability.shockwave:` — l'ancre choisie pour l'insertion. Le Grand souffle
n'étant pas un projectile, rien ne s'affichait, et rien ne criait non plus :
le code était parfaitement valide. Trois captures ont été perdues à chercher
un bug de rendu qui n'existait pas. *Une ancre d'édition doit être unique dans
le fichier, pas seulement plausible.*

⚠️ **Et un vrai bug trouvé au passage** : les tableaux d'images du Level ne
sont pas vidés avant d'être remplis, et le chargement des textures est refait à
chaque niveau. Mesuré : douze images de cône au lieu de six, donc une animation
qui joue deux fois trop vite dès le deuxième niveau. Quatre tableaux étaient
concernés (cône, onde, tornade, gerbes).

Deux réglages de taille : à deux fois le rayon, l'onde avalait le quart de
l'écran ; et l'additif d'un dessin déjà blanc SATURE — à pleine opacité, le
souffle devenait une tache où l'on ne distinguait plus ni les volutes ni le
mage.

### 2026-08-25 — le MAGE DE LA TERRE

**PICS DE TERRE — la gerbe COURT DANS LE COULOIR.** C'était un souffle
circulaire autour du mage : la même mécanique que trois autres sorts du jeu,
dessinée avec l'éclat générique. La Terre n'avait aucun geste à elle.

Elle part maintenant de ses pieds et file droit devant, **virages du couloir
compris**, en frappant tout ce qu'elle croise — c'est le pilier de la Terre, la
LIGNE, là où la Foudre a la chaîne et le Feu ses placements. Nouvelle forme
`Ability.Kind.LINE`.

La gerbe suit le couloir tant qu'il n'y a **qu'une seule façon de continuer**. À
une intersection elle s'arrête : au-delà, « tout droit » ne veut plus rien dire,
et une gerbe qui choisirait sa route à la place du joueur serait un sort qu'on
ne peut pas viser.

Second temps, celui qui en fait un sort de Terre : **les pointes restent
plantées 4 s** et mordent ce qui passe dessus. Elles sont implémentées comme des
ZONES d'une seule case — le mécanisme existe, il est éprouvé, il sait déjà
mordre par seconde, ralentir et expirer. Écrire un second système qui ferait la
même chose aurait été deux fois le code et deux fois les bugs.

**Les pics étaient DÉJÀ DESSINÉS**, en trois tailles, pendant que le sort
s'affichait en rond générique. Même histoire que les nuages de la Foudre. La
gerbe jaillit avec un dépassement (elle sort trop haut d'un dixième puis se
pose — sans quoi elle monte comme un ascenseur) et soulève une motte de terre :
une pierre qui perce le sol sans remuer un grain de poussière n'a aucun poids.

⚠️ **Une épreuve du feu qui n'a rien prouvé.** Le test « la gerbe ne frappe
qu'une fois » posait une créature IMMOBILE — or une créature immobile n'est de
toute façon à portée que d'une seule case du chemin. Sabotée, la mémoire des
touchés n'a fait crier personne. Réécrit : la créature RECULE désormais au
rythme de la gerbe, le seul cas où cette mémoire compte. Le sabotage donne
maintenant « la créature encaisse 165 pour une gerbe à 30 ».

Leçon générale : *une épreuve du feu qui ne crie pas ne prouve pas que le code
est bon — elle prouve que l'épreuve est mauvaise.*

**ÉGIDE DE PIERRE — le Mur de pierre est remplacé.** Le mur marchait, mais il
était INVISIBLE : la case qu'il dressait était rendue comme n'importe quel mur
du labyrinthe, donc le joueur ne pouvait ni reconnaître le sien, ni savoir quand
il tomberait. Et la Terre venait de recevoir son sort de terrain avec les Pics :
deux sorts de couloir sur trois, c'était un mage à une seule idée.

Il a désormais le seul RÉPIT du jeu. La distinction avec le bouclier de l'Eau
est le cœur du sort : celui de l'Eau est une **réserve** (45 dégâts absorbés,
il tombe quand il est vidé), celui-ci est un **temps** (rien ne l'entame
pendant 30 s, quoi qu'il traverse). Un test refuse que les deux se confondent.

L'immunité est posée sur la SANTÉ et non au point de contact avec un ennemi :
un mage intouchable doit l'être pour tout ce qui blesse, y compris ce qu'on
ajoutera demain. La règle n'a ainsi qu'un seul endroit où mentir.

⚠️ **Trente secondes, c'est énorme** — demandé, assumé, et payé par la recharge
la plus longue du jeu : 60 s. Un test interdit que la recharge descende sous la
durée, ce qui rendrait l'immunité permanente sans que rien ne le signale.

**L'égide se VOIT, en deux temps.** Une immunité est comme un bonus de dégâts :
la seule chose d'un jeu d'action qu'on ne peut pas voir. La coque de pierre
paraît d'abord — c'est le geste — puis se disperse en cailloux et en étoiles
vertes qui tournent autour de son torse tant qu'il est intouchable. Une coque
immobile plantée devant lui l'aurait caché trente secondes durant, et n'aurait
rien dit du temps qui reste ; l'orbite, elle, s'accélère et se resserre dans les
quatre dernières secondes.

⚠️ Deux corrections signalées par l'utilisateur : la coque était **coupée à
gauche et en bas** (boîte à 1388 alors que la pierre commence à 1375), et elle
EFFAÇAIT le mage à pleine opacité. Recoupée au quadrillage, et ramenée à 42 %
d'opacité : ce qui compte est de reconnaître le mage protégé, pas d'admirer la
pierre.

**ÉCLATS DE CRISTAL — une FAILLE qui surgit, loin devant.** Le sort mentait
deux fois : il annonçait « trois éclats » et en tirait UN, et ce coup-là (14
dégâts toutes les 8 s) était *strictement moins bon que son attaque de base*
(23 toutes les 0,7 s). Un bouton qu'aucun joueur n'avait de raison d'appuyer.

Il est passé par trois concepts avant de se fixer, tous essayés en jeu :

1. **un cristal PLANTÉ qui tire tout seul** (forme `TURRET`) — refusé : le
   cristal restait en arrière et le mage le plus lent du jeu ne peut pas
   revenir le chercher ;
2. **le même, qui SUIT le mage** — refusé : c'était l'Orage de la Foudre en
   vert, ce que j'avais signalé avant de le faire ;
3. **des pierres en orbite qu'il LANCE une par une** — refusé aussi : le
   concept ne portait pas, malgré trois passes sur la taille des projectiles.

**La forme retenue tient les deux moitiés ensemble** — c'est la quatrième, et
elle réconcilie tout ce qui précède : *l'orbe de pierre s'installe autour du
mage, et le BALAYAGE part tout seul dès qu'une créature entre à portée.*

L'orbe est celui de la troisième version (les éclats en orbite, comme ceux de
l'Égide) ; le balayage est la faille de cristal et de roche. Le mage ne vise
rien : il pose le sort sur lui et va faire autre chose pendant qu'il travaille —
ce qui convient au plus lent des sept.

La faille elle-même est la LIGNE des Pics de terre, à une différence près : elle
se lève D'UN COUP au lieu de courir. Le même geste à deux vitesses donne deux
sorts qui ne se confondent pas — l'un se VISE, devant soi, et tient le terrain ;
l'autre se DÉCLENCHE seul, vers ce qui approche.

Une vitesse de **zéro** dit « simultané » dans le catalogue. C'est une valeur
qui se lit, là où un seuil en secondes aurait été un chiffre magique de plus.
La boucle d'entretien a dû être corrigée au passage : elle avançait d'UNE case
par image, ce qui étalait une faille de dix cases sur un sixième de seconde.
Elle consomme désormais le temps écoulé — ce qui rend aussi la cadence des Pics
indépendante du framerate.

**Une planche d'animation a été commandée pour l'occasion** (prompt donné à
l'utilisateur, rendu par ChatGPT) : `earth_spikes_anim.png`, deux rangées de six
images — cristal vert et roche brune — la fissure, la percée, la montée, la
pleine hauteur, l'éclat, l'affaissement. Découpée par `tools/build_spike_anim.py`.

⚠️ **Le point délicat du découpage est l'ALIGNEMENT.** Recadrée sur son contenu,
la première image (une fissure large et basse) et la quatrième (une gerbe haute
et étroite) n'ont ni la même taille ni le même centre : jouées à la suite, les
pics SAUTENT. Le découpage calcule donc une boîte COMMUNE à toute la rangée et y
taille les six. Un peu plus de pixels, une animation qui tient debout.

Les deux matières alternent selon la case (`(x + y) % 2`), donc d'une case à la
suivante le long du balayage : deux gerbes identiques côte à côte se liraient
comme une image copiée-collée.

⚠️ **La durée des gerbes a dû être séparée de celle du sort.** Les deux se
lisaient dans le même champ, ce qui allait tant que la ligne était lancée à la
main — mais un orbe qui tient trente secondes aurait laissé trente secondes de
pierres derrière chaque balayage, et le couloir ne se serait plus jamais
rouvert. `spike_life` porte désormais la durée des gerbes ; à zéro, elles durent
le temps du sort, comme avant.

Le kit de la Terre tient enfin : les Pics hérissent le couloir devant soi et
tiennent le terrain, la Faille frappe loin et d'un coup, l'Égide protège le
mage. Trois gestes, trois portées, aucun doublon.

Un test refuse explicitement que les deux lignes se confondent — même portée,
même vitesse ou même durée de gerbes font échouer la suite.

**SÉISME — cinq secondes de tremblement, et les parois cèdent.** L'ultime était
une détonation circulaire de plus : `BLAST`, 120 dégâts, rayon 5.

Trois choses le composent désormais :

1. **La caméra tremble**, fort puis de moins en moins. Amplitude ET fréquence
   décroissent ensemble : la première seconde est une secousse serrée et
   violente, la dernière un balancement lourd. Faire décroître la seule
   amplitude donne une vibration régulière qui s'éteint — ça se lit comme un
   moteur qu'on arrête, pas comme un séisme. Le décalage est appliqué à la
   caméra APRÈS le suivi du mage, jamais à sa cible : sinon le lissage de la
   caméra avale la secousse et il ne reste qu'un flottement.
2. **Des pans cèdent par vagues de trois**, et la cadence s'emballe puis se
   calme — avalanche d'abord, grondement ensuite. Chaque éboulement fait tomber
   des blocs, monter de la poussière, et JAILLIR la pierre : la même planche
   animée que la Faille, ce qui donne au mage une signature d'un bout à l'autre
   de son kit.
3. **Le tremblement lui-même blesse**, partout, tant qu'il dure.

⚠️ **Deux erreurs de conception, toutes deux prises par la mesure.**

La première version faisait céder les pans AU PIED DES MURS, avec un commentaire
qui promettait qu'y longer une paroi serait dangereux et tenir un carrefour
sûr. Mesuré : **97 à 99 % des cases d'un labyrinthe touchent un mur**. La règle
était décorative et le commentaire, faux. Retirée.

La seconde est plus grave : sans le point 3, l'ultime était un SPECTACLE.
Mesuré : vingt-sept éboulements tirés au sort sur six cents cases ne touchent
une créature donnée qu'une fois sur cinq — l'épreuve du feu l'a montrée en
posant une proie à douze pas, qui traversait tout le séisme sans une
égratignure. Le tremblement fait maintenant sept dégâts par seconde à tout ce
qui tient debout : les pans restent la grosse frappe locale et aléatoire, la
secousse est le fond continu qui n'épargne personne.

⚠️ **Et une épreuve du feu qui ne prouvait rien**, la troisième de cette
séance : « plus de pans au début qu'à la fin » passait même à cadence
CONSTANTE, parce que la toute première vague part à l'instant zéro et fait
pencher la moitié initiale. L'épreuve exige désormais un tiers d'écart, que
seule une vraie décélération produit — sabotée, elle rapporte « 15 pans contre
12 : le séisme ne se calme pas assez ».

Ce qui le sépare de l'Embrasement du Feu n'est donc pas l'endroit où ça tombe,
mais la TEXTURE : le Feu lâche quatorze météores lourdes à cadence égale, la
Terre fait crouler des pans qui s'espacent, sur un fond de secousse continue.

**Code laissé en place** : la forme `TURRET` et ses rendus (`stone_orbit.gd`,
`thrown_stone.gd`, `crystal_turret.gd`, `thrown_glow.gdshader`) ne sont plus
employés par aucun mage. Le projet n'est pas sous git : on ne supprime pas ce
qui a coûté trois itérations avant d'être sûr que personne n'en veut. À jeter
d'un bloc le jour où ce sera décidé.

`Ability.Kind.WALL` n'est plus employé par aucun mage. Le mécanisme reste en
place : il servira à qui en aura besoin.

### 2026-08-24 — le MAGE DE LA FOUDRE

**Choisi sur pièces.** L'audit des cinq mages restants a montré que QUATRE
avaient des sorts qui mentent : les « trois éclats » de la Terre en tirent un
seul, la Rune des Ténèbres « explose au premier passage » alors qu'elle
grignote en continu, son Explosion d'ombre « repousse » sans rien repousser —
et la Chaîne d'éclairs de la Foudre était une explosion circulaire. Ce dernier
est le mensonge le plus voyant du catalogue : le nom, la description ET
l'élément annonçaient tous les trois la même chose, et la mécanique faisait
autre chose.

**ORAGE — le nuage SUIT le mage.** C'était une seconde zone posée au sol, qui
aurait fait doublon avec le Champ de foudre. Le raisonnement qui a tranché : un
orage n'est pas un LIEU, c'est un événement qui se DÉPLACE.

Le nuage se lève au-dessus du mage, l'accompagne partout, et foudroie tout seul
l'ennemi le plus proche toutes les 0,9 s pendant douze secondes. C'est la
première chose du jeu qui ACCOMPAGNE le joueur au lieu de l'attendre quelque
part — et elle est faite pour ce personnage précis : le plus rapide et le plus
fragile, celui qui doit rester en mouvement. Le sort le récompense de courir
plutôt que de camper.

Chaque décharge est un coup D'ORIGINE, donc elle déclenche l'arc de l'élément :
l'orage est redoutable au milieu d'un groupe et anodin sur un isolé. Ses dégâts
par décharge sont bas pour cette raison.

Trois promesses testées : la première décharge tombe TOUT DE SUITE (un sort qui
ne fait rien pendant sa première seconde se lit comme un sort raté), la cadence
est régulière, et relancer l'orage le REMET à neuf au lieu d'en ouvrir un
second — deux nuages superposés doubleraient la cadence sans que rien ne le
montre à l'écran.

Le nuage a demandé une passe de correction : à 0,16 de luminosité il se lisait
comme un TROU dans le décor et non comme une masse. Un nuage d'orage est sombre,
mais pas noir — corps relevé, frange claire sur le bord supérieur, et deux crocs
de charge sous le ventre qui annoncent l'éclair une fraction de seconde avant
qu'il ne tombe.

**CHAMP DE FOUDRE — il remplace une SECONDE téléportation.** « Fulgurance »
était un BLINK de cinq cases, et « Éclair fuyant », sa fuite, un BLINK de sept :
deux téléportations dans le même kit, dont l'une strictement inférieure à
l'autre. Le sort n'avait aucune raison d'exister. Un test interdit désormais
d'en avoir deux.

À la place, sa zone — et elle ne ressemble ni au brasier du Feu ni au cercle
glacé de l'Eau, ce que le test vérifie chiffre par chiffre :

    brasier (Feu)   30 s, 6 dég/s, retient 5 s PUIS brûle     -> tenir le terrain
    cercle (Eau)    10 s, 6 dég/s, englue à 35 %              -> ralentir
    champ (Foudre)   8 s, 16 dég/s, paralyse 5 s PENDANT      -> une fenêtre pour frapper

Le champ est rendu par SHADER (`assets/shaders/field.gdshader`) et non par
particules : l'électricité est faite de TRAITS qui relient, pas de grains qui
volent. Des particules donnent des étincelles — jolies, mais elles ne disent pas
« ce sol est sous tension ». Les filaments sont calculés en coordonnées
polaires, chacun avec son propre serpentement tiré de son numéro : sans ce
décalage, les neuf branches ondulent à l'unisson et le champ se lit comme une
roue qui tourne.

Deux réglages trouvés en capture : le halo au sol recouvrait le labyrinthe d'un
aplat jaune (une zone doit marquer un sol, pas le remplacer), et les filaments
prenaient la couleur de l'élément au lieu de tirer vers le BLANC — une décharge
est blanche en son cœur quelle que soit la teinte de son halo, et c'est ce
contraste qui la fait lire comme de l'électricité plutôt que comme une flaque.

**CHAÎNE D'ÉCLAIRS — nouvelle forme `Ability.Kind.CHAIN`.** Elle touche une
cible puis rebondit sur trois voisines en perdant un quart de sa force à chaque
relais. Ça donne au Mage de la Foudre son pilier : le MULTI-CIBLE, là où le Feu
place des coups et où l'Eau entretient des états.

Le parcours est calculé D'UN COUP au lancement, puis joué relais par relais. Le
recalculer à chaque saut aurait laissé les ennemis bouger entre-temps : la
chaîne aurait pu revenir en arrière ou changer d'avis en vol, ce qu'un éclair ne
fait pas.

⚠️ **Le test a trouvé deux bugs que je n'avais pas vus** — 5 arcs pour 3 relais
annoncés, et une créature encaissant 83 dégâts pour un sort à 30. Cause : le
TRAIT élémentaire de la Foudre (l'arc) se déclenchait par-dessus le sort. Un
sort qui chaîne déjà ne doit pas déclencher en plus la chaîne de son élément.

Corriger ça a forcé à SÉPARER deux freins qui n'en faisaient qu'un : jusqu'ici
`with_trait` coupait à la fois le trait élémentaire et l'exaltation. Or le
premier maillon de la chaîne ne doit pas déclencher le trait, MAIS doit profiter
de l'exaltation du joueur. Un seul drapeau ne pouvait pas dire les deux —
`_apply_damage` en a désormais deux, et les trois sites de dégâts DÉRIVÉS
(brûlure, arc, écho) passent explicitement `false, false`.

Épreuves du feu : « la chaîne fait des allers-retours » en retirant la mémoire
des touchés, et « l'exaltation se multiplie sur la brûlure » en rouvrant le
second frein.

**JUGEMENT CÉLESTE — il lève un CIEL, pas une explosion.** L'ultime était une
détonation circulaire de plus : `BLAST`, 140 dégâts, rayon 5,5 — le même sort
que celui de quatre autres mages, repeint en jaune.

Le sort ouvre désormais le ciel. La décharge initiale part comme avant et
traverse les murs, puis DOUZE NUAGES se forment un peu partout dans le
labyrinthe et y restent quinze secondes : chacun foudroie tout seul, toutes les
1,2 s, ce qui passe à moins de quatre cases sous lui.

La différence avec l'Embrasement du Feu tient en une phrase, et un test la
garde : *une météore tombe UNE fois et disparaît, un nuage s'installe et frappe
tant qu'il est là.* L'un est une averse, l'autre un ciel d'orage. Le test refuse
que l'ultime du Feu lève des nuages ou que celui de la Foudre fasse pleuvoir —
sans quoi les deux redeviendraient le même sort en deux couleurs.

Chaque frappe est un coup d'ORIGINE : elle rebondit donc sur les voisins. Le
Jugement est ravageur là où les créatures se pressent, et modeste sur une carte
vide — la même logique que l'Orage, à l'échelle du labyrinthe entier.

**Les nuages étaient DÉJÀ DESSINÉS.** La planche `mage_thunder.png` en
contenait deux depuis le début, éclair compris — un sombre et un bleu allumé —
et le jeu affichait des cercles gris tracés en code à leur place. Ils sont
maintenant découpés (`cloud.png`, `cloud_dark.png`) et le nuage BASCULE de l'un
à l'autre au moment de sa décharge : c'est le dessinateur qui a décidé à quoi
ressemble un nuage qui tonne, pas un multiplicateur de teinte.

Ils flottent, aussi : oscillation lente et balancement, déphasés par leur case.
Sans ce déphasage les douze nuages se balancent à l'unisson et le ciel se lit
comme une seule image répétée ; sans le flottement du tout, ils se lisent comme
du décor collé au sol.

⚠️ **L'`impact.png` de la Foudre était une bouillie bleue de 96×84** — signalé
par l'utilisateur. En quadrillant la planche pour la retrouver, j'ai découvert
les nuages inutilisés au passage. La vraie frappe au sol, avec son anneau, était
là elle aussi.

**L'ATTAQUE DE BASE ÉTAIT UNE ORBE.** Signalé par l'utilisateur : le tir de
base empruntait la bille lumineuse commune aux sept mages, ce qui ne veut rien
dire pour cet élément — *un éclair ne voyage pas, il relie* — et la rendait
indistincte du tir du Feu. Un drapeau de données (`Ability.bolt`) fait
maintenant tracer le tir en TRAIT BRISÉ le long du couloir. Les quatre gestes de
foudre — tir, chaîne, fuite, jugement — se lisent enfin comme une même famille.

⚠️ **Les arcs étaient invisibles en jeu.** Le trait était correct au banc
d'essai et introuvable à l'écran : une case fait 32 pixels, et le cœur du trait
mesurait moins de deux pixels. La Chaîne d'éclairs ne montrait donc que des
impacts au sol, sans le trait qui les explique — depuis le début. Largeurs
triplées, quatre passes au lieu de trois, corps DORÉ et cœur blanc (un trait
uniformément teinté se délave sur le vert du labyrinthe).

La leçon, notée ici parce qu'elle resservira : *un effet correct en isolement
peut être invisible en jeu.* C'est l'image du JEU qui tranche, jamais celle du
banc d'essai.

⚠️ **L'impact de la Foudre était CASSÉ** — signalé par l'utilisateur. Ma boîte
de découpe tranchait le dessin des deux côtés : les pointes commencent à y=352
et la boîte partait de 362 ; la branche droite va jusqu'à x=1372 et la boîte
s'arrêtait à 1352. D'où un buisson bleu étêté. Troisième mesure, au quadrillage
cette fois : (1256, 348) - (1376, 508) prend la décharge entière, anneau au sol
compris. Le blason au foudre voisin est découpé aussi (`crest.png`) et sert de
**signature de l'Extra** : il paraît au lancement de l'ultime, DROIT et
transparent, au-dessus du mage, respire une fois et s'efface en une seconde.
Jamais en rotation — une emblème qui tourne se lit comme un objet ramassable
qui vole, pas comme une signature.

Un ultime coûte quatre éliminations : le joueur doit VOIR qu'il vient de le
dépenser sans avoir à lire le bandeau. Le mécanisme est ouvert aux six autres
mages sans une ligne de code : déposer un `crest.png` dans le dossier d'un
personnage suffit à lui en donner un.

Deux réglages en capture : à 3,2 cases posé sur le mage, le blason lui couvrait
le torse — on voyait l'emblème au lieu de voir le personnage lancer son sort.
Remonté à 1,8 case au-dessus de lui et réduit à 2,6.

⚠️ **Le blason ne remplaçait rien : il s'ajoutait.** L'utilisateur voyait encore
l'ancien dessin d'impact au lancement — à deux endroits. Le souffle de l'ultime
étirait `impact.png` sur ses SIX cases de rayon (un dessin pensé pour marquer
une frappe d'une case y devient une tache), et chacun des douze nuages en posait
un en se formant : douze frappes annoncées avant d'avoir eu lieu.

Les deux sont retirés. L'éclat TRACÉ reste — c'est lui qui dit la portée — et
`impact.png` ne sert plus qu'à ce pour quoi il est dessiné : marquer une frappe
qui vient de tomber.

**Les six vignettes de la Foudre sont posées.** `mage_thunder_skills.png`
découpée : éclair, chaîne, champ, orage, course de foudre, jugement. La planche
suivait cette fois l'ordre demandé — ce qui n'était vrai ni pour le Feu ni pour
l'Eau, donc on relève quand même case par case. Vérifié à l'écran sur les deux
interfaces : barre de bureau et pastilles tactiles.

Elles ont révélé un défaut de mise en page : la vignette prend la place du
texte, et « Chaîne d'éclairs » s'affichait « Chaîne d'écl », coupé en plein mot
par Godot. Le nom se coupe désormais SUR UN MOT, points de suite compris —
« Chaîne… » se lit, « Chaîne d'écl » ressemble à un bug.

Trois mages ont leurs vignettes (Feu, Eau, Foudre) ; cinq attendent la leur
(Terre, Ténèbres, Air, Invocateur, Suprême) et affichent en attendant leurs
boutons en texte seul.

**ÉCLAIR FUYANT — il DEVIENT la foudre.** Sa description le disait depuis
toujours (« il devient foudre le temps d'un battement de cils ») et il empruntait
la traînée douce commune aux sept mages. Un arc électrique est désormais posé
sur chaque tronçon du couloir emprunté : la décharge suit les virages au lieu de
couper à travers les murs.

### 2026-08-24 — le MAGE DE L'EAU

**Trois sorts MENTAIENT sur ce qu'ils font.** Trouvé en lisant son kit avant de
toucher au style, et c'est ce qui comptait le plus — une description fausse est
pire qu'une description absente, le joueur bâtit sa tactique dessus :

    Cercle glacé  « ce qui la traverse s'engluent »  ->  ne ralentissait rien
    Geyser        « et le mage se régénère »          ->  ne soignait rien
    Vague         « balaie le couloir DEVANT »        ->  explosait tout autour

Corrigés : le givre ralentit à 35 % pendant 4 s (bien plus que la trempe de
l'élément, 62 % — c'est SON métier, pas un effet secondaire), le Geyser rend
3 PV, et la Vague reçoit une OUVERTURE de 150°. Ce dernier point change la
façon de la jouer : il faut faire face. En échange elle porte plus loin et
frappe plus fort — viser se paie, donc doit rapporter.

Nouveau champ `Ability.arc`, mesuré à VOL D'OISEAU depuis le lanceur et non le
long des couloirs : le joueur juge « devant » à ce qu'il voit, pas à la
topologie du labyrinthe.

Le signal `enemy_soaked` porte désormais son FACTEUR en plus de sa durée : la
trempe de l'élément et le givre du Cercle glacé ralentissent tous deux, mais
pas d'autant. Sans le facteur, chaque récepteur devait deviner de quel
ralentissement il s'agissait. Le plus fort gagne — un ennemi déjà trempé qui
entre dans un cercle glacé ralentit davantage.

**LES ICÔNES DE L'EAU** (`mage_water_skills.png`). Le générateur n'a PAS
respecté l'ordre du prompt : geyser en troisième au lieu de sixième, bouclier
en quatrième au lieu de troisième. La table de `build_skill_icons.py` relève
donc ce que chaque case MONTRE, jamais ce qu'on avait demandé — c'est noté dans
l'outil pour les six planches à venir.

⚠️ Le dégorgement du magenta a demandé TROIS versions, et les deux premières
étaient de vraies régressions :

  1. ramener le bleu sous le vert sur TOUS les pixels. Invisible sur le feu (une
     flamme orange a déjà b < g), désastreux sur l'eau dont le bleu EST le canal
     dominant : les six icônes viraient au turquoise et le bouclier violet
     devenait ROUGE. Une correction réglée sur un seul élément ne vaut pas pour
     les huit ;
  2. la même chose, limitée aux pixels de teinte magenta. Mieux, mais le dôme du
     bouclier est TRANSLUCIDE — le fond se voit à travers, et ces pixels-là se
     faisaient repeindre au lieu d'être effacés ;
  3. la bonne mesure : la « magenta-ité » d'un pixel, soit ce qu'il a de rouge
     ET de bleu EN PLUS de son vert. Elle vaut 1 sur le fond pur, 0 sur un bleu
     d'eau ou un orange de flamme, et une valeur intermédiaire sur ce qui est
     MÉLANGÉ au fond. On s'en sert deux fois : pour rendre ces pixels d'autant
     plus transparents qu'ils sont magenta — le fond vu à travers le verre
     disparaît au lieu d'être recoloré — et pour retirer la dominante rose de ce
     qui reste. Zéro pixel magenta sur les douze icônes, et le feu inchangé.

**Recharges du Mage de l'Eau resserrées** (2 s / 5 s / 8 s, demandées). Elles
donnent au personnage sa cohérence : c'est celui qui ENTRETIENT ses états —
coque de 30 s, exaltation de 30 s, givre qui tient le terrain. Des recharges
longues l'auraient obligé à choisir lequel entretenir, alors que son fantasme
est de tout tenir à la fois. La Vague à 2 s devient son RYTHME : elle est sa
seule vraie source de dégâts entre deux recharges, le reste de son kit étant
défensif et son attaque ne faisant que 14.

⚠️ Cumulé au reste (bouclier quasi permanent, exaltation tous les 2 kills), ça
fait beaucoup de puissance ajoutée d'un coup. Mesuré plutôt que débattu.

**LA VAGUE VA CHERCHER L'ENNEMI** (défaut signalé). Elle suivait le REGARD du
mage — défaut de conception de ma part : en fuyant, on tourne le dos à ses
poursuivants, et le sort partait donc systématiquement du mauvais côté. Il
fallait s'arrêter et se retourner pour s'en servir, exactement ce qu'un sort
défensif doit éviter. Elle remonte désormais le couloir jusqu'à l'ennemi le
plus proche, comme un projectile, mais en frappant tout ce qu'elle croise. À
défaut de cible, elle part devant : un sort qui refuserait de sortir faute
d'ennemi visible serait un bouton mort.

**LE FRONT PASSE EN SHADER** (`assets/shaders/wave.gdshader`). Trois traits
empilés donnaient une masse, pas une lame : il manquait le PROFIL. Le shader
peint un ventre (plus profonde au centre, elle s'affaisse aux bords), une crête
d'écume quantifiée en paliers — même parti pris « dessin animé » que l'onde de
choc du Feu, pour que les deux éléments appartiennent au même jeu — et un dos
qui s'étale derrière.

⚠️ Blending NORMAL, à l'inverse du feu : de l'eau assombrit et teinte ce qu'elle
recouvre, elle ne l'éclaire pas. C'est ce qui sépare les deux éléments au
premier coup d'œil.

⚠️ Piège d'implémentation : `@onready var blade` n'était PAS résolu au moment où
le Level appelle `setup()` dans la foulée de `add_child()`. La référence était
nulle, la lame ne se dessinait pas du tout — et AUCUNE erreur ne remontait. Le
nœud est désormais récupéré dans `setup()` par `get_node_or_null`.

⚠️ Piège d'ÉPREUVE DU FEU : mon premier sabotage a touché `_cast_projectile` au
lieu de `_cast_wave` — les deux fonctions portent la même ligne
`var target := find_target(...)`, et le remplacement a mordu sur la première.
Neuf tests ont crié, mais aucun ne prouvait ce que je voulais prouver. Un
sabotage doit viser une ligne UNIQUE.

**LA VAGUE DÉFERLE** — nouvelle forme de sort `Ability.Kind.WAVE`.

Trois versions successives, chacune corrigée sur retour :
  1. explosion circulaire autour du mage — la nova du Feu sous un autre nom,
     alors que sa description promettait « balaie le couloir DEVANT » ;
  2. souffle en cône de 150° — plus juste, mais toujours INSTANTANÉ ;
  3. un FRONT qui part du mage et remonte le couloir en frappant ce qu'il
     traverse, sur le principe de la boule de feu.

La différence avec la boule tient en une phrase : **la boule cherche une cible,
la vague prend le couloir.** On ne la place pas sur un ennemi, on l'aligne sur
un passage — et l'ennemi la VOIT venir, ce qui lui laisse une intersection pour
s'écarter. C'est le premier sort du jeu qui récompense la lecture du terrain
plutôt que la visée.

⚠️ Chaque ennemi n'encaisse QU'UNE FOIS par vague. Sans mémoire des touchés, un
ennemi resté dans le couloir prenait un coup PAR CASE traversée — épreuve du
feu : « la vague frappe 2 fois le même ennemi (68 dégâts) ».

La crête est PERPENDICULAIRE à sa course (un mur, pas une boule), en trois
épaisseurs empilées : une seule donnait un trait. Une lueur la précède pour
annoncer l'arrivée du front, et un sillage retombe derrière.

**LE BOUCLIER D'EAU « ne faisait rien »** (signalé par l'utilisateur). Il
faisait quelque chose — il absorbait — mais trois défauts se cumulaient, dont
un VRAI BUG :

  1. **sa durée était ignorée.** Sa fiche annonçait 8 s ; `_cast_shield`
     appelait `health.add_shield()` et rien ne l'expirait jamais. Posé, il
     tenait jusqu'à ce qu'un ennemi touche le mage — éventuellement une partie
     entière. Corrigé, et testé dans les deux sens (il tient sa durée, il tombe
     à l'échéance, il tombe aussi vidé par les coups) ;
  2. **le signal `player_shielded` n'était écouté PAR PERSONNE.** Aucune bulle,
     aucun message, aucune jauge — d'où l'impression qu'il ne se passait rien ;
  3. **rien ne montrait ce qu'il en restait.**

La COQUE suit l'absorption et non le temps : un bouclier vidé en deux coups
disparaît tout de suite, même s'il lui reste vingt secondes au compteur. Elle
bat plus vite dans sa dernière seconde — l'avertissement doit arriver AVANT le
coup qui fait mal. Dans le HUD, l'absorption se dessine PAR-DESSUS la barre de
vie, depuis la droite : c'est de la vie en sursis, pas une seconde jauge.

⚠️ La bulle est en mélange NORMAL et non additif. En additif, un intérieur
plein éclaircit le mage au lieu de le teinter : on obtient un halo blanc qui
efface le personnage, pas une coque qu'on voit à travers. Le bord reste FIN —
une coque épaisse se lit comme un mur, alors qu'elle doit se lire comme une
membrane.

Durée portée à 30 s (demandée) : le bouclier cesse d'être un réflexe d'urgence
pour devenir un état qu'on entretient. C'est cohérent avec l'exaltation du
Geyser, qui dure aussi trente secondes — le Mage de l'Eau devient le
personnage qui joue en ENTRETENANT ses états, là où le Feu joue en plaçant des
coups.

⚠️ Réserve : 30 s de coque pour 12 s de recharge et deux charges, c'est une
protection quasi permanente. Mesuré plutôt que débattu.

**LE GEYSER, ultime en trois temps** (demandé : pluie de 30 s, +10 de dégâts,
colonne de pression, activation à 2 kills).

C'est le premier ultime du jeu qui n'est pas une explosion mais un ÉTAT :
l'Embrasement se joue à l'instant où on l'appuie, le Geyser se joue pendant la
demi-minute qui suit. Ses dégâts immédiats sont donc volontairement plus bas
(70 contre 130) : il paie son coup d'éclat en durée.

⚠️ `empower_bonus` ne s'applique QU'AU COUP D'ORIGINE, jamais aux dégâts
dérivés. Sans cette limite, +10 s'ajouterait à chaque tic de brûlure, à chaque
arc de foudre et à chaque écho : le bonus se MULTIPLIERAIT au lieu de
s'ajouter. Rien ne planterait — les chiffres seraient juste faux, et
l'équilibrage avec. Épreuve du feu : « l'exaltation se multiplie sur la
brûlure : 69 dégâts au total » au lieu de 45.

L'AURA d'exaltation n'est pas décorative : un bonus de dégâts est la seule
chose d'un jeu d'action qu'on ne peut pas voir. Elle monte le long du mage
plutôt que de s'étaler au sol (où elle se serait confondue avec les zones de
sorts), et bat plus vite dans sa dernière seconde — c'est le seul avertissement
avant de perdre le bonus.

**2 kills : troisième exception à la règle de constitution**, argumentée. Un
ÉTAT de 30 s ne vaut que s'il revient assez souvent pour qu'on construise sa
partie autour ; à cinq kills, le Mage de l'Eau l'aurait vu deux fois par niveau
et n'en aurait rien tiré. C'est le mage qui joue AVEC son ultime, là où les
autres jouent POUR.

⚠️ Réserve exprimée avant de le faire : 30 s d'exaltation tous les 2 kills, ça
peut être permanent, et +10 sur une attaque à 14 dégâts fait +71 %. Appliqué
comme demandé, puis mesuré.

### 2026-08-24 — le Mage du Feu, sort par sort (retours de l'utilisateur)

**« La boule de feu ressemble à l'attaque de base. »** Vrai, et la cause était
structurelle : les deux sont des `PROJECTILE`, et le `Level` donnait la MÊME
texture d'orbe à tous les projectiles d'un personnage. C'était littéralement le
même sprite. La signature visuelle — taille, vitesse, traînée, onde de choc —
appartient désormais à la COMPÉTENCE (`Ability.projectile_scale`,
`projectile_speed`, `trail_density`, `shockwave`).

**« Sa portée est trop loin. »** Vrai aussi, et pire que l'impression : attaque
8 cases, boule de feu 11. Le sort le plus puissant du mage portait PLUS LOIN que
son attaque de base — il se jouait en sniper, sans risque. Portée ramenée à 7,
soit MOINS que l'attaque : pour la placer, il faut avancer. En échange, 42
dégâts (contre 30), rayon 2,6, recharge 5 s, et un projectile deux fois plus
gros qui vole deux fois moins vite — ce dernier point est du gameplay, la
simulation le voit comme le joueur.

**Sur les extensions Godot** (question posée) : déconseillées ici. Le renderer
est `gl_compatibility` — obligatoire pour couvrir iOS, Web et desktop d'un seul
code — et beaucoup d'addons VFX supposent Forward+. Le natif suffit : shader +
particules. Les particules sont en CPUParticles2D et non GPU, pour la même
raison de compatibilité mobile.

**L'onde de choc** (`assets/shaders/shockwave.gdshader`) : anneau quantifié en
trois paliers nets — le rendu « cartoon » demandé — sans aucune lecture d'écran
(SCREEN_TEXTURE se comporte mal en gl_compatibility sur mobile). Deux réglages
trouvés à la capture, pas à la lecture du code : l'onde à pleine opacité NOYAIT
le labyrinthe (ramenée à 50 %), et le dessin d'impact de l'ultime s'affichait
sur huit cases de large et effaçait le mage — plafonné à 3,4 cases. Un gros
sort a un gros ANNEAU, pas une grosse tache.

**L'Aura ardente devient un BRASIER PIÈGE** (30 s, demandé) : ce qui entre est
cloué 5 s, puis repart en brûlant 3 s. Ce n'est plus un sort de combat mais un
sort de TERRAIN — on ferme un couloir, on cueille ce qui sort d'un repaire.
Recharge la plus longue du mage (34 s) et dégâts par seconde volontairement bas :
ce qui fait mal est l'immobilisation, pas la nappe. Additionner les deux
donnerait une exécution garantie à chaque passage.

⚠️ Le piège s'applique UNE FOIS par créature et par passage, jamais par tick.
Sans ce verrou, une zone qui tique deux fois par seconde pendant trente secondes
reprend sa victime à chaque tick : elle ne repart JAMAIS. Le test le vérifie
dans les deux sens (une seule prise en 6 s, mais reprise possible passé le
verrou) — épreuve du feu : « le piège se réarme : 12 immobilisations en 6 s
(prison à vie) ».

**Différenciation des deux zones du Feu** (demandée : « c'est pareil »). La
distinction passe par la FORME, pas par la couleur — une teinte se remarque
moins qu'une silhouette :

    nappe    elle S'ÉTALE : flammes basses et couchées (dispersion 96°), rouge
             sombre, cercle ÉCRASÉ à l'horizontale — une flaque vue de dessus
    brasier  il TIENT : colonne haute et resserrée (12°), cœur blanc-or, disque
             plein, et un ANNEAU DE MORSURE cerné de crocs

L'anneau de morsure n'est pas décoratif : c'est une information de jeu. Un
brasier qui cloue cinq secondes doit dire OÙ il mord, sinon le joueur le frôle,
se fait prendre, et ne comprend pas pourquoi. Les flammes, larges et floues, ne
peuvent pas porter cette limite ; un trait net, si. Il bat plus vite que la zone
(un bord immobile se lit comme un décor) et ses crocs pointent vers l'INTÉRIEUR,
pour dire le sens de la menace.

**Recharges resserrées** (2 s pour la nappe, 7 s pour le brasier — demandées).
⚠️ Réserve exprimée avant de le faire : cinq charges de 30 s rechargées toutes
les 7 s permettent une dizaine de brasiers vivants en permanence. Appliqué comme
demandé, puis MESURÉ — c'est aux chiffres de trancher, pas à l'intuition.

Refus argumenté : cinq charges pour la nappe aussi. Ce serait refaire les deux
sorts jumeaux qu'on venait de séparer. Leurs métiers doivent différer — la
nappe est réactive (2 s, on la jette en courant), le brasier stratégique.

**Le panache de la boule de feu** : un cône de flammes qui pointe toujours à
l'opposé du vol. Le triangle vient de la DISPERSION, pas d'une forme d'émission :
une forme triangulaire aurait donné un panneau rigide qui pivote, alors que là
il se déforme dans les virages. Deux réglages trouvés en capture — le panache
saturait en BLANC PUR (une trentaine de blobs additifs qui se chevauchent) et
formait une boule sans forme : moins de flammes, plus pâles, et surtout des
vitesses très étalées (0,15 à 2,2 cases/s) — c'est l'écart de vitesse qui creuse
le triangle, à vitesse égale toutes les flammes restent sur un même arc.

Les trois émetteurs de feu du jeu (brasier, panache, explosion) partagent
désormais une seule fabrique, `FxTextures` : trois copies du même réglage
auraient dérivé l'une de l'autre.

**LES ICÔNES DE SORTS** (`assets/peso&cover/mage_fire_skills.png`, commandée sur
un prompt fourni à l'utilisateur). `tools/build_skill_icons.py` découpe la
grille 3 × 2 et détoure le fond.

Deux choix qui ont fait la différence :
- **fond magenta uni plutôt que transparence** : les modèles d'image tiennent
  mal l'alpha, un aplat magenta se détoure au pixel près, et aucune palette de
  feu ne contient de magenta ;
- **détourage par TEINTE et non par distance RGB** : une flamme porte des halos
  roses très proches du magenta en distance brute, et une clé par distance
  grignotait le feu. La teinte sépare nettement 300° de l'orange.

Deux corrections mesurées, pas devinées :
- la première version ne retirait que le fond RELIÉ AU BORD, par prudence
  (« un reflet magenta au cœur d'une flamme appartient au dessin »). Mesuré :
  l'anneau de l'Aura ardente gardait **10 % de pixels à (255, 11, 163)**,
  c'est-à-dire du fond pur vu à travers les flammes. Tout le magenta part
  désormais, enclavé compris — il en reste 0,00 % ;
- **anti-frange** : les bords des flammes se mélangeaient au fond et
  ressortaient violacés — pas assez magenta pour être découpés, assez pour se
  voir. Le bleu est ramené sous le vert : une flamme orange a déjà b < g et ne
  bouge pas, une frange magenta a b > g et retombe.

L'icône est mise à l'échelle sur sa DIAGONALE et non sur son côté : le pad
tactile affiche des boutons ronds, et une icône large calée sur le carré sort
du cercle. Elle occupe donc le carré inscrit (70 %).

`UiIcons.for_ability()` les cherche par identifiant de sort, avec cache — la
barre se redessine à chaque frame, un `load()` par bouton ferait des centaines
d'accès disque par seconde. Un personnage SANS planche garde les pastilles
colorées d'avant : les mages peuvent être habillés un par un, au rythme où les
planches arrivent.

**Le seuil d'ultime suit la CONSTITUTION** (demandé : le Feu à 4 kills, et que
chacun ait le sien). Six personnages sur huit exigeaient cinq kills : le
compteur ne disait donc rien de celui qu'on jouait. La règle retenue —
`kills = constitution + 1` — lie le seuil à la fragilité : un mage qui encaisse
peu atteint son ultime plus tôt, parce qu'il ne peut pas se permettre un long
combat ; un mage robuste le paie plus cher, parce qu'il a les moyens d'attendre.

    Feu, Ténèbres, Foudre (3 PV)  ->  4 kills
    Eau, Air (4 PV)               ->  5 kills
    Terre (5 PV)                  ->  6 kills
    Suprême  8 — son ultime est le plus puissant du jeu
    Invocateur 6 — ses kills viennent de ses invocations, donc plus régulièrement

Le test vérifie la règle, les deux exceptions, ET que les seuils prennent au
moins trois valeurs distinctes : une règle qui rendrait tout le monde égal nous
ramènerait au point de départ sans qu'aucun test ne s'en aperçoive.

**La fiche de personnage documente enfin tout.** Il y manquait la FUITE — l'un
des six boutons de la barre — et le seuil d'ultime, qui varie désormais d'un
personnage à l'autre. `Ability.summary()` mentionne maintenant les
PARTICULARITÉS après les chiffres : charges, piège, traversée des murs, pluie de
météores. Deux sorts à « 30 dégâts · rayon 2 » ne se jouent pas pareil si l'un
cloue sur place et l'autre non ; un résumé muet là-dessus laisse choisir à
l'aveugle.

Les DESCRIPTIONS s'affichent sous chaque sort quand la fiche est assez haute
(`card_room > 300`), et se retirent sinon — même règle adaptative que le reste
de l'écran. Vérifié en 900×760 et en 844×390.

⚠️ `summary()` a été scindé en deux (`summary` / `_base_summary`) plutôt que
réécrit : la session voisine y ajoutait le cas des INVOCATIONS pendant ce
travail, et le tableau des formes lui appartient.

**EMBRASEMENT — l'ultime volcanique.** Demandé : une explosion de volcan qui
traverse les murs, plus une pluie de météores au hasard sur toute la carte.

Deux PRIVILÈGES qu'aucun autre sort du jeu n'a, et c'est délibéré :

  1. **le souffle traverse les haies.** Partout ailleurs, les dégâts de zone se
     mesurent en distance de CHEMIN — une explosion qui passerait à travers un
     mur serait incompréhensible dans un labyrinthe. L'ultime mesure à vol
     d'oiseau. C'est une entorse assumée à une règle fondatrice : un ultime doit
     être la seule chose contre laquelle un mur ne protège pas. La condition
     n'est pas négociable — que ça SE VOIE, d'où l'onde de choc géante qui
     balaye l'écran par-dessus le labyrinthe. Sans elle, le joueur croirait à
     un bug plutôt qu'à une règle ;
  2. **une pluie de 14 météores** tombe au hasard sur les cases praticables
     pendant 2,5 s. Elles ne visent pas : c'est du chaos, et c'est ce qui la
     rend volcanique plutôt que chirurgicale. Elles ne touchent QUE les
     ennemis — une pluie qui blesserait le lanceur ferait de l'ultime un pari,
     alors qu'il se mérite en cinq kills.

Le MARQUEUR AU SOL de chaque météore est le vrai travail. Un rocher qui apparaît
et explose n'est pas un événement, c'est un dégât inexpliqué : le joueur voit une
barre de vie tomber sans savoir d'où ça vient. Le cercle qui se resserre pendant
la chute dit trois choses d'un coup — quelque chose arrive, ça tombera LÀ, et
dans combien de temps. Le signal part donc À L'AVANCE (`meteor_incoming`), le
dégât suit à l'échéance.

⚠️ La pluie tire au sort ses cases, donc `CombatSystem` a désormais une GRAINE,
alimentée par celle du niveau. Sans elle, la simulation d'équilibrage mesurerait
un ultime différent à chaque partie et deux captures du même sort ne se
compareraient plus.

Le test protège les deux exceptions — y compris en vérifiant qu'AUCUN sort
ordinaire des huit personnages ne les a acquises au passage. Une exception qui
déborde ne planterait rien : elle rendrait toutes les haies inutiles sans que
personne ne le remarque. Épreuve du feu : « le souffle de l'ultime ne passe pas
la haie » et « les météores tombent en 0,0 s : c'est un bloc, pas une pluie ».

**BRAISE FUYANTE — le sort de fuite.** Son propre texte disait déjà ce qu'il
fallait faire : « le mage se disperse en braises et se reforme plus loin ». Il
ne dispersait rien — deux colonnes identiques aux deux bouts et un fondu, ce qui
racontait « il était là, il est ici », pas « il s'est défait, il s'est refait ».
Trois pièces ajoutées :

  - au DÉPART, les braises éclatent vers l'extérieur ;
  - à l'ARRIVÉE, elles CONVERGENT — accélération radiale négative, les
    particules naissent en cercle et tombent vers le point de reformation.
    C'est le seul moyen d'obtenir une convergence avec un émetteur qui, par
    nature, projette vers l'extérieur ;
  - entre les deux, une TRAÎNÉE le long du trajet (`WarpTrail`, une position
    d'émission par case traversée).

La traînée est la pièce qui compte. Sans elle, le joueur voit deux événements
sans rapport et perd son propre personnage sur un écran chargé ; elle dit par où
il est passé, donc qu'il s'agit bien de lui. Elle a demandé un renforcement
après capture : deux fois trop maigre, elle se perdait dans les feuillages et on
ne la distinguait plus des champignons du sol.

L'effet est GÉNÉRIQUE et teinté par l'élément : les sept mages ont tous une
translation, et chacun laisse sa couleur — braises orange pour le Feu, traînée
violette pour le Pas de l'ombre, blanche pour la Rafale.

**La comète volait À RECULONS.** Défaut signalé par l'utilisateur, invisible sur
toutes mes captures : la boule de feu ne se voyait de travers qu'en tirant vers
la DROITE, et mes captures la montraient volant vers le haut. La comète de la
planche pointe déjà vers la droite — c'est-à-dire vers le zéro de rotation de
Godot — et mon retournement la mettait tête en arrière. Le `flip` a sauté.

⚠️ Leçon d'outillage : une erreur d'orientation ne se voit que dans UNE
direction. Capturer un tir suffit à croire que c'est bon.

**L'explosion refaite.** Elle tenait en deux images, et ce qu'on y voyait
surtout, c'étaient les particules géométriques de l'ImpactEffect — des losanges
jaunes qui se lisaient comme des confettis posés sur le feu. Trois changements :

  - un impact À FLAMMES ne dessine plus ses polygones du tout : quand il y a du
    vrai feu, les formes tracées le concurrencent au lieu de l'habiller ;
  - trois émetteurs au lieu d'un — le CŒUR (dense, explosif, 0,34 s : le
    flash), les PROJECTIONS (qui fusent loin et retombent : l'éclaboussure) et
    la FUMÉE (lente, sombre, elle monte et grossit) ;
  - la durée double pour les sorts à flammes. À 0,55 s, tout était fini avant
    d'être vu.

C'est la FUMÉE qui fait la différence : elle survit au feu et donne un APRÈS à
l'explosion. Sans elle, le feu s'éteint et il ne s'est rien passé. Elle est en
blending NORMAL et non additif — une fumée additive éclaircit le décor au lieu
de le masquer, et cesse d'être de la fumée.

**Cinq charges pour le brasier** (demandé après essai) : `Ability.charges`.
Le sort part cinq fois d'affilée, puis la recharge court — et elle rend TOUTES
les charges d'un coup. Cinq petites recharges séparées donneraient un
goutte-à-goutte qu'on ne peut pas planifier, alors qu'un plein d'un coup se
joue : on installe un dispositif, on garde la dernière en réserve.

Deux détails qui ne se voient qu'en jouant :
- un délai de 0,35 s entre deux charges. Sur téléphone, une pression un peu
  longue est lue comme deux appuis, et sans ce garde-fou le joueur viderait
  deux charges sur la même case sans l'avoir voulu ;
- tant qu'il reste une charge, le sort est PRÊT — sa recharge ne court qu'à
  partir de la dernière. C'est ce qui distingue un sort à charges d'un sort à
  recharge courte.

Les charges s'AFFICHENT, sous deux formes selon l'écran : « 4/5 » en chiffres
sur la barre du clavier, et cinq pastilles en arc autour du bouton tactile —
sur un bouton de 33 px sous un pouce, un ratio est illisible alors qu'on compte
trois points d'un coup d'œil. Sans compteur, le joueur découvrirait la recharge
par surprise.

Les flammes ont demandé trois passes, chacune corrigeant un défaut visible en
capture : des points d'un pixel (sans texture, CPUParticles2D dessine des
carrés durs — il leur faut un blob en dégradé radial), puis des lumières
isolées (le nombre suit désormais l'AIRE et non le rayon : à densité constante,
un brasier deux fois plus large paraissait deux fois plus clairsemé).

### 2026-08-24 — nuit : la page DÉMO, et la revue des monuments

**Le mode démo.** Troisième bouton sur la sélection des mages : « DÉMO » lance
le TERRAIN D'ESSAI — un petit labyrinthe ouvert (moitié des culs-de-sac
supprimés), trois cibles lentes et myopes mais coriaces (spectre, gobelin,
golem : de quoi voir une brûlure ticker), tous les sorts débloqués, l'ultime
chargé d'office, 100 PV. La progression y est FICTIVE et incapable d'écrire sur
le disque ; quitter l'essai ramène à la sélection, pas à l'accueil — on était
en train de choisir son mage, on y retourne. `LevelConfig.demo()`,
`GameManager.demo`, `GameFlow.start_game(demo)`. Raccourci dev : `--demo`.

**Sorts ILLIMITÉS en démo** (demandé après essai, pour pouvoir donner des
retours) : `CombatSystem.free_use`, posé par le `Level` depuis `config.is_demo`.
Ni recharge, ni ultime dépensé. Une conséquence n'était pas prévue et le test
l'a attrapée : la règle « une cible déjà visée n'est pas re-visée » rendait le
bouton MORT dès qu'une orbe était en l'air — le joueur appuyait, rien ne
partait. Elle saute aussi en démo : elle protège d'un tir gaspillé pendant la
recharge, et sans recharge il n'y a rien à gaspiller.

Le test couvre les DEUX moitiés (démo sans recharge, campagne avec) : un
drapeau qui débraye les recharges partout viderait le jeu de sa gestion des
sorts sans qu'aucune partie ne plante pour le signaler. Épreuve du feu passée —
trois échecs quand `free_use` vaut vrai partout.

**La revue des monuments** (signalée par l'utilisateur : découpage cassé).
Constats sur fond violet, stage par stage : tours TRONQUÉES (le temple de
foudre décapité, le phare coupé en deux, le château amputé de sa droite) et
fonds de scène peinte gardés en rectangle (la clairière du 1, la jungle du 7).
Corrections :
- boîtes élargies sur les dix stages — plus une seule troncature ;
- clé de fond à QUATRE références (une par côté) : un ciel en dégradé n'a pas
  la même couleur en haut qu'en bas, la médiane unique laissait des coins ;
- FONDU DE BORDURE de 14 px dans tous les cas : là où aucune clé ne peut
  détourer une forêt peinte, la découpe s'éteint en vignette au lieu de poser
  un rectangle à bords droits au milieu du labyrinthe.

### 2026-08-24 — nuit : la planche du stage 9 est arrivée

`stage_9.jpeg` — un format à part : des TUILES d'autotile sur fond damier (et le
damier est APLATI dans le JPEG, il n'y a pas d'alpha), un panneau paysage aux
aurores, et le titre dessiné : « SANCTUAIRE DÉCHU ». Le nom provisoire tombait
juste, il devient définitif.

Intégrée aux trois pipelines, chacun avec sa particularité :
- **vignette** : le panneau aux aurores (les autres stages prennent leur
  illustration encadrée, celle-ci n'existe pas sur cette planche) ;
- **terrain** : les VRAIES tuiles dessinées — « Sol de Base » pour le sol,
  l'intérieur de « Bord de Falaises » pour le mur. Deux corrections mesurées :
  la rangée de tuiles commence à y=557 (pas 492 — la première boîte découpait
  les tampons de mur), et la règle de lisibilité s'applique AUSSI aux tuiles
  dessinées — sol et mur sont deux pierres moussues de même valeur, leurs
  luminances sont écartées comme celles des palettes ;
- **props** : détourage « damier » spécifique (gris neutre et clair = fond),
  aucun prop de la planche n'étant gris clair. Monument = le temple en ruine au
  cristal violet ; lisière = l'arbre noueux ; lueur = la torche verte.

⚠️ L'utilisateur signale qu'un AUTRE agent traite peut-être cette planche en
parallèle. Mes découpes vivent dans mes outils (`build_stage_*.py`) et dans
`assets/stages/props/stage_9/` + `assets/tiles/stage_9/` — en cas de doublon,
comparer avant d'écraser.

### 2026-08-24 — nuit : les sorts par élément

**Le problème.** Sept mages, sept couleurs, un seul jeu : tous tiraient le même
projectile, tous explosaient pareil. Le choix du personnage était un choix de
teinte.

**Les traits élémentaires** (`CombatSystem`, pure logique testée) : chaque
élément marque désormais ses coups —

    FEU      Brûlure — 30 % des dégâts en plus, étalés sur 1,5 s
    EAU      Trempe — la cible ralentit de 38 % pendant 2,2 s
    TERRE    Ébranlement — arrêt net 0,7 s (verrou anti-paralysie de 3 s)
    TÉNÈBRES Ponction — le mage récupère 22 % des dégâts
    FOUDRE   Arc — le coup saute au voisin (moitié des dégâts)
    AIR      Bourrasque — la cible est soufflée de 2 cases le long du couloir
    SUPRÊME  Écho — 40 % des dégâts se répètent 0,6 s plus tard

Deux garde-fous, nés du papier : les ZONES ne déclenchent aucun trait (un tick
par 0,5 s ferait de chaque statut une condition permanente), et les traits ne se
COMPOSENT jamais entre eux (la brûlure rallumerait une brûlure, l'arc
rebondirait jusqu'au dernier ennemi). Tests + épreuve du feu sur les deux.

La simulation applique les traits de mouvement (trempe, ébranlement,
bourrasque) comme le Level — et au passage, elle ignorait encore les VITESSES
PAR ESPÈCE du bestiaire : corrigé, elle mesurait un autre jeu.

**Les effets dessinés** (`tools/build_spell_fx.py`) : orbe, impact et cercle de
zone par mage, découpés des planches — la comète de feu (ANIMÉE, ses quatre
phases en flip-book), l'orbite géante multicolore du Suprême, la frappe de
foudre au sol, la galaxie irisée en ultime. Le dessin est la pièce maîtresse,
les particules procédurales restent l'habillage (rayon, mouvement).

Trois règles de découpe se sont succédé, les deux premières JETÉES sur preuve :
« la plus grosse forme » ne gardait qu'une langue d'un anneau de flammes ;
« jeter ce qui touche le bord » déchirait tout dessin dont la lueur dépassait la
boîte. La bonne : la boîte ne fait que DÉSIGNER — on retient les formes dont le
centre tombe dedans, prises en entier, jamais coupées. Reste un mode « fenêtre »
pour les dessins aux lueurs jointives (la frappe de foudre soudée à son
bouclier voisin).

**⚠️ Collision : l'INVOCATEUR.** Pendant ce travail, la session voisine a ajouté
un huitième personnage au catalogue (il délègue ses combats à des invocations).
Mes gardes ont été adaptées : le compte passe à 8, et il est exempté du test de
dominance — ses quatre axes personnels sont volontairement faibles, sa puissance
vit dans ses invocations que ces axes ne mesurent pas.

### 2026-08-23 — nuit : le décor et le monument de chaque stage

**Trois détections automatiques essayées et jetées.** Les planches de stage
portent un vrai catalogue de props, mais sur un fond OPAQUE :

  - alpha : il n'y en a pas ;
  - contraste local + composantes connexes : marche sur la planche 1, dont les
    props sont espacés. Ailleurs ils se touchent BORD À BORD et tout fusionne en
    un bloc couvrant 85 % du panneau ;
  - creux de gradient (la découpe classique d'une planche serrée) : il n'existe
    aucune ligne creuse, ni en lignes ni en colonnes.

**Ce qui a été retenu** : des boîtes relevées à la main, mais GROSSIÈRES. À
l'intérieur, l'outil calcule le masque de contraste et ne garde que la plus
grosse forme — ce qui élimine les bouts de voisins qui dépassent dans le cadre.
Viser large, laisser trancher : c'est ce qui rend le relevé rapide (quatre rôles
par stage, relevés en trois images à grille).

Deux règles trouvées à la vérification, et opposées l'une à l'autre :

  - une forme qui remplit plus de 72 % de sa boîte est du FOND, pas un prop —
    sur les planches au fond texturé (les ruines, le château), c'est le fond
    qui gagnait le concours de taille ;
  - sauf pour un MONUMENT, qui remplit légitimement sa boîte. La règle
    ci-dessus ne gardait de la ziggourat du stage 8 qu'un éclat de trois pixels.

Les monuments ne se détourent d'ailleurs pas par contraste du tout — leur masque
revient plein et on obtenait un rectangle opaque posé au centre du labyrinthe.
Ils passent par une CLÉ DE FOND depuis les bords de la boîte, comme les portails.

Résultat : neuf monuments — l'autel à gemme de la forêt, le temple de foudre, le
temple de feu des dunes, le phare de corail, les flèches de cristal, le palais de
glace, le sanctuaire d'épines, la ziggourat moussue, le château du ciel — plus
une lisière et un semis par stage. Le stage 9, sans planche, garde la forêt.

### 2026-08-23 — nuit : barre du clavier, téléportation animée

**Les compétences n'existaient que sur téléphone.** Au clavier, les six touches
fonctionnaient mais RIEN ne les montrait : un joueur sur Mac ne pouvait pas
savoir qu'il avait trois sorts, encore moins lesquels étaient prêts.
`src/ui/action_bar.gd` affiche les mêmes entrées que le pad tactile — l'UIManager
les fabrique une fois pour les deux. Les libellés de touche sont lus dans
l'InputMap au moment de l'affichage : une antisèche qui ment est pire que pas
d'antisèche. Le nom du sort rétrécit jusqu'à tenir, parce que Godot COUPE au
lieu de réduire et qu'un sort affiché « Explosion d' » n'apprend rien.

⚠️ L'action de la frappe s'appelle `teleport` dans l'InputMap — nom d'origine,
d'avant que le combat existe. La barre d'espace est contextuelle.

**Une sauvegarde de joueur écrasée, une deuxième fois.** Après les tests, ce sont
les CAPTURES qui écrivaient : une session `--screenshot` pouvait ramasser une
potion ou franchir la porte, et pousser la progression. `DevTools` met désormais
`progress.persistent = false` dès qu'un argument de ligne de commande est passé.
Une session de développement n'est pas une partie.

**La téléportation était brutale.** Le sort de fuite déplaçait le mage à la frame
près : on ne comprenait pas ce qui venait de se passer. `tools/build_warps.py`
découpe la section « DISPARITION / APPARITION » de chaque planche, et
`WarpEffect` la joue AUX DEUX CASES — celle qu'on quitte, celle où l'on arrive —
pendant que le mage revient en fondu blanchi.

Les sept planches ne dessinent pas cette section de la même façon : colonne vide
puis colonne habitée (terre, air), les deux collées en un seul bloc (suprême,
foudre), un anneau de flammes (feu), un cercle et un ovale sans personnage
(eau), et rien du tout pour les ténèbres — on y prend le vortex des particules.
On ne retient donc qu'UNE forme par mage, celle SANS personnage : la version
habitée aurait affiché deux mages superposés, celui du dessin et celui du joueur.

Deux réglages trouvés à la capture : l'effet est dimensionné sur sa PLUS GRANDE
dimension et non sa hauteur (l'anneau de feu, large et plat, débordait sur trois
cases), et il passe SOUS les acteurs — le personnage joué ne doit jamais être
masqué.

### 2026-08-23 — nuit : le terrain des dix stages

**Première tentative, abandonnée.** Découper de vraies tuiles de l'aperçu de
labyrinthe, en séparant sol et murs par « les murs sont fins, le sol est large »
(érosion de huit pixels : les lignes disparaissent, le fond survit). Deux
défauts, chacun rédhibitoire :

- la règle se trompe dès le stage 2, dont l'aperçu contient DEUX terrains — le
  sable en haut, la roche électrique en bas. Elle avait l'air générale, elle ne
  l'était pas ;
- même bien classé, le plus grand carré qu'on puisse inscrire dans un mur d'une
  case de large fait quelques pixels. Agrandi à 96, il ne reste qu'un dégradé
  flou. Les tuiles du jeu, elles, sont dessinées pour être répétées.

**Ce qui a été retenu.** Garder le DESSIN des tuiles existantes et leur prendre
la COULEUR du biome : la luminance de la tuile module la teinte du stage.
L'herbe reste de l'herbe, avec son grain et son ombre, mais elle devient sable
aux Dunes et glace aux Montagnes Glacées. Les neuf couples de couleurs sont
relevés à la main sur les aperçus — même choix que pour les portails et les
repaires, et pour la même raison.

**Un garde-fou nécessaire.** Deux biomes violaient la règle du projet — « c'est
le contraste de LUMINOSITÉ qui fait lire le chemin, pas la couleur » : le Bois
d'Épine, sombre sur sombre, et le Château du Ciel, or sur or. Leur labyrinthe
était illisible alors que chaque couleur, prise seule, était juste. Un écart
minimal de 52 sur 255 est désormais imposé, en écartant les deux luminances
symétriquement — éclaircir seulement le mur ferait dériver le biome vers le
pastel.

### 2026-08-23 — soir (fin) : l'instrument avait encore dérivé

La simulation d'équilibrage a signalé un niveau à **92 % de morts**. Réflexe
acquis : soupçonner l'instrument avant le jeu. Elle avait raison de crier, mais
pas de la bonne chose — depuis les repaires, elle ne modélisait plus le jeu :

- elle faisait naître les SEPT ennemis d'un coup sur les DEUX cases de repaire,
  là où le jeu les fait sortir un par un, à 1,6 s d'écart ;
- elle les faisait réapparaître **au hasard**, alors que le jeu les ressort de
  la maison la plus éloignée du mage ;
- elle ignorait la seconde d'ouverture de la porte, qui est du répit.

Elle mesurait donc un jeu plus dur que celui qu'on joue. Les trois délais sont
passés dans `LevelConfig` — c'est un réglage de difficulté, et la règle 3 dit
que la difficulté vit là — et la simulation les lit comme le `Level`. Pour la
position, les deux appellent la même `MazeGenerator.farthest_lair()`.

Les deux niveaux où il faut abattre les repaires ne sont plus JUGÉS : le bot ne
sait pas démolir une maison, donc il ne finit jamais, et ni sa victoire ni sa
mortalité n'y veulent dire quoi que ce soit — il erre jusqu'au plafond de
quatre minutes. Leurs chiffres restent affichés, marqués comme non comparables.

### 2026-08-23 — soir (fin) : le bestiaire

Les onze planches suivent une convention régulière, **vérifiée sur les neuf** :
r0 de face, r1 de dos, r2 de profil, r3 les poses d'attaque, r4+ les effets. La
quatrième rangée n'est donc PAS la quatrième orientation comme chez les mages —
le profil sert aux deux côtés, retourné pose par pose.

Nouveau mode de découpe `"rangees"` ajouté à `build_characters.py` (additif, la
table de l'autre session n'est pas touchée) et nouvel outil `build_bestiary.py`
qui garde sa propre table. Deux planches — l'ombre et le chevalier — avaient une
grille mal détectée : elle mesurait un pas de DEUX rangées et rendait un dos
coupé en deux moitiés empilées. D'où l'option « grille imposée », quatre nombres
écrits à la main. Aucun réglage automatique ne rattrape une erreur de facteur.

La case du bestiaire est commune AU BESTIAIRE et pas commune avec les mages :
un serpent et un minotaure n'ont pas la stature d'un mage, et les forcer dans la
même case les aurait tous ramenés au gabarit du plus large.

Côté moteur, `goblin_count` disparaît : c'est le roster du stage qui décide, et
l'espèce tourne dedans. `LevelConfig.enemy_health(id)` et `enemy_speed(id)`
remplacent le booléen gobelin/spectre.

Les trois fabriques de stages sont devenues **privées** (`_stage_1`…) : depuis
que `for_stage()` pose le nom, l'épisode et le roster, une fabrique appelée
directement rend un chapitre nu — un stage 2 peuplé de spectres seuls. Le test
d'équilibrage tombait exactement dans ce piège.

Le bandeau du HUD tronquait les noms longs (« Le Château du Ci »). Il choisit
désormais la forme la plus longue **qui tient**, mesurée à la police réelle.

### 2026-08-23 — soir (suite) : sélection de stage

**Une sauvegarde de joueur écrasée par la suite de tests.** Le test des règles de
déverrouillage appelait `reach(5, 2)` sur un `Progress.new()` — et `reach()`
sauvegarde. La partie du joueur s'est retrouvée au stage 5 avec zéro sort, état
qu'aucune partie réelle ne produit. Remise à zéro (c'est la sauvegarde de bureau ;
celle de l'iPhone est indépendante).

Le correctif n'est pas « penser à ne pas sauvegarder dans les tests » : un
garde-fou qu'il faut penser à activer n'en est pas un. `Progress.persistent` est
désormais **faux par défaut**, et seule `load_saved()` le met à vrai. Une
progression fabriquée en mémoire ne PEUT plus écrire. Un test le vérifie.

**L'écran.** Dix cartes illustrées, mise en page entièrement calculée (vérifiée en
844×390, la taille d'un iPhone en paysage). Un défaut de rendu au passage : le
fond est un ENFANT du nœud, donc dessiné APRÈS lui — il repeignait par-dessus les
cartes. `show_behind_parent` sur le fond.

Le format des cartes est borné entre 2,9:1 et 1,6:1 et l'illustration est
**recadrée au centre** plutôt qu'étirée. Sans cette latitude, dix cartes au
format exact de la source laissaient la moitié de l'écran vide.

`stage_9.png` étant absent, sa vignette est un carton **hachuré** portant un
grand « 9 » : un rectangle noir se serait lu comme un bug d'affichage.

### 2026-08-23 — soir : repaires, épisodes, destruction

**Maisons d'ennemis.** `assets/lairs/{rouge,violet,vert,cyan}.png`, 6 poses.
`MazeGenerator._place_lairs` les pose sur la case praticable la plus proche des
deux coins, en excluant maison, portails et tout ce qui est à moins de 6 cases
du joueur. Deux bugs attrapés par `test_maze` avant toute capture : une gemme
pouvait tomber sur un repaire, et le mage pouvait démarrer DEDANS.

Trois corrections après coup, toutes trouvées en relisant le branchement :
- la sortie était liée au **rang du repaire** alors que le handler comparait un
  rang d'ennemi — deux numérotations confondues ;
- avec 3 ennemis morts et 2 maisons, `_lair_for()` pouvait rendre une maison
  déjà occupée et **écraser** la sortie en attente : l'ennemi écrasé n'était
  jamais revenu, sa file ayant été vidée. Il patiente désormais ;
- la pose de sortie — le point culminant de l'animation — ne durait **qu'une
  seule image** (16 ms). Elle est tenue 0,35 s.

Les ennemis naissent tous sur les cases des repaires, et il n'y en a que deux :
au-delà de deux ennemis ils se superposaient au démarrage. Les surnuméraires
attendent DANS la maison et sortent l'un après l'autre, 1,6 s d'écart.

**Épisodes.** Le `GameManager` continue de manipuler un index PLAT (0 à 19) ;
c'est `LevelConfig.flat_index()` qui traduit. Il n'a jamais à compter en deux
dimensions. `--stage N` désigne désormais le CHAPITRE et non l'index plat, sinon
`--stage 3` serait tombé sur le stage 2.

Les dix stages portent les noms **dessinés sur les planches** d'`assets/stages/`.
`stage_9.jpeg` est arrivé le 24 au soir — et il s'appelle bien « SANCTUAIRE
DÉCHU » : le nom provisoire devient définitif. Voir l'entrée du 2026-08-24.

**Destruction des repaires.** Les tests ont passé l'épreuve du feu : pénalité de
ciblage remise à 0 → « le tir choisit la maison collée au mage plutôt que
l'ennemi » ; PV du repaire ramenés à 100 → « une maison à 100 PV tombe trop vite
pour être un enjeu ». Les deux instruments mordent.

Pas de pose de ruine sur la planche : une maison morte est rendue par
**noircissement** (`modulate` 0.32/0.26/0.30), ce qui la distingue le plus
lisiblement d'une maison au repos.

**Collision de session — en direct.** Pendant ce travail, `assets/characters/`
`{fire,earth,air}/*.png` ont été réécrits (19 h 23 à 19 h 45) avec les
**planches brutes 2172×724** à la place des bandes découpées 918×112. Résultat
en jeu : le mage joué s'affichait quatre fois trop grand, `hframes=6` taillant
la planche source en six bandes. Restauré en relançant `build_characters.py`.
Garde-fou ajouté au passage : une vérification que `largeur == cellule × poses`
pour chaque bande — c'est ce qui a permis de nommer le défaut en une commande.

⚠️ Piège retrouvé : `build_characters.py` utilise des chemins **relatifs**
(`SOURCE = Path("assets/peso&cover")`). Lancé hors de la racine du projet, il
signale « introuvable » pour les neuf planches et ne fait rien.

### 2026-08-23 — après-midi : analyse
- Analyse de l'existant et rédaction de ce plan.
- Planche du Mage Arcane analysée : format « grille étiquetée », fond transparent,
  directement découpable.
- **Bloquant** : 4 planches sur 5 et la couverture sont introuvables sur le disque.
  Seule la planche Arcane est présente (`~/Downloads`). Le dossier « peso&cover »
  mentionné n'existe pas sur cette machine.
- À noter : `tools/build_assets.py` contient une section **gobelin** écrite par une
  autre session (avec `assets/raw/gobelin_sheet.png`). Ne pas l'écraser.


---

## 6bis. Découpage des planches — `tools/build_characters.py`

Les sept planches n'ont pas la même mise en page (panneaux d'effets à droite ou
en bas, étiquettes présentes ou non, lueurs qui débordent d'une case sur
l'autre). Deux approches ont échoué avant la bonne :

1. **Composantes connexes** — deux sprites voisins fusionnent par leur halo, et
   les tailles varient trop d'une planche à l'autre pour filtrer.
2. **Bandes de projection** — marche sur `mage_fire`, échoue complètement sur
   `mage_thunder` et `mage_element` où tout se touche verticalement.

Ce qui marche : la grille est **régulière**. On retrouve son pas par
**autocorrélation** du profil d'opacité, puis sa phase en cherchant le décalage
qui met les lignes de grille dans les **gouttières**. Ce qui reste propre à
chaque planche (où commence la grille) tient dans une table de sept lignes.

Sortie, par personnage :

```
assets/characters/<id>/down.png up.png left.png right.png   6 poses par bande
assets/characters/<id>/frames.json                          case, pieds, ordre
```

Ordre des poses, identique partout : IDLE, WALK 1-4, ATTACK.

## 6. Inventaire des assets fournis (`assets/peso&cover/`)

Trouvés le 2026-08-23. Le dossier était **dans le projet**, pas dans le dossier
personnel — mes premières recherches ne descendaient pas assez profond.

### Planches de personnages (1536×1024, grille 4 directions × IDLE/WALK 1-4/ATTACK)

| Fichier | Personnage | Alpha | À faire |
|---|---|---|---|
| `mage_fire.png` | **Mage du Feu** | ✅ | découpé |
| `mage_circle.png` | **Mage de l'Eau** | ✅ | découpé (a aussi HIT + DEATH) |
| `mage_earth.png` | **Mage de la Terre** | ✅ | découpé |
| `mage_dark.png` | **Sorcier des Ténèbres** | ✅ | découpé |
| `mage_element.png` | **Sorcier Suprême** | ✅ | découpé |
| `mage_thunder.png` | **Mage de la Foudre** | ✅ | découpé — **à ajouter au catalogue** |
| `mage_wind.png` | **Mage de l'Air** | ✅ | découpé — **à ajouter au catalogue** |

L'utilisateur a remplacé les JPEG par des PNG transparents le 2026-08-23 à 15 h,
et ajouté deux mages : le roster passe de cinq à **sept**.

Chaque planche porte en plus : portrait, émotes, effets de sorts, particules,
palette de couleurs. Les grilles d'effets serviront d'**icônes de compétences**.

### Références d'interface

- `couverture.png` (1024×1536) — **l'écran d'accueil**, désormais utilisé tel quel.
- `selection_mage1.jpeg` / `selection_mage2.jpeg` — maquettes de l'écran de sélection.
- `configuration.jpeg` — **cahier des charges complet** : HUD, barres de vie
  ennemies (100 / 150 / 300 HP), dégâts affichés en rouge, fumée grise à la mort,
  grilles d'effets par élément, notes en étoiles.

### À noter

La couverture et les maquettes de sélection ne montrent que **cinq** mages :
elles datent d'avant l'ajout de la Foudre et de l'Air. Le catalogue du jeu doit
donc passer à sept, et l'écran de sélection s'adapte déjà à n'importe quel
nombre.

### Écarts assumés avec la référence

- **PV des ennemis** : la référence indique 100 / 150 / 300. Le jeu utilise
  150-200 / 230-270, valeurs **mesurées** par `test_balance.gd` — à 100 PV
  l'attaque de base abattait un poursuivant en trois secondes et la simulation
  donnait 100 % de victoires sans une seule mort. Le troisième palier (300 PV)
  attend un type d'ennemi « puissant » qui n'existe pas encore.

## 2026-11-01 — l'explosion du Feu, en quatre temps

Inspirée du découpage d'une explosion animée à la main (pack de Duc Vu, regardé comme
référence, ni acheté ni copié) : un éclair fin, un gonflement en lobes, des trous sombres
qui les creusent, des filets qui s'effilent (`fire_burst.gdshader`). Elle ne s'estompe
jamais : elle se réduit, en gardant ses aplats.

⚠️ C'est le TEMPS et la silhouette en lobes qui font l'explosion, pas le bruit. Celui-ci
ne sert qu'à tordre les lobes, à très basse fréquence.
À appliquer aux autres mages une fois le Feu validé sur téléphone.

## 2026-10-31 — les sorts sont peints au shader, un dessin par sort

Les huit mages passent au shader (`PaintedFx`, `MagicOrb.PAINTED`,
`ZoneEffect.PAINTED_STYLES`, `PaintedBurst`, `Level.PAINTED_MAGES`). Le vortex rond de
`impact.png` n'est plus joué. Les dessins du Feu s'inspirent de
`peso&cover/sorts/mage_fire_skills.png`.

⚠️ **La règle : chaque sort a son dessin, tiré de ce qu'il FAIT.** Une première version
recolorait les shaders du Feu en violet pour les Ténèbres : jetée le jour même. Une
palette donne sept teintes, pas sept mages. Le Feu s'ouvre et se déchire, l'Ombre se
referme sur elle-même, l'Invocateur trace au compas sans aucun bruit.
`test_animation` échoue si deux sorts partagent un même habillage.

⚠️ **`PaintedFx.cover` éteint les planches sans retirer les nœuds.** Tornade, égide,
cristal, nuage et les autres gardent leur logique et leurs particules ; `self_modulate`
masque leurs images et un quad peint prend la place. Les planches restent donc CHARGÉES
pour rien : à retirer une fois le rendu validé sur téléphone.

⚠️ **Un blanc sur blanc ne se voit pas.** Le vent de l'Air disparaissait sur les stages
clairs tant qu'il n'avait pas de liseré sombre. Contrôler chaque effet sur un sol clair.

⚠️ **La Terre et l'Air gardent leurs dessins, à la demande du joueur** : rocher, pics,
égide, cristal, éboulement ; lame, tornade, cône du souffle, cyclone. Leurs shaders s'y
AJOUTENT seulement : le sol qui se fend, l'onde du séisme, les traits de vent, le voile.
Ce sont les seules exceptions à la règle ; ne pas les « corriger » (`Level.DRAWN_MAGES`).

Encore dessinées aussi : les créatures invoquées.

**Les Quatre Sceaux partagent une seule flamme, à la demande du joueur** : la traînée de
la Boule de feu, dressée à la verticale, dans les couleurs de chaque élément
(`seal_flame.gdshader`). C'est la seule palette voulue du jeu.

**Le Suprême repeint une seconde fois** : sa première version alignait des disques et
des anneaux colorés, jugés trop simples. `elements.gdshaderinc` peint maintenant la
MATIÈRE des quatre éléments, et tous ses sorts s'en servent : le feu brûle, l'eau strie,
la terre se casse en plaques, l'air n'est que filets.

⚠️ **Le bruit ne doit pas pouvoir créer de matière hors de la forme** (`inside`) : il
rallumait des pixels loin du dessin, qui se découpait en carré sur son quad.
⚠️ **Une flamme se fait avec un bruit très étiré.** Fin dans les deux sens, il grésille.
Les effets déjà codés restent tels quels (vague, implosion, champ, chaîne, orage).

⚠️ **Ce n'est pas plus rapide qu'une image, c'est plus cher.** Mesuré sur M1 avec
`tools/preview_fire.gd --bench`, à 300 projectiles : 0,33 ms en image, 1,24 ms pour le
trait, 2,72 ms pour la boule. À 30, l'écart n'est pas mesurable. Ce qu'on achète,
c'est le mouvement, la variété et un sol qui suit exactement le rayon du sort. Le
téléphone reste à mesurer, surtout avec les cinq auras de 30 s posées ensemble.

⚠️ **`gl_compatibility` ne précompile pas ses shaders** : le premier sort saccaderait.
`Level._warm_painted_shaders` les affiche au chargement, sur quelques pixels presque
transparents, comme le prescrit la doc de Godot.

⚠️ **Sans texture, une particule est un carré.** Ça se voyait à peine sur l'ancienne
orbe additive, et ça sautait aux yeux sur ces aplats. `MagicOrb._round_embers`.

## 2026-10-31 — les quatre derniers ennemis, et trois pièges de découpe

Dragonnet, Archer d'Os, Démon de Cristal et Chevalier Noir passent au format à
17 poses.

**L'Archer d'Os devient un tireur pur** : quatre cases en ligne droite, 2,2 s entre
deux flèches. Il s'arrête dès qu'il a sa ligne et ne frappe jamais au contact.
Sa flèche est dessinée par le moteur : la planche n'en montre qu'une traînée floue.

⚠️ **Le rechargement de `ThrowSystem` se figeait pendant le repos d'après coup.**
Le jeu tirait donc à deux fois le cycle de coup, et la simulation à une fois. Il
court maintenant toujours, et `throw_reload` dit le rythme : 2,1 s pour le Golem
de Lave et 2,2 s pour celui de Givre, ce qu'ils tiraient déjà en jeu.

⚠️ **`test_balance --quick` n'avait jamais marché.** Un tableau mal typé le faisait
planter avant `quit()`, et Godot restait ouvert sans rien dire. Une fois réparé, il
affichait 33 % pour 4 victoires sur 4 : les moyennes divisaient par 12 quel que soit
le nombre de parties.

⚠️ **Une marche commandée sur une seule phrase ne marche pas.** Celle de l'Archer
a donné huit fois la même foulée figée (0,03 de course du pied, contre 0,50 pour
le gobelin, seul à avoir ses huit temps écrits). Toutes les bêtes à jambes
reçoivent maintenant `LEG_BEATS`, et les autres ne reçoivent plus la règle des
vrais pas, qui contredisait les pattes repliées du Dragonnet.

⚠️ **Un débordement se prouve.** Un morceau détaché au bord d'une case n'est pas
forcément à la voisine : la boule du Golem de Lave en est un. Ce qui le condamne,
c'est que la matière continue de l'autre côté de la frontière
(`without_side_bleed`). Une flèche en vol, coupée en deux morceaux détachés, garde
sa plus grande moitié : la première version l'effaçait des deux côtés.

⚠️ **Le cœur du Démon de Cristal est du même magenta que le fond**, et le détourage
lui laissait un trou dans la poitrine. Les vrais trous enclavés s'écartent de 14 à
21 du fond, le cœur de 30 à 45 : `keep_enclosed` garde ce qui dépasse 25, pour cette
seule bête. Le seuil est réglé sur elle et n'est pas une règle générale.

La nouvelle règle de débordement n'a été appliquée qu'à ces quatre bêtes. Un
nouveau découpage du Spectre, du Golem de Givre, du Golem de Lave ou du Gobelin
retirerait aussi des morceaux de leurs poses : à recontrôler à ce moment-là.

## 2026-08-29 — le décor du sol était invisible

Les props semés dans les couloirs — champignons, coquillages, tonneaux, ancres —
faisaient **0,42 case, soit treize pixels**, quand le mage en fait cinquante. Ce
n'est pas discret, c'est invisible : on les prend pour un défaut du sol.

Ils font maintenant 0,62 case, et ce qui brille 0,68.

⚠️ **Le plafond comptait autant que le plancher, et il ne se devinait pas.** Un
premier réglage à 0,72 / 0,82 rendait les props lumineux **plus gros que la
GEMME** (0,78) — exactement la confusion que ce fichier redoutait depuis
toujours : « le joueur ne distingue plus les portails du mobilier ». On agrandit
le décor, et l'objectif se noie dedans.

La taille est donc **dérivée de celle de la gemme** et non écrite à côté :

    const PROP_TILES := Gem.TARGET_HEIGHT_TILES * 0.80
    const GLOW_TILES := Gem.TARGET_HEIGHT_TILES * 0.87

Si la gemme grandit un jour, le décor la suit et lui reste inférieur. Ce que le
joueur doit ramasser est TOUJOURS la plus grosse chose posée au sol — écrit dans
le code plutôt que dans un commentaire, c'est la seule forme qui tienne.

La DENSITÉ n'a pas bougé (un prop pour douze cases de couloir) : le même
commentaire prévient qu'au-delà le décor devient du bruit, et cet avertissement
vaut davantage maintenant que les props ont doublé de taille.

## 2026-08-28 — rendre la vérification faisable

Quatre contrôles ont annoncé un succès sans rien vérifier, en une seule journée :
un découpage rendu en carrés gris uniformes salué comme parfait, un contrôleur
qui annonçait « 0 planches bien découpées » et concluait au succès, une barre
tactile mesurée en pixels d'écran pendant que trois boutons sortaient de
l'écran, et un test qui plantait sans faire échouer sa suite.

Aucun n'était le même bug. Le point commun est ailleurs : **vérifier ce projet
demandait sept commandes et la lecture de sept sorties**. Personne ne le fait
sept fois, donc personne ne le fait.

`tools/verifier.sh` — une commande, un verdict, et elle filtre les
`SCRIPT ERROR` que les suites ne font pas échouer.

Et `test_balance` a une **passe rapide** (`-- --quick`) : un niveau sur quatre,
quatre parties au lieu de douze, environ trois minutes contre une demi-heure.
Elle annonce elle-même ce qu'elle ne prouve pas — « rien de gros n'a dérivé,
mais c'était la passe rapide ». C'est le seul test qui juge l'équilibrage, et il
n'avait pas tourné une seule fois pendant que la Rune, l'Implosion, la Faille,
le Cyclone et l'ordre du roster étaient réécrits. Un test d'une demi-heure ne se
lance pas au milieu d'une séance ; celui-ci, si.

## 2026-08-28 — trois dettes soldées

### La Ponction ne rend plus immortel

Le trait des Ténèbres rendait « 22 % des dégâts infligés », et c'était un défaut
d'UNITÉS : `dealt` se compte en points de vie d'ENNEMI — 16 pour une orbe, 110
pour un ultime — quand le mage en a TROIS. Une orbe rendait donc 4 PV sur un
maximum de 3 : **le Sorcier des Ténèbres se remettait à fond à chaque coup
porté**, et sa fiche annonçait « encaisse mal ».

Rien ne pouvait l'attraper. Les deux nombres sont des entiers, l'appel est
valide, et le soin est plafonné par le maximum du mage : le défaut ne se voit
qu'en jouant, et il se lit comme de la chance.

Le trait garde son sens mais à l'échelle du mage : **un point de vie, au plus
toutes les dix secondes**. De quoi se relever d'une erreur, pas de quoi ne plus
jamais en payer une. Le verrou compte autant que le chiffre — un trait qui rend
1 PV à chaque coup reste une immortalité, juste plus lente.

⚠️ Le trait est partagé : l'INVOCATEUR est lui aussi de l'élément Ténèbres, et
il gagnait la même immortalité sans que sa fiche l'annonce nulle part.

### La Translation devient le Passage, et traverse les murs

Le Sorcier des Ténèbres avait DEUX translations : 4 cases toutes les 9 s, et 6
cases toutes les 6,5 s. Plus courte, plus lente, sur le même geste : la première
n'avait aucune raison d'exister. Signalé deux fois sans être traité.

Elle FRANCHIT maintenant la haie qu'elle regarde. Le Pas de l'ombre reste la
fuite — il glisse le long du couloir quand on est rattrapé ; le Passage coupe à
travers le labyrinthe. C'est un raccourci, pas une échappatoire, et c'est la
seule chose du jeu qui le fasse — ce qui va au mage des passages, dont rien dans
le kit n'exploitait la topologie.

⚠️ **Une règle du projet a dû être précisée, et c'est le test qui l'a exigé** :
« aucun sort hors ultime ne traverse les murs ». Ce qu'elle protège, c'est
qu'aucun sort ne FRAPPE à travers une haie — c'est ce qui rendrait l'ultime
ordinaire. Une translation qui franchit un mur ne frappe rien : elle déplace son
lanceur, ça se voit entièrement, et ça ne retire rien à personne. La règle porte
désormais sur la PORTÉE et non sur le déplacement, et le test dit lequel des deux
il garde.

### `build_lairs.py` remarche

Les deux planches de portails traînaient dans un dossier nommé « dossier sans
titre » ; `build_lairs.py` et `build_portals.py` les cherchaient à
`assets/portail/`, qui n'existe plus. Le premier produit les repaires d'ennemis,
que le jeu utilise, et il était **inexécutable**. Les planches sont rangées dans
`assets/peso&cover/decor/`, les chemins sont réparés, et le dossier sans titre a
disparu.

### ⚠️ Un test qui plante est compté comme un test qui passe

Trouvé en écrivant le test du Passage : un appel à une méthode inexistante
interrompt la fonction fautive et REND LA MAIN à l'appelant. La suite continue et
conclut « TOUS LES TESTS PASSENT » — sur un test qui n'a rien vérifié.

Quatrième défaut de cette famille en une journée, après les huit carrés gris du
découpage, le contrôleur qui annonçait « 0 planches bien découpées » et la barre
tactile mesurée en pixels d'écran. Consigné dans `CLAUDE.md` avec la commande qui
l'attrape — il n'existe aucun moyen de le détecter depuis GDScript.

## 2026-08-28 — la carte respire : vignette, halo, poussière

Le labyrinthe était éclairé **uniformément d'un bord à l'autre**. C'est ce qui le
faisait lire comme une planche de tuiles et non comme un endroit : rien ne
séparait le proche du lointain, rien ne bougeait à l'écran sauf les personnages,
et le sol sous les pieds du mage était exactement celui de vingt cases plus loin.

Trois couches, sur un seul `CanvasLayer` (`src/fx/ambience.gd`) :

- **la VIGNETTE** — l'écran s'assombrit vers ses bords, dans la teinte du stage.
  Elle prend la couleur MOYENNE du sol du biome, mesurée une fois au chargement
  sur une grille de 81 points ;
- **le HALO DU MAGE** — le monde s'éclaire autour de lui, avec un battement de
  flamme. C'est le signal le plus fort qu'on puisse donner : le décor RÉAGIT au
  personnage ;
- **la POUSSIÈRE** — quarante-quatre motes qui dérivent lentement, en
  `CPUParticles2D` comme tout le reste du jeu, pour que le rendu soit identique
  sur mobile.

⚠️ **Aucune lecture du tampon d'écran.** Le renderer est `gl_compatibility` : y
lire coûte une copie de l'écran par passe. Deux nappes en composition ordinaire
— l'une qui assombrit, l'autre qui éclaire — font le même travail pour rien.

Quatre pièges, dont deux silencieux :

1. **le mode de composition d'un ShaderMaterial se déclare DANS le shader**
   (`render_mode blend_add`). Poser un `CanvasItemMaterial` en `next_pass`
   AJOUTE une passe, ça ne change pas la composition de la première : le halo
   restait en alpha ordinaire et voilait le décor de blanc au lieu de
   l'éclairer ;
2. **l'interface se faisait assombrir avec le décor.** L'ambiance vit sur le
   calque 1 ; l'UI était restée au calque 0 par défaut, donc dessous. Mesuré :
   le bandeau perdait **44 % de sa luminosité** (86 -> 48) et ses libellés
   viraient au gris. `main.tscn` donne maintenant le calque 2 à l'UI. Un défaut
   qu'on regarde sans le voir — on croit que la vignette est un peu forte ;
3. **une vignette qui reprend la couleur du sol APLATIT au lieu de creuser.**
   Prise telle quelle elle repeignait le sable en sable ; il faut l'assombrir ET
   la refroidir — le bleu qui reste dit « ombre » quel que soit le biome ;
4. **les motes doivent naître PARTOUT.** Émises depuis le bas de l'écran, elles
   mettaient neuf secondes à monter et l'air restait vide au-dessus du mage,
   c'est-à-dire là où l'on regarde.

### Le contraste se MESURE, il ne se choisit pas à l'œil

Premier réglage : joli en capture, illisible en jeu. Le rapport de luminosité
entre le centre de l'écran et ses coins était monté à **x2,3** — les coins
perdaient la moitié de leur lumière, et avec eux les couloirs et les poursuivants
qui y arrivaient. Un labyrinthe dont on ne voit plus les bords n'est plus un
labyrinthe.

Mesuré sur cinq anneaux de rayon croissant autour du mage :

| rayon (px) | 60 | 160 | 260 | 380 | 500 | contraste |
|---|---:|---:|---:|---:|---:|---:|
| avant l'ambiance | 190 | 186 | 188 | 177 | 185 | **x1,03** |
| premier réglage | 219 | 194 | 175 | 130 | 95 | **x2,30** |
| réglage retenu | 215 | 201 | 192 | 160 | 141 | **x1,52** |

Deux corrections, et la seconde pesait plus lourd que la première :

- **le halo ne s'élève plus au carré.** Élevé au carré il faisait un noyau blanc
  serré cerclé de nuit : le contraste entre la flaque et son bord se voyait plus
  que la flaque elle-même. Portée élargie, force ramenée de 0,26 à 0,15 ;
- **la vignette était le vrai coupable** — densité 0,74 ramenée à 0,40, et son
  début repoussé vers l'extérieur. C'est elle qui écrasait les coins, pas la
  lumière du mage.

Vérifié sur un stage CLAIR (le 4, sable) et un stage SOMBRE (le 5, cristal) : ce
sont les deux extrêmes où une ambiance mal réglée se voit — l'une délave, l'autre
écrase. Le contraste y vaut **1,52 et 1,54**, ce qui est le point : le même des
deux côtés.

## 2026-08-28 — le sceau de la maison retiré, il faisait doublon

Un anneau flottait au-dessus du monument central, portant une pastille par gemme
manquante dans la couleur exacte de la gemme à trouver. Il disait exactement ce
que le bandeau d'information dit déjà, en haut de l'écran : une pastille par
gemme du niveau, éteinte quand elle est ramassée.

Deux compteurs de la même chose, dont l'un flottait au milieu du décor. Retiré.

Ce qui reste dit la même chose sans la répéter : la TEINTE froide et bleutée de
la maison scellée — une maison verrouillée qui reste chaleureuse invite à s'en
approcher, exactement le contresens à éviter — et l'onde chaude qui s'ouvre au
moment où la dernière gemme tombe.

`House.set_seal(Array[Color])` devient `set_locked(int)` : depuis que le sceau a
disparu, les COULEURS des gemmes ne servaient plus à rien ici. Le bandeau les
affiche ; la maison ne fait que s'ouvrir ou non. Trente lignes de dessin et deux
champs partent avec — dont `_seal_y`, qui existait pour poser le sceau au sommet
réel du sprite parce qu'une hauteur fixe le plantait au milieu des îlots
flottants.

## 2026-08-28 — un seul portail, contenu dans son couloir

Le portail de téléportation avait trois défauts, tous mesurés en capture :

1. **il débordait du couloir.** Réglé à 1,6 case de haut quand un couloir en
   fait UNE : l'anneau montait sur les haies des deux côtés et l'on ne voyait
   plus où marcher ;
2. **il se délavait.** Rendu en ADDITIF, un anneau clair posé sur le sable du
   stage 3 devenait une tache pâle. L'additif ne sait qu'éclaircir : sur un sol
   déjà clair, il n'a plus rien à ajouter. C'est l'erreur symétrique de celle
   de la flaque d'ombre, qui ne pouvait pas peindre du noir en additif ;
3. **huit couleurs, aucune cohérence.** Huit teintes tirées de huit rangées
   d'une même planche ne font pas une famille.

Remplacés par **une seule boucle de huit images, en cyan**, posée à plat et
contenue dans 0,95 case. Composition NORMALE et non additive.

### Les six états ne sont plus dessinés, ils sont joués

C'est le changement qui simplifie tout. Il y avait 8 couleurs x 6 états dessinés
= **48 images**. Les états — repos, ouverture, ouvert, actif, saut, fermeture —
sont maintenant des RÉGLAGES de la boucle unique : la vitesse de rotation, la
taille et l'éclat. Au repos elle tourne à 3,5 images par seconde et sombre, sous
les pieds du mage à 9 et claire, au saut à 20. **Huit images remplacent
quarante-huit**, et les états sont enfin cohérents entre eux.

⚠️ La vitesse est un COMPTEUR CONTINU et non un numéro d'image posé : changer de
cadence ne doit pas faire sauter la rotation en arrière.

⚠️ **On perd le repère de couleur**, et c'était un choix documenté : « le
portail vert » était mémorisable dans un labyrinthe où l'on revient sur ses pas.
Ce qui les distingue maintenant est leur DÉPHASAGE — ils sont identiques mais
pas synchrones, ce qui évite au moins le clignotant d'ambulance.

⚠️ **L'anneau tracé en code a disparu.** Il existait pour dire « c'est CETTE
case », la lueur d'avant étant large et floue. Le dessin actuel fait exactement
une case : l'anneau ne disait plus que ce que le portail dit déjà, et deux
cercles concentriques se lisaient comme un défaut de rendu.

Vérifié sur un stage CLAIR (le 3, sable) et un stage SOMBRE (le 5, cristal) —
c'est là que les deux erreurs opposées se voient.

### Ménage, et deux outils cassés trouvés en passant

Les huit planches de couleur et leur `frames.json` ont été supprimés : plus rien
ne les ouvrait et elles partaient dans l'app. `tools/build_portals.py` est marqué
hors service en tête de fichier plutôt que rafistolé — le rafistoler donnerait
l'illusion d'un outil vivant, alors que la règle du jeu a changé.

⚠️ **`build_portals.py` ET `build_lairs.py` pointent tous deux vers
`assets/portail/`, qui n'existe plus** : leurs planches sont dans
`assets/dossier sans titre/`. Le premier est désormais obsolète ; **le second ne
l'est pas** — il produit les repaires d'ennemis, que le jeu utilise — et il est
actuellement inexécutable. À réparer par qui a déplacé les planches.

## 2026-08-28 — la barre tactile en éventail régulier

**La fuite et le troisième sort étaient superposés.** Signalé en jeu, confirmé
au calcul : le troisième sort tombait à 196° + 2 x 37° = **270°**, exactement
l'angle de la fuite. Leurs centres étaient à 10 px l'un de l'autre pour des
rayons de 33 et 39 — **62 px de recouvrement**. On visait un sort, on
déclenchait l'autre.

Le défaut ne pouvait pas se voir en relisant : les trois placements — les sorts
en arc, la fuite « juste au-dessus de la frappe », l'ultime « à l'écart » —
étaient écrits séparément et chacun était raisonnable pris seul. Leur commentaire
affirmait même que les rayons d'arc garantissaient que deux voisins ne se
touchent pas ; c'était vrai entre les sorts, et faux dès qu'on ajoutait la fuite.

Remplacés par **un seul éventail régulier** : un rayon pour tous les
secondaires, un pas angulaire constant, et l'ordre qui suit le pouce — la fuite
ouvre l'éventail à hauteur de main, les trois sorts montent DANS L'ORDRE, et
l'ultime ferme la marche tout en haut, le plus long à atteindre, ce qui était
déjà son intention.

Les boutons sont un peu plus gros au passage, comme demandé : 52 -> 56 pour la
frappe, 33 -> 38 pour les sorts.

### Deux erreurs de plus, attrapées par le test et pas par l'œil

1. **Un rayon d'éventail constant sort de l'écran.** La barre est dessinée en
   unités d'interface et non en pixels : `Platform.apply_ui_scale` en change le
   nombre selon l'appareil, et un téléphone en paysage n'en offre qu'environ
   690 x 330 là où son écran en fait 960 x 460. Les trois boutons du haut y
   étaient coupés net — et le premier test passait, parce qu'il éprouvait des
   PIXELS d'écran ;
2. **rabattre le rayon sans toucher aux boutons les fait se chevaucher**, ce qui
   est le défaut qu'on répare. Et les rétrécir dans le même rapport rétrécit
   AUSSI le jeu entre eux : il tombait à 7 px là où la règle en demande 10. Il
   fallait RÉSOUDRE — la corde disponible est connue, on en déduit le rayon de
   bouton qui laisse le jeu entier.

`tests/test_pad.gd` vérifie sur cinq tailles d'interface qu'aucun bouton n'en
chevauche un autre et qu'aucun ne sort de l'écran. C'est la seule chose qui
empêche le défaut de revenir au prochain réglage : un chevauchement se voit sur
une capture quand on sait où regarder, et pas autrement.

## 2026-08-28 — l'écran-titre passe en paysage

La couverture était un PORTRAIT 2:3, et le jeu se joue en paysage. Mesuré en
capture à 1280x600 : l'illustration n'occupait que **le tiers central** de
l'écran, les deux bandes restantes étant remplies par elle-même, agrandie et
assombrie à 30 %. Ça faisait illusion, pas une page d'accueil. Et elle ne
montrait que **cinq mages** — elle datait d'avant la Foudre et l'Air.

Nouvelle image en 1659x948 : le labyrinthe sur toute la largeur, et **les huit
mages** de dos.

### Les boutons ne sont plus peints

C'est le vrai changement. Les trois boutons étaient DESSINÉS DANS L'IMAGE, et le
jeu posait des `Button` transparents dessus à des rectangles relevés à la main
(`HOTSPOTS`). Deux défauts : le texte était de la peinture — il ne pouvait ni
changer ni rester net quand on l'agrandissait — et chaque nouvelle couverture
obligeait à re-mesurer trois rectangles.

Le jeu les dessine maintenant avec `MenuStyle`, comme tous les autres menus.
`HOTSPOTS` a disparu.

⚠️ **Et ils sont en RANGÉE, pas en colonne.** Le prompt demandait un tiers
inférieur calme pour les loger ; l'illustration livrée met ses huit mages sur
toute cette hauteur. Une colonne centrée en couvrait quatre — et ce sont eux
qu'on est venu regarder. Une rangée basse ne mange qu'un bandeau. Elle est posée
sur un dégradé sombre : les boutons sont translucides pour laisser voir le
décor, et sur un dallage éclairé par huit auras ils s'y noyaient.

⚠️ **Trois boutons de MÊME largeur.** Les dimensionner à leur importance était
joli et faux : c'est « CHOISIR SON MAGE », le plus long libellé, qui se
retrouvait dans le plus étroit.

Vérifié aux trois formes d'écran où l'ancienne échouait : 1280x720, 1280x600 et
960x460 (paysage téléphone).

### ⚠️ 48 Mo de planches sources partent dans l'app

Relevé en passant, en vérifiant que l'ancienne couverture cessait d'être
embarquée. `export_presets.cfg` exclut des DOSSIERS depuis leur rangement, mais
une quinzaine de planches sont revenues **à la racine** de `assets/peso&cover/`
et ne sont couvertes par aucun motif : `orb_*.png` pour les huit mages,
`shadow_rune.png`, `convergence_skill.png`, `impact_thunder.png`,
`geyser_water.png`, les trois `mage_invocateur_*.png`.

**22,9 Mo que le jeu n'ouvre jamais** — vérifié, aucune n'est citée dans `src/`.
Le reste (25 Mo) est légitime : la couverture, le fond de sélection et les neuf
portraits, tous chargés à l'exécution.

Je n'ai exclu que ce qui est à moi — `refonte/` et l'ancienne `couverture.png`,
soit 19 Mo. Les planches de la racine appartiennent à l'autre session, qui les y
a déposées et les utilise peut-être encore : les ranger sans le lui dire
casserait ses outils.

## 2026-08-28 — la fiche de personnage cesse d'être un listing

L'écran de sélection affichait les sept lignes de la fiche dans UN SEUL libellé,
alignées à l'espace : « SKILL 2   Nom — chiffres », puis la description en
dessous, décalée de dix espaces. Rien ne se détachait de rien. C'est pourtant
cet écran qui décide du choix d'un mage.

Refaite en VRAIES LIGNES (`AbilityRow`), une par bouton de la barre d'action,
avec trois niveaux de lecture :

- **l'icône**, reconnue avant d'être lue — et c'est la même qu'on retrouvera sur
  le bouton en jeu, ce qui fait de cette fiche un apprentissage et non une
  notice ;
- **le nom** en clair, le créneau en petit à côté, dans la couleur de l'élément ;
- **les chiffres** à droite, en retrait, et la description en dessous.

Le TRAIT a quitté la liste des sorts pour rejoindre la vie et la vitesse : c'est
une propriété du personnage, pas un bouton. Rangé parmi les sorts, il se lisait
comme un septième sort qu'on cherchait en vain sur la barre.

Trois pièges de mise en page, tous mesurés en capture :

1. **la pastille ne peut pas dépasser la hauteur de ligne.** C'est elle qui fixe
   la hauteur minimale du `HBoxContainer` : à 1,15 fois la ligne, six sorts
   débordaient de la fiche et l'ULTIME se retrouvait coupé en deux ;
2. **mais l'icône, elle, doit déborder de la pastille.** Les icônes sont
   découpées pour les boutons RONDS du pad — `fitted()` les inscrit dans 70 % de
   leur image pour qu'elles ne sortent pas du cercle. Cadrées pile sur la
   pastille, elles n'en occupaient que les deux tiers et les sorts se lisaient
   comme de petites taches. On les laisse mordre sur le bord de 15 % ;
3. **la pastille est TOUJOURS là**, même quand l'icône manque : sans fond, une
   icône claire et une icône sombre ne commencent pas à la même place à l'œil et
   la liste ondule. Sans icône du tout, elle se remplit de la couleur du mage.

La hauteur de ligne, le corps du texte et la présence de la description se
CALCULENT à partir de la place disponible : vérifié en 1280x720 et en 960x460
(paysage téléphone), où les six sorts tiennent encore avec leurs descriptions.

## 2026-08-28 — le Suprême a ses icônes, les huit mages sont habillés

Sept mages sur huit avaient leurs six icônes ; le Suprême était le dernier sans.
Planche commandée sur la convention habituelle — 3 x 2 cases de 512, fond
magenta — et découpée par `build_skill_icons.py` : rose des vents à quatre
pointes, quatre orbes en spirale, anneau à quatre sceaux, goutte au bourgeon,
silhouette qui file, météores et onde de choc.

**Rien à coder côté jeu.** `UiIcons` cherche `assets/icons/<mage>/<sort>.png` et
retombe sur les pastilles colorées quand il ne trouve rien : c'est ce qui a
permis d'habiller les mages un par un, et le Suprême s'est habillé tout seul dès
le découpage fait. Vérifié à la barre du clavier ET aux boutons ronds du pad.

⚠️ Cette planche a suivi l'ordre demandé, ce qui n'était vrai ni pour le Feu ni
pour l'Eau. La table de l'outil relève quand même ce que chaque case MONTRE —
c'est la seule façon de ne pas se faire avoir la fois où il dérive.

### Une fausse alerte, et une vraie correction

J'ai d'abord cru les couleurs délavées : mesuré, l'orbe bleue passait de
(125, 76, 210) à (78, 122, 177). **La mesure était fausse** — je comparais un
point de la planche source à un point de l'icône finale, qui ne se correspondent
pas après recadrage et mise à l'échelle. Comparée cellule par cellule, la
saturation est intacte : 0,704 en entrée, 0,698 en sortie. L'impression venait
de regarder un aperçu sur fond magenta à côté d'une planche sur fond gris.

La correction faite au passage reste, parce qu'elle ferme un risque documenté :
**le dégorgement ne s'applique plus qu'au BORD**. La « magenta-ité » — ce qu'un
pixel a de rouge ET de bleu en plus de son vert — est aussi la signature du
violet, et c'est elle qui avait obligé à écrire un détoureur séparé pour la Rune
des Ténèbres. L'atténuation d'ALPHA, elle, reste globale : c'est elle qui fait
disparaître le fond vu à travers un dôme de verre, et ce fond-là est bien à
l'intérieur du dessin.

Mesuré sur les 48 icônes des huit mages : la correction ne change rien de
visible (+1 % de saturation au mieux, jamais moins). Elle ne répare pas un
défaut, elle en empêche un.

## 2026-08-26 — le Cyclone de l'Air : trois colonnes qui chassent

L'ultime de l'Air était une explosion de plus : 115 dégâts sur 6,5 cases, le
même geste que son Grand souffle en plus gros. Rien qui casse une règle, donc
rien qui ressemble à un ultime.

**Trois colonnes de vent et de foudre** se lèvent maintenant et partent chasser.
Elles VOLENT — droit sur les poursuivants, haies comprises — à 3 cases par
seconde, et tiennent deux minutes. 18 dégâts toutes les 1,5 s chacune : énorme
en cumul, faible à l'instant. Elles n'exécutent personne, elles usent tout ce
qui traîne dans le labyrinthe pendant que le mage court aux gemmes.

### La version jetée : un phénomène qui SUIT le mage

Premier jet, écrit et retiré le jour même : une colonne unique qui accompagnait
le mage en traînant derrière lui (`Ability.storm_follow`, la machinerie du nuage
d'orage avec une vitesse de suivi). Ça marchait, c'était même joli — et c'était
le sort de quelqu'un d'autre. Si lentement qu'un phénomène suive son lanceur, il
reste le nuage d'orage du mage de la Foudre sous un autre dessin.

Ce qui distingue vraiment, c'est l'AUTONOMIE : ces colonnes-là ne suivent
personne. C'est le contrat de l'Invocateur — ça chasse pendant que le mage fait
autre chose — mais sans créature à nourrir, et à travers les murs.

`storm_follow`, la position propre du phénomène, le signal `storm_moved` et le
reparentage du nuage ont donc été retirés : soixante lignes sans utilisateur.
`test_combat._test_air_cyclone` garde une trace de l'erreur — il vérifie encore
que le sort n'est PAS un phénomène qui suit.

### TROIS, et c'est le nombre qui fait le sort

Une seule colonne se contourne ; trois quadrillent. C'est aussi ce qui rend
acceptable qu'elles soient lentes : à 3 cases/s elles ne rattrapent personne à
la course, mais elles coupent à travers les haies pendant que leurs proies font
le tour, et il y en a une devant.

Elles réutilisent la machinerie des invocations — donc le CombatSystem, donc
`test_balance` peut les faire chasser en headless — avec une entrée de plus dans
`SUMMON_KINDS`. Leurs coups ne déclenchent pas la bourrasque de l'Air : la règle
du projet veut qu'un trait élémentaire soit la signature du MAGE, pas de ce
qu'il envoie à sa place.

### Le dessin

`cyclone_spin.png` (huit images d'un tour, 4 x 2) et `cyclone_bolt.png` (amorce,
éclair, impact, retombée). Découpées par `build_spike_anim.py`, qui a appris
deux choses au passage :

- **une animation peut s'étaler sur plusieurs rangées** (`rangees_par_matiere`).
  Le tour du cyclone tient sur deux lignes de quatre : ce ne sont pas deux
  matières comme les cristaux et la pierre de l'éruption, c'est une seule
  animation qui se lit ligne par ligne ;
- **l'ancre « base »** : le PIED de la colonne se pose sur la case, comme la
  pointe du cône du Grand souffle se pose sur le mage. Calée sur son centre, la
  colonne se serait enfoncée dans le sol de la moitié de sa hauteur. Le pied est
  pris sur l'axe des MASSES et non sur le milieu de la boîte — le sommet du
  cyclone s'évase d'un côté et aurait tiré le pied avec lui.

⚠️ **Le cyclone n'est pas une créature, même s'il chasse comme elles.** Il n'a ni
faces ni pose de coup : `SummonVisual` n'aurait rien su lire de lui dans
`allies.json`. Il a donc son propre nœud (`CycloneColumn`), et `_on_summon_moved`
ne lui donne pas de direction — une colonne qui tourne n'en a pas, et la
retourner lui ferait changer de sens de rotation en pleine course.

`CycloneColumn` joue le tour à 13 images par seconde et fait LEVER la colonne :
la levée et la retombée se jouent sur la hauteur et non sur l'opacité, parce
qu'une colonne translucide se lit comme une colonne faible quand une colonne
courte se lit comme une colonne qui monte. `BoltStrike` pose la décharge sur la
victime, sans fondu entre images — un éclair claque, il ne se fond pas dans le
suivant.

⚠️ En passant : `dump_reference.gd` écrivait « ? » dans la colonne « type » pour
cinq familles de sorts (phénomène, chaîne, vague, ligne, tourelle) depuis leur
création. Un trou que personne ne remarque — la ligne reste lisible, le tableau
reste droit, et le type a simplement disparu. Les noms manquants sont écrits, et
un `push_warning` prévient à la prochaine famille oubliée.

## 2026-08-25 — le Grand souffle recadré

Deux défauts signalés sur le deuxième sort du Mage de l'Air, et une seule cause.

**Le cône était tranché.** Ses images 2 à 5 sortaient coupées net à la verticale.
`wind_blast.png` n'est pas sur sa grille : ses images GRANDISSENT — un cône qui
s'ouvre, une onde qui s'élargit — et le générateur les a resserrées vers la
gauche. Les vraies séparations tombent 35 à 72 px avant les lignes régulières,
et une découpe à la colonne rabotait donc chaque image un peu plus que la
précédente. `row_cuts()` prend maintenant les gouttières les plus larges.

⚠️ Contrairement aux planches de mages, la RÉGULARITÉ ne peut pas servir de juge
ici : les images ne sont pas également espacées, elles grandissent. C'est la
largeur du vide qui tranche — les gouttières parasites, à l'intérieur d'une onde
qui s'ouvre, sont toutes bien plus fines que celles qui séparent deux images.

**L'onde n'était centrée sur rien.** Chaque image la posait ailleurs dans sa
boîte : jouée, elle sautait, et le mage n'était au centre d'aucune. La boîte
commune de l'outil était calée sur la CASE, ce qui suffit à une gerbe de pierre
qui pousse toujours du même point, pas à un dessin qui dérive.

Chaque famille a maintenant son ANCRE, et c'est le moteur qui l'impose
(`src/fx/wind_blast.gd`) : l'onde est un Sprite2D CENTRÉ sur le mage, le cône
est décentré pour que son bord gauche tombe sur lui. On cale donc l'onde sur le
centre de son anneau, le cône sur sa POINTE — et la boîte est bâtie AUTOUR de
l'ancre, ce qui la rend immobile d'une image à l'autre.

⚠️ Une boîte commune ne suffit pas : il la faut SYMÉTRIQUE. Bâtie sur les
débordements réellement mesurés, elle ne l'était pas — l'onde s'étale plus vers
le bas que vers le haut — et l'ancre se retrouvait 28 px sous le milieu de
l'image. Le moteur pose ce sprite centré : ce qui n'est pas au milieu de l'image
n'est pas sur le mage.

Vérifié à la mesure : la pointe du cône est à x = 0 sur les six images, son axe
à moins d'un demi-pixel du milieu ; le centre de l'anneau est à moins d'un
demi-pixel du centre de l'image sur les six.

## 2026-08-25 — les huit mages redessinés sur le même gabarit

Les huit planches avaient été dessinées séparément, et chacune occupait la case
commune comme elle voulait : **de 60 % (Feu) à 93 % (Invocateur)**. Un mage
paraissait donc plus petit qu'un autre sans qu'aucune règle du jeu ne le
justifie. Huit planches neuves, commandées sur le même gabarit — 6 x 4 cases de
256, personnage à 80 % de la hauteur, pieds près du bas.

**Résultat : 62 à 66 %, écart entre mages x1,07** au lieu de x1,55.

Les anciennes planches restent en place et ne sont PAS écrasées : elles sont
encore la source de l'orbe, de l'impact, de la zone et de la colonne de
téléportation de chaque mage (`build_spell_fx.py`, `build_warps.py`), découpés à
des coordonnées relevées à la main dedans. Les planches d'effets de la refonte
n'étant pas encore arrivées, les deux jeux coexistent — le personnage vient des
neuves, ses effets des anciennes.

Six pièges, dont quatre se félicitaient eux-mêmes :

1. **les nouvelles planches n'ont pas de canal alpha.** Elles arrivent en RGB
   sur un gris uni — c'est ce que le prompt demande, un fond uni se relisant
   mieux qu'un alpha que les modèles tiennent mal. Converties en RGBA, elles
   sont opaques d'un bord à l'autre : le découpage a rendu huit carrés gris
   parfaitement identiques, et la mesure de remplissage a annoncé fièrement
   **78 % pour tout le monde**. Un défaut qui se félicite lui-même est le pire
   de tous. D'où `keyed_on_flat()`, qui ne retire le fond que là où il TOUCHE LE
   BORD, de proche en proche : une pénombre au creux d'une capuche a beau avoir
   la couleur du fond, elle n'y est pas reliée ;
2. **la pose d'attaque est dessinée À CHEVAL sur la ligne.** Mesuré sur les huit
   planches et les quatre rangées : le mage qui lance son sort déborde de 40 à
   125 px dans la case de gauche. Le générateur centre cette pose sur son SORT,
   pas sur son mage. Découpée à la ligne théorique, elle perdait son lanceur —
   le corps, dont le centre tombe à gauche, était rendu à la case voisine, et il
   ne restait dans la case d'attaque que la boule de feu. **22 % de remplissage
   au lieu de 65 sur les Ténèbres.** `_attack_box()` cherche donc la vraie
   séparation : la plus large bande vide AYANT DE L'ENCRE DES DEUX CÔTÉS ;
3. **`check_characters.py` annonçait « les 0 planches sont bien découpées ».**
   Il ne reconnaissait plus une entrée de mage (la clé porte maintenant son
   sous-dossier, et la grille est imposée au lieu d'être détectée), sautait donc
   les huit, et concluait au succès. Réécrit : il ne compare plus une détection
   à la réalité — il n'y a plus de détection — mais mesure les trois défauts que
   les prompts visent, **et il les mesure sur la BANDE DÉCOUPÉE**. Mesurer le
   remplissage sur la planche revenait à mesurer le débordement que le découpage
   retire : la pose de profil du Feu y pèse 89 % de sa case à cause de la fumée
   de la rangée du dessus, et 58 % une fois rendue à sa voisine ;
4. **la pose d'attaque ne se mesure pas comme les autres.** Elle porte le sort
   en plus du mage : la faire entrer dans l'écart de marche accusait les huit
   planches d'un coup, ce qui est le signe d'un contrôle faux et non de huit
   planches fausses.

**5. La grille annoncée n'est pas celle qui est dessinée.** Les planches
respectent leurs 6 x 4 cases dans l'ensemble, mais chaque pose y flotte : une
écharpe, un éclair, un pan de cape franchissent régulièrement une ligne. La
bande de face du Mage de l'Air est sortie avec une écharpe volée à la pose
suivante et un lanceur amputé — pendant que le contrôleur annonçait huit
planches irréprochables, puisqu'il ne mesurait que des hauteurs. Chaque pose est
maintenant découpée sur sa vraie GOUTTIÈRE.

⚠️ Et le choix de la gouttière a demandé trois essais. « La plus large » allait
chercher celle de la pose suivante sur une rangée dont les poses dérivent ; « la
plus proche » préférait le vide entre le mage et son orbe. **Une rangée demandait
l'inverse de l'autre.** Ce qui tranche est ce qu'on SAIT de la planche — six
poses également espacées : on essaie les combinaisons de cinq gouttières et on
garde celle qui donne les cases de marche les plus régulières.

**6. Le Sorcier des Ténèbres, vu de dos, est une robe NOIRE sur un gris très
foncé.** Un quart de ses pixels sont à une distance de 2 ou 3 du fond,
c'est-à-dire dans le bruit de la planche (p99 = 2) : aucune clé par couleur ne
peut les distinguer, et un seuil confortable lui mangeait les trois quarts du
corps — il ne restait qu'une capuche violette et une orbe flottante. Le seuil ne
sert donc plus qu'à FAIRE COULER le fond depuis les bords, et c'est la connexité
qui travaille : ce qui est de la couleur du fond mais enfermé dans une
silhouette n'est jamais atteint. Le fondu du bord, lui, ne s'applique qu'au bord
— appliqué partout, il rendait translucide l'intérieur des robes sombres.

Le contrôle qui porte toute la refonte est le dernier ajouté : **l'écart ENTRE
mages**. Chacun peut être irréprochable pris à part et l'ensemble rester bancal
— c'était exactement l'état d'avant.

L'Invocateur a rejoint la table commune de `build_characters.py` : sa nouvelle
planche a une grille régulière, là où l'ancienne posait ses poses librement.
`build_invocateur.py` ne découpe donc plus le mage — il ne garde que ce que lui
seul sait faire, les créatures invoquées et leurs effets — mais sa fonction
`build_mage` reste, inappelée et entière : le jour où l'on redécoupe depuis
l'ancienne planche, il faut ce code et non un souvenir.

## 2026-08-25 — la Faille des ténèbres déchire au lieu d'exploser

L'ultime du Sorcier des Ténèbres faisait 110 dégâts sur 6 cases. Même geste que
son Implosion, même lecture, un chiffre trois fois plus haut : rien qui
ressemble à un ULTIME. La règle du projet dit qu'un ultime a le droit de casser
une règle du jeu ; celui-là n'en cassait aucune.

Il en casse deux maintenant. **Il agit loin du lanceur** — trois failles
s'ouvrent près des poursuivants les plus proches, quand tous les autres sorts du
jeu partent du mage. Et **il continue d'agir deux minutes**, quand tout le reste
se joue en une seconde.

Deux ombres par faille, six au plus. Elles chassent avec la machinerie des
invocations (`_update_summons`), donc dans le CombatSystem et non dans le Level
— la simulation d'équilibrage les fait chasser en headless avec les règles du
jeu. Leur souffle est un gaz : portée d'une case et demie là où les marcheurs
frappent au contact, 12 dégâts, et surtout le **poison** de 3 PV/s emprunté à
l'Implosion. Le kit du mage se tient enfin d'un bout à l'autre : la Rune retient,
l'Implosion rassemble et empoisonne, la Faille envoie ce qui empoisonne.

Trois arbitrages qui auraient pu partir de travers :

- **une porte par ennemi aurait été la fin de la partie.** À huit poursuivants,
  seize ombres nettoient le labyrinthe pendant que le joueur regarde. Trois
  portes prennent la meute qui arrive — celle qu'on avait sous les yeux en
  lançant le sort — et laissent le reste au joueur ;
- **les portes visent les plus PROCHES, pas les plus faibles.** Un ciblage malin
  qui irait chercher le blessé à l'autre bout du labyrinthe se lirait comme un
  bug : le joueur lance son ultime en voyant une meute lui arriver dessus ;
- **sans proie, le sort est refusé** et ne coûte rien. Il se gagne en quatre
  kills : le dépenser dans un couloir vide serait un vol pur.

La porte réutilise le portail de la Rune, joué plus vite et affiché 2,4 s. Ce
n'est pas une économie de dessin : c'est le même passage, ouvert pour soi au sol
ou déchiré au loin, et le joueur doit le reconnaître.

### La planche, arrivée dans la foulée

`ombre_malefique.png` respecte le prompt case pour case : 4 x 5, fond magenta,
profil tourné à gauche. Découpée par **`tools/build_ombre.py`** — un outil de
plus et non une entrée dans `build_invocateur.py`, parce que la clé de fond ne
pouvait pas être la même :

⚠️ **la clé des icônes DISSOUT cette créature.** `build_skill_icons.keyed()`
retire « ce qu'un pixel a de rouge ET de bleu en plus de son vert » — la
signature du magenta, mais aussi celle du VIOLET, et l'ombre est violette d'un
bout à l'autre. On sépare ici sur la seule chose qui distingue vraiment le fond
du sujet : le fond a son rouge et son bleu À ÉGALITÉ (|r-b| ≈ 5), le gaz violet
a une teinte mesurée à 277°, c'est-à-dire beaucoup plus de bleu que de rouge.

⚠️ **les dessins débordent de leur case.** Le prompt demandait 40 px de marge ;
la fumée de la rangée 1 descend cinq pixels dans la case de la rangée 2. Une
découpe à la grille aurait coupé les traînées et semé des fragments en haut des
cases voisines. On découpe avec débordement et chaque forme connexe revient à la
case où tombe son centre — la règle de `build_characters._claim_cell`.

⚠️ **l'alignement se fait sur la CAPUCHE, pas sur le bas.** Les seize poses ont
été calées sur le haut du corps : la créature lévite, sa fumée traîne à des
hauteurs différentes selon la pose (40 px d'écart mesurés entre le profil et le
dos) et le souffle en projette encore plus bas. Ce que l'œil suit chez une
créature qui flotte, c'est sa tête.

Quatre directions écrites sur le disque, la droite étant le miroir de la gauche
— le moteur lit un dossier sans avoir à deviner quoi retourner.

### Les deux rangées manquantes

La première planche ne dessinait le souffle que de FACE : trois attaques sur
quatre ne montraient rien. Plutôt que de tout régénérer — un modèle d'image ne
redessine pas deux fois le même personnage, on aurait jeté une planche réussie
pour en obtenir une autre — on a demandé **les deux rangées manquantes seules**,
la planche existante jointe en référence (`ombre_souffle.png`, addendum de
`docs/prompts/sorts/ombre_malefique.md`). Le même outil les découpe, et l'ÉLAN de frappe qui
servait de pis-aller a été retiré : il n'avait plus aucun cas où s'appliquer.

Six pièges, tous mesurés, tous consignés dans `build_ombre.py` :

1. **la planche d'appoint n'est pas à la même échelle** — 22 % plus grande
   (manteau de 238 px contre 192 de dos). Sans correction, l'ombre enflait d'un
   cinquième au moment de souffler. On remet chaque rangée à l'échelle de la vue
   qu'elle prolonge, en comparant la LARGEUR DU MANTEAU : la hauteur ne vaut
   rien, elle enfle avec le jet ;
2. **la toile d'alignement doit grandir de ce qu'on descend.** Décaler une pose
   dans une toile de sa taille d'origine lui coupe le bas. Tant que tout venait
   d'une seule planche les décalages étaient de quelques pixels ; la seconde, à
   la capuche bien plus basse, a fait tomber cent pixels de fumée sous la toile
   — **la créature a rétréci d'un tiers sans un mot** ;
3. **on n'étiquette pas sur le voile.** À alpha > 24, les quatre poses de profil
   ne font qu'UNE forme connexe : les volutes les plus ténues d'un souffle
   effleurent la fumée d'à côté. Trois cases sur quatre ressortaient vides. On
   sépare sur ce qui est FERME (alpha > 110), puis on rend le voile au
   propriétaire le plus proche ;
4. **on ne sonde pas un point.** Le milieu de la boîte du manteau tombe dans un
   TROU sur trois poses sur quatre — une silhouette encapuchonnée est creuse
   entre sa tête et ses bras. On prend la forme qui contient le PLUS de manteau ;
5. **une rangée a des créatures ou elle n'en a pas**, et ça se décide pour la
   rangée entière. Les nuages de la rangée du gaz seul ont des cœurs assez
   foncés pour passer pour des manteaux dès qu'on desserre le seuil : deux se
   faisaient ancrer pendant que les deux autres étaient aspirés par leurs
   voisins ;
6. **un souffle ne part que d'un côté**, et du même côté pour toute la rangée.
   Il reste sinon des bouffées du jet VOISIN : sa tête part si loin qu'elle se
   pose derrière la créature d'à côté, et aucune mesure de distance ne peut
   deviner qu'elle ne lui appartient pas. Le sens du souffle, lui, le dit. La
   règle ne mord que si la rangée penche franchement — sur le souffle de face,
   le gaz descend et se répartit, rien n'est retiré.

Le jet de profil est enfin ROGNÉ : il porte à 294 px de l'axe, une case qui le
contiendrait ferait 588 px de large pour une créature qui en occupe 165, et le
moteur mettant la CASE à l'échelle, l'ombre y paraîtrait minuscule. On garde son
départ et on laisse filer sa queue — laquelle tombe là où `GasPuff` pose déjà
son nuage sur la victime. Le dessin rogné est celui qui faisait doublon.

Vérifié à la mesure et non à l'œil : sur les 32 poses, l'axe du manteau est à 0
du centre de sa case et la capuche à y = 174. Aucun sursaut possible.

La rangée du GAZ SEUL sert vraiment : `GasPuff` la joue **sur la victime** et
non sur le souffleur. La créature a sa pose de souffle ; ce qui manquait à
l'écran était l'endroit où le nuage ARRIVE — sans quoi on voit une ombre
gesticuler et un ennemi perdre des points de vie sans lien visible entre les
deux. Quatre poses fondues deux à deux, comme le portail de la Rune.

Le pis-aller (`SummonVisual.STAND_INS`) a servi une heure et est maintenant
vide. Le mécanisme reste — c'est la quatrième créature ajoutée au jeu — mais
sans entrée qui traîne : elle masquerait un découpage cassé derrière un
remplacement convaincant.

⚠️ **Non mesuré :** six chasseurs pendant deux minutes est probablement le sort
le plus fort du jeu, et `test_balance` ne tient toujours pas dans le temps
disponible. Le chiffre à baisser en premier est le nombre de portes.

Couvert par `test_combat._test_shadow_rift` : refus sans proie, une porte par
créature jusqu'au plafond, deux ombres par porte, portes ouvertes SUR les proies
et non aux pieds du mage, et chasse effective avec poison en 12 s simulées.

## 2026-08-25 — l'Explosion d'ombre devient une IMPLOSION

Le troisième créneau du Sorcier des Ténèbres était une explosion ordinaire :
34 dégâts sur 2,6 cases. C'est-à-dire **son propre ultime en plus petit** — la
Faille des ténèbres fait 110 sur 6 cases, même forme, même geste. Dans un kit de
cinq sorts, le troisième n'apprenait rien au joueur. Sa description mentait par
-dessus le marché : « elle repousse et blesse », alors que repousser est le trait
de l'AIR et que ce sort ne déplaçait personne.

Elle ASPIRE maintenant. `Ability.pull_radius` / `pull_cells` : les créatures à
4,6 cases sont ramenées de 3 cases vers le mage, PUIS l'explosion part sur 2,6.
Le souffle porte donc plus loin que les dégâts, et c'est tout le sort — le joueur
convertit de la distance en dégâts au lieu d'en gagner.

`_haul_in` est le miroir exact de `_push_away`, à un signe près sur la
comparaison du champ. C'était voulu : l'Air écarte, l'Ombre ramène, et deux
éléments qui déplaceraient dans le même sens ne se distingueraient plus.

Ce que ça noue : on aspire la meute dans la Rune posée à ses pieds, elle y rampe
à 18 % et s'y use à 10 PV/s, et les deux translations restent là pour ressortir.
Trois sorts qui se répondent, là où il y avait trois sorts sans rapport. Et
c'est le seul mage du jeu qui ATTIRE ses poursuivants, à 3 PV — vérifié en jeu :
le dragonnet ramené a touché le mage dans la seconde. Le risque est le sort.

Deux pièges rencontrés :

- **le champ de l'IA date de 300 ms.** Pris tel quel, il ramenait vers l'endroit
  où le mage était — exactement le défaut qui avait faussé l'arrêt au corps à
  corps. On recalcule depuis `player_cell`, via le cache d'une frame ;
- **une aspiration ne se dessine pas comme une explosion à l'envers.** Trois
  versions du VFX ont été jetées : des volutes radiales font une ÉTOILE, et une
  étoile est symétrique — rien n'y dit si les branches entrent ou sortent. C'est
  la SPIRALE qui tranche, un tourbillon n'ayant qu'un sens. Les deux autres
  finissaient sur un écran vide juste avant le claquement, l'anneau et les
  volutes atteignant zéro ensemble : d'où la « gorge » (`THROAT`), un fond
  d'anneau que l'ouverture reprend à la frame suivante.

Le VFX ne se jugeait pas en jeu — il dure deux tiers de seconde et le mage n'est
jamais au même endroit d'un lancer à l'autre, si bien que `--frames` tombait
tantôt avant, tantôt après. D'où `tools/preview_implosion.gd`, qui pose six
copies à six instants sur une bande, et `--skill-delay` pour lancer un sort une
fois les poursuivants sortis.

**Deux corrections le jour même**, après essai en jeu :

1. **elle livrait son lanceur.** Le souffle déposait les poursuivants AU CONTACT
   du mage, qui frappaient dans la seconde : le sort offrait le coup qu'il
   devait éviter. `Ability.pull_min` arrête l'aspiration à deux cases — la meute
   est rangée sur un anneau, dans l'explosion (rayon 2,6) mais hors de portée
   des griffes. Elle ne repousse personne pour autant : une créature déjà collée
   y reste, le sort corrige ce qu'il provoque et non ce qu'il trouve ;
2. **l'ombre reste.** Une flaque noire de quinze secondes est laissée là où tout
   le monde vient d'être rassemblé (`residue_duration`), et elle empoisonne :
   1 PV par seconde pendant 15 s, poison qui SUIT sa victime dehors. L'explosion
   cesse d'être un instant pour devenir un LIEU, et c'est ce qui donne son prix
   au fait d'y avoir tiré la meute.

Le poison tique à la SECONDE et non au demi-tick des zones : `damage * ZONE_TICK`
sur un dégât de 1 s'arrondit à 1 par demi-tick, ce qui aurait fait 2 PV/s là où
la fiche en annonce 1. Un chiffre annoncé faux est pire qu'un chiffre faible.

15 PV au total contre 100 à 460 selon la créature : c'est peu, et c'est assumé —
ce sort n'achève pas par sa flaque, il installe un endroit où l'on ne veut pas
rester pendant que la Rune, elle, ronge pour de bon.

Côté image, la flaque est la seule zone du jeu qui ÉTEINT au lieu de s'allumer
(composition normale, comme la rune). Sa frange est faite de lobes de rayons
INÉGAUX : à taille égale ils se lisaient comme une rosace de cercles empilés,
c'est-à-dire une figure — exactement ce qu'une flaque ne doit pas être.

Couvert par `test_combat._test_shadow_implosion` : le souffle doit porter plus
loin que les dégâts, une créature à 4 pas doit être ramenée ET avoir encaissé
(ce qui vérifie l'ordre aspirer-puis-frapper), aucune ne doit finir sur le mage
ni en deçà de la butée, la butée doit rester dans le rayon, la flaque doit
empoisonner à 1 PV/s pile, et le poison doit continuer hors de la flaque.

## 2026-08-24 — la Rune retient et ronge

L'englu de la Rune était un compte à rebours : trois secondes à 80 % de
l'allure, prises à l'entrée. Un poursuivant traversait donc le portail sans
presque ralentir, et — pire — retrouvait sa vitesse en restant DEDANS. Une zone
qui rend l'allure à qui s'attarde en elle fait le contraire d'un piège.

Nouveau réglage : `Ability.slow_sustained`. Le drapeau ne change pas la valeur
de `slow_duration`, il en change le SENS — ce n'est plus la durée de l'effet
mais sa TRAÎNÉE, le temps qu'il faut pour repartir une fois dehors. Tant que la
créature est dans le rayon, l'englu est réarmé à chaque frame. La Rune passe
donc de « 3 s à 80 % » à « 18 % de l'allure tant qu'on y reste, 0,5 s de
traînée ».

**Première version, jetée le jour même :** les dégâts avaient gardé le verrou du
péage — 10 PV une seule fois par passage. Erreur de conception, et elle se voit
dès qu'on l'écrit : retenir quelqu'un sans rien lui prendre pendant qu'il est
retenu, c'est offrir l'immobilisation. Un ennemi englué dix secondes payait le
même prix que celui qui traversait en courant. `Ability.damage_once` n'avait
donc plus aucun usage et a été retiré ; la Rune est redevenue une zone
ordinaire côté dégâts — 10 PV par seconde, sur le tick de zone.

Le chiffrage tient : huit secondes pleines coûtent 80 PV, quand le spectre du
stage 1 en a déjà 100 et le Golem de Givre 460. La rune use, elle n'exécute pas.

Deux points non évidents :

- **retenir et ronger vont ENSEMBLE.** C'est la leçon de la version jetée : un
  englu soutenu posé sur un prélèvement unique punit le passage, pas la
  présence, et laisse le temps perdu dedans entièrement gratuit ;
- **l'englu se réarme par frame, les dégâts au tick.** À 0,5 s de tick, la
  traînée de 0,5 s expirerait entre deux passages et l'ennemi retrouverait son
  allure deux fois par seconde. Les dégâts, eux, n'ont aucune raison de sortir
  du tick : c'est une usure, pas une rafale. Le champ de distances passe par le
  cache d'une frame (`_field_from`), sinon c'est un BFS par zone et par frame.

Couvert par `test_combat._test_rune_drain` : 3 s sur la rune doivent coûter
~30 PV et ~180 réarmements d'englu, et la sortie doit tout couper net.


## 2026-11-01 — la glace et le geyser de l'Eau, la foudre, et des bruits spécialisés

Un seul bruit (`fire_noise.png`) nourrissait tous les shaders. `tools/build_noise.py`
génère maintenant `thunder_noise.png` et `ice_noise.png`, chacun avec un canal par usage.
Essai guidé par la base « Textures for VFX » de Simon Schreibt, comparé effet par effet
(`tools/preview_thunder.gd`, `tools/preview_water.gd`).

⚠️ **Un bruit dédié n'aide que si le shader le lit autrement, et pas partout.** Foudre :
gain net sur le nuage (vraies veines), léger sur le flash ; aucun sur l'étoile ; PIRE sur
le dard, trop petit pour porter des cassures fines. Ces deux derniers gardent l'ancien
bruit (`PaintedFx.NOISES`). Tester chaque effet avant d'étendre.

**Le Cercle glacé est enfin de la glace** (`water_ice.gdshader`, style `glace_peinte`) :
il était peint en mare calme alors qu'il se décrit comme une flaque gelée. Le gel part du
centre, et les plaques cèdent une à une à la fin de la zone. Les plaques sont précalculées
dans la texture : un Voronoï par pixel sur six cases, dix secondes durant, coûterait
davantage qu'une lecture.
⚠️ Le banc de comparaison ne juge pas la taille : à l'échelle du jeu, la première version
éblouissait et masquait les haies. Translucide, plaques deux fois plus petites.

**Le Geyser ne brûle plus** (`water_geyser.gdshader`) : un cœur blanc au milieu du jet est
la structure d'une flamme. Corps bleu strié de filets, parasol d'écume, gouttes, flaque.
⚠️ Il retombe d'un bloc : vidée par le bas, la colonne laissait sa couronne flotter comme
une méduse, ce que seule une capture en jeu a montré.

**La Vague, l'impact et la pluie, le Courant et le Bouclier, repris dans la foulée.**
- la Vague : son dos gardait un quart d'opacité au bout du quad et traînait un bord droit. Il
  s'effiloche maintenant en langues, en trois aplats, avec une écume nette ;
- ⚠️ son écume partait du seul milieu de la crête et s'empilait en une tache blanche. Seul
  le vrai nœud l'a montré : le banc ne dessine pas les particules ;
- l'impact et la pluie : huit gouttes inégales en cloche, une couronne, des ondes en ellipses
  cassées. Onze ronds réguliers se lisaient comme un cadran ;
- le Courant : trois bras inégaux qui se referment sur un puits sombre, plus un logo ;
- le Bouclier : surface qui respire lentement, reflets en croissant sur le bord, centre clair
  pour laisser voir le mage trente secondes durant.
Le Jet ne bouge pas : trop petit, même leçon que le dard.

⚠️ **Le Geyser coûte plus cher qu'avant** : mesuré sur M1, 90 colonnes à l'échelle du jeu,
1,6 ms par image pour l'ancien et 3,9 ms pour le nouveau, après avoir réduit le calcul de ses
gouttes à un sinus chacune. Le jeu n'en affiche que neuf à la fois, moins d'une seconde. Le
Mac ne dit rien du téléphone : à mesurer sur iPhone.

## 2026-11-01 — le Mage de la Foudre : Jugement, Champ, Orage, arcs et éclats

La Foudre mélangeait deux palettes : du jaune additif pour ses zones et ses éclats, du blanc
cerné de bleu pour ses shaders. L'additif brûlait sur l'herbe et la neige et effaçait ses
propres traits. **Tout est maintenant composé normalement : cœur blanc, cerne bleu.**

- `thunder_crest` : le Jugement au moment où il part. La foudre tombe du ciel sur le mage, le
  sol noircit et se fend, les ondes s'en vont. C'était deux zigzags dans un cercle ;
- `thunder_cloud` : ⚠️ une silhouette de lobes et non du bruit seuillé, qui faisait une tache
  d'encre. Le haut éclairé vient de la même masse décalée vers le bas : un reflet par lobe
  faisait une grappe de raisin ;
- `thunder_storm` (nouveau) : le nuage de l'Orage, clair et tournant, distinct du Jugement
  (un dessin par sort). Il remplace les ronds de `StormCloud`. ⚠️ `HEIGHT` monte à 2,05 : à
  1,5, le quad peint cachait la tête du mage ;
- `field.gdshader` : veines par saccades et arc brisé sur le bord. ⚠️ `ZoneEffect._draw` ne
  doit rien tracer pour le champ, ses anneaux jaunes revenaient par-dessus le shader ;
- `LightningArc` : milieu brisé sur trois passes, deux fourches, un changement de tracé à
  mi-vie. Il sert à la Chaîne, à l'Orage, au Jugement, à l'attaque et à la fuite ;
- `ImpactEffect` : la Foudre a ses éclats brisés (`Shape.ARC`). Ses ronds jaunes recouvraient
  le mage et sa cible. L'Air garde `SPARK`.

Le dard et l'étoile ne bougent pas. L'onde de choc de l'ultime (`shockwave`), commune aux
autres mages, n'est pas retouchée et voile encore un peu l'écran.

⚠️ **Le nouveau nuage coûte plus cher** : mesuré sur M1, 90 nuages à l'échelle du jeu, 1,55 ms
par image pour l'ancien et 3,75 ms pour le nouveau. Le Jugement en pose douze sur la carte, 15 s
durant, mais seuls ceux à l'écran comptent. À mesurer sur iPhone, avec les geysers de l'Eau.

## 2026-11-01 — le Suprême : une matière par canal, et un premier pack extérieur

`elements.gdshaderinc` nourrit tous ses sorts, d'où le gain pour un seul fichier. La terre
(une pâte brune) et l'air (des pétales de métal) lisent maintenant `supreme_noise.png` ; le feu
et l'eau gardent leur dessin, le canal R étant l'ancien bruit agrandi.

Les deux sources viennent du pack « 700+ Noise Textures » de Screaming Brain Studios, CC0
(`assets/raw/noise/`, exclu de l'export, voir `LICENCE.txt`) : `voronoi_12` pour les plaques
de la terre, `streak_4` pour les filets de l'air. Seules ces deux-là entrent dans le dépôt.
⚠️ Les repères de ces shaders sont petits (souvent polaires) : à l'échelle de l'ancien bruit, les
plaques étaient si grandes que la terre restait lisse. Il a fallu quadrupler la fréquence.
`tools/preview_supreme.gd` montre chaque matière sur sol sombre et clair.

## 2026-11-01 — le Cercle d'invocation prend du volume

Idées reprises, sans ses images, du pack « Arcane Magic Circles » de DucVu Fx, vu dans la base
« Textures for VFX » : des pleins plutôt que des traits fins, une colonne de lumière. Le pack
n'est pas acheté, et le cercle reste tracé au compas, sans bruit, comme le veut ce mage.

`arcane_circle.gdshader` : anneau à pleins et déliés, couronne de marques, triangles aux traits
effilés, trois lames au cœur, disque sombre et cerne pour tenir sur les sols clairs.
`arcane_pillar.gdshader` : la colonne jaillit à l'ouverture et n'est plus qu'un voile après 1,3 s,
car elle passe devant les couloirs. ⚠️ Son pied descend sous le centre du cercle et suit une
ellipse : coupée droit au centre du quad, elle faisait un rectangle gris.

## 2026-11-01 — les serviteurs de l'Invocateur

- **Gargouille et dragon** : la case d'une bête au sol est symétrique autour des pieds. Le
  souffle de la gargouille sortait de sa case et son aile s'imprimait sur la pose voisine.
  L'aile du dragon était coupée à plat par sa rangée (marge `DRAGON_ROW_MARGIN`).
- **Marcheurs** (`_walk_summon`) : ils vont au centre de la case choisie avant d'en choisir
  une autre. Ils coupaient le coin des haies (116 pas hors axe dans `test_combat`, zéro
  maintenant). Vaut aussi pour les ombres de la Faille. Passe rapide d'équilibrage verte.
- **Diablotin** : le chevalier du premier sort cède la place à un vrai diablotin
  (`docs/prompts/sorts/diablotin.md`), découpé par `build_invocateur.py` : 8 pas et 8 coups
  par direction, case 204 x 148. ⚠️ Les deux planches ne dessinent pas tout à fait la même
  bête : cornes rayées et oreilles plus petites sur l'attaque.

## 2026-11-01 — l'impact et la fuite de l'Invocateur

- **Deux dessins** : l'impact et le Pas du néant partageaient `arcane_sigil`. La fuite a
  maintenant `arcane_void_step` (un trou noir au sol, cinq bras, des éclats aspirés), et
  `test_animation` refuse qu'une fuite reprenne le dessin d'un autre effet.
- **Le sceau** (`arcane_sigil`) : frappé trop grand, écrasé à sa taille, puis il fond en trois
  éclats. Sans fondu : c'est le trait qui s'amincit. L'éclat tracé ne s'y ajoute plus, ses
  pointes blanches en brouillaient le triangle.
- **La traînée** : braises de 0,14 case pour ce mage (`WarpTrail.setup`). À 0,62, entassées sur
  une case, elles faisaient une tache blanche sur son visage. Les autres mages la gardent.
