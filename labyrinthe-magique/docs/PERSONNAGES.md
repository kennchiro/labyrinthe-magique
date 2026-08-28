# Les mages — fiches de référence

> ⚙️ **Fichier GÉNÉRÉ.** Ne pas éditer à la main : `godot --headless --path . --script res://tools/dump_reference.gd`.
> La source est `src/characters/character_catalog.gd` ; corriger un chiffre se fait là-bas, puis on régénère.

8 mages jouables. La barre d'action a toujours la même forme —
attaque, trois sorts, fuite, extra — et c'est ce qui rend les fiches
comparables d'un personnage à l'autre.

## Vue d'ensemble

| Mage | Élément | Vie | Vitesse | Extra à | Trait élémentaire |
|---|---|---:|---:|---:|---|
| **Mage du Feu** | Feu | 3 | 5.0 | 4 kills | **Brûlure** — 30 % de dégâts en plus, étalés sur 1.5 s |
| **Mage de l'Eau** | Eau | 4 | 4.9 | 2 kills | **Trempe** — la cible ralentit de 38 % pendant 2.2 s |
| **Mage de la Terre** | Terre | 5 | 4.5 | 6 kills | **Ébranlement** — la cible s'arrête net 0.7 s (une fois toutes les 3 s) |
| **Sorcier des Ténèbres** | Ténèbres | 3 | 5.1 | 4 kills | **Ponction** — le mage récupère 22 % des dégâts en vie |
| **Mage de la Foudre** | Foudre | 3 | 5.3 | 4 kills | **Arc** — le coup saute à un voisin à 4 cases (50 % des dégâts) |
| **Mage de l'Air** | Air | 4 | 4.9 | 5 kills | **Bourrasque** — la cible est repoussée de 2 cases |
| **Invocateur** | Ténèbres | 3 | 4.9 | 6 kills | **Ponction** — le mage récupère 22 % des dégâts en vie |
| **Sorcier Suprême** | Suprême | 4 | 4.9 | 8 kills | **Écho** — 40 % des dégâts se répètent 0.6 s plus tard |

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

Trait : **Ponction** — le mage récupère 22 % des dégâts en vie

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Orbe d'ombre** | projectile | 16 dégâts · portée 10 · recharge 0.5 s | 0.5 s |
| SKILL 1 | **Rune** | zone | 10 dégâts/s · rayon 1.4 · 8 s · 3 charges · recharge 8 s · englue à 18 % tant qu'on y reste | 8.0 s |
| SKILL 2 | **Translation** | translation | saut de 4 cases · recharge 9 s | 9.0 s |
| SKILL 3 | **Implosion d'ombre** | explosion | 34 dégâts · rayon 2.6 · recharge 9 s · aspire à 4.6 cases · laisse une ombre 15 s · empoisonne 15 s à 1 PV/s | 9.0 s |
| FUITE | **Pas de l'ombre** | translation | saut de 6 cases · recharge 6.5 s | 6.5 s |
| EXTRA | **Faille des ténèbres** | invocation (ombre) | 3 failles · 2 ombres chacune · 120 s | 1.0 s |

- **Orbe d'ombre** — Une bille d'ombre qui remonte les couloirs jusqu'à sa cible.
- **Rune** — Un passage laissé au sol. Qui marche dessus rampe et perd 10 PV par seconde tant qu'il n'en est pas sorti.
- **Translation** — Saut instantané de quelques cases dans la direction regardée.
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

Trait : **Ponction** — le mage récupère 22 % des dégâts en vie

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
| SKILL 3 | **Renaissance** | soin | rend 2 PV · recharge 16 s | 16.0 s |
| FUITE | **Glissement** | translation | saut de 6 cases · recharge 6.5 s | 6.5 s |
| EXTRA | **Jugement des quatre** | explosion | 150 dégâts · rayon 6 · TRAVERSE LES MURS · 12 météores à 75 dégâts · la terre tremble 1 s · éboulements à 0 dégâts | 1.0 s |

- **Trait élémentaire** — Un trait qui change d'élément à chaque tir.
- **Convergence élémentaire** — Feu, eau, terre et air se fondent en un noyau qui explose à l'impact.
- **Les Quatre Sceaux** — Quatre sceaux se gravent autour de lui : le feu brûle, l'eau ralentit, la terre arrête, l'air balaie.
- **Renaissance** — Eau et terre : la nature repousse et referme les blessures.
- **Glissement** — Les quatre éléments le déplacent d'un souffle.
- **Jugement des quatre** — Le ciel s'ouvre : des météores des quatre éléments tombent sur chaque poursuivant, et la terre tremble.