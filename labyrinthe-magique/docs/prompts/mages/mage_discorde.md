# La Démone de la Discorde — fiche et modèle du personnage

> Élément **Envoûtement** · teinte du jeu `#e8308f` · vert sapin, noir et argent sur elle, magenta dans ses sorts. Onglet **Démon**.
> Une humaine noble, marionnettiste : elle ne se bat presque pas, elle retourne les ennemis les uns contre les autres.

**Elle est jouable.** Les cinq images sont livrées ; pour en regénérer une, garder cet ordre : la première sert de modèle aux autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/discorde.png` | `refonte/chrono.png` |
| 2 | La marche | [mages_animes/discorde](../mages_animes/discorde.md), prompt 1 | `mages/discorde_marche.png` | `refonte/discorde.png` et `guide_marche.png` |
| 3 | L'attaque | [mages_animes/discorde](../mages_animes/discorde.md), prompt 2 | `mages/discorde_attaque.png` | `refonte/discorde.png` |
| 4 | Les six icônes | [sorts/icones_discorde](../sorts/icones_discorde.md) | `sorts/mage_discorde_skills.png` | aucune |
| 5 | Le portrait du menu | [menu/portrait_discorde](../menu/portrait_discorde.md) | `interface/portraits/portrait_discorde.png` | `ref_carte.png`, `portrait_fire.png` et `refonte/discorde.png` |

## Identité visuelle

Son pouvoir se voit dans ses fils et ses sorts, pas dans son corps : pas de cornes, de queue ni d'ailes,
comme le Démon du Pacte.

⚠️ **Aucun rose, aucun violet sur elle ni sur ses icônes, alors que son élément est magenta.** Le fond des
planches est magenta, et le détourage retire cette couleur :

| couleur | après `demagenta` (personnage) |
|---|---|
| rose `#e8308f` | `(137, 48, 48)`, un rouge terne |
| prune `#3a1a40` | `(26, 26, 32)`, un gris sombre |
| vert sapin `#12463a` | inchangé |
| argent `#c9d2d6` | inchangé |

Le magenta n'existe donc que dans les effets, peints au shader par le jeu. Le vert sapin a un second avantage :
c'est la couleur opposée, donc ses sorts ressortiront sur elle.

## L'idée

Elle est forte quand les ennemis sont nombreux, et faible en duel : un ennemi seul n'a personne à
attaquer. Il faut donc se placer, et parfois laisser vivre un ennemi pour qu'il serve aux autres.

Le Démon du Pacte paie de sa vie pour frapper fort. Elle reste loin et ne paie rien, mais elle dépend
de ce que font les autres.

## Ses six sorts

Passe rapide seulement (4 parties, un niveau sur 4) : 0 % de morts sur quatre niveaux, 25 % sur le Sanctuaire Déchu.

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 3 PV, vitesse 5,5, extra à 4 kills | |
| ATTAQUE | **Murmure** | un fil qui vise. Au bout de 3 touches, la cible est **troublée** : plus lente, et possédée plus longtemps | 14 dégâts, portée 7, 0,5 s |
| SKILL 1 | **Mauvais Œil** | possède un ennemi : il attaque ses voisins, ceux-ci ripostent, et il ne chasse plus l'héroïne | portée 8, 5 s (7 si troublée), 20 par coup, recharge 10 s |
| SKILL 2 | **Cercle de Discorde** | une zone où chaque ennemi prend plus de dégâts si d'autres ennemis sont avec lui | 16 dégâts/s, +50 % par ennemi en plus, rayon 2,5, 6 s, recharge 12 s |
| SKILL 3 | **Lien de Souffrance** | enchaîne 3 ennemis proches : une part des dégâts reçus par l'un passe aux deux autres | portée 8, 50 %, 8 s, recharge 14 s |
| FUITE | **Échange** | elle échange sa place avec l'ennemi le plus proche | portée 6, recharge 9 s |
| EXTRA | **Grande Discorde** | tous les ennemis à l'écran se battent entre eux et ne la chassent plus. Leurs morts comptent pour elle | 6 s, 22 par coup |

**Les boss** ne peuvent être ni possédés ni échangés. Le Cercle et le Lien les touchent quand même.

## Ce qui est programmé

Tout est en jeu, dans `CombatSystem` (section Démone) : la simulation d'équilibrage voit donc les mêmes règles.

- **La possession** repose sur l'aveuglement : l'ennemi ne chasse plus et ne peut plus frapper. Tous les possédés
  marchent vers un seul foyer, pour qu'un seul champ de distances suffise, même sous la Grande Discorde.
- **La mêlée :** un possédé frappe un voisin au contact toutes les `POSSESS_GAP` secondes, et le voisin riposte
  s'il n'est pas possédé lui-même. Les morts comptent pour elle.
- **Le Lien** ne se relance jamais lui-même : sinon trois enchaînés se renverraient le même coup à l'infini.
- **Les fils** sont tracés par `src/fx/discord_threads.gd`, car ils suivent des corps qui bougent. Les autres effets
  sont au shader : `tools/preview_discorde.gd` les montre, et `--crowd` regroupe les ennemis pour les voir en partie.

## Les effets visuels, sort par sort

