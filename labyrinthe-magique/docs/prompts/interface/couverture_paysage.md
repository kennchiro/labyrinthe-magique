# La couverture en PAYSAGE — prompt

## Pourquoi

`couverture.png` fait 1024 x 1536, un **portrait 2:3**. Le jeu, lui, se joue en
paysage sur téléphone et sur écran de bureau. Résultat mesuré en capture à
1280 x 600 : l'illustration n'occupe que **le tiers central** de l'écran, et les
deux bandes restantes sont remplies par la couverture elle-même, agrandie et
assombrie à 30 %. Ça fait illusion, ça ne fait pas une page d'accueil.

⚠️ Et elle ne montre que **cinq mages**. Elle date d'avant la Foudre et l'Air ;
depuis, l'Invocateur et le Suprême sont arrivés. **Ils sont huit.** Le paysage a
justement la largeur qu'il faut pour les aligner tous.

## Ce qui change dans le jeu, et ce qui ne change pas

Aujourd'hui les trois boutons sont **peints dans l'image**, et le jeu pose des
zones tactiles invisibles par-dessus (`HOTSPOTS`, en coordonnées relatives).
C'est fragile : chaque nouvelle image demande de re-mesurer trois rectangles, et
le texte des boutons est de la peinture — il ne peut ni changer ni rester net
quand on agrandit.

**On demande donc l'illustration SANS boutons**, et le jeu les dessinera par
-dessus, avec le style des autres menus. Le texte redevient net à toute taille,
les libellés se changent sans repasser par une image, et il n'y a plus de
rectangle à relever.

---

## Le prompt

> Copier-coller tel quel.

```
Illustration d'écran-titre pour un jeu de rôle mobile, en PAYSAGE.

FORMAT : image de 1792 x 1024 pixels, horizontale. Aucune bordure, aucun cadre.

STYLE : pixel-art cartoon riche et coloré, très détaillé, lumière nocturne
magique. Bleus profonds, verts sombres de feuillage, or chaud pour la lumière.
Contours nets, ambiance de conte, pas de photoréalisme.

SCÈNE — un LABYRINTHE DE PIERRE vu en plongée, s'enfonçant vers l'horizon au
centre de l'image : des haies de pierre moussue et de lierre, des dalles usées,
des braseros et des runes qui brillent le long des couloirs. Au fond, un
PORTAIL de lumière cyan sous une grande lune pâle, et des tours en ruine. Des
lucioles et des particules magiques flottent dans l'air. Sur les côtés, des
arbres et des ruines encadrent la scène en repoussoir sombre.

AU PREMIER PLAN, vus DE DOS, HUIT MAGES alignés sur toute la largeur, en
silhouettes découpées sur la lumière du labyrinthe. Chacun tient un bâton ou
une flamme de sa couleur, et une aura de son élément :
  1. rouge-orange (feu)      5. jaune électrique (foudre)
  2. bleu (eau)              6. blanc bleuté (air)
  3. vert (terre)            7. violet et or (invocateur)
  4. violet sombre (ombre)   8. or aux quatre couleurs (suprême)
Ils sont petits par rapport au décor — ils regardent le labyrinthe, ils ne
posent pas. Espacés régulièrement, aucun ne dépasse le tiers inférieur.

TITRE, en haut au centre, sur une bannière de bois et d'or ornée de feuillage :
    LABYRINTHE
    DES ÉLÉMENTS
en grandes capitales dorées à contour sombre, la seconde ligne plus petite.
Juste en dessous, en tout petit :
    CHOISIS TON HÉROS. MAÎTRISE LES ÉLÉMENTS. SAUVE LE ROYAUME.

⚠️ AUCUN BOUTON, aucun cadre d'interface, aucun autre texte que le titre et sa
phrase. Le tiers inférieur central doit rester CALME et un peu plus sombre —
c'est là que le jeu posera ses boutons, et rien d'important ne doit s'y trouver.

À NE PAS FAIRE : pas de bouton, pas de menu, pas de logo, pas de filigrane, pas
de bandes noires sur les côtés, pas de cadre décoratif autour de l'image, pas de
personnage vu de face.
```

---

## Où la déposer, et ce que je fais ensuite

    assets/peso&cover/interface/couverture_paysage.png

Puis me le dire. Je m'occupe du reste :

1. `title_screen.gd` prend la nouvelle image et **dessine ses trois boutons**
   avec `MenuStyle`, comme les autres menus. Les `HOTSPOTS` — trois rectangles
   relevés à la main sur l'ancienne image — disparaissent ;
2. le remplissage des bords reste, mais il ne servira plus qu'aux écrans très
   larges ou très carrés : à 16:9 l'image couvre tout ;
3. contrôle en capture à trois formes d'écran — 1280x720, 960x460 (paysage
   téléphone) et 1280x600 — parce que c'est exactement là que l'ancienne
   échouait.

⚠️ **Si le titre sort mal écrit** — les générateurs déforment le texte une fois
sur deux — dites-le moi plutôt que de recommencer : je peux demander une image
sans titre du tout et l'écrire dans le jeu, comme les boutons. C'est même la
solution la plus propre ; on n'y va pas d'emblée parce que la bannière dorée
peinte fait la moitié du charme de cette page.
