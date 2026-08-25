# L'Ombre maléfique de la Faille des ténèbres — prompt pour la planche

## Ce qui existe déjà côté jeu

L'ultime est **fini et vérifié en headless**. Il ne reste que le dessin.

| | |
|---|---|
| **3 failles** | une par poursuivant, les plus proches d'abord |
| **2 ombres** par faille, soit **6** au plus | |
| **120 s** de vie chacune | |
| souffle de **gaz violet** | portée 1,5 case, 12 dégâts, poison de 3 PV/s |

La **porte** est déjà là : c'est le portail de la Rune (`rune.png`, six poses
qui tournent), joué plus vite et affiché 2,4 s — juste de quoi voir sortir ce
qu'il contient. On ne redemande donc PAS de portail : le même passage, ouvert
pour soi au sol ou déchiré au loin, doit se reconnaître.

En attendant la planche, l'ombre emprunte les bandes de la **gargouille**,
teintée en violet sombre (`SummonVisual.STAND_INS`). Elle est donc jouable et
réglable dès maintenant — mais aucune capture ne montre son vrai visage.

---

## Le prompt

> Copier-coller tel quel. Le fond MAGENTA n'est pas un caprice : les modèles
> d'image tiennent mal la transparence, alors qu'un aplat magenta se détoure au
> pixel près — et aucune palette du jeu ne contient de magenta, donc rien de
> légitime ne lui ressemble. Convention déjà utilisée sur quatre planches, sans
> un seul échec.

```
Feuille d'animation (sprite sheet) pour un jeu 2D vu de DESSUS en légère
plongée trois-quarts, style cartoon coloré de jeu de rôle mobile, contours
nets, couleurs saturées.

SUJET — une OMBRE MALÉFIQUE : une créature spectrale sans jambes, faite de
fumée noire et violette, qui flotte au-dessus du sol. Silhouette encapuchonnée
aux bords déchiquetés qui s'effilochent en volutes ; deux yeux d'un violet
lumineux comme seule source de lumière du corps ; deux mains griffues de fumée
plus dense. Le bas du corps se dissout en traînées de brume — PAS de pieds.
Palette : noir d'encre, violet profond (#4a1d7a), violet lumineux (#b06cff)
pour les yeux et les liserés.

FORMAT DE LA PLANCHE — impératif :
- fond MAGENTA UNI #FF00FF partout, y compris entre les cases, aucun dégradé,
  aucune ombre portée sur le fond, aucune transparence ;
- grille RÉGULIÈRE de 4 colonnes sur 5 rangées, cases de 512x512 pixels
  exactement, image finale 2048x2560 ;
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte ;
- chaque dessin RESTE ENTIÈREMENT dans sa case, avec au moins 40 pixels de vide
  magenta tout autour — rien ne doit toucher ni franchir le bord d'une case ;
- la créature a la MÊME TAILLE dans les vingt cases, et son centre est le même
  dans chaque case ;
- le bas de la brume touche toujours la même hauteur, aux deux tiers de la
  case : c'est la ligne de sol, elle ne bouge d'aucune case à l'autre.

CONTENU, rangée par rangée (lecture de gauche à droite) :

RANGÉE 1 — flottement VERS L'AVANT, la créature fait FACE au spectateur, on
voit son visage et ses deux yeux. 4 poses d'un cycle qui boucle : la brume du
bas ondule, le corps monte puis redescend, la capuche suit avec un temps de
retard.

RANGÉE 2 — flottement VERS L'ARRIÈRE, vue de DOS : on ne voit ni yeux ni
visage, seulement la capuche et le dos. 4 poses du même cycle.

RANGÉE 3 — flottement DE PROFIL, la créature regarde vers la GAUCHE de
l'image. Ses yeux, sa capuche et ses griffes pointent tous vers la GAUCHE ; les
volutes de brume traînent vers la DROITE, derrière elle. 4 poses du même cycle.

RANGÉE 4 — LE SOUFFLE DE GAZ, vue de FACE, 4 poses successives :
  1. elle se cambre en arrière, les mains ramenées, les yeux plus vifs ;
  2. la capuche s'ouvre, une lueur violette monte dans sa gorge ;
  3. elle projette en avant un JET DE GAZ VIOLET épais, en cône, qui part de
     sa capuche et s'élargit vers le bas de la case ;
  4. le jet se disperse en nappe, la créature retombe, un filet de gaz
     s'échappe encore.

RANGÉE 5 — LE GAZ SEUL, sans la créature, sur les quatre cases : un nuage de
gaz violet toxique vu de dessus, en quatre étapes de sa vie — il jaillit, il
s'étale, il tourne sur lui-même, il se dissipe. Bulles et volutes visibles,
cœur plus clair que les bords.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas de sol dessiné, pas
d'ombre portée, pas de cadre, pas de texte, pas de flou, pas de vignettage,
aucune case vide.
```

---

## Pourquoi cette mise en page

Chacune de ces contraintes vient d'un découpage qui a échoué :

