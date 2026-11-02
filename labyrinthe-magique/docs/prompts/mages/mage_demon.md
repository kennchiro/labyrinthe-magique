# Le Démon du Pacte — fiche et modèle du personnage

> Élément **Sang** · teinte du jeu `#c8143c` · bordeaux, noir et or vieilli. Onglet **Démon**.
> Un héros humain noble qui canalise un pouvoir démoniaque : moins il lui reste de PV, plus il frappe fort.

**Le modèle est prêt.** Les quatre prompts des images restantes sont rédigés et
liés ici :

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/demon.png` | `refonte/lumiere.png` et `mages/feu_marche.png` |
| 2 | La marche | [mages_animes/demon](../mages_animes/demon.md), prompt 1 | `mages/demon_marche.png` | `refonte/demon.png` et `guide_marche.png` |
| 3 | L'attaque | [mages_animes/demon](../mages_animes/demon.md), prompt 2 | `mages/demon_attaque.png` | `refonte/demon.png` |
| 4 | Les six icônes | [sorts/icones_demon](../sorts/icones_demon.md) | `sorts/mage_demon_skills.png` | aucune |
| 5 | Le portrait du menu | [menu/portrait_demon](../menu/portrait_demon.md) | `interface/portraits/portrait_demon.png` | `ref_carte.png` et `refonte/demon.png` |

## Identité visuelle

Le héros est **humain**, avec un costume noble de fantasy manga : manteau noir
richement brodé, doublure bordeaux, gilet cramoisi et détails or vieilli. Son
pouvoir démoniaque se voit dans la magie de sang et les sceaux de pacte, pas dans
son corps. Pas de cornes, queue, crocs, ailes ni auréole.

| | |
|---|---|
| id | `demon` |
| vie | 4 |
| vitesse | 5,1 |
| extra | à 5 kills (vie + 1, la règle du jeu) |

---

## L'idée

Tous les autres héros veulent garder leurs PV. Lui a une vraie raison de ne pas se soigner : le jeu
tient dans la question « je me soigne, ou je reste à 1 PV pour frapper fort ? ».

Rester à 1 PV doit être un choix tenable, donc il a besoin de frapper **de loin** : aucun sort ne
l'oblige à aller au contact, sauf le Festin, qui est justement le sort du soin.

## Ses six sorts

Les chiffres viennent de l'équilibrage : à ceux de départ, le bot expert mourait jusqu'à 92 % du temps.

| créneau | sort | ce qu'il fait | chiffres |
|---|---|---|---|
| Trait | **Rage** | ses coups gagnent en force selon les PV perdus, jusqu'au maximum à 1 PV | jusqu'à +50 % |
| ATTAQUE | **Griffe de sang** | il lance une griffure de sang, qui vise et ne rate jamais | 18 dégâts, portée 7, 0,5 s |
| SKILL 1 | **Pacte de sang** | il sacrifie 1 PV pour renforcer tous ses coups. Refusé à 1 PV : le pacte ne tue jamais | +8 dégâts, 6 s, recharge 12 s |
| SKILL 2 | **Sillon de soufre** | une gerbe de flammes de sang court dans le couloir et reste plantée | 42 dégâts, portée 7, recharge 7 s |
| SKILL 3 | **Festin** | une gueule de sang se referme autour de lui, et il reprend 1 PV s'il a touché quelqu'un | 26 dégâts, rayon 2, recharge 14 s |
| FUITE | **Bond de soufre** | un saut qui suit les couloirs : il ne traverse pas les haies | 4 cases, recharge 8 s |
| EXTRA | **Dernier Pacte** | une explosion, puis il tombe à 1 PV et devient intouchable. À la fin, il récupère les trois quarts des PV sacrifiés | 60 dégâts, rayon 4, 6 s |

La Rage se calcule sur ses PV **maximum**, pour rester au sommet à 1 PV quel que soit le stage :
`bonus = 50 % x (max - PV) / (max - 1)`. Au stage 1 (4 PV), chaque PV perdu vaut environ +17 %. Au
stage 10 (11 PV), il vaut +5 %. Elle ne compte que sur le coup d'origine, comme l'exaltation : ni sur
les dégâts dérivés, ni sur les repaires.

Le Dernier Pacte est son moment fort, et il a un vrai coût : à 11 PV sur 11, il finit à 9 après être tombé à 1. À 1 PV, il
ne perd rien et ne gagne rien, à part six secondes de répit à pleine puissance.

## Ce qui est programmé

Tout est en jeu : l'élément Sang et la Rage (`rage_bonus`), le coût en PV (`self_cost`,
`Health.sacrifice`), le Festin (`heal_needs_hit`), le Dernier Pacte (`last_pact_seconds`) et l'onglet
Démon. Ses effets sont peints au shader : `tools/preview_demon.gd` les montre tous.

**Ce que les bots mesureront mal.** La Rage joue toute seule, donc `test_balance` la verra. Mais les
bots lanceront le Pacte dès que leurs autres sorts seront en recharge, et le Festin quand il sera prêt,
sans jamais chercher à rester à 1 PV. Le jeu « tout près de la mort » ne se jugera qu'en jouant.

## Les effets visuels, sort par sort

Ils sont peints au shader, et les planches n'en montrent que le geste. Pour les voir tous :
`godot --path . --resolution 1080x1440 --script res://tools/preview_demon.gd -- /tmp/demon.png`.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le pâle | `#ffe9a8` | cœur des coups, éclairs, instant de l'impact |
| L'or | `#d8a93a` | sceaux, graduations, éclats : la broderie de son manteau |
| Le cramoisi | `#c8143c` | matière principale : griffures, flammes, gouttes |
| Le sang sombre | `#6b0a1f` | creux, gencives, dégradé vers le bord |
| Le noir | `#140a0e` | cerne, qui tient sur les sols clairs |

