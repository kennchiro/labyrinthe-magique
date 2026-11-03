# Les pièces et la cage du Roi de Braise — prompt

Le jeu les dessine séparément du personnage : elles flottent, volent et se referment seules.

| case | objet | sert à |
|---|---|---|
| 1 | gantelet, main ouverte | l'orbite, les chasseurs en vol, l'impact du Poing de braise |
| 2 | gantelet, poing fermé | le Poing de braise en vol, le coup des chasseurs |
| 3 | plastron fermé | l'orbite, le plastron posé au sol |
| 4 | plastron ouvert comme un four | la morsure |
| 5 | cage ouverte | la chute des Mille Cages |
| 6 | cage fermée | l'attente des Mille Cages |

Le jeu met le gantelet droit en miroir pour obtenir le gauche, et ajoute lui-même la flamme.

## Prompt

> Joindre `assets/peso&cover/refonte/braise.png`, pour le métal, les couleurs et le trait.

```
Planche de six objets pour un jeu de rôle mobile vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites du jeu. L'image jointe donne
le métal, les couleurs et le trait de l'armure : ces objets lui appartiennent. Ne dessine
PAS le personnage.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2 rangées, six
cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne de grille, cadre, numéro,
lettre ou texte. Un objet centré par case, environ 70 % de la case, avec une marge magenta
généreuse et sans débordement.

Palette STRICTE : or noirci (#2a2118), arêtes d'or vieilli (#b8862b), et de fines fissures de
lave orange (#ff7a18). AUCUN rose, AUCUN violet, AUCUN magenta dans les objets. Les fissures sont
des traits nets, sans aucune lueur.

Dans l'ordre de lecture :
1. GANTELET OUVERT — un très gros gantelet droit, massif, doigts écartés, paume vers nous,
   parcouru de fissures. Il est VIDE : le poignet s'ouvre sur du noir.
2. GANTELET FERMÉ — le même gantelet, fermé en un gros poing, vu de trois quarts.
3. PLASTRON FERMÉ — un plastron royal, massif et bombé, vu de face, sans tête, bras ni corps,
   avec des fissures qui partent de son centre. Il est VIDE.
4. PLASTRON OUVERT — le même plastron, ouvert en deux battants comme la porte d'un four, avec des
   dents de métal sur ses bords. Son intérieur est noir et vide.
5. CAGE OUVERTE — une cage ronde royale, en barreaux d'or noirci, vue de face et de l'extérieur,
   ouverte par le bas : les barreaux s'écartent en griffes. Vide.
6. CAGE FERMÉE — la même cage, entièrement refermée, les barreaux joints à sa base, surmontée
   d'une petite couronne brisée. Vide.

⚠️ Les barreaux sont ÉPAIS et bien espacés, et le fond magenta se voit franchement entre eux.
⚠️ Les deux gantelets ont le même dessin, les deux plastrons aussi, les deux cages aussi.

Pas de décor, flamme, particule, ombre, flou, personnage, corne, crâne ou chaîne. Le magenta
du fond ne doit pas se refléter dans les objets.
```

Déposer dans **`assets/peso&cover/sorts/braise_pieces.png`**.

## À vérifier sur la planche reçue

Comme pour les icônes, le générateur peut changer l'ordre : relever ce que chaque case MONTRE avant de découper.

| Défaut | Conséquence en jeu |
|---|---|
| Une main, un corps ou un visage dans une pièce | Elle ne semblerait plus vide |
| Des barreaux fins ou serrés | La cage devient une tache en très petit, et l'ennemi disparaît dessous |
| Le plastron ouvert ne ressemble plus au fermé | Il change d'objet au moment de mordre |
