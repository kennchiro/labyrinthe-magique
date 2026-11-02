#!/usr/bin/env python3
"""Les prompts des dix boss de fin de stage : une fiche par boss, dans `docs/prompts/boss/`.

    tools/.venv/bin/python tools/build_prompts_boss.py     # DEPUIS LA RACINE

Même gabarit que les ennemis, donc même fabrique : marche et attaque viennent de
`fiche()`. Un boss demande en plus une TROISIÈME planche, sa scène : il arrive, lance
son attaque de loin, tombe. Elle est dessinée de face seulement, parce que ces trois
moments ne dépendent pas de la direction où il regardait. Trois orientations de plus
coûteraient deux images par boss pour des poses qu'on voit à peine.

Quatrième planche, sa PORTÉE : la zone qui s'allume au sol avant le coup, puis l'effet
de sa spécialité. Elle est à part parce que le jeu la pose LOIN du boss, autant de fois
qu'il y a de cases menacées. C'est elle qui laisse au joueur le temps de fuir.

⚠️ AUCUN ROSE SUR UN BOSS. Le fond à effacer est magenta, et une brume violette d'un
autre monstre a déjà été mesurée plus magenta que son ombre. Le violet est permis s'il
tire franchement vers le bleu : c'est ce qui compte aux stages 5 et 9.
"""

from pathlib import Path
import sys

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))

from build_prompts_enemies import BLOCKING_TOP, CELL, COLUMNS, HEADER, ROWS, fiche, sheet_block

OUT = Path("docs/prompts/boss")
## Le grand portrait de la planche `boss.png`, seul : joindre la planche entière ferait
## recopier sa mise en page et son fond violet.
ROI_SOURCE = Path("assets/peso&cover/creatures/boss.png")
ROI_BOX = (940, 0, 1536, 500)
ROI_REF = OUT / "ref_roi_dechu.png"

NO_KEY = ("AUCUN ROSE ET AUCUN MAGENTA sur la créature ni dans ses effets : ce serait"
          " effacé avec le fond")
ONE_SIZE = ("ce qu'elle porte ne sort JAMAIS de sa case : plie ses membres plutôt que de"
            " réduire la créature, de la même taille partout")
## Ajouté à chaque description. Une case de 256 ne donne aucune échelle : sans repère, le
## générateur dessine des personnages. Il faut donc nommer le mage et les proportions.
## L'utilisateur veut des boss HUMANOÏDES, qui incarnent leur nom, et non des animaux.
MONSTROUS = (" ⚠️ C'EST UN MONSTRE HUMANOÏDE : il se tient DEBOUT sur DEUX JAMBES, avec"
             " DEUX bras, un torse droit, un cou et une tête à leur place, les proportions d'un"
             " homme géant, jamais voûté comme un singe. JAMAIS à quatre"
             " pattes, jamais un animal, jamais un humain ordinaire. Il reste effrayant et"
             " MASSIF, aux membres épais, griffes ou crocs bien visibles, jamais mignon,"
             " sans les proportions d'un enfant. IL EST GRAND : debout à côté d'un mage"
             " humain, il le dépasse nettement, d'environ une demi-hauteur de plus. Cette"
             " masse doit se lire sur la silhouette.")
## Hauteur du corps à l'écran, en pixels, à poser dans le bestiaire : le dessin ne la
## décide pas. Le mage en fait 38 et le Seigneur Démon, le plus grand ennemi, 58.
BOSS_BODY = 60
ONLY_ROWS = ("ne dessine AUCUNE planche de plus, seulement les trois rangées demandées")

## Temps d'alerte et intervalle entre deux attaques de loin, en secondes, du stage 1 au
## stage 10. Un point de départ, à régler à l'essai : le dernier boss prévient moins
## longtemps et frappe plus souvent, mais on a toujours le temps de sortir de la zone.
ALERT_RANGE = (1.6, 0.9)
EVERY_RANGE = (7.0, 4.0)

## Les deux formes de zone. La ronde se pose sur une case, la bande se met bout à bout.
ROUND = ("un ROND parfait vu du dessus, centré dans la case, large de 90 % de la case,"
         " sans toucher les bords")
## Fermée sur les côtés ou posée dans un cercle, la bande ne se raccorde plus : c'est ce
## que les premières planches ont rendu.
BAND = ("une BANDE horizontale vue du dessus, haute de 60 % de la case, qui va exactement"
        " du bord gauche au bord droit de la case : le jeu met ces cases bout à bout pour"
        " tracer une ligne continue. Son contour ne court QUE le long de son bord haut et de"
        " son bord bas, droit et sans angle. JAMAIS de contour à gauche ni à droite, jamais"
        " de cercle ni de cadre fermé")

## Par boss : sa portée en jeu, la forme de sa zone, ce qu'on voit dedans pendant
## l'alerte, et ce qui en sort quand le coup tombe.
SPECIALS = {
    "boss_sylvain": {
        "reach": "3 cases marquées autour du mage", "zone": ROUND,
        "warn": "de la terre brune qui se fissure, avec de petites pousses vertes",
        "hit": "de grosses racines brunes griffues jaillissent du sol vers le haut, avec"
               " des mottes de terre",
    },
    "boss_oiseau_tonnerre": {
        "reach": "toute une rangée de 7 cases", "zone": BAND,
        "warn": "un sol bleu nuit parcouru de petites étincelles jaunes",
        "hit": "un gros éclair jaune et blanc tombe du haut de la case au milieu de la"
               " bande et éclate en étincelles",
    },
    "boss_scorpion": {
        "reach": "2 cases autour de l'endroit où il ressort", "zone": ROUND,
        "warn": "un tourbillon de sable clair en spirale, avec quelques braises orange",
        "hit": "le sable explose vers le haut en une gerbe de sable et de braises orange",
    },
    "boss_behemoth": {
        "reach": "un couloir de 6 cases devant lui", "zone": BAND,
        "warn": "une eau turquoise agitée de petites vaguelettes",
        "hit": "une grande vague turquoise à crête d'écume blanche se dresse sur toute la"
               " largeur de la bande",
    },
    "boss_araignee": {
        "reach": "4 cases marquées autour du mage", "zone": ROUND,
        "warn": "un sol indigo d'où pointent de petits éclats de cristal cyan",
        "hit": "un bouquet de hautes pointes de cristal cyan et indigo jaillit du sol",
    },
    "boss_yeti": {
        "reach": "4 cases marquées autour du mage", "zone": ROUND,
        "warn": "une ombre bleu sombre avec du givre, l'ombre du bloc qui va tomber",
        "hit": "un gros bloc de glace bleue tombe du haut de la case, s'écrase et se brise"
               " en éclats, dans un nuage de neige",
    },
    "boss_mere_ronce": {
        "reach": "un couloir de 5 cases", "zone": BAND,
        "warn": "un sol vert sombre d'où sortent de petites épines noires",
        "hit": "un haut mur de ronces noires hérissées d'épines jaillit sur toute la largeur"
               " de la bande",
    },
    "boss_idole": {
        "reach": "un couloir de 5 cases devant elle", "zone": BAND,
        "warn": "une dalle de pierre fissurée, dont les fissures brillent en vert jade",
        "hit": "une onde tranchante de lumière jade traverse la bande, de gauche à droite,"
               " avec des éclats de pierre",
    },
    "boss_roi_dechu": {
        "reach": "3 cases marquées autour du mage", "zone": ROUND,
        "warn": "un cercle noir bleuté, gravé de runes violet bleuté",
        "hit": "le cercle s'ouvre sur un vide noir, et un crâne ivoire aux yeux violet"
               " bleuté en sort vers le haut, entouré d'éclats",
    },
    "boss_chimere": {
        "reach": "5 cases marquées autour du mage", "zone": ROUND,
        "warn": "une dalle de marbre blanc, gravée d'un cercle bleu azur",
        "hit": "une grande lame d'or tombe du haut de la case et se plante au centre, dans"
               " un éclat de lumière azur",
    },
}

