# Les mages — fiches de référence

> ⚙️ **Fichier GÉNÉRÉ.** Ne pas éditer à la main : `godot --headless --path . --script res://tools/dump_reference.gd`.
> La source est `src/characters/character_catalog.gd` ; corriger un chiffre se fait là-bas, puis on régénère.

16 mages jouables. La barre d'action a toujours la même forme —
attaque, trois sorts, fuite, extra — et c'est ce qui rend les fiches
comparables d'un personnage à l'autre.

## Vue d'ensemble

| Mage | Élément | Vie | Vitesse | Extra à | Trait élémentaire |
|---|---|---:|---:|---:|---|
| **Mage du Feu** | Feu | 3 | 5.0 | 4 kills | **Brûlure** — 30 % de dégâts en plus, étalés sur 1.5 s |
| **Mage de l'Eau** | Eau | 4 | 4.9 | 2 kills | **Trempe** — la cible ralentit de 38 % pendant 2.2 s |
| **Mage de la Terre** | Terre | 5 | 4.5 | 6 kills | **Ébranlement** — la cible s'arrête net 0.7 s (une fois toutes les 3 s) |
| **Sorcier des Ténèbres** | Ténèbres | 3 | 5.1 | 4 kills | **Ponction** — le mage récupère 1 PV, au plus toutes les 10 s |
| **Mage de la Foudre** | Foudre | 3 | 5.3 | 4 kills | **Arc** — le coup saute à un voisin à 4 cases (50 % des dégâts) |
| **Mage de l'Air** | Air | 4 | 4.9 | 5 kills | **Bourrasque** — la cible est repoussée de 2 cases |
| **Invocateur** | Ténèbres | 3 | 4.9 | 6 kills | **Ponction** — le mage récupère 1 PV, au plus toutes les 10 s |
| **Sorcier Suprême** | Suprême | 4 | 4.9 | 8 kills | **Écho** — 40 % des dégâts se répètent 0.6 s plus tard |
| **Chronomancien** | Temps | 4 | 5.0 | 5 kills | **Retard** — la cible ralentit de 40 % pendant 1.4 s |
| **Mage de la Peste** | Poison | 3 | 5.2 | 4 kills | **Venin** — jusqu'à 3 doses, 7 dégâts par seconde chacune pendant 5 s |
| **Porte-Lumière** | Lumière | 4 | 5.0 | 5 kills | **Éblouissement** — la cible perd sa trace 1.2 s, au plus toutes les 5 s |
| **Ange de la Mort** | Mort | 3 | 5.2 | 4 kills | **Sentence** — un ennemi sous 15 % de ses PV après un coup est achevé |
| **Ange des Étoiles** | Étoiles | 4 | 5.1 | 5 kills | **Astre** — au 3e coup sur une cible, ses étoiles explosent pour 26 dégâts |
| **Archange d'Acier** | Acier | 6 | 4.3 | 7 kills | **Plaques** — 3 plaques encaissent chacune un coup à la place des PV ; 2 kills en reforgent une |
| **Démon du Pacte** | Sang | 4 | 5.1 | 5 kills | **Rage** — jusqu'à +50 % de dégâts selon les PV perdus, au maximum à 1 PV |
| **Démone de la Discorde** | Envoûtement | 3 | 5.5 | 4 kills | **Trouble** — au 3e murmure, la cible ralentit de 30 % pendant 4.0 s, et sa possession dure 2.0 s de plus |

La **vie** est celle de base : le stage y ajoute son bonus (`LevelConfig.player_health_bonus`, de 0 au stage 1 à +7 au stage 10).
La **vitesse** est en cases par seconde ; celle des poursuivants ne s'en déduit pas — voir la fiche du bestiaire.


---

## Mage du Feu — Feu

> Brûle tout ce qui approche. Dégâts de zone énormes, santé minimale.

`id: fire` · puissance affichée 4/5 · vie 3 · vitesse 5.0 · extra à 4 kills

