# portrait_dragon_eveil — Dragon Primordial

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.

L'Éveil du Dragon des Abysses, pour son bouton ÉVEIL de l'écran de sélection. Joins **deux images** à ChatGPT :

1. `assets/peso&cover/interface/portraits/portrait_dragon.png` — son portrait actuel : le STYLE, le
   cadrage et le visage à garder ;
2. `assets/peso&cover/mages/dragon_eveil_marche.png` — sa planche de marche éveillée : CE QU'IL DEVIENT.

Résultat attendu : `portrait_dragon_eveil.png` dans `assets/peso&cover/interface/portraits/`.

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

SUJET — Dragon Primordial : même dragon-démon bipède et massif aux écailles noir charbon et aux plaques rouge sang, mais le premier feu du monde se réveille en lui : QUATRE CORNES d'obsidienne où coulent des filets de lave, des yeux d'un blanc de magma, une gorge qui rougeoie entre ses crocs, et au milieu du torse un CŒUR DE MAGMA jaune et blanc qui bat entre des côtes d'obsidienne. Des pointes d'obsidienne hérissent ses épaules, la lave coule le long de ses bras, et ses ailes rouge sombre sont bordées de flammes. Il doit paraître plus puissant et
plus lumineux que dans la première image, sans devenir un autre personnage.

FOND : une simple nappe de couleur magma orange et rouge sang, sur un fond d'obsidienne et de fumée, plus lumineuse derrière le
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
