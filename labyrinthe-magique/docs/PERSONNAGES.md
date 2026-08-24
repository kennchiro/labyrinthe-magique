# Les mages — fiches de référence

> ⚙️ **Fichier GÉNÉRÉ.** Ne pas éditer à la main : `godot --headless --path . --script res://tools/dump_reference.gd`.
> La source est `src/characters/character_catalog.gd` ; corriger un chiffre se fait là-bas, puis on régénère.

8 mages jouables. La barre d'action a toujours la même forme —
attaque, trois sorts, fuite, extra — et c'est ce qui rend les fiches
comparables d'un personnage à l'autre.

## Vue d'ensemble

| Mage | Élément | Vie | Vitesse | Extra à | Trait élémentaire |
|---|---|---:|---:|---:|---|
| **Mage du Feu** | Feu | 3 | 5.0 | 5 kills | **Brûlure** — 30 % de dégâts en plus, étalés sur 1.5 s |
| **Mage de l'Eau** | Eau | 4 | 4.9 | 5 kills | **Trempe** — la cible ralentit de 38 % pendant 2.2 s |
| **Mage de la Terre** | Terre | 5 | 4.5 | 5 kills | **Ébranlement** — la cible s'arrête net 0.7 s (une fois toutes les 3 s) |
| **Sorcier des Ténèbres** | Ténèbres | 3 | 5.1 | 5 kills | **Ponction** — le mage récupère 22 % des dégâts en vie |
| **Mage de la Foudre** | Foudre | 3 | 5.3 | 5 kills | **Arc** — le coup saute à un voisin à 4 cases (50 % des dégâts) |
| **Mage de l'Air** | Air | 4 | 4.9 | 5 kills | **Bourrasque** — la cible est repoussée de 2 cases |
| **Invocateur** | Ténèbres | 3 | 4.9 | 6 kills | **Ponction** — le mage récupère 22 % des dégâts en vie |
| **Sorcier Suprême** | Suprême | 4 | 4.9 | 8 kills | **Écho** — 40 % des dégâts se répètent 0.6 s plus tard |

La **vie** est celle de base : le stage y ajoute son bonus (`LevelConfig.player_health_bonus`, de 0 au stage 1 à +7 au stage 10).
La **vitesse** est en cases par seconde ; celle des poursuivants ne s'en déduit pas — voir la fiche du bestiaire.


---

## Mage du Feu — Feu

> Brûle tout ce qui approche. Dégâts de zone énormes, santé minimale.

`id: fire` · puissance affichée 4/5 · vie 3 · vitesse 5.0 · extra à 5 kills

Trait : **Brûlure** — 30 % de dégâts en plus, étalés sur 1.5 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Trait de flamme** | projectile | 19 dégâts · portée 8 | 0.5 s |
| SKILL 1 | **Boule de feu** | projectile | 42 dégâts · portée 7 | 5.0 s |
| SKILL 2 | **Sol embrasé** | zone | 9 dégâts/s · rayon 2.2 · 5 s | 10.0 s |
| SKILL 3 | **Aura ardente** | zone | 6 dégâts/s · rayon 1.7 · 30 s | 34.0 s |
| FUITE | **Braise fuyante** | translation | saut de 5 cases | 7.0 s |
| EXTRA | **Embrasement** | explosion | 130 dégâts · rayon 5.5 | 1.0 s |

- **Trait de flamme** — Une flèche de feu, rapide et courte.
- **Boule de feu** — Lourde et lente. Il faut s'approcher — mais tout brûle.
- **Sol embrasé** — Une nappe de flammes qui brûle quiconque la traverse.
- **Aura ardente** — Cinq brasiers. Chacun tient 30 s ; ce qui entre est cloué 5 s, puis brûle.
- **Braise fuyante** — Le mage se disperse en braises et se reforme plus loin.
- **Embrasement** — Toute la clairière prend feu d'un coup.

---

## Mage de l'Eau — Eau

> Ralentit, encaisse et se soigne. Le personnage qui pardonne les erreurs.

`id: water` · puissance affichée 3/5 · vie 4 · vitesse 4.9 · extra à 5 kills

Trait : **Trempe** — la cible ralentit de 38 % pendant 2.2 s

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Jet d'eau** | projectile | 14 dégâts · portée 9 | 0.4 s |
| SKILL 1 | **Vague** | explosion | 24 dégâts · rayon 3.0 | 7.0 s |
| SKILL 2 | **Bouclier d'eau** | bouclier | absorbe 45 · 8 s | 12.0 s |
| SKILL 3 | **Cercle glacé** | zone | 6 dégâts/s · rayon 3.0 · 6 s | 10.0 s |
| FUITE | **Courant** | translation | saut de 6 cases | 7.0 s |
| EXTRA | **Geyser** | explosion | 95 dégâts · rayon 5.0 | 1.0 s |

