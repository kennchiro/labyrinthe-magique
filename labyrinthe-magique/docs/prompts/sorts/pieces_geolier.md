# Les pièces du Geôlier — prompt

Le jeu les dessine séparément du personnage : le poing qui vole, le crochet et les maillons de ses chaînes.

| case | objet | sert à |
|---|---|---|
| 1 | gantelet, poing fermé | le Poing spectral en vol |
| 2 | gantelet, main grande ouverte | le Crochet qui saisit |
| 3 | crochet de fer | la pointe de la chaîne du Crochet |
| 4 | maillon de chaîne | répété le long de toutes ses chaînes |
| 5 | manille ouverte | l'entrave qui claque au sol au troisième coup |
| 6 | maillon brisé | la fin des Chaînes d'âmes et de la Geôle |

Le jeu ajoute lui-même la flamme, la lueur et la traînée.

## Prompt

> Joindre `assets/peso&cover/refonte/geolier.png`, pour le métal, les couleurs et le trait.

```
Planche de six objets pour un jeu de rôle mobile vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites du jeu. L'image jointe donne
le métal, les couleurs et le trait de l'armure : ces objets lui appartiennent. Ne dessine
PAS le personnage.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2 rangées, six
cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne de grille, cadre, numéro,
lettre ou texte. Un objet centré par case, environ 70 % de la case, avec une marge magenta
généreuse et sans débordement.

Palette STRICTE : obsidienne noire (#14181f), reflets gris-bleu (#2a3640), liseré gris-bleu
clair (#8fb8c0), et un seul accent CYAN pur (#16e0e8). AUCUN rose, AUCUN violet, AUCUN magenta
dans les objets. Les accents cyan sont des aplats nets, sans aucune lueur ni flamme.

Dans l'ordre de lecture :
1. POING FERMÉ — un très gros gantelet droit de métal noir, fermé en poing, vu de trois
   quarts, poing tourné vers le haut à droite. Une fente cyan sur le dos de la main. Le
   poignet est ouvert et vide.
2. MAIN OUVERTE — le même gantelet, doigts grands écartés et crochus, paume vers nous.
3. CROCHET — un crochet de fer noir épais et recourbé, pointe vers le haut, avec un anneau à
   sa base et une arête cyan.
4. MAILLON — un seul maillon de chaîne ovale, épais, vu de face, en métal noir à liseré
   gris-bleu, à plat.
5. MANILLE — un fer d'entrave ouvert, en forme de U épais, vu de dessus, avec un rivet cyan.
6. MAILLON BRISÉ — le même maillon que la case 4, cassé en deux morceaux qui s'écartent.

⚠️ Le poing et la main ont le même dessin de gantelet ; le maillon brisé est le même que le
maillon entier.

Pas de décor, flamme, particule, ombre, flou, personnage, corne ou crâne. Le magenta du fond
ne doit pas se refléter dans les objets.
```

Déposer dans **`assets/peso&cover/sorts/geolier_pieces.png`**.

## À vérifier sur la planche reçue

Le générateur peut changer l'ordre : relever ce que chaque case MONTRE avant de découper.

| Défaut | Conséquence en jeu |
|---|---|
| Un bras ou une main de chair dans le gantelet | Il ne semblerait plus vide |
| Un maillon en perspective ou trop fin | Répété le long d'une chaîne, il se lirait comme un trait |
| Des flammes dessinées | Elles doubleraient celles que le jeu ajoute |
