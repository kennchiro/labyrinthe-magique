# Le héros principal — plan complet

> Statut : concept et transformation **validés** par le joueur le 2026-11-03, avec sa planche de concept
> `assets/peso&cover/refonte/ael_concept.png`. Prompts : [heros_ael](prompts/mages/heros_ael.md).
> L'Apprenti est jouable depuis le 2026-11-03 : premier onglet de la sélection, personnage par défaut, élément Prisme
> (sans trait). Depuis le 2026-11-04 : XP sauvegardée, niveaux, quatre jeux de compétences, animations des
> trois évolutions, transformation et icônes raccordés au jeu. Son portrait est en place.
> L’équilibrage a une première passe rapide ; la campagne complète et l’essai sur téléphone restent à valider.
>
> Implémentation et vérifications : [AEL_IMPLEMENTATION](AEL_IMPLEMENTATION.md).

## 1. Qui il est

**Aël, l'Enfant sans élément** (nom provisoire).

Tous les autres personnages ont un élément dès le départ. Lui n'en a aucun : c'est un jeune apprenti humain,
chibi comme les mages, qui ne porte qu'une épée courte et un éclat de gemme terne pendu au cou. Son don est
rare : **il absorbe la lumière des gemmes et la force des ennemis qu'il abat**. C'est ce qui le fait évoluer.

Ce choix colle au jeu : l'objectif de chaque niveau est déjà de ramasser des gemmes. Pour lui, ce n'est plus
seulement une clé de porte, c'est ce qui le nourrit.

Élément : un nouvel élément **Prisme** (blanc, cyan, or). ⚠️ Aucun rose ni violet, le fond des planches est
magenta et le détourage les mangerait (même règle que la Démone de la Discorde).

## 2. Les quatre formes

| Forme | Comment | Ce qui change à l'image |
|---|---|---|
| **0. Apprenti** | au départ, niveau 1 | cheveux noirs en épis, tunique de voyage, écharpe, épée courte, éclat de gemme éteint |
| **1. Éveillé** | **niveau 10**, définitif | la gemme s'allume sur sa poitrine, mèches blanches, gantelet de cristal, lame de cristal |
| **2. Ascendant** | **niveau 20**, définitif | épaulières et brassards de cristal, courte cape, cheveux argentés, yeux qui brillent |
| **3. Prisme** (finale) | **niveau 30** débloque, puis **en combat seulement**, et il redevient normal | cheveux dressés blanc-or lumineux, aura prismatique, éclats de cristal qui flottent autour, lame de pure lumière |

Les évolutions 1 et 2 sont des paliers définitifs, comme une croissance. La forme finale est une
**transformation** : elle se déclenche pendant un combat, dure un temps, et il revient à sa forme Ascendant.

### Les caractéristiques

| Forme | PV de base | Vitesse | Extra Power | Dégâts |
|---|---|---|---|---|
| Apprenti | 3 | 5,0 | 5 kills | base |
| Éveillé | 4 | 5,2 | 5 kills | +25 % |
| Ascendant | 4 + 1 plaque | 5,4 | 6 kills : la **transformation** une fois le niveau 30 atteint | +50 % |
| Prisme | garde ses PV, + 1 plaque d'aura | 6,0 | — | +100 % |

Entre deux formes, chaque niveau ajoute **+2 % de dégâts**. Une plaque (`Health.plates`, déjà utilisée par
l'Archange d'Acier) encaisse un coup entier avant les PV.

## 3. Les compétences de chaque forme

Chaque forme a son propre jeu de six boutons, comme un personnage à part entière. Les noms changent, les
gestes montent en puissance. Presque tout réutilise des formes de sorts qui existent déjà (`Ability.Kind`),
ce qui réduit le code ; les nouveautés sont signalées.

