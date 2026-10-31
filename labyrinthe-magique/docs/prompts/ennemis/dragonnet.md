# Dragonnet de Feu — planches de marche et d'attaque

## Pourquoi celui-ci

Il vole, donc il ne ralentit jamais dans les virages : c'est le seul dont le
battement d'ailes doit rester lisible à toute vitesse.

    aujourd'hui   4 pas · 1 pose de coup
    demain        4 orientations · 8 pas · 8 poses de coup

⚠️ **Le moteur sait déjà les jouer.** Il lit les poses par leur NOM et non par
leur nombre : une planche à seize poses et une planche à six se jouent par le
même code, et l'attaque se déroule sur la durée exacte de la frappe. Les autres
créatures continuent de tourner sans y toucher. Il ne manque que le dessin.

---

## Deux planches, et pourquoi pas une

    dragonnet_marche.png    8 colonnes x 3 rangées   face / dos / profil DROIT
    dragonnet_attaque.png   8 colonnes x 3 rangées   face / dos / profil DROIT

Quarante-huit cases dans une seule image reviendraient bouillies : chaque pose
ferait moins de 256 pixels et la créature perdrait son visage. En deux
planches, chaque case reste grande.

⚠️ **La gauche n'est PAS demandée.** Le jeu la fabrique en retournant le profil
droit. Deux dessins donneraient deux démarches — et c'est exactement le défaut
qui a fait marcher sept créatures de ce jeu à reculons pendant des semaines,
sans que rien ne le signale.

⚠️ **Le profil regarde à DROITE.** C'est la seule chose que la convention ne
disait pas, et elle a coûté cher. Les indices qui tranchent : l'œil, la gueule,
et la traînée du coup qui part DEVANT.

Les deux planches vont dans `assets/peso&cover/creatures/`.

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
- dans chaque case, la créature est CENTRÉE et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LA CRÉATURE — UN DRAGONNET DE FEU. Un petit dragon rouge sang aux écailles
sombres, avec deux grandes ailes membraneuses rouge vif nervurées de noir, bien
plus larges que son corps. Deux cornes dorées recourbées sur la tête, des yeux
jaunes, une petite gueule pleine de crocs. Une flamme orange brûle sous lui,
entre ses pattes repliées.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : la créature vue DE FACE, elle avance vers le bas de l'image
- rangée 2 : la créature vue DE DOS, elle s'éloigne vers le haut de l'image
- rangée 3 : la créature vue DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers
  la droite de l'image

LES 8 COLONNES de chaque rangée, lues de gauche à droite, sont un BATTEMENT D'AILES complet : les ailes montent, s'ouvrent en grand, redescendent ; le corps monte et descend légèrement à contretemps, la flamme sous lui s'étire et se ramasse. La 8e image doit enchaîner sur la première sans à-coup.

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

⚠️ RÈGLE BLOQUANTE — LES JAMBES DOIVENT FAIRE DE VRAIS PAS. Le corps reste en
place, mais les JAMBES, elles, doivent travailler franchement : sur la rangée de
profil, on doit voir une jambe partir loin DEVANT pendant que l'autre pousse loin
DERRIÈRE, puis l'inverse. Deux appuis complets sur les huit images.

⚠️ CHIFFRE À TENIR : aux images d'APPUI, l'écart entre le talon avant et les
orteils arrière doit valoir au moins LA MOITIÉ DE LA HAUTEUR de la créature. Sur
les planches livrées jusqu'ici il valait un cinquième — c'est trois fois trop peu,
et c'est précisément ce qui fait glisser la bête. Des jambes qui ne font que
frémir donnent une bête qui GLISSE sur le sol au lieu de marcher — c'est le
défaut le plus désagréable à l'œil, et le seul qu'on ne sache pas nommer quand on
le voit.

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
- son souffle est COURT : il reste dans la case, il ne la traverse pas — cette créature frappe au contact
- ses ailes ne doivent jamais sortir de la case, même ouvertes
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
- dans chaque case, la créature est CENTRÉE et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LA CRÉATURE — UN DRAGONNET DE FEU. Un petit dragon rouge sang aux écailles
sombres, avec deux grandes ailes membraneuses rouge vif nervurées de noir, bien
plus larges que son corps. Deux cornes dorées recourbées sur la tête, des yeux
jaunes, une petite gueule pleine de crocs. Une flamme orange brûle sous lui,
entre ses pattes repliées.

