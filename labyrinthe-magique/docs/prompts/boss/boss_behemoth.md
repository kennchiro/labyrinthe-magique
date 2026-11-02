# Stage 4 · Les Rivages Océaniques — Le Béhémoth des Abysses

## Pourquoi celui-ci

Le stage 4 amène l'Ombre et la Gelée, sans visage ni l'une ni l'autre. Une
énorme géant remonté des fonds apporte une gueule qu'on n'oublie pas, et une
pince dont la portée se voit.

**Son combat, proposé.** Il frappe de sa pince au contact et lance son pouvoir de
loin : une vague balaie un couloir, blesse le mage et le repousse.

**Son attaque de loin, proposée.** Portée : un couloir de 6 cases devant lui. La zone s'allume
1.4 s avant le coup, et il recommence toutes les 6.0 s. Son coup au contact n'a pas de
zone : il se voit à son geste, sur la planche d'attaque.

**Avant de lancer :** Pour la marche, joindre `docs/prompts/mages_animes/guide_marche.png`. Pour l'attaque, joindre la planche de marche
livrée, pour que le générateur garde la même créature.

---

## Quatre planches

    boss_behemoth_marche.png    8 colonnes x 3 rangées   face / dos / profil DROIT
    boss_behemoth_attaque.png   8 colonnes x 3 rangées   face / dos / profil DROIT
    boss_behemoth_scene.png     8 colonnes x 3 rangées   arrivée / attaque de loin / mort, de face
    boss_behemoth_portee.png    8 colonnes x 3 rangées   alerte / coup / fin, vue du dessus

Une seule image reviendrait bouillie : chaque planche garde des cases de 256 pixels. La
scène n'est dessinée que de face, car ces trois moments ne dépendent pas de la direction
où le boss regardait. La portée est à part parce que le jeu la pose loin du boss.

⚠️ **La gauche n'est PAS demandée.** Le jeu la fabrique en retournant le profil
droit. Deux dessins donneraient deux démarches — et c'est exactement le défaut
qui a fait marcher sept créatures de ce jeu à reculons pendant des semaines,
sans que rien ne le signale.

⚠️ **Le profil regarde à DROITE.** C'est la seule chose que la convention ne
disait pas, et elle a coûté cher. Les indices qui tranchent : l'œil, la gueule,
et la traînée du coup qui part DEVANT.

Les quatre planches vont dans `assets/peso&cover/creatures/`.

---

## Prompt 1 — la marche

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases. Trois choses en
  particulier, qui reviennent sans cesse et qu'il faut supprimer :
    * AUCUNE OMBRE PORTÉE sous la créature — pas de flaque, pas de tache
    * AUCUN TRAIT entre les cases — pas de cadre, pas de bordure, pas de grille
    * aucun dégradé, aucune texture : un aplat, la même couleur partout
- dans chaque case, la créature est CENTRÉE et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LA CRÉATURE — LE BÉHÉMOTH DES ABYSSES, un énorme monstre marin à forme humaine,
qui marche debout. Corps d'homme géant, torse droit, à la peau bleu-vert
sombre, ventre gris pâle. Tête de géant monstrueux, bien dégagée des épaules :
immense gueule ouverte aux longues dents ivoire en désordre, petits yeux
turquoise lumineux, et sur le front une antenne terminée par un LEURRE
turquoise qui brille. Le bras droit finit par une ÉNORME PINCE de crabe orange
sombre, le bras gauche par une grosse main palmée griffue. Dos couvert de
coraux ORANGE, de coquillages et d'algues vert sombre. Deux longues jambes très
épaisses, pieds palmés griffus. ⚠️ C'EST UN MONSTRE HUMANOÏDE : il se tient
DEBOUT sur DEUX JAMBES, avec DEUX bras, un torse droit, un cou et une tête à
leur place, les proportions d'un homme géant, jamais voûté comme un singe.
JAMAIS à quatre pattes, jamais un animal, jamais un humain ordinaire. Il reste
effrayant et MASSIF, aux membres épais, griffes ou crocs bien visibles, jamais
mignon, sans les proportions d'un enfant. IL EST GRAND : debout à côté d'un
mage humain, il le dépasse nettement, d'environ une demi-hauteur de plus. Cette
masse doit se lire sur la silhouette.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : la créature vue DE FACE, elle avance vers le bas de l'image
- rangée 2 : la créature vue DE DOS, elle s'éloigne vers le haut de l'image
- rangée 3 : la créature vue DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers
  la droite de l'image

