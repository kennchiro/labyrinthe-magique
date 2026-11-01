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