Trois règles pour tous : le dessin est **net, à plages franches**. Un effet **se réduit au lieu de
s'estomper**. Et **ce qui est grand passe sous lui ou reste creux au centre** : le joueur doit toujours voir
son personnage, surtout à 1 PV.

### Griffe de sang (attaque)

- **Vol :** trois griffures parallèles, légèrement courbes, qui s'effilent vers l'arrière. Cœur pâle,
  chair cramoisie, cerne noir. Des gouttes et des éclats d'or traînent derrière.
- **Impact :** l'éclair du contact, puis trois entailles aux bords déchirés qui s'ouvrent l'une après
  l'autre. Le sang jaillit de chaque plaie et retombe, des éclats d'or partent en étoile, et les plaies se
  referment en fils noirs. Trois plaies là où l'Ange de la Mort n'en a qu'une.

### La Rage (trait)

Sans aucun chiffre, un cercle de langues sombres sous ses pieds dit à quel point il frappe fort. Rien à
pleine vie. Il grandit à chaque PV perdu, bat de plus en plus vite et crache de plus en plus de braises. À
1 PV, un filet d'or le borde. Seul son bord est plein, pour ne pas cacher ce qui approche.

### Pacte de sang, 0,95 s

- **Le tracé :** l'anneau d'or se dessine d'un trait, avec ses graduations qui tournent et ses quatre pointes.
- **La goutte :** elle tombe de haut dans le losange du sceau.
- **Le sang court :** une onde cramoisie part de l'impact, et des veines remplissent le losange.
- **La fin :** le sceau se referme sur lui-même, et des éclats d'or s'élèvent.

### Sillon de soufre

Le sol se fend case après case. Des flammes hautes en sortent, noires au bord, cramoisies, à cœur d'or.
Elles ondulent et crachent des braises tant que la zone tient, puis se tassent dans la fente.

### Festin, 0,6 s

