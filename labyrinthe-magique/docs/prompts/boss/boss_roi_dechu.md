# Stage 9 · Le Sanctuaire Déchu — Le Roi Déchu

## Pourquoi celui-ci

`boss.png` attend depuis le début de la refonte sans être découpée, faute de
boss en jeu. Son armure noire et violette est celle du Sanctuaire : on garde
l'armure et l'allure de roi, et on redessine ses poses sur la grille du jeu,
car sa planche n'a ni grille régulière ni fond à effacer.

**Son combat, proposé.** Il combat à l'épée de près et tire des crânes de loin. Le
stage 9 oblige déjà à détruire les repaires : ce boss vient après, et rouvre un
cercle de vide sur les cases marquées.

**Son attaque de loin, proposée.** Portée : 3 cases marquées autour du mage. La zone s'allume
1.0 s avant le coup, et il recommence toutes les 4.3 s. Son coup au contact n'a pas de
zone : il se voit à son geste, sur la planche d'attaque.

**Avant de lancer :** Pour la marche, joindre `docs/prompts/boss/ref_roi_dechu.png`, son portrait, et `docs/prompts/mages_animes/guide_marche.png`. Pour l'attaque, joindre la planche de marche
livrée, pour que le générateur garde la même créature.

---

## Quatre planches

    boss_roi_dechu_marche.png    8 colonnes x 3 rangées   face / dos / profil DROIT
    boss_roi_dechu_attaque.png   8 colonnes x 3 rangées   face / dos / profil DROIT
    boss_roi_dechu_scene.png     8 colonnes x 3 rangées   arrivée / attaque de loin / mort, de face
    boss_roi_dechu_portee.png    8 colonnes x 3 rangées   alerte / coup / fin, vue du dessus

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

LA CRÉATURE — LE ROI DÉCHU, un énorme démon en armure, d'après l'image de
référence jointe : garde son armure et son épée, sur un corps de géant plus
massif. Forme humaine, très large et droit, bras épais aux griffes noires, deux
longues jambes massives, pieds griffus, SANS QUEUE. Armure noire écailleuse à
liserés de bronze doré, petit crâne de bronze à la ceinture. Tête haute aux
longues cornes noires recourbées : heaume fendu sur une GUEULE ouverte aux
crocs ivoire, yeux violet bleuté. Cape et pagne violet sombre en lambeaux. Il
tient à la main droite une longue épée noire dentelée, parcourue d'une veine
violet bleuté, pointe basse. COULEURS FROIDES : son violet tire vers le BLEU et
reste sombre, sans halo autour de lui, à la différence de l'image jointe. ⚠️
C'EST UN MONSTRE HUMANOÏDE : il se tient DEBOUT sur DEUX JAMBES, avec DEUX
bras, un torse droit, un cou et une tête à leur place, les proportions d'un
homme géant, jamais voûté comme un singe. JAMAIS à quatre pattes, jamais un
animal, jamais un humain ordinaire. Il reste effrayant et MASSIF, aux membres
épais, griffes ou crocs bien visibles, jamais mignon, sans les proportions d'un
enfant. IL EST GRAND : debout à côté d'un mage humain, il le dépasse nettement,
d'environ une demi-hauteur de plus. Cette masse doit se lire sur la silhouette.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : la créature vue DE FACE, elle avance vers le bas de l'image
- rangée 2 : la créature vue DE DOS, elle s'éloigne vers le haut de l'image
- rangée 3 : la créature vue DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers
  la droite de l'image

LES 8 COLONNES de chaque rangée, lues de gauche à droite, sont une MARCHE DE BOSS : pas lourds et sûrs, la cape ondule derrière lui, l'épée tenue d'une main, pointe basse, la main gauche ouverte. Ce cycle, et voici ce que chacune doit montrer :
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
- de dos, on voit la cape déchirée, les cornes, et le bout de la lame qui dépasse à droite
- de profil, la lame est DEVANT lui, la cape DERRIÈRE lui
- AUCUN halo, aucune brume, aucun éclat autour de lui, hors des images où son geste en demande un : le fond doit rester un magenta pur
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

