# Le Dragon des Abysses — planches de marche et d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/dragon.png` au générateur, pour qu'il garde le même
personnage. Pour la marche, joindre AUSSI `docs/prompts/mages_animes/guide_complet.png`, qui porte les jambes du
Chronomancien, la [marche de référence](marche_chronomancien.md) : le dragon en reprend le RYTHME, pas la longueur
des jambes.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/dragon_marche.png
    assets/peso&cover/mages/dragon_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche se commande ENTIÈRE, les trois rangées
ensemble : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT ses écailles, ses cornes, son
magma, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Dragon des Abysses, un dragon-démon BIPÈDE, debout, massif et redoutable,
aux proportions de l'image jointe, PAS chibi : tête de reptile petite, deux grandes cornes
noires recourbées vers l'arrière, yeux jaunes, crocs. Épaules très larges, torse puissant,
bras musclés à mains griffues. Jambes de bête aux genoux pliés vers l'arrière, pieds à trois
griffes. Écailles noir charbon (#1c1210) et plaques rouge sang (#8a160c), fendues de veines
de magma orange (#ff5a10) à cœur jaune (#ffe36a). Ailes rouge sombre REPLIÉES dans le dos.
Longue queue à lame d'os, basse, derrière ses jambes.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

IL MARCHE COMME UNE PERSONNE QUI SE DÉPLACE, d'un pas lourd et menaçant, sur place. Le buste
reste droit. Les 8 colonnes de chaque rangée sont UNE BOUCLE de marche, et à CHAQUE image
les jambes ET les bras changent de position.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à
produire. Dans chaque case, reprends QUEL PIED est devant, l'ÉCART des pieds et les images
où ils se rejoignent. Le corps gris du guide, son bâton, son sablier, sa robe verte et ses
bottes brunes ne doivent PAS apparaître, et ses jambes courtes non plus : ce sont les jambes
de bête du dragon qui prennent ces poses.

LES BRAS BALANCENT EN OPPOSITION AUX JAMBES, COMME CHEZ UN HOMME QUI MARCHE :
quand la jambe DROITE avance, c'est le bras GAUCHE qui part devant et le bras DROIT qui part
derrière ; puis ils échangent. Le coude plie, l'avant-bras pivote, et la main griffue suit
avec un léger retard, doigts à demi refermés. Les bras ne restent JAMAIS figés le long du
corps, ni collés au torse, ni croisés.

LE PAS, image par image (de profil, la jambe et le bras PROCHES sont ceux qu'on voit le mieux) :
1. jambe proche DEVANT, jambe éloignée derrière ; bras proche DERRIÈRE, bras éloigné DEVANT
2. jambes encore ouvertes ; les bras reviennent vers le corps, coudes pliés
3. ⚠️ JAMBES JOINTES sous le corps, un pied à peine levé ; les deux bras le long du corps,
   mains côte à côte : POINT DE PASSAGE
4. les jambes s'ouvrent de nouveau, les pieds ont ÉCHANGÉ leur place ; le bras proche part
   vers l'avant, le bras éloigné vers l'arrière
5. l'INVERSE de l'image 1 : jambe proche DERRIÈRE, bras proche DEVANT, bras éloigné DERRIÈRE
6. jambes encore ouvertes ; les bras reviennent vers le corps, coudes pliés
7. ⚠️ JAMBES JOINTES, l'autre pied à peine levé ; les deux bras le long du corps : POINT DE
   PASSAGE
8. les jambes s'ouvrent comme à l'image 1, le bras proche repart vers l'arrière : l'image
   enchaîne sur la première
DE FACE et DE DOS, l'avant devient le BAS de l'image et l'arrière le HAUT : la main qui
avance grossit et descend un peu, celle qui recule rétrécit et monte un peu, de chaque côté
du corps ; le genou qui avance monte un peu.

LA QUEUE ET LES AILES :
- la queue ondule en CONTRE-TEMPS : sa pointe part du côté opposé à la jambe qui avance ;
- de profil, la queue traîne DERRIÈRE lui, vers la gauche, basse, sans sortir de la case ;
- les ailes restent REPLIÉES et frémissent à peine, leurs pointes bougent d'une image à l'autre.

⚠️ RÈGLE BLOQUANTE — LES BRAS NE SONT JAMAIS FIGÉS. D'une image à la suivante, l'avant-bras
et la main changent de position, et les images 1 et 5 montrent les bras INVERSÉS. Deux
images voisines identiques pour les bras sont une erreur. Le bras qui avance est TOUJOURS
du côté opposé à la jambe qui avance.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Les
images 5 à 8 ne répètent pas les images 1 à 4 : les deux jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. La tête et les cornes ont EXACTEMENT
la même hauteur et la même largeur dans les 24 cases : il n'est pas plus petit ni plus fin de
profil, et ses jambes ne sont pas plus longues que de face.

⚠️ RÈGLE BLOQUANTE — LA TÊTE ET LE TORSE NE GLISSENT PAS. Dans une même rangée, ils se
superposent d'une case à l'autre, à un léger balancement près : seuls les jambes, les bras,
la queue et les pointes des ailes bougent. C'est le JEU qui le fait avancer sur la carte.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — LE MAGMA EST UN APLAT NET ET OPAQUE. Aucune flamme, aucun halo, aucune
lueur diffuse, aucune braise ni particule détachée : le JEU ajoute le feu.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : ses ailes sont rouge sombre.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa tête regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT ses écailles, ses cornes, son magma, ses couleurs et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — le Dragon des Abysses, un dragon-démon BIPÈDE, debout, massif et redoutable,
aux proportions de l'image jointe, PAS chibi : tête de reptile petite, deux grandes cornes
noires recourbées vers l'arrière, yeux jaunes, crocs. Épaules très larges, bras musclés à
mains griffues, jambes de bête. Écailles noir charbon (#1c1210) et plaques rouge sang
(#8a160c), fendues de veines de magma orange (#ff5a10) à cœur jaune (#ffe36a). Ailes rouge
sombre REPLIÉES dans le dos, queue basse derrière ses jambes.

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le torse ont les
mêmes dimensions en pixels. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il crache VERS LE BAS DE L'IMAGE, face au joueur. La tête plonge vers nous,
  gueule ouverte, DANS la largeur du corps
- rangée 2 : il crache VERS LE HAUT DE L'IMAGE, de dos. La tête se tend droit devant lui et
  disparaît en partie, DANS la largeur du corps, jamais sur le côté
- rangée 3 : il crache VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
1. posture prête, les griffes à demi levées
2. il se redresse, la tête part en arrière, la gorge s'illumine de magma
3. il gonfle le torse, les épaules remontent, les griffes s'écartent
4. L'IMPACT : la tête est projetée en avant, GUEULE GRANDE OUVERTE dans la direction de la
   rangée, avec une petite boule de magma NETTE devant les crocs
5. la boule a disparu, la gueule reste ouverte
6. la gueule se referme, un filet de fumée noire sort des naseaux
7. la tête revient au-dessus des épaules
8. il retrouve exactement sa pose de marche
Les jambes restent posées, les pieds ne bougent pas pendant le geste.

⚠️ RÈGLE BLOQUANTE — LE GESTE PART DANS LA DIRECTION DE LA RANGÉE, JAMAIS SUR LE CÔTÉ en
rangée 1 ou 2. Le corps reste CENTRÉ dans sa case : c'est le CORPS qu'on centre.

⚠️ RÈGLE BLOQUANTE — AUCUN SORT DESSINÉ, AUCUN JET DE FLAMMES. Le seul effet est la petite
boule de l'image 4, plus petite que sa tête. Le JEU dessine les flammes.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU dans les 24 cases, et le magma garde des aplats
nets et opaques, sans halo.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT REPLIÉES, la queue reste basse, dans la case.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa tête regarde VERS
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
| Un corps chibi, une grosse tête | Ce n'est plus la morphologie du modèle |
| Les ailes s'ouvrent ou la queue sort de la case | Elle est coupée au découpage |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque coup |
| La tête part sur le côté en rangée 1 ou 2 | Il semble cracher à côté de sa cible |
| Des flammes ou un halo autour du magma | Une frange rose resterait au détourage |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et l'écart
des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
