# Planches de terrain — dépose ici

Les images générées pour le terrain des stages arrivent **dans ce dossier**, avec
le nom exact attendu par les outils. Rien d'autre à faire : je les trouve seul.

Les prompts qui les produisent sont dans `docs/prompts/`, un fichier par planche.
L'index est [`docs/PROMPT_TERRAIN.md`](../../../docs/PROMPT_TERRAIN.md).

| # | Stage | Fichiers à déposer ici |
|---|---|---|
| 1 | La Forêt | `terrain_1_sol.png` · `terrain_1_mur.png` · `terrain_1_decor.png` |
| 2 | Le Canyon de la Foudre | `terrain_2_sol.png` · `terrain_2_mur.png` · `terrain_2_decor.png` |
| 3 | Les Dunes de Feu | `terrain_3_sol.png` · `terrain_3_mur.png` · `terrain_3_decor.png` |
| 4 | Les Rivages Océaniques | `terrain_4_sol.png` · `terrain_4_mur.png` · `terrain_4_decor.png` |
| 5 | Les Cavernes de Cristal | `terrain_5_sol.png` · `terrain_5_mur.png` · `terrain_5_decor.png` |
| 6 | Les Montagnes Glacées | `terrain_6_sol.png` · `terrain_6_mur.png` · `terrain_6_decor.png` |
| 7 | Le Bois d'Épine | `terrain_7_sol.png` · `terrain_7_mur.png` · `terrain_7_decor.png` |
| 8 | Les Ruines Anciennes | `terrain_8_sol.png` · `terrain_8_mur.png` · `terrain_8_decor.png` |
| 9 | Le Sanctuaire Déchu | `terrain_9_sol.png` · `terrain_9_mur.png` · `terrain_9_decor.png` |
| 10 | Le Château du Ciel | `terrain_10_sol.png` · `terrain_10_mur.png` · `terrain_10_decor.png` |

Formats attendus : `_sol` = 1024 x 1024 pleine image (pas de magenta) ·
`_mur` = 1024 x 1024, 16 cases de 256 sur magenta ·
`_decor` = 1024 x 768, 12 cases de 256 sur magenta.

**Un stage peut avancer seul.** Rien n'oblige à fournir les trente planches d'un
coup : les stages sans planche gardent leur terrain teinté actuel.

## Règles du dossier

- **le nom fait foi.** Les outils cherchent ces noms exacts. `terrain_1_sol (2).png`
  ou `ChatGPT Image 25 aout.png` ne seront pas trouvés — renomme avant de déposer ;
- **PNG uniquement.** Un JPEG n'a pas de canal alpha et rajoute du bruit de
  compression sur les bords de magenta, ce qui coûte une frange colorée au découpage ;
- **on ne remplace jamais un nom par un autre FORMAT.** Déposer un `.jpeg` à côté
  d'un `.png` du même nom a déjà silencieusement faussé trois tables de découpe
  sur ce projet (voir `docs/REFONTE.md`, stage 9) ;
- **garde les ratés.** Si une planche est mauvaise, renomme-la
  `terrain_1_mur_rate_1.png` plutôt que de l'écraser : comparer deux essais est
  souvent ce qui montre lequel des deux défauts corriger.

⚠️ Ce dossier est **exclu de l'export** (`*/peso&cover/terrain/*` dans
`export_presets.cfg`) : ces planches sont des sources de travail, elles ne
partent pas dans l'application. Ce sont les fichiers découpés d'`assets/tiles/`
et d'`assets/sprites/` que le jeu charge.