## Par boss : tout ce que `fiche()` attend, plus son stage, son `power` (une phrase pour
## le tableau), et les huit temps de chaque rangée de sa scène (`rise`, `cast`, `fall`).
BOSSES = [
    {
        "stage": 1, "terrain": "La Forêt",
        "file": "boss_sylvain", "id": "boss_sylvain", "name": "Le Sylvain Ancien",
        "medium_steps": True,
        "worst": "Le premier boss du jeu : il doit impressionner sans punir, car le stage 1"
                 " sert à apprendre. Un arbre qui marche se lit d'un coup d'œil dans la"
                 " forêt, et sa lenteur laisse le temps de comprendre chaque geste.",
        "arrival": "Lent et massif, il frappe au contact et fait jaillir des racines sur les"
                   " cases qu'il a marquées. Une seule attaque de loin, longue à armer : c'est le boss"
                   " qui apprend à regarder le sol.",
        "power": "des racines jaillissent des cases marquées au sol",
        "look": "LE SYLVAIN ANCIEN, un homme-arbre géant, debout. Corps d'homme fait d'un tronc"
                " d'écorce brun sombre, très large aux épaules, avec une taille marquée, couronne de feuillage vert vif sur"
                " la tête et les épaules, dont pendent des lianes. Visage creusé dans"
                " l'écorce : deux yeux vert lumineux, une large gueule aux crocs de bois. Au milieu de la"
                " poitrine, entre deux branches, un GROS CRISTAL VERT luisant. Deux longs"
                " bras de branches noueuses aux mains griffues. Deux jambes de racines"
                " épaisses, bien distinctes, aux pieds de racines écartées. Quelques"
                " champignons orange et de la mousse sur les hanches.",
        "walk": "une MARCHE DE BOSS lente : pas lourds, les bras ballants, le feuillage et"
                " les lianes qui balancent à contretemps",
        "strike": [
            "il se campe, le bras droit recule",
            "il lève le bras droit très haut, les branches s'ouvrent",
            "le bras est au plus haut, le cristal de sa poitrine brille",
            "il abat le bras, des feuilles se détachent",
            "L'IMPACT : le poing de branches au bout de sa course, DEVANT lui, avec une"
            " gerbe de terre et de feuilles au plus large",
            "la gerbe retombe, le poing touche presque le sol",
            "il relève le bras, le buste se redresse",
            "il rejoint la pose de marche",
        ],
        "rise": [
            "il est immobile, tête baissée, comme un arbre endormi, les yeux éteints",
            "un œil vert s'allume",
            "les deux yeux brillent, le cristal s'allume",
            "il relève la tête, des feuilles tombent",
            "il redresse le buste, les bras s'écartent",
            "il ouvre grand les bras",
            "IL RUGIT : bouche ouverte, bras en l'air, cristal au plus fort",
            "il rejoint la pose de marche",
        ],
        "cast": [
            "il se campe, les bras écartés",
            "il joint les mains au-dessus de sa tête",
            "le cristal de sa poitrine brille plus fort",
            "le cristal est au plus fort, ses racines vibrent",
            "il plonge les deux mains vers le sol",
            "LE GESTE : ses mains touchent le sol, ses pieds-racines s'enfoncent",
            "il reste penché, les mains au sol",
            "il se redresse et rejoint la pose de marche",
        ],
        "fall": [
            "il recule d'un pas, une main sur le cristal fissuré",
            "le cristal se fend, sa lumière vacille",
            "ses genoux plient, des feuilles tombent en masse",
            "il tombe à genoux, la tête penche",
            "il bascule en avant, le feuillage se clairsème",
            "il est presque couché, les yeux s'éteignent",
            "il est à terre, le cristal éteint",
            "il n'est plus qu'une souche et des branches, immobiles",
        ],
        "extra": ["de dos, on voit le tronc, le feuillage et les lianes, sans cristal ni"
                  " visage", ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 2, "terrain": "Le Canyon de la Foudre",
        "file": "boss_oiseau_tonnerre", "id": "boss_oiseau_tonnerre",
        "name": "L'Oiseau-Tonnerre", "medium_steps": True,
        "worst": "Le canyon est bleu et électrique. Un géant à tête de rapace, les ailes"
                 " serrées dans le dos, s'y lit d'un coup d'œil, et sa foudre oblige à quitter"
                 " les longues lignes droites.",
        "arrival": "Il avance à pas lourds et lève le bras vers le ciel : la foudre tombe sur"
                   " toute une rangée marquée, et il suffit d'en sortir. Il apprend ce geste"
                   " avant les tireurs des stages 6 et 7.",
        "power": "la foudre tombe sur une rangée de cases marquée",
        "look": "L'OISEAU-TONNERRE, un colosse homme-oiseau, debout comme un guerrier. Torse"
                " large et bras épais couverts de plumes bleu nuit, poitrine gris clair, mains"
                " griffues aux griffes jaune or. Tête de rapace monstrueux au bec recourbé jaune"
                " or bordé de crocs, quatre yeux blancs lumineux, huppe de plumes dressées dont"
                " la pointe est jaune. Dans le dos, deux ailes bleu électrique parcourues de"
                " veines d'éclair jaune pâle, TOUJOURS À MOITIÉ REPLIÉES derrière les épaules."
                " Deux jambes puissantes aux pieds de serres jaune or. Courte queue de plumes en"
                " éventail, derrière les jambes.",
        "walk": "une MARCHE DE BOSS pesante : pas lourds sur ses serres, les bras ballants,"
                " les ailes repliées bougent à peine, la huppe suit à contretemps",
        "strike": [
            "il se campe, le bras droit recule, griffes ouvertes",
            "il lève le bras droit, des éclairs courent sur ses plumes",
            "le bras est au plus haut, le bec s'ouvre",
            "il abat le bras, griffes en avant",
            "L'IMPACT : les griffes au bout de leur course, DEVANT lui, avec un éclat de"
            " foudre jaune au plus large",
            "l'éclat se dissipe, le bras reste bas",
            "il relève le buste, le bras revient",
            "il rejoint la pose de marche",
        ],
        "rise": [
            "un genou à terre, tête baissée, les ailes serrées autour de lui, les yeux éteints",
            "un éclair court sur son dos, un œil s'allume",
            "les quatre yeux brillent, la huppe se dresse",
            "il relève la tête",
            "il se met debout, les bras le long du corps",
            "il écarte les bras, des éclairs courent sur ses plumes",
            "IL CRIE : bec grand ouvert, bras levés, ailes à moitié ouvertes",
            "il rejoint la pose de marche",
        ],
        "cast": [
            "il se campe, les jambes écartées",
            "il lève le bras droit vers le ciel",
            "des éclairs se rassemblent autour de sa main levée",
            "tout son corps s'illumine de jaune pâle",
            "il abaisse le bras d'un coup, le doigt pointé devant lui",
            "LE GESTE : le bras tendu, le bec ouvert, ses plumes crépitent",
            "il garde la pose, les éclairs s'éteignent",
            "il rejoint la pose de marche",
        ],
        "fall": [
            "il recule d'un pas, une main sur la poitrine",
            "des plumes s'arrachent, ses éclairs vacillent",
            "une aile pend, il titube",
            "il tombe à genoux, la tête penche",
            "il bascule en avant, les bras au sol",
            "il s'affaisse, la tête tombe",
            "il est couché, les yeux éteints",
            "il ne bouge plus, quelques plumes posées autour de lui",
        ],
        "extra": ["⚠️ LES AILES RESTENT À MOITIÉ REPLIÉES : elles ne dépassent jamais de la"
                  " largeur des épaules de plus d'une main, et ne sortent JAMAIS de la case."
                  " Chaque case contient une pose, et une seule",
                  "de dos, on voit le dos bleu nuit et les ailes repliées",
                  "de profil, le bec est à droite, la queue à gauche",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 3, "terrain": "Les Dunes de Feu",
        "file": "boss_scorpion", "id": "boss_scorpion", "name": "Le Scorpion des Braises",
        "medium_steps": True,
        "worst": "Les dunes sont orange et le désert appelle un scorpion. Sa queue dressée"
                 " se voit par-dessus sa tête et annonce où il va frapper, et ses bras à pinces"
                 " disent son nom même debout : c'est un boss qui se lit à sa silhouette.",
        "arrival": "Il s'enfonce dans le sable et ressort plus loin, là où un tourbillon"
                   " l'annonce. Sa queue crache une boule de braise en ligne droite.",
        "power": "il s'enfouit, ressort sous un tourbillon de sable annoncé",
        "look": "LE SCORPION DES BRAISES, un guerrier géant homme-scorpion, debout. Armure"
                " naturelle de carapace d'obsidienne noire aux plaques bordées d'orange, fissures"
                " de lave orange lumineuse entre les plaques. Torse large, tête casquée de"
                " carapace, petits yeux rouge feu groupés, mandibules ivoire à la place de la"
                " bouche. Deux bras épais qui finissent par de GRANDES PINCES noires et orange."
                " Deux jambes de carapace, très épaisses, aux pieds griffus. Du bas de son dos"
                " part une longue queue articulée, dressée au-dessus de sa tête, terminée par un"
                " dard de braise orange incandescent. Un peu de sable clair sur les pieds.",
        "walk": "une MARCHE DE BOSS : pas lourds, les pinces tenues devant lui, la queue"
                " oscille à peine au-dessus de sa tête",
        "strike": [
            "il se campe, les pinces écartées",
            "la queue recule au-dessus de sa tête, le dard s'allume",
            "le dard est au plus brillant, tout le corps est tendu",
            "la queue part vers l'avant, par-dessus sa tête",
            "L'IMPACT : le dard au bout de sa course, DEVANT lui, avec une gerbe de braises"
            " orange au plus large",
            "la gerbe s'éteint, le dard reste bas",
            "la queue remonte, les pinces se referment",
            "il rejoint la pose de marche",
        ],
        "rise": [
            "seuls le haut de sa tête et le dard sortent, le corps est tassé au plus bas",
            "il remonte un peu, du sable coule de ses épaules",
            "les épaules et les pinces se dégagent",
            "il pousse sur ses jambes, les fissures s'allument",
            "il est debout, la queue se dresse",
            "les pinces s'ouvrent en grand",
            "IL MENACE : pinces levées, queue dressée, dard au plus brillant",
            "il rejoint la pose de marche",
        ],
        "cast": [
            "il s'arrête, les pinces baissées",
            "il croise les pinces devant son torse",
            "ses pieds fouillent, du sable vole sur les côtés",
            "il s'accroupit, le sable monte à ses genoux",
            "il est enfoncé jusqu'à la taille, la queue encore dressée",
            "LE GESTE : seuls sa tête et son dard dépassent encore",
            "le mouvement s'inverse, il remonte",
            "il rejoint la pose de marche",
        ],
        "fall": [
            "il se cabre, les pinces en l'air",
            "ses fissures de lave clignotent",
            "la queue vacille et penche",
            "un genou cède, il tombe à genoux",
            "il s'écrase en avant, la queue retombe",
            "les pinces s'ouvrent et se posent au sol",
            "les fissures s'éteignent une à une",
            "il ne bouge plus, carapace noire et froide",
        ],
        "extra": ["ON COMPTE DEUX JAMBES ET DEUX BRAS À PINCES, jamais de pattes en plus",
                  "de profil, la tête et les pinces sont à droite, la queue part de ses reins"
                  " vers la gauche puis remonte au-dessus de sa tête",
                  "de dos, la queue est au premier plan et les pinces dépassent à peine",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 4, "terrain": "Les Rivages Océaniques",
        "file": "boss_behemoth", "id": "boss_behemoth", "name": "Le Béhémoth des Abysses",
        "medium_steps": True,
        "worst": "Le stage 4 amène l'Ombre et la Gelée, sans visage ni l'une ni l'autre. Une"
                 " énorme géant remonté des fonds apporte une gueule qu'on n'oublie pas, et"
                 " une pince dont la portée se voit.",
        "arrival": "Il frappe de sa pince au contact et lance son pouvoir de loin : une vague"
                   " balaie un couloir, blesse le mage et le repousse.",
        "power": "une vague balaie un couloir, blesse et repousse le mage",
        "look": "LE BÉHÉMOTH DES ABYSSES, un énorme monstre marin à forme humaine, qui marche debout. Corps"
                " d'homme géant, torse droit, à la peau bleu-vert sombre, ventre gris pâle. Tête"
                " de géant monstrueux, bien dégagée des épaules : immense gueule"
                " ouverte aux longues dents ivoire en désordre, petits yeux turquoise"
                " lumineux, et sur le front une antenne terminée par un LEURRE turquoise"
                " qui brille. Le bras droit finit par une ÉNORME PINCE de crabe orange"
                " sombre, le bras gauche par une grosse main palmée griffue. Dos couvert de"
                " coraux ORANGE, de coquillages et d'algues vert sombre. Deux longues"
                " jambes très épaisses, pieds palmés griffus.",
        "walk": "une MARCHE DE BOSS pesante : il roule des épaules, le buste droit, la pince tenue"
                " basse, le leurre oscille à contretemps, de l'eau dégoutte de ses bras",
        "strike": [
            "il se campe, la pince tirée en arrière",
            "il lève la pince au-dessus de son épaule, elle s'ouvre",
            "la pince est au plus haut, grande ouverte, le leurre brille",
            "il l'abat à bout de bras",
            "L'IMPACT : la pince au bout de sa course, DEVANT lui, avec une gerbe d'eau"
            " turquoise au plus large",
            "la gerbe retombe, la pince se referme près du sol",
            "il relève le buste, la pince revient",
            "il rejoint la pose de marche",
        ],
        "rise": [
            "il est tassé sur lui-même comme un rocher couvert de coraux, le leurre éteint",
            "de l'eau coule de son dos, le leurre s'allume faiblement",
            "ses yeux s'allument, sa tête se dégage",
            "il redresse les épaules",
            "il déplie la pince et la main griffue",
            "il ouvre lentement la gueule",
            "IL RUGIT : gueule grande ouverte, pince levée, leurre au plus fort",
            "il rejoint la pose de marche",
        ],
        "cast": [
            "il plante ses pieds, les bras écartés",
            "il lève la main griffue, de l'eau tourne autour de son poignet",
            "l'eau monte autour de son bras jusqu'à l'épaule",
            "il lève la pince au-dessus de lui, le leurre brille",
            "il abat la pince sur le sol",
            "LE GESTE : la pince au sol, une couronne d'eau collée autour de ses pieds",
            "l'eau retombe",
            "il se redresse et rejoint la pose de marche",
        ],
        "fall": [
            "il recule, la main griffue sur le ventre",
            "le leurre clignote, sa gueule s'ouvre sans bruit",
            "ses genoux plient, la pince retombe",
            "il tombe à genoux, la tête basse",
            "il bascule sur le côté, de l'eau sort de sa gueule",
            "il est à terre, ses yeux s'éteignent",
            "le leurre s'éteint et retombe sur le sol",
            "il ne bouge plus, masse de coraux et de chair, la pince ouverte",
        ],
        "extra": ["de dos, on voit le dos de coraux et d'algues, et la pince qui dépasse à"
                  " droite", "de profil, la gueule, le leurre et la pince sont DEVANT lui,"
                  " à droite", ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 5, "terrain": "Les Cavernes de Cristal",
        "file": "boss_araignee", "id": "boss_araignee", "name": "La Reine de Cristal",
        "medium_steps": True,
        "worst": "Une géante de cristal couronnée dit son nom au premier regard, et elle reste"
                 " lisible sur le sol violet des cavernes parce qu'elle est bleue et noire.",
        "arrival": "Elle tend le bras et fait monter des pointes de cristal sur les cases"
                   " marquées. Elle se place loin et oblige à venir la chercher.",
        "power": "des pointes de cristal sortent des cases marquées",
        "look": "LA REINE DE CRISTAL, une reine géante et monstrueuse faite de cristal, debout."
                " Corps de pierre noire bleutée et luisante, entièrement couvert d'une armure de"
                " CRISTAUX INDIGO ET CYAN qui brillent de l'intérieur en bleu, épaules hérissées"
                " de gros cristaux. Visage de cristal sombre et anguleux, yeux cyan lumineux,"
                " bouche aux crocs de cristal ivoire. Sur la tête, une HAUTE COURONNE de cristal"
                " cyan. Deux longs bras épais aux mains griffues, griffes de cristal bleu glacé."
                " Deux jambes épaisses bien distinctes, sous une courte jupe de longs éclats de"
                " cristal. PAS de violet rosé : son cristal tire franchement vers le BLEU.",
        "walk": "une MARCHE DE BOSS lente et royale : pas lourds, le buste droit, les bras"
                " écartés, griffes vers le bas, ses cristaux luisent doucement",
        "strike": [
            "elle se campe, le bras droit recule, griffes ouvertes",
            "elle lève le bras droit",
            "le bras est au plus haut, ses griffes de cristal s'allument",
            "elle l'abat vers l'avant",
            "L'IMPACT : les griffes au bout de leur course, DEVANT elle, avec des éclats"
            " de cristal bleu au plus large",
            "les éclats retombent, la main touche presque le sol",
            "elle relève le buste, le bras revient",
            "elle rejoint la pose de marche",
        ],
        "rise": [
            "elle est figée, comme une statue de cristal, tête baissée, les yeux éteints",
            "ses cristaux commencent à briller, un œil s'allume",
            "ses deux yeux brillent",
            "elle relève la tête, sa couronne s'allume",
            "elle écarte les bras",
            "elle lève les deux mains, griffes ouvertes",
            "ELLE MENACE : bouche ouverte, bras levés, cristaux au plus fort",
            "elle rejoint la pose de marche",
        ],
        "cast": [
            "elle s'arrête, les jambes écartées",
            "elle lève une main, paume vers le ciel",
            "ses cristaux brillent plus fort",
            "ses cristaux sont au plus fort, sa couronne étincelle",
            "elle abaisse les deux mains vers le sol d'un coup",
            "LE GESTE : elle penche, les griffes vers le sol, une lueur bleue au bout des doigts",
            "la lueur s'éteint, elle se redresse",
            "elle rejoint la pose de marche",
        ],
        "fall": [
            "elle recule d'un pas, une main sur la poitrine",
            "des cristaux de ses épaules éclatent",
            "sa couronne se fend",
            "elle penche, sa lumière vacille",
            "elle tombe à genoux",
            "ses bras retombent, la tête basse",
            "ses yeux s'éteignent",
            "elle ne bouge plus, affaissée, cristaux éteints",
        ],
        "extra": ["CE N'EST PAS UNE ARAIGNÉE : deux bras et deux jambes, jamais de pattes en plus",
                  "son armure de cristal la couvre entièrement : c'est un monstre imposant,"
                  " jamais une silhouette séduisante",
                  "de profil, le visage et les griffes sont à droite",
                  "de dos, on voit la couronne et le dos hérissé de cristaux",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 6, "terrain": "Les Montagnes Glacées",
        "file": "boss_yeti", "id": "boss_yeti", "name": "Le Roi Yéti",
        "medium_steps": True,
        "worst": "Le Golem de Givre a déjà pris la place de la pierre gelée. Le Yéti apporte"
                 " un géant vivant, rapide pour sa taille, qui reste lisible sur la neige"
                 " grâce à son visage et à sa couronne sombres.",
        "arrival": "Il charge en ligne droite jusqu'au premier mur, où il reste un instant"
                   " sonné : c'est là qu'on le touche. Son pouvoir fait tomber des blocs de"
                   " glace sur les cases marquées.",
        "power": "il frappe le sol, des blocs de glace tombent sur les cases marquées",
        "look": "LE ROI YÉTI, un géant des neiges, debout comme un homme. Long pelage blanc bleuté aux"
                " ombres bleu acier, très large aux épaules, bras puissants qui"
                " s'arrêtent à mi-cuisse, deux longues jambes épaisses, dos droit. Visage et mains"
                " bleu nuit, gueule aux crocs ivoire, yeux bleu glacier lumineux. Sur la tête"
                " une couronne de cristaux de glace bleu vif, et des cristaux pareils"
                " incrustés sur l'épaule gauche. Peau de bête brune en travers de la taille.",
        "walk": "une MARCHE DE BOSS de géant : pas lourds, le buste droit,"
                " les bras se balancent en sens inverse des jambes, le pelage suit",
        "strike": [
            "il se penche, les deux poings en arrière",
            "il lève les deux poings joints au-dessus de sa tête",
            "les poings sont au plus haut, du givre se forme autour",
            "il les abat de toutes ses forces",
            "L'IMPACT : les poings au bout de leur course, DEVANT lui, avec une gerbe de"
            " neige et d'éclats de glace au plus large",
            "la gerbe retombe, les poings touchent le sol",
            "il relève le buste",
            "il rejoint la pose de marche",
        ],
        "rise": [
            "il est accroupi en boule, comme un rocher enneigé, le visage caché",
            "de la neige glisse de son dos",
            "il relève la tête, ses yeux s'allument",
            "il se redresse, les bras pendants",
            "il lève les poings à hauteur de poitrine",
            "il se frappe la poitrine d'un poing",
            "IL RUGIT : gueule grande ouverte, bras écartés, poings fermés",
            "il rejoint la pose de marche",
        ],
        "cast": [
            "il se campe, jambes écartées",
            "il lève les deux bras très haut, poings fermés",
            "du givre remonte le long de ses bras",
            "il prend son élan, le buste en arrière",
            "il abat les deux poings au sol",
            "LE GESTE : poings au sol, une couronne de neige soulevée autour de lui",
            "la neige retombe, il reste penché",
            "il se redresse et rejoint la pose de marche",
        ],
        "fall": [
            "il recule, une main sur la poitrine",
            "sa couronne de glace se fend",
            "il met un genou à terre, les bras ballants",
            "il tombe à genoux, la tête basse",
            "il bascule en avant",
            "il s'étale, les bras en avant, les yeux s'éteignent",
            "de la neige commence à couvrir son dos",
            "il ne bouge plus, à moitié couvert de neige",
        ],
        "extra": ["de dos, on voit le large dos de pelage, les cristaux de l'épaule et la"
                  " pointe de la couronne",
                  "sa peau et son pelage restent bien contrastés, avec un contour bleu sombre"
                  " net : il doit se lire sur un sol de neige blanche",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 7, "terrain": "Le Bois d'Épine",
        "file": "boss_mere_ronce", "id": "boss_mere_ronce", "name": "La Mère-Ronce",
        "medium_steps": True,
        "worst": "Le Bois d'Épine ressemble à la Forêt, et le Sylvain y a déjà pris la place"
                 " de l'arbre. Une géante de ronces couronnée d'une fleur carnivore donne à ce"
                 " stage un adversaire d'une autre nature : elle ne court pas après le mage,"
                 " elle lui prend le terrain.",
        "arrival": "Elle fait jaillir des murs de ronces : ils blessent qui reste dessus et"
                   " ferment le couloir un moment. Elle avance lentement. C'est un combat de"
                   " placement.",
        "power": "un mur de ronces jaillit, blesse le mage et ferme le couloir un moment",
        "look": "LA MÈRE-RONCE, une géante monstrueuse faite de ronces, debout, silhouette de"
                " grande femme sans aucun détail féminin marqué. Corps de ronces noires et de"
                " grosses lianes vert sombre tressées, hérissé de longues épines. Sa tête est une"
                " FLEUR CARNIVORE aux pétales rouge sombre et jaune d'or, ouverte comme une"
                " gueule, bordée de crocs ivoire, avec une langue vert acide et trois yeux vert"
                " acide lumineux au-dessus. Deux longs bras de lianes épineuses aux mains griffues,"
                " griffes d'épines noires. Une robe courte de ronces et de feuilles en lambeaux,"
                " qui laisse bien voir DEUX JAMBES de racines tordues, aux pieds de racines"
                " écartées. Quelques spores vert acide autour d'elle.",
        "walk": "une MARCHE DE BOSS lente : pas lourds sur ses pieds de racines, les bras de"
                " lianes se balancent, la fleur bouge à peine",
        "strike": [
            "elle s'arrête, le bras droit part en arrière",
            "la fleur s'ouvre en grand, les yeux s'allument",
            "le bras est tendu en arrière, la fleur recule",
            "le bras et la fleur partent vers l'avant",
            "L'IMPACT : les griffes d'épines au bout de leur course, DEVANT elle, avec un"
            " fouet de ronces vert et noir au plus large",
            "le fouet retombe, la fleur se referme à moitié",
            "le bras revient contre elle",
            "elle rejoint la pose de marche",
        ],
        "rise": [
            "elle est accroupie, repliée comme un gros buisson de ronces, la fleur fermée",
            "les ronces s'écartent, le bouton de fleur sort",
            "le bouton monte, trois yeux s'allument",
            "elle se relève, les jambes se dégagent",
            "elle est debout, les bras se déplient",
            "la fleur commence à s'ouvrir, on voit les crocs",
            "ELLE RUGIT : fleur grande ouverte, crocs visibles, bras levés",
            "elle rejoint la pose de marche",
        ],
        "cast": [
            "elle s'arrête, les bras bas",
            "elle lève les deux bras, la fleur se referme",
            "la fleur s'ouvre, des spores tournent autour d'elle",
            "ses bras sont tendus vers le ciel, ses yeux brillent",
            "elle plonge les deux mains vers le sol",
            "LE GESTE : penchée, les griffes enfoncées dans le sol, fleur grande ouverte",
            "elle retire ses mains, la fleur se referme à moitié",
            "elle se redresse et rejoint la pose de marche",
        ],
        "fall": [
            "elle se cambre, les bras écartés",
            "ses pétales se déchirent",
            "un bras retombe, puis l'autre",
            "la fleur penche, ses yeux clignotent",
            "elle tombe à genoux",
            "elle s'affaisse, la fleur fanée touche le sol",
            "ses yeux s'éteignent dans les ronces",
            "il ne reste qu'un tas de ronces sèches et une fleur fanée, immobiles",
        ],
        "extra": ["ON COMPTE DEUX JAMBES ET DEUX BRAS, jamais de lianes-bras en plus et jamais"
                  " de pied unique qui rampe",
                  "de dos, on voit l'arrière des pétales, le dos épineux et les jambes",
                  "de profil, la gueule de la fleur s'ouvre vers la droite",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 8, "terrain": "Les Ruines Anciennes",
        "file": "boss_idole", "id": "boss_idole", "name": "L'Idole Éveillée",
        "medium_steps": True,
        "worst": "Les ruines ont besoin de leur gardien. Un colosse de pierre taillé comme une statue se"
                 " distingue au premier regard des golems du bestiaire, et ses longues griffes"
                 " rendent sa zone de danger évidente.",
        "arrival": "Elle frappe de ses griffes au contact. De loin, elle tourne sur elle-même et"
                   " projette une onde de jade le long d'un couloir ; ses yeux de jade"
                   " s'allument juste avant.",
        "power": "elle tourne sur elle-même et projette une onde de jade le long d'un couloir",
        "look": "L'IDOLE ÉVEILLÉE, un colosse de pierre à forme humaine, au visage de"
                " démon. Pierre grise et beige, fendue par endroits, mousse vert vif sur les"
                " épaules. Torse énorme et droit, tête bien dégagée des épaules :"
                " gueule de pierre aux grandes défenses et aux crocs, deux yeux de JADE vert"
                " lumineux et un joyau de jade au front. Collier d'or terni. DEUX GROS BRAS,"
                " dont chaque main finit par de longues griffes de bronze."
                " Deux longues jambes très épaisses aux chevilles ornées d'or, pieds griffus.",
        "walk": "une MARCHE DE COLOSSE : pas lourds et raides, le buste ne pivote pas, les"
                " deux bras restent écartés, griffes vers le bas",
        "strike": [
            "elle se campe, les deux griffes écartées",
            "les deux bras se lèvent",
            "les griffes sont au plus haut, ses yeux de jade s'allument",
            "elle abat les deux griffes, en croix",
            "L'IMPACT : les griffes au bout de leur course, DEVANT elle, avec une traînée de"
            " jade et des éclats de pierre au plus large",
            "la traînée se dissipe, les bras restent bas",
            "elle relève les bras",
            "elle rejoint la pose de marche",
        ],
        "rise": [
            "elle est figée, comme une statue, les bras croisés sur la poitrine, les yeux éteints",
            "une fissure court sur son torse, de la poussière tombe",
            "ses yeux de jade s'allument",
            "le bras gauche se décroise",
            "le bras droit se décroise",
            "les deux bras s'écartent, les griffes sortent",
            "ELLE S'ÉVEILLE : griffes levées, joyau du front au plus fort",
            "elle rejoint la pose de marche",
        ],
        "cast": [
            "elle se campe, les deux bras tendus sur les côtés",
            "le buste pivote un peu vers la gauche",
            "le buste est tourné vers la gauche, prêt à partir",
            "elle pivote, les griffes en traînée",
            "elle fait face, les griffes en traînée de jade tout autour d'elle",
            "LE GESTE : les deux griffes tendues, un anneau de jade autour d'elle",
            "l'anneau s'éteint, les bras retombent",
            "elle rejoint la pose de marche",
        ],
        "fall": [
            "elle se fige, les yeux clignotent",
            "de grandes fissures courent sur son torse",
            "le bras gauche se brise et tombe",
            "elle penche, de gros éclats tombent de son épaule",
            "ses genoux cèdent, elle tombe à genoux",
            "son torse se fend en deux",
            "elle s'effondre, les yeux éteints",
            "il ne reste qu'un tas de pierres, la tête de pierre posée dessus",
        ],
        "extra": ["ON COMPTE DEUX BRAS dans toutes les cases, jamais plus",
                  "de dos, on voit le dos de pierre moussu et les deux bras",
                  "de profil, la gueule et les griffes sont tournés à droite",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 9, "terrain": "Le Sanctuaire Déchu",
        "file": "boss_roi_dechu", "id": "boss_roi_dechu", "name": "Le Roi Déchu",
        "medium_steps": True,
        "reference": ROI_REF,
        "worst": "`boss.png` attend depuis le début de la refonte sans être découpée, faute"
                 " de boss en jeu. Son armure noire et violette est celle du Sanctuaire : on"
                 " garde l'armure et l'allure de roi, et on redessine ses poses sur la grille du jeu, car sa"
                 " planche n'a ni grille régulière ni fond à effacer.",
        "arrival": "Il combat à l'épée de près et tire des crânes de loin. Le stage 9 oblige"
                   " déjà à détruire les repaires : ce boss vient après, et rouvre un cercle"
                   " de vide sur les cases marquées.",
        "power": "un cercle de vide s'ouvre sur les cases marquées, des crânes en sortent",
        "look": "LE ROI DÉCHU, un énorme démon en armure, d'après l'image de référence jointe :"
                " garde son armure et son épée, sur un corps de géant plus massif. Forme humaine,"
                " très large et droit, bras épais aux griffes noires, deux longues jambes"
                " massives, pieds griffus, SANS QUEUE. Armure noire écailleuse à liserés"
                " de bronze doré, petit crâne de bronze à la ceinture. Tête haute aux longues"
                " cornes noires recourbées : heaume fendu sur une GUEULE ouverte aux crocs"
                " ivoire, yeux violet bleuté. Cape et pagne violet sombre en lambeaux. Il tient"
                " à la main droite une longue épée noire dentelée, parcourue d'une veine violet"
                " bleuté, pointe basse. COULEURS FROIDES : son violet tire vers le BLEU et reste"
                " sombre, sans halo autour de lui, à la différence de l'image jointe.",
        "walk": "une MARCHE DE BOSS : pas lourds et sûrs, la cape ondule derrière lui, l'épée"
                " tenue d'une main, pointe basse, la main gauche ouverte",
        "strike": [
            "il se campe, l'épée basse",
            "il lève l'épée au-dessus de son épaule",
            "l'épée est au plus haut, sa veine s'allume",
            "il abat l'épée, la cape se soulève",
            "L'IMPACT : la lame au bout de sa course, DEVANT lui, avec une traînée en"
            " croissant violet bleuté au plus large",
            "la traînée se dissipe, la lame touche presque le sol",
            "il relève le buste, l'épée revient",
            "il rejoint la pose de marche",
        ],
        "rise": [
            "il est un genou à terre, tête baissée, les deux mains sur la garde de l'épée",
            "ses yeux s'allument sous le heaume",
            "il relève la tête",
            "il se relève, l'épée encore plantée",
            "il est debout, il arrache l'épée du sol",
            "il lève la main gauche, ouverte",
            "IL RUGIT : gueule grande ouverte, épée pointée devant lui, cape soulevée",
            "il rejoint la pose de marche",
        ],
        "cast": [
            "il se campe, l'épée basse",
            "il lève la main gauche, une petite lueur s'y forme",
            "la lueur grossit en une orbe violet bleuté, sans halo autour de lui",
            "il lève l'orbe au-dessus de sa tête",
            "il plante l'épée au sol et abaisse l'orbe",
            "LE GESTE : l'épée plantée, la main gauche tendue vers le sol, l'orbe éclate",
            "la lueur s'éteint",
            "il reprend l'épée et rejoint la pose de marche",
        ],
        "fall": [
            "il recule d'un pas, une main sur le plastron",
            "son épée s'échappe et pointe vers le sol",
            "il plante l'épée pour se retenir",
            "il tombe un genou à terre",
            "ses cornes se fendent, il penche la tête",
            "il lâche l'épée et s'affaisse",
            "son armure s'effondre, ses yeux s'éteignent",
            "il ne reste qu'un tas d'armure noire, l'épée plantée à côté",
        ],
        "extra": ["de dos, on voit la cape déchirée, les cornes, et le bout de la lame qui"
                  " dépasse à droite",
                  "de profil, la lame est DEVANT lui, la cape DERRIÈRE lui",
                  "AUCUN halo, aucune brume, aucun éclat autour de lui, hors des images où son"
                  " geste en demande un : le fond doit rester un magenta pur",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
    {
        "stage": 10, "terrain": "Le Château du Ciel",
        "file": "boss_chimere", "id": "boss_chimere", "name": "La Chimère d'Or",
        "medium_steps": True,
        "worst": "Le dernier combat de la campagne. Le château est blanc et or : le monstre"
                 " final en porte les couleurs, comme s'il en gardait les portes. Debout, tête"
                 " de lion, ailes de lames et queue de serpent réunis sur un seul colosse, aucune"
                 " autre créature du jeu n'a sa silhouette.",
        "arrival": "Elle enchaîne deux menaces : pluie de lames d'or sur les cases marquées,"
                   " charge en ligne droite. Blessée, elle perd ses ailes et va plus vite.",
        "power": "une pluie de lames d'or tombe sur les cases marquées",
        "look": "LA CHIMÈRE D'OR, une colosse guerrière à tête de lion, DEBOUT SUR DEUX JAMBES."
                " Corps très musclé au pelage blanc crème, couvert d'une armure de plaques d'or"
                " et de marbre aux fines gravures bleu azur. Grosse tête de fauve à la crinière"
                " d'or en pointes, gueule ouverte aux longs crocs ivoire, TROIS yeux bleu azur"
                " lumineux, deux cornes d'or et un HALO D'OR flottant au-dessus. Deux bras énormes"
                " aux mains griffues, griffes d'or. Deux jambes épaisses aux pieds griffus d'or."
                " Dans le dos, deux ailes faites de lames d'or séparées, TOUJOURS À MOITIÉ"
                " REPLIÉES derrière les épaules. Longue queue de serpent en écailles d'or, derrière"
                " les jambes, terminée par une tête de serpent aux yeux azur.",
        "walk": "une MARCHE DE BOSS : pas lourds et sûrs, les épaules roulent, les bras"
                " balancent, griffes ouvertes, les ailes bougent à peine, la queue serpente",
        "strike": [
            "elle se campe, le bras droit part en arrière, la gueule s'ouvre",
            "elle lève le bras droit, griffes sorties",
            "le bras est au plus haut, ses ailes s'écartent un peu, ses yeux brillent",
            "elle abat le bras vers l'avant",
            "L'IMPACT : les griffes au bout de leur course, DEVANT elle, avec une traînée de"
            " lumière azur et or au plus large",
            "la traînée se dissipe, la main touche presque le sol",
            "elle relève le buste, le bras revient",
            "elle rejoint la pose de marche",
        ],
        "rise": [
            "un genou à terre comme une statue de gardien, ailes serrées, halo et yeux éteints",
            "le halo s'allume faiblement",
            "ses trois yeux s'allument",
            "elle relève la tête, sa crinière se hérisse",
            "elle se met debout, ses ailes de lames se séparent",
            "elle écarte les bras, sa queue se dresse",
            "ELLE RUGIT : gueule grande ouverte, griffes levées, halo au plus fort",
            "elle rejoint la pose de marche",
        ],
        "cast": [
            "elle se campe, les jambes écartées",
            "elle lève la tête vers le ciel",
            "le halo grandit, elle lève les deux bras",
            "ses bras sont au plus haut, les lames de ses ailes brillent",
            "elle abaisse les bras d'un coup vers l'avant",
            "LE GESTE : bras tendus devant elle, gueule ouverte, halo au plus fort",
            "la lumière s'éteint, les bras retombent",
            "elle rejoint la pose de marche",
        ],
        "fall": [
            "elle se fige, ses yeux vacillent",
            "le halo se brise",
            "une aile perd ses lames, elles tombent une à une",
            "un genou cède, elle tombe à genoux",
            "ses plaques se fendent",
            "elle bascule en avant, sa queue retombe",
            "elle est couchée, ses yeux s'éteignent",
            "elle ne bouge plus, des lames d'or éparses autour d'elle",
        ],
        "extra": ["⚠️ JAMAIS À QUATRE PATTES : elle se tient debout, comme un guerrier, dans"
                  " toutes les cases, sauf quand elle s'effondre à sa mort",
                  "⚠️ LES AILES RESTENT À MOITIÉ REPLIÉES et ne sortent JAMAIS de la case. Chaque"
                  " case contient une pose, et une seule",
                  "de dos, on voit les ailes de lames, le dos et la queue de serpent",
                  "de profil, la tête est à droite, la queue à gauche",
                  "un contour sombre et net tout autour d'elle : elle doit se lire sur un sol"
                  " blanc et or",
                  ONE_SIZE, ONLY_ROWS, NO_KEY],
    },
]


## La partie « aucune ombre, aucun cadre » de la règle commune : la seule qui vaille pour
## une planche de face, où ni le profil ni la marche n'ont à être tenus.
NO_SHADOW_RULE = BLOCKING_TOP[BLOCKING_TOP.index("⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE"):]


def scene_prompt(boss: dict) -> str:
    rows = [("rise", "SON ARRIVÉE, de l'immobilité au rugissement"),
            ("cast", "SON ATTAQUE DE LOIN : le geste seulement. La zone et l'effet sont sur"
                     " une autre planche"),
            ("fall", "SA MORT : la dernière image reste à l'écran, la créature y est encore"
                     " visible")]
    blocks = []
    for index, (key, title) in enumerate(rows):
        beats = "\n".join(f"{i + 1}. {beat}" for i, beat in enumerate(boss[key]))
        blocks.append(f"RANGÉE {index + 1} — {title} :\n{beats}")
    extra = [rule for rule in boss["extra"]
             if not rule.startswith(("de dos", "de profil"))]
    rules = "\n".join(f"- {rule}" for rule in extra)
    joined = "\n\n".join(blocks)
    return f"""{HEADER}

{sheet_block(boss['look'])}

⚠️ L'IMAGE JOINTE EST SA PLANCHE DE MARCHE : c'est cette créature-là, à l'identique,
avec les mêmes couleurs et la même taille.

CETTE PLANCHE EST TOUTE ENTIÈRE DE FACE. La créature regarde vers le bas de l'image
dans les {COLUMNS * ROWS} cases, sans se retourner. Chaque rangée se lit de gauche à droite et ne
boucle pas : les rangées 1 et 2 finissent en pose de marche.

{joined}

⚠️ RÈGLE BLOQUANTE — LA CRÉATURE EST VISIBLE DANS LES {COLUMNS * ROWS} CASES, y compris à la
dernière image de sa mort. C'est le jeu qui la fera disparaître en fondu.

⚠️ RÈGLE BLOQUANTE — LE BAS DE LA CRÉATURE RESTE SUR LA MÊME LIGNE dans les {COLUMNS * ROWS}
cases, et elle reste centrée. Elle peut se baisser ou s'effondrer, mais vers cette ligne,
sans jamais descendre en dessous ni glisser sur le côté.

⚠️ RÈGLE BLOQUANTE — RIEN NE S'ÉLOIGNE D'ELLE. Pas de racines, de vague, de foudre ni de
cristaux qui partent sur le terrain : un petit effet collé à son corps est seul permis.

{NO_SHADOW_RULE}

AUTRES RÈGLES :
{rules}
```"""


def timing(boss: dict) -> tuple:
    done = (boss["stage"] - 1) / 9.0
    alert = ALERT_RANGE[0] + (ALERT_RANGE[1] - ALERT_RANGE[0]) * done
    every = EVERY_RANGE[0] + (EVERY_RANGE[1] - EVERY_RANGE[0]) * done
    return round(alert, 1), round(every, 1)


def reach_prompt(boss: dict) -> str:
    special = SPECIALS[boss["file"]]
    name = boss["name"]
    return f"""Feuille d'effets pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon coloré
à contours nets, même facture que les sprites d'un jeu de rôle mobile.

FORMAT, à respecter exactement :
- UNE image de {COLUMNS * CELL} x {ROWS * CELL} pixels
- grille RÉGULIÈRE de {COLUMNS} colonnes x {ROWS} rangées, soit {COLUMNS * ROWS} cases de {CELL} x {CELL}
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases
- aucun trait entre les cases, aucun texte, aucun chiffre, aucun décor

CE QUE MONTRE CETTE PLANCHE — la portée de l'attaque DE LOIN de {name}, sur le sol.
LE MONSTRE N'EST PAS DESSINÉ : aucune créature, aucun personnage. Le jeu pose cette zone
sur le terrain, loin de lui, pour que le joueur la voie et s'enfuie à temps.

LA ZONE — {special['zone']}. Elle reste au même endroit et de la même taille dans les
rangées 1 et 2.
- son CONTOUR est épais, blanc-jaune vif, avec un fin liseré NOIR des deux côtés : il doit
  se voir sur n'importe quel sol du jeu, clair ou sombre, et dire DANGER au premier regard
- son INTÉRIEUR montre {special['warn']}

RANGÉE 1 — L'ALERTE, on voit venir le coup. Lue de gauche à droite, sans boucler :
1. le contour seul, fin, l'intérieur encore vide de magenta
2. le contour s'épaissit
3. l'intérieur se remplit au centre, sur un quart de la zone
4. l'intérieur est rempli à moitié, depuis le centre
5. l'intérieur est rempli aux trois quarts
6. l'intérieur est plein
7. le contour clignote : il devient blanc pur
8. DERNIER INSTANT : contour blanc pur au plus épais, intérieur au plus vif

RANGÉE 2 — LE COUP : {special['hit']}. Lue de gauche à droite :
1. le premier éclat, au centre de la zone, tout petit
2. l'effet grandit
3. l'effet grandit encore
4. L'IMPACT : l'effet est à son plus grand, sans sortir de la case
5. il tient, encore très grand
6. il commence à retomber
7. il retombe nettement
8. il n'en reste que la moitié

RANGÉE 3 — LA FIN, le danger est passé : la même zone qui s'éteint, de gauche à droite.
Le contour disparaît dès l'image 2. L'effet se défait peu à peu. L'image 7 ne garde que
quelques débris, et l'image 8 est une CASE VIDE, tout en magenta.

⚠️ RÈGLE BLOQUANTE — RIEN N'EST TRANSPARENT, RIEN N'EST FLOU. Tout a un bord net et des
couleurs pleines : pas de halo, pas de lueur qui se fond dans le fond, pas d'ombre portée.
Le jeu efface le magenta et ajoute lui-même la transparence. Un dégradé vers le fond
laisserait une frange rose autour de la zone, et elle ne se rattrape pas.

⚠️ RÈGLE BLOQUANTE — RIEN NE SORT DE SA CASE. L'effet tient dans ses {CELL} x {CELL} pixels,
même au moment de l'impact.

AUTRES RÈGLES :
- {NO_KEY}
- {ONLY_ROWS}
```"""


def boss_fiche(boss: dict) -> str:
    boss = {**boss, "look": boss["look"] + MONSTROUS}
    text = fiche(boss)
    text = text.replace(f"# {boss['name']} — planches de marche et d'attaque",
                        f"# Stage {boss['stage']} · {boss['terrain']} — {boss['name']}")
    text = text.replace("**Ce qu'elle fait.** ", "**Son combat, proposé.** ")
    text = text.replace("## Deux planches, et pourquoi pas une", "## Quatre planches")
    attack_line = next(line for line in text.splitlines()
                       if line.startswith(f"    {boss['file']}_attaque.png"))
    text = text.replace(attack_line, attack_line + (
        f"\n    {boss['file']}_scene.png     8 colonnes x 3 rangées"
        "   arrivée / attaque de loin / mort, de face"
        f"\n    {boss['file']}_portee.png    8 colonnes x 3 rangées"
        "   alerte / coup / fin, vue du dessus"))
    text = text.replace("""Quarante-huit cases dans une seule image reviendraient bouillies : chaque pose
ferait moins de 256 pixels et la créature perdrait son visage. En deux
planches, chaque case reste grande.""", """Une seule image reviendrait bouillie : chaque planche garde des cases de 256 pixels. La
scène n'est dessinée que de face, car ces trois moments ne dépendent pas de la direction
où le boss regardait. La portée est à part parce que le jeu la pose loin du boss.""")
    text = text.replace("Les deux planches vont dans", "Les quatre planches vont dans")
    if boss.get("reference"):
        text = text.replace(
            "**Avant de lancer :** Pour la marche, joindre ",
            f"**Avant de lancer :** Pour la marche, joindre `{boss['reference']}`, son"
            " portrait, et ")
    alert, every = timing(boss)
    text = text.replace("**Avant de lancer :** ", f"""**Son attaque de loin, proposée.** Portée : {SPECIALS[boss['file']]['reach']}. La zone s'allume
{alert} s avant le coup, et il recommence toutes les {every} s. Son coup au contact n'a pas de
zone : il se voit à son geste, sur la planche d'attaque.

**Avant de lancer :** """, 1)
    # La scène se glisse après l'attaque, avant le tableau des défauts.
    head, tail = text.split("## Si ça revient mal", 1)
    text = (f"{head}## Prompt 3 — la scène : arrivée, attaque de loin, mort\n\n"
            f"Joindre la planche de marche livrée.\n\n```\n{scene_prompt(boss)}\n\n"
            f"---\n\n## Prompt 4 — la portée : alerte, coup, fin\n\n"
            f"Ne rien joindre : le monstre n'y apparaît pas.\n\n```\n{reach_prompt(boss)}\n\n"
            f"---\n\n## Si ça revient mal{tail}")
    text = text[:text.index("## Ce que je fais quand elles arrivent")]
    text = text.replace("occupe environ 80 % de la hauteur", "occupe environ 90 % de la hauteur")
    return text + f"""## Ce que je fais quand elles arrivent

Les déposer dans `assets/peso&cover/creatures/`. `tools/build_bosses.py {boss['file']}` les
découpe vers `assets/enemies/{boss['id']}/`. Le combat de ce boss n'est **pas encore
programmé**.

*Fiche produite par `tools/build_prompts_boss.py`.*
"""


def overview() -> str:
    rows = "\n".join(
        f"| {b['stage']} | {b['terrain']} | [{b['name']}]({b['file']}.md) | {b['power']}"
        f" | {SPECIALS[b['file']]['reach']} | {timing(b)[0]} s | {timing(b)[1]} s |"
        for b in BOSSES)
    return f"""# Les boss de fin de stage

Un boss par stage, dans l'ordre de la campagne. Chacun tient dans la palette de son
terrain et ne reprend aucune créature du bestiaire.

Ce sont tous des **monstres humanoïdes et massifs**, debout sur deux jambes, qui incarnent
leur nom et ne sont jamais des animaux. Le dessin donne la masse,
le jeu donne la taille : le corps d'un boss fera **{BOSS_BODY} px** à l'écran, contre 38 pour le
mage et 58 pour le Seigneur Démon, le plus grand ennemi actuel.

Chacun attaque de loin selon sa spécialité, à intervalle régulier. **Avant chacune de ces
attaques, une zone s'allume au sol** : on la voit se remplir, puis clignoter, et on a le
temps de s'écarter. Le coup au contact n'a pas de zone : il se voit au geste du boss.

| Stage | Terrain | Boss | Attaque de loin | Portée | Alerte | Intervalle |
|---:|---|---|---|---|---:|---:|
{rows}

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
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    Image.open(ROI_SOURCE).convert("RGB").crop(ROI_BOX).save(ROI_REF)
    for boss in BOSSES:
        (OUT / f"{boss['file']}.md").write_text(boss_fiche(boss), encoding="utf-8")
    (OUT / "README.md").write_text(overview(), encoding="utf-8")
    print("%d fiches écrites dans %s : %s" % (
        len(BOSSES), OUT, ", ".join(b["file"] for b in BOSSES)))


if __name__ == "__main__":
    main()