- **Jet d'eau** — Un trait d'eau sous pression, régulier mais à mi-portée.
- **Vague** — Une lame d'eau qui balaie le couloir devant le mage.
- **Bouclier d'eau** — Une coque liquide qui absorbe les coups avant les points de vie.
- **Cercle glacé** — Une flaque gelée : les ennemis qui la traversent s'englueent.
- **Courant** — Il se liquéfie et file avec le courant.
- **Geyser** — Le sol se fend, l'eau jaillit et le mage se régénère.

---

## Mage de la Terre — Terre

> Le plus résistant. Frappe fort, avance lentement, et peut fermer un couloir.

`id: earth` · puissance affichée 3/5 · vie 5 · vitesse 4.5 · extra à 5 kills

Trait : **Ébranlement** — la cible s'arrête net 0.7 s (une fois toutes les 3 s)

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Rocher** | projectile | 23 dégâts · portée 6 | 0.7 s |
| SKILL 1 | **Pics de terre** | explosion | 30 dégâts · rayon 2.2 | 6.0 s |
| SKILL 2 | **Mur de pierre** | mur | bloque 8 s | 14.0 s |
| SKILL 3 | **Éclats de cristal** | projectile | 14 dégâts · portée 10 | 8.0 s |
| FUITE | **Terrier** | translation | saut de 4 cases | 8.0 s |
| EXTRA | **Séisme** | explosion | 120 dégâts · rayon 5.0 | 1.0 s |

- **Rocher** — Un bloc de pierre lancé à bout de bras. Lent mais lourd.
- **Pics de terre** — Des pointes de roche jaillissent du sol autour du mage.
- **Mur de pierre** — Ferme le couloir derrière soi. Les poursuivants doivent contourner.
- **Éclats de cristal** — Trois éclats partent sur les ennemis les plus proches.
- **Terrier** — Il s'enfonce dans le sol et ressort à couvert.
- **Séisme** — Le labyrinthe tremble et tout ce qui tient debout tombe.

---

## Sorcier des Ténèbres — Ténèbres

> Maître des ombres et des portails. Frappe loin, se déplace vite, mais encaisse mal.

`id: shadow` · puissance affichée 4/5 · vie 3 · vitesse 5.1 · extra à 5 kills

Trait : **Ponction** — le mage récupère 22 % des dégâts en vie

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Orbe d'ombre** | projectile | 16 dégâts · portée 10 | 0.5 s |
| SKILL 1 | **Rune** | zone | 18 dégâts/s · rayon 1.2 · 8 s | 8.0 s |
| SKILL 2 | **Translation** | translation | saut de 4 cases | 9.0 s |
| SKILL 3 | **Explosion d'ombre** | explosion | 34 dégâts · rayon 2.6 | 9.0 s |
| FUITE | **Pas de l'ombre** | translation | saut de 6 cases | 6.5 s |
| EXTRA | **Faille des ténèbres** | explosion | 110 dégâts · rayon 6.0 | 1.0 s |

- **Orbe d'ombre** — Une bille d'ombre qui remonte les couloirs jusqu'à sa cible.
- **Rune** — Piège posé au sol : le premier ennemi qui passe dessus explose.
- **Translation** — Saut instantané de quelques cases dans la direction regardée.
- **Explosion d'ombre** — Détonation autour du mage, elle repousse et blesse.
- **Pas de l'ombre** — Il se fond dans l'ombre et reparaît plus loin.
- **Faille des ténèbres** — Le labyrinthe se déchire : tout ce qui est proche est pulvérisé.

---

## Mage de la Foudre — Foudre

> Le plus rapide du royaume. Frappe vite et souvent, mais tombe au premier faux pas.

`id: thunder` · puissance affichée 4/5 · vie 3 · vitesse 5.3 · extra à 5 kills

Trait : **Arc** — le coup saute à un voisin à 4 cases (50 % des dégâts)

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Éclair** | projectile | 10 dégâts · portée 7 | 0.3 s |
| SKILL 1 | **Chaîne d'éclairs** | explosion | 28 dégâts · rayon 3.0 | 7.0 s |
| SKILL 2 | **Fulgurance** | translation | saut de 5 cases | 8.0 s |
| SKILL 3 | **Orage** | zone | 11 dégâts/s · rayon 2.5 · 5 s | 11.0 s |
| FUITE | **Éclair fuyant** | translation | saut de 7 cases | 6.0 s |
| EXTRA | **Jugement céleste** | explosion | 140 dégâts · rayon 5.5 | 1.0 s |

