# Le Héros d'essai — le gabarit d'animation

> Identifiant `test`. Il ne sert qu'à régler le mouvement et l'attaque, sans toucher aux personnages
> qui marchent déjà. Ce qui est validé sur lui devient le gabarit des prochains héros.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|
| 1 | le modèle du personnage | `refonte/test.png` | `refonte/chrono.png` |
| 2 | la course | `mages/test_marche.png` | `refonte/test.png` et `docs/prompts/template/guide_course.png` |
| 2 bis | la course de profil, écartée à l'essai | `mages/test_profil.png` | `refonte/test.png` et `docs/prompts/template/guide_profil.png` |
| 2 ter | **la marche de profil, à la façon des mages** | `mages/test_profil.png`, en remplaçant le précédent | `refonte/test.png` et `docs/prompts/mages_animes/guide_profil.png` |
| 3 | l'attaque | `mages/test_attaque.png` | `refonte/test.png` et `docs/prompts/template/guide_attaque.png` |
| 4 | le repos | `mages/test_repos.png` | `refonte/test.png` |
| 5 | les gestes | `mages/test_gestes.png` | `refonte/test.png` |

Les images 1, 2 bis et 3 suffisent pour l'essai en jeu. Vérifier chaque image avant de passer à
la suivante : un défaut du modèle se retrouve sur toutes les planches.

La gauche n'est jamais demandée : le jeu retourne le profil droit.

## Qui fait quoi

| Dessiné sur les planches | Fait par le jeu, à 60 images par seconde |
|---|---|
| Jambes, bras, arme | Rebond et écrasement à chaque appui |
| Penchée du buste en course | Inclinaison au départ et au freinage |
| Écharpe qui suit le mouvement | Durée de chaque pose d'attaque |
| Les poses clés du coup | Gel à l'impact, flash, recul, arc de lame peint au shader |

C'est ce partage qui rend le gabarit réutilisable : la partie du jeu vaut pour tous les héros, et il
n'y a que les planches à refaire.

## Comment le jeu jouera l'attaque

Ce sont des cibles de départ, à régler en jeu : les huit images ne durent pas le même temps.

| image | rôle | durée |
|---|---|---:|
| 1 | l'élan | 17 ms |
| 2 | armé | 33 ms |
| 3 | la lame part | 17 ms |
| 4 | **l'impact** | 67 ms |
| 5 | la lame finit sa course | 50 ms |
| 6 | fin du geste, tenue | 67 ms |
| 7 | le retour | 33 ms |
| 8 | la pose de course | 33 ms |