Trait : **Brûlure** — 30 % de dégâts en plus, étalés sur 1.5 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Trait de flamme** | projectile | 19 dégâts · portée 8 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Boule de feu** | projectile | 42 dégâts · portée 7 · recharge 5 s | 5.0 s |
| SKILL 2 | **Sol embrasé** | zone | 9 dégâts/s · rayon 2.2 · 5 s · recharge 2 s | 2.0 s |
| SKILL 3 | **Aura ardente** | zone | 6 dégâts/s · rayon 1.7 · 30 s · 5 charges · recharge 7 s · cloue 5 s · puis brûle 3 s | 7.0 s |
| FUITE | **Braise fuyante** | translation | saut de 5 cases · recharge 7 s | 7.0 s |
| EXTRA | **Embrasement** | explosion | 130 dégâts · rayon 7 · TRAVERSE LES MURS · 14 météores à 48 dégâts | 1.0 s |

- **Trait de flamme** — Une flèche de feu, rapide et courte.
- **Boule de feu** — Lourde et lente. Il faut s'approcher — mais tout brûle.
- **Sol embrasé** — Une nappe de flammes qui brûle quiconque la traverse.
- **Aura ardente** — Cinq brasiers. Chacun tient 30 s ; ce qui entre est cloué 5 s, puis brûle.
- **Braise fuyante** — Le mage se disperse en braises et se reforme plus loin.
- **Embrasement** — Le souffle traverse les murs, puis une pluie de météores s'abat.

---

## Mage de l'Eau — Eau

> Ralentit, encaisse et se soigne. Le personnage qui pardonne les erreurs.

`id: water` · puissance affichée 3/5 · vie 4 · vitesse 4.9 · extra à 2 kills

Trait : **Trempe** — la cible ralentit de 38 % pendant 2.2 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Jet d'eau** | projectile | 14 dégâts · portée 9 · recharge 0.4 s | 0.4 s |
| SKILL 1 | **Vague** | vague | 34 dégâts · déferle sur 7 cases · recharge 2 s | 2.0 s |
| SKILL 2 | **Bouclier d'eau** | bouclier | absorbe 45 · 30 s · 2 charges · recharge 5 s | 5.0 s |
| SKILL 3 | **Cercle glacé** | zone | 6 dégâts/s · rayon 3 · 10 s · 3 charges · recharge 8 s · englue 4 s à 35 % | 8.0 s |
| FUITE | **Courant** | translation | saut de 6 cases · recharge 7 s | 7.0 s |
| EXTRA | **Geyser** | explosion | 70 dégâts · rayon 6 · soigne 3 PV · TRAVERSE LES MURS · 9 geysers à 26 dégâts · 30 gouttes à 16 dégâts · +10 dégâts 30 s | 1.0 s |

- **Jet d'eau** — Un trait d'eau sous pression, régulier mais à mi-portée.
- **Vague** — Un mur d'eau qui remonte le couloir et emporte tout sur son passage.
- **Bouclier d'eau** — Une coque liquide qui absorbe les coups avant les points de vie.
- **Cercle glacé** — Une flaque gelée : ce qui la traverse s'englue et rampe.
- **Courant** — Il se liquéfie et file avec le courant.
- **Geyser** — L'eau jaillit, la pluie tombe 30 s — et chaque coup du mage porte +10.

---

## Mage de la Terre — Terre

> Le plus résistant. Frappe fort, avance lentement, et peut fermer un couloir.

`id: earth` · puissance affichée 3/5 · vie 5 · vitesse 4.5 · extra à 6 kills

Trait : **Ébranlement** — la cible s'arrête net 0.7 s (une fois toutes les 3 s)

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Rocher** | projectile | 23 dégâts · portée 6 · recharge 0.7 s | 0.7 s |
| SKILL 1 | **Pics de terre** | ligne | 30 dégâts · ligne de 6 cases · recharge 6 s · englue 1.2 s à 55 % · pics plantés 4 s à 6 dégâts/s | 6.0 s |
| SKILL 2 | **Égide de pierre** | bouclier | INTOUCHABLE 30 s · recharge 60 s | 60.0 s |
| SKILL 3 | **Éclats de cristal** | tourelle | fend le couloir tout seul · 24 dégâts toutes les 2 s · 30 s · portée 7 · autour de lui · recharge 34 s · englue 0.8 s à 60 % | 34.0 s |
| FUITE | **Terrier** | translation | saut de 4 cases · recharge 8 s | 8.0 s |
| EXTRA | **Séisme** | explosion | 110 dégâts · rayon 5 · TRAVERSE LES MURS · la terre tremble 5 s · éboulements à 16 dégâts | 1.0 s |