- **la grille régulière et les 40 px de marge** — sur la planche du gobelin, les
  poses voisines débordaient par-dessus les lignes et le découpage sectionnait
  des massues. Il a fallu détecter les formes connexes au lieu de découper la
  grille, puis effacer les débordements par appartenance ;
- **la même taille dans toutes les cases** — la case est commune à toutes les
  directions d'une créature, et c'est ELLE qu'on met à l'échelle, pas le dessin.
  Un souffle dessiné deux fois plus gros que le flottement ferait grossir la
  créature au moment de frapper ;
- **la ligne de sol constante** — l'alignement se fait sur les pieds (ici sur le
  bas de la brume). Sur `skill_rune.png`, la rangée du bas était dessinée 91 px
  plus haut que celle du haut : le portail sautait entre deux poses ;
- **le profil qui regarde à GAUCHE, dit explicitement** — sept créatures du
  bestiaire ont marché à reculons pendant des semaines parce que la convention
  ne précisait pas le sens du profil. Les indices qui tranchent sont l'œil, la
  traînée du coup qui part DEVANT, et la brume qui reste DERRIÈRE ;
- **aucune case vide** — une case vide passe sous le radar de l'audit « cellule
  non vide » quand la phase de la grille se décale, et le défaut ne se voit
  qu'en jeu.

## Quand la planche arrive

La déposer dans `assets/peso&cover/` sous le nom `ombre_malefique.png`. Je m'en
charge ensuite : découpage vers `assets/allies/ombre/`, entrée dans
`allies.json`, retrait du pis-aller, et les effets autour du gaz (nappe qui
retombe, yeux qui s'allument dans la faille) restent à ma charge comme convenu.

---

# Addendum — les rangées qui manquent

La planche livrée ne dessine le souffle **que de face**. Trois directions sur
quatre attaquaient donc sans rien montrer. Deux réponses, et elles ne coûtent
pas la même chose.

## Ce qui est déjà fait, sans nouvelle image

Un **élan de frappe** (`SummonVisual.LUNGE`) : dans les directions sans pose de
souffle, l'ombre recule puis se jette vers sa proie. Ça marche dans les quatre
sens, ça dit la même chose que la pose — c'est elle qui frappe, et c'est par là
— et le nuage de gaz paraît de toute façon sur la victime. C'est suffisant pour
jouer.

## Si l'on veut le dessin

**Ne pas régénérer la planche entière.** Un modèle d'image ne redessine pas deux
fois le même personnage à l'identique : une nouvelle planche complète donnerait
une autre créature, et il faudrait jeter celle-ci, qui est bonne. On demande
donc **les deux rangées manquantes seulement**, en fournissant la planche
actuelle comme référence.

> Joindre `assets/peso&cover/ombre_malefique.png` au message.

```
Voici une feuille de sprites que tu as produite (image jointe). Je veux DEUX
RANGÉES SUPPLÉMENTAIRES de la MÊME créature, dans exactement le même style, la
même palette et la même taille — c'est le même personnage, pas une variante.

Rends une image de 4 colonnes sur 2 rangées, cases de 280x280 pixels, image
finale 1120x560, fond MAGENTA UNI #FF00FF, sans lignes de grille, sans texte.

RANGÉE 1 — LE SOUFFLE DE GAZ VU DE DOS, 4 poses. On ne voit ni yeux ni visage,
seulement la capuche et le dos, comme dans la deuxième rangée de l'image
jointe. Le jet de gaz violet part de sa capuche et s'éloigne VERS LE HAUT de la
case, en s'élargissant. Les quatre poses : elle se cambre ; la lueur monte ; le
jet part ; le jet se disperse.

RANGÉE 2 — LE SOUFFLE DE GAZ DE PROFIL, la créature regarde vers la GAUCHE de
l'image, 4 poses. Sa capuche, ses griffes et son regard pointent vers la
GAUCHE ; ses volutes de fumée traînent vers la DROITE, derrière elle. Le jet de
gaz violet part de sa capuche vers la GAUCHE en s'élargissant. Mêmes quatre
étapes que ci-dessus.

Contraintes identiques à la première planche : la créature a la MÊME TAILLE que
dans l'image jointe, elle reste entièrement dans sa case avec au moins 40 pixels
de vide magenta autour, le bas de sa fumée touche la même hauteur d'une case à
l'autre, aucune case vide, pas d'arrière-plan, pas d'ombre portée, pas de cadre.
```

La droite reste le **miroir de la gauche**, écrit sur le disque — inutile de la
demander.

## Où la déposer

    assets/peso&cover/ombre_souffle.png

Puis relancer `tools/.venv/bin/python tools/build_ombre.py` : l'outil la prend
tout seul si elle est là, et l'annonce s'il ne la trouve pas. Elle passe par le
**même alignement** que la première planche — c'est pour ça qu'elle est
découpée par le même outil et non par un second : les poses de coup doivent
tomber sur la même capuche que les poses de repos, sinon la créature sursaute au
moment de souffler. Les bandes `up`, `left` et `right` recevront alors leurs
poses de coup, et l'élan cessera de son propre chef sur ces directions.