⚠️ MÊMES COULEURS ET MÊME TAILLE QUE LA PLANCHE DE MARCHE. Les deux planches
sont jouées l'une après l'autre sur le même monstre : une teinte plus sombre ou
une créature plus grande se verrait comme un clignotement au moment du coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle frappe VERS LE BAS, face au joueur
- rangée 2 : elle frappe VERS LE HAUT, de dos
- rangée 3 : elle frappe VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL COUP qui se déroule, lu de
gauche à droite — ce n'est PAS une boucle :
1. il replie ses ailes et gonfle la gorge, qui s'éclaire d'orange
2. il rejette la tête en arrière, la lueur monte dans son cou
3. les ailes s'ouvrent en grand, la gueule s'entrouvre
4. il projette la tête en avant et lâche son souffle
5. le souffle est à son plus fort : un jet de flammes court et large
6. le jet s'éteint, quelques braises restent en l'air
7. il referme la gueule, les ailes reviennent
8. il retrouve son vol, prêt à recommencer

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

⚠️ RÈGLE BLOQUANTE — LES JAMBES DOIVENT FAIRE DE VRAIS PAS. Le corps reste en
place, mais les JAMBES, elles, doivent travailler franchement : sur la rangée de
profil, on doit voir une jambe partir loin DEVANT pendant que l'autre pousse loin
DERRIÈRE, puis l'inverse. Deux appuis complets sur les huit images.

⚠️ CHIFFRE À TENIR : aux images d'APPUI, l'écart entre le talon avant et les
orteils arrière doit valoir au moins LA MOITIÉ DE LA HAUTEUR de la créature. Sur
les planches livrées jusqu'ici il valait un cinquième — c'est trois fois trop peu,
et c'est précisément ce qui fait glisser la bête. Des jambes qui ne font que
frémir donnent une bête qui GLISSE sur le sol au lieu de marcher — c'est le
défaut le plus désagréable à l'œil, et le seul qu'on ne sache pas nommer quand on
le voit.

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
- son souffle est COURT : il reste dans la case, il ne la traverse pas — cette créature frappe au contact
- ses ailes ne doivent jamais sortir de la case, même ouvertes
- rien ne QUITTE la case : cette créature frappe au contact, elle ne tire pas
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le profil regarde à gauche | **défaut bloquant** : le monstre marchera à reculons. Rappeler « tourné vers la DROITE » et nommer l'indice — l'œil, la gueule, la traînée devant |
| Une case ne montre que l'effet, sans la créature | **défaut bloquant** : elle disparaîtrait en plein coup. `build_enemies.py` mesure la matière du haut de case et nomme les fautives |
| Le profil change de côté d'une case à l'autre | **défaut bloquant**, et le plus sournois : vu de loin la planche semble juste. La créature se retournerait la tête quatre fois par cycle. `build_enemies.py` le mesure et nomme les cases fautives |
| Une ombre portée est dessinée sur le fond | **défaut bloquant** : elle survit à l'effacement du magenta et laisse une salissure grise sous la bête |
| La créature glisse au lieu de marcher | **défaut bloquant** : ses jambes ne bougent pas assez. Redemander « une jambe loin devant, l'autre loin derrière, deux appuis sur les huit images ». `build_enemies.py` mesure la course du pied avant |
| La créature dérive dans son cadre d'une case à l'autre | **défaut bloquant**, et le plus fréquent : elle patinerait d'avant en arrière au lieu de marcher. Redemander en insistant sur « le tronc se superpose d'une image à l'autre, seuls les membres bougent ». `build_enemies.py` mesure la dérive en pixels |
| La créature change de taille d'une case à l'autre | **défaut bloquant** : elle sauterait à l'écran à chaque image |
| Le bas de la créature bouge d'une case à l'autre | **défaut bloquant** : elle s'enfoncerait dans le sol en marchant |
| Les deux planches n'ont pas les mêmes couleurs | rappeler « mêmes couleurs, même taille » — sinon clignotement au moment du coup |
| Le cycle de marche ne boucle pas | moins grave — huit images passent vite. À corriger si on le voit sauter |
| La dernière image d'attaque reste en garde | rappeler « elle rejoint la pose de marche » |

---

## Ce que je fais quand elles arrivent

1. **découpe** : `tools/.venv/bin/python tools/build_enemies.py dragonnet` —
   l'outil est écrit et il attend les planches. Il détoure le magenta y compris
   enclavé, mesure les 48 cases ENSEMBLE pour une case commune, cale sur les
   pieds, et fabrique la gauche en retournant le profil droit ;
2. **import** : `godot --headless --path . --import`, obligatoire pour tout
   nouveau PNG ;
3. **contrôle** : `tools/.venv/bin/python tools/check_profiles.py` — la planche
   de contact qui vérifie que tous les profils gauches regardent bien à gauche.
   C'est l'outil né du défaut des sept créatures ;
4. **capture en jeu**, la créature collée au mage, pour voir le coup se dérouler.

Sortie : `assets/enemies/dragonnet/` — quatre bandes de 17 poses (`idle`,
huit pas, huit coups) et leur descripteur.

---

*Fiche produite par `tools/build_prompts_enemies.py`. Les onze fiches partagent
leur format : corriger une règle se fait dans l'outil, pour tout le bestiaire à
la fois.*
