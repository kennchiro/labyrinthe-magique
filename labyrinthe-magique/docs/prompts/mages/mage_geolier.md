# Le Geôlier — fiche et modèle du personnage

> Élément **Flamme froide** · teinte du jeu `#16e0e8` · armure noire vide, flamme cyan. Onglet **Démon**.
> Une armure sans visage, habitée par une flamme froide. Il flotte, enchaîne ses ennemis et traverse les haies.

**Il est jouable.** Les six images sont livrées ; pour en regénérer une, garder cet ordre : la première sert de modèle aux autres.
La référence visuelle voulue par le joueur est `docs/prompts/ref/geolier_concept.png`.

| # | Image | Prompt | À déposer dans `assets/peso&cover/` | À joindre |
|---|---|---|---|---|
| 1 | Le modèle | ci-dessous | `refonte/geolier.png` (remplace le robot rejeté) | `ref/geolier_concept.png` |
| 2 | Le vol | [mages_animes/geolier](../mages_animes/geolier.md), prompt 1 | `mages/geolier_marche.png` (remplace l'ancienne) | `refonte/geolier.png` |
| 3 | L'attaque | [mages_animes/geolier](../mages_animes/geolier.md), prompt 2 | `mages/geolier_attaque.png` | `refonte/geolier.png` |
| 4 | Les pièces | [sorts/pieces_geolier](../sorts/pieces_geolier.md) | `sorts/geolier_pieces.png` | `refonte/geolier.png` |
| 5 | Les six icônes | [sorts/icones_geolier](../sorts/icones_geolier.md) | `sorts/mage_geolier_skills.png` | aucune |
| 6 | Le portrait du menu | [menu/portrait_geolier](../menu/portrait_geolier.md) | `interface/portraits/portrait_geolier.png` | `ref_carte.png`, `portrait_fire.png`, `ref/geolier_concept.png` |

⚠️ Les anciennes `refonte/geolier.png` et `mages/geolier_marche.png` montrent le petit robot rejeté le 2026-11-03 :
les nouvelles prennent leur place, sous le même nom.

## Identité visuelle

⚠️ **Il n'est PAS chibi**, à la demande du joueur : il garde la morphologie de la référence, grande et massive, et non
celle des mages. Le jeu le met à la même hauteur que les autres (`body_height`) ; c'est sa silhouette qui change.

Une armure d'obsidienne noire, VIDE, sans visage, habitée par une flamme froide cyan qui sort des yeux, du col et des
jointures. **Il n'a pas de jambes** : le bas de son corps se défait en flamme, et il flotte. Ses gantelets sont séparés
de ses bras par un vide de flamme, comme sur la référence.

- **Pas de pas à dessiner** : la planche de marche ne montre qu'une flamme qui ondule et un léger flottement. C'est la
  planche qui a posé le plus de problèmes aux autres héros (glissement, jambe répétée).
- **Les flammes sont peintes en aplats nets et OPAQUES**, sans halo : un halo translucide sur fond magenta se détoure mal
  et laisse une frange rose.
- Le noir et le cyan passent `demagenta` sans changer d'une seule valeur (mesuré) : `#14181f`, `#2a3640`, `#8fb8c0`,
  `#16e0e8`, `#e6fdff`, `#0a6f7a`. Jamais de `despilled`, qui repeint ce qui a plus de bleu que de vert.
- ⚠️ Le cyan est voisin du turquoise du Chronomancien (`#2fd6b8`) et poussé vers le bleu pour s'en écarter. Ce sont
  l'armure noire et les chaînes qui les distinguent.

## Ce qui est programmé

Tout est dans `CombatSystem` (section Geôlier) : la simulation d'équilibrage voit les mêmes règles.

- **L'entrave** (`_shackle_hits`) passe par l'étourdissement. Le **Souffle** est un `Kind.BLAST` avec `stun_seconds`.
- **Le Crochet** (`Kind.HOOK`) ramène l'ennemi à une case de lui, sur son propre chemin : jamais de l'autre côté d'une haie.
- **Les Chaînes** (`Kind.SOUL_CHAINS`) et **la Geôle** (`Kind.GAOL`) rongent au rythme des zones. `GaolerChains` dessine
  les chaînes maillon par maillon. La **Traversée** est un `BLINK` avec `pierces_walls`.
- Ses planches sont en cases hautes (1774 x 887) : `build_enemies.py` les ramène en cases carrées (`tall_cells`).
- `tools/preview_geolier.gd` montre ses effets, `tools/build_geolier_pieces.py` découpe ses pièces.

## L'idée

Le Roi de Braise enferme dans des cages. Le Geôlier **enchaîne** : il attrape, retient et ramène. C'est aussi le seul
héros qui **traverse une haie**, une fois par recharge.

## Ses six sorts

Passe rapide seulement (4 parties, un niveau sur 4) : le bot expert gagne partout, sans aucune mort. Il est peut-être un
peu fort. Ses 5 PV (et l'extra à 6 kills) viennent du test d'équilibre : à 4 PV, sept héros le dominaient.

| créneau | sort | ce qu'il fait | chiffres de départ |
|---|---|---|---|
| Base | | 5 PV, vitesse 4,8, extra à 6 kills | |
| ATTAQUE | **Poing spectral** | un gantelet de flamme froide file et frappe. Au troisième coup sur le même ennemi, il l'**enchaîne** au sol | 16 dégâts, portée 6, 0,6 s · enchaîné 1,5 s |
| SKILL 1 | **Crochet** | une chaîne attrape l'ennemi le plus éloigné à portée et le ramène devant lui, sonné | portée 8, 20 dégâts, sonné 1 s, recharge 9 s |
| SKILL 2 | **Chaînes d'âmes** | des chaînes le relient à 3 ennemis : ils sont ralentis et brûlent de froid tant qu'elles tiennent | portée 6, 6 s, ralentis de 50 %, 12 dégâts/s, recharge 13 s |
| SKILL 3 | **Souffle glacé** | une nova de flamme froide autour de lui fige les ennemis touchés | 30 dégâts, rayon 2,5, figés 2 s, recharge 11 s |
| FUITE | **Traversée spectrale** | il devient flamme et passe à travers une seule haie, droit devant | 3 cases au plus, recharge 12 s |
| EXTRA | **La Geôle** | un cercle de flamme froide s'abat autour de lui ; des chaînes sortent du sol et clouent chaque ennemi à l'intérieur | rayon 6, 5 s, 15 dégâts/s |

**Les boss** ne sont ni ramenés par le Crochet ni cloués par la Geôle : ils subissent seulement les dégâts.

## Les effets visuels, sort par sort

Tout sera peint au shader ou tracé (`Line2D`, chaînes) ; seuls le poing, le crochet et les maillons sont dessinés (image 4).

### La palette, commune à tous ses effets

| rôle | couleur | usage |
|---|---|---|
| Le pâle | `#e6fdff` | cœur des flammes, éclairs |
| Le cyan | `#16e0e8` | matière principale : flamme, chaînes chauffées, sceaux |
| Le profond | `#0a6f7a` | creux, dégradé vers le bord |
| Le liseré | `#8fb8c0` | maillons, arêtes du métal |
| L'obsidienne | `#14181f` | cerne, qui tient sur les sols clairs |

Un dessin **net, à plages franches**, un effet qui **se réduit au lieu de s'estomper**, et **ce qui est grand reste sous
lui ou creux au centre**.

### Poing spectral (attaque)

- **Vol :** le gantelet file poing fermé dans une traînée de flamme froide à trois langues.
- **Impact :** un éclat à quatre branches et un anneau de givre. Au troisième coup, une manille de fer claque au sol sous
  l'ennemi et le cloue.

### Crochet

- **Le jet :** le crochet part en tirant sa chaîne, maillon par maillon, en ligne droite.
- **La prise :** il se plante, la chaîne se tend d'un coup et s'illumine.
- **Le retour :** l'ennemi est traîné jusqu'à lui dans une gerbe d'étincelles, et la chaîne se rétracte.

### Chaînes d'âmes, 6 s

- **Le lien :** trois chaînes jaillissent de sa poitrine vers les trois ennemis.
- **La brûlure :** une onde cyan les parcourt à chaque seconde, et leurs proies fument de froid.
- **La fin :** les maillons se brisent un à un.

### Souffle glacé

- **L'inspiration :** la flamme se rétracte dans son armure, qui s'assombrit un instant.
- **La nova :** un anneau de flamme froide déferle, avec des pointes de givre au sol.
- **Le gel :** chaque ennemi touché se couvre d'une gangue de glace, qui éclate au bout de 2 s.

### Traversée spectrale

- **Le départ :** son armure se défait en flamme et passe dans la haie comme un fantôme.
- **L'arrivée :** l'armure se reforme pièce par pièce, dans un anneau de flamme.

### La Geôle (extra), 5 s

- **La chute :** un grand cercle de runes de flamme froide se trace au sol autour de lui, d'un trait.
- **Les chaînes :** une chaîne jaillit du sol sous chaque ennemi et l'enroule ; l'écran tremble à chaque prise.
- **La brûlure :** le cercle bat, et une flamme froide monte des chaînes.
- **La fin :** toutes les chaînes se brisent ensemble dans un éclat de givre.

---

## Image 1 — le modèle du personnage

Joindre `docs/prompts/ref/geolier_concept.png` seule : elle donne l'apparence ET la morphologie. Pas de `chrono.png`,
qui imposerait un corps chibi. À déposer dans `assets/peso&cover/refonte/geolier.png`.

⚠️ **Ne jamais joindre une planche du Seigneur Démon** : elle vient d'un pack sous licence, et le dépôt est public.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.
L'IMAGE JOINTE EST UNE PLANCHE DE CONCEPT : reprends EXACTEMENT le personnage du grand
dessin en haut à gauche, son armure, sa flamme, son allure ET SES PROPORTIONS. Ne reprends
ni le texte, ni les cadres, ni la mise en page de cette planche.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — le Geôlier, une armure d'obsidienne noire (#14181f) aux reflets gris-bleu
(#2a3640), VIDE et habitée par une flamme froide cyan (#16e0e8). Heaume pointu et fermé,
sans visage : deux yeux en fente cyan dans le noir. Épaulières anguleuses, plastron en V
parcouru d'une veine cyan, quelques maillons de chaîne pendus à la taille. La flamme cyan
sort du col, des épaules et des jointures. Ses deux gros gantelets noirs flottent au bout
de ses bras, séparés des avant-bras par un petit vide de flamme. IL N'A PAS DE JAMBES : sous
la taille, son corps se défait en une longue flamme qui s'effile vers le bas, et il flotte.
Les arêtes du métal portent un fin liseré gris-bleu clair (#8fb8c0).

⚠️ RÈGLE BLOQUANTE — LES FLAMMES SONT DES APLATS NETS ET OPAQUES, à contours francs, en
trois tons : cyan pâle (#e6fdff) au cœur, cyan (#16e0e8), cyan profond (#0a6f7a) au bord.
Aucun halo, aucune lueur diffuse, aucune transparence, aucune particule.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE L'IMAGE JOINTE, PAS UN CORPS CHIBI. Une
silhouette grande et massive : heaume petit par rapport au corps, épaules très larges,
torse puissant, énormes gantelets. Sous la taille, une longue flamme occupe environ le
tiers de la hauteur. Jamais de grosse tête ni de corps d'enfant.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA FLAMME S'ARRÊTE SUR UNE MÊME LIGNE dans les trois cases :
c'est là que le jeu posera son ombre. Pas d'anneau ni de cercle sous lui.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Son
noir tire vers le gris-bleu, jamais vers le violet. Aucun emblème rose ou violet.

⚠️ RÈGLE BLOQUANTE — AUCUNE ARME, aucun objet tenu. Pas de cornes, de crâne, d'ailes ni de queue.

⚠️ RÈGLE BLOQUANTE — MÊME armure, mêmes couleurs et mêmes proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Un corps chibi, à grosse tête | Ce n'est pas la morphologie voulue : à regénérer sans attendre |
| Les flammes ont un halo flou | Le détourage laisserait une frange rose autour |
| Des jambes apparaissent | Il marcherait au lieu de flotter, et la planche de vol ne collerait plus |
| Un anneau ou un cercle sous lui | Il serait collé au sprite, et le jeu dessine déjà son ombre |
| Le noir paraît violet | Le détourage le griserait |
