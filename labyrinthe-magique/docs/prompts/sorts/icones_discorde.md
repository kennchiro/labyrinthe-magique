# Les icônes de sorts de la Démone de la Discorde — prompt

| créneau | sort | symbole |
|---|---|---|
| ATTAQUE | Murmure | fil d'argent ondulant, perle à sa pointe |
| SKILL 1 | Mauvais Œil | œil étroit dont pendent quatre fils |
| SKILL 2 | Cercle de Discorde | anneau traversé d'une toile de fils |
| SKILL 3 | Lien de Souffrance | trois nœuds reliés par une chaîne fine |
| FUITE | Échange | deux flèches courbes qui se croisent |
| EXTRA | Grande Discorde | grand œil, avec une pluie de fils |

⚠️ **Le rose est proscrit, même si ses sorts sont magenta en jeu.** Le fond de la planche est magenta, et
`build_skill_icons.py` rend un pixel d'autant plus transparent qu'il a de rouge et de bleu en plus de son vert :
un rose `#e8308f` y perdrait plus du tiers de son opacité. L'accent des icônes est donc un corail, sans
aucun bleu en plus du vert.

## Prompt

> Copier-coller tel quel, sans image jointe.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga,
contours nets et formes lisibles en petit. Ces symboles appartiennent à une
marionnettiste humaine et noble, qui retourne ses ennemis les uns contre les autres.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2
rangées, six cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne
de grille, cadre, numéro, lettre ou texte. Une icône centrée par case, environ
70 % de la case, avec une marge magenta généreuse et sans débordement.

Palette STRICTE : argent clair, vert sapin sombre, noir, et un seul accent CORAIL
vif (#ff7a5c). AUCUN rose, AUCUN violet, AUCUN magenta dans les dessins. Les icônes
sont des symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. MURMURE — un fil d'argent ondulant, qui file en diagonale vers le haut à droite,
   terminé par une petite perle corail.
2. MAUVAIS ŒIL — un œil étroit et horizontal, à l'iris corail, cerné de noir et
   d'argent. Quatre fils d'argent pendent de sa paupière basse.
3. CERCLE DE DISCORDE — un anneau d'argent vu de face, traversé par une toile de
   fils qui relient quatre petits points corail.
4. LIEN DE SOUFFRANCE — trois nœuds vert sapin en triangle, reliés par une chaîne
   fine d'argent. Le nœud du haut brille en corail.
5. ÉCHANGE — deux flèches courbes d'argent et de vert sapin, qui tournent l'une
   autour de l'autre et se croisent. Une petite étincelle corail au centre.
6. GRANDE DISCORDE — un grand œil grand ouvert, à l'iris corail éclatant, cerclé
   d'argent et de noir, d'où tombe une pluie dense de fils d'argent. C'est l'icône
   la plus spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte, personnage, corne,
aile ou crâne. Le magenta du fond ne doit pas se refléter dans les icônes.
```

Déposer dans **`assets/peso&cover/sorts/mage_discorde_skills.png`**.