LES 8 COLONNES de chaque rangée, lues de gauche à droite, sont une MARCHE DE BOSS pesante : il roule des épaules, le buste droit, la pince tenue basse, le leurre oscille à contretemps, de l'eau dégoutte de ses bras. Ce cycle, et voici ce que chacune doit montrer :
1. le pied proche est devant, le pied éloigné derrière, les deux posés
2. le pied proche recule, le pied éloigné se lève à peine
3. PASSAGE : les pieds se croisent, le pied éloigné levé
4. le pied éloigné passe devant, le pied proche recule
5. l'INVERSE de l'image 1 : le pied éloigné devant, le pied proche derrière
6. le pied éloigné recule, le pied proche se lève à peine
7. PASSAGE : les pieds se croisent, le pied proche levé
8. le pied proche passe devant : l'image enchaîne sur la première

La 8e image enchaîne sur la première sans à-coup.

⚠️ L'IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche à
produire. Dans chaque case, recopie EXACTEMENT la position de ses deux pieds et la
place de son corps. Le pied ROUGE est la jambe la plus proche de nous, le pied BLEU
la plus éloignée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est la
créature décrite ici, avec ses vraies pattes, qui prend ces poses.

⚠️ RÈGLE BLOQUANTE — NI GRAND ÉCART NI PIEDS COLLÉS. De profil, aux images 1 et 5,
l'écart entre les pieds vaut environ UN TIERS DE LA HAUTEUR de la créature, jamais
plus. Les deux pieds échangent leur place : celui qui est devant à l'image 1 est
derrière à l'image 5. De face et de dos, les pieds restent sous le corps, sans
s'écarter vers les côtés : l'un puis l'autre se lève.

⚠️ RÈGLE BLOQUANTE — LA CRÉATURE EST DESSINÉE DANS LES 24 CASES, sans une seule
exception. Son coup, son souffle, sa rafale ou son projectile s'ajoutent à elle,
ils ne la REMPLACENT jamais : pas une case où l'on ne verrait que l'effet. Le jeu
enchaîne ces images en une seconde — une case sans la bête la fait disparaître au
milieu de son propre coup, ce que le joueur lit comme un bug d'affichage.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa
tête est tournée VERS LA DROITE dans les 8 cases, sans une seule exception. Elle
ne doit pas regarder à droite sur une case et à gauche sur la suivante : en jeu,
les 8 cases s'enchaînent en une seconde, et la créature se retournerait la tête
quatre fois en marchant.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Ce sont les deux défauts
livrés le plus souvent, et aucun des deux ne se rattrape après coup :

  · l'OMBRE sous la créature est un magenta assombri. Le jeu efface le fond en
    mesurant l'écart à sa couleur : l'ombre en est trop loin pour être effacée,
    et il en reste une flaque rose collée sous la bête dans les 24 cases. On ne
    peut pas la viser sans risquer la créature elle-même — c'est mesuré : la
    brume violette d'un autre monstre de ce jeu est PLUS magenta que cette
    flaque. Il n'y a donc qu'un endroit où la retirer : ici, en ne la dessinant
    pas.

  · le TRAIT entre les cases est blanc, donc aussi loin du magenta qu'on peut
    l'être : il survit à tout et devient le bord de chaque sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. C'est la règle
la plus souvent ratée, alors voici comment la vérifier toi-même :

    EMPILE MENTALEMENT LES 8 IMAGES D'UNE RANGÉE.
    Le TRONC et la TÊTE doivent se superposer exactement.
    Seuls les bras, les jambes, la cape et l'arme bougent.