- **Rocher** — Un bloc de pierre lancé à bout de bras. Lent mais lourd.
- **Pics de terre** — Une gerbe de pierre court dans le couloir et y reste plantée.
- **Égide de pierre** — Une coque de pierre l'enveloppe : plus rien ne peut le toucher.
- **Éclats de cristal** — Un orbe de pierre l'entoure et fend le sol dès qu'une créature approche.
- **Terrier** — Il s'enfonce dans le sol et ressort à couvert.
- **Séisme** — Cinq secondes de tremblement : les parois cèdent et la pierre jaillit.

---

## Sorcier des Ténèbres — Ténèbres

> Maître des ombres et des portails. Frappe loin, se déplace vite, mais encaisse mal.

`id: shadow` · puissance affichée 4/5 · vie 3 · vitesse 5.1 · extra à 4 kills

Trait : **Ponction** — le mage récupère 1 PV, au plus toutes les 10 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Orbe d'ombre** | projectile | 16 dégâts · portée 10 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Rune** | zone | 10 dégâts/s · rayon 1.4 · 8 s · 3 charges · recharge 8 s · englue à 18 % tant qu'on y reste | 8.0 s |
| SKILL 2 | **Passage** | translation | saut de 4 cases · recharge 9 s · TRAVERSE LES MURS | 9.0 s |
| SKILL 3 | **Implosion d'ombre** | explosion | 34 dégâts · rayon 2.6 · recharge 9 s · aspire à 4.6 cases · laisse une ombre 15 s · empoisonne 15 s à 1 PV/s | 9.0 s |
| FUITE | **Pas de l'ombre** | translation | saut de 6 cases · recharge 6.5 s | 6.5 s |
| EXTRA | **Faille des ténèbres** | invocation (ombre) | 3 failles · 2 ombres chacune · 120 s | 1.0 s |

- **Orbe d'ombre** — Une bille d'ombre qui remonte les couloirs jusqu'à sa cible.
- **Rune** — Un passage laissé au sol. Qui marche dessus rampe et perd 10 PV par seconde tant qu'il n'en est pas sorti.
- **Passage** — Il franchit la haie qu'il regarde et reparaît de l'autre côté.
- **Implosion d'ombre** — L'ombre inspire : elle arrache les poursuivants à leur couloir, les rassemble, puis claque — et la flaque qu'elle laisse empoisonne quinze secondes durant.
- **Pas de l'ombre** — Il se fond dans l'ombre et reparaît plus loin.
- **Faille des ténèbres** — Le labyrinthe se déchire près de chaque poursuivant. Deux ombres sortent de chaque faille et les traquent deux minutes durant, à coups de gaz violet.

---

## Mage de la Foudre — Foudre

> Le plus rapide du royaume. Frappe vite et souvent, mais tombe au premier faux pas.

`id: thunder` · puissance affichée 4/5 · vie 3 · vitesse 5.3 · extra à 4 kills

Trait : **Arc** — le coup saute à un voisin à 4 cases (50 % des dégâts)

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Éclair** | projectile | 10 dégâts · portée 7 · recharge 0.3 s | 0.3 s |
| SKILL 1 | **Chaîne d'éclairs** | chaîne | 30 dégâts · 3 relais · portée 7 · recharge 1.8 s | 1.8 s |
| SKILL 2 | **Champ de foudre** | zone | 16 dégâts/s · rayon 2.4 · 8 s · 2 charges · recharge 11 s · cloue 5 s | 11.0 s |
| SKILL 3 | **Orage** | phénomène | 14 dégâts toutes les 2.0 s · 30 s · portée 5 · recharge 34 s | 34.0 s |
| FUITE | **Éclair fuyant** | translation | saut de 7 cases · recharge 6 s | 6.0 s |
| EXTRA | **Jugement céleste** | explosion | 140 dégâts · rayon 6 · TRAVERSE LES MURS · 12 nuages foudroient 15 s | 1.0 s |