LA CRÉATURE — LE ROI DÉCHU, un énorme démon en armure, d'après l'image de
référence jointe : garde son armure et son épée, sur un corps de géant plus
massif. Forme humaine, très large et droit, bras épais aux griffes noires, deux
longues jambes massives, pieds griffus, SANS QUEUE. Armure noire écailleuse à
liserés de bronze doré, petit crâne de bronze à la ceinture. Tête haute aux
longues cornes noires recourbées : heaume fendu sur une GUEULE ouverte aux
crocs ivoire, yeux violet bleuté. Cape et pagne violet sombre en lambeaux. Il
tient à la main droite une longue épée noire dentelée, parcourue d'une veine
violet bleuté, pointe basse. COULEURS FROIDES : son violet tire vers le BLEU et
reste sombre, sans halo autour de lui, à la différence de l'image jointe. ⚠️
C'EST UN MONSTRE HUMANOÏDE : il se tient DEBOUT sur DEUX JAMBES, avec DEUX
bras, un torse droit, un cou et une tête à leur place, les proportions d'un
homme géant, jamais voûté comme un singe. JAMAIS à quatre pattes, jamais un
animal, jamais un humain ordinaire. Il reste effrayant et MASSIF, aux membres
épais, griffes ou crocs bien visibles, jamais mignon, sans les proportions d'un
enfant. IL EST GRAND : debout à côté d'un mage humain, il le dépasse nettement,
d'environ une demi-hauteur de plus. Cette masse doit se lire sur la silhouette.

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
1. il se campe, l'épée basse
2. il lève l'épée au-dessus de son épaule
3. l'épée est au plus haut, sa veine s'allume
4. il abat l'épée, la cape se soulève
5. L'IMPACT : la lame au bout de sa course, DEVANT lui, avec une traînée en croissant violet bleuté au plus large
6. la traînée se dissipe, la lame touche presque le sol
7. il relève le buste, l'épée revient
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
- de dos, on voit la cape déchirée, les cornes, et le bout de la lame qui dépasse à droite
- de profil, la lame est DEVANT lui, la cape DERRIÈRE lui
- AUCUN halo, aucune brume, aucun éclat autour de lui, hors des images où son geste en demande un : le fond doit rester un magenta pur
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

LA CRÉATURE — LE ROI DÉCHU, un énorme démon en armure, d'après l'image de
référence jointe : garde son armure et son épée, sur un corps de géant plus
massif. Forme humaine, très large et droit, bras épais aux griffes noires, deux
longues jambes massives, pieds griffus, SANS QUEUE. Armure noire écailleuse à
liserés de bronze doré, petit crâne de bronze à la ceinture. Tête haute aux
longues cornes noires recourbées : heaume fendu sur une GUEULE ouverte aux
crocs ivoire, yeux violet bleuté. Cape et pagne violet sombre en lambeaux. Il
tient à la main droite une longue épée noire dentelée, parcourue d'une veine
violet bleuté, pointe basse. COULEURS FROIDES : son violet tire vers le BLEU et
reste sombre, sans halo autour de lui, à la différence de l'image jointe. ⚠️
C'EST UN MONSTRE HUMANOÏDE : il se tient DEBOUT sur DEUX JAMBES, avec DEUX
bras, un torse droit, un cou et une tête à leur place, les proportions d'un
homme géant, jamais voûté comme un singe. JAMAIS à quatre pattes, jamais un
animal, jamais un humain ordinaire. Il reste effrayant et MASSIF, aux membres
épais, griffes ou crocs bien visibles, jamais mignon, sans les proportions d'un
enfant. IL EST GRAND : debout à côté d'un mage humain, il le dépasse nettement,
d'environ une demi-hauteur de plus. Cette masse doit se lire sur la silhouette.

⚠️ L'IMAGE JOINTE EST SA PLANCHE DE MARCHE : c'est cette créature-là, à l'identique,
avec les mêmes couleurs et la même taille.

