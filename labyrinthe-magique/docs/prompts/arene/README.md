# L'Arène — les images à commander

✅ Les cinq planches sont LIVRÉES (sol, décors, gemme et fond le 2026-11-09, murs le 2026-11-10) et
découpées par `tools/build_arena.py` : le Colisée est le décor par défaut de l'arène.

| Planche | Fiche | À déposer dans |
|---|---|---|
| Le sol | [sol_arene](sol_arene.md) | `assets/peso&cover/terrain/arene_sol.png` |
| Les murs (haies, piliers, bornes) | [mur_arene](mur_arene.md) | `assets/peso&cover/terrain/arene_mur.png` |
| Les décors posés | [decor_arene](decor_arene.md) | `assets/peso&cover/decor/arene_decor.png` |
| La Gemme-Cœur et ses états | [gemme_coeur](gemme_coeur.md) | `assets/peso&cover/decor/arene_gemme.png` |
| Le fond de la préparation | [fond_arene](fond_arene.md) | `assets/peso&cover/interface/arene_fond.png` |

**Joins à chaque prompt une capture d'un stage existant** (par exemple
`assets/stages/stage_1.png`), et dis « même style, même palette, mêmes contours ».

Les planches passent TOUJOURS par `tools/build_arena.py`, jamais telles quelles dans `assets/`.
Le générateur n'a suivi ni l'ordre des décors ni la rangée « gemme seule » : l'outil le sait (voir
son en-tête), à revérifier si une planche est refaite.
