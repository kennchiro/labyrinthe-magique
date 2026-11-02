# Les boss de fin de stage

Un boss par stage, dans l'ordre de la campagne. Chacun tient dans la palette de son
terrain et ne reprend aucune créature du bestiaire.

Ce sont tous des **monstres humanoïdes et massifs**, debout sur deux jambes, qui incarnent
leur nom et ne sont jamais des animaux. Le dessin donne la masse,
le jeu donne la taille : le corps d'un boss fera **60 px** à l'écran, contre 38 pour le
mage et 58 pour le Seigneur Démon, le plus grand ennemi actuel.

Chacun attaque de loin selon sa spécialité, à intervalle régulier. **Avant chacune de ces
attaques, une zone s'allume au sol** : on la voit se remplir, puis clignoter, et on a le
temps de s'écarter. Le coup au contact n'a pas de zone : il se voit au geste du boss.

| Stage | Terrain | Boss | Attaque de loin | Portée | Alerte | Intervalle |
|---:|---|---|---|---|---:|---:|
| 1 | La Forêt | [Le Sylvain Ancien](boss_sylvain.md) | des racines jaillissent des cases marquées au sol | 3 cases marquées autour du mage | 1.6 s | 7.0 s |
| 2 | Le Canyon de la Foudre | [L'Oiseau-Tonnerre](boss_oiseau_tonnerre.md) | la foudre tombe sur une rangée de cases marquée | toute une rangée de 7 cases | 1.5 s | 6.7 s |
| 3 | Les Dunes de Feu | [Le Scorpion des Braises](boss_scorpion.md) | il s'enfouit, ressort sous un tourbillon de sable annoncé | 2 cases autour de l'endroit où il ressort | 1.4 s | 6.3 s |
| 4 | Les Rivages Océaniques | [Le Béhémoth des Abysses](boss_behemoth.md) | une vague balaie un couloir, blesse et repousse le mage | un couloir de 6 cases devant lui | 1.4 s | 6.0 s |
| 5 | Les Cavernes de Cristal | [La Reine de Cristal](boss_araignee.md) | des pointes de cristal sortent des cases marquées | 4 cases marquées autour du mage | 1.3 s | 5.7 s |
| 6 | Les Montagnes Glacées | [Le Roi Yéti](boss_yeti.md) | il frappe le sol, des blocs de glace tombent sur les cases marquées | 4 cases marquées autour du mage | 1.2 s | 5.3 s |
| 7 | Le Bois d'Épine | [La Mère-Ronce](boss_mere_ronce.md) | un mur de ronces jaillit, blesse le mage et ferme le couloir un moment | un couloir de 5 cases | 1.1 s | 5.0 s |
| 8 | Les Ruines Anciennes | [L'Idole Éveillée](boss_idole.md) | elle tourne sur elle-même et projette une onde de jade le long d'un couloir | un couloir de 5 cases devant elle | 1.1 s | 4.7 s |
| 9 | Le Sanctuaire Déchu | [Le Roi Déchu](boss_roi_dechu.md) | un cercle de vide s'ouvre sur les cases marquées, des crânes en sortent | 3 cases marquées autour du mage | 1.0 s | 4.3 s |
| 10 | Le Château du Ciel | [La Chimère d'Or](boss_chimere.md) | une pluie de lames d'or tombe sur les cases marquées | 5 cases marquées autour du mage | 0.9 s | 4.0 s |

## Ce qu'il faut générer

Quatre planches par boss, de 2048 x 768 chacune :

1. **la marche**, en premier. Joindre `docs/prompts/mages_animes/guide_marche.png` si la
   fiche le demande ;
2. **l'attaque**, en joignant la marche livrée ;
3. **la scène** (arrivée, attaque de loin, mort), en joignant aussi la marche livrée ;
4. **la portée** (alerte, coup, fin), sans rien joindre : le monstre n'y apparaît pas.

## Où on en est

Les règles ont changé après la livraison des planches. Trente-quatre sont à refaire :

- **les dix boss, marche + attaque + scène :** les planches livrées ne sont plus bonnes, car
  tous les boss sont maintenant humanoïdes ;
- **portée en bande :** l'Oiseau-Tonnerre, le Béhémoth, la Mère-Ronce, l'Idole.

Les six portées rondes restent bonnes, car le monstre n'y apparaît pas.

## Ce qui n'existe pas encore

Le combat est en jeu, voir `BossFight` et `BossCatalog`. Restent à faire, s'ils sont voulus :
la vague qui repousse, le mur de ronces qui ferme le couloir, les charges du Yéti et de la
Chimère, les ailes qu'elle perd. Les portées et durées de ce tableau restent à régler à
l'essai. Aux stages 3 et 9, le dernier épisode oblige déjà à détruire les repaires : le boss
y vient après ce verrou, ce qui rallonge ces deux fins de stage.

*Fiche produite par `tools/build_prompts_boss.py`.*
