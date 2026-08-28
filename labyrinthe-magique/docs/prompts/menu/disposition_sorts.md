# disposition_sorts — la mise en page des six sorts sur « Choisis ton mage »

> ⚠️ **Ce qui revient est une MAQUETTE DE RÉFÉRENCE, pas un asset.** Rien de ce
> dessin ne part dans le jeu : les libellés sont du texte tracé par le moteur
> (`AbilityRow`, `character_select.gd`), et une image de texte changerait de
> langue avant l'image. On demande des PROPORTIONS et un ordre de lecture, qu'on
> reporte ensuite dans `_layout_card()`.
> Joins la capture de l'écran actuel (`godot --path . -- --select --character
> shadow --screenshot /tmp/sel.png`) — c'est le sujet de la critique.

## Ce qui ne va pas aujourd'hui, et qu'il faut dire au modèle

Six lignes pleine largeur empilées, toutes bâties pareil : pastille ronde ·
créneau · nom · **chiffres collés au bord droit** · description en gris dessous.
Trois défauts qui se voient sur la capture :

1. **le regard traverse l'écran pour chaque sort** — le nom est à gauche, ses
   chiffres à 900 px de là. Sur les six lignes, ça fait six allers-retours ;
2. **c'est un mur de texte** — description sous chaque ligne, même corps, même
   gris : rien ne dit ce qu'il faut lire en premier. Or ce qui décide du choix
   d'un mage, c'est ce que font ses sorts, pas leurs chiffres ;
3. **l'ULTIME ne se distingue presque pas** — il n'a qu'un liseré doré, alors
   que c'est le seul sort qui se MÉRITE (« à 4 kills »).

## Les contraintes que la maquette doit respecter — mesurées, pas supposées

| | |
|---|---|
| **paysage**, viewport de base **1280 x 720** | et jusqu'à **~960 x 450 unités** sur un téléphone posé en paysage |
| la fiche occupe la largeur moins 28 px | soit **~1250 x 410** au repos, **~930 x 230** sur téléphone |
| **portrait du mage à droite**, 24 % de la largeur | il reste ~76 % pour le texte |
| **6 sorts**, toujours : ATTAQUE · SORT 1 · SORT 2 · SORT 3 · FUITE · EXTRA | jamais plus, jamais moins |
| **nom du sort** : 4 à 23 caractères | « Rune », « Convergence élémentaire » |
| **chiffres** : jusqu'à **90 caractères** | `10 dégâts/s · rayon 1.4 · 8 s · 3 charges · recharge 8 s · englue à 18 % tant qu'on y reste` |
| **description** : 36 à **155 caractères** | médiane 61 |
| **icône ronde**, source 256 px | dessin inscrit dans 70 % du carré |
| au doigt, toute cible fait **62 points** | mais ici rien n'est cliquable : la fiche se lit, elle ne se manipule pas |

---

## Le prompt