Autrement dit : la créature est CENTRÉE au même endroit dans les 8 cases, à
quelques pixels près, et elle garde exactement la même taille. Ne dessine SURTOUT
PAS une marche qui traverse le cadre — un personnage qui part du bord gauche à la
première image et arrive au bord droit à la huitième est précisément le défaut à
éviter. C'est le JEU qui la fait avancer sur la carte ; la planche ne montre que
le mouvement des membres, sur place, comme quelqu'un qui marcherait sur un tapis
roulant.

Une créature qui dérive dans son cadre patine d'avant en arrière à l'écran au
lieu de marcher, et son arme sort de la case au passage.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de la créature doit toucher
la même ligne dans les 24 cases. C'est cette ligne que le jeu pose sur le sol :
si elle bouge, le monstre s'enfonce et ressort du sol en marchant.

AUTRES RÈGLES :
- la MÊME créature dans les 24 cases : mêmes couleurs, même taille
- le profil regarde VERS LA DROITE dans les 8 cases de la rangée 3, sans
  exception
- de dos, on voit le dos de coraux et d'algues, et la pince qui dépasse à droite
- de profil, la gueule, le leurre et la pince sont DEVANT lui, à droite
- ce qu'elle porte ne sort JAMAIS de sa case : plie ses membres plutôt que de réduire la créature, de la même taille partout
- ne dessine AUCUNE planche de plus, seulement les trois rangées demandées
- AUCUN ROSE ET AUCUN MAGENTA sur la créature ni dans ses effets : ce serait effacé avec le fond
- aucune attaque, aucun projectile : elle se déplace, c'est tout
```

---

## Prompt 2 — l'attaque

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases. Trois choses en
  particulier, qui reviennent sans cesse et qu'il faut supprimer :
    * AUCUNE OMBRE PORTÉE sous la créature — pas de flaque, pas de tache
    * AUCUN TRAIT entre les cases — pas de cadre, pas de bordure, pas de grille
    * aucun dégradé, aucune texture : un aplat, la même couleur partout
- dans chaque case, la créature est CENTRÉE et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LA CRÉATURE — LE BÉHÉMOTH DES ABYSSES, un énorme monstre marin à forme humaine,
qui marche debout. Corps d'homme géant, torse droit, à la peau bleu-vert
sombre, ventre gris pâle. Tête de géant monstrueux, bien dégagée des épaules :
immense gueule ouverte aux longues dents ivoire en désordre, petits yeux
turquoise lumineux, et sur le front une antenne terminée par un LEURRE
turquoise qui brille. Le bras droit finit par une ÉNORME PINCE de crabe orange
sombre, le bras gauche par une grosse main palmée griffue. Dos couvert de
coraux ORANGE, de coquillages et d'algues vert sombre. Deux longues jambes très
épaisses, pieds palmés griffus. ⚠️ C'EST UN MONSTRE HUMANOÏDE : il se tient
DEBOUT sur DEUX JAMBES, avec DEUX bras, un torse droit, un cou et une tête à
leur place, les proportions d'un homme géant, jamais voûté comme un singe.
JAMAIS à quatre pattes, jamais un animal, jamais un humain ordinaire. Il reste
effrayant et MASSIF, aux membres épais, griffes ou crocs bien visibles, jamais
mignon, sans les proportions d'un enfant. IL EST GRAND : debout à côté d'un
mage humain, il le dépasse nettement, d'environ une demi-hauteur de plus. Cette
masse doit se lire sur la silhouette.

⚠️ L'IMAGE JOINTE EST SA PLANCHE DE MARCHE : c'est cette créature-là, à l'identique.

⚠️ MÊMES COULEURS ET MÊME TAILLE QUE LA PLANCHE DE MARCHE. Les deux planches
sont jouées l'une après l'autre sur le même monstre : une teinte plus sombre ou
une créature plus grande se verrait comme un clignotement au moment du coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle frappe VERS LE BAS, face au joueur
- rangée 2 : elle frappe VERS LE HAUT, de dos
- rangée 3 : elle frappe VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL COUP qui se déroule, lu de
gauche à droite — ce n'est PAS une boucle :
1. il se campe, la pince tirée en arrière
2. il lève la pince au-dessus de son épaule, elle s'ouvre
3. la pince est au plus haut, grande ouverte, le leurre brille
4. il l'abat à bout de bras
5. L'IMPACT : la pince au bout de sa course, DEVANT lui, avec une gerbe d'eau turquoise au plus large
6. la gerbe retombe, la pince se referme près du sol
7. il relève le buste, la pince revient
8. il rejoint la pose de marche

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE. Le jeu enchaîne
directement sur le déplacement : si la créature reste en position de combat à la
dernière image, elle se remettra à marcher dans cette pose.

⚠️ RÈGLE BLOQUANTE — LA CRÉATURE EST DESSINÉE DANS LES 24 CASES, sans une seule
exception. Son coup, son souffle, sa rafale ou son projectile s'ajoutent à elle,
ils ne la REMPLACENT jamais : pas une case où l'on ne verrait que l'effet. Le jeu
enchaîne ces images en une seconde — une case sans la bête la fait disparaître au
milieu de son propre coup, ce que le joueur lit comme un bug d'affichage.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa
tête est tournée VERS LA DROITE dans les 8 cases, sans une seule exception. Elle
ne doit pas regarder à droite sur une case et à gauche sur la suivante : en jeu,
les 8 cases s'enchaînent en une seconde, et la créature se retournerait la tête
quatre fois en marchant.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Ce sont les deux défauts
livrés le plus souvent, et aucun des deux ne se rattrape après coup :

  · l'OMBRE sous la créature est un magenta assombri. Le jeu efface le fond en
    mesurant l'écart à sa couleur : l'ombre en est trop loin pour être effacée,
    et il en reste une flaque rose collée sous la bête dans les 24 cases. On ne
    peut pas la viser sans risquer la créature elle-même — c'est mesuré : la
    brume violette d'un autre monstre de ce jeu est PLUS magenta que cette
    flaque. Il n'y a donc qu'un endroit où la retirer : ici, en ne la dessinant
    pas.

  · le TRAIT entre les cases est blanc, donc aussi loin du magenta qu'on peut
    l'être : il survit à tout et devient le bord de chaque sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. C'est la règle
la plus souvent ratée, alors voici comment la vérifier toi-même :

    EMPILE MENTALEMENT LES 8 IMAGES D'UNE RANGÉE.
    Le TRONC et la TÊTE doivent se superposer exactement.
    Seuls les bras, les jambes, la cape et l'arme bougent.

Autrement dit : la créature est CENTRÉE au même endroit dans les 8 cases, à
quelques pixels près, et elle garde exactement la même taille. Ne dessine SURTOUT
PAS une marche qui traverse le cadre — un personnage qui part du bord gauche à la
première image et arrive au bord droit à la huitième est précisément le défaut à
éviter. C'est le JEU qui la fait avancer sur la carte ; la planche ne montre que
le mouvement des membres, sur place, comme quelqu'un qui marcherait sur un tapis
roulant.

Une créature qui dérive dans son cadre patine d'avant en arrière à l'écran au
lieu de marcher, et son arme sort de la case au passage.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de la créature doit toucher
la même ligne dans les 24 cases. C'est cette ligne que le jeu pose sur le sol :
si elle bouge, le monstre s'enfonce et ressort du sol en marchant.

AUTRES RÈGLES :
- la traînée du coup part DEVANT elle, dans la direction qu'elle frappe — vers le
  bas rangée 1, vers le haut rangée 2, vers la droite rangée 3
- de dos, on voit le dos de coraux et d'algues, et la pince qui dépasse à droite
- de profil, la gueule, le leurre et la pince sont DEVANT lui, à droite
- ce qu'elle porte ne sort JAMAIS de sa case : plie ses membres plutôt que de réduire la créature, de la même taille partout
- ne dessine AUCUNE planche de plus, seulement les trois rangées demandées
- AUCUN ROSE ET AUCUN MAGENTA sur la créature ni dans ses effets : ce serait effacé avec le fond
- rien ne QUITTE la case : cette créature frappe au contact, elle ne tire pas
```

