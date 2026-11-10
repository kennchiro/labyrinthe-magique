#!/usr/bin/env python3
"""Les prompts de l'écran « Choisis ton mage » : portraits, cadre, fond.

    tools/.venv/bin/python tools/build_prompts_menu.py     # DEPUIS LA RACINE

Produit :
    docs/prompts/menu/portrait_<id>.md   un par mage — le personnage seul
    docs/prompts/menu/cadre_carte.md     le cadre VIDE, une seule fois
    docs/prompts/menu/fond_selection.md  le fond de la page
    docs/PROMPT_MENU.md                  l'index

⚠️ Fichier SÉPARÉ de `build_prompts.py`, qui fait le terrain. Rien à voir : ces
planches n'ont ni grille, ni raccord, ni contrainte de contraste de jeu, et leur
planche de référence est la maquette d'interface, pas les décors de stage.
C'est l'usage du projet — un outil par sujet.

CE QUI CLOCHE AUJOURD'HUI, ET QUE CES PROMPTS RÉPARENT

L'écran affiche le SPRITE DE JEU de chaque mage : sa première pose de marche de
face, vue de DESSUS, haute de 112 pixels. Dans une vignette de 116 x 142 elle
occupe un tiers de la surface et flotte au milieu d'une boîte vide. Ce n'est pas
un défaut de mise en page : un sprite vu de dessus ne fera JAMAIS un portrait,
parce qu'on n'y voit pas le visage.

Il faut donc un dessin fait pour ça. La maquette existe déjà —
`assets/peso&cover/interface/selection_mage1.jpeg` — et c'est elle qu'on rejoue.

POURQUOI LE CADRE EST DEMANDÉ **UNE SEULE FOIS**

C'est la décision qui structure tout le reste. Demander « le mage du Feu dans son
cadre » huit fois donnerait huit cadres différents : épaisseurs, gemmes, coins et
vignes ne tomberaient jamais deux fois pareil, et une rangée de huit cartes mal
assorties est PIRE qu'une rangée sans cadre. C'est exactement la leçon des pièces
de mur — « la même largeur de tronçon dans les seize cases » — et elle vaut ici
avec encore plus de force, puisque les huit cartes sont côte à côte à l'écran.

Le partage est donc :
    le MODÈLE dessine ce qui change  -> les huit personnages, le fond
    le MOTEUR dessine ce qui se répète -> le cadre, la lueur de sélection,
                                          la plaque de nom
Et le NOM reste du texte, jamais une image : il doit rester lisible à toutes les
tailles, et il changerait de langue avant l'image.
"""

from pathlib import Path

OUT = Path("docs/prompts/menu")

## Format des portraits. 3:4 debout, comme les cartes de la maquette. Le moteur
## dessine ses vignettes dans ce rapport plutôt que l'inverse : recadrer un
## personnage déjà dessiné lui coupe la tête ou les pieds.
PORTRAIT_SIZE = "1024 x 1365 pixels (rapport 3:4, debout)"

