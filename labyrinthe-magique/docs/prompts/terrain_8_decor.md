# terrain_8_decor — le SEMIS des couloirs du stage 8 (Les Ruines Anciennes)

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts.py`. Ne pas l'éditer à la
> main : corriger une consigne se fait dans la table de l'outil, puis on relance.
> Sinon la correction ne profite qu'à un stage sur dix.

Si le modèle rend mieux en anglais, demande-lui de **traduire ce prompt** avant
de générer : ça évite de maintenir soixante blocs en deux langues.

**Joins `ref/ref_8_decor.png` à ChatGPT** — ce sont les props de
`assets/stages/stage_8.png` — et dis « même style, même palette, mêmes contours ».

À quoi ça sert : `DecorLayer` sème un objet sur une case de couloir sur douze.
Les neuf objets actuels sont **générés en code** par `build_assets.py`, et sont
les mêmes aux dix stages. Ceux de la planche sont sans commune mesure.

Résultat attendu : `terrain_8_decor.png` dans `assets/peso&cover/terrain/`.

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
1.  une colonne de pierre brisée, posée debout
2.  un bloc de pierre gravé, couché
3.  un petit tas de dalles éboulées
4.  un arbre mort aux branches nues

Rangée 2
5.  un buisson à petites fleurs violettes
6.  un rocher gris couvert de mousse
7.  un groupe de trois cailloux clairs
8.  un crâne posé au sol

Rangée 3
9.  un chariot de bois à roues de fer
10. deux planches de bois clouées
11. un obélisque de pierre à gemme verte LUMINEUSE
12. une lanterne de fer, verre vert ALLUMÉ

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
