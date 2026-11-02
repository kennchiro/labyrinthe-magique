#!/usr/bin/env python3
"""Les guides de pose du Héros d'essai, joints au générateur avec ses prompts.

    tools/.venv/bin/python tools/build_template_guides.py    # DEPUIS LA RACINE

`guide_marche.png` ne donne que des jambes sous un corps droit et immobile. Ici, le
mannequin penche dans sa course, balance les bras et tient son arme : c'est ce que le
texte seul n'obtient pas du générateur.

CE QUI EST DESSINÉ, ET CE QUI NE L'EST PAS. Les planches portent les jambes, les bras et
la penchée, toujours la même. Le rebond et l'écrasement restent au jeu : réglés au code,
ils tournent à 60 images par seconde, et `steadied` n'y voit pas une dérive à corriger.
La tête ne bouge donc jamais d'une case à l'autre.

⚠️ AUCUNE PHASE EN L'AIR : un pied reste au sol à chaque image. Le joueur a rejeté les
pieds joints (« on dirait qu'il saute ») et les grandes enjambées (« catastrophe »),
d'où un écart maximal d'un tiers de la hauteur. La course se lit au genou qui monte.
"""

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

OUT = Path("docs/prompts/template")
COLUMNS = 8
ROWS = 3
CELL = 256

MAGENTA = (255, 0, 255)
BODY = (70, 70, 70)
NEAR = (235, 30, 30)
FAR = (40, 90, 235)
BLADE = (255, 215, 0)

CENTRE = CELL // 2
HEAD_Y = 60
HEAD_RADIUS = 36
SHOULDER_Y = 98
HIP_Y = 158
FLOOR_Y = 222
THIGH = 34
SHIN = 34
FOOT = 26
LIMB_WIDTH = 11
BLADE_LENGTH = 62
## La lame qui vient vers nous, ou s'éloigne, paraît plus courte.
BLADE_DEPTH_LENGTH = 46

## La penchée de la course, de profil : les épaules passent devant les hanches.
RUN_LEAN = 9

## La trajectoire d'un pied sur les huit images : (avancée, hauteur). L'autre pied la suit
## avec quatre images d'écart. ±34, soit un écart d'un tiers de la hauteur du corps.
STRIDE = [(34, 0), (18, 0), (0, 0), (-18, 0), (-34, 8), (-18, 26), (6, 36), (26, 14)]

## L'attaque, image par image : (main x depuis le centre, main y, angle de la lame en
## degrés, 0 vers la droite et 90 vers le bas). Un seul geste : 1 élan, 2 armé, 3 élancé,
## 4 IMPACT, 5 et 6 fin du geste, 7 retour, 8 pose de course.
STRIKE = {
    "profil": [(-10, 128, 135), (-30, 78, -120), (8, 66, -70), (48, 112, 10),
               (40, 140, 60), (24, 150, 85), (6, 138, 120), (-6, 130, 150)],
    "face": [(-30, 120, 110), (-44, 72, -110), (-30, 90, -50), (10, 150, 70),
             (30, 160, 40), (34, 158, 30), (-10, 140, 100), (-38, 130, 100)],
    "dos": [(38, 135, 100), (44, 100, 60), (38, 72, -40), (6, 60, -100),
            (-24, 66, -140), (-30, 76, -150), (10, 110, 60), (38, 130, 100)],
}
## La penchée du buste pendant l'attaque de profil, la tête restant en place.
STRIKE_LEAN = [0, -6, 0, 12, 12, 8, 4, 0]

## Le guide de profil part de la planche livrée : ses jambes sont repeintes.
SIDE_SOURCE = Path("assets/peso&cover/mages/test_marche.png")
SIDE_LEGS_SHARE = 0.27
SIDE_HIP_X = -4
SIDE_LEG_WIDTH = 17


def knee(hip: tuple, foot: tuple, sign: float) -> tuple:
    """Le genou de la jambe à deux segments, plié du côté `sign`."""
    dx, dy = foot[0] - hip[0], foot[1] - hip[1]
    span = min(math.hypot(dx, dy), THIGH + SHIN - 0.5)
    along = (THIGH * THIGH - SHIN * SHIN + span * span) / (2.0 * span)
    side = math.sqrt(max(0.0, THIGH * THIGH - along * along))
    ux, uy = dx / max(span, 0.5), dy / max(span, 0.5)
    return (hip[0] + ux * along - uy * side * sign, hip[1] + uy * along + ux * side * sign)


def draw_leg(pen: ImageDraw.ImageDraw, hip: tuple, foot: tuple, colour: tuple,
             sign: float, toe: float) -> None:
    joint = knee(hip, foot, sign)
    pen.line([hip, joint, foot], fill=colour, width=LIMB_WIDTH, joint="curve")
    left, right = (foot[0] - 6, foot[0] + FOOT) if toe > 0 else (foot[0] - FOOT / 2, foot[0] + FOOT / 2)
    pen.rounded_rectangle([left, foot[1] - 6, right, foot[1] + 6], radius=5, fill=colour)