# id, nom affiché, élément, couleur, et ce à quoi le mage RESSEMBLE déjà dans le
# jeu. La description physique n'est pas inventée : elle est relevée sur la
# planche du mage et sur la maquette. Un portrait qui ne ressemble pas au sprite
# qu'on jouera ensuite est un mensonge fait au joueur au moment du choix.
MAGES = [
    {
        "id": "fire", "nom": "Mage du Feu", "element": "Feu", "couleur": "#ff6a2a",
        "corps": "une longue robe rouge sang à capuche, dont le capuchon ne "
                 "laisse voir que DEUX YEUX ORANGE lumineux — aucun visage. Un "
                 "bâton de bois noirci surmonté d'une flamme dans la main "
                 "gauche, une boule de feu qui danse au creux de la main droite. "
                 "Broderies d'or et braises qui montent le long de la robe",
        "aura": "orange et rouge, comme un feu de forge",
        "phrase": "Brûle tout ce qui approche.",
    },
    {
        "id": "water", "nom": "Mage de l'Eau", "element": "Eau", "couleur": "#37c6ff",
        "corps": "un grand CHAPEAU POINTU bleu qui retombe, une cape bleu roi, "
                 "et un visage juvénile bien VISIBLE et souriant sous le bord du "
                 "chapeau. Un bâton à cristal bleu clair dans la main droite, "
                 "des gouttes et un ruban d'eau qui tournent autour de lui",
        "aura": "bleu clair et turquoise, comme une eau éclairée par-dessous",
        "phrase": "Ralentit, encaisse et se soigne.",
    },
    {
        "id": "earth", "nom": "Mage de la Terre", "element": "Terre", "couleur": "#7bc043",
        "corps": "un NAIN trapu à LONGUE BARBE GRISE, visage buriné bien "
                 "visible, armure de cuir brun à plastron vert et épaulières de "
                 "pierre. Un lourd bâton noueux à cristal VERT dans la main "
                 "droite, des cailloux qui lévitent autour de ses pieds",
        "aura": "vert mousse et brun terre",
        "phrase": "Le plus résistant, et il peut fermer un couloir.",
    },
    {
        "id": "shadow", "nom": "Sorcier des Ténèbres", "element": "Ténèbres",
        "couleur": "#b06cff",
        "corps": "une robe violet sombre presque noire à large capuche, dont le "
                 "capuchon est un TROU NOIR sans visage ni yeux. Deux ORBES "
                 "VIOLETTES lumineuses flottent au-dessus de ses paumes "
                 "ouvertes, et de la fumée violette s'échappe du bas de la robe",
        "aura": "violet profond, avec un halo magenta",
        "phrase": "Maître des ombres et des portails.",
    },
    {
        "id": "thunder", "nom": "Mage de la Foudre", "element": "Foudre",
        "couleur": "#ffd93a",
        "corps": "des CHEVEUX BLANCS HÉRISSÉS dressés par l'électricité, un "
                 "visage jeune et décidé bien visible, une armure légère DORÉE "
                 "sur une tunique blanche. Un bâton à pointe d'or dans la main "
                 "droite d'où part un éclair, des arcs électriques bleus qui "
                 "courent sur ses bras",
        "aura": "jaune d'or et blanc électrique",
        "phrase": "Le plus rapide du royaume.",
    },
    {
        "id": "air", "nom": "Mage de l'Air", "element": "Air", "couleur": "#cfe9ff",
        "corps": "une robe BLANCHE et bleu très pâle, une longue écharpe qui "
                 "flotte loin derrière lui, une capuche rejetée en arrière sur "
                 "un visage calme et VISIBLE. Un bâton pâle surmonté d'une "
                 "plume, des spirales de vent translucides autour de ses pieds "
                 "— il ne touche pas tout à fait le sol",
        "aura": "blanc bleuté, très clair, comme un ciel d'hiver",
        "phrase": "Il gagne les combats qu'il refuse de livrer.",
    },
    {
        "id": "invocateur", "nom": "Invocateur", "element": "Ténèbres",
        "couleur": "#b06cff",
        "corps": "une robe noire et violette à capuche, un visage en partie "
                 "visible et grave sous le capuchon, un long bâton surmonté "
                 "d'une ORBE VIOLETTE À RUNES. À ses pieds, un CERCLE "
                 "D'INVOCATION gravé qui luit, et DEUX PETITES CRÉATURES "
                 "d'ombre aux yeux violets qui l'accompagnent",
        "aura": "violet et noir, avec la lueur du cercle par en dessous",
        "phrase": "Ne combat pas : il invoque.",
    },
    {
        "id": "supreme", "nom": "Sorcier Suprême", "element": "Suprême",
        "couleur": "#ffd36a",
        "corps": "une robe sombre à liserés d'or et une COURONNE dorée, le "
                 "visage dans l'ombre avec des yeux dorés. QUATRE SPHÈRES "
                 "élémentaires tournent autour de lui — une rouge de feu, une "
                 "bleue d'eau, une verte de terre, une jaune de foudre — et "
                 "leurs quatre couleurs se reflètent sur sa robe",
        "aura": "or, avec les quatre couleurs élémentaires qui s'y mêlent",
        "phrase": "Maître des quatre éléments.",
    },
    {
        "id": "chrono", "nom": "Chronomancien", "element": "Temps",
        "couleur": "#2fd6b8",
        "corps": "une longue robe turquoise sombre à liserés de cuivre, un haut "
                 "col de cuivre, des cheveux argentés courts coiffés en arrière "
                 "et un visage calme bien VISIBLE, un monocle de cuivre à l'œil "
                 "droit. Un GRAND SABLIER de cuivre au sable turquoise est fixé "
                 "dans son dos et dépasse au-dessus de ses épaules. Il tient de "
                 "la main droite un bâton en forme de GRANDE AIGUILLE D'HORLOGE "
                 "en cuivre, surmonté d'un petit cadran turquoise, et des grains "
                 "de sable turquoise restent suspendus en l'air autour de lui",
        "aura": "turquoise et cuivre",
        "phrase": "Il ne fuit pas : il revient en arrière.",
    },
    {
        "id": "peste", "nom": "Mage de la Peste", "element": "Poison",
        "couleur": "#b4f02a",
        "corps": "un MASQUE DE MÉDECIN DE PESTE en cuir sombre, à long bec courbe et à "
                 "deux verres ronds VERT ACIDE lumineux : aucun visage visible. Une "
                 "capuche et un long manteau aubergine très sombre, presque noir, à "
                 "liserés vert acide. Trois petites FIOLES de liquide vert acide pendent "
                 "à sa ceinture. Il tient de la main droite un bâton tordu en bois noir, "
                 "surmonté d'une grosse FIOLE RONDE pleine de liquide vert acide d'où "
                 "montent des bulles, et une fine fumée verte s'enroule autour de ses bottes",
        "aura": "vert acide et vert très sombre",
        "phrase": "Plus on le poursuit, plus on s'empoisonne.",
    },
    {
        "id": "lumiere", "nom": "Porte-Lumière", "element": "Lumière",
        "couleur": "#fff1b8",
        "corps": "un ANGE aux deux GRANDES AILES de plumes blanches, largement ouvertes "
                 "derrière lui. Une AURÉOLE d'or plate flotte au-dessus de sa tête. Courts "
                 "cheveux blonds, visage jeune et serein bien VISIBLE, armure légère blanc "
                 "ivoire à liserés d'or sur une tunique blanche, bottes d'or. Il tient de la "
                 "main droite une LANCE dorée, surmontée d'une pointe de cristal blanc "
                 "lumineux, et de petites plumes de lumière flottent autour de lui. Ses formes "
                 "blanches sont cernées d'un contour brun foncé net, qui les détache du fond",
        "aura": "or pâle au centre et bleu nuit profond",
        "phrase": "Sa lumière aveugle : ils perdent sa trace.",
    },
    {
        "id": "mort", "nom": "Ange de la Mort", "element": "Mort",
        "couleur": "#e2382a",
        "corps": "un ANGE DÉCHU à l'allure un peu démoniaque, aux deux GRANDES AILES de plumes "
                 "noires déchirées, largement ouvertes derrière lui. Deux PETITES CORNES noires "
                 "courbes sortent de son front, et une AURÉOLE BRISÉE rouge braise, ouverte comme "
                 "un anneau fendu, flotte au-dessus de sa tête. Visage pâle couleur d'os bien "
                 "VISIBLE, grave et calme, aux yeux rouge braise, cheveux noirs mi-longs, armure "
                 "gris anthracite à liserés couleur d'os sur une longue robe noire déchirée, "
                 "bottes griffues. Il tient de la main droite une grande FAUX au manche d'os, dont "
                 "la lame noire est bordée de rouge braise, et quelques plumes noires et braises "
                 "flottent autour de lui. Ses formes noires sont cernées d'un fin liseré clair "
                 "couleur d'os, qui les détache du fond",
        "aura": "rouge braise au centre et noir bleuté profond",
        "phrase": "Ce qu'il a blessé, il vient le prendre.",
    },
    {
        "id": "etoiles", "nom": "Ange des Étoiles", "element": "Étoiles",
        "couleur": "#9db8ff",
        "corps": "un ANGE, une FEMME ADULTE au visage calme et bien VISIBLE, aux deux GRANDES "
                 "AILES de plumes bleu nuit, semées de petits points blancs comme un ciel étoilé, "
                 "largement ouvertes derrière elle. Une COURONNE EN CROISSANT DE LUNE argentée "
                 "flotte au-dessus de sa tête. Longs cheveux argentés attachés en une tresse, longue "
                 "robe bleu nuit à manches longues, sobre et couvrante, à liserés d'argent, bottines "
                 "argentées. Elle tient de la main droite un fin SCEPTRE d'argent surmonté d'une "
                 "étoile blanche à quatre branches, et trois petites étoiles reliées par de fins "
                 "traits de lumière flottent près d'elle. Ses formes sombres sont cernées d'un fin "
                 "liseré argenté, qui les détache du fond",
        "aura": "bleu pâle au centre et bleu nuit profond",
        "phrase": "Elle trace dans le labyrinthe les pièges de son ciel.",
    },
    {
        "id": "acier", "nom": "Archange d'Acier", "element": "Acier",
        "couleur": "#a9b6c6",
        "corps": "un ANGE GUERRIER MASSIF et COSTAUD, très large d'épaules, en ARMURE DE PLATES "
                 "INTÉGRALE gris-bleu, faite de grandes plaques épaisses : énormes épaulières, "
                 "plastron bombé, gantelets et grosses bottes de métal. HEAUME FERMÉ, sans aucun "
                 "visage, dont la fente horizontale laisse sortir une lueur orange, et de fines "
                 "fentes orange de métal chauffé courent entre les plaques. Ses deux GRANDES AILES "
                 "sont faites entièrement de LAMES D'ACIER superposées, sans aucune plume, largement "
                 "ouvertes derrière lui. Il tient à deux mains un grand MARTEAU DE GUERRE à la tête "
                 "d'acier massive, posée au sol devant lui. Le métal reste gris-bleu, sans reflet "
                 "rose ni violet",
        "aura": "orange de métal chauffé au centre et gris acier sombre",
        "phrase": "Il va droit au combat, et c'est le combat qui recule.",
    },
    {
        "id": "ciel", "nom": "Archange du Ciel", "element": "Ciel",
        "couleur": "#34e07a",
        "corps": "un JEUNE ARCHANGE GUERRIER au visage calme et décidé, bien VISIBLE, aux yeux "
                 "émeraude. Cheveux blancs courts en mèches soulevées, DIADÈME D'OR orné de deux "
                 "petites ailes dorées sur les tempes. ARMURE LÉGÈRE blanche à bords dorés, petites "
                 "épaulières dorées, et un TABARD COURT émeraude à liseré d'or qui s'arrête au-dessus "
                 "des genoux. Ses deux GRANDES AILES de plumes BLANCHES, aux pointes émeraude, sont "
                 "largement ouvertes derrière lui. Il tient de la main droite une LANCE D'OR à pointe "
                 "blanche, levée vers le ciel, et une petite CLOCHE D'OR pend à sa ceinture. Le blanc "
                 "reste blanc, ombré de gris-vert, sans reflet rose ni violet",
        "aura": "émeraude lumineux au centre et vert profond presque noir",
        "phrase": "Il voit le labyrinthe d'en haut, et ses coups tombent du ciel.",
    },
    {
        "id": "cherubin", "nom": "Chérubin", "element": "Feu sacré",
        "couleur": "#3d6bff",
        "corps": "le CHÉRUBIN de la Bible, gardien d'Éden : un JEUNE ANGE au visage grave et calme, "
                 "bien VISIBLE, aux yeux bleu saphir. Cheveux d'or foncé courts et bouclés, et derrière "
                 "sa tête une ROUE D'OR à huit rayons, avec un œil d'or sur sa jante, dessinée comme un "
                 "objet solide. TUNIQUE COURTE de LIN BLANC qui s'arrête au-dessus des genoux, CUIRASSE "
                 "de BRONZE POLI, jambières et sandales de bronze, CEINTURE BLEU SAPHIR. QUATRE GRANDES "
                 "AILES, en DEUX PAIRES, blanches aux pointes saphir, largement ouvertes derrière lui, "
                 "avec quelques YEUX D'OR stylisés sur les plumes, calmes et jamais inquiétants. Il tient "
                 "de la main droite une ÉPÉE de bronze dont la lame est une FLAMME BLEU SAPHIR aux "
                 "langues nettes, levée devant lui. Le bleu est un saphir franc, jamais violet ; le lin "
                 "reste blanc, ombré de gris-beige, sans reflet rose ni violet",
        "aura": "bleu saphir lumineux au centre et bleu nuit presque noir",
        "phrase": "Il garde le chemin d'Éden, et nul n'approche de son épée.",
    },
]

