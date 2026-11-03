# L'Archange d'Acier — images à générer et effets visuels

> Élément **Acier** · teinte du jeu `#a9b6c6` · acier gris-bleu et métal chauffé à l'orange.
> Lent, massif, son marteau lance une onde à 6 cases : ses plaques d'armure encaissent les coups à la place de ses PV.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | prompt | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|---|
| 1 | le modèle du personnage | ci-dessous | `refonte/acier.png` | `refonte/chrono.png` |
| 2 | la marche | [mages_animes/acier](../mages_animes/acier.md), prompt 1 | `mages/acier_marche.png` | `refonte/acier.png` et `guide_marche.png` |
| 3 | l'attaque | [mages_animes/acier](../mages_animes/acier.md), prompt 2 | `mages/acier_attaque.png` | `refonte/acier.png` |
| 4 | les six icônes de sorts | [sorts/icones_acier](../sorts/icones_acier.md) | `sorts/mage_acier_skills.png` | aucune |
| 5 | le portrait du menu | [menu/portrait_acier](../menu/portrait_acier.md) | `interface/portraits/portrait_acier.png` | `ref_carte.png` et `refonte/acier.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches. **Les reflets du métal et la largeur des ailes sont les premiers points à
regarder** : une armure brillante sur un fond magenta attrape facilement des reflets roses.

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
1. vue DE FACE, immobile : le heaume se voit bien, le haut des ailes dépasse derrière les épaules
2. vue DE DOS, immobile : les deux ailes de lames, à demi repliées, se voient en entier
3. vue DE PROFIL, TOURNÉ VERS LA DROITE, immobile : une seule aile se voit, derrière son dos

LE PERSONNAGE — l'Archange d'Acier, un ange guerrier MASSIF et COSTAUD, très large d'épaules,
en ARMURE DE PLATES INTÉGRALE gris-bleu, faite de grandes plaques épaisses bien visibles :
énormes épaulières, plastron bombé, gantelets et grosses bottes de métal. HEAUME FERMÉ : aucun
visage, seulement une fente horizontale d'où sort une lueur orange. De fines fentes orange,
couleur de métal chauffé, courent entre les plaques du plastron. Deux GRANDES AILES faites
entièrement de LAMES D'ACIER superposées, sans aucune plume, à demi repliées dans son dos. Il
porte de la main droite un grand MARTEAU DE GUERRE posé sur l'épaule, à la tête d'acier massive
et au manche épais. Corps CHIBI, très grosse tête, silhouette lisible en très petit. Pas de halo, pas de particules, pas d'étincelles
autour de lui.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES. Jamais déployées. Elles ne dépassent
pas de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au
niveau des genoux. Le personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — SES PIEDS SE VOIENT. Aucune cape, aucune jupe longue : les deux jambes
blindées et les deux bottes de métal se lisent clairement, séparées l'une de l'autre.

⚠️ RÈGLE BLOQUANTE — LE MÉTAL RESTE GRIS-BLEU. Des gris francs, du clair (#dfe6ee) au sombre
(#3a4450), à plages nettes et sans dégradé brillant. AUCUN reflet rose, aucun violet : le métal ne
reflète JAMAIS le fond magenta. Les seules couleurs chaudes sont les fentes orange (#ff8a2a).

⚠️ RÈGLE BLOQUANTE — UN FIN LISERÉ GRIS CLAIR autour des plaques sombres, ailes comprises : il
doit rester lisible sur un sol très sombre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même heaume, même marteau, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur totale
vaut 2,5 TÊTES : la tête (coiffure ou casque compris) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de longues
jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même morphologie.
Il reste le plus LARGE : ses épaules font presque trois fois la largeur de sa tête, sans le grandir.
Son heaume est GROS, comme une tête de mage, et son marteau reste assez court pour tenir dans la case.


⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : c'est la raison de cette refonte, à regénérer sans attendre |
| Des reflets roses sur le métal | Le détourage y ferait des trous, et une frange rose resterait sur l'armure |
| Les ailes sont déployées ou très larges | Il deviendrait bien plus large que les autres, et ses ailes passeraient sur les murs |
| Les ailes ont des plumes | Il perdrait ce qui le distingue des autres anges |
| Un visage apparaît | Le heaume fermé fait toute sa silhouette, et sa lueur orange se voit de loin |
| Il n'a pas l'air massif | C'est tout le personnage : mieux vaut le regénérer maintenant |
| Trop d'orange | Il ressemblerait au Mage du Feu : l'orange reste un fin filet entre les plaques |
| Le marteau dépasse de la case | La tête serait coupée sur toutes les planches suivantes |

---

## Ses six sorts

Ce sont les règles que je propose ; les chiffres seront réglés à l'équilibrage.

| créneau | sort | ce qu'il fait |
|---|---|---|
| Trait | Plaques | 3 plaques d'armure : chaque coup reçu en arrache une avant de toucher ses PV, et ses kills les reforgent |
| ATTAQUE | Coup de marteau | il frappe le sol : une onde de choc court jusqu'à sa cible, à 6 cases, et touche ce qui l'entoure |
| SKILL 1 | Ailes-lames | une volée de lames part en éventail, puis revient vers lui et retouche au retour |
| SKILL 2 | Onde d'enclume | il frappe le sol : l'onde court dans les couloirs et étourdit les ennemis |
| SKILL 3 | Rempart | il se referme dans ses ailes, immobile, et renvoie les dégâts reçus |
| FUITE | Charge | il fonce en ligne droite et renverse ce qu'il croise |
| EXTRA | Acier en fusion | son armure chauffe au rouge : plaques pleines, taille plus grande, et ses coups projettent les ennemis |

Il est lent, mais il encaisse et frappe de loin : ses plaques lui laissent le temps de se placer.

---

## Les effets visuels, sort par sort

Ce sont les consignes des shaders que j'écrirai quand il sera branché. Les durées et les tailles
sont des cibles : l'équilibrage et ton essai en jeu peuvent les changer.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le métal blanc | `#fff4e0` | instant de l'impact, cœur du métal en fusion |
| Le métal chauffé | `#ff8a2a` | étincelles, fentes, tranchant des lames |
| L'acier clair | `#dfe6ee` | matière principale des lames et des éclats |
| L'acier sombre | `#3a4450` | ombres des plaques, fissures |
| Le cerne | `#161b22` | contour qui tient sur les sols clairs |

