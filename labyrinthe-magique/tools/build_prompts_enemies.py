#!/usr/bin/env python3
"""Les prompts du bestiaire : une fiche par créature, dans `docs/prompts/ennemis/`.

    tools/.venv/bin/python tools/build_prompts_enemies.py     # DEPUIS LA RACINE

ONZE FICHES ÉCRITES PAR UN SEUL TEXTE, et c'est tout l'intérêt.

Ces fiches partagent 90 % de leur contenu : le format de la planche, les trois
rangées, les règles bloquantes, la marche à suivre au retour. Recopiées onze
fois à la main, elles auraient divergé dès la première correction — on aurait
durci une règle sur le Minotaure et oublié les dix autres, et le défaut serait
revenu par la porte qu'on venait de fermer.

Ici la règle s'écrit UNE fois. Ce qui reste par créature, c'est ce qui lui
appartient vraiment : sa description, sa façon de se déplacer, et les huit
temps de son coup.

⚠️ LE PROFIL REGARDE À DROITE, et c'est la ligne la plus chère de ce fichier.
La convention ne le disait pas ; sept planches sur neuf ont été lues à l'envers
pendant des semaines et sept créatures marchaient à reculons sans que rien ne le
signale — les fichiers existaient, les tests passaient. La règle est donc
répétée trois fois dans chaque fiche, et `tools/check_profiles.py` la vérifie
au retour.
"""

from pathlib import Path
from textwrap import fill

OUT = Path("docs/prompts/ennemis")

## Colonnes, rangées, côté de case. La grille est la même pour tout le monde :
## c'est ce qui permet à `build_enemies.py` de n'avoir rien à deviner.
COLUMNS, ROWS, CELL = 8, 3, 256