- **Éclair** — Un trait de foudre, presque instantané. Il porte peu et frappe faible.
- **Chaîne d'éclairs** — Un arc qui rebondit d'ennemi en ennemi, en s'affaiblissant.
- **Champ de foudre** — Un sol sous tension : ce qui entre est paralysé 5 s et électrocuté.
- **Orage** — Un nuage qui suit le mage et foudroie seul ce qui l'approche.
- **Éclair fuyant** — Il devient foudre le temps d'un battement de cils.
- **Jugement céleste** — Le ciel s'ouvre : douze nuages se forment et foudroient 15 s durant.

---

## Mage de l'Air — Air

> Repousse, ralentit et se protège. Il gagne les combats qu'il refuse de livrer.

`id: air` · puissance affichée 3/5 · vie 4 · vitesse 4.9 · extra à 5 kills

Trait : **Bourrasque** — la cible est repoussée de 2 cases

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Lame de vent** | projectile | 12 dégâts · portée 12 · recharge 0.4 s | 0.4 s |
| SKILL 1 | **Tornade** | zone | 10 dégâts/s · rayon 1.4 · 4 s · recharge 10 s · remonte 7 cases · EMPORTE ce qu'elle attrape | 10.0 s |
| SKILL 2 | **Grand souffle** | explosion | 18 dégâts · rayon 3 · recharge 7 s · projette de 4 cases · +14 contre un mur | 7.0 s |
| SKILL 3 | **Voile d'air** | bouclier | absorbe 38 · 7 s · recharge 11 s | 11.0 s |
| FUITE | **Rafale** | translation | saut de 7 cases · recharge 6.5 s | 6.5 s |
| EXTRA | **Cyclone** | invocation (cyclone) | 3 créatures · 120 s | 1.0 s |

- **Lame de vent** — Une lame d'air comprimé, la plus longue portée du royaume.
- **Tornade** — Elle remonte le couloir et emporte ce qu'elle attrape.
- **Grand souffle** — Il projette tout autour de lui. Ce qui heurte un mur le paie.
- **Voile d'air** — Une bulle de vent qui dévie les coups.
- **Rafale** — Une bourrasque l'emporte hors de portée.
- **Cyclone** — Trois colonnes de vent et de foudre se lèvent et partent chasser. Elles vont droit sur les poursuivants, haies comprises, deux minutes durant.

---

## Invocateur — Ténèbres

> Ne combat pas : il invoque. Ses créatures chassent 2 minutes pendant qu'il court aux gemmes.

`id: invocateur` · puissance affichée 3/5 · vie 3 · vitesse 4.9 · extra à 6 kills

Trait : **Ponction** — le mage récupère 1 PV, au plus toutes les 10 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Trait occulte** | projectile | 12 dégâts · portée 9 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Diablotins** | invocation (imp) | 2 créatures · 30 s · recharge 18 s | 18.0 s |
| SKILL 2 | **Gargouille** | invocation (gargouille) | 1 créature · 40 s · recharge 22 s | 22.0 s |
| SKILL 3 | **Cercle d'invocation** | zone | 10 dégâts/s · rayon 1.8 · 6 s · recharge 10 s | 10.0 s |
| FUITE | **Pas du néant** | translation | saut de 4 cases · recharge 8 s | 8.0 s |
| EXTRA | **Dragon ancien** | invocation (dragon) | 1 créature · 120 s | 1.0 s |

- **Trait occulte** — Une aiguille d'énergie violette, faible mais rapide.
- **Diablotins** — Deux diablotins surgissent et pourchassent l'ennemi le plus proche.
- **Gargouille** — Une gargouille de pierre, lente mais qui frappe deux fois plus fort.
- **Cercle d'invocation** — Un cercle gravé au sol qui ronge quiconque le traverse.
- **Pas du néant** — Le mage s'efface et reparaît quelques cases plus loin.
- **Dragon ancien** — Le dragon répond à l'appel : il vole par-dessus les haies, droit sur ses proies.

---