ENTETE = """> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.
"""

COMMUN = """RÈGLES ABSOLUES :
- le personnage est ENTIER, debout, de face, légèrement de trois quarts, et
  regarde le joueur. On voit ses pieds et le haut de sa tête
- il occupe environ 80 % de la hauteur de l'image et reste CENTRÉ
- aucun CADRE, aucune bordure, aucun liseré, aucune vignette : le cadre est
  ajouté par le jeu, un cadre dessiné ici se superposerait au sien
- aucun TEXTE, aucun nom, aucun chiffre, aucun logo
- aucun sol, aucun décor, aucune ombre portée au sol : le fond est une nappe de
  couleur, pas une scène
- aucun autre personnage"""


## LES ÉVEILS (2026-11-09, demande du joueur) : l'écran de sélection montre la forme éveillée d'un mage quand on
## enclenche son bouton ÉVEIL. Le portrait est la TRANSFORMATION du portrait du mage, pas un nouveau personnage :
## on joint donc le portrait de base (le style, le visage) ET la planche de marche de l'Éveil (ce qu'il devient).
## `base` est l'id du mage, `planche` le nom de sa planche de marche éveillée dans `assets/peso&cover/mages/`.
EVEILS = [
    {
        "id": "fire_eveil", "base": "fire", "nom": "Phénix", "de": "du Mage du Feu",
        "planche": "feu_eveil_marche.png",
        "corps": "sa capuche brûle et s'ouvre en une CRÊTE DE FLAMMES EN PLUMES, comme la tête d'un phénix ; "
                 "ses yeux sont d'or blanc. Sa robe écarlate se couvre de plumes d'or aux épaules et son ourlet se "
                 "découpe en pointes de plumes qui flambent. Deux grandes AILES DE FEU s'ouvrent dans son dos, "
                 "plumes de flamme orange et or à cœur blanc, cernées de rouge sombre. Ses mains nues sont cerclées "
                 "de flammes",
        "aura": "or et orange vif, comme un soleil levant derrière lui",
    },
    {
        "id": "water_eveil", "base": "water", "nom": "Seigneur des Marées", "de": "du Mage de l'Eau",
        "planche": "eau_eveil_marche.png",
        "corps": "même jeune visage et mêmes vêtements bleu profond, mais le bord de son chapeau s'ouvre en une "
                 "CRÊTE DE VAGUE turquoise et blanc d'écume. Son écharpe est devenue deux RUBANS D'EAU qui "
                 "ondulent dans son dos. Le cristal de son bâton s'est allongé en une pointe de TRIDENT lumineux. "
                 "Des filets turquoise et des motifs de courants parcourent sa robe, et ses yeux brillent "
                 "turquoise pâle",
        "aura": "turquoise et bleu profond, comme la lumière sous une vague",
    },
    {
        "id": "earth_eveil", "base": "earth", "nom": "Colosse", "de": "du Mage de la Terre",
        "planche": "terre_eveil_marche.png",
        "corps": "même nain à longue barbe grise, même visage sévère et même robe vert sombre, mais la roche le "
                 "recouvre : de gros BLOCS DE ROCHE font ses épaulières, d'où sortent des CRISTAUX VERTS, et des "
                 "plaques de roche couvrent ses avant-bras, son torse et ses jambes, séparées par de fines "
                 "FISSURES DE LAVE orange qui luisent. Ses yeux brillent d'un vert vif, et la pierre de son bâton "
                 "est devenue un gros cristal vert taillé",
        "aura": "vert mousse et ambre de lave, comme une caverne de cristal",
    },
    {
        "id": "thunder_eveil", "base": "thunder", "nom": "Avatar de la Tempête", "de": "du Mage de la Foudre",
        "planche": "foudre_eveil_marche.png",
        "corps": "même jeune homme aux cheveux blancs en pointes, même tunique jaune et bleu nuit, mais la foudre le "
                 "traverse : ses cheveux se dressent plus haut et leurs pointes deviennent des ÉCLAIRS blancs et "
                 "bleus, ses yeux sont blancs et lumineux, sans pupille. Le bas de sa tunique se déchire en "
                 "ZIGZAGS D'ÉCLAIR, des ARCS ÉLECTRIQUES courent sur ses avant-bras, deux bracelets d'or retiennent "
                 "la foudre, et son bâton se termine en pointe de foudre jaune et bleue",
        "aura": "jaune électrique et bleu nuit, comme un ciel d'orage",
    },
    {
        "id": "air_eveil", "base": "air", "nom": "Souverain des Vents", "de": "du Mage de l'Air",
        "planche": "air_eveil_marche.png",
        "corps": "même enfant aux yeux bleus sous sa capuche souple, même robe blanche et bleu pâle à liserés d'or, "
                 "mais le vent l'habite : ses écharpes sont devenues de longs RUBANS DE VENT bleu ciel qui ondulent "
                 "derrière lui, le bas de sa robe s'effile en volutes de vent, et un ANNEAU DE VENT flotte derrière "
                 "sa tête comme une couronne. Ses yeux brillent bleu ciel ; l'anneau de son bâton a grandi, une "
                 "petite spirale de vent tourne au milieu",
        "aura": "bleu ciel et blanc nacré, comme un ciel balayé de vent",
    },
    {
        "id": "shadow_eveil", "base": "shadow", "nom": "Seigneur du Néant", "de": "du Sorcier des Ténèbres",
        "planche": "tenebres_eveil_marche.png",
        "corps": "même capuche profonde et même robe violet sombre et noire, mais sous la capuche il n'y a plus de "
                 "visage : un VIDE NOIR où brillent seulement deux grands yeux violets. Le bas de sa robe se défait "
                 "en VRILLES D'OMBRE qui finissent en petites mains griffues. L'orbe de sa main gauche est devenu "
                 "une ÉCLIPSE, un soleil noir cerclé d'un anneau violet vif. Deux chaînes d'argent pendent à sa "
                 "ceinture et des runes violettes luisent au bord de sa capuche",
        "aura": "violet profond et noir, avec un anneau d'éclipse lumineux derrière lui",
    },
    {
        "id": "invocateur_eveil", "base": "invocateur", "nom": "Maître des Légions", "de": "de l'Invocateur",
        "planche": "invocateur_eveil_marche.png",
        "corps": "mêmes cheveux noirs en épis, même visage découvert et même robe violette à liserés d'or, mais une "
                 "COURONNE DE CORNES NOIRES cerclée d'or sort de ses cheveux et ses yeux brillent de violet. Sa robe "
                 "est devenue un MANTEAU DE SEIGNEUR au col haut, brodé en bas de runes violettes lumineuses ; son "
                 "collier est une chaîne de petits crânes aux orbites violettes. Son bâton torsadé, dans la main "
                 "droite, porte une grande orbe où tourne un cercle de runes, et un grimoire enchaîné à l'œil "
                 "violet pend à sa hanche",
        "aura": "violet royal et or, comme la lueur d'un portail d'invocation",
    },
    {
        "id": "chrono_eveil", "base": "chrono", "nom": "Seigneur des Heures", "de": "du Chronomancien",
        "planche": "chrono_eveil_marche.png",
        "corps": "mêmes cheveux blancs en épis, même long manteau sarcelle à liserés de cuivre, mais une AURÉOLE "
                 "D'HORLOGE en laiton flotte derrière sa tête, un anneau gravé de chiffres romains avec deux "
                 "aiguilles. Le sablier qu'il porte au dos brille et son sable sarcelle remonte. Des ENGRENAGES DE "
                 "CUIVRE lui font des épaulières, son bâton est devenu un SCEPTRE surmonté d'une grande horloge à "
                 "cadran sarcelle, ses yeux s'allument de sarcelle vif, et des chiffres romains d'or sont brodés au "
                 "bas de son manteau",
        "aura": "sarcelle et cuivre doré, comme la lumière d'un cadran",
    },
    {
        "id": "peste_eveil", "base": "peste", "nom": "Seigneur du Fléau", "de": "du Mage de la Peste",
        "planche": "peste_eveil_marche.png",
        "corps": "même capuche et même long manteau presque noir à liserés vert acide, mais son masque est devenu un "
                 "CRÂNE-BEC DE BRONZE dont les deux verres ronds brûlent de vert acide. Le bas de son manteau est en "
                 "lambeaux, effrangé en pointes, des PLAQUES DE BRONZE gravées de runes couvrent ses épaules, et son "
                 "bâton tordu porte un ENCENSOIR de bronze ajouré plein d'un liquide vert qui luit. Les fioles de "
                 "sa ceinture sont plus nombreuses et bouillonnent",
        "aura": "vert acide et bronze sombre, comme une brume empoisonnée",
    },
    {
        "id": "supreme_eveil", "base": "supreme", "nom": "Archimage Primordial", "de": "du Sorcier Suprême",
        "planche": "supreme_eveil_marche.png",
        "corps": "même capuche profonde sur un visage d'ombre aux deux yeux violets, mais une AURÉOLE D'OR gravée de "
                 "quatre runes se dresse derrière sa capuche. Sa robe est devenue un MANTEAU DE NUIT ÉTOILÉE, noir "
                 "bleuté semé de petites étoiles d'or, avec un haut col d'or et de grandes épaulières d'or. Une "
                 "ÉTOLE D'OR descend sur sa poitrine, sertie de QUATRE GEMMES : rouge feu, bleu eau, ambre terre et "
                 "blanc nacré. Ses mains nues sont cerclées de bracelets d'or. Quatre orbes tournent autour de lui : "
                 "une de feu, une d'eau, une de terre et une d'air",
        "aura": "or lumineux sur un ciel de nuit étoilé, avec les quatre couleurs des éléments qui s'y mêlent",
    },
    {
        "id": "demon_eveil", "base": "demon", "nom": "Archidémon du Pacte", "de": "du Démon du Pacte",
        "planche": "demon_eveil_marche.png",
        "corps": "même visage de noble, même long manteau noir brodé d'or à doublure bordeaux et même gilet "
                 "cramoisi, mais le démon du pacte sort de lui : deux GRANDES CORNES noires luisantes jaillissent de "
                 "ses tempes, cerclées d'anneaux d'or, à pointe rouge sang incandescente. Ses cheveux ont poussé, "
                 "rejetés en arrière, aux pointes cramoisies ; ses yeux sont rouge sang à pupilles fendues d'or, et "
                 "un sceau d'or brûle sur son front. Le rubis de son jabot est devenu un CŒUR DE PACTE, un gros "
                 "cristal rouge serré dans des griffes d'or, d'où partent des fissures rouges sous la peau de son cou",
        "aura": "rouge sang et or, comme la lueur d'un pacte qui brûle",
    },
    {
        "id": "discorde_eveil", "base": "discorde", "nom": "Reine de la Discorde", "de": "de la Démone de la Discorde",
        "planche": "discorde_eveil_marche.png",
        "corps": "même visage, mêmes yeux verts, même long manteau vert sapin brodé d'argent, mais son chignon s'est "
                 "défait : ses longs cheveux noirs flottent derrière elle et leurs pointes se changent en FILS "
                 "D'ARGENT. Une COURONNE D'ARGENT à fines pointes d'aiguille ceint sa tête, sertie d'un œil "
                 "d'émeraude, et un TROISIÈME ŒIL vertical d'un vert émeraude lumineux s'est ouvert sur son front. "
                 "Deux fines cornes noires à pointe d'argent remontent vers l'arrière, et dans son dos se dresse "
                 "une CROIX DE MARIONNETTISTE d'argent d'où pendent des fils jusqu'à ses mains",
        # Jamais de rose ni de violet sur elle : c'est la couleur que le détourage efface sur ses planches.
        "aura": "vert émeraude profond et argent, comme un clair de lune sur une forêt",
    },
    {
        "id": "braise_eveil", "base": "braise", "nom": "Empereur des Cendres", "de": "du Roi de Braise",
        "planche": "braise_eveil_marche.png",
        "corps": "même visage d'homme au regard sévère et à la cicatrice, même armure d'or noirci, mais sa COURONNE "
                 "BRISÉE s'est reforgée, ses morceaux soudés par des coulées de lave et hérissés de hautes pointes "
                 "d'or, et un anneau de pointes de braise flotte au-dessus. Ses cheveux s'embrasent en FLAMMES "
                 "orange et ambre, ses yeux brûlent d'un ambre presque blanc et sa cicatrice laisse couler un filet "
                 "de lave. Les fissures de lave de son armure brillent, et une PLAQUE DE MAGMA bat au milieu de "
                 "son torse comme un cœur de forge",
        "aura": "ambre et orange de forge, sur un fond de cendres sombres",
    },
    {
        "id": "ecarlate_eveil", "base": "ecarlate", "nom": "Seigneur Écarlate", "de": "du Chevalier Écarlate",
        "planche": "ecarlate_eveil_marche.png",
        "corps": "mêmes longs cheveux blancs en queue basse, même armure samouraï de laque rouge sang bordée de noir, "
                 "mais le démon de sa lame se montre : un MASQUE DE DÉMON rouge et noir à crocs blancs lui couvre le "
                 "bas du visage, ses yeux sont rouge écarlate à pupille blanche fendue, et un CIMIER EN CROISSANT "
                 "noir bordé de rouge se dresse sur son front. Les pointes de ses cheveux rougissent comme trempées "
                 "dans le sang, et une LAME FANTÔME blanche cernée de rouge flotte en travers de son dos",
        # Un rouge franc, sans aucun bleu : avec un peu de bleu, le détourage lui retire son rouge.
        "aura": "rouge sang franc et noir, comme une nuit sous une lune rouge",
    },
    {
        "id": "geolier_eveil", "base": "geolier", "nom": "Gardien de l'Abîme", "de": "du Geôlier",
        "planche": "geolier_eveil_marche.png",
        "corps": "même armure d'obsidienne noire VIDE habitée par une flamme froide cyan, même heaume sans visage aux "
                 "yeux en fente cyan, mais le geôlier de l'abîme se révèle : son heaume est couronné de POINTES DE "
                 "GLACE noire d'où jaillit une plume de flamme blanche et cyan, une SERRURE lumineuse s'ouvre au "
                 "milieu de son plastron, de lourdes CHAÎNES à crochets s'enroulent autour de ses énormes gantelets "
                 "hérissés de givre, et un trousseau de grandes CLÉS spectrales cyan pend à son dos",
        # Grand et massif, pas chibi, comme sa forme de base ; aucun rose ni violet dans ses flammes.
        "aura": "cyan glacé et noir d'abîme, comme le fond d'une prison de glace",
    },
    {
        "id": "dragon_eveil", "base": "dragon", "nom": "Dragon Primordial", "de": "du Dragon des Abysses",
        "planche": "dragon_eveil_marche.png",
        "corps": "même dragon-démon bipède et massif aux écailles noir charbon et aux plaques rouge sang, mais le "
                 "premier feu du monde se réveille en lui : QUATRE CORNES d'obsidienne où coulent des filets de lave, "
                 "des yeux d'un blanc de magma, une gorge qui rougeoie entre ses crocs, et au milieu du torse un CŒUR "
                 "DE MAGMA jaune et blanc qui bat entre des côtes d'obsidienne. Des pointes d'obsidienne hérissent ses "
                 "épaules, la lave coule le long de ses bras, et ses ailes rouge sombre sont bordées de flammes",
        # Jamais doré : ce serait le Dragon d'or d'Aël. PAS chibi, comme sa forme de base.
        "aura": "magma orange et rouge sang, sur un fond d'obsidienne et de fumée",
    },
    {
        "id": "croupier_eveil", "base": "croupier", "nom": "Maître du Casino", "de": "du Croupier des Enfers",
        "planche": "croupier_eveil_marche.png",
        "corps": "même visage pâle au sourire en coin, mêmes yeux rouges, mêmes cheveux noirs plaqués et mêmes gants "
                 "blancs, mais le banquier des Enfers se révèle : un HAUT-DE-FORME noir à bande d'or, un as glissé "
                 "dans la bande, d'où sortent deux CORNES DORÉES ; un MONOCLE d'or dont le verre est une petite "
                 "roulette ; une QUEUE-DE-PIE bordeaux doublée d'or, les quatre enseignes brodées sur les revers ; une "
                 "chaîne de montre en or, et une canne noire au pommeau en forme de dé",
        # Un bordeaux sans bleu : le détourage retire le prune et le rose.
        "aura": "or de jetons et rouge de roulette, sur un fond de tapis vert sombre",
    },
    {
        "id": "avide_eveil", "base": "avide", "nom": "Faim Sans Fond", "de": "de l'Avide",
        "planche": "avide_eveil_marche.png",
        "corps": "même démon pur sang, massif et voûté, à la peau noir d'encre et sans yeux, mais sa faim l'a ouvert : "
                 "la GUEULE de son ventre s'ouvre jusqu'au cou, bordée de deux rangées de crocs ivoire, sa gorge "
                 "éclairée de vert bile ; une petite BOUCHE à crocs s'ouvre sur chaque avant-bras ; ses cornes de "
                 "bélier se sont FENDUES EN QUATRE autour d'une couronne de crocs, et une crête de vertèbres pointues "
                 "hérisse son dos ; des filets de bile coulent de ses bouches",
        # PAS chibi, toujours sans yeux ; ses gorges sont rouge très sombre, jamais roses.
        "aura": "vert bile et ivoire de crocs, sur un fond d'encre",
    },
    {
        "id": "lumiere_eveil", "base": "lumiere", "nom": "Étoile du Matin", "de": "du Porte-Lumière",
        "planche": "lumiere_eveil_marche.png",
        "corps": "même visage serein d'enfant, mêmes courts cheveux blonds et même lance dorée dans la main droite, "
                 "mais il est devenu un petit soleil : un grand DISQUE SOLAIRE d'or gravé de rayons se dresse "
                 "derrière sa tête, ses deux ailes sont devenues des AILES DE RAYONS, longues lames de lumière "
                 "blanche à cœur d'or, et son armure est d'or blanc, avec une ÉTOILE À HUIT BRANCHES d'or au milieu "
                 "du plastron. Ses yeux brillent d'or clair, la pointe de sa lance est une étoile de cristal blanc "
                 "cerclée d'or, et une courte cape blanche doublée d'or tombe de ses épaules. Deux ailes seulement",
        # Jamais de rose ni de violet : le blanc garde des ombres beiges.
        "aura": "or solaire et blanc chaud, comme un lever de soleil",
    },
    {
        "id": "mort_eveil", "base": "mort", "nom": "Faucheur des Âmes", "de": "de l'Ange de la Mort",
        "planche": "mort_eveil_marche.png",
        "corps": "même visage pâle couleur d'os aux yeux rouge braise, mêmes cheveux noirs et mêmes deux petites "
                 "cornes, même armure gris anthracite à liserés d'os sur une longue robe noire déchirée, mais il est "
                 "devenu la Mort elle-même : son AURÉOLE BRISÉE s'est ressoudée en un anneau complet de braise rouge "
                 "gravé de runes, une CAPUCHE NOIRE déchirée percée par ses cornes lui tombe sur la tête, ses deux ailes "
                 "de plumes noires finissent en flammes de braise, et il tient une FAUX DOUBLE, deux lames noires "
                 "bordées de rouge de part et d'autre du manche d'os. Une chaîne d'os et un petit sablier noir pendent "
                 "à sa taille. Un ange d'abord : le visage reste visible, jamais un crâne",
        # Un rouge braise qui tire sur l'orange : pas de rose ni de violet.
        "aura": "noir profond et rouge braise, avec une lune rouge pâle derrière lui",
    },
    {
        "id": "cherubin_eveil", "base": "cherubin", "nom": "Gardien du Trône", "de": "du Chérubin",
        "planche": "cherubin_eveil_marche.png",
        "corps": "même jeune ange au visage grave et calme, mêmes yeux bleu saphir, mêmes cheveux d'or foncé courts "
                 "et bouclés, même tunique de lin blanc, même cuirasse de bronze poli et même ceinture saphir, mais il "
                 "est devenu le chérubin du Trône : ses QUATRE AILES sont couvertes d'yeux d'or calmes et finissent en "
                 "langues de flamme saphir, une ROUE DANS UNE ROUE d'or à yeux, à jante de flamme saphir, touche "
                 "l'arrière de sa tête, il tient une GRANDE ÉPÉE FLAMBOYANTE à lame de flamme saphir ondulée, et sa "
                 "cuirasse porte quatre petites faces gravées en or. Un seul visage, le sien : un ange, jamais un "
                 "monstre. Le saphir reste un bleu franc, jamais violet",
        # Jamais de violet : le saphir tomberait au détourage.
        "aura": "bleu saphir profond et or, avec un grand cercle de flamme saphir derrière lui",
    },
    {
        "id": "ciel_eveil", "base": "ciel", "nom": "Séraphin", "de": "de l'Archange du Ciel",
        "planche": "ciel_eveil_marche.png",
        "corps": "même jeune archange guerrier au visage calme et décidé, mêmes yeux émeraude, mêmes cheveux blancs "
                 "courts, même diadème d'or, même armure légère blanche à bords dorés et même tabard court émeraude, "
                 "mais il est devenu un séraphin : il porte SIX AILES blanches à pointes d'or, en trois paires empilées "
                 "dans son dos, une AURÉOLE D'OR cerclée de petites flammes émeraude au-dessus de la tête, et sa LANCE "
                 "D'OR a une pointe de flamme émeraude. Une cloche d'or gravée pend à sa hanche. Les ombres de son "
                 "blanc sont gris-vert, jamais roses",
        # Jamais de rose ni de violet : le blanc garde des ombres gris-vert.
        "aura": "ciel blanc lumineux, or et émeraude, comme une percée de lumière dans les nuages",
    },
    {
        "id": "acier_eveil", "base": "acier", "nom": "Forgeron Céleste", "de": "de l'Archange d'Acier",
        "planche": "acier_eveil_marche.png",
        "corps": "même ange guerrier massif et très large d'épaules, même armure de plates intégrale gris-bleu, même "
                 "heaume fermé sans visage et mêmes deux ailes de lames d'acier, mais il est devenu la forge du ciel : "
                 "les fentes entre ses plaques FLAMBOIENT d'un orange vif de métal en fusion, une COURONNE D'ENCLUME "
                 "d'or est posée sur son heaume, le tranchant de chaque lame de ses ailes rougeoie d'orange, et il "
                 "tient un énorme MARTEAU-FORGE cerclé d'or au cœur incandescent. La lueur de son heaume est plus "
                 "vive. L'acier gris-bleu reste sa couleur, l'or et l'orange sont en touches",
        # Un orange franc de forge : jamais de rose ni de violet, même dans le fond.
        "aura": "gris acier sombre et orange de forge, avec une lueur de métal en fusion derrière lui",
    },
    {
        "id": "etoiles_eveil", "base": "etoiles", "nom": "Reine du Firmament", "de": "de l'Ange des Étoiles",
        "planche": "etoiles_eveil_marche.png", "elle": True,
        "corps": "même femme adulte au visage calme, même longue tresse argentée, même longue robe bleu nuit à "
                 "liserés d'argent et mêmes ailes bleu nuit semées d'étoiles, mais elle est devenue la reine de la "
                 "nuit : sa couronne en croissant d'argent porte CINQ PETITES ÉTOILES D'OR PÂLE dressées comme des "
                 "pointes, une longue CAPE DE NUIT bleu nuit doublée d'argent, semée d'étoiles et de constellations "
                 "dessinées, tombe de ses épaules, et son sceptre d'argent porte une GRANDE ÉTOILE blanche à quatre "
                 "branches, à cœur d'or pâle, cerclée d'un anneau d'argent. Ses yeux brillent d'un bleu stellaire "
                 "clair. Le bleu nuit et l'argent restent ses couleurs, l'or n'est qu'en touches",
        # Sa nuit est bleue : jamais de violet ni de rose, même dans le fond.
        "aura": "bleu nuit profond semé de petites étoiles blanches, avec une lueur bleu clair derrière elle",
    },
]


