# Le Croupier des Enfers — fiche et modèle du personnage

> Élément **Hasard** · teinte du jeu `#c9a227` · costume bordeaux, noir et or. Onglet **Démon**.
> Un homme élégant, démon joueur. Cartes, dés, pièce et roulette : chaque sort est un pari, et il gagne toujours quelque chose.

**Il est jouable** (`--demo --character croupier`). Les sept images sont livrées ; pour en regénérer une, garder cet
ordre : la première sert de modèle aux autres.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/croupier.png` | `refonte/chrono.png` |
| 2 | La marche | [mages_animes/croupier](../mages_animes/croupier.md), prompt 1 | `mages/croupier_marche.png` | `refonte/croupier.png` et `guide_complet.png` |
| 3 | L'attaque | [mages_animes/croupier](../mages_animes/croupier.md), prompt 2 | `mages/croupier_attaque.png` | `refonte/croupier.png` |
| 4 | Les pièces | [sorts/pieces_croupier](../sorts/pieces_croupier.md) | `sorts/croupier_pieces.png` | `refonte/croupier.png` |
| 5 | La roulette | [sorts/roulette_croupier](../sorts/roulette_croupier.md) | `sorts/croupier_roulette.png` | aucune |
| 6 | Les six icônes | [sorts/icones_croupier](../sorts/icones_croupier.md) | `sorts/mage_croupier_skills.png` | aucune |
| 7 | Le portrait du menu | [menu/portrait_croupier](../menu/portrait_croupier.md) | `interface/portraits/portrait_croupier.png` | `ref_carte.png`, `portrait_fire.png` et `refonte/croupier.png` |

## Identité visuelle

Un homme ADULTE, en proportions **chibi** comme les mages et les autres démons humains (le Roi de Braise, le Chevalier
Écarlate) : c'est un humain, et c'est sa silhouette de joueur élégant qui le distingue, pas sa taille.

Peau pâle, cheveux noirs plaqués en arrière, yeux rouges, sourire en coin. **Deux petites cornes noires** percent ses
cheveux : c'est la seule marque de démon sur son corps. Costume trois-pièces **bordeaux** à revers noirs, gilet noir brodé
d'or, chemise blanche, cravate rouge, **gants blancs**, chaîne de montre en or. Sa veste s'arrête aux hanches : rien ne
cache ses jambes.

- **Aucune carte, aucun dé dans ses mains sur les planches** : le jeu les dessine à part (images 4 et 5).
- **Aucun rose, aucun violet** : son bordeaux est un rouge sombre SANS bleu (`#7a0f14`), loin du magenta du fond.
- ⚠️ Son or ancien (`#c9a227`) reste voisin du Suprême et de la Foudre : c'est le bordeaux du costume et les cartes qui
  le distinguent.

## Ce qui est programmé

Tout est dans `CombatSystem` (section Croupier des Enfers), et chaque tirage passe par `_rng` : la même graine rejoue la
même partie.

- **Le coup de chance** (`_gamble`) : 20 % des coups d'origine font x3, et `lucky_hit` fait jaillir l'or.
- **Les Dés** (`Kind.DICE`) suivent le couloir (`_corridor_ahead`) ; le `Level` affiche leur total en grand.
- **La Carte piège** (`Kind.TRAP_CARD`) : deux au plus au sol, la plus ancienne s'efface. Elle se retourne sous le
  premier ennemi qui entre sur sa case (`Suit` : feu, glace, foudre).
- **Pile ou face** (`Kind.COIN`) : Face passe par l'intouchabilité commune ; Pile double les 3 prochaines cartes.
- **La fuite** est un `BLINK` avec `decoy_seconds` : le leurre du Roi de Braise, que le `Level` dessine en carte.
- **La Roulette** (`Kind.ROULETTE`) tire son `Slot` au lancer, et frappe après `ROULETTE_SPIN`. Le `Level` arrête la
  roue sur la case tirée.

## L'idée

Les autres démons humains ont le pacte de sang, la possession, l'armure et l'épée. Le Croupier joue **le hasard** :
chaque sort tire au sort son résultat. Le tirage se fait dans `CombatSystem`, avec la graine de la partie, pour que
l'équilibrage le mesure comme le reste. Aucun tirage ne le laisse perdant : le pire résultat reste utile.

## Ses six sorts

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 4 PV, vitesse 5,0, extra à 5 kills | |
| TRAIT | **Coup de chance** | environ un coup sur cinq est un coup critique : triple dégâts, éclat d'or | 20 % de chance, x3 |
| ATTAQUE | **Carte tranchante** | une carte file en tournoyant et tranche | 22 dégâts, portée 7, 0,6 s |
| SKILL 1 | **Dés pipés** | deux dés roulent dans le couloir devant lui. Le total des faces (2 à 12) fixe les dégâts ; un double sonne ce qu'ils touchent | 6 cases, 6 dégâts par point, double : sonné 1,5 s, recharge 9 s |
| SKILL 2 | **Carte piège** | une carte face cachée posée au sol ; le premier ennemi qui passe la retourne et elle frappe au hasard : As de feu (brûle), Dame de glace (fige), Roi de foudre (saute à 3 ennemis) | 40 dégâts, 12 s au sol, 2 cartes à la fois, recharge 8 s |
| SKILL 3 | **Pile ou face** | une pièce d'or tourne. Face : intouchable 2 s et +1 PV. Pile : ses 3 prochains coups font double dégâts | recharge 14 s |
| FUITE | **Tour de passe-passe** | il disparaît dans une gerbe de cartes et reparaît plus loin ; une carte reste à sa place et attire les ennemis | 4 cases, leurre 2 s, recharge 11 s |
| EXTRA | **La Roulette infernale** | une roulette géante tourne au-dessus de la carte, la bille tombe. Rouge : tout brûle. Noir : tout est figé. Zéro (1 chance sur 7) : le jackpot, une pluie d'or foudroie tout | rouge 15 dégâts/s 4 s · noir figés 3 s + 30 · zéro 120 |