def draw_arm(pen: ImageDraw.ImageDraw, shoulder: tuple, hand: tuple, colour: tuple,
             sign: float) -> None:
    elbow = knee(shoulder, hand, sign)
    pen.line([shoulder, elbow, hand], fill=colour, width=LIMB_WIDTH, joint="curve")
    pen.ellipse([hand[0] - 8, hand[1] - 8, hand[0] + 8, hand[1] + 8], fill=colour)


def draw_blade(pen: ImageDraw.ImageDraw, hand: tuple, angle: float, length: int) -> None:
    radians = math.radians(angle)
    tip = (hand[0] + math.cos(radians) * length, hand[1] + math.sin(radians) * length)
    pen.line([hand, tip], fill=BLADE, width=9)


def draw_body(pen: ImageDraw.ImageDraw, cx: int, oy: int, lean: float) -> None:
    pen.polygon([(cx - 28 + lean, oy + SHOULDER_Y - 10), (cx + 28 + lean, oy + SHOULDER_Y - 10),
                 (cx + 28, oy + HIP_Y), (cx - 28, oy + HIP_Y)], fill=BODY)
    pen.ellipse([cx - HEAD_RADIUS, oy + HEAD_Y - HEAD_RADIUS,
                 cx + HEAD_RADIUS, oy + HEAD_Y + HEAD_RADIUS], fill=BODY)


def side_foot(cx: int, oy: int, phase: int) -> tuple:
    forward, lift = STRIDE[phase % COLUMNS]
    return (cx + forward, oy + FLOOR_Y - lift)


def run_side(pen: ImageDraw.ImageDraw, cx: int, oy: int, i: int) -> None:
    hip = (cx, oy + HIP_Y - 4)
    shoulder = (cx + RUN_LEAN, oy + SHOULDER_Y)
    far_swing = STRIDE[i % COLUMNS][0]
    near_swing = STRIDE[(i + 4) % COLUMNS][0]

    draw_arm(pen, shoulder, (shoulder[0] + far_swing * 0.8, oy + 142 - abs(far_swing) * 0.25), FAR, 1)
    draw_leg(pen, hip, side_foot(cx, oy, i + 4), FAR, -1, 1)
    draw_body(pen, cx, oy, RUN_LEAN)
    draw_leg(pen, hip, side_foot(cx, oy, i), NEAR, -1, 1)
    hand = (shoulder[0] + near_swing * 0.8, oy + 142 - abs(near_swing) * 0.25)
    draw_blade(pen, hand, 150, BLADE_LENGTH)
    draw_arm(pen, shoulder, hand, NEAR, 1)


def elbow_out(side: int, hand_y: float, oy: int) -> int:
    """Le pli qui écarte le coude du corps : il s'inverse selon que le bras monte ou descend."""
    return -side if hand_y > oy + SHOULDER_Y else side


def frontal_lift(phase: int) -> float:
    """De face et de dos, le pied ne quitte pas l'aplomb du corps : il monte seulement."""
    forward, lift = STRIDE[phase % COLUMNS]
    return lift + max(0.0, -forward) * 0.2


def run_frontal(pen: ImageDraw.ImageDraw, cx: int, oy: int, i: int, facing: int) -> None:
    # `facing` : -1 de face (sa droite est à gauche de l'image), +1 de dos.
    hip = oy + HIP_Y - 4
    near_x, far_x = cx + 15 * facing, cx - 15 * facing
    near_foot = (near_x, oy + FLOOR_Y - frontal_lift(i))
    far_foot = (far_x, oy + FLOOR_Y - frontal_lift(i + 4))
    near_hand = (cx + 42 * facing, oy + 140 + STRIDE[i % COLUMNS][0] * 0.3)
    far_hand = (cx - 42 * facing, oy + 140 + STRIDE[(i + 4) % COLUMNS][0] * 0.3)

    if facing > 0:
        draw_body(pen, cx, oy, 0)
    # Jambe DROITE, sans genou de côté : plié vers l'extérieur, il donne le compas.
    draw_leg(pen, (near_x, hip), near_foot, NEAR, 0, 0)
    draw_leg(pen, (far_x, hip), far_foot, FAR, 0, 0)
    if facing < 0:
        draw_body(pen, cx, oy, 0)
    draw_arm(pen, (cx + 30 * facing, oy + SHOULDER_Y), near_hand, NEAR, elbow_out(facing, near_hand[1], oy))
    draw_arm(pen, (cx - 30 * facing, oy + SHOULDER_Y), far_hand, FAR, elbow_out(-facing, far_hand[1], oy))
    draw_blade(pen, near_hand, 100, BLADE_DEPTH_LENGTH)