def eveil_page(eveil: dict) -> str:
    return f"""# portrait_{eveil['id']} — {eveil['nom']}

{ENTETE}
L'Éveil {eveil['de']}, pour son bouton ÉVEIL de l'écran de sélection. Joins **deux images** à ChatGPT :

1. `assets/peso&cover/interface/portraits/portrait_{eveil['base']}.png` — son portrait actuel : le STYLE, le
   cadrage et le visage à garder ;
2. `assets/peso&cover/mages/{eveil['planche']}` — sa planche de marche éveillée : CE QU'{'ELLE' if eveil.get('elle') else 'IL'} DEVIENT.

Résultat attendu : `portrait_{eveil['id']}.png` dans `assets/peso&cover/interface/portraits/`.

```
Illustration de personnage pour un écran de sélection de jeu de rôle mobile,
style cartoon coloré à contours nets, personnage aux proportions héroïques
légèrement stylisées, EXACTEMENT la même facture et le même cadrage que la
PREMIÈRE image jointe.

La première image est le portrait du personnage. Dessine LE MÊME personnage,
transformé dans sa forme éveillée : la seconde image jointe montre cette forme
en petit, vue de dessus. Reprends ses couleurs et ses attributs, mais dessine-le
comme la première image : de face, en grand, avec son visage.

FORMAT : une seule image de {PORTRAIT_SIZE}.

SUJET — {eveil['nom']} : {eveil['corps']}. {'Elle' if eveil.get('elle') else 'Il'} doit paraître plus puissant{'e' if eveil.get('elle') else ''} et
plus lumineux que dans la première image, sans devenir un autre personnage.

FOND : une simple nappe de couleur {eveil['aura']}, plus lumineuse derrière le
personnage et plus sombre vers les bords, comme un halo. Rien d'autre : ni
paysage, ni objet, ni motif.

{COMMUN}
- aucune pose ni grille de la seconde image : une seule figure, en grand
- le fond n'est JAMAIS le magenta uni de la seconde image : c'est la nappe de
  couleur décrite plus haut
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Il ne ressemble plus au mage | rappeler « LE MÊME personnage que la première image, transformé » |
| Il est dessiné petit, vu de dessus | rappeler « de face, en grand, comme la première image » |
| Un cadre ou une bordure apparaît | rappeler « aucun cadre, le jeu ajoute le sien » |
| Le fond devient un décor | rappeler « une nappe de couleur, pas une scène » |
| Le fond est resté magenta | rappeler « la nappe décrite, jamais le magenta de la planche » ; sinon `NAPPES` dans `build_menu.py` le repeint |

Voir [../../PROMPT_MENU.md](../../PROMPT_MENU.md).
"""


