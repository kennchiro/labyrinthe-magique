# Aël, l'Enfant sans élément — fiche et modèles du héros principal

> Élément **Prisme** · blanc, cyan et or · le héros principal, qui évolue avec son niveau. Plan complet :
> [HEROS_PRINCIPAL](../../HEROS_PRINCIPAL.md).

**Les quatre formes sont intégrées et disponibles à l’essai.** La planche de concept du joueur fixe son allure et ses quatre formes :
`assets/peso&cover/refonte/ael_concept.png`. Elle est jointe à CHAQUE prompt, mais seulement pour l'allure :
sa mise en page, son fond violet, ses textes et ses lueurs ne doivent jamais être recopiés.

## L'ordre des images

L'Apprenti d'abord, seul : une fois son modèle validé, il est joint aux trois autres formes, pour qu'Aël garde
le même visage et la même taille en évoluant.

| # | Image | À déposer dans `assets/peso&cover/` | À joindre, dans cet ordre |
|---|---|---|---|
| 1 | Modèle de l'Apprenti | `refonte/ael_apprenti.png` | `refonte/ael_concept.png`, `refonte/chrono.png` |
| 2 | Modèle de l'Éveillé | `refonte/ael_eveille.png` | `refonte/ael_concept.png`, `refonte/ael_apprenti.png` |
| 3 | Modèle de l'Ascendant | `refonte/ael_ascendant.png` | `refonte/ael_concept.png`, `refonte/ael_apprenti.png` |
| 4 | Modèle du Prisme | `refonte/ael_prisme.png` | `refonte/ael_concept.png`, `refonte/ael_apprenti.png` |
| 5 | Marche et attaque de l'Apprenti | [mages_animes/ael](../mages_animes/ael.md) | voir la fiche |

Les marches, attaques, portraits et icônes des trois autres formes sont déposés et intégrés ; voir [la commande complète](ael_commande_complete.md).

## Ce que la planche de concept ne doit PAS transmettre

| Sur la planche de concept | Pourquoi c'est interdit sur nos images |
|---|---|
| Le fond violet et les lueurs roses | Le fond de nos planches est magenta : le détourage mangerait tout ce qui est rose ou violet |
| Les cheveux argent-lavande de l'Ascendant | Même raison : un argent froid, teinté de bleu, jamais de lavande |
| Le halo, les cristaux qui flottent et les étincelles du Prisme | Le jeu les peint lui-même, au shader, en mouvement |
| Un corps un peu élancé | Il doit être chibi comme les mages, sinon il paraît plus grand qu'eux |

## Les quatre formes

Le même garçon, au même visage, à la même taille. Seuls les cheveux, la tenue et la lumière changent.

| Forme | Cheveux et yeux | Tenue | Épée et gemme |
|---|---|---|---|
| **Apprenti** | noirs, en épis ; yeux brun sombre | longue écharpe rouge sombre, tunique de cuir brun ceinturée, pantalon brun foncé, bottes brunes, mitaines | épée courte d'acier ; petit éclat de gemme pâle et ÉTEINT pendu au cou |
| **Éveillé** | noirs, une grande mèche BLANCHE sur le devant ; yeux brun sombre | courte cape blanc crème sur les épaules, tunique brune, gantelet de cristal cyan à l'avant-bras gauche | lame de cristal cyan translucide ; la gemme brille, blanc-bleu, sur sa poitrine |
| **Ascendant** | argentés, teinte froide BLEUTÉE ; yeux cyan | épaulières et brassards de cristal bleu pâle bordés d'or, tenue bleu nuit, courte cape blanche doublée de bleu | lame de cristal bleue ; gemme d'or |
| **Prisme** | dressés vers le haut, blanc et or ; yeux d'or | armure légère blanche et or, bordée de cristal | lame de lumière dorée ; gemme d'or éclatante |

---

## Image 1 — le modèle de l'Apprenti

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/chrono.png`.
À déposer dans `assets/peso&cover/refonte/ael_apprenti.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Elle montre ses quatre formes ;
  dessine UNIQUEMENT la première, « 0. Apprenti » (le garçon aux cheveux noirs et à l'écharpe
  rouge). Garde son visage, sa coiffure, sa tenue et ses couleurs. Ne recopie NI sa mise en page,
  NI son fond violet, NI ses textes, NI ses cadres, NI ses lueurs.
- la DEUXIÈME sert UNIQUEMENT de référence de style, de proportions et de mise en page : ne copie
  ni son personnage, ni ses couleurs, ni ses objets.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël l'Apprenti, un jeune garçon HUMAIN, apprenti aventurier, déterminé.
