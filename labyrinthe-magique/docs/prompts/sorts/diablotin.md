# Diablotin — planches de marche et d'attaque

## Pourquoi celui-ci

Le sort s'appelle Diablotins et invoque deux chevaliers en armure, sans vrai
pas : leurs jambes bougent à peine, ils glissent, et ils ressemblent au
Chevalier Noir qu'on combat. Il faut un petit serviteur qui trottine, qu'on ne
prenne pour aucun ennemi.

    aujourd'hui   un chevalier · 4 images sans vrai pas
    demain        un diablotin · 8 pas · 8 poses de coup

⚠️ **Le moteur sait déjà les jouer.** Il lit les poses par leur NOM et non par
leur nombre : une planche à seize poses et une planche à six se jouent par le
même code, et l'attaque se déroule sur la durée exacte de la frappe. Les autres
créatures continuent de tourner sans y toucher. Il ne manque que le dessin.

---

## Deux planches, et pourquoi pas une

    diablotin_marche.png    8 colonnes x 3 rangées   face / dos / profil DROIT
    diablotin_attaque.png   8 colonnes x 3 rangées   face / dos / profil DROIT

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

LA CRÉATURE — UN DIABLOTIN SERVITEUR. Un petit démon trapu, nettement plus
petit qu'un homme, à la peau violet sombre et au ventre lilas clair. Grosse
tête, deux petites cornes dorées recourbées, grandes oreilles pointues, yeux
jaune or, large sourire plein de crocs. Deux bras courts aux griffes dorées,
deux jambes courtes bien visibles. Une longue queue fine terminée en pointe de
flèche. Un pagne violet foncé et, au cou, une petite amulette d'or à orbe
violette. SANS AILES, SANS ARMURE, SANS ARME.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : la créature vue DE FACE, elle avance vers le bas de l'image
- rangée 2 : la créature vue DE DOS, elle s'éloigne vers le haut de l'image
- rangée 3 : la créature vue DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers
  la droite de l'image

LES 8 COLONNES de chaque rangée, lues de gauche à droite, sont un TROT rapide et sautillant, la queue balancée en sens inverse des pas. Ce cycle, et voici ce que chacune doit montrer :
1. APPUI AVANT : jambe droite loin devant, talon qui touche le sol, jambe gauche loin derrière, orteils qui poussent. Les deux pieds sont ÉCARTÉS AU MAXIMUM — plus large que ses épaules
2. la jambe arrière quitte le sol et remonte
3. PASSAGE : les deux jambes se croisent au milieu, presque jointes
4. la jambe gauche part vers l'avant, la droite reste en arrière
5. APPUI AVANT INVERSE : jambe gauche loin devant, talon au sol, jambe droite loin derrière. Écartement maximal, comme à l'image 1 mais jambes échangées
6. la jambe arrière quitte le sol et remonte
7. PASSAGE : les deux jambes se croisent au milieu, presque jointes
8. la jambe droite repart vers l'avant : on revient à l'image 1

La 8e image enchaîne sur la première sans à-coup.

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

LA CRÉATURE — UN DIABLOTIN SERVITEUR. Un petit démon trapu, nettement plus
petit qu'un homme, à la peau violet sombre et au ventre lilas clair. Grosse
tête, deux petites cornes dorées recourbées, grandes oreilles pointues, yeux
jaune or, large sourire plein de crocs. Deux bras courts aux griffes dorées,
deux jambes courtes bien visibles. Une longue queue fine terminée en pointe de
flèche. Un pagne violet foncé et, au cou, une petite amulette d'or à orbe
violette. SANS AILES, SANS ARMURE, SANS ARME.

⚠️ MÊMES COULEURS ET MÊME TAILLE QUE LA PLANCHE DE MARCHE. Les deux planches
sont jouées l'une après l'autre sur le même monstre : une teinte plus sombre ou
une créature plus grande se verrait comme un clignotement au moment du coup.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle frappe VERS LE BAS, face au joueur
- rangée 2 : elle frappe VERS LE HAUT, de dos
- rangée 3 : elle frappe VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL COUP qui se déroule, lu de
gauche à droite — ce n'est PAS une boucle :
1. il se ramasse sur ses jambes, les griffes reculent, la queue se dresse
2. il se tasse encore, les yeux s'allument, la gueule s'ouvre
3. il bondit vers l'avant, griffes droites levées, sans quitter sa case
4. la griffe droite s'abat, une courte traînée violette part DEVANT lui
5. la griffe est au bout du geste, la traînée est à son plus large
6. la griffe gauche suit, la traînée s'efface
7. il retombe sur ses deux pieds, bras ouverts
8. il se redresse et rejoint la pose de marche

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

Les déposer sous les noms `diablotin_marche.png` et `diablotin_attaque.png` dans
`assets/peso&cover/creatures/`, puis :

1. **découpe** : `tools/.venv/bin/python tools/build_invocateur.py`. Tant que les deux
   planches ne sont pas là, il garde le chevalier ;
2. **import** : `godot --headless --path . --import` ;
3. **contrôle** : `godot --path . --resolution 1200x390 --script
   res://tools/preview_summons.gd -- /tmp/summons.png`, puis une capture en jeu.

Sortie : `assets/allies/imp_{down,up,left,right}.png`. La créature garde son identifiant
`imp` : ni ses chiffres ni ses règles ne changent.

*Fiche produite par `tools/build_prompt_diablotin.py`.*