def portrait_page(mage: dict) -> str:
    return f"""# portrait_{mage['id']} — {mage['nom']}

{ENTETE}
**Joins `../ref/ref_carte.png` à ChatGPT** — c'est une carte de la maquette
`selection_mage1.jpeg` — et dis « même style de personnage, mais SANS le cadre
ni le texte ».

Résultat attendu : `portrait_{mage['id']}.png` dans
`assets/peso&cover/interface/portraits/`.

```
Illustration de personnage pour un écran de sélection de jeu de rôle mobile,
style cartoon coloré à contours nets, personnage aux proportions héroïques
légèrement stylisées, même facture que l'image de référence jointe.

FORMAT : une seule image de {PORTRAIT_SIZE}.

SUJET — {mage['nom']} : {mage['corps']}.

FOND : une simple nappe de couleur {mage['aura']}, plus lumineuse derrière le
personnage et plus sombre vers les bords, comme un halo. Rien d'autre : ni
paysage, ni objet, ni motif.

{COMMUN}
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Un cadre ou une bordure apparaît | rappeler « aucun cadre, le jeu ajoute le sien » |
| Le personnage est coupé aux genoux | rappeler « ENTIER, on voit ses pieds » |
| Le fond devient un décor | rappeler « une nappe de couleur, pas une scène » |
| Le visage ne ressemble pas au sprite du jeu | rejoindre la planche `mages/mage_*.png` en seconde référence |

⚠️ Le NOM du mage n'est jamais dans l'image : c'est du texte dessiné par le jeu,
qui doit rester lisible à toutes les tailles. Voir
[../../PROMPT_MENU.md](../../PROMPT_MENU.md).
"""


