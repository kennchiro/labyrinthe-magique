# La barre du mage, refaite — prompts

Trois images à générer dans ChatGPT, **chacune dans une conversation neuve**, pour
qu'il ne reparte pas de l'image précédente. Le jeu écrit tous les textes et remplit
lui-même les jauges : les images ne fournissent que la matière.

| # | Fichier à déposer dans `assets/peso&cover/interface/barre/` | Rôle | Joindre |
|---|---|---|---|
| 1 | `cadre_barre.png` | le cadre vide | `ref_barre_mage.png` + `ref_carte.png` |
| 2 | `pieces_barre.png` | jauges, gemme, sertissage, icônes | `ref_carte.png` |
| 3 | `cadre_case.png` | le cadre d'une case de sort (clavier) | `ref_carte.png` |

Les deux références sont dans `docs/prompts/ref/`.

Format d'export à demander à chaque fois : **PNG, 1536 x 1024, paysage**.

---

## 1. Le cadre de la barre

```
Élément d'interface pour un jeu de rôle mobile, style cartoon coloré à contours
nets, même facture que le cadre de la carte jointe : pierre grise sculptée, filets
d'or, petites vignes.

Reprends EXACTEMENT la disposition du gabarit joint (formes, proportions, positions).
Ce gabarit est un plan : tu l'habilles sans déplacer ni redimensionner aucune zone.

FORMAT : une seule image de 1536 x 1024 pixels, en paysage.

SUJET, vu de face, centré :
- à gauche, un grand MÉDAILLON ROND de pierre et d'or, qui dépasse du cadre en haut
  et en bas. Entre son bord et sa fenêtre court une GORGE circulaire lisse et très
  sombre, vide de tout ornement : le jeu y dessine une jauge
- à droite du médaillon, une longue BARRE horizontale de pierre sculptée rehaussée
  d'or, angles renforcés, quelques vignes discrètes sur l'extérieur
- l'intérieur de cette barre est une plaque d'ardoise bleu nuit presque noire, MATE
  et TRÈS PEU détaillée : le jeu y écrira du texte
- dans cette plaque, deux GOUTTIÈRES horizontales serties d'un fin filet d'or,
  celle du haut deux fois plus épaisse que celle du bas

ZONES MAGENTA PUR UNI (#FF00FF), à bords nets, sans dégradé ni ombre :
- la fenêtre ronde du médaillon
- l'intérieur des deux gouttières
- tout ce qui entoure l'objet

RÈGLES ABSOLUES :
- exactement trois trous magenta à l'intérieur de l'objet, ni plus ni moins, chacun
  fermé par son contour
- le cadre est GRIS et OR, sans rouge, bleu, vert ni violet
- rien ne pend ni ne déborde dans les gouttières et la fenêtre
- aucune lueur, aucune ombre portée, aucun halo sur le magenta
- aucun texte, aucun chiffre, aucune gemme, aucun personnage, aucune icône
```

### Si ça revient mal

| Défaut | Correction |
|---|---|
| Il a écrit des textes ou posé des gemmes | rappeler « cadre VIDE, le jeu écrit tout » |
| Gouttières peintes en rouge et bleu | rappeler « magenta pur », c'est bloquant |
| Halo autour du médaillon | rappeler « aucune lueur sur le magenta » : il salirait le détourage |
| Plaque trop ornée | rappeler « ardoise mate » : du texte de 11 points doit s'y lire |

---

## 2. Les pièces

```
Planche de pièces d'interface pour un jeu de rôle mobile, style cartoon coloré à
contours nets, même facture que l'image jointe. Éclairage venant du haut.

FORMAT : une seule image de 1536 x 1024 pixels, en paysage, fond MAGENTA PUR UNI
(#FF00FF) partout entre les pièces. Les pièces ne se touchent pas, avec une large
marge de magenta entre elles et autour.

QUATRE RANGÉES :

RANGÉE 1 — une longue bande horizontale, presque toute la largeur de l'image, aussi
haute qu'un douzième de l'image : un RUBIS LIQUIDE, rouge profond en bas, rouge vif
au milieu, reflet clair net en haut.

RANGÉE 2 — même bande, mêmes dimensions : une ÉNERGIE DE PORTAIL, bleu nuit en bas,
cyan au milieu, reflet presque blanc en haut.

RANGÉE 3 — même bande, mêmes dimensions : un CRISTAL DE BOUCLIER translucide, bleu
glacier très pâle, avec un reflet blanc en haut.

RANGÉE 4 — cinq pièces carrées de même taille, alignées, bien espacées :
1. un SERTISSAGE rond vide, vu de face : anneau de pierre et d'or, creux sombre
2. une GEMME ronde à facettes, vue de face, entièrement en NUANCES DE GRIS CLAIR
   (jamais colorée), avec un éclat blanc
3. une petite icône de PORTAIL : un tourbillon bleu dans un anneau de runes
4. une petite icône de CRÂNE stylisé, ivoire, simple et lisible en très petit
5. une petite icône d'ÉCLAT D'OR à quatre branches

RÈGLES ABSOLUES :
- les trois bandes sont IDENTIQUES de gauche à droite : aucun motif, aucune bulle,
  aucune fissure, aucun embout arrondi. Bords gauche et droit coupés droit. Le jeu
  les étire et les coupe à n'importe quelle longueur
- les trois bandes n'ont ni cadre ni contour
- aucune ombre portée, aucune lueur sur le magenta
- aucun texte, aucun chiffre
- les icônes restent reconnaissables réduites à 16 pixels : formes pleines, peu de
  détails
```

### Si ça revient mal

| Défaut | Correction |
|---|---|
| Bulles ou motifs dans les bandes | rappeler « identiques de gauche à droite » : étirés, ils se déforment |
| Gemme colorée | rappeler « gris clair » : le jeu la teint à la couleur de chaque gemme |
| Bandes à bouts arrondis | rappeler « coupés droit » |
| Icônes trop fines | rappeler « lisibles à 16 pixels » |

---

## 3. La case de sort

```
Élément d'interface pour un jeu de rôle mobile, style cartoon coloré à contours
nets, même facture que le cadre de la carte jointe.

FORMAT : une seule image de 1536 x 1024 pixels, en paysage.

SUJET, vu de face, centré : UN SEUL cadre rectangulaire couché, deux fois plus
large que haut, occupant les deux tiers de la largeur de l'image. Pierre grise
sculptée et filet d'or, quatre angles renforcés IDENTIQUES.

L'INTÉRIEUR DU CADRE ET TOUT CE QUI L'ENTOURE SONT EN MAGENTA PUR UNI (#FF00FF), à
bords nets, sans dégradé ni ombre.

RÈGLES ABSOLUES :
- la bordure est fine, un quinzième de la hauteur du cadre, et RÉGULIÈRE sur les
  quatre côtés
- entre deux angles, les bords sont répétitifs et sans motif central : le jeu étire
  ce cadre sans déformer les angles
- le cadre est GRIS et OR uniquement : le jeu le teinte à la couleur de chaque mage
- pas de vignes, pas de gemme, pas de sertissage
- aucune lueur, aucun texte, aucune icône
```

### Si ça revient mal

| Défaut | Correction |
|---|---|
| Ornement au milieu d'un bord | rappeler « sans motif central » : il s'étirerait |
| Bordure épaisse | rappeler « un quinzième de la hauteur » : elle mangerait l'icône du sort |
| Cadre doré ou coloré | rappeler « GRIS et OR, le jeu le teinte » |
