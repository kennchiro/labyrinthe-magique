# portrait_peste_eveil — Seigneur du Fléau

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.

L'Éveil du Mage de la Peste, pour son bouton ÉVEIL de l'écran de sélection. Joins **deux images** à ChatGPT :

1. `assets/peso&cover/interface/portraits/portrait_peste.png` — son portrait actuel : le STYLE, le
   cadrage et le visage à garder ;
2. `assets/peso&cover/mages/peste_eveil_marche.png` — sa planche de marche éveillée : CE QU'IL DEVIENT.

Résultat attendu : `portrait_peste_eveil.png` dans `assets/peso&cover/interface/portraits/`.

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

SUJET — Seigneur du Fléau : même capuche et même long manteau presque noir à liserés vert acide, mais son masque est devenu un CRÂNE-BEC DE BRONZE dont les deux verres ronds brûlent de vert acide. Le bas de son manteau est en lambeaux, effrangé en pointes, des PLAQUES DE BRONZE gravées de runes couvrent ses épaules, et son bâton tordu porte un ENCENSOIR de bronze ajouré plein d'un liquide vert qui luit. Les fioles de sa ceinture sont plus nombreuses et bouillonnent. Il doit paraître plus puissant et
plus lumineux que dans la première image, sans devenir un autre personnage.

FOND : une simple nappe de couleur vert acide et bronze sombre, comme une brume empoisonnée, plus lumineuse derrière le
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
