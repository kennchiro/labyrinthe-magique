# Les pièces de l'Avide — prompt

Le jeu les dessine séparément du personnage, et ajoute lui-même la lueur, la bile qui gicle et le mouvement.

| case | objet | sert à |
|---|---|---|
| 1 | la langue-fouet | l'attaque : le jeu l'étire du mage à sa cible |
| 2 | le gouffre au sol, vu de dessus | le Gouffre béant qui s'ouvre et se referme |
| 3 | la boule de bile | la Régurgitation, une boule par bouchée |
| 4 | la grande gueule du ventre, ouverte | Dévorer et le Festin, qui avale les ennemis |

## Prompt

> Joindre `assets/peso&cover/refonte/avide.png`, pour la peau, les couleurs et le trait.

```
Planche de quatre objets pour un jeu de rôle mobile vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites du jeu. L'image jointe donne
la peau, les couleurs et le trait d'un démon dévoreur : ces objets lui appartiennent. Ne
dessine PAS le personnage entier.

FORMAT exact : image 1024 x 1024 pixels, grille régulière de 2 colonnes x 2 rangées, quatre
cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne de grille, cadre, numéro,
lettre ou texte. Un objet centré par case, environ 80 % de la case, avec une marge magenta
et sans débordement.

Palette STRICTE : noir d'encre (#111014), os ivoire (#e9e2cf), vert bile (#c8e830), vert
pâle (#f2ffb0) et vert sombre (#5a7a12). AUCUN rose, AUCUN violet, AUCUN magenta dans les
objets. La bile est en aplats nets, sans halo flou ni transparence.

Dans l'ordre de lecture :
1. LA LANGUE-FOUET — une longue langue noire, HORIZONTALE, droite, qui traverse toute la
   largeur de la case, d'épaisseur constante, luisante de reflets vert bile, finie à DROITE
   par une pointe d'os ivoire en harpon. Rien à gauche : elle est coupée net.
2. LE GOUFFRE — une gueule RONDE ouverte dans le sol, VUE EXACTEMENT DE DESSUS : une couronne
   de crocs ivoire pointés vers le centre, une gorge noire profonde, et une lueur vert bile au
   fond. Le bord est une terre noire fendue. Cercle parfait, symétrique.
3. LA BOULE DE BILE — une boule vert bile luisante, gluante, avec des bulles et deux
   gouttes qui s'en détachent, vue de face.
4. LA GRANDE GUEULE — une gueule VERTICALE immense, vue de face, GRANDE OUVERTE : deux rangées
   de crocs ivoire inégaux sur les bords, des lèvres de chair noire, une gorge vert bile
   lumineuse au fond, et des filets de bave verte entre les crocs. Pas de tête autour, pas de
   corps : seulement la gueule.

Pas de décor, particule, ombre, flou, ni personnage. Le magenta du fond ne doit pas se
refléter dans les objets.
```

Déposer dans **`assets/peso&cover/sorts/avide_pieces.png`**.

## À vérifier sur la planche reçue

Le générateur peut changer l'ordre : relever ce que chaque case MONTRE avant de découper.

| Défaut | Conséquence en jeu |
|---|---|
| La langue est courbée ou en biais | Elle ne s'étirerait pas droite du mage à sa cible |
| Le gouffre vu de biais, en ellipse | Il se déformerait au sol |
| Une tête entière autour de la grande gueule | Le Festin collerait une tête sur l'écran |
| Un halo vert autour de la bile | Une frange rose resterait au détourage |