- **La gueule :** deux gencives striées, un fond sombre, deux rangées de crocs d'ivoire décalées.
- **Le claquement :** elle se referme d'un coup, les crocs s'emboîtent, et un éclair barre la morsure.
- **Le sang :** une onde part au rayon du sort, le sang jaillit des deux côtés, et le bout des crocs rougit.
- **Le soin :** la gueule se retire vers le haut et le bas, et une goutte file vers lui.

### Bond de soufre

- **Le sol se fend :** un anneau déchiqueté s'ouvre, en plongée.
- **Les flammes montent :** huit langues hautes et ondulantes, qui l'avalent au départ et le rendent à
  l'arrivée.
- **La retombée :** elles se tassent dans le sol, des gouttes retombent et des braises s'élèvent.

### Dernier Pacte (extra), 1,15 s

- **L'appel :** des filets de sang convergent de tout le cercle vers lui.
- **Le sceau :** il se trace au rayon réel du sort : double anneau, graduations, étoile à quatre pointes.
- **La fente :** quatre branches de lumière pâle le fendent depuis le centre, en laissant le héros visible.
- **L'éclatement :** un flash, une secousse de l'écran, une onde, et les éclats noirs du sceau partent vers le
  bord en traînant du sang. L'anneau se rompt en arcs.
- **La pluie :** il ne reste que des gouttes qui tombent et des braises qui montent.

### Le répit du Dernier Pacte, 6 s

Un sceau d'or à quatre pointes tourne autour de lui, gradué, avec un filet intérieur en sens inverse et six
gouttes en orbite. Le centre reste vide. Il clignote juste avant de céder, puis se referme en petit sceau
au moment où les PV reviennent.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/lumiere.png` pour la mise en page, et
`assets/peso&cover/mages/feu_marche.png` pour les proportions compactes et le style des sprites.
À déposer dans `assets/peso&cover/refonte/demon.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt
est public.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
La première image jointe donne la mise en page ; la seconde donne les proportions physiques,
la taille de tête, les membres courts et le style des mages du jeu. Ne copie aucun de leurs
personnages, couleurs ou vêtements.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — un jeune homme HUMAIN noble, peau claire, cheveux sombres coiffés en arrière,
yeux ambrés et expression calme, assurée. Costume de fantasy manga raffiné et très détaillé :
long manteau noir ajusté à col haut, doublure bordeaux brodée, broderies or vieilli, gilet
cramoisi, chemise claire et lavallière avec pierre rouge, boutons ornés, gants noirs, ceinture
décorée, pantalon ajusté et bottes élégantes. Les plis, coutures, tissus et broderies donnent
une tenue riche sans l'alourdir. Un sceau de pacte et de fines marques rouge sombre sur un gant
évoquent son pouvoir. Une petite flamme cramoisie et noire peut entourer une main, près du corps.
Sa morphologie reprend celle des mages du jeu : grosse tête lisible (environ un tiers de sa
hauteur), torse compact, bras et jambes courts, bottes larges. Il n'a pas l'anatomie élancée
d'un adulte réaliste ; la tenue noble est adaptée à ce gabarit de sprite.

⚠️ RÈGLE BLOQUANTE — IL EST HUMAIN. Aucun corne, queue, croc, aile, auréole, peau rouge ou
transformation démoniaque. Le pouvoir est magique ; il ne change pas son apparence.

⚠️ RÈGLE BLOQUANTE — COSTUME NOBLE DÉTAILLÉ. Manteau, doublure brodée, gilet, lavallière,
ornements et bottes sont présents et cohérents dans les trois vues. Pas d'armure complète,
cape flottante ou arme.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.
Palette noire, bordeaux/cramoisie, or vieilli et peau humaine claire. Pas de reflet magenta.
Fond magenta uni, aucun texte, grille, décor, ombre portée ou cadre.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Il a des attributs physiques de démon | Il doit rester un héros humain qui canalise un pouvoir |
| Le manteau et les broderies manquent | Son identité de noble fantasy manga disparaît |
| Le costume devient une armure lourde | Il doit garder une silhouette mobile et lisible |
| La magie prend toute la place | Le personnage et ses détails de costume doivent rester dominants |
