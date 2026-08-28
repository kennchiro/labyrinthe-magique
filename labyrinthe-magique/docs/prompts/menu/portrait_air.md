# portrait_air — Mage de l'Air

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.

**Joins `../ref/ref_carte.png` à ChatGPT** — c'est une carte de la maquette
`selection_mage1.jpeg` — et dis « même style de personnage, mais SANS le cadre
ni le texte ».

Résultat attendu : `portrait_air.png` dans
`assets/peso&cover/interface/portraits/`.

```
Illustration de personnage pour un écran de sélection de jeu de rôle mobile,
style cartoon coloré à contours nets, personnage aux proportions héroïques
légèrement stylisées, même facture que l'image de référence jointe.

FORMAT : une seule image de 1024 x 1365 pixels (rapport 3:4, debout).

SUJET — Mage de l'Air : une robe BLANCHE et bleu très pâle, une longue écharpe qui flotte loin derrière lui, une capuche rejetée en arrière sur un visage calme et VISIBLE. Un bâton pâle surmonté d'une plume, des spirales de vent translucides autour de ses pieds — il ne touche pas tout à fait le sol.

FOND : une simple nappe de couleur blanc bleuté, très clair, comme un ciel d'hiver, plus lumineuse derrière le
personnage et plus sombre vers les bords, comme un halo. Rien d'autre : ni
paysage, ni objet, ni motif.

RÈGLES ABSOLUES :
- le personnage est ENTIER, debout, de face, légèrement de trois quarts, et
  regarde le joueur. On voit ses pieds et le haut de sa tête
- il occupe environ 80 % de la hauteur de l'image et reste CENTRÉ
- aucun CADRE, aucune bordure, aucun liseré, aucune vignette : le cadre est
  ajouté par le jeu, un cadre dessiné ici se superposerait au sien
- aucun TEXTE, aucun nom, aucun chiffre, aucun logo
- aucun sol, aucun décor, aucune ombre portée au sol : le fond est une nappe de
  couleur, pas une scène
- aucun autre personnage
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Un cadre ou une bordure apparaît | rappeler « aucun cadre, le jeu ajoute le sien » |
| Le personnage est coupé aux genoux | rappeler « ENTIER, on voit ses pieds » |
| Le fond devient un décor | rappeler « une nappe de couleur, pas une scène » |
| Le visage ne ressemble pas au sprite du jeu | rejoindre la planche `mages/mage_*.png` en seconde référence |

⚠️ Le NOM du mage n'est jamais dans l'image : c'est du texte dessiné par le jeu,
qui doit rester lisible à toutes les tailles. Voir
[../../PROMPT_MENU.md](../../PROMPT_MENU.md).
