#!/usr/bin/env python3
"""Les prompts des mages ANIMÉS : une fiche par mage, dans `docs/prompts/mages_animes/`.

    tools/.venv/bin/python tools/build_prompts_mages.py     # DEPUIS LA RACINE

Même gabarit que le bestiaire (`build_prompts_enemies.py`) : 8 pas et 8 images
d'attaque au lieu de 4 pas et une pose. Le texte commun s'écrit UNE fois, seul ce
qui appartient au mage reste par fiche.

Trois règles viennent de ce que les planches actuelles ont montré :

⚠️ LE SORT PART DU CÔTÉ REGARDÉ. Le générateur centre l'attaque sur le sort et le
lance presque toujours vers la droite : six mages sur huit tiraient dans leur dos.
⚠️ LE SORT NE S'ÉLOIGNE PAS DU CORPS. Le rocher de la Terre et le croissant de l'Air
faussaient le calage sur les pieds, et le mage sautait d'un quart de case. Le jeu
dessine déjà le projectile : la planche ne montre que le geste et sa lueur.
⚠️ LE SORT PART TÔT, à l'image 3. Le jeu lance le projectile à la pression de la
touche et le geste dure 0,32 s : plus tard, le tir partirait avant la main.
"""

from pathlib import Path
from textwrap import fill

from PIL import Image, ImageDraw

OUT = Path("docs/prompts/mages_animes")
## Le guide de marche joint au générateur, en plus de l'image du personnage.
GUIDE = OUT / "guide_marche.png"

COLUMNS, ROWS, CELL = 8, 3, 256

COMPACT = ("Corps COMPACT, tête un peu large, silhouette lisible en très petit. "
           "L'aura reste COLLÉE au corps : pas de halo large, pas de nuage de "
           "particules autour.")

