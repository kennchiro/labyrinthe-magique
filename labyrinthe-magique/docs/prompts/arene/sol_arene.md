# sol_arene — le SOL de l'arène

Même gabarit que les `terrain_N_sol` : une plaque pleine que l'outil rendra raccordable
lui-même. On ne demande JAMAIS « seamless » au modèle, il dessine un cadre pour faire semblant.

Résultat attendu : `arene_sol.png` dans `assets/peso&cover/terrain/`.

```
Texture de sol pour un jeu 2D vu de DESSUS, style cartoon coloré, contour marqué,
même facture et même palette que l'image de référence jointe.

FORMAT : une seule image carrée de 1024 x 1024 pixels.

SUJET : le sol d'une arène de combat magique — de grandes DALLES de pierre claire
beige et grise, usées, aux joints irréguliers, quelques fissures fines, un peu de
sable doré dans les joints, de rares éclats de cristal bleu pâle incrustés. Vue
strictement VERTICALE, à la perpendiculaire du sol : aucun horizon, aucun ciel,
aucune perspective, aucun objet debout.

ÉCHELLE, le point le plus important : l'image entière représente environ 3 x 3
mètres de sol. Une dalle fait environ un quart de la largeur de l'image. Les
fissures et les éclats sont petits. Aucun élément ne doit dominer l'image.

ÉCLAIRAGE : parfaitement PLAT et UNIFORME. Pas de vignettage, pas de coin sombre,
pas de tache de lumière, pas d'ombre d'un objet hors champ. La luminosité doit
être la même au centre et dans les quatre coins.

COULEURS : beige pierre et gris chaud, SOURDS. C'est le FOND sur lequel se battent
les héros et éclatent les sorts : garde-le CALME — moins contrasté, moins saturé
et moins détaillé que les décors. Entre deux valeurs, prends la plus sourde.

RÈGLES ABSOLUES :
- la matière touche les QUATRE BORDS de l'image, elle est coupée net par le cadre
- aucun cadre, aucune bordure, aucune vignette, aucun fond visible
- aucun cercle, aucune rosace, aucun motif central, aucun symbole : le sol doit
  pouvoir se répéter sans qu'on voie la répétition
- aucun texte, aucun chiffre, aucun filigrane
- aucun personnage, aucun objet debout, aucun mur
```