def strike_side(pen: ImageDraw.ImageDraw, cx: int, oy: int, i: int) -> None:
    hip = (cx, oy + HIP_Y - 4)
    lean = STRIKE_LEAN[i]
    shoulder = (cx + lean, oy + SHOULDER_Y)
    hand_x, hand_y, angle = STRIKE["profil"][i]
    # L'autre bras contrebalance : il part en arrière quand la lame part en avant.
    draw_arm(pen, shoulder, (shoulder[0] - hand_x * 0.6 - 8, oy + 132), FAR, -1)
    # Les pieds restent plantés : le jeu déplace le mage, le geste n'avance pas.
    draw_leg(pen, hip, (cx + 24, oy + FLOOR_Y), FAR, -1, 1)
    draw_body(pen, cx, oy, lean)
    draw_leg(pen, hip, (cx - 24, oy + FLOOR_Y), NEAR, -1, 1)
    hand = (cx + hand_x, oy + hand_y)
    draw_blade(pen, hand, angle, BLADE_LENGTH)
    draw_arm(pen, shoulder, hand, NEAR, 1)


def strike_frontal(pen: ImageDraw.ImageDraw, cx: int, oy: int, i: int, facing: int) -> None:
    key = "face" if facing < 0 else "dos"
    hip = oy + HIP_Y - 4
    hand_x, hand_y, angle = STRIKE[key][i]
    hand = (cx + hand_x, oy + hand_y)
    near_x, far_x = cx + 20 * facing, cx - 20 * facing
    draw_leg(pen, (cx + 12 * facing, hip), (near_x, oy + FLOOR_Y), NEAR, facing, 0)
    draw_leg(pen, (cx - 12 * facing, hip), (far_x, oy + FLOOR_Y), FAR, -facing, 0)
    draw_body(pen, cx, oy, 0)
    draw_arm(pen, (cx - 30 * facing, oy + SHOULDER_Y), (cx - 42 * facing, oy + 140), FAR, facing)
    draw_blade(pen, hand, angle, BLADE_DEPTH_LENGTH)
    draw_arm(pen, (cx + 30 * facing, oy + SHOULDER_Y), hand, NEAR, elbow_out(facing, hand[1], oy))


def sheet(path: Path, frontal, side) -> None:
    guide = Image.new("RGB", (COLUMNS * CELL, ROWS * CELL), MAGENTA)
    pen = ImageDraw.Draw(guide)
    for i in range(COLUMNS):
        cx = i * CELL + CENTRE
        frontal(pen, cx, 0, i, -1)
        frontal(pen, cx, CELL, i, 1)
        side(pen, cx, 2 * CELL, i)
    guide.save(path)
    print(f"  {path}")


def side_guide(path: Path) -> None:
    """Sa vraie silhouette de profil, sur des jambes rouge et bleue qui s'échangent.

    Le guide complet a été ignoré : sa course dessine deux fois le même demi-cycle. Une seule
    rangée, son propre corps, et deux couleurs que rien ne permet de confondre.
    """
    with Image.open(SIDE_SOURCE) as source:
        row = np.array(source.convert("RGB").crop((0, 2 * CELL, COLUMNS * CELL, 3 * CELL)))
    background = (row[..., 0] > 190) & (row[..., 2] > 190) & (row[..., 1] < 90)
    filled = np.nonzero((~background).any(axis=1))[0]
    top, floor = int(filled[0]), int(filled[-1])
    hem = int(floor - (floor - top) * SIDE_LEGS_SHARE)
    # La lame reste : claire et sans couleur, contrairement aux bottes qu'on efface.
    blade = (row.min(axis=2) > 120) & (row.max(axis=2) - row.min(axis=2) < 40)
    erase = np.zeros(background.shape, dtype=bool)
    erase[hem:] = True
    row[erase & ~blade] = MAGENTA
    guide = Image.fromarray(row)
    pen = ImageDraw.Draw(guide)
    for i in range(COLUMNS):
        centre = i * CELL + CENTRE + SIDE_HIP_X
        hip = (centre, hem - 6)
        for phase, colour in ((i + 4, FAR), (i, NEAR)):
            forward, lift = STRIDE[phase % COLUMNS]
            foot = (centre + forward, floor - 8 - lift)
            pen.line([hip, knee(hip, foot, -1), foot], fill=colour, width=SIDE_LEG_WIDTH, joint="curve")
            pen.rounded_rectangle([foot[0] - 10, foot[1] - 9, foot[0] + 32, foot[1] + 8],
                                  radius=7, fill=colour)
    guide.save(path)
    print(f"  {path}")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    side_guide(OUT / "guide_profil.png")
    sheet(OUT / "guide_course.png", run_frontal, run_side)
    sheet(OUT / "guide_attaque.png", strike_frontal, strike_side)


if __name__ == "__main__":
    main()
