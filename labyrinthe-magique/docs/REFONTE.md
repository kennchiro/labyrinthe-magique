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