- **Éclair** — Un trait de foudre, presque instantané. Il porte peu et frappe faible.
- **Chaîne d'éclairs** — La foudre saute d'un ennemi à l'autre autour du mage.
- **Fulgurance** — Le mage devient éclair et reparaît cinq cases plus loin.
- **Orage** — Un nuage crépitant qui foudroie ce qui passe dessous.
- **Éclair fuyant** — Il devient foudre le temps d'un battement de cils.
- **Jugement céleste** — Le ciel s'ouvre et la foudre tombe partout à la fois.

---

## Mage de l'Air — Air

> Repousse, ralentit et se protège. Il gagne les combats qu'il refuse de livrer.

`id: air` · puissance affichée 3/5 · vie 4 · vitesse 4.9 · extra à 5 kills

Trait : **Bourrasque** — la cible est repoussée de 2 cases

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Lame de vent** | projectile | 12 dégâts · portée 12 | 0.4 s |
| SKILL 1 | **Tornade** | zone | 13 dégâts/s · rayon 2.4 · 4 s | 8.0 s |
| SKILL 2 | **Bourrasque** | explosion | 23 dégâts · rayon 3.2 | 7.0 s |
| SKILL 3 | **Voile d'air** | bouclier | absorbe 38 · 7 s | 11.0 s |
| FUITE | **Rafale** | translation | saut de 7 cases | 6.5 s |
| EXTRA | **Cyclone** | explosion | 115 dégâts · rayon 6.5 | 1.0 s |

- **Lame de vent** — Une lame d'air comprimé, la plus longue portée du royaume.
- **Tornade** — Une colonne d'air qui malmène tout ce qu'elle touche.
- **Bourrasque** — Un souffle qui balaie le couloir autour du mage.
- **Voile d'air** — Une bulle de vent qui dévie les coups.
- **Rafale** — Une bourrasque l'emporte hors de portée.
- **Cyclone** — Le labyrinthe entier est aspiré dans une spirale.

---

## Invocateur — Ténèbres

> Ne combat pas : il invoque. Ses créatures chassent 2 minutes pendant qu'il court aux gemmes.

`id: invocateur` · puissance affichée 3/5 · vie 3 · vitesse 4.9 · extra à 6 kills

Trait : **Ponction** — le mage récupère 22 % des dégâts en vie

| Créneau | Sort | Forme | Effet | Recharge |
|---|---|---|---|---:|
| ATTAQUE | **Trait occulte** | projectile | 12 dégâts · portée 9 | 0.5 s |
| SKILL 1 | **Diablotins** | invocation (imp) | 2 créatures · 120 s | 18.0 s |
| SKILL 2 | **Gargouille** | invocation (gargouille) | 1 créature · 120 s | 22.0 s |
| SKILL 3 | **Cercle d'invocation** | zone | 10 dégâts/s · rayon 1.8 · 6 s | 10.0 s |
| FUITE | **Pas du néant** | translation | saut de 4 cases | 8.0 s |
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
| ATTAQUE | **Trait élémentaire** | projectile | 20 dégâts · portée 8 | 0.5 s |
| SKILL 1 | **Vapeur brûlante** | zone | 11 dégâts/s · rayon 2.8 · 5 s | 9.0 s |
| SKILL 2 | **Coulée de magma** | zone | 14 dégâts/s · rayon 2.2 · 6 s | 11.0 s |
| SKILL 3 | **Renaissance** | soin | rend 2 PV | 16.0 s |
| FUITE | **Glissement** | translation | saut de 6 cases | 6.5 s |
| EXTRA | **Prisme des quatre** | explosion | 180 dégâts · rayon 7.0 | 1.0 s |

- **Trait élémentaire** — Un trait qui change d'élément à chaque tir.
- **Vapeur brûlante** — Feu et eau mêlés : une nuée qui aveugle et brûle.
- **Coulée de magma** — Feu et terre : la roche fond et coule dans le couloir.
- **Renaissance** — Eau et terre : la nature repousse et referme les blessures.
- **Glissement** — Les quatre éléments le déplacent d'un souffle.
- **Prisme des quatre** — Les quatre éléments se rejoignent en un seul trait de lumière.