## Par créature : le nom du fichier à livrer, l'identifiant du dossier de jeu,
## le nom affiché, l'allure, la façon de marcher, et les huit temps du coup.
##
## `look` est recopié TEL QUEL dans les deux prompts : les deux planches doivent
## représenter la même bête, et la seule façon d'en être sûr est de lui donner
## deux fois exactement la même description.
HERD = [
    {
        "file": "spectre", "id": "hunter", "name": "Spectre Violet", "legs": False,
        "worst": "Sa planche ne lui donne qu'UNE orientation : il est dessiné de"
                 " face, et sa vue de gauche est cette même image retournée. Il"
                 " n'a ni dos ni profil — il vous regarde en face pendant qu'il"
                 " vous poursuit dans le dos.",
        "look": "UN SPECTRE VIOLET. Une silhouette encapuchonnée qui FLOTTE au"
                " ras du sol, sans jambes visibles : une robe déchirée en"
                " lambeaux violets et indigo qui se dissout en volutes vers le"
                " bas. Sous la capuche, pas de visage — deux yeux qui brûlent"
                " d'un violet magenta clair. Des liserés dorés courent sur les"
                " bords de la robe. Une brume violette pâle traîne derrière lui.",
        "walk": "un CYCLE DE FLOTTAISON complet : il monte et redescend d'une"
                " petite hauteur, sa robe ondule, ses lambeaux se soulèvent puis"
                " retombent",
        "strike": [
            "il se ramasse, ses lambeaux se resserrent contre lui",
            "il se cabre en arrière, les bras s'écartent, ses yeux s'allument",
            "une griffe de brume violette se forme au bout de ses manches",
            "il jette le bras en avant, la griffe part",
            "le coup est porté : une traînée violette en croissant, au plus large",
            "la traînée s'étire et pâlit",
            "il retombe, les lambeaux se soulèvent dans le courant",
            "il revient à sa position de départ, prêt à recommencer",
        ],
        "extra": ["de dos, on ne voit AUCUN œil : c'est ce qui distingue la"
                  " rangée 2 de la rangée 1"],
    },
    {
        "file": "serpent", "id": "serpent", "name": "Serpent d'Émeraude", "legs": False,
        "worst": "Il file dans les couloirs plus vite que tout le reste du"
                 " bestiaire, et c'est le mouvement qu'on voit le moins : quatre"
                 " images pour une reptation, ça glisse sans onduler.",
        "look": "UN SERPENT D'ÉMERAUDE. Un corps de serpent lové sur lui-même,"
                " écailles vert émeraude qui virent au jaune sur le ventre,"
                " parcourues de reflets. Une collerette de membranes roses et"
                " magenta s'ouvre derrière sa tête, nervurée comme une aile. Ses"
                " yeux sont deux fentes dorées, sa langue fine et fourchue.",
        "walk": "une REPTATION complète : le corps ondule en vague de la tête à"
                " la queue, la collerette frémit, la langue sort et rentre",
        "strike": [
            "il se ramasse, le corps se tasse en ressort",
            "il se dresse, la collerette s'ouvre en grand",
            "la gueule s'ouvre, les crochets paraissent",
            "il se détend et projette la tête en avant",
            "la morsure est portée, au plus loin de son élan",
            "il tient la morsure, un éclat vert au point de contact",
            "il se rétracte, la collerette se replie",
            "il revient lové, prêt à recommencer",
        ],
        "extra": ["il n'a PAS de pattes : rien ne doit ressembler à un pas",
                  "sa collerette reste DERRIÈRE sa tête, elle ne passe jamais"
                  " devant sa gueule"],
    },
    {
        "file": "ombre", "id": "ombre", "name": "Ombre Encapuchonnée", "legs": False,
        "worst": "Elle glisse sans bruit et rattrape en ligne droite : c'est le"
                 " monstre qu'on découvre dans son dos, donc celui dont la vue"
                 " DE DOS compte le plus.",
        "look": "UNE OMBRE ENCAPUCHONNÉE. Une grande robe indigo et bleu nuit,"
                " au capuchon profond, dont les pans se déchirent en lambeaux"
                " vers le bas. Sous la capuche, l'obscurité complète et deux"
                " points rouges. Ses mains sont des serres décharnées violettes"
                " qui sortent de manches trop longues. Elle glisse au ras du sol.",
        "walk": "un GLISSEMENT complet : la robe ondule d'avant en arrière, les"
                " lambeaux du bas traînent et se soulèvent, le capuchon oscille"
                " à peine",
        "strike": [
            "elle se recroqueville, la robe se referme sur elle",
            "les deux serres sortent des manches",
            "elle se dresse, les bras s'ouvrent en croix, les points rouges brillent",
            "elle abat les deux serres en avant",
            "le coup est porté : deux griffures d'ombre parallèles",
            "les griffures s'effilochent en fumée noire",
            "les bras retombent, la robe se referme",
            "elle revient à sa position de glissement",
        ],
        "extra": ["ses deux points rouges NE PARAISSENT PAS sur la rangée de dos",
                  "aucune jambe ne doit apparaître : elle glisse, elle ne marche pas",
                  "⚠️ ELLE NE DOIT PAS RESSEMBLER AU SPECTRE VIOLET, l'autre"
                  " créature encapuchonnée de ce jeu. Deux choses les séparent et"
                  " il faut les pousser : sa robe est BLEU NUIT et INDIGO, jamais"
                  " violette ; ses yeux sont deux points ROUGES, jamais blancs ni"
                  " magenta. À la taille où le jeu les affiche, c'est tout ce"
                  " qu'on aura pour les distinguer"],
    },
    {
        "file": "dragonnet", "id": "dragonnet", "name": "Dragonnet de Feu", "legs": False,
        "worst": "Il vole, donc il ne ralentit jamais dans les virages : c'est"
                 " le seul dont le battement d'ailes doit rester lisible à toute"
                 " vitesse.",
        "look": "UN DRAGONNET DE FEU. Un petit dragon rouge sang aux écailles"
                " sombres, avec deux grandes ailes membraneuses rouge vif"
                " nervurées de noir, bien plus larges que son corps. Deux cornes"
                " dorées recourbées sur la tête, des yeux jaunes, une petite"
                " gueule pleine de crocs. Une flamme orange brûle sous lui, entre"
                " ses pattes repliées.",
        "walk": "un BATTEMENT D'AILES complet : les ailes montent, s'ouvrent en"
                " grand, redescendent ; le corps monte et descend légèrement à"
                " contretemps, la flamme sous lui s'étire et se ramasse",
        "strike": [
            "il replie ses ailes et gonfle la gorge, qui s'éclaire d'orange",
            "il rejette la tête en arrière, la lueur monte dans son cou",
            "les ailes s'ouvrent en grand, la gueule s'entrouvre",
            "il projette la tête en avant et lâche son souffle",
            "le souffle est à son plus fort : un jet de flammes court et large",
            "le jet s'éteint, quelques braises restent en l'air",
            "il referme la gueule, les ailes reviennent",
            "il retrouve son vol, prêt à recommencer",
        ],
        "extra": ["son souffle est COURT : il reste dans la case, il ne la"
                  " traverse pas — cette créature frappe au contact",
                  "ses ailes ne doivent jamais sortir de la case, même ouvertes"],
    },
    {
        "file": "golem_lave", "id": "golem", "name": "Golem de Lave",
        "worst": "C'est une masse : on ne le sème pas, on l'use. Sa marche doit"
                 " PESER — c'est la seule chose qui dit au joueur qu'il ne sert à"
                 " rien de courir. Et c'est le SEUL du bestiaire à frapper de"
                 " loin : il jette une boule de lave à six cases. Son geste de"
                 " jet doit donc se lire de l'autre bout d'un couloir, sinon le"
                 " joueur encaisse sans savoir d'où c'est parti.",
        "look": "UN GOLEM DE LAVE. Un colosse fait de blocs de roche brune et"
                " ocre mal ajustés, épaules énormes, bras plus gros que ses"
                " jambes, sans cou. Entre les blocs, des fissures de lave orange"
                " incandescente ; un cœur de feu brûle au milieu de sa poitrine."
                " Sa tête est un bloc où s'ouvrent deux yeux orange.",
        "walk": "un PAS LOURD complet : il se balance d'une jambe sur l'autre,"
                " les épaules roulent, le corps s'enfonce à chaque appui ; les"
                " fissures de lave pulsent plus fort quand il pose le pied",
        "strike": [
            "il se tasse sur ses jambes, les fissures s'assombrissent",
            "il ramène les deux bras contre lui, la lave afflue dans ses mains",
            "une BOULE DE LAVE se forme entre ses paumes, encore petite",
            "la boule a grossi, blanche au cœur, elle éclaire son torse",
            "il arme le bras en arrière, la boule au-dessus de l'épaule",
            "il jette les deux bras en avant : la boule QUITTE ses mains",
            "la boule est devant lui, au bord de la case, une traînée de braises"
            " derrière elle ; ses bras sont tendus, vides",
            "les bras retombent, des gouttes de lave tombent au sol",
        ],
        "extra": ["⚠️ LA BOULE NE SORT PAS DE LA CASE. C'est le jeu qui la fait"
                  " voler jusqu'au mage : la planche montre le GESTE, pas le"
                  " voyage. Une boule dessinée hors du cadre serait dessinée deux"
                  " fois à l'écran",
                  "on doit voir la boule NAÎTRE dans ses mains (cases 3-4), puis"
                  " ses mains VIDES après le jet (cases 7-8) — c'est ce qui dit"
                  " au joueur ce qui lui arrive",
                  "il est le plus MASSIF du bestiaire : large, jamais élancé"],
    },
    {
        "file": "archer_os", "id": "archer", "name": "Archer d'Os",
        "worst": "Sec et rapide du geste, fragile au contact : son coup doit"
                 " partir vite, donc se lire en huit images qui ne traînent pas.",
        "look": "UN ARCHER D'OS. Un squelette encapuchonné dans une étoffe grise"
                " en lambeaux, os beiges et fêlés, une épaulière de cuir sombre."
                " Un œil rouge brûle dans une orbite vide, l'autre est éteinte."
                " Il tient un arc court en os courbé, et un carquois de flèches"
                " noires est sanglé dans son dos.",
        "walk": "une MARCHE SÈCHE complète : jambes d'os raides, un léger"
                " cliquetis d'articulations, l'étoffe en lambeaux qui bat, le"
                " carquois qui se balance",
        "strike": [
            "il porte la main au carquois",
            "il encoche une flèche noire sur l'arc",
            "il commence à tendre la corde, le bras arrière recule",
            "la corde est tendue au maximum, l'œil rouge s'intensifie",
            "il lâche : la flèche part, la corde vibre",
            "l'arc se détend, une traînée noire courte reste dans l'air",
            "il abaisse l'arc",
            "il revient à sa position de marche, prêt à recommencer",
        ],
        "extra": ["la flèche NE SORT PAS de la case : ce monstre frappe à bout"
                  " portant, il ne tire pas à distance dans le jeu",
                  "un seul œil rouge, toujours le même — pas deux"],
    },
    {
        "file": "demon_cristal", "id": "cristal", "name": "Démon de Cristal",
        "worst": "Blindé de cristal et lourd à déplacer : ce qu'on doit lire sur"
                 " lui, c'est l'ARMURE — sinon ce n'est qu'un monstre bleu de plus.",
        "look": "UN DÉMON DE CRISTAL. Une créature trapue dont le corps sombre"
                " disparaît sous des plaques de cristal bleu électrique et"
                " violet, taillées en pointes qui se dressent aux épaules, aux"
                " avant-bras et dans le dos. Un cœur de lumière magenta brille"
                " au centre de sa poitrine. Ses yeux sont deux éclats blancs.",
        "walk": "un PAS LOURD complet : il avance lentement, les pointes de"
                " cristal du dos oscillent à contretemps du corps, et une lueur"
                " parcourt les cristaux d'un bout à l'autre à chaque appui",
        "strike": [
            "il se tasse, les cristaux du dos se hérissent",
            "il ramène un bras en arrière, les pointes de l'avant-bras s'allongent",
            "le cœur magenta s'allume à plein",
            "il projette le bras en avant, les pointes en premier",
            "l'impact : une étoile de cristal éclate au point de contact",
            "des éclats de cristal retombent en tournoyant",
            "le bras revient, les pointes se rétractent",
            "il retrouve son appui, prêt à recommencer",
        ],
        "extra": ["les cristaux sont sa signature : ils doivent rester visibles"
                  " et pointus dans les 24 cases, même de dos"],
    },
    {
        "file": "minotaure", "id": "minotaure", "name": "Minotaure",
        "worst": "Robuste ET rapide, la pire combinaison du jeu. Son coup doit se"
                 " voir venir : c'est le seul avertissement que le joueur a, et"
                 " c'est la hache levée qui le donne.",
        "look": "UN MINOTAURE ARMÉ D'UNE GRANDE HACHE. Un colosse à torse d'homme"
                " et tête de taureau, pelage brun-roux, deux grandes cornes"
                " blanches recourbées vers l'avant, un anneau de fer dans le"
                " mufle. Des bracelets de cuir clouté aux avant-bras, un pagne"
                " sombre, des sabots. Ses yeux sont rouges et son souffle fait de"
                " la buée. Il porte une GRANDE HACHE DE GUERRE à double tranchant,"
                " au long manche de bois cerclé de fer, aussi haute que lui — il"
                " la tient à deux mains et ne la lâche JAMAIS, ni en marchant ni"
                " en frappant.",
        "walk": "une MARCHE PESANTE ET RAPIDE, LA HACHE EN MAIN : les épaules"
                " roulent, la tête descend et remonte, les sabots frappent le sol,"
                " la buée sort des naseaux par à-coups, et le fer de la hache"
                " oscille au rythme du pas",
        "strike": [
            "il se ramasse, la hache ramenée en arrière",
            "il lève la hache au-dessus de sa tête, à deux mains",
            "la hache est au plus haut, il baisse les cornes et souffle",
            "il abat la hache devant lui de tout son poids",
            "l'impact : le fer au plus bas, un arc rouge de choc au sol",
            "l'arc s'estompe, la poussière monte autour du fer",
            "il arrache la hache du sol et redresse le buste",
            "il revient à sa position de marche, la hache en main",
        ],
        "extra": ["⚠️ LA HACHE EST DANS LES 24 CASES DES DEUX PLANCHES, sans une"
                  " seule exception — un monstre qui la pose entre deux images la"
                  " ferait clignoter",
                  "elle reste DU MÊME CÔTÉ : sur la rangée de profil, le fer est"
                  " du côté vers lequel il regarde",
                  "l'arc rouge du coup part DEVANT lui, jamais derrière — c'est ce"
                  " qui dit de quel côté il frappe",
                  "ni les cornes ni le fer de la hache ne sortent de la case : si"
                  " la hache levée ne tient pas, la dessiner un peu plus courte"],
    },
    {
        "file": "chevalier_noir", "id": "chevalier", "name": "Chevalier Noir",
        "worst": "Bouclier et lame, sans faiblesse marquée : il n'a qu'un défaut"
                 " aujourd'hui, c'est qu'on ne voit pas de quel côté il tient sa"
                 " lame.",
        "look": "UN CHEVALIER NOIR. Une armure de plates noire et pourpre, aux"
                " épaulières hérissées, avec un heaume fermé d'où sortent deux"
                " lueurs violettes à la place des yeux. Une longue cape sombre"
                " tombe dans son dos. Il tient une épée droite à lame violette"
                " luisante dans une main, et un écu noir bordé de violet dans"
                " l'autre.",
        "walk": "une MARCHE MARTIALE complète : pas réguliers et lourds, la cape"
                " ondule derrière lui, l'écu monte et descend, la lame luit par"
                " intermittence",
        "strike": [
            "il se met en garde, l'écu devant, la lame en arrière",
            "il lève la lame au-dessus de l'épaule",
            "la lame est au plus haut, sa lueur violette s'intensifie",
            "il abat la lame en diagonale",
            "la frappe : un croissant violet au plus large, devant lui",
            "le croissant se dissipe, la lame poursuit sa course",
            "il ramène la lame et se remet en garde",
            "il retrouve sa position de marche, prêt à recommencer",
        ],
        "extra": ["l'écu et la lame restent DU MÊME CÔTÉ dans les 24 cases : sur"
                  " la rangée de profil, la lame est du côté où il regarde",
                  "sa cape traîne DERRIÈRE lui — c'est elle qui dit son sens"],
    },
    {
        "file": "golem_givre", "id": "givre", "name": "Golem de Givre",
        "worst": "C'est le jumeau glacé du Golem de Lave, et il doit s'en"
                 " distinguer AU PREMIER COUP D'ŒIL : même stature, tout le"
                 " reste opposé. Et comme lui il frappe de loin — une rafale de"
                 " cristaux à quatre cases devant lui, qu'il faut voir partir.",
        "look": "UN GOLEM DE GIVRE. Un colosse de pierre grise sombre couvert de"
                " plaques de glace bleu vif. SON DOS PORTE UNE CRÊTE DE GRANDS"
                " CRISTAUX DE GLACE, dressés comme les pointes d'un dos de"
                " dragon, du cou jusqu'aux reins — c'est sa marque, elle doit se"
                " voir de face comme de dos, dépassant de ses épaules. D'autres"
                " cristaux plus courts sortent de ses avant-bras. Un cœur de"
                " glace bleu clair brille dans sa poitrine, ses yeux sont deux"
                " fentes blanches. Une buée froide tombe de ses bras.",
        "walk": "un PAS LOURD complet : il se balance d'une jambe sur l'autre,"
                " la crête de cristaux du dos oscille à contretemps du corps, et"
                " un souffle de givre s'échappe au sol à chaque appui",
        "strike": [
            "il se tasse, la crête du dos se hérisse et s'allonge",
            "il ramène les deux bras contre lui, la glace craque",
            "le cœur bleu s'allume à plein, du givre monte de ses paumes",
            "il ouvre les bras d'un grand geste, paumes en avant",
            "LA RAFALE PART : une rangée de pointes de glace jaillit du sol"
            " devant lui, la plus proche est la plus haute",
            "la rangée s'étire un peu plus loin, les premières pointes"
            " commencent à se fendre",
            "les pointes s'effondrent en esquilles, la buée s'étale au sol",
            "il retrouve son appui, les bras retombés",
        ],
        "extra": ["il ne doit JAMAIS avoir de teinte orange ou rouge : c'est ce"
                  " qui le sépare du Golem de Lave, sa seule différence lisible"
                  " à la taille où le jeu l'affiche",
                  "⚠️ LA RAFALE NE SORT PAS DE LA CASE. Elle part de ses pieds et"
                  " s'arrête au bord : c'est le jeu qui la fait courir sur quatre"
                  " cases. Une rangée dessinée hors du cadre serait dessinée deux"
                  " fois à l'écran",
                  "⚠️ IL RESTE DEBOUT DERRIÈRE SA RAFALE, visible en entier, dans"
                  " les 8 cases. La rangée de glace s'ajoute à lui, elle ne prend"
                  " jamais sa place — une case où l'on ne verrait que les"
                  " cristaux le ferait disparaître en plein coup",
                  "la crête du dos est visible dans les 24 cases des DEUX"
                  " planches, y compris de face — elle dépasse de ses épaules"],
    },
    {
        "file": "gobelin", "id": "goblin", "name": "Gobelin",
        "worst": "Petit, coriace, il frappe vite et souvent : c'est le monstre"
                 " qu'on voit le plus dans le jeu, donc celui dont la marche est"
                 " la plus regardée.",
        "look": "UN GOBELIN. Un petit humanoïde à la peau vert vif, grandes"
                " oreilles pointues, gros nez, yeux jaunes et sourire de travers"
                " plein de dents. Il porte une capuche et une tunique de cuir"
                " brun usé, une ceinture large, des bottes trop grandes. Il tient"
                " une massue de bois cloutée, plus grosse que son bras.",
        "walk": "une COURSE VIVE : grandes enjambées, les épaules qui roulent,"
                " les oreilles qui battent, la massue qui rebondit sur l'épaule",
        "walk_beats": [
            "APPUI AVANT : jambe droite loin devant, talon qui touche le sol,"
            " jambe gauche loin derrière, orteils qui poussent. Les deux pieds"
            " sont ÉCARTÉS AU MAXIMUM — plus large que ses épaules",
            "la jambe arrière quitte le sol et remonte, le corps s'abaisse",
            "PASSAGE : les deux jambes se croisent au milieu, presque jointes,"
            " le corps est au plus bas",
            "la jambe gauche part vers l'avant, la droite reste en arrière",
            "APPUI AVANT INVERSE : jambe gauche loin devant, talon au sol, jambe"
            " droite loin derrière. Écartement maximal, comme à l'image 1 mais"
            " jambes échangées",
            "la jambe arrière quitte le sol et remonte, le corps s'abaisse",
            "PASSAGE : les deux jambes se croisent au milieu, presque jointes",
            "la jambe droite repart vers l'avant : on revient à l'image 1",
        ],
        "strike": [
            "il se ramasse, la massue derrière l'épaule",
            "il lève la massue en arrière, tout le corps se tord",
            "la massue est au plus haut, il montre les dents",
            "il abat la massue devant lui de tout son poids",
            "l'impact : la massue au plus bas, un choc et de la poussière",
            "la poussière retombe, il est encore penché en avant",
            "il redresse le buste et remonte la massue",
            "il revient à sa position de marche, prêt à recommencer",
        ],
        "extra": ["la massue reste DU MÊME CÔTÉ dans les 24 cases : sur la"
                  " rangée de profil, elle est du côté où il regarde"],
    },
]


