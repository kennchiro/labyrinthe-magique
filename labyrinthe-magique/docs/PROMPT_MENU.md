# L'écran « Choisis ton mage » — index des prompts

⚠️ Les fichiers de `docs/prompts/menu/` sont **GÉNÉRÉS** par
`tools/build_prompts_menu.py`. Ne pas les éditer à la main.

## Ce qui cloche aujourd'hui

L'écran affiche le **sprite de jeu** de chaque mage : sa première pose de marche
de face, vue de DESSUS, haute de 112 pixels. Dans une vignette de 116 x 142 elle
occupe un tiers de la surface et flotte au milieu d'une boîte vide.

Ce n'est pas un défaut de mise en page. Un sprite vu de dessus ne fera **jamais**
un portrait : on n'y voit pas le visage, et c'est précisément le visage qu'on
regarde au moment de choisir. Il faut un dessin fait pour ça.

La maquette existe déjà — `assets/peso&cover/interface/selection_mage1.jpeg` —
et c'est elle qu'on rejoue.

## Dix prompts, à lancer un par un

| Mage | Élément | Couleur | Prompt |
|---|---|---|---|
| Mage du Feu | Feu | `#ff6a2a` | [portrait_fire](prompts/menu/portrait_fire.md) |
| Mage de l'Eau | Eau | `#37c6ff` | [portrait_water](prompts/menu/portrait_water.md) |
| Mage de la Terre | Terre | `#7bc043` | [portrait_earth](prompts/menu/portrait_earth.md) |
| Sorcier des Ténèbres | Ténèbres | `#b06cff` | [portrait_shadow](prompts/menu/portrait_shadow.md) |
| Mage de la Foudre | Foudre | `#ffd93a` | [portrait_thunder](prompts/menu/portrait_thunder.md) |
| Mage de l'Air | Air | `#cfe9ff` | [portrait_air](prompts/menu/portrait_air.md) |
| Invocateur | Ténèbres | `#b06cff` | [portrait_invocateur](prompts/menu/portrait_invocateur.md) |
| Sorcier Suprême | Suprême | `#ffd36a` | [portrait_supreme](prompts/menu/portrait_supreme.md) |
| Chronomancien | Temps | `#2fd6b8` | [portrait_chrono](prompts/menu/portrait_chrono.md) |
| Mage de la Peste | Poison | `#b4f02a` | [portrait_peste](prompts/menu/portrait_peste.md) |
| Porte-Lumière | Lumière | `#fff1b8` | [portrait_lumiere](prompts/menu/portrait_lumiere.md) |
| Ange de la Mort | Mort | `#e2382a` | [portrait_mort](prompts/menu/portrait_mort.md) |
| Ange des Étoiles | Étoiles | `#9db8ff` | [portrait_etoiles](prompts/menu/portrait_etoiles.md) |
| Archange d'Acier | Acier | `#a9b6c6` | [portrait_acier](prompts/menu/portrait_acier.md) |
| Archange du Ciel | Ciel | `#34e07a` | [portrait_ciel](prompts/menu/portrait_ciel.md) |
| Chérubin | Feu sacré | `#3d6bff` | [portrait_cherubin](prompts/menu/portrait_cherubin.md) |

## Les portraits des Éveils

Le bouton ÉVEIL de la fiche montre la forme éveillée du mage. Chaque prompt joint le portrait du mage ET sa
planche de marche éveillée. Tant qu'un portrait manque, la carte montre le sprite de l'Éveil.