---

## Prompt 3 — la scène : arrivée, attaque de loin, mort

Joindre la planche de marche livrée.

```
Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases. Trois choses en
  particulier, qui reviennent sans cesse et qu'il faut supprimer :
    * AUCUNE OMBRE PORTÉE sous la créature — pas de flaque, pas de tache
    * AUCUN TRAIT entre les cases — pas de cadre, pas de bordure, pas de grille
    * aucun dégradé, aucune texture : un aplat, la même couleur partout
- dans chaque case, la créature est CENTRÉE et occupe environ 90 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LA CRÉATURE — LE BÉHÉMOTH DES ABYSSES, un énorme monstre marin à forme humaine,
qui marche debout. Corps d'homme géant, torse droit, à la peau bleu-vert
sombre, ventre gris pâle. Tête de géant monstrueux, bien dégagée des épaules :
immense gueule ouverte aux longues dents ivoire en désordre, petits yeux
turquoise lumineux, et sur le front une antenne terminée par un LEURRE
turquoise qui brille. Le bras droit finit par une ÉNORME PINCE de crabe orange
sombre, le bras gauche par une grosse main palmée griffue. Dos couvert de
coraux ORANGE, de coquillages et d'algues vert sombre. Deux longues jambes très
épaisses, pieds palmés griffus. ⚠️ C'EST UN MONSTRE HUMANOÏDE : il se tient
DEBOUT sur DEUX JAMBES, avec DEUX bras, un torse droit, un cou et une tête à
leur place, les proportions d'un homme géant, jamais voûté comme un singe.
JAMAIS à quatre pattes, jamais un animal, jamais un humain ordinaire. Il reste
effrayant et MASSIF, aux membres épais, griffes ou crocs bien visibles, jamais
mignon, sans les proportions d'un enfant. IL EST GRAND : debout à côté d'un
mage humain, il le dépasse nettement, d'environ une demi-hauteur de plus. Cette
masse doit se lire sur la silhouette.

⚠️ L'IMAGE JOINTE EST SA PLANCHE DE MARCHE : c'est cette créature-là, à l'identique,
avec les mêmes couleurs et la même taille.

CETTE PLANCHE EST TOUTE ENTIÈRE DE FACE. La créature regarde vers le bas de l'image
dans les 24 cases, sans se retourner. Chaque rangée se lit de gauche à droite et ne
boucle pas : les rangées 1 et 2 finissent en pose de marche.

RANGÉE 1 — SON ARRIVÉE, de l'immobilité au rugissement :
1. il est tassé sur lui-même comme un rocher couvert de coraux, le leurre éteint
2. de l'eau coule de son dos, le leurre s'allume faiblement
3. ses yeux s'allument, sa tête se dégage
4. il redresse les épaules
5. il déplie la pince et la main griffue
6. il ouvre lentement la gueule
7. IL RUGIT : gueule grande ouverte, pince levée, leurre au plus fort
8. il rejoint la pose de marche

RANGÉE 2 — SON ATTAQUE DE LOIN : le geste seulement. La zone et l'effet sont sur une autre planche :
1. il plante ses pieds, les bras écartés
2. il lève la main griffue, de l'eau tourne autour de son poignet
3. l'eau monte autour de son bras jusqu'à l'épaule
4. il lève la pince au-dessus de lui, le leurre brille
5. il abat la pince sur le sol
6. LE GESTE : la pince au sol, une couronne d'eau collée autour de ses pieds
7. l'eau retombe
8. il se redresse et rejoint la pose de marche

RANGÉE 3 — SA MORT : la dernière image reste à l'écran, la créature y est encore visible :
1. il recule, la main griffue sur le ventre
2. le leurre clignote, sa gueule s'ouvre sans bruit
3. ses genoux plient, la pince retombe
4. il tombe à genoux, la tête basse
5. il bascule sur le côté, de l'eau sort de sa gueule
6. il est à terre, ses yeux s'éteignent
7. le leurre s'éteint et retombe sur le sol
8. il ne bouge plus, masse de coraux et de chair, la pince ouverte

⚠️ RÈGLE BLOQUANTE — LA CRÉATURE EST VISIBLE DANS LES 24 CASES, y compris à la
dernière image de sa mort. C'est le jeu qui la fera disparaître en fondu.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA CRÉATURE RESTE SUR LA MÊME LIGNE dans les 24
cases, et elle reste centrée. Elle peut se baisser ou s'effondrer, mais vers cette ligne,
sans jamais descendre en dessous ni glisser sur le côté.

⚠️ RÈGLE BLOQUANTE — RIEN NE S'ÉLOIGNE D'ELLE. Pas de racines, de vague, de foudre ni de
cristaux qui partent sur le terrain : un petit effet collé à son corps est seul permis.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Ce sont les deux défauts
livrés le plus souvent, et aucun des deux ne se rattrape après coup :

  · l'OMBRE sous la créature est un magenta assombri. Le jeu efface le fond en
    mesurant l'écart à sa couleur : l'ombre en est trop loin pour être effacée,
    et il en reste une flaque rose collée sous la bête dans les 24 cases. On ne
    peut pas la viser sans risquer la créature elle-même — c'est mesuré : la
    brume violette d'un autre monstre de ce jeu est PLUS magenta que cette
    flaque. Il n'y a donc qu'un endroit où la retirer : ici, en ne la dessinant
    pas.

  · le TRAIT entre les cases est blanc, donc aussi loin du magenta qu'on peut
    l'être : il survit à tout et devient le bord de chaque sprite.

AUTRES RÈGLES :
- ce qu'elle porte ne sort JAMAIS de sa case : plie ses membres plutôt que de réduire la créature, de la même taille partout
- ne dessine AUCUNE planche de plus, seulement les trois rangées demandées
- AUCUN ROSE ET AUCUN MAGENTA sur la créature ni dans ses effets : ce serait effacé avec le fond
```

