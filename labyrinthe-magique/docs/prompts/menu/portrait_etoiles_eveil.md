# portrait_etoiles_eveil — Reine du Firmament

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.

L'Éveil de l'Ange des Étoiles, pour son bouton ÉVEIL de l'écran de sélection. Joins **deux images** à ChatGPT :

1. `assets/peso&cover/interface/portraits/portrait_etoiles.png` — son portrait actuel : le STYLE, le
   cadrage et le visage à garder ;
2. `assets/peso&cover/mages/etoiles_eveil_marche.png` — sa planche de marche éveillée : CE QU'ELLE DEVIENT.

Résultat attendu : `portrait_etoiles_eveil.png` dans `assets/peso&cover/interface/portraits/`.

```
Illustration de personnage pour un écran de sélection de jeu de rôle mobile,
style cartoon coloré à contours nets, personnage aux proportions héroïques
légèrement stylisées, EXACTEMENT la même facture et le même cadrage que la
PREMIÈRE image jointe.

La première image est le portrait du personnage. Dessine LE MÊME personnage,
transformé dans sa forme éveillée : la seconde image jointe montre cette forme
en petit, vue de dessus. Reprends ses couleurs et ses attributs, mais dessine-le
comme la première image : de face, en grand, avec son visage.

FORMAT : une seule image de 1024 x 1365 pixels (rapport 3:4, debout).

SUJET — Reine du Firmament : même femme adulte au visage calme, même longue tresse argentée, même longue robe bleu nuit à liserés d'argent et mêmes ailes bleu nuit semées d'étoiles, mais elle est devenue la reine de la nuit : sa couronne en croissant d'argent porte CINQ PETITES ÉTOILES D'OR PÂLE dressées comme des pointes, une longue CAPE DE NUIT bleu nuit doublée d'argent, semée d'étoiles et de constellations dessinées, tombe de ses épaules, et son sceptre d'argent porte une GRANDE ÉTOILE blanche à quatre branches, à cœur d'or pâle, cerclée d'un anneau d'argent. Ses yeux brillent d'un bleu stellaire clair. Le bleu nuit et l'argent restent ses couleurs, l'or n'est qu'en touches. Elle doit paraître plus puissante et
plus lumineux que dans la première image, sans devenir un autre personnage.

FOND : une simple nappe de couleur bleu nuit profond semé de petites étoiles blanches, avec une lueur bleu clair derrière elle, plus lumineuse derrière le
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
- aucune pose ni grille de la seconde image : une seule figure, en grand
- le fond n'est JAMAIS le magenta uni de la seconde image : c'est la nappe de
  couleur décrite plus haut
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Il ne ressemble plus au mage | rappeler « LE MÊME personnage que la première image, transformé » |
| Il est dessiné petit, vu de dessus | rappeler « de face, en grand, comme la première image » |
| Un cadre ou une bordure apparaît | rappeler « aucun cadre, le jeu ajoute le sien » |
| Le fond devient un décor | rappeler « une nappe de couleur, pas une scène » |
| Le fond est resté magenta | rappeler « la nappe décrite, jamais le magenta de la planche » ; sinon `NAPPES` dans `build_menu.py` le repeint |

Voir [../../PROMPT_MENU.md](../../PROMPT_MENU.md).