**Les boss** ne sont pas figés par la Dame de glace ni par le Noir ; ils subissent seulement les dégâts.

## Les effets visuels, sort par sort

Tout sera peint au shader ou dessiné avec les pièces (images 4 et 5). Ce sont des effets de **casino infernal** : de
l'or, des cartes qui volent, des jetons qui sautent, et un éclat de jackpot sur les gros coups.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| L'éclat | `#fff2c4` | cœur des éclats, reflets de l'or |
| L'or | `#e8b54a` | matière principale : pièces, jetons, éclairs du jackpot |
| L'or ancien | `#c9a227` | bord des éclats, roulette |
| Le bordeaux | `#7a0f14` | cartes, tapis, rouge de la roulette |
| Le noir | `#15100f` | cerne, noir de la roulette |

### Coup de chance (le trait)

- **Le critique :** un éclat d'or en étoile sur la cible, des pièces qui jaillissent, et le chiffre des dégâts en or.

### Carte tranchante (attaque)

- **Vol :** une carte qui tournoie à plat, suivie d'un mince filet d'or.
- **Impact :** une entaille dorée en diagonale.

### Dés pipés

- **Le lancer :** deux gros dés filent en roulant dans le couloir, en rebondissant, avec une traînée de poussière d'or.
- **Le résultat :** ils s'arrêtent et leur total s'affiche en grand chiffres d'or au-dessus d'eux. Un double fait un
  éclat plus grand et un bruit de cloche.

### Carte piège

- **La pose :** une carte face cachée tombe au sol en tournant et se plaque.
- **Le retournement :** elle se dresse, se retourne d'un coup et montre sa figure. As de feu : gerbe de flammes. Dame de
  glace : éclat de givre. Roi de foudre : éclairs qui sautent d'un ennemi à l'autre.

### Pile ou face

- **Le lancer :** une grosse pièce d'or monte en tournant au-dessus de sa tête, lentement, avec un court ralenti.
- **Face :** un halo d'or l'entoure. **Pile :** ses gants s'illuminent d'or pour ses trois coups.

### Tour de passe-passe

- **Le départ :** il s'efface dans une gerbe de cartes qui s'envolent en éventail.
- **L'arrivée :** les cartes se rassemblent et il reparaît. Une carte dressée reste à son ancienne place, et brille.

### La Roulette infernale (extra)

- **L'ouverture :** l'écran s'assombrit, un tapis rouge sombre s'étend, et une roulette géante apparaît au-dessus de la
  carte, vue de dessus.
- **La rotation :** elle tourne vite, puis ralentit ; la bille d'or court sur le bord, avec un cliquetis.
- **Le résultat :** la bille tombe dans une case, qui s'illumine. Rouge : une colonne de flammes sur chaque ennemi. Noir :
  chaque ennemi se fige dans le noir. Zéro : JACKPOT, une pluie de pièces d'or et d'éclairs dorés sur tout l'écran.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, pour le style, la mise en page et surtout les proportions.
À déposer dans `assets/peso&cover/refonte/croupier.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt est public.

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

LE PERSONNAGE — le Croupier des Enfers, un homme ADULTE et HUMAIN, élégant et inquiétant,
un démon joueur de casino. Visage découvert, peau pâle, cheveux noirs (#15100f) plaqués en
arrière, yeux rouges (#e0201a), sourire en coin, sûr de lui. Deux PETITES cornes noires
recourbées percent ses cheveux, au-dessus du front. Costume trois-pièces bordeaux (#7a0f14)
à revers noirs : veste ajustée qui S'ARRÊTE AUX HANCHES, gilet noir brodé d'or (#c9a227),
chemise blanche, cravate rouge sombre, chaîne de montre en or sur le gilet. Pantalon
bordeaux, chaussures noires vernies. Gants BLANCS (#f4efe6). Ses mains sont vides. Toutes
ses formes sombres sont cernées d'un fin liseré d'or, qui les détache des sols sombres.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (cornes comprises) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de
longues jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même
morphologie.

⚠️ RÈGLE BLOQUANTE — AUCUNE CARTE, AUCUN DÉ, AUCUNE PIÈCE, AUCUN CHAPEAU, AUCUNE CANNE. Ses
mains gantées sont vides : le jeu dessinera ses cartes à part.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes sont séparées l'une
de l'autre ; aucune queue-de-pie, aucune cape, aucun long manteau ne les cache.

⚠️ RÈGLE BLOQUANTE — LE SEUL SIGNE DE DÉMON, CE SONT LES DEUX PETITES CORNES et les yeux
rouges. Aucune queue, aile, griffe, croc, peau colorée ni aura.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Son
bordeaux tire vers le brun-rouge, jamais vers le rose ou le violet.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE sur cette image : ni lueur, ni particule, ni carte qui flotte.

⚠️ RÈGLE BLOQUANTE — MÊME visage, costume, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : à regénérer sans attendre |
| Une queue-de-pie ou un long manteau cache les jambes | Il glisserait en marchant |
| Il tient des cartes, une canne ou porte un chapeau | Le jeu dessine ses cartes ; un chapeau cacherait les cornes |
| Le bordeaux paraît rose ou violet | Le détourage le griserait |
| Les cornes sont trop grandes | Il deviendrait une bête : ce sont deux petites cornes |
