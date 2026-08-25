# terrain_2_decor — le SEMIS des couloirs du stage 2 (Le Canyon de la Foudre)

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts.py`. Ne pas l'éditer à la
> main : corriger une consigne se fait dans la table de l'outil, puis on relance.
> Sinon la correction ne profite qu'à un stage sur dix.

Si le modèle rend mieux en anglais, demande-lui de **traduire ce prompt** avant
de générer : ça évite de maintenir soixante blocs en deux langues.

**Joins `ref/ref_2_decor.png` à ChatGPT** — ce sont les props de
`assets/stages/stage_2.png` — et dis « même style, même palette, mêmes contours ».

À quoi ça sert : `DecorLayer` sème un objet sur une case de couloir sur douze.
Les neuf objets actuels sont **générés en code** par `build_assets.py`, et sont
les mêmes aux dix stages. Ceux de la planche sont sans commune mesure.

Résultat attendu : `terrain_2_decor.png` dans `assets/peso&cover/terrain/`.

```
Planche d'objets de décor pour un jeu 2D vu de DESSUS, style cartoon coloré,
contour marqué, même facture et même palette que l'image de référence jointe.

FORMAT, à respecter exactement :
- image de 1024 x 768 pixels
- grille RÉGULIÈRE de 4 colonnes x 3 rangées, soit 12 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
  portée sur le magenta
- aucun texte, aucun chiffre, aucune bordure dessinée

LES 12 OBJETS, de gauche à droite puis de haut en bas — un seul objet par case,
CENTRÉ, posé au sol, vu de dessus en légère plongée (on voit le dessus et un peu
la face avant, comme dans la référence) :

Rangée 1
1.  un amas de cristaux bleus dressés
2.  un amas de cristaux violets dressés
3.  un arbre mort foudroyé, branches nues et tordues
4.  un rocher violet arrondi

Rangée 2
5.  un groupe de trois cailloux violets de tailles différentes
6.  une souche de roche fendue
7.  un crâne blanchi posé au sol
8.  un tonneau de bois cerclé de fer

Rangée 3
9.  un chariot de mine en bois, roues de fer
10. une portion de clôture de bois brisée
11. une borne runique bleue à gravure LUMINEUSE
12. une torche sur pied à flamme bleue ALLUMÉE

RÈGLES ABSOLUES :
- chaque objet occupe environ 70 % de sa case et reste CENTRÉ, avec du magenta
  visible tout autour : rien ne touche le bord de sa case
- la MÊME échelle apparente d'une case à l'autre : ces objets seront posés côte
  à côte dans le même couloir. Un caillou aussi haut qu'un arbre serait faux
- la lumière vient du HAUT dans les douze cases
- l'ombre au sol est TRÈS légère et collée sous l'objet — pas de grande ombre
  portée qui déborderait sur le magenta
- les deux DERNIERS objets sont les seuls à ÉMETTRE de la lumière ; les dix
  autres ne brillent pas
- aucun personnage, aucun sol, aucun fond, aucun mur
- aucun cristal taillé en gemme à ramasser, aucune pierre précieuse isolée :
  ce sont les objectifs du jeu, le décor ne doit jamais les imiter
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Les objets n'ont pas la même échelle entre eux | relancer en insistant sur « MÊME échelle apparente » |
| Un objet touche le bord de sa case | rappeler « 70 % de la case, centré, magenta tout autour » |
| Une grande ombre portée sur le magenta | rappeler « ombre très légère, collée sous l'objet » |
| Tout brille | rappeler « seuls les deux DERNIERS émettent de la lumière » |

⚠️ Les cases 11 et 12 partent dans la liste **GLOWING** de `DecorLayer` — elles
reçoivent une lumière en jeu, contrairement aux dix autres. C'est pour ça
qu'elles sont toujours en dernier, à tous les stages. Voir
[../PROMPT_TERRAIN.md](../PROMPT_TERRAIN.md).