## Sorcier Suprême — Suprême

> Maître des quatre éléments. Ses sorts les combinent — mais son ultime se mérite.

`id: supreme` · puissance affichée 5/5 · vie 4 · vitesse 4.9 · extra à 8 kills

Trait : **Écho** — 40 % des dégâts se répètent 0.6 s plus tard

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Trait élémentaire** | projectile | 20 dégâts · portée 8 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Convergence élémentaire** | projectile | 56 dégâts · portée 8 · recharge 11 s | 11.0 s |
| SKILL 2 | **Les Quatre Sceaux** | zone | 9 dégâts/s · rayon 1.1 · 60 s · recharge 12 s | 12.0 s |
| SKILL 3 | **Renaissance** | soin | rend 3 PV · recharge 38 s · +8 dégâts 30 s | 38.0 s |
| FUITE | **Glissement** | translation | saut de 6 cases · recharge 6.5 s | 6.5 s |
| EXTRA | **Jugement des quatre** | explosion | 150 dégâts · rayon 6 · TRAVERSE LES MURS · 12 météores à 75 dégâts · la terre tremble 1 s · éboulements à 0 dégâts | 1.0 s |

- **Trait élémentaire** — Un trait qui change d'élément à chaque tir.
- **Convergence élémentaire** — Feu, eau, terre et air se fondent en un noyau qui explose à l'impact.
- **Les Quatre Sceaux** — Quatre sceaux se gravent autour de lui : le feu brûle, l'eau ralentit, la terre arrête, l'air balaie.
- **Renaissance** — Il renaît des quatre éléments : +8 à chaque coup et 2 coups absorbés pendant 30 s, et ses blessures se referment.
- **Glissement** — Les quatre éléments le déplacent d'un souffle.
- **Jugement des quatre** — Le ciel s'ouvre : des météores des quatre éléments tombent sur chaque poursuivant, et la terre tremble.

---

## Chronomancien — Temps

> Il ne fuit pas : il revient en arrière. Frappe peu, ralentit tout et répare ses erreurs de chemin.

`id: chrono` · puissance affichée 3/5 · vie 4 · vitesse 5.0 · extra à 5 kills

Trait : **Retard** — la cible ralentit de 40 % pendant 1.4 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Aiguille** | projectile | 16 dégâts · portée 8 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Bulle de lenteur** | zone | 12 dégâts/s · rayon 2.6 · 8 s · recharge 12 s · englue à 35 % tant qu'on y reste | 12.0 s |
| SKILL 2 | **Écho** | ? | 60 dégâts · rejoue 5 s de marche · recharge 9 s | 9.0 s |
| SKILL 3 | **Sablier** | ? | rend 50 % des PV perdus en 8 s · recharge 28 s | 28.0 s |
| FUITE | **Retour** | translation | revient 4 s en arrière · recharge 7 s | 7.0 s |
| EXTRA | **Arrêt du temps** | ? | tout se fige 4 s | 1.0 s |

- **Aiguille** — Une aiguille d'horloge qui ralentit un court instant ce qu'elle touche.
- **Bulle de lenteur** — Dans la bulle, ennemis et projectiles vont au ralenti. Lui, non.
- **Écho** — Un double rejoue ses 5 dernières secondes de marche et blesse ce qu'il croise.
- **Sablier** — Pendant 8 s, les coups reçus sont notés. À la fin, il récupère la moitié des points perdus, arrondie au-dessus.
- **Retour** — Il revient là où il était il y a 4 s, sans récupérer de vie.
- **Arrêt du temps** — Pendant 4 s, tout se fige sauf lui.

---

## Mage de la Peste — Poison

> Plus on le poursuit, plus on s'empoisonne. Fragile et rapide : ses doses travaillent pendant qu'il fuit.

`id: peste` · puissance affichée 3/5 · vie 3 · vitesse 5.2 · extra à 4 kills

