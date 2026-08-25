# Les planches de la refonte des mages — dépôt

Déposer ici les images qui arrivent de ChatGPT, **sans écraser quoi que ce soit
ailleurs**, sous ces noms exactement :

| mage | planche de mouvements | planche d'effets |
|---|---|---|
| Mage du Feu | `feu.png` | `feu_fx.png` |
| Mage de l'Eau | `eau.png` | `eau_fx.png` |
| Mage de la Terre | `terre.png` | `terre_fx.png` |
| Mage de la Foudre | `foudre.png` | `foudre_fx.png` |
| Mage de l'Air | `air.png` | `air_fx.png` |
| Sorcier des Ténèbres | `tenebres.png` | `tenebres_fx.png` |
| Invocateur | `invocateur.png` | `invocateur_fx.png` |
| Sorcier Suprême | `supreme.png` | `supreme_fx.png` |

Les prompts correspondants sont dans `docs/prompts/mages/`.

## Pourquoi un dossier à part plutôt que remplacer directement

⚠️ **Les planches actuelles ne servent pas qu'au personnage.** `build_spell_fx.py`
y découpe l'orbe, l'impact et la zone de chaque mage, et `build_warps.py` sa
colonne de téléportation — à des coordonnées en pixels **relevées à la main dans
la planche**. Exemple, pour le Feu : la comète est prise en (1103, 446)-(1192,
524), le vortex d'impact en (1288, 585)-(1398, 700).

Écraser `mages/mage_fire.png` remplacerait donc le mage ET les quatre effets par
un découpage au hasard, **sans le moindre message d'erreur** : les outils
trouveraient bien un fichier, à la bonne taille, et couperaient dedans.

Un mage ne bascule donc que quand ses **deux** planches sont là. À ce
moment-là :

1. la planche de mouvements rejoint `mages/` et prend sa place dans la table de
   `build_characters.py` ;
2. la planche d'effets rejoint `sorts/`, et je relève ses quatre boîtes pour
   `build_spell_fx.py` et `build_warps.py`, qui cessent de lire l'ancienne ;
3. l'ancienne planche part à l'attic — pas avant, parce qu'elle est la seule
   source des effets tant que la nouvelle n'est pas relevée.

## Ce qui se vérifie à l'arrivée

Trois mesures, et ce sont les trois qui coûtent un redécoupage :

- le personnage occupe ~80 % de la hauteur de sa case (aujourd'hui : de 60 %
  pour le Feu à 93 % pour l'Invocateur — c'est tout l'objet de la refonte) ;
- rien ne déborde sur la case voisine, bâton compris ;
- la taille ne change pas d'une case à l'autre.