def sheet_block(subject: str) -> str:
    width, height = COLUMNS * CELL, ROWS * CELL
    return f"""FORMAT, à respecter exactement :
- UNE image de {width} x {height} pixels
- grille RÉGULIÈRE de {COLUMNS} colonnes x {ROWS} rangées, soit {COLUMNS * ROWS} cases de {CELL} x {CELL}
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases. Trois choses en
  particulier, qui reviennent sans cesse et qu'il faut supprimer :
    * AUCUNE OMBRE PORTÉE sous la créature — pas de flaque, pas de tache
    * AUCUN TRAIT entre les cases — pas de cadre, pas de bordure, pas de grille
    * aucun dégradé, aucune texture : un aplat, la même couleur partout
- dans chaque case, la créature est CENTRÉE et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

{fill("LA CRÉATURE — " + subject, 79)}"""


HEADER = """Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile."""

BLOCKING_TOP = """⚠️ RÈGLE BLOQUANTE — LA CRÉATURE EST DESSINÉE DANS LES 24 CASES, sans une seule
exception. Son coup, son souffle, sa rafale ou son projectile s'ajoutent à elle,
ils ne la REMPLACENT jamais : pas une case où l'on ne verrait que l'effet. Le jeu
enchaîne ces images en une seconde — une case sans la bête la fait disparaître au
milieu de son propre coup, ce que le joueur lit comme un bug d'affichage.

⚠️ RÈGLE BLOQUANTE — ELLE NE SE RETOURNE JAMAIS. Sur la rangée de profil, sa
tête est tournée VERS LA DROITE dans les 8 cases, sans une seule exception. Elle
ne doit pas regarder à droite sur une case et à gauche sur la suivante : en jeu,
les 8 cases s'enchaînent en une seconde, et la créature se retournerait la tête
quatre fois en marchant.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Ce sont les deux défauts
livrés le plus souvent, et aucun des deux ne se rattrape après coup :

  · l'OMBRE sous la créature est un magenta assombri. Le jeu efface le fond en
    mesurant l'écart à sa couleur : l'ombre en est trop loin pour être effacée,
    et il en reste une flaque rose collée sous la bête dans les 24 cases. On ne
    peut pas la viser sans risquer la créature elle-même — c'est mesuré : la
    brume violette d'un autre monstre de ce jeu est PLUS magenta que cette
    flaque. Il n'y a donc qu'un endroit où la retirer : ici, en ne la dessinant
    pas.

  · le TRAIT entre les cases est blanc, donc aussi loin du magenta qu'on peut
    l'être : il survit à tout et devient le bord de chaque sprite."""