Trait : **Venin** — jusqu'à 3 doses, 7 dégâts par seconde chacune pendant 5 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Dard venimeux** | projectile | 8 dégâts · portée 8 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Traînée toxique** | ? | flaques 5 s · pendant 6 s · recharge 14 s | 14.0 s |
| SKILL 2 | **Contagion** | ? | passe le poison à 5 cases · portée 8 · recharge 8 s | 8.0 s |
| SKILL 3 | **Transfusion** | ? | 1 PV par 2 ennemis empoisonnés · recharge 22 s | 22.0 s |
| FUITE | **Brume** | translation | saut de 6 cases · recharge 7 s | 7.0 s |
| EXTRA | **Pandémie** | ? | toute la carte empoisonnée 8 s · ils éclatent | 1.0 s |

- **Dard venimeux** — Un trait faible, mais chaque coup ajoute une dose de poison, jusqu'à 3.
- **Traînée toxique** — Pendant 6 s, il laisse du poison sur les cases où il passe.
- **Contagion** — Le poison d'une cible passe aux ennemis proches.
- **Transfusion** — Il reprend de la vie selon le nombre d'ennemis empoisonnés.
- **Brume** — Il se dissout et reparaît plus loin, en laissant un nuage toxique derrière lui.
- **Pandémie** — Tous les ennemis de la carte sont empoisonnés 8 s, et ceux qui en meurent éclatent en nuage toxique.

---

## Porte-Lumière — Lumière

> Sa lumière aveugle : les ennemis perdent sa trace. Bons dégâts en ligne droite, s'il se place bien.

`id: lumiere` · puissance affichée 4/5 · vie 4 · vitesse 5.0 · extra à 5 kills

Trait : **Éblouissement** — la cible perd sa trace 1.2 s, au plus toutes les 5 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Trait d'aube** | projectile | 15 dégâts · portée 9 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Lance solaire** | ? | 55 dégâts · rayon de 14 cases dans les couloirs · recharge 6 s | 6.0 s |
| SKILL 2 | **Sanctuaire** | zone | 14 dégâts/s · rayon 2.4 · 8 s · recharge 16 s | 16.0 s |
| SKILL 3 | **Ailes gardiennes** | bouclier | absorbe 1 · 8 s · recharge 18 s | 18.0 s |
| FUITE | **Envol** | translation | saut de 5 cases · recharge 8 s · TRAVERSE LES MURS | 8.0 s |
| EXTRA | **L'Aube** | ? | 130 dégâts sur toute la carte · aveugle 5 s | 1.0 s |

- **Trait d'aube** — Un trait net. De temps en temps, il aveugle sa cible un instant.
- **Lance solaire** — Un rayon qui suit les couloirs, vire vers les ennemis et touche tout ce qu'il traverse.
- **Sanctuaire** — Un cercle de lumière au sol : ce qui y entre est aveuglé et brûlé.
- **Ailes gardiennes** — Ses ailes absorbent un coup, puis aveuglent ce qui se tient au contact.
- **Envol** — Il survole les haies, et son atterrissage aveugle les ennemis proches.
- **L'Aube** — L'écran s'embrase, et une colonne de lumière tombe sur chaque ennemi de la carte, aveuglé 5 s.

---

## Ange de la Mort — Mort

> Ce qu'il a blessé, il vient le prendre : il achève les ennemis presque morts et récolte leurs âmes. Fragile.

`id: mort` · puissance affichée 4/5 · vie 3 · vitesse 5.2 · extra à 4 kills

Trait : **Sentence** — un ennemi sous 15 % de ses PV après un coup est achevé

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Croissant noir** | projectile | 16 dégâts · portée 7 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Moisson** | explosion | 45 dégâts · rayon 3 · recharge 5 s · balaie 150° devant | 5.0 s |
| SKILL 2 | **Glas** | zone | 6 dégâts/s · rayon 2.6 · 7 s · recharge 15 s | 15.0 s |
| SKILL 3 | **Âmes captives** | ? | 30 dégâts par âme · portée 14 · recharge 9 s | 9.0 s |
| FUITE | **Passage** | translation | saut de 5 cases · recharge 8 s · TRAVERSE LES MURS | 8.0 s |
| EXTRA | **L'Heure dernière** | ? | la moitié des PV de chaque ennemi · achève sous 15 % | 1.0 s |

