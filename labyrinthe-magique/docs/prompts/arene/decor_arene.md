# decor_arene — les décors POSÉS dans l'arène

Même gabarit que les `terrain_N_decor` : douze objets sur fond magenta, un par case.
Ce sont des décors, pas des obstacles : les obstacles sont les murs (`mur_arene`), que le
combat connaît. Ces objets se posent sur le pourtour et dans les coins, jamais sur une case
où l'on se bat.

Résultat attendu : `arene_decor.png` dans `assets/peso&cover/decor/`.

```
Planche d'objets de décor pour un jeu 2D vu de DESSUS, style cartoon coloré,
contour marqué, même facture et même palette que l'image de référence jointe.

FORMAT, à respecter exactement :
- image de 1024 x 768 pixels
- grille RÉGULIÈRE de 4 colonnes x 3 rangées, soit 12 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
  portée sur le magenta
- aucun texte, aucun chiffre, aucune bordure dessinée, aucun trait de grille

LES 12 OBJETS, de gauche à droite puis de haut en bas — un seul objet par case,
CENTRÉ, posé au sol, vu de dessus en légère plongée (on voit le dessus et un peu
la face avant, comme dans la référence) :

Rangée 1
1.  un brasero de bronze sur trois pieds, flamme orange
2.  un brasero de bronze sur trois pieds, flamme BLEUE
3.  une statue de gardien en pierre tenant une lance, sur un petit socle
4.  un pilier de pierre BRISÉ à mi-hauteur, des débris à son pied

Rangée 2
5.  un étendard planté, tissu BLEU uni, sans motif ni lettre
6.  un étendard planté, tissu ROUGE uni, sans motif ni lettre
7.  un râtelier d'armes en bois avec deux lances et une épée
8.  un tas de boucliers ronds et d'épées abandonnés

Rangée 3
9.  un tonneau et deux caisses en bois
10. un petit cristal bleu qui sort du sol, lumineux
11. une amphore de terre cuite fêlée
12. un petit tas de pierres de taille éboulées

COULEURS : pierre claire, bronze chaud, bois brun. Le bleu et le rouge ne servent
QUE aux étendards et aux flammes : ce sont les couleurs des deux équipes, il ne
faut pas qu'un objet neutre les porte.

RÈGLES :
- même taille apparente pour les objets d'une même famille (les deux braseros,
  les deux étendards)
- rien ne dépasse sur la case voisine
- aucun personnage, aucun sol dessiné sous l'objet
```