| Éveil | Mage | Prompt |
|---|---|---|
| Phénix | fire | [portrait_fire_eveil](prompts/menu/portrait_fire_eveil.md) |
| Seigneur des Marées | water | [portrait_water_eveil](prompts/menu/portrait_water_eveil.md) |
| Colosse | earth | [portrait_earth_eveil](prompts/menu/portrait_earth_eveil.md) |
| Avatar de la Tempête | thunder | [portrait_thunder_eveil](prompts/menu/portrait_thunder_eveil.md) |
| Souverain des Vents | air | [portrait_air_eveil](prompts/menu/portrait_air_eveil.md) |
| Seigneur du Néant | shadow | [portrait_shadow_eveil](prompts/menu/portrait_shadow_eveil.md) |
| Maître des Légions | invocateur | [portrait_invocateur_eveil](prompts/menu/portrait_invocateur_eveil.md) |
| Seigneur des Heures | chrono | [portrait_chrono_eveil](prompts/menu/portrait_chrono_eveil.md) |
| Seigneur du Fléau | peste | [portrait_peste_eveil](prompts/menu/portrait_peste_eveil.md) |
| Archimage Primordial | supreme | [portrait_supreme_eveil](prompts/menu/portrait_supreme_eveil.md) |
| Archidémon du Pacte | demon | [portrait_demon_eveil](prompts/menu/portrait_demon_eveil.md) |
| Reine de la Discorde | discorde | [portrait_discorde_eveil](prompts/menu/portrait_discorde_eveil.md) |
| Empereur des Cendres | braise | [portrait_braise_eveil](prompts/menu/portrait_braise_eveil.md) |
| Seigneur Écarlate | ecarlate | [portrait_ecarlate_eveil](prompts/menu/portrait_ecarlate_eveil.md) |
| Gardien de l'Abîme | geolier | [portrait_geolier_eveil](prompts/menu/portrait_geolier_eveil.md) |
| Dragon Primordial | dragon | [portrait_dragon_eveil](prompts/menu/portrait_dragon_eveil.md) |
| Maître du Casino | croupier | [portrait_croupier_eveil](prompts/menu/portrait_croupier_eveil.md) |
| Faim Sans Fond | avide | [portrait_avide_eveil](prompts/menu/portrait_avide_eveil.md) |
| Étoile du Matin | lumiere | [portrait_lumiere_eveil](prompts/menu/portrait_lumiere_eveil.md) |
| Faucheur des Âmes | mort | [portrait_mort_eveil](prompts/menu/portrait_mort_eveil.md) |
| Gardien du Trône | cherubin | [portrait_cherubin_eveil](prompts/menu/portrait_cherubin_eveil.md) |
| Séraphin | ciel | [portrait_ciel_eveil](prompts/menu/portrait_ciel_eveil.md) |
| Forgeron Céleste | acier | [portrait_acier_eveil](prompts/menu/portrait_acier_eveil.md) |
| Reine du Firmament | etoiles | [portrait_etoiles_eveil](prompts/menu/portrait_etoiles_eveil.md) |

Plus deux prompts communs :

| | Prompt | Pourquoi |
|---|---|---|
| Le cadre | [cadre_carte](prompts/menu/cadre_carte.md) | **une seule fois pour les huit** |
| Le fond | [fond_selection](prompts/menu/fond_selection.md) | la page entière |

Dépose les résultats dans `assets/peso&cover/interface/portraits/` (les huit
portraits et le cadre) et `assets/peso&cover/interface/` (le fond).

---

## Le partage entre le modèle et le moteur

C'est la décision qui structure tout le reste :

    le MODÈLE dessine ce qui CHANGE      -> les huit personnages, le fond
    le MOTEUR dessine ce qui SE RÉPÈTE   -> le cadre, la gemme d'élément,
                                            la lueur de sélection, le nom

Demander « le mage du Feu dans son cadre » huit fois donnerait **huit cadres
différents** : épaisseurs, gemmes, coins et vignes ne tomberaient jamais deux
fois pareil. Or les huit cartes sont côte à côte à l'écran, où le moindre écart
se voit. C'est la même leçon que les pièces de mur du terrain — « la même
largeur de tronçon dans les seize cases » — et elle vaut ici avec plus de force
encore.

Le **nom** reste du texte dessiné par le jeu, jamais une image : il doit rester
lisible à toutes les tailles, et il changerait de langue avant l'image.

---

## Ce que je fais quand les planches arrivent

1. **Le cadre est détouré une fois** (fenêtre magenta) et devient un `NinePatch` :
   ses bords s'étirent, ses coins ne se déforment pas, donc la même image sert à
   la vignette de la rangée et à la grande carte de la fiche ;
2. **`CharacterPortrait` change de dessin** : fond élémentaire, portrait, cadre
   teinté à la couleur de l'élément, gemme, puis la lueur de sélection par-dessus.
   Le sprite de jeu disparaît de cet écran ;
3. **Le fond remplace `MenuBackdrop`** sur cet écran, avec le voile sombre qui
   existe déjà derrière la fiche ;
4. **Repli prévu** : un mage sans portrait garde le rendu actuel. Rien n'oblige
   à fournir les huit d'un coup.
