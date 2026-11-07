# L'Éveil du Mage de l'Eau — le Seigneur des Marées

> Le Mage de l'Eau, celui qui encaisse, ralentit et se soigne, devient le **Seigneur des Marées** pendant
> une minute. Le Phénix renaît une fois ; lui ne cesse d'encaisser : sa coque d'eau se reforme toute seule.

✅ **Programmé et jouable depuis le 2026-11-07** : `--demo --character water`, puis le bouton à droite de la
barre du mage ou la touche **T**. Règles communes : **1 min**, **10 s d'épuisement**, **6 kills** de charge.

Le joueur a d'abord eu une autre version, l'**Esprit des Marées** (trait Source vive : 1 PV toutes les 10 s),
écrite par une autre session. Le 2026-11-07, il a préféré ce kit-ci. **Les quatre images de l'Esprit sont
gardées** : la capuche à crête de vague, le trident et la robe aux courants vont au Seigneur des Marées, et
les six icônes correspondent à ses sorts (la sixième, un geyser sous la pluie, va avec la pluie qui suit le
Léviathan). Les prompts plus bas sont ceux qui les ont produites.

| # | Image | À déposer dans `assets/peso&cover/` | Statut |
|---|---|---|---|
| 1 | Le modèle | `refonte/eau_eveil.png` | ✅ reçue |
| 2 | La marche | `mages/eau_eveil_marche.png` | ✅ reçue, découpée (`water_eveil`) |
| 3 | L'attaque | `mages/eau_eveil_attaque.png` | ✅ reçue, découpée |
| 4 | Les six icônes | `sorts/mage_eau_eveil_skills.png` | ✅ reçue, découpée |

## Le Seigneur des Marées

### Trait éveillé — Marée haute

Une **coque d'eau** l'entoure : elle encaisse un coup entier, puis **se reforme toute seule 6 s après avoir
cédé** (`Awakening.SHELL_REGROW`). Il va aussi 15 % plus vite. La coque part avec l'Éveil.

### Six sorts éveillés

Ce sont les chiffres du jeu (`CharacterCatalog.water_awakened`). Ils ne sont pas mesurés : les bots ne
s'éveillent pas.

| Créneau | Sort éveillé | Effet | Chiffres |
|---|---|---|---|
| Attaque | **Trident** | le jet touche sa cible, puis rebondit sur deux ennemis voisins | 16 dégâts, portée 9, rebonds à 3 cases, 70 % à chaque saut |
| Skill 1 | **Raz-de-marée** | une vague géante remonte le couloir, emporte les ennemis et les plaque contre le mur | 40 dégâts, projette de 3 cases, +25 contre un mur, recharge 4 s |
| Skill 2 | **Bulle des abysses** | une bulle qui encaisse trois coups, et lui rend 1 PV si elle tient jusqu'au bout | 3 coups, 12 s, recharge 10 s |
| Skill 3 | **Glacier** | le cercle se hérisse de pics de glace : ce qui entre est gelé net, puis rampe | 8 dégâts/s, rayon 3, 8 s, gèle 2 s, recharge 8 s |
| Fuite | **Torrent** | il file en suivant le couloir, et laisse un courant qui ralentit | 9 cases, courant 4 s, recharge 7 s |
| Extra | **Léviathan** | un serpent d'eau géant traverse le labyrinthe et emporte tout sur son passage, puis une pluie le soigne | 110 dégâts, bande de 6 rangées, à travers les haies, +2 PV |

### Les effets (`assets/shaders/maree_*`, `tools/preview_maree.gd`)

Palette : écume `#e9ffff`, turquoise `#54eadb`, bleu vif `#37c6ff`, bleu abyssal `#0758bd`, argent `#c8d6e5`,
cerne `#062b62`. Aucun rose ni violet.

- **L'Éveil :** l'eau monte en spirale autour de lui, puis une vague se dresse dans son dos, sa crête
  s'enroule, et elle retombe en éclaboussures.