CETTE PLANCHE EST TOUTE ENTIÈRE DE FACE. La créature regarde vers le bas de l'image
dans les 24 cases, sans se retourner. Chaque rangée se lit de gauche à droite et ne
boucle pas : les rangées 1 et 2 finissent en pose de marche.

RANGÉE 1 — SON ARRIVÉE, de l'immobilité au rugissement :
1. il est un genou à terre, tête baissée, les deux mains sur la garde de l'épée
2. ses yeux s'allument sous le heaume
3. il relève la tête
4. il se relève, l'épée encore plantée
5. il est debout, il arrache l'épée du sol
6. il lève la main gauche, ouverte
7. IL RUGIT : gueule grande ouverte, épée pointée devant lui, cape soulevée
8. il rejoint la pose de marche

RANGÉE 2 — SON ATTAQUE DE LOIN : le geste seulement. La zone et l'effet sont sur une autre planche :
1. il se campe, l'épée basse
2. il lève la main gauche, une petite lueur s'y forme
3. la lueur grossit en une orbe violet bleuté, sans halo autour de lui
4. il lève l'orbe au-dessus de sa tête
5. il plante l'épée au sol et abaisse l'orbe
6. LE GESTE : l'épée plantée, la main gauche tendue vers le sol, l'orbe éclate
7. la lueur s'éteint
8. il reprend l'épée et rejoint la pose de marche

RANGÉE 3 — SA MORT : la dernière image reste à l'écran, la créature y est encore visible :
1. il recule d'un pas, une main sur le plastron
2. son épée s'échappe et pointe vers le sol
3. il plante l'épée pour se retenir
4. il tombe un genou à terre
5. ses cornes se fendent, il penche la tête
6. il lâche l'épée et s'affaisse
7. son armure s'effondre, ses yeux s'éteignent
8. il ne reste qu'un tas d'armure noire, l'épée plantée à côté

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
- AUCUN halo, aucune brume, aucun éclat autour de lui, hors des images où son geste en demande un : le fond doit rester un magenta pur
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

CE QUE MONTRE CETTE PLANCHE — la portée de l'attaque DE LOIN de Le Roi Déchu, sur le sol.
LE MONSTRE N'EST PAS DESSINÉ : aucune créature, aucun personnage. Le jeu pose cette zone
sur le terrain, loin de lui, pour que le joueur la voie et s'enfuie à temps.

LA ZONE — un ROND parfait vu du dessus, centré dans la case, large de 90 % de la case, sans toucher les bords. Elle reste au même endroit et de la même taille dans les
rangées 1 et 2.
- son CONTOUR est épais, blanc-jaune vif, avec un fin liseré NOIR des deux côtés : il doit
  se voir sur n'importe quel sol du jeu, clair ou sombre, et dire DANGER au premier regard
- son INTÉRIEUR montre un cercle noir bleuté, gravé de runes violet bleuté

RANGÉE 1 — L'ALERTE, on voit venir le coup. Lue de gauche à droite, sans boucler :
1. le contour seul, fin, l'intérieur encore vide de magenta
2. le contour s'épaissit
3. l'intérieur se remplit au centre, sur un quart de la zone
4. l'intérieur est rempli à moitié, depuis le centre
5. l'intérieur est rempli aux trois quarts
6. l'intérieur est plein
7. le contour clignote : il devient blanc pur
8. DERNIER INSTANT : contour blanc pur au plus épais, intérieur au plus vif

RANGÉE 2 — LE COUP : le cercle s'ouvre sur un vide noir, et un crâne ivoire aux yeux violet bleuté en sort vers le haut, entouré d'éclats. Lue de gauche à droite :
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

Les déposer dans `assets/peso&cover/creatures/`. `tools/build_bosses.py boss_roi_dechu` les
découpe vers `assets/enemies/boss_roi_dechu/`. Le combat de ce boss n'est **pas encore
programmé**.

*Fiche produite par `tools/build_prompts_boss.py`.*
