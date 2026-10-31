# Le bestiaire — fiches de référence

> ⚙️ **Fichier GÉNÉRÉ.** Ne pas éditer à la main : `godot --headless --path . --script res://tools/dump_reference.gd`.
> La source est `src/entities/bestiary.gd` et `src/core/level_config.gd`.

Les valeurs sont des **rapports**, pas des absolus. Le Spectre est
l'unité — c'est sur lui que tout l'équilibrage a été mesuré — et les
points de vie de chaque espèce s'en déduisent :
`PV = LevelConfig.hunter_health × robustesse`.

## Vue d'ensemble

| Créature | Apparaît | Robustesse | Vélocité | Coup | Repos | Ce qu'elle est |
|---|---:|---:|---:|---:|---:|---|
| **Spectre** | stage 1 | ×1.00 | ×1.00 | 0.60 s | 0.55 s | lévite lentement, charge son coup à bout de bras |
| **Gobelin** | stage 2 | ×1.37 | ×1.00 | 0.22 s | 0.28 s | petit, coriace, frappe vite et souvent |
| **Serpent d'Émeraude** | stage 3 | ×0.82 | ×1.16 | 0.30 s | 0.30 s | file dans les couloirs, mais se brise au premier sort |
| **Ombre Encapuchonnée** | stage 4 | ×1.10 | ×1.12 | 0.45 s | 0.40 s | glisse sans bruit, rattrape en ligne droite |
| **Dragonnet de Feu** | stage 5 | ×1.20 | ×1.14 | 0.35 s | 0.35 s | vole, donc ne ralentit jamais dans les virages |
| **Golem de Lave** | stage 6 | ×1.90 | ×0.80 | 0.50 s | 0.55 s | une masse : on ne le sème pas, on l'use — et il jette de loin |
| **Archer d'Os** | stage 7 | ×1.05 | ×1.00 | 0.28 s | 0.34 s | sec et rapide du geste, fragile au contact |
| **Démon de Cristal** | stage 8 | ×1.70 | ×0.86 | 0.45 s | 0.50 s | blindé de cristal, lourd à déplacer |
| **Minotaure** | stage 9 | ×1.60 | ×1.10 | 0.30 s | 0.36 s | charge : robuste ET rapide, la pire combinaison |
| **Chevalier Noir** | stage 10 | ×1.45 | ×1.02 | 0.34 s | 0.38 s | bouclier et lame, sans faiblesse marquée |
| **Golem de Givre** | stage 10 | ×2.00 | ×0.78 | 0.52 s | 0.58 s | le plus dur du bestiaire, et le plus lent |

**Robustesse** multiplie les PV, **vélocité** la vitesse du stage.
**Coup** est la durée de la pose de frappe, **repos** le temps mort
qui la suit — sans lui, un ennemi collé au mage relance son geste à
la frame près et l'animation devient un battement continu.

## Points de vie, stage par stage

Ce que chaque espèce encaisse réellement, une fois le rapport appliqué
à la référence du stage.

| Créature | St.1 | St.2 | St.3 | St.4 | St.5 | St.6 | St.7 | St.8 | St.9 | St.10 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| **Spectre** | 100 | 135 | 165 | 175 | 184 | 193 | 203 | 212 | 221 | 230 |
| **Gobelin** | — | 185 | 226 | 240 | 252 | 264 | 278 | 290 | 303 | 315 |
| **Serpent d'Émeraude** | — | — | 135 | 144 | 151 | 158 | 166 | 174 | 181 | 189 |
| **Ombre Encapuchonnée** | — | — | — | 193 | 202 | 212 | 223 | 233 | 243 | 253 |
| **Dragonnet de Feu** | — | — | — | — | 221 | 232 | 244 | 254 | 265 | 276 |
| **Golem de Lave** | — | — | — | — | — | 367 | 386 | 403 | 420 | 437 |
| **Archer d'Os** | — | — | — | — | — | — | 213 | 223 | 232 | 242 |
| **Démon de Cristal** | — | — | — | — | — | — | — | 360 | 376 | 391 |
| **Minotaure** | — | — | — | — | — | — | — | — | 354 | 368 |
| **Chevalier Noir** | — | — | — | — | — | — | — | — | — | 334 |
| **Golem de Givre** | — | — | — | — | — | — | — | — | — | 460 |

## Qui rencontre-t-on, et où

Le roster est **cumulatif** : le stage 7 contient encore le spectre du
stage 1. C'est ce qui fait sentir la progression — non pas « d'autres
ennemis » mais « les mêmes, plus quelque chose de neuf ».

| Stage | Nom | Nouveauté | Effectif | Vitesse | Détection |
|---:|---|---|---:|---:|---:|
| 1 | La Forêt | Spectre | 3 | ×0.74 | 6 cases |
| 2 | Le Canyon de la Foudre | Gobelin | 4 | ×0.76 | 7 cases |
| 3 | Les Dunes de Feu | Serpent d'Émeraude | 6 | ×0.80 | 8 cases |
| 4 | Les Rivages Océaniques | Ombre Encapuchonnée | 6 | ×0.78 | 8 cases |
| 5 | Les Cavernes de Cristal | Dragonnet de Feu | 6 | ×0.79 | 8 cases |
| 6 | Les Montagnes Glacées | Golem de Lave | 7 | ×0.79 | 8 cases |
| 7 | Le Bois d'Épine | Archer d'Os | 7 | ×0.80 | 9 cases |
| 8 | Les Ruines Anciennes | Démon de Cristal | 7 | ×0.81 | 9 cases |
| 9 | Le Sanctuaire Déchu | Minotaure | 8 | ×0.81 | 9 cases |
| 10 | Le Château du Ciel | Chevalier Noir, Golem de Givre | 8 | ×0.82 | 9 cases |

## Les créatures de l'Invocateur

Elles ne sont pas du bestiaire : ce sont des **alliées**, invoquées par
l'Invocateur, et elles chassent les créatures ci-dessus. Leurs règles
vivent dans `CombatSystem.SUMMON_KINDS`.

| Créature | Appelée par | Nombre | Durée | Vitesse | Dégâts | Cadence | Portée | Déplacement |
|---|---|---:|---:|---:|---:|---:|---:|---|
| **imp** | Diablotins | 2 | 30 s | 2.8 c/s | 10 | 0.9 s | 1.1 case | suit les couloirs |
| **gargouille** | Gargouille | 1 | 40 s | 4.0 c/s | 18 | 1.1 s | 1.1 case | suit les couloirs |
| **dragon** | Dragon ancien | 1 | 120 s | 3.6 c/s | 34 | 1.3 s | 10.0 case | vole par-dessus les murs |
| **ombre** | — | 0 | 0 s | 4.2 c/s | 12 | 1.1 s | 1.5 case | suit les couloirs |
| **cyclone** | — | 0 | 0 s | 3.0 c/s | 18 | 1.5 s | 1.4 case | vole par-dessus les murs |

Il n'y en a jamais plus de **4** à la fois (au-delà, la plus ancienne
cède la place). Leurs kills nourrissent l'extra du mage, mais leurs
coups ne déclenchent **pas** de trait élémentaire : le trait est la
signature du mage, pas celle de ses bêtes.