# ⚠️ POUR LES BÊTES À JAMBES SEULEMENT. Posée sur toutes, cette règle demandait de
# grandes enjambées au Dragonnet, dont le prompt replie les pattes sous lui : deux
# consignes contraires dans la même image. Ce qui vole, flotte ou rampe n'a pas de
# `stride` dans le bestiaire, et porte ici `"legs": False`.
LEG_RULE = """⚠️ RÈGLE BLOQUANTE — LES JAMBES DOIVENT FAIRE DE VRAIS PAS. Le corps reste en
place, mais les JAMBES, elles, doivent travailler franchement : sur la rangée de
profil, on doit voir une jambe partir loin DEVANT pendant que l'autre pousse loin
DERRIÈRE, puis l'inverse. Deux appuis complets sur les huit images.

⚠️ CHIFFRE À TENIR : aux images d'APPUI, l'écart entre le talon avant et les
orteils arrière doit valoir au moins LA MOITIÉ DE LA HAUTEUR de la créature. Sur
les planches livrées jusqu'ici il valait un cinquième — c'est trois fois trop peu,
et c'est précisément ce qui fait glisser la bête. Des jambes qui ne font que
frémir donnent une bête qui GLISSE sur le sol au lieu de marcher — c'est le
défaut le plus désagréable à l'œil, et le seul qu'on ne sache pas nommer quand on
le voit."""

