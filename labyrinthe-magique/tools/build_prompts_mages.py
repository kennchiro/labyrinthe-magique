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