---

## Prompt 4 — la portée : alerte, coup, fin

Ne rien joindre : le monstre n'y apparaît pas.

```
Feuille d'effets pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré
à contours nets, même facture que les sprites d'un jeu de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 768 pixels
- grille RÉGULIÈRE de 8 colonnes x 3 rangées, soit 24 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases
- aucun trait entre les cases, aucun texte, aucun chiffre, aucun décor

CE QUE MONTRE CETTE PLANCHE — la portée de l'attaque DE LOIN de Le Béhémoth des Abysses, sur le sol.
LE MONSTRE N'EST PAS DESSINÉ : aucune créature, aucun personnage. Le jeu pose cette zone
sur le terrain, loin de lui, pour que le joueur la voie et s'enfuie à temps.

LA ZONE — une BANDE horizontale vue du dessus, haute de 60 % de la case, qui va exactement du bord gauche au bord droit de la case : le jeu met ces cases bout à bout pour tracer une ligne continue. Son contour ne court QUE le long de son bord haut et de son bord bas, droit et sans angle. JAMAIS de contour à gauche ni à droite, jamais de cercle ni de cadre fermé. Elle reste au même endroit et de la même taille dans les
rangées 1 et 2.
- son CONTOUR est épais, blanc-jaune vif, avec un fin liseré NOIR des deux côtés : il doit
  se voir sur n'importe quel sol du jeu, clair ou sombre, et dire DANGER au premier regard
- son INTÉRIEUR montre une eau turquoise agitée de petites vaguelettes

RANGÉE 1 — L'ALERTE, on voit venir le coup. Lue de gauche à droite, sans boucler :
1. le contour seul, fin, l'intérieur encore vide de magenta
2. le contour s'épaissit
3. l'intérieur se remplit au centre, sur un quart de la zone
4. l'intérieur est rempli à moitié, depuis le centre
5. l'intérieur est rempli aux trois quarts
6. l'intérieur est plein
7. le contour clignote : il devient blanc pur
8. DERNIER INSTANT : contour blanc pur au plus épais, intérieur au plus vif

RANGÉE 2 — LE COUP : une grande vague turquoise à crête d'écume blanche se dresse sur toute la largeur de la bande. Lue de gauche à droite :
1. le premier éclat, au centre de la zone, tout petit
2. l'effet grandit
3. l'effet grandit encore
4. L'IMPACT : l'effet est à son plus grand, sans sortir de la case
5. il tient, encore très grand
6. il commence à retomber
7. il retombe nettement
8. il n'en reste que la moitié

RANGÉE 3 — LA FIN, le danger est passé : la même zone qui s'éteint, de gauche à droite.
Le contour disparaît dès l'image 2. L'effet se défait peu à peu. L'image 7 ne garde que
quelques débris, et l'image 8 est une CASE VIDE, tout en magenta.

⚠️ RÈGLE BLOQUANTE — RIEN N'EST TRANSPARENT, RIEN N'EST FLOU. Tout a un bord net et des
couleurs pleines : pas de halo, pas de lueur qui se fond dans le fond, pas d'ombre portée.
Le jeu efface le magenta et ajoute lui-même la transparence. Un dégradé vers le fond
laisserait une frange rose autour de la zone, et elle ne se rattrape pas.

⚠️ RÈGLE BLOQUANTE — RIEN NE SORT DE SA CASE. L'effet tient dans ses 256 x 256 pixels,
même au moment de l'impact.

AUTRES RÈGLES :
- AUCUN ROSE ET AUCUN MAGENTA sur la créature ni dans ses effets : ce serait effacé avec le fond
- ne dessine AUCUNE planche de plus, seulement les trois rangées demandées
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le profil regarde à gauche | **défaut bloquant** : le monstre marchera à reculons. Rappeler « tourné vers la DROITE » et nommer l'indice — l'œil, la gueule, la traînée devant |
| Une case ne montre que l'effet, sans la créature | **défaut bloquant** : elle disparaîtrait en plein coup. `build_enemies.py` mesure la matière du haut de case et nomme les fautives |
| Le profil change de côté d'une case à l'autre | **défaut bloquant**, et le plus sournois : vu de loin la planche semble juste. La créature se retournerait la tête quatre fois par cycle. `build_enemies.py` le mesure et nomme les cases fautives |
| Une ombre portée est dessinée sur le fond | **défaut bloquant** : elle survit à l'effacement du magenta et laisse une salissure grise sous la bête |
| La créature dérive dans son cadre d'une case à l'autre | **défaut bloquant**, et le plus fréquent : elle patinerait d'avant en arrière au lieu de marcher. Redemander en insistant sur « le tronc se superpose d'une image à l'autre, seuls les membres bougent ». `build_enemies.py` mesure la dérive en pixels |
| La créature change de taille d'une case à l'autre | **défaut bloquant** : elle sauterait à l'écran à chaque image |
| Le bas de la créature bouge d'une case à l'autre | **défaut bloquant** : elle s'enfoncerait dans le sol en marchant |
| Les deux planches n'ont pas les mêmes couleurs | rappeler « mêmes couleurs, même taille » — sinon clignotement au moment du coup |
| Le cycle de marche ne boucle pas | moins grave — huit images passent vite. À corriger si on le voit sauter |
| La dernière image d'attaque reste en garde | rappeler « elle rejoint la pose de marche » |

---

## Ce que je fais quand elles arrivent

Les déposer dans `assets/peso&cover/creatures/`. `tools/build_bosses.py boss_behemoth` les
découpe vers `assets/enemies/boss_behemoth/`. Le combat de ce boss n'est **pas encore
programmé**.

*Fiche produite par `tools/build_prompts_boss.py`.*