BLOCKING_BOTTOM = """⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. C'est la règle
la plus souvent ratée, alors voici comment la vérifier toi-même :

    EMPILE MENTALEMENT LES 8 IMAGES D'UNE RANGÉE.
    Le TRONC et la TÊTE doivent se superposer exactement.
    Seuls les bras, les jambes, la cape et l'arme bougent.

Autrement dit : la créature est CENTRÉE au même endroit dans les 8 cases, à
quelques pixels près, et elle garde exactement la même taille. Ne dessine SURTOUT
PAS une marche qui traverse le cadre — un personnage qui part du bord gauche à la
première image et arrive au bord droit à la huitième est précisément le défaut à
éviter. C'est le JEU qui la fait avancer sur la carte ; la planche ne montre que
le mouvement des membres, sur place, comme quelqu'un qui marcherait sur un tapis
roulant.

Une créature qui dérive dans son cadre patine d'avant en arrière à l'écran au
lieu de marcher, et son arme sort de la case au passage.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de la créature doit toucher
la même ligne dans les 24 cases. C'est cette ligne que le jeu pose sur le sol :
si elle bouge, le monstre s'enfonce et ressort du sol en marchant."""


GLIDE_ROW = """| La créature glisse au lieu de marcher | **défaut bloquant** : ses jambes ne bougent pas assez. Redemander « une jambe loin devant, l'autre loin derrière, deux appuis sur les huit images ». `build_enemies.py` mesure la course du pied avant |
"""


