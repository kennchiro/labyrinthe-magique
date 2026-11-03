# Le Geôlier — planches de vol et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/geolier.png` au générateur, pour qu'il garde le
même personnage. Pas de guide de marche : il flotte, il n'a pas de jambes.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/geolier_marche.png
    assets/peso&cover/mages/geolier_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche se commande ENTIÈRE, les trois rangées
ensemble : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — le vol

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe est le
modèle exact du personnage : garde EXACTEMENT son armure, ses flammes, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Geôlier, une armure d'obsidienne noire (#14181f) aux reflets gris-bleu,
VIDE et habitée par une flamme froide cyan (#16e0e8), aux proportions de l'image jointe,
grandes et massives, PAS chibi : heaume petit, épaules très larges, énormes gantelets. Heaume pointu et fermé, sans visage, deux yeux en fente cyan. Épaulières
anguleuses, plastron en V à veine cyan, quelques maillons pendus à la taille. Deux gros
gantelets noirs flottent au bout de ses bras. PAS DE JAMBES : sous la taille, son corps se
défait en une longue flamme qui s'effile vers le bas.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL FLOTTE, IL NE MARCHE PAS, MAIS SES BRAS BOUGENT COMME CEUX D'UN MARCHEUR. Les 8 colonnes
de chaque rangée sont UNE BOUCLE de déplacement :
- LES BRAS BALANCENT FRANCHEMENT, en opposition : quand l'avant-bras et le gantelet droits
  partent vers l'avant, les gauches partent vers l'arrière, puis ils échangent. Le coude
  plie, l'avant-bras pivote, et le gantelet suit avec un temps de retard, comme s'il était
  lourd. Les bras ne restent JAMAIS figés le long du corps ;
- la flamme du bas ondule et se balance, ses pointes changent d'une image à l'autre ;
- les flammes du col et des épaules battent avec le mouvement des bras ;
- DE PROFIL, la flamme du bas traîne un peu EN ARRIÈRE, vers la gauche, comme poussée par
  son avance. L'image 8 enchaîne sur l'image 1.

LE BALANCEMENT DES BRAS, image par image (le bras PROCHE est celui qu'on voit le mieux) :
1. bras proche tendu vers l'AVANT, gantelet à hauteur de taille ; bras éloigné vers l'ARRIÈRE
2. bras proche qui redescend, coude un peu plié ; bras éloigné qui revient
3. les deux bras le long du corps, gantelets côte à côte, POINT DE PASSAGE
4. bras proche qui part vers l'arrière ; bras éloigné qui part vers l'avant
5. l'INVERSE de l'image 1 : bras proche vers l'ARRIÈRE, bras éloigné tendu vers l'AVANT
6. bras éloigné qui redescend ; bras proche qui revient
7. les deux bras le long du corps, POINT DE PASSAGE
8. bras proche qui repart vers l'avant : l'image enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : le gantelet qui
avance grossit et descend un peu, celui qui recule rétrécit et monte un peu, de chaque côté
du corps.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Le heaume a EXACTEMENT la même
hauteur et la même largeur dans les 24 cases : il n'est pas plus petit ni plus fin de profil.

⚠️ RÈGLE BLOQUANTE — LE HEAUME ET LE TORSE NE BOUGENT PAS. Dans une même rangée, ils se
superposent exactement d'une case à l'autre : seuls les bras, les gantelets et les flammes
bougent. C'est le JEU qui le fait avancer sur la carte.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. D'une image à la suivante, l'avant-bras
et le gantelet changent de position, et les images 1 et 5 montrent les bras inversés. Deux
images voisines identiques pour les bras sont une erreur.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA FLAMME S'ARRÊTE SUR LA MÊME LIGNE HORIZONTALE dans les 24
cases, et rien n'est dessiné plus bas. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — LES FLAMMES SONT DES APLATS NETS ET OPAQUES, en trois tons de cyan.
Aucun halo, aucune lueur diffuse, aucune transparence, aucune particule détachée.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : son noir tire vers le gris-bleu.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son heaume regarde
VERS LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son armure, ses flammes, ses couleurs et ses proportions, mais
PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Geôlier, une armure d'obsidienne noire (#14181f) VIDE, habitée par une
flamme froide cyan (#16e0e8), aux proportions de l'image jointe, grandes et massives, PAS
chibi : heaume petit, épaules très larges, énormes gantelets. Heaume pointu
sans visage, deux yeux en fente cyan, épaulières anguleuses, plastron en V à veine cyan. Deux
gros gantelets noirs flottent au bout de ses bras. PAS DE JAMBES : sous la taille, une longue
flamme qui s'effile vers le bas.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE VOL : le heaume et le torse ont les
mêmes dimensions en pixels. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face au joueur. Le gantelet vient DROIT VERS
  NOUS, devant son plastron, et reste DANS la largeur du corps, jamais sur le côté
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos. Le bras part droit devant lui et le
  gantelet disparaît derrière son heaume, DANS la largeur du corps, jamais sur le côté
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, les gantelets près du corps
2. il ramène le gantelet droit en arrière, la flamme des épaules se gonfle
3. il arme encore, le corps ramassé
4. L'IMPACT : bras tendu d'un coup dans la direction de la rangée, gantelet ouvert, et un
   petit éclat CYAN net au bout des doigts
5. l'éclat a disparu, le bras reste tendu
6. le gantelet se referme
7. le bras revient près du corps
8. il retrouve exactement sa pose de vol

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en rangée
1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble
corps et bras.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUN GANTELET QUI S'ENVOLE, AUCUNE CHAÎNE. Le seul
effet est le petit éclat de l'image 4, plus petit que sa main. Le JEU dessine les sorts.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA FLAMME S'ARRÊTE SUR LA MÊME LIGNE HORIZONTALE dans les 24
cases, et la flamme garde des aplats nets et opaques, sans halo.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son heaume regarde VERS
LA DROITE dans les 8 cases.
```

---

## À vérifier sur la planche reçue

| Défaut | Conséquence en jeu |
|---|---|
| Une ombre, un anneau ou un trait de grille | Une salissure reste collée au sprite |
| Le heaume bouge dans la case | Il tressaute en volant |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque coup |
| Le heaume est plus étroit de profil | Il change de taille en tournant |
| Un corps chibi, à grosse tête | Ce n'est plus la morphologie du modèle |
| Le bras part sur le côté en rangée 1 ou 2 | Il semble frapper à côté de sa cible |
| Des jambes ou des pieds apparaissent | Il marcherait au lieu de flotter |
| Les bras restent figés le long du corps | Il glisse comme une statue au lieu d'avancer |
| Les mêmes bras devant aux images 1 et 5 | Il balance un seul bras |
| Un halo flou autour des flammes | Une frange rose resterait au détourage |

**À la livraison :** la largeur du heaume, de profil par rapport à la face, doit rester entre 0,95 et 1,05.