Cheveux noirs en épis, yeux brun sombre, sourcils froncés. Longue écharpe rouge sombre
(#8e1b17) nouée au cou, dont un pan tombe dans son dos. Tunique courte de cuir brun (#6b4428)
serrée par une ceinture à boucle, pantalon brun foncé (#3b2a1e), bottes de cuir brun,
mitaines de cuir. Il tient de la main droite une ÉPÉE COURTE d'acier, pointe vers le bas. Un
petit éclat de gemme pâle, TERNE et ÉTEINT, pend à son cou. Toutes ses formes sombres sont
cernées d'un fin contour brun foncé net.

⚠️ RÈGLE BLOQUANTE — LA MORPHOLOGIE EST CELLE DE LA DEUXIÈME IMAGE : UN CORPS CHIBI. Sa hauteur
totale vaut 2,5 TÊTES : la tête (coiffure comprise) occupe près de 40 % de la hauteur, et les
jambes à peine un quart. Grosses mains, gros pieds, torse court. Jamais de corps élancé, de
longues jambes ou de petite tête.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT. Les deux jambes sont séparées l'une de
l'autre ; ni l'écharpe ni la tunique ne les cachent.

⚠️ RÈGLE BLOQUANTE — AUCUNE MAGIE : la gemme est éteinte. Ni lueur, ni aura, ni particule.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond. Son
écharpe est d'un rouge sombre qui tire vers le brun, jamais vers le rose.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

---

## Image 2 — le modèle de l'Éveillé

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
À déposer dans `assets/peso&cover/refonte/ael_eveille.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Dessine UNIQUEMENT sa deuxième
  forme, « 1. Éveillé » (la mèche blanche et la courte cape crème). Garde sa coiffure, sa tenue
  et ses couleurs. Ne recopie NI sa mise en page, NI son fond violet, NI ses textes, NI ses
  cadres, NI ses lueurs.
- la DEUXIÈME est le MÊME garçon dans sa première forme, déjà validée : garde EXACTEMENT son
  visage, sa taille, ses proportions et la mise en page de ses trois cases. Il a seulement évolué.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël l'Éveillé, le même jeune garçon HUMAIN, plus sûr de lui. Cheveux noirs en
épis avec une grande mèche BLANCHE sur le devant, yeux brun sombre. Une courte cape blanc crème
(#efe6d2) couvre ses épaules et s'arrête au milieu du dos. Tunique de cuir brun ceinturée,
pantalon brun foncé, bottes brunes. Un gantelet de CRISTAL cyan (#7fe3ff) couvre son avant-bras
gauche. Il tient de la main droite une épée à LAME DE CRISTAL cyan translucide, pointe vers le
bas. La gemme est maintenant fixée sur sa poitrine, et ELLE BRILLE, blanc-bleu (#dff6ff), par
sa seule couleur. Toutes ses formes sont cernées d'un fin contour brun foncé net.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE ET LE MÊME CORPS QUE SUR LA DEUXIÈME IMAGE. Tête, tronc,
jambes et pieds ont les mêmes dimensions : il change d'allure, pas de corps. Toujours CHIBI,
2,5 TÊTES de haut.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT : la cape s'arrête au dos et ne les cache
jamais.

⚠️ RÈGLE BLOQUANTE — LA LUMIÈRE EST DANS LES COULEURS, PAS AUTOUR. La gemme, le gantelet et la
lame sont clairs et lumineux, mais sans halo, sans aura, sans particule ni étincelle.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

---

## Image 3 — le modèle de l'Ascendant

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
À déposer dans `assets/peso&cover/refonte/ael_ascendant.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Dessine UNIQUEMENT sa troisième
  forme, « 2. Ascendant » (l'armure de cristal). Garde sa coiffure, son armure et ses couleurs,
  SAUF la teinte lavande de ses cheveux. Ne recopie NI sa mise en page, NI son fond violet, NI
  ses textes, NI ses cadres, NI ses lueurs.
- la DEUXIÈME est le MÊME garçon dans sa première forme, déjà validée : garde EXACTEMENT son
  visage, sa taille, ses proportions et la mise en page de ses trois cases. Il a seulement évolué.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël l'Ascendant, le même jeune garçon HUMAIN, devenu un guerrier sûr de sa
force. Cheveux en épis ARGENTÉS, d'un argent froid teinté de bleu (#d8e4f0), yeux cyan
(#3fd8ff). Épaulières et brassards de CRISTAL bleu pâle (#a9dcff) bordés d'or (#e0b84a), sur
une tenue ajustée bleu nuit (#1e2a4a) à ceinture d'or. Courte cape blanche doublée de bleu, qui
s'arrête au milieu du dos. Bottes bleu nuit à renforts de cristal. Il tient de la main droite
une épée à LAME DE CRISTAL bleue, pointe vers le bas. Une gemme d'or est sertie sur sa
poitrine. Toutes ses formes sombres sont cernées d'un fin liseré clair, qui les détache des
sols sombres.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE ET LE MÊME CORPS QUE SUR LA DEUXIÈME IMAGE. Tête, tronc,
jambes et pieds ont les mêmes dimensions : l'armure s'ajoute sur lui, elle ne le grandit pas.
Toujours CHIBI, 2,5 TÊTES de haut. Les épaulières restent compactes.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT : la cape s'arrête au dos et ne les cache
jamais.

⚠️ RÈGLE BLOQUANTE — LA LUMIÈRE EST DANS LES COULEURS, PAS AUTOUR. Cristal et yeux sont clairs
et lumineux, mais sans halo, sans aura, sans particule ni étincelle.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUNE LAVANDE, AUCUN MAGENTA sur lui, ni reflet du
fond. L'argent de ses cheveux tire vers le bleu.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

---

## Image 4 — le modèle du Prisme

Joindre `assets/peso&cover/refonte/ael_concept.png` **puis** `assets/peso&cover/refonte/ael_apprenti.png`.
À déposer dans `assets/peso&cover/refonte/ael_prisme.png`.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, même facture que les sprites d'un jeu de rôle mobile.

LES IMAGES JOINTES :
- la PREMIÈRE est la planche de concept du personnage, Aël. Dessine UNIQUEMENT sa forme finale,
  « 3. Prisme » (les cheveux dressés blanc et or). Garde sa coiffure, son armure et ses couleurs.
  Ne recopie NI sa mise en page, NI son fond violet, NI ses textes, NI ses cadres, et SURTOUT NI
  son halo, NI les cristaux qui flottent autour de lui, NI ses étincelles.
- la DEUXIÈME est le MÊME garçon dans sa première forme, déjà validée : garde EXACTEMENT son
  visage, sa taille, ses proportions et la mise en page de ses trois cases. Il s'est transformé.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite : face, dos, puis profil tourné vers la droite.

LE PERSONNAGE — Aël en forme Prisme, sa transformation finale, le même jeune garçon HUMAIN, au
sommet de sa puissance, regard intense. Cheveux en épis DRESSÉS VERS LE HAUT, blancs aux pointes
dorées (#fff4c8 et #f2c94c), yeux d'or. Armure légère blanche (#f6f3ea) bordée d'or et de
cristal clair, épaulières compactes, tenue blanche, ceinture d'or, bottes blanches et or. Il
tient de la main droite une épée à LAME DE LUMIÈRE dorée, pointe vers le bas. Une gemme d'or
éclatante est sertie sur sa poitrine. Toutes ses formes claires sont cernées d'un contour brun
doré net, qui les détache des sols clairs.

⚠️ RÈGLE BLOQUANTE — LA MÊME TAILLE ET LE MÊME CORPS QUE SUR LA DEUXIÈME IMAGE. Tête, tronc,
jambes et pieds ont les mêmes dimensions ; seuls les cheveux dressés dépassent un peu au-dessus.
Toujours CHIBI, 2,5 TÊTES de haut.

⚠️ RÈGLE BLOQUANTE — RIEN NE FLOTTE AUTOUR DE LUI. Aucun halo, aucune aura, aucun cristal
détaché, aucune particule, aucune étincelle : le jeu ajoutera lui-même son aura, en mouvement.
La lumière est seulement dans les couleurs de ses cheveux, de sa lame et de sa gemme.

⚠️ RÈGLE BLOQUANTE — SES JAMBES SE LISENT EN TRÈS PETIT : rien ne les cache.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET, AUCUN MAGENTA sur lui, ni reflet du fond.

⚠️ RÈGLE BLOQUANTE — MÊME visage, tenue, couleurs et proportions dans les trois cases.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

---

## À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Il est élancé, ou sa tête est petite | Il ne ressemblerait pas aux mages : à regénérer sans attendre |
| Les formes 2 à 4 n'ont pas la même taille que l'Apprenti | Il changerait de corps en évoluant |
| Un fond violet, du rose ou de la lavande sur lui | Le détourage le trouerait |
| Un halo, des cristaux qui flottent ou des étincelles | Ils resteraient collés au sprite, immobiles |
| La cape ou l'écharpe cachent les jambes | Il glisserait en marchant |