Soit 0,32 s, comme aujourd'hui. Les coups partent en 67 ms environ, assez peu pour que la commande ne
paraisse pas lente.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'image jointe sert UNIQUEMENT de référence de style, de proportions et de mise en page :
ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vue DE FACE, immobile, l'épée tenue basse dans sa main droite
2. vue DE DOS, immobile : l'écharpe se voit dans son dos
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — un jeune aventurier agile de jeu de rôle. Cheveux châtains courts en
épis, grands yeux vifs. Tunique courte bleu sarcelle (#1f8a96) serrée par une ceinture de
cuir brun, pantalon gris sombre ajusté, grosses bottes de cuir brun. Une ÉCHARPE courte
jaune safran (#f2b632) nouée au cou, dont les deux pans tombent dans son dos jusqu'à la
taille. Une ÉPÉE COURTE à lame gris clair et garde brune, dans la main droite, aussi
longue que son torse et sa tête réunis, pas plus. Pas de bouclier, pas de cape, pas de
sac, pas de halo, pas de particules.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête occupe près de 40 % de la hauteur, et les jambes à peine un
quart. Grosses mains, gros pieds, torse court. Posé à côté du personnage de l'image jointe,
il a la même morphologie.

⚠️ RÈGLE BLOQUANTE — SES MEMBRES SE LISENT EN TRÈS PETIT. Les deux jambes sont séparées l'une
de l'autre, les deux bras se détachent du torse, et la tunique s'arrête en haut des cuisses.
Ce personnage sert à régler le mouvement : un membre qu'on ne voit pas ne sert à rien.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET. Rien sur lui ne reflète le fond magenta.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR SOMBRE NET autour de toute la silhouette, et un fin liseré
clair sur le pantalon : il doit rester lisible sur un sol très sombre comme sur un sol clair.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, même
écharpe, même épée, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne serait plus à la taille des autres héros, et le gabarit ne s'appliquerait pas |
| Les jambes se touchent, ou la tunique les cache | On ne pourrait pas juger la course |
| L'épée dépasse de la longueur prévue | Elle serait coupée par la case dans l'attaque |
| L'écharpe tombe plus bas que la taille | Elle se mêlerait aux jambes dans la course |
| Du rose sur la lame | Le détourage y ferait des trous |

---

## Image 2 — la course

Joindre `assets/peso&cover/refonte/test.png` **puis** `docs/prompts/template/guide_course.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, ses couleurs, ses vêtements et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il court vers le bas de l'image
- rangée 2 : vu DE DOS, il court vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il court vers la droite de l'image

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds, de ses mains, de
ses genoux et de son épée. Rouge : le bras et la jambe qui tiennent l'épée. Bleu : les
autres. Jaune : l'épée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image, avec ses vrais vêtements, qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN CYCLE DE COURSE énergique, à pas MOYENS :
1. contact : le pied rouge pose devant, le pied bleu pousse derrière
2. le pied rouge porte le poids, le genou bleu commence à monter
3. PASSAGE : le pied rouge sous le corps, le genou bleu monte haut devant
4. le pied bleu part devant, le pied rouge recule
5. l'INVERSE de l'image 1 : le pied bleu pose devant, le pied rouge pousse derrière
6. le pied bleu porte le poids, le genou rouge commence à monter
7. PASSAGE : le pied bleu sous le corps, le genou rouge monte haut devant
8. le pied rouge part devant : l'image enchaîne sur la première

SON ÉNERGIE, ce qui fait une vraie course de jeu vidéo :
- de profil, le BUSTE PENCHE EN AVANT d'environ 8 degrés dans les 8 images, sans jamais se
  redresser ; la tête regarde devant lui ;
- les COUDES SONT PLIÉS, les bras balancent franchement en opposition aux jambes ;
- l'épée reste tenue basse, la pointe vers l'arrière, et suit le bras sans jamais croiser
  les jambes ;
- l'ÉCHARPE FLOTTE DERRIÈRE LUI : ses deux pans ondulent et s'y déplacent d'une image à
  l'autre, en retard sur le corps. De profil ils partent vers la gauche, de face ils se
  voient à peine de chaque côté du cou, de dos ils flottent vers le bas de l'image.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL. Il ne saute pas, il n'y a aucune image où les
deux pieds sont en l'air, et aucune où ils sont joints.

⚠️ RÈGLE BLOQUANTE — NI GRAND ÉCART NI JAMBES EN COMPAS. De profil, aux images 1 et 5, l'écart
entre les pieds vaut environ UN TIERS DE LA HAUTEUR du personnage, jamais plus. De face et de
dos, les pieds restent sous le corps sans s'écarter vers les côtés : l'un puis l'autre monte.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement les 8 images
d'une rangée : la tête se superpose exactement, même taille, même place. C'est le JEU qui le fait
avancer sur la carte et qui le fait rebondir : la planche montre les membres, sur place, comme
sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas que cette ligne.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune poussière, aucun trait de vitesse.
Les effets sont ajoutés par le jeu.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Les pieds gardent le même écart sur les 8 images de profil | Il glisserait, le défaut déjà vu sur les anges |
| Les deux pieds quittent le sol | Il aurait l'air de sauter |
| Le buste se redresse d'une image à l'autre | Il tremblerait à grande cadence |
| L'écharpe saute d'un côté à l'autre | Elle clignoterait au lieu de flotter |
| Le mannequin rouge et bleu apparaît | Le guide a été recopié trop fidèlement : regénérer |

---

## Image 2 bis — la course de profil, à refaire

La rangée de profil de `test_marche.png` dessine deux fois le même demi-cycle : il court sur une seule
jambe. Cette image la remplace sans toucher à la face ni au dos. `build_enemies.py` la prend d'elle-même
tant qu'elle est plus récente que `test_marche.png`, et signale le défaut s'il revient.

Joindre `assets/peso&cover/refonte/test.png` **puis** `docs/prompts/template/guide_profil.png`.

```
Bande de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à contours
nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image jointe montre le
personnage : garde EXACTEMENT son visage, ses couleurs, ses vêtements et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 256 pixels
- UNE SEULE rangée de 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

Il est vu DE PROFIL, TOURNÉ VERS LA DROITE, dans les 8 cases, et il court sur place. Le buste penche
en avant, l'épée reste basse, la pointe vers l'arrière, et l'écharpe flotte derrière lui.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DES JAMBES. Elle a la même grille que l'image à produire.
Son haut du corps est le bon : garde-le. Ses jambes sont peintes en deux couleurs, et ces couleurs ne
doivent PAS apparaître : dessine à leur place ses vrais pantalons et ses vraies bottes, dans la position
EXACTE de chaque couleur.
- le ROUGE est sa jambe PROCHE de nous : elle passe DEVANT l'autre, sa botte se voit en entier ;
- le BLEU est sa jambe ÉLOIGNÉE : elle passe DERRIÈRE l'autre, sa botte est un peu plus sombre.

LES 8 IMAGES, de gauche à droite :
1. jambe PROCHE devant, pied à plat ; jambe ÉLOIGNÉE derrière, pied sur la pointe
2. la jambe proche porte le poids ; le pied éloigné quitte le sol, derrière
3. la jambe proche est droite sous le corps ; le genou éloigné passe devant elle, pied levé
4. le pied éloigné va se poser devant ; la jambe proche part en arrière
5. ⚠️ L'INVERSE DE L'IMAGE 1 : jambe ÉLOIGNÉE devant, pied à plat ; jambe PROCHE derrière, sur la pointe
6. la jambe éloignée porte le poids ; le pied proche quitte le sol, derrière
7. la jambe éloignée est droite sous le corps ; le genou proche passe devant elle, pied levé
8. le pied proche va se poser devant ; la jambe éloignée part en arrière : on revient à l'image 1

⚠️ RÈGLE BLOQUANTE — C'EST LE DÉFAUT À CORRIGER : LES IMAGES 5 À 8 NE RÉPÈTENT PAS LES IMAGES 1 À 4. Les
deux jambes échangent leurs rôles. À l'image 1, la botte qui se voit en entier est DEVANT ; à l'image 5, cette
même botte est DERRIÈRE. Une planche où la même jambe reste devant sur les 8 images est fausse.

⚠️ RÈGLE BLOQUANTE — LE PIED AVANT NE RESTE PAS EN PLACE : d'une image à l'autre, les deux pieds se
déplacent, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL, jamais les deux en l'air, et le bas du pied posé touche
la même ligne horizontale dans les 8 cases. À l'image 1, l'écart entre les pieds vaut environ UN TIERS
de la hauteur du personnage, jamais plus.

⚠️ RÈGLE BLOQUANTE — SEULES LES JAMBES CHANGENT. La tête et le tronc se superposent exactement d'une
case à l'autre, à la même taille, et il regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune poussière, aucun trait de vitesse.
```

**À regarder avant de déposer :** compare les images 1 et 5. Si la botte entière est devant sur les deux,
c'est encore le même défaut : regénère. Rouge ou bleu restés sur le dessin : regénère aussi.

---

## Image 2 ter — la marche de profil, à la façon des mages

Le joueur préfère le pas des mages à la course de l'image 2 bis : une marche droite, à pas moyens, où
les pieds se rejoignent aux images 3 et 7. Le guide vient d'une vraie marche réussie, celle du Chronomancien.

Joindre `assets/peso&cover/refonte/test.png` **puis** `docs/prompts/mages_animes/guide_profil.png`. Déposer
le résultat dans `assets/peso&cover/mages/test_profil.png`, à la place du précédent.

```
Bande de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à contours
nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image jointe montre le
personnage : garde EXACTEMENT son visage, ses couleurs, ses vêtements et ses proportions, mais PAS
sa mise en page. Prends sa vue DE PROFIL, à droite sur cette image.

FORMAT, à respecter exactement :
- UNE image de 2048 x 256 pixels
- UNE SEULE rangée de 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — un jeune aventurier chibi. Cheveux châtains courts en épis, tunique courte bleu
sarcelle, ceinture de cuir, pantalon gris sombre, grosses bottes de cuir brun, écharpe jaune safran
dont les deux pans tombent dans son dos. Une épée courte dans la main droite. Sa hauteur totale vaut
2,5 TÊTES, et ses jambes à peine un quart.

Il est vu DE PROFIL, TOURNÉ VERS LA DROITE, dans les 8 cases, et il MARCHE tranquillement sur place. IL
NE COURT PAS : le buste reste DROIT, sans pencher en avant, les genoux restent bas. L'épée reste tenue
basse le long de la jambe, la pointe vers le bas, et les pans de l'écharpe tombent dans son dos en
bougeant à peine. Ses bras balancent légèrement, en opposition aux jambes.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à produire.
Dans chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS. Le corps gris du guide,
son bâton, sa robe et ses bottes ne doivent PAS apparaître : c'est le personnage de la première image qui
prend ces poses, avec son pantalon et ses propres bottes.

LES 8 IMAGES, de gauche à droite :
1. jambes ouvertes, à pas MOYEN : un pied devant, l'autre derrière, les deux posés à plat
2. jambes encore ouvertes, les pieds se rapprochent
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes, à pas MOYEN : l'INVERSE de l'image 1
6. jambes encore ouvertes, les pieds se rapprochent
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — NI GRAND ÉCART NI GENOU LEVÉ. Aux images 1 et 5, l'écart entre les pieds vaut environ
UN QUART de la hauteur du personnage, jamais plus. Le pied levé quitte à peine le sol : aucun genou ne
monte devant lui. Pas de jambes en compas, et pas de saut à pieds joints.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. Aux images 3 et 7, la largeur occupée par
les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Les images 5 à 8 ne répètent pas les
images 1 à 4 : les deux jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LES BOTTES GARDENT LEUR TAILLE, et ne sont pas plus grandes que sur la première image.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES ET LES BRAS BOUGENT. La tête et le tronc se superposent exactement
d'une case à l'autre, à la même taille, et il regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne horizontale
dans les 8 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucune poussière, aucun trait de vitesse.
```

**À regarder avant de déposer :** aux images 3 et 7, les jambes sont-elles jointes et aucun genou n'est-il
levé ? Le buste est-il droit ? Si un bâton ou une robe du guide apparaissent, regénère.

---

## Image 3 — l'attaque

Joindre `assets/peso&cover/refonte/test.png` **puis** `docs/prompts/template/guide_attaque.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, ses couleurs, ses vêtements et ses
proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

⚠️ MÊME TAILLE QUE SUR LA PREMIÈRE IMAGE JOINTE : la tête et le tronc ont les mêmes dimensions
dans les 24 cases. Un corps plus petit se verrait comme un rétrécissement à chaque coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il frappe VERS LE BAS DE L'IMAGE, face à nous : le coup vient VERS NOUS
- rangée 2 : il frappe VERS LE HAUT DE L'IMAGE, de dos : le coup s'éloigne de nous
- rangée 3 : il frappe VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds, de sa main, de son
buste et l'angle de son épée. Rouge : le bras et la jambe qui tiennent l'épée. Bleu : les
autres. Jaune : l'épée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN SEUL COUP D'ÉPÉE, de gauche à droite, pas une boucle :
1. L'ÉLAN : il abaisse l'épée vers l'arrière, les épaules se tournent
2. ARMÉ : l'épée est levée au plus loin en arrière, le corps enroulé, tendu comme un ressort
3. LE DÉPART : la lame file par-dessus l'épaule, le buste commence à se dérouler
4. L'IMPACT : le bras est tendu, la lame devant lui, le buste jeté en avant, l'écharpe encore
   en arrière
5. LA LAME FINIT SA COURSE : elle passe de l'autre côté, le buste reste penché, l'écharpe arrive
6. FIN DU GESTE : le bras est au bout de son mouvement, le corps est tenu, l'écharpe le dépasse
7. LE RETOUR : le bras se replie, le buste se redresse
8. il retrouve la pose de sa course, l'épée basse, la pointe vers l'arrière

Les images 2, 4 et 6 sont les POSES CLÉS : elles doivent se distinguer au premier regard par
leur seule silhouette, comme dans un jeu d'action.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE, et le corps reste CENTRÉ dans sa
case, sur la tête et les pieds, jamais sur l'ensemble du corps et de l'épée. C'est le jeu qui fait
la petite poussée vers l'avant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS NE BOUGENT PAS. Ils sont plantés aux mêmes endroits dans les 8 images
d'une rangée, et leur bas touche la même ligne horizontale dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — L'ÉPÉE PART DANS LA DIRECTION DE LA RANGÉE, et reste entière dans sa case. Elle
garde sa longueur : elle ne paraît plus courte que quand elle vient vers nous ou s'éloigne de nous.

⚠️ RÈGLE BLOQUANTE — AUCUN EFFET : aucun arc lumineux, aucune traînée, aucun flou, aucune étincelle,
aucun projectile. Le jeu les ajoute lui-même, au bon moment et à la bonne couleur.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS LA
DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Les images 2, 4 et 6 se ressemblent | Le coup serait mou, quelle que soit sa cadence |
| Le corps se recentre sur l'épée | Il sursauterait à l'impact |
| La pointe de l'épée est coupée | La case ne la rattrapera pas |
| Un arc lumineux est dessiné | Il ne suivrait plus les durées du jeu |

---

## Image 4 — le repos

Joindre `assets/peso&cover/refonte/test.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son visage, ses couleurs, ses vêtements et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE
- rangée 2 : vu DE DOS
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UNE BOUCLE DE GARDE, vivante et prête à repartir : pieds
écartés de la largeur des épaules, genoux un peu fléchis, épée basse dans la main droite.
1. position de base, poitrine basse
2 à 4. il inspire : les épaules et la main de l'épée montent d'un rien, l'écharpe se soulève
5. poitrine haute
6 à 8. il expire : tout redescend, l'écharpe retombe avec un peu de retard
L'image 8 enchaîne sur l'image 1 sans à-coup.

⚠️ RÈGLE BLOQUANTE — UN MOUVEMENT DISCRET : d'une image à l'autre, rien ne bouge de plus de 4 pixels,
et l'écharpe de plus de 8.

⚠️ RÈGLE BLOQUANTE — LES PIEDS NE BOUGENT JAMAIS, et leur bas touche la même ligne horizontale dans
les 24 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, AUCUN EFFET.
```

---

## Image 5 — les gestes

Joindre `assets/peso&cover/refonte/test.png`.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. L'image jointe montre le
personnage : garde EXACTEMENT son visage, ses couleurs, ses vêtements et ses proportions, mais PAS
sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, tourné vers le bas de l'image
- rangée 2 : vu DE DOS, tourné vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont QUATRE GESTES COURTS de deux images chacun, sans lien
entre eux :
1. LE DÉPART, début : il se ramasse, genoux pliés, buste bas et jeté vers l'avant
2. LE DÉPART, fin : la jambe arrière pousse, le bras de l'épée part en arrière
3. LE FREINAGE, début : le pied avant plante, le buste part en arrière, l'écharpe passe devant
4. LE FREINAGE, fin : il se rattrape, genoux pliés, l'écharpe retombe
5. LE COUP REÇU, début : la tête et le buste sont rejetés vers l'arrière, les bras s'écartent,
   grimace, yeux fermés
6. LE COUP REÇU, fin : il se recroqueville, une main sur le ventre, l'épée basse
7. L'ESQUIVE, début : il plonge vers l'avant, très bas, un genou presque au sol, buste à
   l'horizontale
8. L'ESQUIVE, fin : il se relève d'un coup, un pied en avant, prêt à courir

⚠️ RÈGLE BLOQUANTE — LE BAS DU PIED LE PLUS BAS touche la même ligne horizontale dans les 24 cases.

⚠️ RÈGLE BLOQUANTE — MÊME TAILLE dans les 24 cases, et le personnage reste entier dans sa case, sans
chevaucher sa voisine, même dans les poses les plus étirées.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS LA
DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, AUCUN EFFET, aucune poussière.
```

---

## Reprendre le gabarit pour un autre héros

Quand le Héros d'essai est validé en jeu :

1. Remplacer le bloc `LE PERSONNAGE` du modèle, et ses mentions de l'épée et de l'écharpe.
2. Garder la grille, les guides, les règles et les huit colonnes de chaque planche.
3. Pour un mage, le geste reste le même : le bras tendu de l'image 4 lance le sort à la place de
   l'impact. Le guide d'attaque tient, à condition d'écrire dans le prompt que le trait jaune n'est
   pas une épée : il indique seulement la direction du bras.

Les guides se regénèrent avec `tools/.venv/bin/python tools/build_template_guides.py`.