| Bouton | Apprenti | Éveillé | Ascendant | Prisme (finale) |
|---|---|---|---|---|
| **Attaque** | Coup d'épée, en arc devant lui (`BLAST`) | Lame d'éclat : coup + petite onde de 3 cases | Double coup, deux charges | Rafale de lumière, tir très rapide (`PROJECTILE`) |
| **Sort 1** | Tranche-vent : une lame d'air en croissant (`PROJECTILE`) | Gerbe de gemmes, en éventail, qui revient (`BLADES`) | Pluie d'éclats autour de lui (`STARFALL`) | **Comète** : il fonce sur un ennemi et explose à l'arrivée (*nouveau*) |
| **Sort 2** | Parade : intouchable 1,5 s, immobile, rend chaque coup paré (`SHIELD` + `reflect_damage`) | Prisme gardien : bouclier qui renvoie les coups (`SHIELD` + `reflect_damage`) | Cristal sentinelle, qui tire seul (`TURRET`) | Barrière d'aura (`SHIELD`) |
| **Sort 3** | Ruée : il fonce de 4 cases et frappe en chemin (`BLINK` + `trail_damage`) | Frappe éclair : un trait qui court dans le couloir (`LINE`) | Onde prismatique, qui saute d'ennemi en ennemi (`CHAIN`) | Éclats en orbite, qui frappent seuls autour de lui (`STORM`) |
| **Fuite** | Roulade, 3 cases (`BLINK`) | Pas de lumière, 5 cases (`BLINK`) | Ailes de lumière : franchit une haie (`BLINK`) | Transmission : réapparaît derrière l'ennemi le plus proche (*nouveau*) |
| **Extra** | Éveil de l'éclat : un grand cercle de lame, la gemme s'allume (`BLAST`) | Rayon de gemme (`BEAM`) | Nova prismatique (la Transformation a son bouton) | **Prisme ultime** : déflagration de 7 cases à travers les haies, sans viser (`BLAST`) |

L'Apprenti est un **épéiste sans magie** (corrigé le 2026-11-04, à la demande du joueur) : chaque sort est un geste
d'épée, simple, et aucun n'emprunte le visuel d'un autre (sa Ruée était une vague, elle se lisait comme celle de
l'Eau). Seul l'Extra laisse voir la gemme s'éveiller. Ses effets : `FlyingCrescent`, `BladeStreak`, `GuardFlash`,
`SlashArc.setup_ring`, à voir avec `tools/preview_ael.gd`.

Son déplacement et son attaque sont **ceux du Héros d'essai**, validés par le joueur : course de face et de dos,
marche des mages de profil, et toute l'animation que le jeu calcule à 60 images par seconde (`MotionProfile`) :
rebond, écrasement, poussière, à-coups, rythme inégal du coup, poussée et arc de lame (`SlashArc`). Les planches ne
portent que 8 poses par mouvement. Le Démon, lui, a gardé la marche des mages : c'est sur lui que ce rebond a déplu.

### Les effets de chaque sort (2026-11-04)

⚠️ **Aucun effet partagé**, à la demande du joueur : ni avec un autre personnage (la téléportation commune,
l'éclat d'impact générique, la vague de l'Eau, la foudre, le nuage d'orage...), ni entre deux de ses propres
sorts. Les effets sont dans la section « Aël » de `level.gd` ; `tools/preview_ael.gd` les montre tous.

| Bouton | Apprenti (acier) | Éveillé (cristal cyan) | Ascendant (cristal bleu et or) | Prisme (lumière d'or) |
|---|---|---|---|---|
| Attaque | arc de lame | arc cyan, puis trois éclats taillés au ras du sol | deux arcs qui se croisent en X | dard de lumière |
| Sort 1 | lame d'air en croissant | gemmes qui tournoient et reviennent | éclats qui tombent du ciel et se brisent | comète, tête blanche et queue d'or, qui éclate en étoile |
| Sort 2 | garde : deux lames en croix | six plaques de cristal en hexagone | obélisque sentinelle qui tire un trait de lumière | sphère de lumière d'or à méridiens |
| Sort 3 | ruée à silhouettes | aiguilles de cristal qui jaillissent du sol | lumière réfractée d'ennemi en ennemi | épées de lumière en orbite, qui partent frapper |
| Fuite | roulade du corps | grains de lumière et empreintes | ailes de cristal au départ et à l'arrivée | colonne d'étincelles qui l'efface et le reforme |
| Extra | grand cercle de lame, la gemme s'allume | rayon de gemme à facettes | couronne de lances de cristal | explosion de lasers en rubans, droit sur chaque ennemi, sans viser (`PrismNova`) |

L'évolution : une colonne de lumière, trois ondes, des rayons, des éclats qui montent (`AscensionBurst`). Quand le
Prisme se dissipe, la lumière retombe en éclats.

### La démo

L'onglet Héros a **une carte par forme** (`CharacterCatalog.AEL_FORMS`). DÉMO lance Aël au niveau qui ouvre la forme,
et la carte du Prisme déclenche la transformation dès l'arrivée. JOUER part avec le niveau acquis : il est grisé
sur une forme pas encore atteinte, et toujours sur le Prisme, qui se prend en combat. `tests/test_hero_cards.gd`.

## 4. La transformation finale

> ⚠️ **Mise à jour du 2026-11-04 : la Transformation a son BOUTON DÉDIÉ**, à la demande du joueur. C'est
> `TransformButton`, à droite de la barre du mage, visible dès le niveau 30 (touche T au clavier). Il a sa
> propre charge, 6 kills depuis la dernière transformation (`HeroRuntime.TRANSFORM_KILLS`), gratuite en démo.
> L'Extra de l'Ascendant reste sa Nova. Ce qui suit sur « la place de l'Extra » ne vaut plus.

**Pas de septième bouton.** Le pad tactile est déjà calculé pour six, et ses tests le vérifient. La
transformation prend la place de l'Extra Power de la forme Ascendant, et se charge de la même façon (kills
et potions, `KillSystem`).

