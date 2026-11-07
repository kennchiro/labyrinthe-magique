# Aël l'Apprenti — planches de déplacement et d'attaque

**Avant de lancer :** le modèle `assets/peso&cover/refonte/ael_apprenti.png` doit être validé (fiche
[heros_ael](../mages/heros_ael.md), image 1). Il est joint aux deux prompts. La planche de concept
`refonte/ael_concept.png` n'est PAS jointe ici : sa mise en page et ses lueurs gêneraient les planches.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/ael_marche.png
    assets/peso&cover/mages/ael_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit. La planche de déplacement se commande ENTIÈRE, les
trois rangées ensemble : [une bande de profil générée à part sort plus fine que la face](marche_chronomancien.md).

---

## Prompt 1 — le déplacement, comme le Héros d'essai

Son déplacement est celui du Héros d'essai, validé par le joueur : une COURSE énergique de face et de dos, et la
marche des mages de profil. Le jeu y ajoute son animation à 60 images par seconde (`MotionProfile`) : rebond,
écrasement, poussière et à-coups. La planche ne porte que les 8 poses de chaque rangée.

Joindre `assets/peso&cover/refonte/ael_apprenti.png` **puis** `docs/prompts/template/guide_heros.png` (la course
du Héros d'essai sur les rangées 1 et 2, les jambes du Chronomancien sur la rangée 3).

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe est le modèle exact du personnage : garde EXACTEMENT son visage, sa coiffure, sa
tenue, ses couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël l'Apprenti, un jeune garçon HUMAIN, en proportions CHIBI : grosse tête,
corps court. Cheveux noirs en épis, yeux brun sombre. Longue écharpe rouge sombre (#8e1b17),
tunique courte de cuir brun ceinturée, pantalon brun foncé, bottes brunes, mitaines. Une
ÉPÉE COURTE d'acier dans la main droite, tenue basse. Un petit éclat de gemme terne pend à
son cou.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il COURT vers le bas de l'image
- rangée 2 : vu DE DOS, il COURT vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il MARCHE d'un pas vif vers la droite

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses pieds et de ses jambes, et
sur les rangées 1 et 2 celle de ses mains et de son épée (rouge : le bras et la jambe qui
tiennent l'épée ; bleu : les autres ; jaune : l'épée). Rien du guide ne doit apparaître : ni
le mannequin, ni ses couleurs, ni le corps gris, le bâton, la robe verte ou les bottes de la
rangée 3. C'est le personnage de la première image qui prend ces poses. ⚠️ Les têtes du guide
n'ont pas la même taille d'une rangée à l'autre : N'EN TIENS PAS COMPTE.

RANGÉES 1 ET 2, UNE COURSE ÉNERGIQUE À PAS MOYENS, en boucle :
1. contact : le pied rouge pose devant, le pied bleu pousse derrière
2. le pied rouge porte le poids, le genou bleu commence à monter
3. PASSAGE : le pied rouge sous le corps, le genou bleu monte
4. le pied bleu part devant, le pied rouge recule
5. l'INVERSE de l'image 1
6. le pied bleu porte le poids, le genou rouge commence à monter
7. PASSAGE : le pied bleu sous le corps, le genou rouge monte
8. le pied rouge part devant : l'image enchaîne sur la première
Les coudes sont pliés et les bras balancent franchement, en opposition aux jambes. L'épée
reste basse et suit le bras. Les pans de l'écharpe flottent derrière lui, en retard sur le
corps. De face et de dos, les pieds restent sous le corps : l'un puis l'autre monte.

RANGÉE 3, DE PROFIL, UNE MARCHE DROITE, sans pencher et sans lever le genou :
1. jambes ouvertes, comme sur le guide : un pied devant, l'autre derrière
2. jambes ouvertes, comme sur le guide
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes : l'INVERSE de l'image 1
6. jambes ouvertes : l'INVERSE de l'image 2
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première
Le bras gauche balance en opposition aux jambes, l'épée reste basse, l'écharpe suit le pas.

⚠️ RÈGLE BLOQUANTE — UN PIED TOUJOURS AU SOL. Il ne saute pas : aucune image où les deux pieds
sont en l'air. Ni grand écart, ni jambes en compas.

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7,
la largeur occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Dans les
trois rangées, les images 5 à 8 ne répètent pas les images 1 à 4 : les jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE SUR LES TROIS RANGÉES. Sa tête a EXACTEMENT la même hauteur
et la même largeur dans les 24 cases : elle n'est pas plus petite de profil. De profil, il n'est
ni plus fin, ni plus grand, et ses jambes ne sont pas plus longues que de face.

⚠️ RÈGLE BLOQUANTE — LA TÊTE NE BOUGE PAS D'UNE CASE À L'AUTRE. Dans une même rangée, elle se
superpose exactement, même taille, même place. C'est le JEU qui le fait avancer et rebondir : la
planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne
horizontale dans les 24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE : la gemme reste éteinte. Ni lueur, ni particule.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui : son écharpe tire vers le brun-rouge.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS
LA DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune
poussière, aucun trait de vitesse. Les effets sont ajoutés par le jeu.
```

---

## Prompt 2 — l'attaque, un coup d'épée

Joindre `assets/peso&cover/refonte/ael_apprenti.png` **puis** `docs/prompts/template/guide_attaque.png`, le
guide du coup d'épée réglé sur le Héros d'essai.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré à
contours nets, même facture que les sprites d'un jeu de rôle mobile. La PREMIÈRE image
jointe montre le personnage : garde EXACTEMENT son visage, sa coiffure, sa tenue, ses
couleurs et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — Aël l'Apprenti, un jeune garçon HUMAIN, en proportions CHIBI : grosse tête,
corps court. Cheveux noirs en épis, longue écharpe rouge sombre (#8e1b17), tunique courte de
cuir brun ceinturée, pantalon brun foncé, bottes brunes, mitaines. Une ÉPÉE COURTE d'acier
dans la main droite. Un petit éclat de gemme terne pend à son cou.

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
8. il retrouve sa pose de marche, l'épée basse, la pointe vers le bas

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
aucune lueur sur la gemme. Le jeu ajoute lui-même l'arc de lame, au bon moment et à la bonne couleur.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET sur lui, aucun reflet du fond magenta.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage regarde VERS LA
DROITE dans les 8 cases.

⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

---

## À vérifier sur les planches reçues

| Défaut | Conséquence en jeu |
|---|---|
| Les pieds ne se rejoignent pas aux images 3 et 7 de profil | Il glisse de profil |
| Le buste penche de profil, ou un genou monte haut | De profil, il doit marcher comme les mages |
| Les deux pieds quittent le sol de face ou de dos | Il aurait l'air de sauter |
| La tête est plus étroite de profil | Il change de taille en tournant |
| Les mêmes jambes devant aux images 1 et 5 | Il marche sur une seule jambe |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque coup |
| Les images 2, 4 et 6 de l'attaque se ressemblent | Le coup paraît mou |
| Un arc lumineux est dessiné | Il ne suivrait plus les durées du jeu |

**À la livraison :** la largeur de la tête, de profil par rapport à la face, doit rester entre 0,95 et 1,05, et l'écart
des pieds de profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts).
