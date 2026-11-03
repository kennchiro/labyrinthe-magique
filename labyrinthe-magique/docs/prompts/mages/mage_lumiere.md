# Le Porte-Lumière — images à générer et effets visuels

> Élément **Lumière** · teinte du jeu `#fff1b8` · blanc chaud et or, contour brun foncé.
> Sa lumière aveugle : les ennemis perdent sa trace.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | prompt | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|---|
| 1 | le modèle du personnage | ci-dessous | `refonte/lumiere.png` | `refonte/chrono.png` |
| 2 | la marche | [mages_animes/lumiere](../mages_animes/lumiere.md), prompt 1 | `mages/lumiere_marche.png` | `refonte/lumiere.png` et `guide_marche.png` |
| 3 | l'attaque | [mages_animes/lumiere](../mages_animes/lumiere.md), prompt 2 | `mages/lumiere_attaque.png` | `refonte/lumiere.png` |
| 4 | les six icônes de sorts | [sorts/icones_lumiere](../sorts/icones_lumiere.md) | `sorts/mage_lumiere_skills.png` | aucune |
| 5 | le portrait du menu | [menu/portrait_lumiere](../menu/portrait_lumiere.md) | `interface/portraits/portrait_lumiere.png` | `ref_carte.png` et `refonte/lumiere.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches. **Les ailes sont le premier point à regarder.**

**Aucune image à demander pour les effets de ses sorts** : ils seront peints au shader,
comme ceux des autres mages. La dernière partie de cette page les décrit en détail.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, pour le style, la mise en page et surtout LES PROPORTIONS.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile. L'image jointe sert UNIQUEMENT de référence de style, de proportions et de
mise en page : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vu DE FACE, immobile : le visage se voit bien, le haut des ailes dépasse derrière les épaules
2. vu DE DOS, immobile : les deux ailes à demi repliées se voient en entier
3. vu DE PROFIL, TOURNÉ VERS LA DROITE, immobile : une seule aile se voit, derrière son dos

LE PERSONNAGE — le Porte-Lumière, un ange. Deux GRANDES AILES de plumes blanches, à demi
repliées dans son dos. Une AURÉOLE d'or plate flotte au-dessus de sa tête. Courts cheveux
blonds, visage serein bien visible, armure légère blanc ivoire à liserés d'or sur une tunique
blanche, bottes d'or. Il tient de la main droite une LANCE dorée, surmontée d'une pointe de
cristal blanc lumineux. Corps CHIBI, très grosse tête, silhouette lisible en très petit.
L'aura reste COLLÉE au corps : pas de halo large, pas de rayons, pas de particules autour.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES. Jamais déployées. Elles ne dépassent
pas de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au
niveau des genoux. Le personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR BRUN FONCÉ NET autour de toutes les formes blanches, plumes
comprises : il doit rester lisible sur un sol très clair.

⚠️ RÈGLE BLOQUANTE — LES COULEURS. Les ombres du blanc sont BEIGE et BRUN CLAIR, jamais roses
ni violettes : aucun reflet du fond magenta sur les plumes. L'or reste un détail : le blanc
domine, sans jaune sur tout le corps.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même auréole, même lance, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur totale
vaut 2,5 TÊTES : la tête (coiffure ou casque compris) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de longues
jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même morphologie.


⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : c'est la raison de cette refonte, à regénérer sans attendre |
| Les ailes sont déployées ou très larges | Il deviendrait bien plus large que les autres mages, et ses ailes passeraient sur les murs |
| Des ombres roses dans les plumes | Le détourage y ferait des trous |
| Pas de contour sombre | Il disparaîtrait sur les stages clairs |
| Le corps vire au jaune | Il ressemblerait au Sorcier Suprême ou au Mage de la Foudre |
| Le blanc tire vers le bleu | Il ressemblerait au Mage de l'Air |

---

## Les effets visuels, sort par sort

Ce sont les consignes des shaders que j'écrirai quand le mage sera branché. Les durées et
les tailles sont des cibles : l'équilibrage et ton essai en jeu peuvent les changer.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le cœur | `#ffffff` | centre des rayons, instant de l'impact |
| La lumière | `#fff1b8` | matière principale |
| L'or | `#ffcf5a` | bords, plumes de lumière, graduations |
| L'or sombre | `#c98a2b` | creux et dégradé vers le bord |
| Le cerne | `#4a2f12` | contour qui tient sur les sols clairs |

