# Le Croupier des Enfers — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/croupier.png` au générateur, pour qu'il garde le même
personnage. Pour la marche, joindre AUSSI `docs/prompts/mages_animes/guide_complet.png`, qui porte les jambes du
Chronomancien, la [marche de référence](marche_chronomancien.md).

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/croupier_marche.png
    assets/peso&cover/mages/croupier_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche se commande ENTIÈRE, les trois rangées
ensemble : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, ses cornes, son
costume, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Croupier des Enfers, un homme ADULTE et HUMAIN, en proportions CHIBI :
grosse tête, corps court. Peau pâle, cheveux noirs plaqués en arrière, yeux rouges, sourire
en coin, deux PETITES cornes noires dans les cheveux. Costume trois-pièces bordeaux (#7a0f14)
à revers noirs, veste qui s'arrête aux hanches, gilet noir brodé d'or (#c9a227), chemise
blanche, cravate rouge sombre, chaîne de montre en or, pantalon bordeaux, chaussures noires
vernies, gants BLANCS. Mains vides : aucune carte, aucun dé, aucun chapeau, aucune canne.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL MARCHE COMME UNE PERSONNE QUI SE DÉPLACE, d'un pas assuré et nonchalant, sur place. Le
buste reste droit. Les 8 colonnes de chaque rangée sont UNE BOUCLE de marche, et à CHAQUE
image les jambes ET les bras changent de position.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le
même écart. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne
doivent PAS apparaître : c'est le personnage de la première image qui prend ces poses, avec son
pantalon bordeaux et ses chaussures vernies.

LES BRAS BALANCENT EN OPPOSITION AUX JAMBES, COMME CHEZ UN HOMME QUI MARCHE :
quand la jambe DROITE avance, c'est le bras GAUCHE qui part devant et le bras DROIT qui part
derrière ; puis ils échangent. Le coude plie un peu, l'avant-bras pivote, et la main gantée
suit avec un léger retard, doigts détendus. Les bras ne restent JAMAIS figés le long du
corps, ni dans les poches, ni croisés.

LE PAS, image par image (de profil, la jambe et le bras PROCHES sont ceux qu'on voit le mieux) :
1. jambe proche DEVANT, jambe éloignée derrière ; bras proche DERRIÈRE, bras éloigné DEVANT
2. jambes encore ouvertes ; les bras reviennent vers le corps, coudes un peu pliés
3. ⚠️ JAMBES JOINTES sous le corps, un pied à peine levé ; les deux bras le long du corps :
   POINT DE PASSAGE
4. les jambes s'ouvrent de nouveau, les pieds ont ÉCHANGÉ leur place ; le bras proche part
   vers l'avant, le bras éloigné vers l'arrière
5. l'INVERSE de l'image 1 : jambe proche DERRIÈRE, bras proche DEVANT, bras éloigné DERRIÈRE
6. jambes encore ouvertes ; les bras reviennent vers le corps, coudes un peu pliés
7. ⚠️ JAMBES JOINTES, l'autre pied à peine levé ; les deux bras le long du corps : POINT DE
   PASSAGE
8. les jambes s'ouvrent comme à l'image 1, le bras proche repart vers l'arrière : l'image
   enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui
avance grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté
du corps. Les pans de la veste suivent la jambe qui avance.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. D'une image à la suivante, l'avant-bras
et la main changent de position, et les images 1 et 5 montrent les bras INVERSÉS. Deux
images voisines identiques pour les bras sont une erreur. Le bras qui avance est TOUJOURS
du côté opposé à la jambe qui avance.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Les
images 5 à 8 ne répètent pas les images 1 à 4 : les deux jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. De profil, il n'est
ni plus fin, ni plus grand, et ses jambes ne sont pas plus longues que de face.

⚠️ RÈGLE BLOQUANTE — LA TÊTE ET LE TRONC NE GLISSENT PAS. Dans une même rangée, ils se
superposent exactement d'une case à l'autre : seuls les jambes, les bras et les pans de la
veste bougent. C'est le JEU qui le fait avancer sur la carte.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE : ni carte qui flotte, ni lueur, ni particule.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : son bordeaux tire vers le brun-rouge.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son visage, ses cornes, son costume, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Croupier des Enfers, un homme ADULTE et HUMAIN, en proportions CHIBI :
grosse tête, corps court. Peau pâle, cheveux noirs plaqués, yeux rouges, deux PETITES cornes
noires. Costume trois-pièces bordeaux (#7a0f14) à revers noirs, gilet noir brodé d'or
(#c9a227), chemise blanche, cravate rouge sombre, gants BLANCS, chaussures noires vernies.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le tronc ont les
mêmes dimensions en pixels. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il lance VERS LE BAS DE L'IMAGE, face au joueur. Sa main part DROIT VERS NOUS,
  devant sa poitrine, et reste DANS la largeur du corps, jamais sur le côté
- rangée 2 : il lance VERS LE HAUT DE L'IMAGE, de dos. Le bras part droit devant lui et la
  main disparaît derrière sa tête, DANS la largeur du corps, jamais sur le côté
- rangée 3 : il lance VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle — le
geste d'un croupier qui lance une carte d'un coup de poignet :
1. posture prête, la main droite à hauteur de poitrine, deux doigts tendus
2. il ramène la main vers son épaule opposée, le poignet plié
3. il arme encore, le buste un peu tourné
4. LE LANCER : le bras se détend d'un coup dans la direction de la rangée, poignet cassé,
   et une petite carte rouge NETTE quitte ses doigts
5. la carte a disparu, le bras reste tendu, deux doigts pointés
6. le poignet se redresse
7. le bras revient près du corps
8. il retrouve exactement sa pose de marche
Les jambes restent posées, les pieds ne bougent pas pendant le geste.

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ. Le seul objet est la petite carte de l'image 4, plus
petite que sa main. Le JEU dessine la carte qui vole.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.
```

---

## À vérifier sur la planche reçue

| Défaut | Conséquence en jeu |
|---|---|
| Les bras restent figés le long du corps | Il glisse comme une statue au lieu de marcher |
| Le bras et la jambe du même côté avancent ensemble | Il marche comme un pantin : à regénérer |
| Les mêmes bras devant aux images 1 et 5 | Il balance un seul bras |
| Les pieds ne se rejoignent pas aux images 3 et 7 | Il glisse de profil |
| La tête est plus étroite de profil | Il change de taille en tournant |
| Une carte, un dé ou une canne dans ses mains en marchant | Ils resteraient collés au sprite |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque coup |
| La main part sur le côté en rangée 1 ou 2 | Il semble lancer à côté de sa cible |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et l'écart
des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