- **Croissant noir** — La faux lance un croissant de lame qui ne rate jamais.
- **Moisson** — Un grand coup de faux en arc devant lui, qui achève ce qui est déjà blessé.
- **Glas** — Une cloche sonne : les ennemis du cercle sont marqués et prennent plus de dégâts.
- **Âmes captives** — Il lâche une âme et toutes celles de ses victimes : elles chassent dans les couloirs.
- **Passage** — Il se défait en plumes noires et traverse les haies.
- **L'Heure dernière** — Éclipse : une faux géante traverse l'écran, et chaque ennemi perd la moitié de ses PV.

---

## Ange des Étoiles — Étoiles

> Elle pose des étoiles dans le labyrinthe : les rayons qui les relient brûlent ce qui passe. C'est le placement qui fait ses dégâts.

`id: etoiles` · puissance affichée 4/5 · vie 4 · vitesse 5.1 · extra à 5 kills

Trait : **Astre** — au 3e coup sur une cible, ses étoiles explosent pour 26 dégâts

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Éclat stellaire** | projectile | 12 dégâts · portée 8 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Constellation** | ? | 28 dégâts/s · 3 étoiles · 16 s · recharge 3 s | 3.0 s |
| SKILL 2 | **Pluie d'étoiles** | ? | 9 étoiles de 22 dégâts · rayon 3.5 · recharge 11 s | 11.0 s |
| SKILL 3 | **Voile de lune** | bouclier | INTOUCHABLE 3 s · recharge 15 s | 15.0 s |
| FUITE | **Étoile filante** | translation | saut de 5 cases · recharge 8 s | 8.0 s |
| EXTRA | **Nuit éternelle** | ? | 120 dégâts sur toute la carte | 1.0 s |

- **Éclat stellaire** — Un petit trait d'étoile. Au troisième coup, les étoiles de la cible explosent.
- **Constellation** — Pose une étoile à ses pieds. Des rayons les relient par-dessus les haies et brûlent ce qui passe.
- **Pluie d'étoiles** — Des étoiles tombent une à une autour d'elle, sur les ennemis d'abord.
- **Voile de lune** — Pendant un court instant, les coups la traversent.
- **Étoile filante** — Un saut rapide en ligne droite, qui laisse une traînée brûlante.
- **Nuit éternelle** — La nuit tombe sur l'écran, et une comète frappe chaque ennemi de la carte.

---

## Archange d'Acier — Acier

> Lent et massif, il frappe le sol de loin : ses plaques d'armure encaissent les coups, et ses kills les reforgent.

`id: acier` · puissance affichée 4/5 · vie 6 · vitesse 4.3 · extra à 7 kills

Trait : **Plaques** — 3 plaques encaissent chacune un coup à la place des PV ; 2 kills en reforgent une

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Coup de marteau** | projectile | 22 dégâts · portée 6 · recharge 0.7 s | 0.7 s |
| SKILL 1 | **Ailes-lames** | ? | 5 lames · 30 dégâts à l'aller et au retour · portée 5 · recharge 7 s | 7.0 s |
| SKILL 2 | **Onde d'enclume** | ? | 34 dégâts · étourdit 1.5 s · 7 cases de couloirs · recharge 10 s | 10.0 s |
| SKILL 3 | **Rempart** | bouclier | INTOUCHABLE 4 s · immobile · renvoie 40 · recharge 18 s | 18.0 s |
| FUITE | **Charge** | translation | charge de 4 cases · 30 dégâts · renverse · recharge 8 s · projette de 2 cases | 8.0 s |
| EXTRA | **Acier en fusion** | explosion | 70 dégâts · rayon 3.5 · armure en fusion 10 s | 1.0 s |

- **Coup de marteau** — Le marteau frappe le sol : une onde de choc court jusqu'à sa cible et touche ce qui l'entoure.
- **Ailes-lames** — Une volée de lames part en éventail par-dessus les haies, puis revient vers lui et retouche au retour.
- **Onde d'enclume** — Il frappe le sol : l'onde court dans les couloirs et étourdit ce qu'elle touche.
- **Rempart** — Il se referme dans ses ailes : immobile et intouchable, il renvoie les coups reçus.
- **Charge** — Il fonce en ligne droite et renverse ce qu'il croise.
- **Acier en fusion** — Son armure chauffe au rouge : plaques pleines, il grandit, et ses coups plus forts projettent les ennemis.

