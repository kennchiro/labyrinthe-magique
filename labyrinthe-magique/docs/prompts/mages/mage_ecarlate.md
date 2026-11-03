# Le Chevalier Écarlate — fiche et modèle du personnage

> Élément **Lame** · teinte du jeu `#fff6ee` · laque rouge sang et plaques noires, flamme blanche. Onglet **Démon**.
> Un bretteur humain aux longs cheveux blancs. Ses coups ne tuent pas tout de suite : ils éclatent quand il rengaine.

**Il est jouable, sans son portrait** (image 5 attendue). Pour regénérer une image, garder cet ordre : la première sert de modèle aux autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/ecarlate.png` | `refonte/chrono.png` |
| 2 | La marche | [mages_animes/ecarlate](../mages_animes/ecarlate.md), prompt 1 | `mages/ecarlate_marche.png` | `refonte/ecarlate.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/ecarlate](../mages_animes/ecarlate.md), prompt 2 | `mages/ecarlate_attaque.png` | `refonte/ecarlate.png` |
| 4 | Les six icônes | [sorts/icones_ecarlate](../sorts/icones_ecarlate.md) | `sorts/mage_ecarlate_skills.png` | aucune |
| 5 | Le portrait du menu | [menu/portrait_ecarlate](../menu/portrait_ecarlate.md) | `interface/portraits/portrait_ecarlate.png` | `ref_carte.png`, `portrait_fire.png` et `refonte/ecarlate.png` |

## Identité visuelle

Sa laque est un rouge SANS BLEU (`#b81414`) : avec un peu de bleu, `#b3121f` perdait 13 points de rouge à `demagenta`
(mesuré). Noir `#17171a`, cheveux `#f4f1ec` et lame `#d9dee3` restent inchangés. Il porte le seul sabre des démons.

⚠️ Le rouge rappelle le Démon du Pacte : ses cheveux blancs et sa laque unie doivent l'en distinguer d'un coup d'œil.
Sa teinte blanche est proche de la Lumière (`#fff1b8`) : ses effets gardent toujours un cerne noir et un filet rouge.

## Ce qui est programmé

Tout est dans `CombatSystem` (section Chevalier Écarlate), et `tools/preview_ecarlate.gd` montre ses effets.

- **Les entailles** (`_cuts`, `Ability.cuts`) sont posées par `_apply_damage`, et `Enemy.set_cuts` les dessine sur le corps.
- **La Garde** réutilise l'immunité et la coupe au premier coup reçu. **La Rengaine** attend `SHEATHE_SILENCE`.
- **La Dernière Rengaine** passe l'écran en noir et blanc : `ecarlate_nuit` lit l'écran sur une seconde, sur un
  `CanvasLayer` posé à la racine de la fenêtre. C'est le seul effet du jeu qui lit l'écran.

## L'idée

Ses coups laissent des **entailles** sur les ennemis, qui ne font rien tant qu'il n'a pas rengainé. Il faut donc en
poser beaucoup, puis choisir l'instant. Le Démon du Pacte paie de sa vie pour frapper fort, le Roi de Braise place
ses pièces, et lui prépare un seul geste.

**Le coup à placer :** traverser une file d'ennemis dans un couloir, parer celui qui riposte, puis rengainer.

## Les entailles

- Chaque ennemi en porte **5 au plus**, et elles durent **8 s** depuis la dernière reçue.
- Elles ne font aucun dégât seules. **La Rengaine** les fait éclater et les consomme.
- Elles se voient sur l'ennemi : un petit trait blanc par entaille.

## Ses six sorts

Passe rapide seulement (4 parties, un niveau sur 4) : le bot expert ne meurt pas sur quatre niveaux, et meurt 25 % du temps sur le Sanctuaire Déchu.

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 4 PV, vitesse 5,2, extra à 5 kills | |
| ATTAQUE | **Entaille** | une coupe de loin qui vise, et laisse 1 entaille | 15 dégâts, portée 5, 0,5 s |
| SKILL 1 | **Pas de Lame** | il file droit dans le couloir et coupe tout ce qu'il traverse : 1 entaille chacun | 5 cases, 20 dégâts, recharge 8 s |
| SKILL 2 | **Garde** | le premier coup reçu est annulé, et il riposte autour de lui avec 2 entailles | 1,5 s, 30 dégâts, rayon 2, recharge 10 s |
| SKILL 3 | **Rengaine** | il rengaine : toutes les entailles à portée éclatent. Refusée et gratuite s'il n'y en a aucune | portée 8, 18 par entaille, recharge 9 s |
| FUITE | **Volte-face** | il saute en arrière dans une pluie de pétales | 5 cases, recharge 9 s |
| EXTRA | **Dernière Rengaine** | l'écran passe en noir et blanc, chaque ennemi visible reçoit 5 entailles, puis tout éclate | 1 s, puis 18 par entaille |

