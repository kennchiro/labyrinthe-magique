# Les pièces du Croupier des Enfers — prompt

Le jeu les dessine séparément du personnage, et ajoute lui-même l'éclat, la traînée et le mouvement.

| case | objet | sert à |
|---|---|---|
| 1 | dos de carte | la Carte tranchante en vol, la Carte piège face cachée, le leurre de la fuite |
| 2 | As de feu | la Carte piège retournée : elle brûle |
| 3 | Dame de glace | la Carte piège retournée : elle fige |
| 4 | Roi de foudre | la Carte piège retournée : la foudre saute |
| 5 | dé | les Dés pipés |
| 6 | pièce, côté face | Pile ou face, et la pluie d'or du jackpot |
| 7 | pièce, côté pile | Pile ou face |
| 8 | jeton de casino | les jetons qui jaillissent d'un coup de chance |
| 9 | bille d'or | la bille de la Roulette infernale |

## Prompt

> Joindre `assets/peso&cover/refonte/croupier.png`, pour les couleurs et le trait.

```
Planche de neuf objets pour un jeu de rôle mobile vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites du jeu. L'image jointe donne
les couleurs et le trait du personnage : ces objets lui appartiennent, un casino infernal.
Ne dessine PAS le personnage.

FORMAT exact : image 1536 x 1536 pixels, grille régulière de 3 colonnes x 3 rangées, neuf
cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne de grille, cadre, numéro,
lettre ou texte en dehors des cartes. Un objet centré par case, environ 70 % de la case, avec
une marge magenta généreuse et sans débordement.

Palette STRICTE : bordeaux (#7a0f14), noir (#15100f), or ancien (#c9a227), or vif (#e8b54a),
ivoire (#f4efe6), et pour les trois figures seulement : orange feu, cyan glace et jaune foudre.
AUCUN rose, AUCUN violet, AUCUN magenta dans les objets.

Dans l'ordre de lecture :
1. DOS DE CARTE — une carte à jouer vue de face, droite, coins arrondis, dos bordeaux à
   motif d'arabesques d'or et un petit crâne cornu doré au centre, liseré d'or.
2. AS DE FEU — la même carte, côté figure : fond ivoire, un grand symbole de FLAMME orange au
   centre, un « A » et une petite flamme dans deux coins opposés.
3. DAME DE GLACE — la même carte : fond ivoire, une dame stylisée au visage froid, couronne de
   cristaux cyan, un grand FLOCON cyan, une petite « D » et un flocon dans deux coins opposés.
4. ROI DE FOUDRE — la même carte : fond ivoire, un roi stylisé barbu, un grand ÉCLAIR jaune,
   un petit « R » et un éclair dans deux coins opposés.
5. DÉ — un gros dé ivoire aux arêtes arrondies, vu de trois quarts, trois faces visibles,
   points bordeaux, liseré d'or.
6. PIÈCE CÔTÉ FACE — une grosse pièce d'or vue de face, bord crénelé, un profil de démon à
   petites cornes en relief au centre.
7. PIÈCE CÔTÉ PILE — la même pièce, de l'autre côté : un crâne cornu entouré de flammes
   gravées, en relief.
8. JETON DE CASINO — un jeton rond bordeaux, vu de face, bord à rayures ivoire, une couronne
   d'or au centre.
9. BILLE D'OR — une bille d'or brillante, ronde et parfaite, un reflet ivoire.

⚠️ Les quatre cartes ont EXACTEMENT la même forme et la même taille. Les deux pièces ont le même
bord et la même taille.

Pas de décor, flamme réelle, particule, ombre, flou ni personnage. Le magenta du fond ne doit
pas se refléter dans les objets.
```

Déposer dans **`assets/peso&cover/sorts/croupier_pieces.png`**.

## À vérifier sur la planche reçue

Le générateur peut changer l'ordre : relever ce que chaque case MONTRE avant de découper.

| Défaut | Conséquence en jeu |
|---|---|
| Les cartes n'ont pas la même taille | Le retournement de la Carte piège sauterait |
| Une carte inclinée ou en perspective | Elle tournoierait de travers en vol |
| Du rose sur la Dame | Le détourage le griserait |
| Des lettres en dehors des cartes | Elles resteraient collées à l'objet |
