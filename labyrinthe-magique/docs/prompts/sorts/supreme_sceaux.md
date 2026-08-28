# Les Quatre Sceaux — le skill 2 du Sorcier Suprême

## Ce qui existe déjà côté jeu

Le sort est **fini et jouable** : il ne manque que le dessin.

| | |
|---|---|
| **4 sceaux** | un par point cardinal, à 2 cases du mage |
| **7 s** de tenue | recharge 12 s |
| **FEU** à droite | 12 dégâts/s, et ça brûle 3 s après la sortie |
| **EAU** en bas | ralentit tant qu'on reste dessus |
| **TERRE** à gauche | arrête net, une fois par passage |
| **AIR** en haut | rayon le plus large, mais le moins mordant |

Il remplace la **Coulée de magma**, qui était déclarée `Element.Kind.FIRE` et
faisait 14 dégâts/s sur 2,2 cases — c'est-à-dire le « Sol embrasé » du Mage du
Feu à un nom près. Elle ne combinait rien, alors que combiner est toute
l'identité du Suprême.

En attendant la planche, les sceaux empruntent la texture de zone du mage,
teintée aux quatre couleurs. Ça se joue, mais les quatre se ressemblent.

---

## Une planche, neuf cases — et un seul sceau

La structure est celle de **Convergence élémentaire**, parce qu'elle a marché du
premier coup :

    cases 1 à 7   la CHARGE, jouée devant le mage
    case 8        ce qui se pose au sol
    case 9        l'éclat

Mais il y a quatre sceaux, et **on n'en demande qu'UN**. C'est la même décision
que pour le cadre des cartes de personnages : demander quatre sceaux donnerait
quatre épaisseurs, quatre diamètres et quatre styles de gravure différents, et
les quatre sont posés **côte à côte à l'écran**, là où le moindre écart se voit.

On demande donc **un seul sceau, en BLANC ET OR**, sans aucune couleur
d'élément — et c'est le jeu qui le teinte en rouge, bleu, vert et blanc selon
l'élément. Un sceau déjà coloré donnerait quatre teintes fausses.

---

## Le prompt

> **Une seule image en grille de 3 x 3**, à déposer sous le nom `sceaux.png`
> dans `assets/peso&cover/sorts/`. C'est moi qui découpe ensuite.
>
> Une planche unique plutôt que neuf fichiers, et ce n'est pas un détail de
> confort : les neuf cases sortent alors du MÊME dessin, donc du même trait, du
> même diamètre d'anneau et de la même palette. Neuf générations séparées
> dérivent — c'est ce qui est arrivé aux pièces de mur du terrain, où aucune
> planche n'avait la même largeur de tronçon.
>
> Le fond MAGENTA se détoure au pixel près — convention déjà utilisée sans un
> seul échec sur ce projet.

```
Série de 9 images pour un sort de jeu 2D vu de DESSUS, style cartoon coloré à
contours nets, effets lumineux, même facture que les sprites de sorts d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image carrée de 1536 x 1536 pixels
- grille RÉGULIÈRE de 3 colonnes x 3 rangées, soit 9 cases de 512 x 512
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé et sans
  ombre portée
- dans chaque case, l'effet est CENTRÉ et occupe environ 80 % de la case
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun cadre, aucun trait de grille, aucun
  personnage, aucun sol

LES 9 CASES se lisent de GAUCHE À DROITE puis de HAUT EN BAS.

CASES 1 à 7 — LA CHARGE. Le mage rassemble les quatre éléments avant de
les sceller. Vue de trois quarts, comme un objet tenu en l'air :
1. quatre minuscules étincelles — une rouge, une bleue, une verte, une blanche —
   très écartées, presque perdues dans le vide
2. elles se rapprochent et laissent chacune une traîne de sa couleur
3. elles tournent autour d'un même centre, les traînes dessinent un anneau
4. l'anneau se referme : un cercle de lumière où les quatre couleurs se suivent
5. des RUNES apparaissent sur l'anneau, encore pâles
6. les runes s'allument, l'anneau s'épaissit et se met à tourner vite
7. l'anneau est à pleine puissance : un disque de runes incandescent, les quatre
   couleurs fondues en une lumière blanche au centre

CASE 8 — LE SCEAU POSÉ. C'est la case la plus importante des neuf :
un sceau circulaire gravé, vu STRICTEMENT DE DESSUS, à plat sur le sol — donc un
CERCLE PARFAIT, jamais une ellipse et jamais vu en biais. Un anneau extérieur de
runes, un second anneau plus fin à l'intérieur, et au centre un motif à QUATRE
BRANCHES orientées vers les quatre points cardinaux. Gravure creusée qui luit
d'une lumière douce.

⚠️ CE SCEAU EST BLANC ET OR, sans AUCUNE autre couleur — pas de rouge, pas de
bleu, pas de vert. Le jeu le teinte lui-même selon l'élément qu'il porte. Un
sceau déjà coloré donnerait quatre teintes fausses.

CASE 9 — LE MORDANT. Le sceau qui se déclenche : une gerbe de lumière qui jaillit
du cercle vers le haut, runes éclatées, éclats qui fusent. Blanc et or également.

RÈGLES ABSOLUES :
- la MÊME taille d'anneau et la MÊME épaisseur de trait dans les cases 7, 8 et 9
- les cases 1 à 7 s'enchaînent : chacune continue exactement la précédente, un
  élément qui change de place d'une image à l'autre fait sauter l'animation
- la case 8 est vue de dessus, les cases 1 à 7 sont vues de trois quarts : c'est
  normal, on tient l'anneau avant de le poser à terre
- rien ne dépasse du cadre
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| La case 8 est une ellipse ou vue en biais | c'est **le** défaut bloquant : le sceau est posé à plat, le jeu l'écrase lui-même. Redemander cette case seule, en 512 x 512 sur magenta |
| Le sceau est coloré | rappeler « BLANC ET OR, le jeu le teinte » — sinon les quatre éléments ne se distingueront pas |
| L'anneau change de taille entre les cases 7, 8 et 9 | rappeler « MÊME taille d'anneau » : le sort clignoterait au moment de se poser |
| La charge saute d'une case à l'autre | redemander la planche entière : les sept premières cases doivent s'enchaîner |
| Frange rose autour de l'effet | rien à faire côté prompt, je dégorge au découpage |

---

## Ce que je fais quand les images arrivent

1. **découpe** — même outil que Convergence : une bande de 8 cases (7 de charge +
   le sceau), plus l'éclat à part. La charge se joue devant le mage à 8 img/s,
   comme le skill 1 ;
2. **branchement** — la case 8 remplace la texture de zone du Suprême pour ce
   sort. `ZoneEffect` la pose déjà à plat et l'écrase à l'horizontale ; elle est
   teintée par `Element.color()`, donc les quatre sceaux se distinguent d'un coup
   d'œil sans qu'aucun ne soit redessiné ;
3. **l'éclat** (case 9) se joue quand un sceau mord, pas en boucle : sinon les quatre
   clignotent ensemble pendant sept secondes et l'écran devient illisible ;
4. **contrôle à l'image** : une capture en démo avec les quatre sceaux posés dans
   un carrefour, pour vérifier qu'on lit bien quel élément garde quel couloir.