- **La coque :** un liseré d'argent où courent deux vaguelettes ; elle éclate en écume quand elle cède.
- **Trident :** trois pointes d'eau en vol, une gerbe en couronne à l'impact, et un jet en arc à chaque rebond.
- **Raz-de-marée :** le front d'eau de l'Éveil (`water_eveil_tsunami`, gardé de l'autre version).
- **Bulle des abysses :** une sphère d'eau aux courants tournants ; tenue, elle se dissout en spirale qui soigne.
- **Glacier :** un cercle de glace fendu, couronné de pics.
- **Torrent :** un courant qui file de case en case, les deux bouts qui éclatent, et des flaques qui ralentissent.
- **Léviathan :** un serpent d'eau qui traverse l'écran gueule ouverte, puis une pluie fine sur tout l'écran.

---

## Image 1 — modèle

Joindre `assets/peso&cover/refonte/eau.png` en premier (identité exacte du Mage de l'Eau), puis `assets/peso&cover/refonte/chrono.png` (proportions et mise en page uniquement).

```
Fiche de modèle pour un personnage de jeu 2D vu de dessus en légère plongée, style cartoon fantasy à contours nets, même facture que les sprites du jeu. La PREMIÈRE image jointe est le Mage de l'Eau exact : transforme ce personnage, ne le remplace pas. Garde son visage, sa robe bleu profond, ses liserés turquoise, sa ceinture, ses bottes et sa silhouette. La DEUXIÈME image ne sert qu'aux proportions chibi et à la grille : ne copie ni son personnage, ni ses couleurs, ni ses objets.

FORMAT EXACT : 1536 x 1024 pixels, trois cases égales de 512 x 1024 sur une rangée, fond uni magenta pur #FF00FF, personnage entier et centré dans chaque case, aucun décor, sol, texte, chiffre, ombre, cadre ou grille.

VUES de gauche à droite : face immobile, dos immobile, profil tourné vers la droite immobile. Le même personnage, la même taille et les mêmes détails dans les trois vues.

TRANSFORMATION — l'Esprit des Marées : même jeune Mage de l'Eau chibi, même visage et mêmes vêtements bleu profond. La capuche s'ouvre en une petite crête de vague turquoise et blanc d'écume. L'écharpe claire devient deux rubans d'eau opaques, courts, qui restent près du dos. La goutte de cristal bleu au sommet de son bâton s'allonge en pointe de trident lumineux ; le bâton reste dans sa main droite. Des filets turquoise et motifs de courants parcourent la robe. Ses yeux brillent turquoise pâle. Ses deux bottes restent bien visibles.

RÈGLE BLOQUANTE — corps compact et hauteur identiques au Mage de l'Eau de la première image ; proportions chibi, environ 2,5 têtes de haut. Aucun agrandissement de la silhouette.
RÈGLE BLOQUANTE — les rubans d'eau ne cachent ni jambes, ni bras, ni bâton et ne dépassent pas d'un quart de la largeur du corps.
RÈGLE BLOQUANTE — eau opaque en aplats nets, bleu profond #0758bd, bleu #37c6ff, turquoise #54eadb et écume #e9ffff, avec un contour bleu nuit #062b62. Aucun halo flou, aucune transparence ni goutte détachée.
RÈGLE BLOQUANTE — aucun rose, violet ou reflet magenta sur le personnage. Fond magenta uni uniquement.
Même personne, même tenue et même échelle dans les trois cases ; aucun cadre ni ombre portée.
```

À contrôler : identité du mage conservée, bâton lisible, écharpe transformée sans cacher les jambes, échelle chibi inchangée.

---

## Image 2 — marche

Joindre `assets/peso&cover/refonte/eau_eveil.png`, puis `docs/prompts/mages_animes/guide_complet.png`.

```
Feuille de sprites 2D vue de dessus en légère plongée, cartoon fantasy à contours nets. Image 1 jointe : modèle exact de l'Esprit des Marées, à conserver. Image 2 : guide exact des positions de jambes et de pieds ; ne pas copier sa silhouette grise, son bâton, son sablier, sa robe ni ses couleurs.

FORMAT EXACT : 2048 x 768 pixels, grille 8 colonnes x 3 rangées de cases 256 x 256, fond uni #FF00FF, un personnage entier centré par case, sans débord, texte, grille, ombre, sol ni décor.

Le personnage garde exactement son modèle : jeune mage chibi, robe bleu profond, crête de vague turquoise, rubans d'eau courts derrière lui, bâton-trident dans la main droite. Trois rangées : face avançant vers le bas, dos avançant vers le haut, profil tourné vers la droite.

Dans chaque case, copie exactement la pose des jambes et des pieds du guide. Huit poses cycliques : 1 pied proche devant ; 2 il revient ; 3 passage ; 4 l'autre pied avance ; 5 inverse de 1 ; 6 il revient ; 7 passage ; 8 reprend la pose 1. Les pieds restent sous le corps de face et de dos ; en profil, les jambes alternent avec un pas moyen.

Le bras libre balance franchement en opposition aux jambes. Le bras droit porte le bâton-trident, qui s'incline légèrement en opposition au pas sans quitter sa main. La tête et le tronc restent exactement à la même place et à la même taille dans chaque rangée. Buste droit, marche calme, pas de course.

RÈGLE BLOQUANTE — les rubans d'eau restent courts et ne cachent jamais les pieds ; le bâton reste entièrement dans chaque case. Même taille dans les 24 cases, pieds au même niveau, profil toujours vers la droite. Eau en aplats opaques turquoise et écume, sans flou ni transparence. Aucun rose ou violet dans le personnage ; magenta uni uniquement pour le fond.
```

## Image 3 — attaque

Joindre `assets/peso&cover/refonte/eau_eveil.png`.

```
Feuille de sprites d'attaque pour jeu 2D vu de dessus en légère plongée, cartoon fantasy à contours nets. L'image jointe est le modèle exact : même visage, mêmes vêtements et proportions, même bâton-trident, même crête et rubans d'eau.

FORMAT EXACT : 2048 x 768 pixels, grille régulière de 8 colonnes x 3 rangées de cases 256 x 256, fond uni magenta #FF00FF, personnage centré et entier dans les 24 cases, aucun texte, aucune grille, ombre, sol ou décor.

Rangée 1 face lançant vers le bas ; rangée 2 dos lançant vers le haut ; rangée 3 profil tourné vers la droite. Dans chaque rangée, un seul geste en huit temps : 1 prêt, bâton près du corps ; 2 il arme, une spirale d'eau entoure le cristal ; 3 il plante les pieds et lève le trident ; 4 impact, il pousse le trident droit devant et trois traits d'eau partent en éventail serré ; 5 les traits sont partis, trident tendu ; 6 il le ramène ; 7 pose de récupération ; 8 pose de marche.

Les trois lances restent courtes et près du bâton dans la planche ; le jeu dessine leur déplacement. L'attaque va vers le bas, vers le haut ou vers la droite selon la rangée, jamais de côté pour les vues face et dos. Les pieds ne bougent pas pendant l'attaque. Le corps et la tête restent centrés et de taille identique ; le profil ne se retourne pas.

Eau en formes opaques nettes bleu profond #0758bd, bleu #37c6ff, turquoise #54eadb et écume #e9ffff, contour bleu nuit #062b62. Aucun halo, flou, transparence, rose ou violet. Fond magenta uni uniquement. Aucun autre sort dessiné.
```

## Image 4 — six icônes éveillées

```
Planche de six icônes de compétences de jeu mobile fantasy, cartoon coloré à contours nets. Palette de l'Esprit des Marées : bleu profond #0758bd, bleu #37c6ff, turquoise #54eadb, écume #e9ffff, contour bleu nuit #062b62. Eau en aplats opaques nets ; aucun flou, halo, rose ou violet.

FORMAT EXACT : 1536 x 1024, grille régulière de 3 colonnes x 2 rangées, six cases de 512 x 512, fond uni magenta #FF00FF partout. Une seule icône centrée par case, lisible en petit, aucune bordure, texte, chiffre, ombre ou décor.

Dans l'ordre de lecture :
1. TRIDENT DES MARÉES — trois traits de lance d'eau qui partent en éventail serré d'une pointe de trident.
2. RAZ-DE-MARÉE — un front d'eau large et courbe qui déferle, vu de face.
3. CARAPACE ABYSSALE — une goutte d'eau facettée au centre d'une coque protectrice circulaire.
4. PRISON DU ZÉRO — un cercle de glace vu de dessus, avec un cristal au centre et des fissures en anneau.
5. TORRENT ASCENDANT — une silhouette de mage qui se liquéfie et file dans un courant en diagonale.
6. DÉLUGE PRIMORDIAL — un grand geyser central entouré d'une couronne de pluie et d'ondes concentriques.

Chaque symbole est distinct, bien détouré et tient dans sa case avec une marge vide. Aucun personnage supplémentaire, aucun élément de feu, aucun reflet rose ou violet.
```

---