```
Tu es directeur artistique d'interface sur un jeu de rôle mobile en PAYSAGE.
Je te joins la capture d'un écran de sélection de personnage fait dans Godot.
Je veux REFAIRE LA DISPOSITION de la liste des six sorts, au centre de la fiche.

CE QUI EXISTE — et qui ne bouge pas :
- en haut, une rangée de huit vignettes de mages ; en bas, trois boutons
- au centre, la fiche du mage choisi : nom, élément, une phrase, ses
  caractéristiques, son trait, puis SES SIX SORTS
- à droite de la fiche, le portrait du mage, sur 24 % de la largeur

CE QUI NE VA PAS, et que tu dois corriger :
1. les six sorts sont six lignes pleine largeur identiques : le nom est collé à
   gauche, ses chiffres collés au bord droit, à presque mille pixels de là. Le
   regard traverse l'écran six fois
2. sous chaque ligne, une description en petit gris : l'ensemble est un mur de
   texte où rien ne se détache de rien
3. l'ULTIME — le sixième sort, celui qui se gagne en tuant des ennemis — ne se
   distingue presque pas des cinq autres

CE QUE CHAQUE SORT DOIT MONTRER, sans exception :
- une icône RONDE (dessin déjà découpé, inscrit dans un cercle)
- son créneau : ATTAQUE, SORT 1, SORT 2, SORT 3, FUITE, EXTRA
- son nom : de 4 à 23 caractères
- ses chiffres : une seule chaîne, JUSQU'À 90 CARACTÈRES, par exemple
  « 10 dégâts/s · rayon 1.4 · 8 s · 3 charges · recharge 8 s · englue à 18 % »
- sa description : de 36 à 155 caractères, médiane 61

CONTRAINTES DE FORMAT — impératives :
- la zone à remplir fait environ 1250 x 410 pixels sur tablette, et descend à
  930 x 230 sur un téléphone en paysage. Ta disposition doit tenir dans les
  DEUX, et tu dois dire explicitement CE QUI DISPARAÎT quand la place manque
- SIX sorts, toujours. Pas cinq, pas sept. Pas de défilement : tout est visible
  d'un coup, c'est un écran de choix, pas une notice
- tout le texte est tracé par le moteur et sera TRADUIT : ne compte sur aucune
  longueur fixe, et prévois qu'un nom puisse s'allonger de moitié
- exprime toutes tes mesures en POURCENTAGE de la zone, jamais en pixels

CE QUE JE VEUX EN RETOUR :
1. TROIS dispositions différentes, dessinées en fil de fer (wireframe) annoté,
   côte à côte sur une seule image, fond sombre. Pas de couleurs finales, pas
   d'illustration : des rectangles, des repères et des cotes en pourcentage.
   Écris dans les blocs du VRAI texte d'exemple, pas du faux-latin, pour que la
   longueur réelle se voie
2. pour chacune, trois lignes : ce qu'on lit en PREMIER, ce qui se compare d'un
   sort à l'autre, ce qui tombe en premier sur un petit écran
3. ta recommandation, et pourquoi les deux autres perdent

Trois pistes à explorer, une par variante, à moins que tu n'aies mieux :
- DEUX COLONNES de trois sorts : le trajet de l'œil est divisé par deux, mais
  chaque bloc est deux fois plus étroit
- une GRILLE DE SIX CARTES (3 x 2) : chaque sort devient une tuile avec son
  icône en haut, comme une main de cartes
- la LISTE GARDÉE mais resserrée : chiffres ramenés SOUS le nom au lieu du bord
  droit, description au survol seulement, ultime sur une ligne à part

Un dernier point, et c'est le plus important : cet écran sert à CHOISIR entre
huit mages. Ce qui compte n'est pas qu'on puisse tout lire, c'est qu'on puisse
COMPARER. Dis-moi laquelle de tes trois dispositions se compare le mieux d'un
mage à l'autre.
```

---

## Ensuite

Une fois la variante choisie, second tour pour l'habillage — mais **seulement
après** avoir reporté les proportions dans le moteur et capturé le résultat :

```
Garde exactement la disposition n° <N> que tu as recommandée, et rends-la
cette fois en couleur, dans le style de la capture jointe : fond bleu nuit
translucide, filets or, texte blanc cassé, accents à la couleur de l'élément du
mage. Toujours en paysage, toujours six sorts. C'est une maquette de rendu :
je veux voir les contrastes et les corps de texte, pas un dessin d'icônes.
```

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Une liste défilante | rappeler « pas de défilement, les six sorts visibles d'un coup » |
| Du faux-latin dans les blocs | rappeler « du VRAI texte d'exemple » — c'est la longueur qu'on juge, et le latin est plus court que le français |
| Une seule variante, très finie | c'est trois FILS DE FER qu'on demande : à ce stade le dessin ne sert à rien, seule la structure se juge |
| Des cotes en pixels | rappeler le pourcentage : la fiche fait 1250 de large sur tablette et 930 sur téléphone |
| Sept sorts, ou cinq | relancer : le nombre est fixe, c'est une contrainte du jeu |
| Il oublie le petit écran | redemander la ligne « ce qui tombe en premier » pour chaque variante |