Ils seront peints au shader, et les planches n'en montrent que le geste.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le pâle | `#ffe3f1` | cœur des fils, éclairs, instant de l'emprise |
| L'argent | `#c9d2d6` | fils, chaînes fines, anneaux : les bagues de ses doigts |
| Le magenta | `#e8308f` | matière principale : yeux, sceaux, lueur des fils |
| Le sombre | `#6a0f4a` | creux, dégradé vers le bord |
| Le noir | `#161a1c` | cerne, qui tient sur les sols clairs |

Mêmes règles que le Démon du Pacte : un dessin **net, à plages franches**, un effet qui **se réduit au lieu de
s'estomper**, et **ce qui est grand reste sous elle ou creux au centre**.

### Murmure (attaque)

- **Vol :** un fil d'argent ondule de ses doigts jusqu'à la cible, avec une perle magenta à sa pointe.
- **Impact :** le fil s'enroule autour de la cible et se serre, puis une petite boucle pâle se rompt.
- **Troublée :** trois petits fils tournent au-dessus de sa tête, et un de plus à chaque touche.

### Mauvais Œil, 5 à 7 s

- **L'ouverture, 0,16 s :** l'œil claque, dépasse sa taille et se rattrape, dans un éclair à quatre branches et un anneau.
- **L'emprise :** son regard saute d'un point à l'autre, sa pupille se serre à chaque saut, l'iris tourne et bat, et des
  cils d'argent le hérissent. Quatre fils lumineux tirent sur le possédé, parcourus de perles, et trois éclats tournent.
- **La fin :** il tremble pendant une demi-seconde, puis se ferme d'un coup.

### Cercle de Discorde

- **Le tracé :** un anneau d'argent se dessine d'un trait, avec un filet magenta en sens inverse.
- **Les liens :** un fil relie entre eux tous les ennemis présents. Plus ils sont nombreux, plus la toile se
  serre et bat vite : on voit d'un coup d'œil si le cercle est bien placé.
- **La fin :** les fils claquent, et l'anneau se rompt en arcs.

### Lien de Souffrance, 8 s

- **Le jet :** une chaîne fine part d'une cible vers la suivante, maillon par maillon.
- **Le transfert :** à chaque coup, une onde magenta court le long de la chaîne jusqu'aux deux autres, qui
  sursautent.
- **La fin :** les maillons se détachent un à un, et tombent.

### Échange

- **Le fil :** un fil tendu relie les deux corps, et frémit une fraction de seconde.
- **Le retournement :** chacun se réduit à une carte de lumière pâle qui se retourne sur place.
- **L'arrivée :** deux anneaux d'argent s'écartent, et des éclats tombent.

### Grande Discorde (extra), 1,05 s puis 6 s

Un œil plein et menaçant, qui flotte à 3 cases au-dessus d'elle pour ne pas la cacher.

- **La déchirure :** une fente de lumière s'ouvre dans l'air, de son centre vers ses bords.
- **L'ouverture :** l'œil s'ouvre d'un coup et dépasse sa taille, dans un éclair, et une ombre tombe sous lui.
- **Le regard :** blanc noir et veiné, iris en feu qui tourne, pupille qui se serre brutalement, paupières d'argent
  épaisses, longs cils en pointes, fils lestés qui descendent, et aiguilles en étoile.
- **Les fils :** un fil part de l'œil vers chaque ennemi à l'écran en 0,32 s, avec une perle à sa pointe.
- **La fin :** il se ferme d'un coup en une seule ligne. Chaque ennemi garde ensuite son petit œil et ses fils pendant 6 s.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, pour le style, la mise en page et surtout les proportions.
À déposer dans `assets/peso&cover/refonte/discorde.png`.

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

LE PERSONNAGE — la Démone de la Discorde, une femme ADULTE, HUMAINE et noble, à l'allure
d'une marionnettiste. Peau claire, cheveux noirs relevés en un chignon haut et serré, retenu
par une épingle d'argent, yeux vert jade et petit sourire calme et entendu. Longue redingote
vert sapin très sombre (#12463a), sobre et couvrante, boutonnée jusqu'à un col haut, brodée
de motifs de fils entrelacés en argent. Ses pans s'ouvrent à partir de la taille et s'arrêtent
à mi-cuisse, sur un pantalon noir ajusté et des bottes noires à boucles d'argent. Gants noirs,
avec une fine bague d'argent à chaque doigt. Ses mains sont vides : aucune arme, aucun objet.
Toutes ses formes sombres sont cernées d'un fin liseré ARGENTÉ, qui les détache des sols sombres.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (coiffure comprise) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de
longues jambes ou de petite tête : posée à côté du personnage de l'image jointe, elle a la
même morphologie.

⚠️ RÈGLE BLOQUANTE — ELLE EST HUMAINE. Aucune corne, queue, croc, aile, auréole, peau colorée
ou transformation démoniaque. Tenue digne et couvrante, sans décolleté.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes sont séparées l'une
de l'autre, et les pans de la redingote ne les cachent jamais.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur elle, ni reflet du fond. Sa
palette est le vert sapin, le noir, l'argent et sa peau claire.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE sur cette image : aucun fil, aucune lueur, aucune particule.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Elle ne ressemblerait pas aux mages : à regénérer sans attendre |
| Du rose ou du violet sur la tenue ou le visage | Le détourage le rendrait terne ou gris |
| Les pans cachent les jambes | Elle glisserait en marchant : le défaut déjà vu sur les anges |
| Le vert paraît noir | Elle perdrait son identité, et se confondrait avec le Démon du Pacte |
| Des attributs de démon | Elle doit rester humaine, comme le Démon du Pacte |
