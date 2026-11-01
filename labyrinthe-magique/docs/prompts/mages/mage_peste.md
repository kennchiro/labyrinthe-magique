# Le Mage de la Peste — images à générer et effets visuels

> Élément **Poison** · teinte du jeu `#b4f02a` · vert acide sur aubergine presque noir.
> Plus on le poursuit, plus on s'empoisonne.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | prompt | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|---|
| 1 | le modèle du personnage | ci-dessous | `refonte/peste.png` | `refonte/chrono.png` |
| 2 | la marche | [mages_animes/peste](../mages_animes/peste.md), prompt 1 | `mages/peste_marche.png` | `refonte/peste.png` et `guide_marche.png` |
| 3 | l'attaque | [mages_animes/peste](../mages_animes/peste.md), prompt 2 | `mages/peste_attaque.png` | `refonte/peste.png` |
| 4 | les six icônes de sorts | [sorts/icones_peste](../sorts/icones_peste.md) | `sorts/mage_peste_skills.png` | aucune |
| 5 | le portrait du menu | [menu/portrait_peste](../menu/portrait_peste.md) | `interface/portraits/portrait_peste.png` | `ref_carte.png` et `refonte/peste.png` |

Vérifier chaque image avant de passer à la suivante : un défaut du modèle se retrouve sur
les deux planches.

**Aucune image à demander pour les effets de ses sorts** : ils seront peints au shader,
comme ceux des autres mages. La dernière partie de cette page les décrit en détail.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/chrono.png`, seulement pour le style et la mise en page.

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
1. vu DE FACE, immobile : les deux verres ronds du masque se voient en entier
2. vu DE DOS, immobile : la capuche et le manteau, avec le bâton à droite
3. vu DE PROFIL, TOURNÉ VERS LA DROITE, immobile : le long bec du masque se voit en entier

LE PERSONNAGE — le Mage de la Peste, un alchimiste. MASQUE DE MÉDECIN DE PESTE en cuir
sombre, à long bec courbe et à deux verres ronds VERT ACIDE lumineux : aucun visage visible.
Capuche et long manteau aubergine très sombre, presque noir, à liserés vert acide. Trois
petites FIOLES de liquide vert acide pendent à sa ceinture. Il tient de la main droite un
BÂTON tordu en bois noir, surmonté d'une grosse FIOLE RONDE pleine de liquide vert acide.
Bottes de cuir sombre. Corps COMPACT, tête un peu large, silhouette lisible en très petit.
L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de particules autour.

⚠️ RÈGLE BLOQUANTE — LES COULEURS. L'aubergine reste PRESQUE NOIR ET BLEUTÉ, jamais violet
vif ni rose, et le vert reste un vert ACIDE tirant sur le jaune : ils ne doivent se confondre
ni avec le fond magenta, ni avec un vert de mousse.

⚠️ RÈGLE BLOQUANTE — UN CONTOUR CLAIR. Le manteau sombre garde un liseré vert net sur tous
ses bords : il doit rester lisible sur un sol sombre.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs,
même masque, même bâton, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE, AUCUNE FUMÉE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le bec est court ou caché | Le masque fait toute sa silhouette : sans lui, c'est un mage à capuche de plus |
| Le manteau tire vers le violet | Il ressemblerait au Sorcier des Ténèbres ou à l'Invocateur, et se découperait mal du fond magenta |
| Le vert tire vers la mousse | Il ressemblerait au Mage de la Terre |
| Le manteau se fond en une tache noire | Il disparaîtrait sur les stages sombres |

---

## Les effets visuels, sort par sort

Ce sont les consignes des shaders que j'écrirai quand le mage sera branché. Les durées et
les tailles sont des cibles : l'équilibrage et ton essai en jeu peuvent les changer.

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le cœur | `#f2ff9e` | reflets, bulles qui éclatent, instant de l'impact |
| Le venin | `#b4f02a` | matière principale |
| L'ombre du venin | `#4e8a12` | creux des flaques et volutes de gaz |
| Le cerne | `#1e3a0c` | contour qui tient sur les sols clairs |
| La nuit | `#2a1a33` | fond du gaz, jamais seule et jamais en violet vif |