1. **Déclenchement** : jauge pleine, il appuie sur EXTRA. Pendant 0,8 s il est intouchable, une onde repousse
   et étourdit tout ce qui est à 2 cases, puis il apparaît en Prisme.
2. **Durée** : sa jauge d'éveil part de 20 s et se vide. Chaque kill rend 2 s (plafond 30 s), chaque coup
   reçu en retire 3.
3. **Retour à la normale**, de deux façons :
   - la jauge est vide ;
   - ~~il lance le Prisme ultime~~ : retiré le 2026-11-04, le joueur ne comprenait pas que son Extra le
     détransforme. Le Prisme ultime se lance et la forme continue ;
   - il tombe à 1 PV : la forme se brise pour le protéger, comme une dernière plaque.
4. **Épuisement** : en revenant, il est ralenti 3 s, et l'Extra repart de zéro. Il faut regagner des kills
   pour se transformer à nouveau.
5. **Ce qui ne change pas** : ses PV restent les mêmes avant et après. Les recharges des sorts qui ont le même
   identifiant se conservent, les autres repartent prêtes.

## 5. L'expérience et les niveaux

### Ce qui rapporte

| Source | XP |
|---|---|
| Un ennemi abattu | 10 × sa force par rapport au spectre (`Bestiary`, l'unité de l'équilibrage) |
| Un boss abattu | 150 |
| Une gemme ramassée | 5 |
| Un épisode gagné | 50, et 25 de plus la première fois |

L'XP gagnée en combat est **gardée même en cas de défaite**, seule la prime de victoire est perdue. Rejouer
un niveau perdu ne doit pas donner l'impression de tout recommencer.

### La courbe

Passer du niveau N au niveau N+1 coûte **60 + 8 × N** XP, du niveau 1 au niveau 30.

| Palier | XP totale | Moment visé dans la campagne |
|---|---|---|
| Niveau 10, Éveillé | 900 | fin du chapitre 3 |
| Niveau 20, Ascendant | 2 660 | fin du chapitre 6 |
| Niveau 30, Prisme | 5 220 | chapitre 9, avant le dernier |

⚠️ **Ces chiffres sont une estimation** : le nombre de kills par épisode n'a jamais été mesuré.
`test_balance` le mesurera, et la courbe se recalera dessus (étape 6).

### Pendant le combat

- Chaque kill affiche « +12 XP » au-dessus de l'ennemi, et une fine barre d'XP s'ajoute à la barre du mage.
- **Monter de niveau en plein combat** : éclair, « NIVEAU 11 ! », et +1 PV soigné.
- **Évoluer en plein combat** (niveaux 10 et 20) : une pause de 1,5 s, intouchable, et il change de forme
  sous les yeux du joueur. C'est le même mécanisme que la transformation, donc rien à écrire deux fois.

## 6. Comment ça se range dans le code

Les règles du projet sont tenues : la logique ne connaît pas le moteur de scène, et la simulation
d'équilibrage exécute le vrai code.

| Pièce | Rôle |
|---|---|
| `HeroProgress` (RefCounted) | XP, niveau et formes acquises, dans `user://hero.cfg`. Comme `Progress`, n'écrit **que** depuis une sauvegarde chargée. |
| `HeroCatalog` | les quatre formes, chacune une `CharacterStats` complète. Ajouter une forme = une fabrique. |
| `Transformation` (RefCounted) | l'état (normal, en transformation, Prisme, épuisé), la jauge, les trois retours. |
| `CombatSystem.change_form()` | remplace ses compétences en gardant PV et recharges : les recharges sont déjà rangées par identifiant de sort. |
| `Player`, `UIManager`, `Level` | `set_character()` existe déjà dans les trois : il suffit de l'appeler au changement de forme. |
| Aura, onde, cheveux lumineux | au shader et non en images, comme les sorts peints. |