def cadre_page() -> str:
    return f"""# cadre_carte — le cadre des huit cartes

{ENTETE}
**Joins `../ref/ref_carte.png` à ChatGPT** et dis « le CADRE seul de cette
carte, sans le personnage ni le texte ».

⚠️ **Une seule image pour les huit mages.** C'est la décision qui tient tout
l'écran : demander « le mage du Feu dans son cadre » huit fois donnerait huit
cadres différents — épaisseurs, gemmes, coins et vignes ne tomberaient jamais
deux fois pareil — et une rangée de huit cartes mal assorties est PIRE qu'une
rangée sans cadre. Le jeu teinte ce cadre unique à la couleur de chaque élément.

Résultat attendu : `cadre_carte.png` dans
`assets/peso&cover/interface/portraits/`.

```
Élément d'interface pour un jeu de rôle mobile, style cartoon coloré à contours
nets, même facture que l'image de référence jointe.

FORMAT : une seule image de {PORTRAIT_SIZE}.

SUJET : un CADRE DE CARTE VIDE, vu de face. Bordure de pierre grise sculptée
rehaussée d'or, angles renforcés, quelques vignes qui courent sur les côtés. Au
MILIEU DU BORD SUPÉRIEUR, un sertissage rond vide destiné à recevoir une gemme —
dessine le sertissage, PAS la gemme. Le cadre a une légère épaisseur, éclairée
par le haut.

L'INTÉRIEUR DU CADRE EST ENTIÈREMENT MAGENTA PUR UNI (#FF00FF), sans dégradé et
sans ombre : c'est la fenêtre où le jeu posera le portrait, et le magenta se
détoure au pixel près. Le magenta remplit aussi les quatre coins autour du cadre.

RÈGLES ABSOLUES :
- le cadre est GRIS et OR, sans aucune couleur d'élément : le jeu le teinte
  lui-même en rouge, bleu, vert, violet selon le mage. Un cadre déjà coloré
  donnerait huit teintes fausses
- la bordure fait environ un vingtième de la largeur de l'image, RÉGULIÈRE sur
  les quatre côtés
- aucun texte, aucune plaque de nom, aucun chiffre
- aucun personnage, aucun décor, aucun objet dans la fenêtre
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| L'intérieur n'est pas magenta | c'est bloquant : sans lui, pas de fenêtre. Relancer |
| Le cadre est doré-rouge ou coloré | rappeler « GRIS et OR, le jeu le teinte » |
| Une gemme est dessinée dans le sertissage | rappeler « le sertissage, PAS la gemme » |
| La bordure est plus épaisse en bas | rappeler « RÉGULIÈRE sur les quatre côtés » |
"""