Trois règles pour tous : le dessin est **net, à plages franches**, comme les autres effets
peints et non un brouillard flou. Le gaz reste **translucide**, pour qu'on lise encore les
couloirs. Et rien ne se compose en additif, qui délaverait le vert sur les stages clairs.

### Dard venimeux (attaque)

- **Vol :** une goutte effilée, sa pointe vers l'avant, longue d'environ une case et demie.
  Son cœur est clair. Trois petites gouttes la suivent et tombent peu à peu.
- **Impact, 0,3 s :** la goutte s'écrase en étoile de cinq à sept éclaboussures, qui se
  rétractent en laissant une tache verte qui s'efface.

### Les doses sur un ennemi empoisonné

C'est l'effet le plus important pour bien jouer : on doit lire l'état d'un ennemi d'un coup
d'œil, sans chiffre.

- **Compteur :** une à trois petites gouttes vertes au-dessus de sa barre de vie, une par dose.
- **Teinte :** son corps vire au vert, de plus en plus franchement à chaque dose, en pulsant
  lentement.
- **Bulles :** une à une, elles montent de son corps et éclatent. À trois doses, il en sort
  en continu.
- **Mort par le poison :** il ne disparaît pas comme les autres, il se dissout en une flaque
  qui bouillonne un instant.

### Traînée toxique, 6 s

- **Pendant le sort :** ses bottes fument, et une flaque naît sur chaque case qu'il quitte.
- **Flaque :** une tache au bord irrégulier, jamais un cercle. Le fond est vert sombre, le
  bord est clair et cerné, et des bulles y éclatent au hasard.
- **Disparition :** elle se craquelle et se rétracte vers son centre, les plus anciennes
  d'abord, ce qui dessine clairement son chemin dans le couloir.
- **Quand un ennemi marche dedans :** un petit jet de gouttes à ses pieds, pour montrer que
  c'est la flaque qui l'empoisonne.

### Contagion, 0,5 s

- **Départ :** la cible se contracte d'un éclair vert, puis éclate en filets.
- **Propagation :** un filet de venin sinueux, avec des gouttes qui le remontent, file vers
  chaque voisin le long du couloir. Il ne ressemble pas à un éclair : il coule, il ne claque pas.
- **Arrivée :** une petite éclaboussure sur chaque ennemi touché, et ses gouttes de dose
  apparaissent.

### Transfusion, 0,8 s

- **Aspiration :** de chaque ennemi empoisonné, un filet de gouttes claires part vers le mage,
  en courbe, en accélérant. On voit donc d'où vient la vie qu'il reprend.
- **Réception :** les gouttes rejoignent la grosse fiole de son bâton, qui s'illumine et déborde
  un instant.
- **Soin :** un anneau de bulles remonte le long de son corps, puis s'efface.

### Brume (fuite)

- **Départ :** il se dissout de bas en haut en volutes vertes. Un nuage reste à sa place et
  empoisonne ce qui le traverse.
- **Nuage, 4 s :** trois ou quatre masses de gaz, à bord net, qui tournent lentement sur
  elles-mêmes. Il s'effiloche à la fin.
- **Arrivée :** les volutes se rassemblent en spirale et le recomposent de haut en bas.

### Pandémie (ultime)

- **Temps 1, 0,5 s :** il lève le bâton et la grosse fiole **se brise** vers le ciel. Le
  venin retombe en anneau autour de lui.
- **Temps 2, 1 s :** une large onde de gaz vert part de lui et traverse le labyrinthe, haies
  comprises. Son front est net, avec des crêtes, et l'écran verdit légèrement sur son passage.
- **Temps 3 :** chaque ennemi touché prend un éclair vert et ses trois gouttes de dose
  s'allument. On doit voir toute la carte tomber malade.
- **Éclatement, tant que dure le poison :** un ennemi qui meurt gonfle, puis éclate en nuage
  toxique de la taille d'une case et demie. C'est le moment le plus satisfaisant du sort.

---

## Quand les images sont là

Il suffit de les déposer et de me le dire : je les découpe, je contrôle chaque planche et je
programme le mage et ses effets.