Trois règles pour tous : le dessin est **net, à plages franches**, comme les autres effets peints.
Tout effet posé au sol est **cerné**, sinon il disparaît sur les stages clairs. Et **l'acier domine,
l'orange ne fait qu'accentuer**, pour ne pas le confondre avec le Mage du Feu.

### Coup de marteau (attaque)

- **Frappe, 0,35 s :** un éclat au sol à ses pieds, avec un anneau d'acier et des étincelles.
- **Onde :** un grand croissant d'acier bordé d'orange court dans le couloir et arrache des éclats au sol.
- **Sillage :** le sol se fend derrière lui jusqu'à la cible, puis refroidit de l'orange au gris.
- **Impact :** un éclat, un anneau et des morceaux d'acier gris qui s'écartent sur la cible.

### Plaques (le trait)

- **Au repos :** trois petites plaques au-dessus de sa barre, pleines ou vides.
- **Plaque arrachée, 0,35 s :** un éclat de métal part en tournant, avec un claquement d'étincelles.
- **Plaque reforgée, 0,3 s :** une plaque rougeoyante vient se coller à lui, puis refroidit au gris.

### Ailes-lames

- **Aller, 0,4 s :** cinq lames d'acier s'ouvrent en éventail en tournant, avec un fin tranchant
  orange et une courte traînée grise.
- **Point haut :** elles ralentissent une fraction de seconde et se retournent, pour qu'on lise
  le retour.
- **Retour, 0,35 s :** elles reviennent vers lui en accélérant et se replient dans ses ailes.
- **Ennemi touché :** une entaille nette, et trois étincelles.

### Onde d'enclume

C'est l'effet qui fait le personnage : on doit sentir son poids.

- **Coup, 0,15 s :** une enclume fantôme gris clair s'abat à ses pieds, et le sol se fend.
- **L'onde :** des fissures sombres cernées d'orange courent dans les couloirs, sans passer les
  haies, et soulèvent des plaques de sol derrière elles.
- **Ennemi étourdi :** de petits éclats de métal tournent au-dessus de sa tête.
- **Fin, 0,4 s :** les fissures se refroidissent de l'orange au gris, puis s'effacent.

### Rempart

- **Fermeture, 0,2 s :** ses ailes se referment devant lui, lame après lame, avec un éclat à chaque lame.
- **Tant qu'il tient :** un dôme de lames superposées l'entoure, et les joints luisent en orange.
- **Coup renvoyé :** une lame part vers l'attaquant, et un anneau d'étincelles marque le dôme.
- **Fin, 0,25 s :** les lames s'ouvrent d'un coup et reprennent leur place dans ses ailes.

### Charge

- **Départ, 0,15 s :** il se ramasse, et le sol se fend derrière ses bottes.
- **Trajet :** de longues traînées grises et un sillon d'étincelles orange au sol.
- **Ennemi renversé :** un éclat blanc, et l'ennemi est projeté sur le côté.
- **Arrivée, 0,25 s :** un petit anneau de poussière grise, et il se redresse.

### Acier en fusion (ultime)

- **Temps 1, 0,5 s :** il plante son marteau, le décor s'assombrit, et ses fentes s'allument une à une.
- **Temps 2, 0,4 s :** son armure passe du gris à l'orange, puis au blanc par endroits, et il grandit
  d'un coup avec une onde de chaleur et une colonne d'étincelles.
- **Tant que ça dure :** son armure reste rougeoyante, des gouttes de métal tombent et brillent un
  instant au sol, et ses coups font jaillir de larges gerbes.
- **Fin, 0,6 s :** l'armure refroidit du blanc à l'orange puis au gris, avec un peu de vapeur.

---

## Quand les images sont là

Il suffit de les déposer et de me le dire : je les découpe, je contrôle chaque planche et je
programme le personnage et ses effets.