def fond_page() -> str:
    return f"""# fond_selection — le fond de la page « Choisis ton mage »

{ENTETE}
**Joins `../ref/ref_fond.png` à ChatGPT** — c'est le fond de la maquette — et
dis « la même ambiance, en plein écran, SANS aucun élément d'interface ».

Résultat attendu : `fond_selection.png` dans
`assets/peso&cover/interface/`.

```
Illustration de fond pour un menu de jeu de rôle mobile, style cartoon coloré à
contours nets, même ambiance et même palette que l'image de référence jointe.

FORMAT : une seule image de 1536 x 864 pixels (rapport 16:9, paysage).

SUJET : des RUINES DE PIERRE ENVAHIES DE VÉGÉTATION, la nuit. Colonnes brisées
et arches couvertes de lierre au premier plan à gauche et à droite, un sol de
dalles au premier plan en bas, des montagnes sombres et un ciel de nuit étoilé au
fond. Quelques cristaux bleus et violets qui luisent doucement entre les pierres,
et de rares lucioles. Palette : bleu nuit profond, vert mousse sombre, gris
pierre, avec les cristaux comme seules notes lumineuses.

RÈGLE LA PLUS IMPORTANTE — LE CENTRE RESTE CALME :
la moitié centrale de l'image doit être SOMBRE, FLOUE et sans détail : c'est là
que le jeu écrit le nom du mage, sa description et la liste de ses sorts, et un
décor chargé rendrait ce texte illisible. Toute la matière intéressante — les
colonnes, le lierre, les cristaux — se tient sur les BORDS et dans les COINS.

AUTRES RÈGLES ABSOLUES :
- aucun élément d'interface : ni cadre, ni bouton, ni carte, ni panneau
- aucun TEXTE, aucun titre, aucun logo
- aucun personnage, aucune créature
- aucune source de lumière forte au centre, aucun rayon qui traverse l'image
- l'image porte jusqu'aux quatre bords, sans vignette dessinée ni cadre noir
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le centre est chargé et le texte devient illisible | c'est le défaut bloquant : rappeler « la moitié centrale SOMBRE et sans détail » |
| Un titre ou un bouton apparaît | rappeler « aucun élément d'interface, aucun texte » |
| L'image est trop claire | rappeler « la nuit, les cristaux sont les SEULES notes lumineuses » |

⚠️ Le jeu assombrit encore ce fond derrière la fiche du mage. Une image déjà
sombre au centre laisse cette marge ; une image claire ne se rattrape pas.
"""


