# Aël — intégration du 2026-11-04

## Ce qui fonctionne

- Les six icônes de l’Apprenti et celles des trois évolutions sont découpées dans `assets/icons/`.
  `UiIcons` les cherche par identifiant de compétence. La planche de l’Apprenti a été refaite pour
  Tranche-vent, Parade, Ruée et Éveil de l’éclat, selon la commande complète.
- `HeroProgress` conserve l’XP et les premières victoires dans `user://hero.cfg`. Une instance fabriquée
  pour un test ou une simulation ne sauvegarde jamais. Les commandes de développement et la démo
  ne sauvegardent pas non plus. L’XP de combat survit à une défaite et au retour au menu.
- Les seuils sont 900 XP au niveau 10, 2 660 au niveau 20, 5 220 au niveau 30. Un niveau soigne 1 PV.
  Le HUD montre le niveau et une barre d’XP ; les gains et montées de niveau s’affichent dans le monde.
  La sélection présente chaque forme sur sa carte. Jouer reprend le niveau acquis ; la démo permet
  d’essayer la forme choisie sans sauvegarder. Le Prisme reste une transformation en vraie partie.
- Dans l’arène de démo, le sélecteur donne accès aux quatre formes, et le bouton Évoluer passe au
  palier suivant. Chaque carte démarre au niveau exact annoncé, indépendamment de la sauvegarde.
  L’Extra se recharge au retour du Prisme ; le joueur peut recommencer après les 3 s d’épuisement.
  Les dégâts ne terminent pas la démo et le changement de décor conserve la forme choisie.
- `HeroCatalog` fournit les six compétences de chaque forme. `HeroRuntime` pilote progression,
  évolution et transformation, sans dépendance aux scènes. Les paliers changent la tenue, la vitesse,
  les compétences et les dégâts ; l’Ascendant obtient sa plaque. La pause d’évolution dure 1,5 s.
- Les fiches de modèle et les planches de marche/attaque de l’Éveillé, de l’Ascendant et du Prisme
  sont dans `assets/peso&cover/`. Le même pipeline que l’Apprenti produit quatre directions et 17 poses
  par direction (repos, huit pas, huit poses d’attaque). La gauche reste le miroir du profil droit.
- La transformation se gagne au niveau 30 et occupe le bouton Extra. Charge de 0,8 s, durée de
  20 s, +2 s par kill avec plafond à 30 s, -3 s par coup. Elle s’achève au temps écoulé, par l’ultime
  ou à 1 PV. Le coup fatal est arrêté à 1 PV avant le retour ; la plaque d’aura restante disparaît.
  Le retour conserve les PV et les recharges et impose 3 s de ralentissement. Les cristaux en orbite
  sont animés par le jeu, pas dessinés sur le sprite.
- Comète rejoint une cible et frappe autour de son arrivée. Transmission choisit une case derrière
  l’ennemi. Le Prisme ultime traverse les haies. Une action refusée ne dépense pas l’Extra.

## Vérifications

Les suites `test_hero_progress`, `test_transformation` et `test_hero_game` vérifient la sauvegarde dans
un fichier temporaire, les paliers, les six boutons, les transitions dans une vraie partie, les PV,
les recharges, le bris à 1 PV, l’ultime à travers les haies et les déplacements ciblés.
Elles sont inscrites dans `tools/verifier.sh`.
`test_hero_cards` et `test_hero_demo` parcourent les vraies cartes et l’arène, les quatre paliers,
les reprises de transformation et l’absence d’écriture de progression. `test_hero_skills` déclenche
les 24 compétences sur une cible dans la vraie scène et contrôle leurs icônes.

La simulation `test_balance` utilise également `HeroRuntime` pour Aël. Exemple de passe rapide :

```sh
godot --headless --path . --script res://tests/test_balance.gd -- --quick --mage ael --hero-campaign --sans-viabilite
```

`--hero-campaign` sélectionne les formes attendues aux paliers de campagne : Apprenti avant le
chapitre 4, Éveillé avant le 7, Ascendant ensuite, transformation disponible au chapitre 9.
Il ne s’agit pas d’une mesure continue de l’XP d’un joueur à travers tous les épisodes.

Après correction de la portée et de l’orientation du ciblage de l’épée, la passe complète a terminé
les 20 épisodes, avec 12 graines pour chacun des deux profils : verdict « ÉQUILIBRAGE DANS LES CLOUS ».
Le bot expert termine notamment les deux épisodes du Bois d’Épine à 92 % de victoires, et ceux des
Ruines, du Sanctuaire et du Château à 100 %. L’explorateur reste fréquemment bloqué, ce qui limite
les conclusions sur la difficulté réelle. Les repaires ne sont pas entièrement représentés par cette
simulation. **Le rythme continu de l’XP et le confort sur téléphone demandent encore un essai humain.**
Toutes les suites de `tools/verifier.sh` et le contrôle des planches passent ; le test de réglages
tactiles a été relancé avec l’accès à son fichier temporaire, nécessaire hors du bac à sable.
Les quatre formes en jeu et la planche des 15 effets ont été contrôlées visuellement.
Les portraits des trois évolutions sont générés et raccordés au HUD et à la sélection, via les
JPEG du pipeline ; aucune planche brute n’est chargée directement par la carte.

## Commandes d’essai

```sh
godot --path . -- --demo --character ael --hero-level 10
godot --path . -- --demo --character ael --hero-level 20
godot --path . -- --demo --character ael --hero-level 30 --transform
godot --path . -- --demo --character ael --hero-form 3
```

## Images et prompts

Génération par l’outil intégré imagegen, puis copie dans le projet et découpage par les outils existants.
Les modèles suivent `docs/prompts/mages/heros_ael.md`, avec concept puis modèle de l’Apprenti.
Les animations adaptent les deux prompts de `docs/prompts/mages_animes/ael.md` à la description de
chaque forme, en joignant son modèle et le guide correspondant. Les trois planches initialement sorties
au mauvais rapport ont été régénérées en 2048 × 768 avant découpage.
Les prompts d’icônes des évolutions sont consignés dans
`docs/prompts/sorts/icones_ael_evolutions.md`.

## Planches livrées

- `assets/peso&cover/refonte/ael_eveille.png`
- `assets/peso&cover/refonte/ael_ascendant.png`
- `assets/peso&cover/refonte/ael_prisme.png`
- `assets/peso&cover/mages/ael_eveille_marche.png`
- `assets/peso&cover/mages/ael_eveille_attaque.png`
- `assets/peso&cover/mages/ael_ascendant_marche.png`
- `assets/peso&cover/mages/ael_ascendant_attaque.png`
- `assets/peso&cover/mages/ael_prisme_marche.png`
- `assets/peso&cover/mages/ael_prisme_attaque.png`
- `assets/peso&cover/sorts/mage_ael_eveille_skills.png`
- `assets/peso&cover/sorts/mage_ael_ascendant_skills.png`
- `assets/peso&cover/sorts/mage_ael_prisme_skills.png`

Les captures du banc `tools/preview_hero.gd` vont dans `/tmp/ael-forme-{1,10,20,30}.png`.

- `assets/peso&cover/sorts/mage_ael_skills.png` (version corrigée)
- `assets/peso&cover/interface/portraits/portrait_ael_eveille.png`
- `assets/peso&cover/interface/portraits/portrait_ael_ascendant.png`
- `assets/peso&cover/interface/portraits/portrait_ael_prisme.png`

Ces quatre dernières images suivent les prompts 1, 5, 10 et 15 de
`docs/prompts/mages/ael_commande_complete.md`, avec les références dans l’ordre prescrit.
