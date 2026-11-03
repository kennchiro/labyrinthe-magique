# L'Ange des Étoiles — images à générer et effets visuels

> Élément **Étoiles** · teinte du jeu `#9db8ff` · bleu nuit, argent et blanc stellaire.
> Elle pose des étoiles dans le labyrinthe, et les rayons qui les relient brûlent ce qui passe.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | prompt | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|---|
| 1 | le modèle du personnage | ci-dessous | `refonte/etoiles.png` | `refonte/chrono.png` |
| 2 | la marche | [mages_animes/etoiles](../mages_animes/etoiles.md), prompt 1 | `mages/etoiles_marche.png` | `refonte/etoiles.png` et `guide_marche.png` |
| 3 | l'attaque | [mages_animes/etoiles](../mages_animes/etoiles.md), prompt 2 | `mages/etoiles_attaque.png` | `refonte/etoiles.png` |
| 4 | les six icônes de sorts | [sorts/icones_etoiles](../sorts/icones_etoiles.md) | `sorts/mage_etoiles_skills.png` | aucune |
| 5 | le portrait du menu | [menu/portrait_etoiles](../menu/portrait_etoiles.md) | `interface/portraits/portrait_etoiles.png` | `ref_carte.png` et `refonte/etoiles.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches. **Le bleu des ailes et la robe sont les premiers points à regarder.**

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
1. vue DE FACE, immobile : le visage se voit bien, le haut des ailes dépasse derrière les épaules
2. vue DE DOS, immobile : les deux ailes à demi repliées et la tresse se voient en entier
3. vue DE PROFIL, TOURNÉE VERS LA DROITE, immobile : une seule aile se voit, derrière son dos

LE PERSONNAGE — l'Ange des Étoiles, une femme adulte, un ange au visage calme et bien visible.
Deux GRANDES AILES de plumes bleu nuit, semées de petits points blancs comme un ciel étoilé, à
demi repliées dans son dos. Une COURONNE EN CROISSANT DE LUNE argentée flotte au-dessus de sa tête.
Longs cheveux argentés attachés en une tresse qui tombe dans son dos. Longue robe bleu nuit à
manches longues, sobre et couvrante, à liserés d'argent, fendue sur le côté, sur des bottines
argentées. Elle tient de la main droite un fin SCEPTRE d'argent, surmonté d'une étoile blanche à
quatre branches. Corps CHIBI, très grosse tête, silhouette lisible en très petit. L'aura reste
COLLÉE au corps : pas de halo large, pas de particules, pas d'étoiles autour d'elle.

⚠️ RÈGLE BLOQUANTE — LES AILES RESTENT À DEMI REPLIÉES. Jamais déployées. Elles ne dépassent
pas de plus d'un quart de la largeur du corps de chaque côté, et leurs pointes s'arrêtent au
niveau des genoux. Le personnage devra marcher dans un couloir étroit.

⚠️ RÈGLE BLOQUANTE — SES PIEDS SE VOIENT. La robe s'arrête au-dessus des chevilles et la fente
laisse passer une jambe : la marche doit se lire sous le tissu.

⚠️ RÈGLE BLOQUANTE — UN FIN LISERÉ ARGENTÉ autour de toutes les formes sombres, plumes comprises :
elle doit rester lisible sur un sol très sombre.

⚠️ RÈGLE BLOQUANTE — LES COULEURS. Le bleu reste un BLEU NUIT franc (#141d4a), et l'argent reste
NEUTRE ou BLEUTÉ. Aucun violet, aucun rose, aucun reflet du fond magenta sur les plumes ou la robe.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs, mêmes
ailes, même couronne, même tresse, même sceptre, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE : UN CORPS CHIBI. Sa hauteur totale
vaut 2,5 TÊTES : la tête (coiffure ou casque compris) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de longues
jambes ou de petite tête : posé à côté du personnage de l'image jointe, il a la même morphologie.
Sa robe et sa tresse raccourcissent avec le corps : elle reste une femme adulte, habillée sobrement.


⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le corps est élancé, ou la tête petite | Il ne ressemblerait pas aux mages : c'est la raison de cette refonte, à regénérer sans attendre |
| Le bleu vire au violet | Le détourage y ferait des trous, et elle se confondrait avec le Sorcier des Ténèbres |
| Les ailes sont déployées ou très larges | Elle deviendrait bien plus large que les autres, et ses ailes passeraient sur les murs |
| La robe cache les pieds | On ne verrait plus ses pas : le jeu a besoin de pieds lisibles |
| Le bleu est trop clair | Elle ressemblerait au Mage de l'Eau ou de l'Air |
| Pas de liseré argenté | Elle disparaîtrait sur les stages sombres |
| Des étoiles autour d'elle | Elles fausseraient le calage sur les pieds, et le jeu dessine déjà ses sorts |

---

## Ses six sorts

Ce sont les règles que je propose ; les chiffres seront réglés à l'équilibrage.

| créneau | sort | ce qu'il fait |
|---|---|---|
| Trait | Astre | chaque coup pose une petite étoile sur l'ennemi ; à la troisième, elles explosent |
| ATTAQUE | Éclat stellaire | un petit trait d'étoile qui vise et ne rate jamais |
| SKILL 1 | Constellation | pose une étoile à ses pieds, trois au plus ; des rayons les relient à travers les haies et brûlent ce qui passe dessus |
| SKILL 2 | Pluie d'étoiles | des étoiles tombent une à une sur une zone autour d'elle |
| SKILL 3 | Voile de lune | pendant un court instant, les coups la traversent |
| FUITE | Étoile filante | un saut rapide qui laisse une traînée brûlante |
| EXTRA | Nuit éternelle | la nuit tombe sur l'écran, et une comète frappe chaque ennemi de la carte |

Une quatrième étoile remplace la plus ancienne : les rayons se déplacent avec elle. C'est le
placement qui fait le personnage, et aucun autre ne pose ses sorts à l'avance de cette façon.

---

## Les effets visuels, sort par sort

Ce sont les consignes des shaders que j'écrirai quand elle sera branchée. Les durées et les tailles
sont des cibles : l'équilibrage et ton essai en jeu peuvent les changer.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le cœur | `#ffffff` | centre des étoiles, instant de l'impact |
| La lueur | `#dbe6ff` | matière principale des rayons et des éclats |
| Le bleu stellaire | `#7fa2ff` | bords, traînées |
| La nuit | `#141d4a` | voiles et fonds |
| Le cerne | `#0a1030` | contour qui tient sur les sols clairs |