Trois règles pour tous : le dessin est **net, à plages franches**, comme les autres effets
peints. Tout effet posé au sol est **cerné**, sinon il disparaît sur les stages clairs. Et rien
ne se compose en additif, qui délaverait la lumière sur ces mêmes stages. Seule l'Aube a le
droit d'éblouir tout l'écran, et seulement un instant.

### Trait d'aube (attaque)

- **Vol :** un trait effilé de lumière, long d'environ une case et demie, à cœur blanc et bords
  or. Quelques plumes minuscules s'en détachent.
- **Impact, 0,3 s :** une étoile à quatre pointes fines et une petite croix claire, qui se
  referment très vite.

### Un ennemi aveuglé

C'est l'effet le plus important : on doit voir d'un coup d'œil qu'il a perdu ta trace.

- **Marque :** trois petites étoiles d'or tournent au-dessus de sa tête.
- **Corps :** il pâlit et passe au blanc chaud, et un éclair blanc marque le début de l'effet.
- **Attitude :** il s'arrête ou erre : c'est sa perte de trace qui se lit, pas sa teinte.
- **Fin :** les étoiles s'éteignent une à une, juste avant qu'il reprenne la poursuite.

### Lance solaire, 0,5 s

- **Temps 1, 0,1 s :** un trait très fin part du mage et file le long du couloir, jusqu'au mur.
- **Temps 2, 0,25 s :** le rayon s'épaissit d'un coup, cœur blanc et bords or, cerné de brun, et
  suit les cases du couloir droit. Il s'arrête net au mur, avec une gerbe d'étincelles.
- **Temps 3, 0,15 s :** il s'amincit depuis le mage jusqu'au mur, et disparaît.
- **Ennemis touchés :** une étoile sur chacun, l'une après l'autre le long du rayon.

### Sanctuaire

- **Ouverture, 0,3 s :** un cercle d'or gravé se trace à la vitesse d'un compas, avec des plumes
  stylisées comme motif sur son pourtour.
- **Vie :** l'intérieur reste un voile translucide de lumière, et le motif tourne lentement. De
  petits filets de lumière montent du sol.
- **Quand un ennemi entre :** un éclat au point d'entrée, sa marque d'aveuglement et une
  petite flamme blanche à ses pieds.
- **Fin :** le motif clignote, puis le cercle se referme depuis l'extérieur.

### Ailes gardiennes

- **Fermeture, 0,25 s :** deux grandes ailes de lumière se referment devant lui en le laissant
  voir, comme un cocon translucide à plumes bien dessinées.
- **Tant qu'elles tiennent :** elles respirent lentement, et une plume s'en détache de temps en
  temps.
- **Quand un coup est absorbé :** elles s'ouvrent d'un coup en éclat de plumes, et l'attaquant
  reçoit un éclair blanc et sa marque d'aveuglement.
- **Sans coup reçu :** elles se rouvrent doucement et se dissipent.

### Envol

- **Départ, 0,2 s :** ses ailes s'ouvrent, et une colonne de plumes monte de sa case.
- **Trajet :** un trait de lumière en arc relie le départ à l'arrivée, par-dessus les haies, avec
  des plumes qui retombent le long de ce trait.
- **Arrivée, 0,3 s :** un anneau d'or s'élargit au sol et un éclair aveugle les ennemis tout
  proches.

### L'Aube (ultime)

- **Temps 1, 0,4 s :** il lève sa lance, ses ailes s'ouvrent, et une petite étoile blanche grossit
  à la pointe. Le décor s'assombrit légèrement autour de lui.
- **Temps 2, 0,25 s :** l'étoile éclate. **Tout l'écran s'embrase de blanc**, puis ce voile se
  retire du centre vers les bords en laissant une lueur dorée.
- **Temps 3, 1,5 s :** une colonne de lumière tombe sur **chaque ennemi de la carte**, l'une après
  l'autre, très vite. Son pied ouvre un anneau d'or au sol et l'ennemi prend ses trois étoiles.
- **Temps 4 :** des plumes de lumière retombent doucement autour du mage et s'effacent.

---

## Quand les images sont là

Il suffit de les déposer et de me le dire : je les découpe, je contrôle chaque planche et je
programme le mage et ses effets.