def fiche(beast: dict) -> str:
    walk_rows ="""LES TROIS RANGÉES, de haut en bas :
- rangée 1 : la créature vue DE FACE, elle avance vers le bas de l'image
- rangée 2 : la créature vue DE DOS, elle s'éloigne vers le haut de l'image
- rangée 3 : la créature vue DE PROFIL, TOURNÉE VERS LA DROITE, elle avance vers
  la droite de l'image"""
    strike_rows = """LES TROIS RANGÉES, de haut en bas :
- rangée 1 : elle frappe VERS LE BAS, face au joueur
- rangée 2 : elle frappe VERS LE HAUT, de dos
- rangée 3 : elle frappe VERS LA DROITE, de profil, TOURNÉE VERS LA DROITE"""

    beats = "\n".join(f"{i + 1}. {beat}"
                      for i, beat in enumerate(beast["strike"]))
    # LA MARCHE, DÉCRITE IMAGE PAR IMAGE quand la créature l'exige.
    #
    # La description en une phrase — « un cycle de marche complet » — suffit à
    # une bête qui ondule ou qui flotte. Elle ne suffit PAS à une bête à jambes :
    # trois planches de gobelin livrées de suite ont donné des jambes qui
    # frémissent, parce que rien ne disait ce que doit contenir un cycle. Les
    # huit temps le disent.
    if beast.get("walk_beats"):
        steps = "\n".join(f"{i + 1}. {beat}"
                           for i, beat in enumerate(beast["walk_beats"]))
        walk_block = (f"LES {COLUMNS} COLONNES de chaque rangée sont UN CYCLE DE "
                      f"MARCHE COMPLET, lu de gauche à droite, et voici ce que "
                      f"chacune doit montrer :\n{steps}\n\nLa {COLUMNS}e image "
                      f"enchaîne sur la première sans à-coup.")
    else:
        walk_block = (f"LES {COLUMNS} COLONNES de chaque rangée, lues de gauche "
                      f"à droite, sont {beast['walk']}. La {COLUMNS}e image doit "
                      f"enchaîner sur la première sans à-coup.")
    extra = "\n".join(f"- {rule}" for rule in beast.get("extra", []))
    extra = ("\n" + extra) if extra else ""

    has_legs = beast.get("legs", True)
    blocking = "\n\n".join([BLOCKING_TOP, LEG_RULE, BLOCKING_BOTTOM] if has_legs
                           else [BLOCKING_TOP, BLOCKING_BOTTOM])
    glide_row = GLIDE_ROW if has_legs else ""

    return f"""# {beast['name']} — planches de marche et d'attaque

## Pourquoi celui-ci

{fill(beast['worst'], 79)}

    aujourd'hui   4 pas · 1 pose de coup
    demain        4 orientations · 8 pas · 8 poses de coup

⚠️ **Le moteur sait déjà les jouer.** Il lit les poses par leur NOM et non par
leur nombre : une planche à seize poses et une planche à six se jouent par le
même code, et l'attaque se déroule sur la durée exacte de la frappe. Les autres
créatures continuent de tourner sans y toucher. Il ne manque que le dessin.

---

## Deux planches, et pourquoi pas une

    {beast['file']}_marche.png    {COLUMNS} colonnes x {ROWS} rangées   face / dos / profil DROIT
    {beast['file']}_attaque.png   {COLUMNS} colonnes x {ROWS} rangées   face / dos / profil DROIT

Quarante-huit cases dans une seule image reviendraient bouillies : chaque pose
ferait moins de {CELL} pixels et la créature perdrait son visage. En deux
planches, chaque case reste grande.

⚠️ **La gauche n'est PAS demandée.** Le jeu la fabrique en retournant le profil
droit. Deux dessins donneraient deux démarches — et c'est exactement le défaut
qui a fait marcher sept créatures de ce jeu à reculons pendant des semaines,
sans que rien ne le signale.

⚠️ **Le profil regarde à DROITE.** C'est la seule chose que la convention ne
disait pas, et elle a coûté cher. Les indices qui tranchent : l'œil, la gueule,
et la traînée du coup qui part DEVANT.

Les deux planches vont dans `assets/peso&cover/creatures/`.

---

## Prompt 1 — la marche

```
{HEADER}

{sheet_block(beast['look'])}

{walk_rows}

{walk_block}

{blocking}

AUTRES RÈGLES :
- la MÊME créature dans les 24 cases : mêmes couleurs, même taille
- le profil regarde VERS LA DROITE dans les 8 cases de la rangée 3, sans
  exception{extra}
- aucune attaque, aucun projectile : elle se déplace, c'est tout
```

---

## Prompt 2 — l'attaque

```
{HEADER}

{sheet_block(beast['look'])}

⚠️ MÊMES COULEURS ET MÊME TAILLE QUE LA PLANCHE DE MARCHE. Les deux planches
sont jouées l'une après l'autre sur le même monstre : une teinte plus sombre ou
une créature plus grande se verrait comme un clignotement au moment du coup.

{strike_rows}

LES {COLUMNS} COLONNES de chaque rangée sont UN SEUL COUP qui se déroule, lu de
gauche à droite — ce n'est PAS une boucle :
{beats}

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE. Le jeu enchaîne
directement sur le déplacement : si la créature reste en position de combat à la
dernière image, elle se remettra à marcher dans cette pose.

{blocking}

AUTRES RÈGLES :
- la traînée du coup part DEVANT elle, dans la direction qu'elle frappe — vers le
  bas rangée 1, vers le haut rangée 2, vers la droite rangée 3{extra}
- rien ne QUITTE la case : cette créature frappe au contact, elle ne tire pas
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Le profil regarde à gauche | **défaut bloquant** : le monstre marchera à reculons. Rappeler « tourné vers la DROITE » et nommer l'indice — l'œil, la gueule, la traînée devant |
| Une case ne montre que l'effet, sans la créature | **défaut bloquant** : elle disparaîtrait en plein coup. `build_enemies.py` mesure la matière du haut de case et nomme les fautives |
| Le profil change de côté d'une case à l'autre | **défaut bloquant**, et le plus sournois : vu de loin la planche semble juste. La créature se retournerait la tête quatre fois par cycle. `build_enemies.py` le mesure et nomme les cases fautives |
| Une ombre portée est dessinée sur le fond | **défaut bloquant** : elle survit à l'effacement du magenta et laisse une salissure grise sous la bête |
{glide_row}| La créature dérive dans son cadre d'une case à l'autre | **défaut bloquant**, et le plus fréquent : elle patinerait d'avant en arrière au lieu de marcher. Redemander en insistant sur « le tronc se superpose d'une image à l'autre, seuls les membres bougent ». `build_enemies.py` mesure la dérive en pixels |
| La créature change de taille d'une case à l'autre | **défaut bloquant** : elle sauterait à l'écran à chaque image |
| Le bas de la créature bouge d'une case à l'autre | **défaut bloquant** : elle s'enfoncerait dans le sol en marchant |
| Les deux planches n'ont pas les mêmes couleurs | rappeler « mêmes couleurs, même taille » — sinon clignotement au moment du coup |
| Le cycle de marche ne boucle pas | moins grave — huit images passent vite. À corriger si on le voit sauter |
| La dernière image d'attaque reste en garde | rappeler « elle rejoint la pose de marche » |

---

## Ce que je fais quand elles arrivent

1. **découpe** : `tools/.venv/bin/python tools/build_enemies.py {beast['file']}` —
   l'outil est écrit et il attend les planches. Il détoure le magenta y compris
   enclavé, mesure les 48 cases ENSEMBLE pour une case commune, cale sur les
   pieds, et fabrique la gauche en retournant le profil droit ;
2. **import** : `godot --headless --path . --import`, obligatoire pour tout
   nouveau PNG ;
3. **contrôle** : `tools/.venv/bin/python tools/check_profiles.py` — la planche
   de contact qui vérifie que tous les profils gauches regardent bien à gauche.
   C'est l'outil né du défaut des sept créatures ;
4. **capture en jeu**, la créature collée au mage, pour voir le coup se dérouler.

Sortie : `assets/enemies/{beast['id']}/` — quatre bandes de 17 poses (`idle`,
huit pas, huit coups) et leur descripteur.

---

*Fiche produite par `tools/build_prompts_enemies.py`. Les onze fiches partagent
leur format : corriger une règle se fait dans l'outil, pour tout le bestiaire à
la fois.*
"""


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for beast in HERD:
        (OUT / f"{beast['file']}.md").write_text(fiche(beast), encoding="utf-8")
    print("%d fiches écrites dans %s : %s" % (
        len(HERD), OUT, ", ".join(b["file"] for b in HERD)))


if __name__ == "__main__":
    main()
