# La marche du Chronomancien, pour tous les mages

Le joueur a jugé son déplacement horizontal le plus satisfaisant, et le veut pour tous. Le guide
`guide_complet.png` porte ses vraies jambes sur les trois rangées, avec le haut du corps peint en gris.

⚠️ **La planche se commande entière, jamais la bande de profil seule.** Générée à part, cette bande sort
plus fine que la face, et le mage change de taille en tournant. Largeur de la tête, de profil par rapport à
la face : 0,77 sur le Démon avec sa bande à part, 1,02 sur son ancienne planche entière.

Ordre de passage, du pas le plus éloigné du sien au plus proche : Démon du Pacte, Démone de la Discorde,
Porte-Lumière, Archange d'Acier, Ange de la Mort, Ange des Étoiles, Mage de la Terre, Mage de la Peste,
Invocateur, Sorcier Suprême. Les mages déjà proches se jugent en jeu, en dernier.

**À regarder avant de déposer :**
- la tête a-t-elle la même taille sur les trois rangées, sans personnage plus fin de profil ?
- de profil, aux images 3 et 7, les pieds sont-ils l'un contre l'autre sous le corps ?
- de profil, aux images 1 et 5, l'écart est-il franc, et les jambes inversées ?
- si un bâton, un sablier, une robe verte ou une zone grise du guide apparaissent, regénérer.

**À la livraison :** ce rapport de largeur de tête doit rester entre 0,95 et 1,05, et l'écart des pieds de
profil près de celui du Chronomancien (0,17 joints, 0,56 ouverts). La nouvelle planche passe avant toute
`<id>_profil.png` plus ancienne : `build_enemies.py` ne prend que la plus récente des deux.

---

## Démon du Pacte

Joindre `assets/peso&cover/refonte/demon.png` **puis** `docs/prompts/mages_animes/guide_complet.png`.
Déposer le résultat dans `assets/peso&cover/mages/demon_marche.png`, à la place de l'ancienne, gardée dans
`demon_marche_ancienne.png`.

```
Feuille de sprites pour un jeu 2D vu de dessus en légère plongée, esthétique fantasy manga, contours
nets. La PREMIÈRE image jointe est le modèle exact du personnage : garde EXACTEMENT son visage, ses
couleurs, ses vêtements et ses proportions, mais PAS sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- une grille de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, entier, et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LE PERSONNAGE — un jeune homme HUMAIN et noble, en proportions CHIBI : grosse tête, corps court. Peau
claire, cheveux sombres en bataille, yeux ambrés, expression calme et déterminée. Long manteau noir ajusté
à col haut, doublure bordeaux, broderies d'or vieilli, gilet cramoisi, chemise claire et lavallière, gants
noirs, pantalon noir ajusté et bottes noires élégantes à liserés d'or. PAS de cornes, de queue, de crocs,
d'ailes ni d'auréole. Aucune arme.

LES RANGÉES :
- rangée 1 : DE FACE, il avance vers le bas
- rangée 2 : DE DOS, il s'éloigne vers le haut
- rangée 3 : DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite

⚠️ RÈGLE BLOQUANTE — C'EST LE DÉFAUT À CORRIGER : LA MÊME TAILLE SUR LES TROIS RANGÉES. C'est le même
personnage vu sous trois angles. Sa tête a EXACTEMENT la même hauteur et la même largeur dans les 24 cases :
elle n'est pas plus petite de profil. De profil, il n'est ni plus fin, ni plus grand, ni plus élancé : ses
jambes ne sont pas plus longues que de face, et son manteau garde son ampleur. Sa hauteur totale est la même
dans les 24 cases.

Il MARCHE tranquillement sur place. IL NE COURT PAS : le buste reste DROIT, sans pencher en avant, et les
genoux restent bas. Ses bras restent près du corps et balancent légèrement, en opposition aux jambes, les
mains gantées fermées.

LE MANTEAU : ses pans bougent à peine et ne couvrent jamais les pieds. Les deux bottes et le bas du pantalon
restent entièrement visibles dans les 24 cases.

⚠️ AUCUNE MAGIE : les flammes rouges et les runes de ses mains sur la première image N'APPARAISSENT PAS. Ni
feu, ni lueur, ni aura, ni particule.

⚠️ LA DEUXIÈME IMAGE JOINTE EST LE GUIDE DE LA MARCHE. Elle a la même grille que l'image à produire. Dans
chaque case, recopie EXACTEMENT la position de SES JAMBES et de SES PIEDS, et le même écart. Le corps gris
du guide, son bâton, son sablier, sa robe verte et ses bottes brunes ne doivent PAS apparaître : c'est le
personnage de la première image qui prend ces poses, avec son pantalon noir et ses propres bottes.

LA RANGÉE DE PROFIL, de gauche à droite :
1. jambes ouvertes, comme sur le guide : un pied devant, l'autre derrière
2. jambes ouvertes, comme sur le guide
3. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, un seul à peine levé
4. jambes ouvertes de nouveau, les pieds ont ÉCHANGÉ leur place
5. jambes ouvertes : l'INVERSE de l'image 1
6. jambes ouvertes : l'INVERSE de l'image 2
7. ⚠️ JAMBES JOINTES : les deux pieds sous le corps, l'un contre l'autre, l'autre à peine levé
8. jambes ouvertes de nouveau : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — LES JAMBES NE GARDENT JAMAIS LA MÊME POSE. De profil, aux images 3 et 7, la largeur
occupée par les deux pieds est MOINS DE LA MOITIÉ de celle des images 1 et 5. Dans les trois rangées, les
images 5 à 8 ne répètent pas les images 1 à 4 : les deux jambes échangent leurs places.

⚠️ RÈGLE BLOQUANTE — SEULS LES JAMBES ET LES BRAS BOUGENT. Dans une même rangée, la tête et le tronc se
superposent exactement d'une case à l'autre, et le profil regarde toujours VERS LA DROITE.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas du pied posé touche la même ligne horizontale dans les
24 cases, et rien n'est dessiné plus bas.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, aucun reflet du fond magenta, aucune poussière.
```
