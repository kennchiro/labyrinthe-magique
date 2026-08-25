# terrain_2_sol — le SOL du stage 2 (Le Canyon de la Foudre)

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts.py`. Ne pas l'éditer à la
> main : corriger une consigne se fait dans la table de l'outil, puis on relance.
> Sinon la correction ne profite qu'à un stage sur dix.

Si le modèle rend mieux en anglais, demande-lui de **traduire ce prompt** avant
de générer : ça évite de maintenir soixante blocs en deux langues.

**Joins `ref/ref_2_sol.png` à ChatGPT** — ce sont les panneaux de sol
étiquetés de `assets/stages/stage_2.png` — et dis « même style, même palette ».

Une seule image, la matière occupe tout. **Pas de magenta** : il n'y a rien à
détourer. Résultat attendu : `terrain_2_sol.png` dans `assets/peso&cover/terrain/`.

```
Texture de sol pour un jeu 2D vu de DESSUS, style cartoon coloré, contour marqué,
même facture et même palette que l'image de référence jointe.

FORMAT : une seule image carrée de 1024 x 1024 pixels.

SUJET : le sol des couloirs d'un labyrinthe — de la terre sableuse ocre CRAQUELÉE, semée de petits cailloux violets et de fines fissures sombres. Vue strictement
VERTICALE, à la perpendiculaire du sol : aucun horizon, aucun ciel, aucune
perspective, aucun objet debout.

ÉCHELLE, le point le plus important : l'image entière représente environ 3 x 3
mètres de sol. Un caillou, une fleur, un éclat font donc moins d'un CENTIÈME de
la largeur de l'image. Il y en a des centaines, petits et serrés. Aucun élément
ne doit dominer l'image.

ÉCLAIRAGE : parfaitement PLAT et UNIFORME. Pas de vignettage, pas de coin sombre,
pas de tache de lumière, pas d'ombre d'un objet hors champ. La luminosité doit
être la même au centre et dans les quatre coins.

COULEURS : ocre sable chaud, calme, sans aucune lueur : c'est le fond sur lequel les éclairs du mur doivent ressortir. C'est le FOND sur lequel courent les
personnages : garde-le CALME — moins contrasté, moins saturé et moins détaillé
que le mur. Entre deux valeurs, prends la plus sourde.

RÈGLES ABSOLUES :
- la matière touche les QUATRE BORDS de l'image, elle est coupée net par le cadre
- aucun cadre, aucune bordure, aucune vignette, aucun fond visible
- aucun chemin continu, aucune ligne traversant l'image de part en part : des
  PLAQUES et des semis, pas un sentier
- aucun texte, aucun chiffre, aucun filigrane
- aucun personnage, aucun objet debout, aucun mur
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Un coin plus sombre que le centre | insister sur « éclairage PLAT », relancer |
| Un gros élément au milieu | rappeler « moins d'un centième de la largeur » |
| Un sentier traverse l'image | rappeler « des PLAQUES, pas un sentier » |
| Une couture visible quand on répète | **ne rien changer** — le raccord est mon travail |

⚠️ Ne demande jamais « seamless » / « tileable » : le modèle dessinera un cadre
pour faire semblant. Voir [../PROMPT_TERRAIN.md](../PROMPT_TERRAIN.md).