def index_page() -> str:
    lignes = "\n".join(
        f"| {m['nom']} | {m['element']} | `{m['couleur']}` | "
        f"[portrait_{m['id']}](prompts/menu/portrait_{m['id']}.md) |"
        for m in MAGES)
    eveils = "\n".join(
        f"| {e['nom']} | {e['base']} | [portrait_{e['id']}](prompts/menu/portrait_{e['id']}.md) |"
        for e in EVEILS)
    return f"""# L'écran « Choisis ton mage » — index des prompts

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
{lignes}

## Les portraits des Éveils

Le bouton ÉVEIL de la fiche montre la forme éveillée du mage. Chaque prompt joint le portrait du mage ET sa
planche de marche éveillée. Tant qu'un portrait manque, la carte montre le sprite de l'Éveil.

| Éveil | Mage | Prompt |
|---|---|---|
{eveils}

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
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for mage in MAGES:
        (OUT / f"portrait_{mage['id']}.md").write_text(
            portrait_page(mage), encoding="utf-8")
    for eveil in EVEILS:
        (OUT / f"portrait_{eveil['id']}.md").write_text(
            eveil_page(eveil), encoding="utf-8")
    (OUT / "cadre_carte.md").write_text(cadre_page(), encoding="utf-8")
    (OUT / "fond_selection.md").write_text(fond_page(), encoding="utf-8")
    Path("docs/PROMPT_MENU.md").write_text(index_page(), encoding="utf-8")
    print(f"{len(MAGES)} portraits + {len(EVEILS)} éveils + cadre + fond -> {OUT}/")
    print("index -> docs/PROMPT_MENU.md")


if __name__ == "__main__":
    main()
