# Renaissance — l'exaltation du Sorcier Suprême

## Ce que le sort est devenu

Il ne rendait que 2 points de vie toutes les 16 s. On l'appuyait sans regarder,
rien ne changeait à l'écran, et le mot « renaissance » ne racontait rien d'un
pansement.

| | |
|---|---|
| **soin** | 3 points de vie, tout de suite |
| **exaltation** | **+8 à chaque coup porté, pendant 30 s** |
| **recharge** | 38 s — il reste huit secondes nues |

⚠️ **La recharge de 38 s est la contrepartie de la durée.** À 16 s pour 30 s
d'effet, l'exaltation ne s'arrête jamais : ce n'est plus un sort, c'est une
statistique de base. À 38 s, la relancer est une décision.

Sur le trait élémentaire à 20, +8 se sent tout de suite (+40 %) sans transformer
la Convergence à 56 en autre chose. L'ultime de l'Eau donne +10, mais il se
mérite en huit kills — celui-ci est disponible d'entrée.

---

## Une planche, deux temps

⚠️ **La planche est livrée** (`supreme_renaissance.png`) et elle sert aux DEUX
effets, pas seulement à l'activation. C'est un écart avec ce qui était prévu
ici, et il vient d'une demande : une aura PERMANENTE sur son corps, du genre
d'une charge de ki, et non trois anneaux calculés.

Elle avait été demandée comme un jaillissement en un temps — le cercle
s'allume, la colonne monte, tout retombe, dernière case presque vide. Telle
quelle, elle ne peut pas boucler : on repasserait par sa case vide et l'aura
s'éteindrait une fois par seconde. On la coupe donc :

    cases 0 à 7   jouées UNE fois     -> l'activation, le jaillissement
    cases 3 à 5   bouclées ensuite    -> l'aura, tant que dure le bonus

Les trois cases de pleine puissance, enchaînées en rond, scintillent sans jamais
retomber : c'est exactement l'aspect d'une aura de charge. Les bornes vivent
dans `renaissance_aura.json`, jamais dans le moteur.

**Ce que le code garde pour lui**, parce qu'aucune bande ne sait le faire :
suivre un corps qui court, et surtout **battre de plus en plus vite dans les
quatre dernières secondes** — c'est le seul avertissement que le joueur a avant
de perdre son bonus, et une image fixe ne sait pas dire « il reste trois
secondes ».

**Et le PLAN, qui a tout décidé.** L'aura est dessinée DERRIÈRE le mage
(`z_index = -1`, relatif à lui qui est au plan 10). Posée devant comme l'égide
de pierre, la colonne de lumière le noyait complètement — vérifié à l'écran. Une
coque de protection se pose devant ; une aura de charge jaillit du corps et le
laisse net devant elle.

⚠️ Le moins-un est RELATIF. Une valeur absolue négative ferait passer l'aura sous
le sol, qui est au plan 0 — c'est le piège de ce jeu, et il a déjà servi.

---

## Le prompt

> Livrée sous le nom `supreme_renaissance.png`, dans `assets/peso&cover/sorts/`.

```
Feuille d'animation pour un sort de jeu 2D vu de DESSUS, style cartoon coloré à
contours nets, effets lumineux, même facture que les sprites de sorts d'un jeu
de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de 2048 x 1024 pixels
- grille RÉGULIÈRE de 4 colonnes x 2 rangées, soit 8 cases de 512 x 512
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé ni ombre
- dans chaque case, l'effet est CENTRÉ et occupe environ 85 % de la case
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol

⚠️ RÈGLE BLOQUANTE — AUCUN PERSONNAGE, ET UN TROU AU MILIEU. Le mage est dessiné
par le jeu et se tiendra au CENTRE de cette image. Le cœur de chaque case doit
donc rester VIDE, magenta, sur environ un cinquième de la largeur : tout ce qui y
serait dessiné le recouvrirait. L'effet vit AUTOUR de ce vide, jamais dessus.

SUJET — UNE RENAISSANCE PAR LES QUATRE ÉLÉMENTS. Un mage invisible est SOULEVÉ
par une colonne de lumière qui jaillit du sol autour de lui. Quatre rubans — un
rouge de feu, un bleu de glace, un vert-brun de pierre, un blanc de vent —
montent en hélice le long de cette colonne et s'ouvrent en haut comme des ailes.
Des pétales dorés et des braises s'élèvent avec eux. Vue de DESSUS en légère
plongée.

LES 8 CASES s'enchaînent, lues de gauche à droite puis de haut en bas — c'est un
JAILLISSEMENT, pas une boucle :
1. un cercle de runes dorées s'allume au sol autour du vide, rien d'autre
2. le cercle se fend, quatre filets de couleur en sortent
3. les filets se dressent et commencent à monter en hélice
4. la colonne de lumière jaillit, les quatre rubans l'enlacent
5. la colonne est à son plus fort, blanche au cœur, les rubans s'écartent
6. les rubans s'ouvrent en haut comme des ailes, des pétales dorés montent
7. la colonne retombe, il ne reste que les ailes qui s'estompent
8. presque vide : le cercle de runes au sol, très pâle, et deux ou trois braises

⚠️ La huitième case est PRESQUE VIDE. Le jeu prend le relais avec sa propre aura
de trente secondes : une dernière image encore pleine laisserait un halo figé sur
le mage par-dessus elle.

AUTRES RÈGLES :
- le TROU CENTRAL reste vide dans les 8 cases, sans exception
- l'effet MONTE : il est bas et large aux cases 1-2, haut et étroit aux cases 5-6
- les quatre couleurs restent identifiables du début à la fin
- aucune explosion, aucun cratère, aucun ennemi : rien n'est frappé ici, c'est le
  mage qui se relève
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le centre est rempli | **défaut bloquant** : le mage se tiendra là. Redemander la planche |
| Un personnage est dessiné | rappeler « aucun personnage, le jeu pose le mage au centre » |
| Ça ressemble à une explosion | rappeler « rien n'est frappé, c'est le mage qui se relève » |
| L'effet ne monte pas | rappeler « bas et large aux cases 1-2, haut et étroit aux cases 5-6 » |
| La dernière image est encore pleine | rappeler « presque vide » : l'aura du jeu prend le relais par-dessus |

---

## Ce qui a été fait

1. **découpée** par `tools/build_renaissance.py`, qui écrit aussi les bornes de
   boucle dans le descripteur ;
2. **branchée** sur `src/fx/rebirth_aura.gd`, attaché au mage — il le suit
   partout, comme l'égide de la Terre ;
3. **vérifiée à l'écran** : jaillissement à 0,7 s, boucle encore franche à
   6,6 s, mage net devant l'aura sur herbe claire.

Le mage sans planche garde les anneaux calculés d'`empower_aura.gd` : le sort
marche exactement pareil, il est seulement moins beau.

## Si un jour on veut mieux

Une planche dessinée d'emblée POUR boucler — huit images d'une même flamme qui
tourne, sans début ni fin — donnerait une charge plus riche que trois cases
prélevées sur un jaillissement. Ce n'est pas nécessaire : la boucle actuelle ne
cligne pas. C'est un luxe, pas un correctif.