**Les boss** reçoivent les entailles et les dégâts comme les autres.

## Les effets visuels, sort par sort

Tout sera peint au shader, et les planches n'en montrent que le geste.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le blanc | `#fff6ee` | matière principale : coupes, flamme, pétales |
| L'acier | `#d9dee3` | reflet de la lame |
| L'écarlate | `#b81414` | filet qui borde chaque coupe |
| Le sombre | `#5e0a0a` | creux, dégradé vers le bord |
| Le noir | `#17171a` | cerne, qui tient sur les sols clairs |

Un dessin **net, à plages franches**, un effet qui **se réduit au lieu de s'estomper**, et **ce qui est grand reste
sous lui ou creux au centre**.

### Entaille (attaque)

- **Le trait :** un croissant blanc, très fin et bordé de rouge, part de sa lame vers la cible.
- **L'impact :** une ligne nette barre l'ennemi, avec quelques pétales.
- **La marque :** un trait reste sur lui, puis un autre à chaque coup, et ils frémissent à 5.

### Pas de Lame

- **Le départ :** il disparaît dans un trait blanc qui suit le couloir.
- **La coupe :** chaque ennemi traversé reçoit sa ligne, avec un décalage très bref.
- **L'arrivée :** le trait se referme derrière lui, du départ vers l'arrivée.

### Garde, 1,5 s

- **La posture :** un fin cercle blanc se dessine autour de lui, et se réduit pendant les 1,5 s.
- **La parade :** un éclat à quatre branches sur la lame, et l'image s'arrête un court instant.
- **La riposte :** un cercle de coupe part de lui, net, puis se brise en arcs.

### Rengaine

- **Le geste :** la lame rentre lentement dans son fourreau, et les entailles à portée s'allument.
- **Le silence :** un quart de seconde, sans rien d'autre qu'un petit claquement.
- **L'éclat :** les entailles s'ouvrent toutes à la fois, plus larges selon leur nombre, dans une gerbe de pétales.

### Volte-face

- **Le départ :** une gerbe de pétales blancs reste à sa place.
- **L'arrivée :** il retombe en glissant, et les pétales le rattrapent, puis disparaissent.

### Dernière Rengaine (extra), 1 s

- **Le noir et blanc :** l'image perd ses couleurs d'un coup, sauf lui et ses coupes.
- **Les coupes :** de grands traits traversent l'écran, très vite, et chaque ennemi se couvre de ses 5 lignes.
- **Le claquement :** il rengaine, et une seconde de suspens se termine sur un seul son sec.
- **L'éclat :** les couleurs reviennent d'un coup, et tous les ennemis visibles éclatent ensemble.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, pour le style, la mise en page et surtout les proportions.
À déposer dans `assets/peso&cover/refonte/ecarlate.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt
est public.

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

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — le Chevalier Écarlate, un homme ADULTE et HUMAIN, un bretteur élégant et froid.
Visage découvert, peau claire, longs cheveux blancs (#f4f1ec) attachés en une queue basse qui
s'arrête au milieu du dos, yeux gris pâle, expression calme. Pas de casque. Armure gothique de
style samouraï, à fines plaques de laque unie rouge sang (#b81414), brillantes, aux bords noirs
(#17171a) : épaulières en lamelles, plastron étroit, brassards et jambières. Dessous, une tenue
noire ajustée, et de hauts solerets noirs. Sur sa hanche gauche, un long sabre fin dans un
fourreau noir, porté incliné vers l'arrière, à la poignée blanche. Ses mains sont vides. Toutes
ses formes sombres sont cernées d'un fin liseré rouge, qui les détache des sols sombres.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (cheveux compris) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de
longues jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même
morphologie.

⚠️ RÈGLE BLOQUANTE — IL EST HUMAIN. Aucune corne, queue, croc, griffe, aile, auréole, peau colorée
ou transformation démoniaque.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes sont séparées l'une
de l'autre : aucune jupe de plaques, cape ou pan de tissu ne les cache, et le fourreau passe
derrière elles sans les couper.

⚠️ RÈGLE BLOQUANTE — LE ROUGE EST FRANC, SANS AUCUN BLEU : jamais de bordeaux, de rose ni de
framboise. AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Ses cheveux restent blancs et neutres.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE sur cette image : ni flamme, ni lueur, ni pétale, ni particule.

⚠️ RÈGLE BLOQUANTE — MÊME visage, armure, sabre, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : à regénérer sans attendre |
| Le rouge tire vers le bordeaux ou le rose | Le détourage le ternirait, et il rappellerait le Démon du Pacte |
| Une jupe de plaques cache les jambes | Il glisserait en marchant : le défaut déjà vu sur les anges |
| Le sabre est trop long ou sort de la case | Il serait coupé à la découpe |
| Les cheveux recouvrent les jambes | Il perdrait sa silhouette de profil |