## `look` est recopié TEL QUEL dans les deux prompts : c'est la seule façon d'être
## sûr que les deux planches montrent le même mage. `legs` dit comment rendre les
## pas visibles sous son vêtement, `hold` ce que ses mains font en marchant.
MAGES = [
    {
        "file": "feu", "id": "fire", "name": "Mage du Feu", "reference": "feu.png",
        "look": "le Mage du Feu. Robe écarlate à liserés orange, capuche relevée, "
                "épaules larges, ceinture de cuir sombre. Ses MAINS SONT NUES et "
                "cerclées de flammes courtes : il n'a pas de bâton. Deux braises "
                "orange lui tiennent lieu d'yeux sous la capuche.",
        "legs": "la robe est fendue devant et ses bottes sombres sortent franchement à chaque pas",
        "hold": "ses deux mains enflammées balancent le long du corps, en opposition aux jambes",
        "strike": [
            "il ramène la main droite contre sa hanche, la flamme s'y resserre",
            "la main remonte à hauteur de poitrine, la flamme grossit, le buste se tourne",
            "LE TIR : bras tendu vers l'avant, paume ouverte, une boule de feu grosse comme sa tête au bout des doigts",
            "le bras reste tendu, la boule se détache de la paume d'un souffle",
            "la flamme retombe en langues courtes autour de la main",
            "le bras redescend à moitié, quelques braises tombent",
            "la main revient près de la hanche, la flamme reprend sa taille",
            "il retrouve exactement sa pose de marche",
        ],
    },
    {
        "file": "eau", "id": "water", "name": "Mage de l'Eau", "reference": "eau.png",
        "look": "le Mage de l'Eau. Robe bleu profond à liserés turquoise, capuche, "
                "écharpe claire. Il tient un BÂTON MAGIQUE de la main droite : une "
                "hampe pâle surmontée d'une GOUTTE DE CRISTAL BLEU d'où perle une "
                "eau qui ne tombe jamais.",
        "legs": "le bas de la robe s'ouvre et ses bottes sortent franchement à chaque pas",
        "hold": "le bâton reste dans sa main droite, tenu droit, et l'écharpe flotte derrière lui",
        "strike": [
            "il ramène le bâton contre l'épaule, la goutte de cristal s'éclaire",
            "le bâton bascule vers l'avant, de l'eau s'enroule autour de la goutte",
            "LE TIR : bâton pointé vers l'avant, un jet d'eau court et dense jaillit de la goutte",
            "le jet s'étire d'un dernier coup, des gouttes s'en échappent",
            "le jet retombe en éclaboussures près de la goutte",
            "le bâton remonte, les dernières gouttes tombent",
            "le bâton revient presque à la verticale",
            "il retrouve exactement sa pose de marche",
        ],
    },
    {
        "file": "terre", "id": "earth", "name": "Mage de la Terre", "reference": "terre.png",
        "look": "le Mage de la Terre. Robe brun-vert, épaulières de pierre brute, "
                "barbe grise, corps LARGE ET TRAPU : c'est le plus massif des huit. "
                "Il tient un BÂTON MAGIQUE de la main droite : une branche noueuse "
                "surmontée d'une PIERRE VERTE BRUTE sertie dans le bois.",
        "legs": "la robe courte laisse voir ses grosses bottes, et chaque pas est lourd et bien posé",
        "hold": "le bâton reste dans sa main droite et frappe le rythme de ses pas",
        "strike": [
            "il saisit le bâton à deux mains, les genoux fléchissent",
            "il lève le bâton à hauteur de poitrine, la pierre verte s'éclaire",
            "LE COUP : il abat le bâton droit devant lui, des éclats de pierre jaillissent à son pied",
            "le bâton est planté dans le sol, une courte gerbe d'éclats et de poussière devant lui",
            "les éclats retombent, il pèse encore sur le bâton",
            "il arrache le bâton du sol, la poussière retombe",
            "il se redresse, le bâton revient à une main",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "AUCUN ROCHER dressé à côté de lui : le jeu dessine lui-même ses rochers. Les éclats restent petits et tiennent DEVANT ses pieds.",
    },
    {
        "file": "foudre", "id": "thunder", "name": "Mage de la Foudre", "reference": "foudre.png",
        "look": "le Mage de la Foudre. Tunique courte jaune et bleu nuit, fendue "
                "pour la course, bottes légères, cheveux blancs dressés par la "
                "charge. Il tient un BÂTON MAGIQUE court de la main droite : une "
                "hampe sombre surmontée d'un ÉCLAT JAUNE CRÉPITANT.",
        "legs": "c'est le plus rapide des huit : tunique courte, jambes bien visibles, une vraie foulée de coureur",
        "hold": "le bâton court est tenu en avant comme un coureur, le bras libre balance",
        "strike": [
            "il ramène le bâton près de l'épaule, de petites étincelles courent dessus",
            "le bâton se lève, l'éclat jaune s'allume, ses cheveux se hérissent",
            "LE TIR : bâton pointé vers l'avant, un éclair court et brisé part de l'éclat",
            "l'éclair crépite encore, deux ou trois branches courtes",
            "l'éclair s'éteint, il reste quelques étincelles sur la hampe",
            "le bâton redescend, les étincelles s'éteignent",
            "le bâton revient près du corps",
            "il retrouve exactement sa pose de marche",
        ],
    },
    {
        "file": "air", "id": "air", "name": "Mage de l'Air", "reference": "air.png",
        "look": "le Mage de l'Air. Robe blanche et bleu très pâle, longues écharpes "
                "qui flottent derrière lui, capuche souple. Il tient un BÂTON "
                "MAGIQUE fin de la main droite : une hampe claire surmontée d'un "
                "ANNEAU OUVERT dans lequel le vent siffle.",
        "legs": "la robe légère se soulève à chaque pas et ses bottines blanches sortent franchement",
        "hold": "le bâton reste dans sa main droite et les écharpes ondulent derrière lui",
        "strike": [
            "il écarte le bâton sur le côté, les écharpes se soulèvent",
            "le bâton commence son arc, un filet de vent s'enroule dans l'anneau",
            "LE TIR : bâton pointé vers l'avant, une courte lame de vent blanc-bleu part de l'anneau",
            "l'arc s'achève, la lame se dissout en deux filets courts",
            "les filets s'effacent, les écharpes retombent à moitié",
            "le bâton revient vers le corps",
            "les écharpes reprennent leur flottement de marche",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "AUCUN GRAND CROISSANT qui s'éloigne de lui : le jeu dessine lui-même le projectile. La lame reste petite et tient dans la case.",
    },
    {
        "file": "tenebres", "id": "shadow", "name": "Sorcier des Ténèbres", "reference": "tenebres.png",
        "look": "le Sorcier des Ténèbres. Robe violet sombre et noire, CAPUCHE "
                "PROFONDE qui mange le visage, deux yeux violets lumineux pour seule "
                "lumière. Pas de bâton : une ORBE D'OMBRE flotte au creux de sa main "
                "gauche, à quelques centimètres de la paume.",
        "legs": "le bas de la robe s'ouvre en lambeaux et ses bottes noires sortent franchement à chaque pas",
        "hold": "l'orbe d'ombre flotte toujours au-dessus de sa main gauche, qu'il garde devant lui",
        "strike": [
            "il ramène la main contre sa poitrine, l'orbe se resserre",
            "l'orbe grossit au creux de sa paume, le buste se tourne",
            "LE TIR : bras tendu vers l'avant, l'orbe au bout des doigts, un filament violet la relie à la paume",
            "le filament s'étire, l'orbe vibre",
            "le filament se rompt et se dissout près de la main",
            "le bras redescend à moitié, une nouvelle petite orbe naît",
            "la main revient devant lui, l'orbe reprend sa taille",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "Le violet reste SOMBRE ET BLEUTÉ, jamais rose vif : il ne doit pas se confondre avec le fond magenta. La robe garde des contours nets.",
    },
    {
        "file": "invocateur", "id": "invocateur", "name": "Invocateur", "reference": "invocateur.png",
        "look": "l'Invocateur. Robe violette à liserés d'or, capuche rejetée en "
                "arrière, cheveux noirs, colliers d'ossements, regard découvert. Il "
                "tient un BÂTON MAGIQUE de la main droite : une hampe torsadée "
                "surmontée d'une ORBE VIOLETTE enserrée dans des griffes d'or.",
        "legs": "la robe s'ouvre sur ses bottes sombres, qui sortent franchement à chaque pas",
        "hold": "le BÂTON EST DANS SA MAIN DROITE DANS LES 24 CASES, sans exception",
        "strike": [
            "il saisit le bâton plus haut, l'orbe s'éclaire doucement",
            "il lève le bâton, l'autre main s'ouvre paume vers le ciel",
            "L'APPEL : le bâton s'abat droit devant lui, l'orbe flamboie",
            "le bâton est planté, l'orbe lance de courtes volutes violettes",
            "les volutes montent et s'effacent, sa main libre reste ouverte",
            "il relâche sa main libre, l'orbe faiblit",
            "il retire le bâton du sol",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "AUCUN CERCLE AU SOL et aucune créature : le jeu dessine lui-même le cercle d'invocation. Le violet reste SOMBRE ET BLEUTÉ, jamais rose vif : il ne doit pas se confondre avec le fond magenta.",
    },
    {
        "file": "supreme", "id": "supreme", "name": "Sorcier Suprême", "reference": "supreme.png",
        "look": "le Sorcier Suprême, maître des quatre éléments. Robe sombre à "
                "liserés d'or, capuchon, deux yeux violets lumineux, quatre orbes "
                "élémentaires (rouge feu, bleu eau, vert terre, violet ténèbres) "
                "qui flottent près de son corps.",
        "legs": "la robe s'ouvre sur des bottes à liserés d'or, qui sortent franchement à chaque pas",
        "hold": "les quatre orbes tournent lentement autour de son buste et font UN tour complet sur les 8 images",
        "strike": [
            "il ramène les mains vers sa poitrine, les orbes se rapprochent de lui",
            "les quatre orbes se réunissent devant ses mains, de l'or brille entre elles",
            "LE TIR : bras tendu vers l'avant, les quatre orbes alignées dans un court trait de lumière dorée",
            "le trait brille encore, des étincelles d'or s'en échappent",
            "le trait s'éteint, les orbes se séparent",
            "les orbes s'écartent de ses mains",
            "les orbes reprennent leur place autour du buste",
            "il retrouve exactement sa pose de marche",
        ],
    },
    {
        "file": "chrono", "id": "chrono", "name": "Chronomancien", "reference": "chrono.png",
        "today": "rien encore, c'est un nouveau mage",
        "look": "le Chronomancien. Longue robe turquoise sombre à liserés de cuivre, "
                "haut col de cuivre, cheveux argentés courts coiffés en arrière, "
                "visage découvert. Un GRAND SABLIER de cuivre au sable turquoise est "
                "fixé DANS SON DOS et dépasse au-dessus de ses épaules. Il tient de "
                "la main droite un BÂTON en forme de GRANDE AIGUILLE D'HORLOGE en "
                "cuivre, surmonté d'un petit cadran turquoise.",
        "legs": "la robe s'ouvre devant et ses bottes de cuir cuivré sortent franchement à chaque pas",
        "hold": "l'aiguille reste dans sa main droite, tenue droite, et le sablier reste immobile dans son dos",
        "strike": [
            "il ramène l'aiguille contre l'épaule, le petit cadran s'éclaire",
            "l'aiguille bascule vers l'avant, un filet de sable turquoise s'enroule autour",
            "LE TIR : aiguille pointée vers l'avant, une courte pointe de lumière turquoise part du cadran",
            "la pointe s'efface, quelques grains de sable turquoise restent suspendus",
            "les grains retombent près du cadran",
            "l'aiguille remonte, le cadran faiblit",
            "l'aiguille revient presque à la verticale",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "LE SABLIER garde la même taille et la même place dans les 24 cases, il reste entier dans la case et ne pivote jamais. AUCUN CADRAN GÉANT ni cercle au sol : le jeu dessine lui-même ses sorts. Le turquoise reste VERT-BLEU et le cuivre reste ORANGÉ, jamais rose : ils ne doivent pas se confondre avec le fond magenta.",
    },
    {
        "file": "peste", "id": "peste", "name": "Mage de la Peste", "reference": "peste.png",
        "today": "rien encore, c'est un nouveau mage",
        "look": "le Mage de la Peste, un alchimiste. MASQUE DE MÉDECIN DE PESTE en cuir "
                "sombre, à long bec courbe et à deux verres ronds VERT ACIDE lumineux. "
                "Capuche et long manteau aubergine très sombre, presque noir, à liserés "
                "vert acide. Trois petites FIOLES de liquide vert acide pendent à sa "
                "ceinture. Il tient de la main droite un BÂTON tordu en bois noir, "
                "surmonté d'une grosse FIOLE RONDE pleine de liquide vert acide.",
        "legs": "le manteau s'ouvre devant et ses bottes de cuir sombre sortent franchement à chaque pas",
        "hold": "le bâton reste dans sa main droite, tenu droit, et les trois fioles restent accrochées à sa ceinture",
        "strike": [
            "il ramène le bâton contre l'épaule, le liquide de la grosse fiole s'éclaire",
            "le bâton bascule vers l'avant, des bulles vertes montent dans la fiole",
            "LE TIR : bâton pointé vers l'avant, un court jet de venin vert acide part de la fiole",
            "le jet s'étire, deux ou trois gouttes vertes s'en détachent",
            "les gouttes tombent près de la fiole et s'éteignent",
            "le bâton remonte, les bulles se calment dans la fiole",
            "le bâton revient presque à la verticale",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "LE BEC DU MASQUE reste entier et de même taille dans les 24 cases : de profil, il pointe VERS LA DROITE. AUCUN NUAGE, aucune flaque au sol et aucun gaz autour de lui : le jeu dessine lui-même ses sorts. L'aubergine reste PRESQUE NOIR ET BLEUTÉ, jamais violet vif ni rose : il ne doit pas se confondre avec le fond magenta.",
    },
    {
        "file": "lumiere", "id": "lumiere", "name": "Porte-Lumière", "reference": "lumiere.png",
        "today": "rien encore, c'est un nouveau mage",
        "look": "le Porte-Lumière, un ange. Deux GRANDES AILES de plumes blanches, à demi "
                "repliées dans son dos. Une AURÉOLE d'or plate flotte au-dessus de sa tête. "
                "Courts cheveux blonds, visage serein bien visible, armure légère blanc "
                "ivoire à liserés d'or sur une tunique blanche, bottes d'or. Il tient de la "
                "main droite une LANCE dorée, surmontée d'une pointe de cristal blanc "
                "lumineux. Toutes ses formes blanches sont cernées d'un contour BRUN FONCÉ net.",
        "legs": "la tunique courte s'ouvre et ses bottes d'or sortent franchement à chaque pas",
        "hold": "la lance reste dans sa main droite, tenue droite, et les ailes restent à demi repliées dans son dos, sans battre",
        "strike": [
            "il ramène la lance contre l'épaule, la pointe de cristal s'éclaire",
            "la lance bascule vers l'avant, un filet de lumière dorée s'enroule autour",
            "LE TIR : lance pointée vers l'avant, un court trait de lumière blanche et or part de la pointe",
            "le trait s'efface, deux ou trois étincelles d'or restent près de la pointe",
            "les étincelles s'éteignent, la pointe brille encore",
            "la lance remonte, la lumière de la pointe faiblit",
            "la lance revient presque à la verticale",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "LES AILES ET L'AURÉOLE gardent la même taille, la même forme et la même place dans les 24 cases, et restent entières DANS la case : jamais déployées, elles ne dépassent pas de plus d'un quart de la largeur du corps de chaque côté. AUCUN RAYON ni halo large autour de lui et aucune colonne de lumière : le jeu dessine lui-même ses sorts. Les ombres du blanc sont BEIGE et BRUN CLAIR, jamais roses ni violettes : aucun reflet du fond magenta sur les plumes.",
    },
    {
        "file": "mort", "id": "mort", "name": "Ange de la Mort", "reference": "mort.png",
        "today": "rien encore, c'est un nouveau personnage",
        "look": "l'Ange de la Mort, un ange déchu à l'allure un peu démoniaque. Deux GRANDES "
                "AILES de plumes noires, déchirées et effilochées au bout, à demi repliées dans "
                "son dos. Deux PETITES CORNES noires courbes sortent de son front, et une "
                "AURÉOLE BRISÉE rouge braise, ouverte comme un anneau fendu, flotte au-dessus de "
                "sa tête. Visage pâle couleur d'os, bien visible, aux yeux rouge braise, et "
                "cheveux noirs mi-longs. Armure sombre gris anthracite à liserés couleur d'os, "
                "sur une longue robe noire déchirée au bas, bottes noires griffues. Il tient de la "
                "main droite une grande FAUX au manche d'os, dont la lame noire est bordée de "
                "rouge braise. Toutes ses formes noires sont cernées d'un fin liseré CLAIR couleur "
                "d'os, qui les détache des sols sombres.",
        "legs": "la robe déchirée s'ouvre devant et ses bottes griffues sortent franchement à chaque pas",
        "hold": "la faux reste dans sa main droite, tenue droite, lame en haut, et les ailes restent à demi repliées dans son dos, sans battre",
        "strike": [
            "il ramène la faux en arrière, au-dessus de l'épaule, la lame s'allume de rouge braise",
            "la faux part vers l'avant en arc de cercle, le buste suit, un filet rouge longe la lame",
            "LE TIR : la faux à l'horizontale devant lui, bras tendus, un court croissant rouge et noir collé au tranchant",
            "le croissant s'efface, deux ou trois braises restent près de la lame",
            "la faux finit son arc, les braises s'éteignent, le tranchant luit encore",
            "la faux remonte, la lueur de la lame faiblit",
            "la faux revient presque à la verticale",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "LES AILES, LES CORNES, L'AURÉOLE BRISÉE ET LA FAUX gardent la même taille, la même forme et la même place dans les 24 cases, et restent entières DANS la case, y compris la lame à l'image du tir : les ailes ne dépassent pas de plus d'un quart de la largeur du corps de chaque côté. AUCUNE FUMÉE, aucune âme et aucune flamme autour de lui : le jeu dessine lui-même ses sorts. Le noir reste NEUTRE ou BLEUTÉ et le rouge reste ORANGÉ, couleur de braise : aucun violet, aucun rose, aucun reflet du fond magenta.",
    },
    {
        "file": "etoiles", "id": "etoiles", "name": "Ange des Étoiles", "reference": "etoiles.png",
        "today": "rien encore, c'est un nouveau personnage",
        "look": "l'Ange des Étoiles, une femme adulte, un ange au visage calme et bien visible. "
                "Deux GRANDES AILES de plumes bleu nuit, semées de petits points blancs comme un "
                "ciel étoilé, à demi repliées dans son dos. Une COURONNE EN CROISSANT DE LUNE "
                "argentée flotte au-dessus de sa tête. Longs cheveux argentés attachés en une "
                "tresse qui tombe dans son dos. Longue robe bleu nuit à manches longues, sobre et "
                "couvrante, à liserés d'argent, fendue sur le côté, sur des bottines argentées. "
                "Elle tient de la main droite un fin SCEPTRE d'argent, surmonté d'une étoile "
                "blanche à quatre branches. Toutes ses formes sombres sont cernées d'un fin liseré "
                "ARGENTÉ, qui les détache des sols sombres.",
        "legs": "la robe s'ouvre par sa fente et ses bottines argentées sortent franchement à chaque pas",
        "hold": "le sceptre reste dans sa main droite, tenu droit, et les ailes restent à demi repliées dans son dos, sans battre",
        "strike": [
            "elle ramène le sceptre contre l'épaule, l'étoile du sommet s'éclaire",
            "le sceptre bascule vers l'avant, un filet de lumière bleu pâle s'enroule autour",
            "LE TIR : sceptre pointé vers l'avant, un petit éclat d'étoile blanc et bleu pâle jaillit du sommet",
            "l'éclat s'efface, deux ou trois petits points blancs restent près de l'étoile",
            "les points s'éteignent, l'étoile brille encore",
            "le sceptre remonte, la lumière de l'étoile faiblit",
            "le sceptre revient presque à la verticale",
            "elle retrouve exactement sa pose de marche",
        ],
        "extra": "LES AILES, LA COURONNE, LA TRESSE ET LE SCEPTRE gardent la même taille, la même forme et la même place dans les 24 cases, et restent entiers DANS la case : les ailes ne dépassent pas de plus d'un quart de la largeur du corps de chaque côté. AUCUNE ÉTOILE ni aucun point lumineux HORS de son corps en dehors de l'éclat du tir : le jeu dessine lui-même ses sorts. Le bleu reste un BLEU NUIT franc et l'argent reste NEUTRE ou BLEUTÉ : aucun violet, aucun rose, aucun reflet du fond magenta.",
    },
    {
        "file": "acier", "id": "acier", "name": "Archange d'Acier", "reference": "acier.png",
        "today": "rien encore, c'est un nouveau personnage",
        "look": "l'Archange d'Acier, un ange guerrier MASSIF et COSTAUD, très large d'épaules, en "
                "ARMURE DE PLATES INTÉGRALE gris-bleu, faite de grandes plaques épaisses bien "
                "visibles : énormes épaulières, plastron bombé, gantelets et grosses bottes de "
                "métal. HEAUME FERMÉ : aucun visage, seulement une fente horizontale d'où sort une "
                "lueur orange. De fines fentes orange, couleur de métal chauffé, courent entre les "
                "plaques du plastron. Deux GRANDES AILES faites entièrement de LAMES D'ACIER "
                "superposées, sans aucune plume, à demi repliées dans son dos. Il porte de la main "
                "droite un grand MARTEAU DE GUERRE, à la tête d'acier massive et au manche épais. "
                "Ses plaques sombres sont cernées d'un fin liseré GRIS CLAIR, qui les détache des "
                "sols sombres.",
        "legs": "ses jambes blindées et ses grosses bottes de métal se lèvent franchement à chaque pas, d'une démarche lourde",
        "hold": "le marteau reste dans sa main droite, posé sur l'épaule, et les ailes de lames restent à demi repliées dans son dos, sans battre",
        "strike": [
            "il saisit le marteau à deux mains et l'arme haut derrière l'épaule, les fentes de l'armure s'éclairent",
            "le marteau monte au-dessus de la tête, le torse se tend, la tête de l'arme rougeoie",
            "le marteau commence à s'abattre vers l'avant, un arc gris clair suit sa tête",
            "L'IMPACT : bras tendus, le marteau frappe vers l'avant, un petit éclat blanc et orange jaillit de sa tête",
            "l'éclat s'efface, deux ou trois petites étincelles orange restent près de la tête du marteau",
            "le marteau remonte, la lueur de sa tête faiblit",
            "le marteau revient vers l'épaule",
            "il retrouve exactement sa pose de marche",
        ],
        "extra": "LES AILES, LE HEAUME ET LE MARTEAU gardent la même taille, la même forme et la même place dans les 24 cases, et restent entiers DANS la case, y compris la tête du marteau à l'image de l'impact : les ailes ne dépassent pas de plus d'un quart de la largeur du corps de chaque côté. AUCUNE ÉTINCELLE ni aucune lueur HORS de son corps en dehors de l'éclat de l'impact : le jeu dessine lui-même ses sorts. Le métal reste GRIS-BLEU, à plages nettes, et les seules couleurs chaudes sont les fentes orange : aucun violet, aucun rose, aucun reflet du fond magenta sur le métal.",
    },
]

HEADER = """Feuille de sprites pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style cartoon
coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile. L'image jointe montre le personnage : garde EXACTEMENT son visage,
ses couleurs, ses vêtements et ses proportions, mais PAS sa mise en page."""

COMMON_RULES = """⚠️ RÈGLE BLOQUANTE — LE PERSONNAGE EST DESSINÉ DANS LES 24 CASES, sans exception.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE. Une ombre sous le personnage
et un trait entre les cases ne s'effacent pas : ils resteraient collés au sprite.

⚠️ RÈGLE BLOQUANTE — LE CORPS NE BOUGE PAS D'UNE CASE À L'AUTRE. Empile mentalement
les 8 images d'une rangée : le TRONC et la TÊTE se superposent exactement. Il garde
la même taille, CENTRÉ au même endroit. C'est le JEU qui le fait avancer sur la
carte : la planche montre les membres, sur place, comme sur un tapis roulant.

⚠️ RÈGLE BLOQUANTE — LES PIEDS AU MÊME NIVEAU. Le bas de ses pieds touche la même
ligne horizontale dans les 24 cases, et rien n'est dessiné plus bas que cette ligne.

⚠️ RÈGLE BLOQUANTE — IL NE SE RETOURNE JAMAIS. Sur la rangée de profil, son visage
regarde VERS LA DROITE dans les 8 cases."""


def sheet_block(look: str) -> str:
    width, height = COLUMNS * CELL, ROWS * CELL
    return f"""FORMAT, à respecter exactement :
- UNE image de {width} x {height} pixels
- grille RÉGULIÈRE de {COLUMNS} colonnes x {ROWS} rangées, soit {COLUMNS * ROWS} cases de {CELL} x {CELL}
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ et occupe environ 80 % de la hauteur
- rien ne dépasse sur la case voisine, et 10 pixels restent vides autour de chaque case
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

{fill("LE PERSONNAGE — " + look + " " + COMPACT, 79)}"""


def fiche(mage: dict) -> str:
    beats = "\n".join(f"{i + 1}. {beat}" for i, beat in enumerate(mage["strike"]))
    extra = fill("⚠️ " + mage["extra"], 79) + "\n\n" if mage.get("extra") else ""
    legs = fill(f"SES JAMBES : {mage['legs']}.", 79)
    hold = fill(f"SES MAINS : {mage['hold']}.", 79)
    return f"""# {mage['name']} — planches de marche et d'attaque

    aujourd'hui   {mage.get('today', "4 pas · 1 pose d'attaque")}
    demain        4 orientations · 8 pas · 8 images d'attaque

**Avant de lancer :** joindre l'image `assets/peso&cover/refonte/{mage['reference']}`
au générateur, pour qu'il garde le même personnage. Pour la marche, joindre AUSSI
`docs/prompts/mages_animes/guide_marche.png`, qui impose la position des pieds.

**Déposer les deux résultats ici :**

    assets/peso&cover/mages/{mage['file']}_marche.png
    assets/peso&cover/mages/{mage['file']}_attaque.png

La gauche n'est PAS demandée : le jeu retourne le profil droit.

---

## Prompt 1 — la marche

```
{HEADER}

{sheet_block(mage['look'])}

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : vu DE FACE, il avance vers le bas de l'image
- rangée 2 : vu DE DOS, il s'éloigne vers le haut de l'image
- rangée 3 : vu DE PROFIL, TOURNÉ VERS LA DROITE, il avance vers la droite de l'image

{legs}
{hold}

⚠️ LA DEUXIÈME IMAGE JOINTE EST UN GUIDE DE POSE. Elle a la même grille que la planche
à produire. Dans chaque case, recopie EXACTEMENT la position de ses deux pieds et la
place de son corps. Le pied ROUGE est la jambe la plus proche de nous, le pied BLEU
la plus éloignée. Le mannequin et ses couleurs ne doivent PAS apparaître : c'est le
personnage de la première image, avec ses vraies bottes, qui prend ces poses.

LES 8 COLONNES de chaque rangée sont UN CYCLE DE MARCHE tranquille, à pas MOYENS :
1. le pied proche est devant, le pied éloigné derrière, les deux posés
2. le pied proche recule, le pied éloigné se lève à peine
3. PASSAGE : les pieds se croisent, le pied éloigné levé
4. le pied éloigné passe devant, le pied proche recule
5. l'INVERSE de l'image 1 : le pied éloigné devant, le pied proche derrière
6. le pied éloigné recule, le pied proche se lève à peine
7. PASSAGE : les pieds se croisent, le pied proche levé
8. le pied proche passe devant : l'image enchaîne sur la première

⚠️ RÈGLE BLOQUANTE — NI GRAND ÉCART NI PIEDS COLLÉS. De profil, aux images 1 et 5, l'écart
entre les pieds vaut environ UN TIERS DE LA HAUTEUR du personnage, jamais plus. Les deux
pieds échangent leur place : celui qui est devant à l'image 1 est derrière à l'image 5.
De face et de dos, les pieds restent sous le corps, sans s'écarter vers les côtés : l'un
puis l'autre se lève. Pas de jambes en compas, et pas de saut à pieds joints.

{COMMON_RULES}

AUCUNE attaque, aucun projectile sur cette planche : il marche, c'est tout.
```

---

## Prompt 2 — l'attaque

```
{HEADER}

{sheet_block(mage['look'])}

⚠️ MÊMES COULEURS ET SURTOUT MÊME TAILLE QUE LA PLANCHE DE MARCHE : la tête et le
tronc ont les mêmes dimensions en pixels. Un corps plus petit se verrait comme un
rétrécissement à chaque sort.

LES TROIS RANGÉES, de haut en bas :
- rangée 1 : il lance VERS LE BAS DE L'IMAGE, face au joueur : le bras et le sort
  viennent VERS NOUS, jamais sur le côté
- rangée 2 : il lance VERS LE HAUT DE L'IMAGE, de dos : le bras et le sort
  s'éloignent de nous, jamais sur le côté
- rangée 3 : il lance VERS LA DROITE, de profil, TOURNÉ VERS LA DROITE

LES 8 COLONNES de chaque rangée sont UN SEUL GESTE, de gauche à droite, pas une boucle :
{beats}

⚠️ RÈGLE BLOQUANTE — LE SORT PART DANS LA DIRECTION DE LA RANGÉE, et le corps reste
CENTRÉ dans sa case : c'est le CORPS qu'on centre, jamais l'ensemble corps et sort.

⚠️ RÈGLE BLOQUANTE — LE SORT RESTE PRÈS DE LA MAIN. Il tient dans la case et ne
dépasse pas la moitié de la hauteur du personnage. Le JEU dessine ensuite le
projectile qui voyage : la planche ne montre que le geste et sa lueur.

⚠️ RÈGLE BLOQUANTE — LA DERNIÈRE IMAGE REJOINT LA POSE DE MARCHE, et les pieds
restent à plat pendant tout le geste, à la même place.

{extra}{COMMON_RULES}
```

---

## À vérifier sur la planche reçue

| Défaut | Conséquence en jeu |
|---|---|
| Une ombre ou un trait de grille | Une salissure reste collée au sprite |
| Le corps se déplace dans la case | Le mage tressaute en marchant |
| Le corps est plus petit sur l'attaque | Il rétrécit à chaque sort |
| Le sort part sur le côté en rangée 1 ou 2 | Il semble tirer à côté de sa cible |
| Les pieds bougent à peine | Il glisse sur le sol |
| Le bâton ou l'orbe disparaît sur une case | L'objet clignote pendant la marche |
"""


## Position des pieds sur les 8 images : (avancée, hauteur), en part de la hauteur du
## mannequin. Le pied éloigné joue le même cycle, décalé de quatre images. C'est ce
## décalage qui fait échanger les pieds.
FOOT_PATH = [(0.17, 0.0), (0.09, 0.0), (0.0, 0.0), (-0.09, 0.0),
             (-0.17, 0.0), (-0.07, 0.06), (0.0, 0.09), (0.10, 0.05)]


def draw_guide() -> None:
    """Le mannequin de marche : un dessin dit ce que le texte n'a pas réussi à obtenir."""
    guide = Image.new("RGB", (COLUMNS * CELL, ROWS * CELL), (255, 0, 255))
    pen = ImageDraw.Draw(guide)
    body = (70, 70, 70)
    near, far = (230, 40, 30), (40, 90, 230)
    height = CELL * 0.80
    for row in range(ROWS):
        for column in range(COLUMNS):
            x0, y0 = column * CELL + CELL // 2, row * CELL
            floor = y0 + CELL * 0.90
            hip = floor - height * 0.34
            top = floor - height
            pen.ellipse((x0 - 36, top, x0 + 36, top + 72), fill=body)
            pen.rectangle((x0 - 28, top + 64, x0 + 28, hip), fill=body)
            for colour, shift in ((far, 4), (near, 0)):
                ahead, lift = FOOT_PATH[(column + shift) % COLUMNS]
                if row == 2:
                    foot_x = x0 + ahead * height
                    step = 22
                else:
                    # De face et de dos, le pied ne change pas de côté : il se lève.
                    side = 14 if colour == near else -14
                    foot_x = x0 + side
                    step = 8
                foot_y = floor - lift * height
                pen.line((x0, hip, foot_x, foot_y - 8), fill=colour, width=14)
                pen.rounded_rectangle((foot_x - 16, foot_y - 14, foot_x + step + 8, foot_y),
                                      radius=5, fill=colour)
    guide.save(GUIDE)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    draw_guide()
    for mage in MAGES:
        (OUT / f"{mage['file']}.md").write_text(fiche(mage), encoding="utf-8")
        print(f"  {mage['file']}.md")


if __name__ == "__main__":
    main()