---

## Démon du Pacte — Sang

> Il a signé avec sa propre vie : moins il lui en reste, plus il frappe fort. Se soigner, ou rester au bord du gouffre ?

`id: demon` · puissance affichée 4/5 · vie 4 · vitesse 5.1 · extra à 5 kills

Trait : **Rage** — jusqu'à +50 % de dégâts selon les PV perdus, au maximum à 1 PV

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Griffe de sang** | projectile | 18 dégâts · portée 7 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Pacte de sang** | ? | coûte 1 PV · jamais le dernier · recharge 12 s · +8 dégâts 6 s | 12.0 s |
| SKILL 2 | **Sillon de soufre** | ligne | 42 dégâts · ligne de 7 cases · recharge 7 s · brûle 3 s à 6/s | 7.0 s |
| SKILL 3 | **Festin** | explosion | 26 dégâts · rayon 2 · recharge 14 s · +1 PV s'il touche | 14.0 s |
| FUITE | **Bond de soufre** | translation | saut de 4 cases · recharge 8 s | 8.0 s |
| EXTRA | **Dernier Pacte** | explosion | 60 dégâts · rayon 4 · 1 PV · INTOUCHABLE 6 s | 1.0 s |

- **Griffe de sang** — D'un geste de la main, trois griffures de sang filent vers leur cible et ne la ratent jamais.
- **Pacte de sang** — Il sacrifie un point de vie pour renforcer tous ses coups. Le pacte ne prend jamais le dernier.
- **Sillon de soufre** — Des flammes de sang courent dans le couloir et y restent.
- **Festin** — Une gueule de sang se referme autour de lui : s'il a touché quelqu'un, il reprend un point de vie.
- **Bond de soufre** — Il disparaît dans une gerbe de sang et reparaît plus loin dans le couloir.
- **Dernier Pacte** — Le sceau éclate : il tombe à 1 PV et devient intouchable, puis récupère les trois quarts de ce qu'il a donné.

---

## Démone de la Discorde — Envoûtement

> Elle tire les fils et laisse les autres se battre. Redoutable dans la foule, bien seule face à un seul ennemi.

`id: discorde` · puissance affichée 3/5 · vie 3 · vitesse 5.5 · extra à 4 kills

Trait : **Trouble** — au 3e murmure, la cible ralentit de 30 % pendant 4.0 s, et sa possession dure 2.0 s de plus

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Murmure** | projectile | 14 dégâts · portée 7 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Mauvais Œil** | ? | possède 1 ennemi · portée 8 · 5 s · 20 par coup · recharge 10 s | 10.0 s |
| SKILL 2 | **Cercle de Discorde** | zone | 16 dégâts/s · +50 % par ennemi en plus · rayon 2.5 · 6 s · recharge 12 s | 12.0 s |
| SKILL 3 | **Lien de Souffrance** | ? | enchaîne 3 ennemis · portée 8 · 50 % des dégâts · 8 s · recharge 14 s | 14.0 s |
| FUITE | **Échange** | ? | échange avec un ennemi · portée 6 · recharge 9 s | 9.0 s |
| EXTRA | **Grande Discorde** | ? | tous les ennemis · 6 s · 22 par coup | 1.0 s |

- **Murmure** — Un fil d'argent file de ses doigts. Au troisième, la cible est troublée.
- **Mauvais Œil** — Un ennemi se retourne contre ses voisins et ne la chasse plus.
- **Cercle de Discorde** — Un cercle se pose sur l'ennemi le plus proche : plus ils y sont nombreux, plus chacun y souffre.
- **Lien de Souffrance** — Une chaîne relie trois ennemis proches : la moitié des coups portés à l'un passe aux deux autres.
- **Échange** — Elle prend la place de l'ennemi le plus proche, et lui laisse la sienne.
- **Grande Discorde** — Tous les ennemis à l'écran se battent entre eux, et leurs morts comptent pour elle. Seuls les boss résistent.