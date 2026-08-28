# jugement_incantation — le geste du mage avant les météores

## Pourquoi cette planche est redemandée

La première — `jugement_mage.png` — a été livrée en **explosion vue de dessus** :
un cratère de lumière qui s'ouvre et retombe. Posée au-dessus du mage, elle ne
racontait rien et le recouvrait.

Elle n'est pas perdue : elle est devenue **l'éclat de chaque météore au but**,
et c'est exactement ce qu'il lui fallait. Ce qui manque maintenant, c'est le
GESTE — ce que fait le mage avant que le ciel ne lui réponde.

## Ce que le jeu attend

Le même principe que la charge des Quatre Sceaux, et pour la même raison : un
effet posé SUR le personnage le cache. Il faut donc quelque chose qui **tourne
autour de lui** et le laisse visible au centre.

    les quatre éléments ORBITENT autour du mage, au sol
    puis ils MONTENT, aspirés vers le ciel
    ils quittent le cadre par le haut — et les météores répondent

Le mage n'est **pas** dessiné : le jeu le pose au centre. L'image doit donc
avoir un **trou au milieu** — c'est là qu'il se tiendra.

---

## Le prompt

> Une planche, `jugement_incantation.png`, dans `assets/peso&cover/sorts/`.

```
Feuille d'animation pour un sort de jeu 2D vu de DESSUS, style cartoon coloré à
contours nets, effets lumineux, même facture que les sprites de sorts d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 2048 pixels
- grille RÉGULIÈRE de 4 colonnes x 4 rangées, soit 16 cases de 512 x 512
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé ni ombre
- dans chaque case, l'effet est CENTRÉ et occupe environ 85 % de la case
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol

⚠️ RÈGLE BLOQUANTE — AUCUN PERSONNAGE, ET UN TROU AU MILIEU. Le mage est dessiné
par le jeu et se tiendra au CENTRE de cette image. Le cœur de chaque case doit
donc rester VIDE, magenta, sur environ un cinquième de la largeur : tout ce qui y
serait dessiné le recouvrirait. L'effet vit AUTOUR de ce vide, jamais dessus.

SUJET — LES QUATRE ÉLÉMENTS QUI SE LÈVENT. Quatre courants — un rouge de feu, un
bleu de glace, un vert-brun de pierre, un blanc de vent — tournent en orbite
autour d'un centre vide, d'abord à plat sur le sol, puis ils s'élèvent en
spirale et quittent le cadre par le haut. Vue de DESSUS en légère plongée.

LES 16 CASES s'enchaînent, lues de gauche à droite puis de haut en bas — c'est
une MONTÉE, pas une boucle :
1.  quatre étincelles posées au sol, largement écartées, immobiles
2.  elles se mettent à tourner, chacune laisse une courte traîne de sa couleur
3.  les traînes s'allongent et dessinent un anneau plat autour du vide
4.  l'anneau s'épaissit, les quatre couleurs se suivent sans se mêler
5.  des runes dorées s'allument sur l'anneau
6.  l'anneau se met à tourner vite, il ondule
7.  les quatre courants commencent à DÉCOLLER : ils quittent le sol en spirale
8.  la spirale monte, l'anneau au sol pâlit
9.  la spirale est haute, elle s'étire vers le haut du cadre
10. les quatre couleurs se rejoignent en une colonne dorée qui monte
11. la colonne quitte le cadre par le haut, l'anneau au sol n'est plus qu'un trait
12. il ne reste au sol qu'un cercle de runes qui pulse
13. le cercle se craquelle, des éclats dorés s'en détachent
14. les éclats montent à leur tour
15. le cercle s'éteint, quelques braises flottent
16. presque vide : deux ou trois braises qui s'éteignent

⚠️ La seizième case est PRESQUE VIDE. Le sort se termine et les météores prennent
le relais : une dernière image encore pleine laisserait un halo figé aux pieds du
mage pendant toute la pluie.

AUTRES RÈGLES :
- le TROU CENTRAL reste vide dans les 16 cases, sans exception
- l'anneau garde le MÊME diamètre du début à la fin : il s'allume, il tourne, il
  monte — il ne grandit pas
- les quatre couleurs restent identifiables jusqu'à la case 10
- aucune météore, aucun cratère, aucune explosion : c'est ce qui les APPELLE
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le centre est rempli | **défaut bloquant** : le mage se tiendra là, il serait recouvert. Redemander la planche |
| Un personnage est dessiné | rappeler « aucun personnage, le jeu pose le mage au centre » |
| Ça ressemble à une explosion | rappeler « c'est ce qui APPELLE les météores, pas leur impact » — c'est l'erreur de la première planche |
| L'anneau grandit d'une case à l'autre | rappeler « le MÊME diamètre du début à la fin » |
| La dernière image est encore pleine | rappeler « presque vide » : sinon un halo reste aux pieds du mage pendant toute la pluie |

---

## Ce que je fais quand elle arrive

1. **découpe** en bande de 16 images, même outil que la météore ;
2. **branchement** par `SpellCharge`, le nœud écrit pour les Quatre Sceaux — il
   joue une bande une seule fois et s'efface. Sa hauteur est réglable depuis le
   lancement : l'ultime la prendra à sept cases, contre 4,5 pour un sort courant ;
3. **cadence** : 16 images à 11 img/s font 1,45 s — et ce nombre est devenu une
   RÈGLE DE JEU. Le ciel ne répond qu'une fois le geste fini : `rain_delay`
   retarde toute la pluie de 1,45 s, si bien que la première météore part au
   moment où les quatre éléments quittent le cadre par le haut. Les deux
   nombres — la cadence de la planche et l'attente du catalogue — doivent
   coïncider, et `tools/build_jugement.py` le vérifie à chaque découpage.

## Ce qui a été fait

Livrée, découpée en bande de 16 images, branchée. Le geste se joue sur sept
cases de haut, la pluie l'attend.
