# Les pièces du Dragon des Abysses — prompt

Le jeu les dessine séparément du personnage, et ajoute lui-même le feu, la lueur, la fumée et la traînée.

| case | objet | sert à |
|---|---|---|
| 1 | boule de magma | le Crachat de magma en vol |
| 2 | écaille de magma | les huit éclats des Écailles de magma |
| 3 | gueule de flamme | la Morsure qui se referme sur la proie |
| 4 | le dragon en vol, vu de dessus | l'Ombre du Dragon : le jeu la noircit et l'agrandit à l'échelle de l'écran |

## Prompt

> Joindre `assets/peso&cover/refonte/dragon.png`, pour les écailles, les couleurs et le trait.

```
Planche de quatre objets pour un jeu de rôle mobile vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites du jeu. L'image jointe donne
les écailles, les couleurs et le trait du dragon : ces objets lui appartiennent.

FORMAT exact : image 1024 x 1024 pixels, grille régulière de 2 colonnes x 2 rangées, quatre
cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne de grille, cadre, numéro,
lettre ou texte. Un objet centré par case, environ 75 % de la case, avec une marge magenta
et sans débordement.

Palette STRICTE : noir charbon (#1c1210), rouge sang (#8a160c), rouge infernal (#d1200c),
magma orange (#ff5a10) et cœur jaune (#ffe36a). AUCUN rose, AUCUN violet, AUCUN magenta dans
les objets. Le magma est en aplats nets, sans halo flou ni transparence.

Dans l'ordre de lecture :
1. BOULE DE MAGMA — une boule de lave ronde, croûte noire craquelée sur le dessus, magma
   orange et jaune qui brille dans les fissures. Vue de face, sans traînée.
2. ÉCAILLE DE MAGMA — une seule grande écaille pointue, en forme de pointe de flèche, noire
   sur le dessus, avec un cœur de magma orange qui suinte de ses bords. Pointe vers le haut.
3. GUEULE DE FLAMME — une immense mâchoire de dragon faite de flammes rouges et orange à
   contours nets, vue de face, GRANDE OUVERTE : rangée de crocs blancs en haut et en bas,
   gorge jaune au fond. Pas de tête autour : seulement la gueule.
4. LE DRAGON EN VOL, VU DE DESSUS — le même dragon, vu exactement d'au-dessus, AILES
   GRANDES DÉPLOYÉES en croix, tête et cornes vers le haut de la case, queue droite vers le
   bas. Les ailes touchent presque les bords gauche et droit de la case. Silhouette
   symétrique, contour très lisible.

⚠️ La case 4 doit rester lisible en ombre noire : une silhouette franche, ailes bien
séparées du corps, sans flamme ni fumée qui en brouillerait le contour.

Pas de décor, particule, ombre, flou, ni autre personnage. Le magenta du fond ne doit pas se
refléter dans les objets.
```

Déposer dans **`assets/peso&cover/sorts/dragon_pieces.png`**.

## À vérifier sur la planche reçue

Le générateur peut changer l'ordre : relever ce que chaque case MONTRE avant de découper.

| Défaut | Conséquence en jeu |
|---|---|
| Le dragon de la case 4 vu de profil ou de trois quarts | Son ombre ne ressemblerait plus à un dragon qui survole |
| Des ailes repliées en case 4 | L'ombre serait une tache, sans envergure |
| Une tête entière autour de la gueule | La Morsure collerait une tête de dragon sur l'ennemi |
| Un halo autour du magma | Une frange rose resterait au détourage |