Outils de développement : `--hero-level N`, `--hero-form N`, `--transform`, pour capturer chaque état.

Tests : `test_hero_progress` (courbe, sauvegarde jamais écrite par un test), `test_transformation` (jauge,
trois retours, PV gardés), et `test_balance` qui joue chaque chapitre avec la forme et le niveau attendus.

## 7. Les images à commander

Par forme : la fiche de modèle (`refonte/`), le portrait de sélection, la planche de marche, la planche
d'attaque. Soit **16 images**, plus les icônes de sorts.

- Les planches de déplacement se commandent **entières**, avec `template/guide_heros.png` : la course du Héros
  d'essai de face et de dos, la marche du Chronomancien de profil, et la même taille de tête partout (rapport
  visé 0,95 à 1,05).
- Les quatre formes partent de la **même fiche de modèle** : même visage, même taille, seuls les cheveux, la
  tenue et la lumière changent. Sinon il changerait de corps en se transformant.

## 8. L'ordre de travail

1. **Valider le concept** : nom, allure, les quatre formes.
2. **Les quatre fiches de modèle**, pour juger l'évolution d'un coup d'œil, côte à côte.
3. **L'Apprenti jouable**, avec l'XP, les niveaux et la barre d'XP.
4. **L'Éveillé et l'Ascendant**, et l'évolution en plein combat.
5. **La transformation finale** et son retour à la normale.
6. **L'équilibrage** : mesurer les kills par épisode, recaler la courbe, vérifier chaque chapitre avec la
   forme attendue.
7. **L'essai sur téléphone**.

## 9. Le Dragon d'or, au niveau 80 (en jeu depuis le 2026-11-05)

Demandé par le joueur : au bout de la progression, Aël devient un dragon humanoïde épique, aux couleurs du Prisme.
Fiche, sorts et prompts : [ael_dragon](prompts/mages/ael_dragon.md).

- **Le niveau maximal passe de 30 à 80.** Entre 30 et 80, chaque niveau garde ses +2 % de dégâts ; la courbe d'XP
  est à prolonger (`HeroProgress`), et à mesurer comme le reste.
- **C'est une seconde transformation**, comme le second palier d'un Super Saiyan : en Prisme, le bouton de la
  Transformation se recharge (8 kills) et un second appui l'éveille en Dragon d'or pour 15 s. Il revient ensuite
  à l'Ascendant, épuisé.
- **Ses ailes, la tête de dragon de son Extra, ses flammes** sont dessinées par le jeu, jamais sur les planches.
- ⚠️ La référence montrée par le joueur est un personnage protégé (*Guilty Gear Xrd*) : elle n'est jamais jointe au
  générateur ni déposée dans le dépôt public.
- **En jeu :** `Transformation.State.DRAGON` (et `DRAGON_CHARGING`), `HeroRuntime.DRAGON_KILLS`, la forme 4 de
  `HeroCatalog`, une cinquième carte dans l'onglet Héros. Ses effets : `ClawRake`, `DragonBreath`, `DragonRoar`,
  `DragonAura`, `GuardFlash.Style.SCALES`, `BladeStreak.Style.DIVE` et `SOAR`. Il rôde : `guide_dragon.png`.
- ⚠️ De profil, ses pattes bougent peu derrière sa lame : l'outil de découpe le signale, il peut glisser un peu.

### Le sort 2 déplace Aël dans toutes ses formes (2026-11-06)

À la demande du joueur, le sort 2 est une charge qui frappe ce qu'elle traverse, dans chaque forme : la Ruée
de l'Apprenti (silhouettes), la Percée de cristal de l'Éveillé (aiguilles de cristal le long du trajet), la Fente
prismatique de l'Ascendant (deux traits de lumière réfractée), les Lames filantes du Prisme (une volée de lames qui
le précède, à travers les haies), la Chute du Dragon d'or. Elle prend la place de la protection : la Parade de
l'Apprenti et les Écailles du Dragon passent en sort 3 ; le Prisme gardien, le Cristal sentinelle et la Barrière
d'aura ne sont plus dans le jeu de sorts (leurs effets restent dans le code). Les trois nouvelles charges n'ont pas
encore d'icône.