Trois règles pour tous : le dessin est **net, à plages franches**, comme les autres effets peints.
Tout effet posé au sol est **cerné**, sinon il disparaît sur les stages clairs. Et aucun violet,
pour ne pas la confondre avec le Sorcier des Ténèbres.

### Éclat stellaire (attaque)

- **Vol :** une petite étoile à quatre branches qui tourne sur elle-même, avec une courte traînée
  bleu pâle, faite de points qui s'éteignent.
- **Impact, 0,3 s :** une croix fine qui s'ouvre et se referme, et quelques points blancs.

### Astre (le trait)

- **Les marques :** une, deux puis trois petites étoiles tournent lentement autour de l'ennemi.
- **La troisième, 0,4 s :** elles foncent sur lui, un éclat blanc l'enveloppe, et un anneau bleu
  pâle s'élargit au sol.

### Constellation

C'est l'effet qui fait le personnage : on doit lire les rayons d'un coup d'œil, même de loin.

- **Pose, 0,3 s :** une étoile descend du ciel jusqu'à ses pieds, et un petit anneau marque le sol.
- **Vie :** l'étoile tourne lentement sur son disque, entourée de points qui clignotent.
- **Les rayons :** un trait fin à cœur blanc et bords bleus relie les étoiles, passe par-dessus les
  haies et palpite. Une petite lueur le parcourt d'une étoile à l'autre.
- **Ennemi touché :** des étincelles jaillissent là où il coupe le rayon.
- **Fin :** l'étoile la plus ancienne s'éteint, et ses rayons se rétractent vers les autres.

### Pluie d'étoiles

- **Ouverture, 0,3 s :** un cercle de points se dessine au sol.
- **Vie :** des étoiles tombent en biais, une à une, avec une longue traînée. Chacune s'écrase sur
  une case du cercle en petit anneau et en éclats.
- **Fin :** les dernières retombent, et le cercle s'efface point par point.

### Voile de lune

- **Ouverture, 0,2 s :** un grand croissant argenté se referme autour d'elle.
- **Tant qu'il tient :** son corps devient translucide et bleuté, et un voile ondule autour d'elle.
- **Coup traversé :** une petite onde argentée part du point touché.
- **Fin :** le voile se déchire en points de lumière, et elle retrouve ses couleurs.

### Étoile filante

- **Départ, 0,15 s :** elle se resserre en une étoile blanche.
- **Trajet :** une longue traînée bleue et blanche, qui s'effile vers l'arrière et reste un instant
  au sol. Elle y brûle ce qui passe.
- **Arrivée, 0,25 s :** un éclat en croix, et son corps se reforme.

### Nuit éternelle (ultime)

- **Temps 1, 0,6 s :** le décor s'assombrit jusqu'au bleu nuit, et les étoiles s'allument une à une
  sur tout l'écran. Ses ailes s'ouvrent, et sa couronne brille.
- **Temps 2, 0,5 s :** des traits relient les étoiles et dessinent une immense constellation.
- **Temps 3, 1,2 s :** **une comète tombe sur chaque ennemi de la carte**, l'une après l'autre, avec
  une longue traînée, puis un anneau bleu et une gerbe d'étoiles.
- **Temps 4 :** le ciel se retire depuis les bords de l'écran, et quelques étoiles tombent encore.

---

## Quand les images sont là

Il suffit de les déposer et de me le dire : je les découpe, je contrôle chaque planche et je
programme le personnage et ses effets.
