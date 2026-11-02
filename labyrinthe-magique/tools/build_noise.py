#!/usr/bin/env python3
"""LES BRUITS SPÉCIALISÉS : foudre, glace et Suprême, raccordables, 256 x 256.

    tools/.venv/bin/python tools/build_noise.py
    godot --headless --path . --import

Un canal par usage, parce qu'un éclair n'a rien d'un nuage de bruit lissé :

  R  un TRACÉ par rangée. Chaque rangée est un éclair complet, indépendant de ses
     voisines : lire une autre rangée redessine tout le trait d'un coup. Les cassures
     tombent à intervalles irréguliers, sur trois échelles.
  G  des VEINES ramifiées, 1 sur le trait et 0 loin de lui. Les branches sont moins
     hautes que leur tronc : un seuil dans le shader les rend donc plus fines.
  B  `fire_noise.png` agrandi. Ce qui n'est pas un éclair (la masse du nuage, le
     moment du flash) garde son dessin et sa fréquence d'avant.

La glace a ses propres canaux, tirés des mêmes plaques (un diagramme de Voronoï) :

  R  la teinte de chaque plaque, uniforme sur toute la plaque.
  G  les fissures : 1 sur la frontière entre deux plaques, 0 à quelques pixels.
  B  une pente dans une direction propre à chaque plaque : un seuil en fait un pan net
     qui accroche la lumière. Calculé ici : un Voronoï par pixel, sur six cases de large
     et dix secondes durant, coûterait bien plus cher qu'une lecture de texture.

Le Suprême mélange quatre matières dans les mêmes shaders, et chacune garde son canal :

  R  `fire_noise.png` agrandi : le feu et l'eau ne changent pas.
  G  la terre : `raw/noise/voronoi_12.png`, des plaques nettes et leurs lignes claires.
  B  l'air : `raw/noise/streak_4.png`, des filets ondulés dans le sens du courant.
"""
import math
import random

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

SIZE = 256
SEED = 20261101
OUT = "assets/shaders/thunder_noise.png"
ICE_OUT = "assets/shaders/ice_noise.png"
SUPREME_OUT = "assets/shaders/supreme_noise.png"
EARTH_SOURCE = "assets/raw/noise/voronoi_12.png"
AIR_SOURCE = "assets/raw/noise/streak_4.png"
ICE_PLATES = 34
ICE_CRACK_WIDTH = 5.0
SOURCE = "assets/shaders/fire_noise.png"
# (nombre de cassures, poids) : les grands coudes, puis ce qui les casse à nouveau.
WALK_OCTAVES = [((4, 7), 1.0), ((9, 15), 0.34), ((20, 32), 0.11)]
VEIN_TRUNKS = 8
VEIN_FORK_CHANCE = 0.2
VEIN_FORK_FADE = 0.72


def walk_octave(rng, count):
    """Une ligne brisée périodique, à cassures irrégulières."""
    knots = sorted(rng.random() * SIZE for _ in range(count))
    values = [rng.uniform(-1.0, 1.0) for _ in range(count)]
    # Le premier point répété une période plus loin, pour raccorder.
    return np.interp(
        np.arange(SIZE), [knots[-1] - SIZE] + knots + [knots[0] + SIZE],
        [values[-1]] + values + [values[0]])


def walks(rng):
    out = np.zeros((SIZE, SIZE))
    for row in range(SIZE):
        line = sum(walk_octave(rng, rng.randint(*span)) * weight
                   for span, weight in WALK_OCTAVES)
        # Chaque rangée occupe toute la plage : l'amplitude reste celle du shader.
        out[row] = (line - line.min()) / (line.max() - line.min())
    return out


def vein(rng, segments, x, y, angle, steps, level):
    """Une branche et ses fourches, en segments dans un repère qui déborde de la tuile."""
    for _ in range(steps):
        angle += rng.uniform(-0.8, 0.8)
        length = rng.uniform(5.0, 13.0)
        end_x = x + math.cos(angle) * length
        end_y = y + math.sin(angle) * length
        segments.append((level, (x, y, end_x, end_y)))
        x, y = end_x, end_y
        if level > 110 and rng.random() < VEIN_FORK_CHANCE:
            fork = angle + rng.choice((-1, 1)) * rng.uniform(0.5, 1.0)
            vein(rng, segments, x, y, fork, max(3, steps // 2), int(level * VEIN_FORK_FADE))


def veins(rng):
    segments = []
    for _ in range(VEIN_TRUNKS):
        vein(rng, segments, rng.random() * SIZE, rng.random() * SIZE,
             rng.random() * math.tau, rng.randint(9, 16), 255)
    # Tracé sur trois tuiles de côté, et seule celle du milieu est gardée : un trait qui
    # sort d'un bord rentre par l'autre, et le flou passe la couture sans la voir.
    canvas = Image.new("L", (SIZE * 3, SIZE * 3), 0)
    pen = ImageDraw.Draw(canvas)
    for level, (ax, ay, bx, by) in sorted(segments, key=lambda s: s[0]):
        for shift_x in (0, SIZE, SIZE * 2):
            for shift_y in (0, SIZE, SIZE * 2):
                pen.line((ax + shift_x, ay + shift_y, bx + shift_x, by + shift_y),
                         fill=level, width=2)
    soft = ImageChops.lighter(canvas.filter(ImageFilter.GaussianBlur(1.1)),
                              canvas.filter(ImageFilter.GaussianBlur(0.5)))
    return np.asarray(soft.crop((SIZE, SIZE, SIZE * 2, SIZE * 2)), float) / 255.0


def old_noise():
    red = Image.open(SOURCE).convert("RGB").getchannel("R")
    side = red.width
    # Agrandi sur trois tuiles lui aussi : l'interpolation doit voir à travers les bords.
    tiled = Image.new("L", (side * 3, side * 3))
    for x in range(3):
        for y in range(3):
            tiled.paste(red, (x * side, y * side))
    grown = tiled.resize((SIZE * 3, SIZE * 3), Image.BILINEAR)
    return np.asarray(grown.crop((SIZE, SIZE, SIZE * 2, SIZE * 2)), float) / 255.0


def ice(rng):
    points = np.array([(rng.random() * SIZE, rng.random() * SIZE) for _ in range(ICE_PLATES)])
    shades = np.array([rng.random() for _ in range(ICE_PLATES)])
    angles = np.array([rng.random() * math.tau for _ in range(ICE_PLATES)])
    ys, xs = np.mgrid[0:SIZE, 0:SIZE].astype(float)
    # La distance se mesure sur le tore : une plaque qui sort d'un bord rentre par l'autre.
    dx = (xs[..., None] - points[:, 0] + SIZE / 2) % SIZE - SIZE / 2
    dy = (ys[..., None] - points[:, 1] + SIZE / 2) % SIZE - SIZE / 2
    distance = np.hypot(dx, dy)
    order = np.argsort(distance, axis=-1)
    nearest = order[..., 0]
    first = np.take_along_axis(distance, order[..., :1], -1)[..., 0]
    second = np.take_along_axis(distance, order[..., 1:2], -1)[..., 0]
    crack = np.clip(1.0 - (second - first) / ICE_CRACK_WIDTH, 0.0, 1.0)
    row = np.arange(SIZE)[:, None]
    col = np.arange(SIZE)[None, :]
    slope = dx[row, col, nearest] * np.cos(angles[nearest]) + dy[row, col, nearest] * np.sin(angles[nearest])
    glint = np.clip(slope / (SIZE / math.sqrt(ICE_PLATES)) + 0.5, 0.0, 1.0)
    return np.stack((shades[nearest], crack, glint), axis=-1)


def supreme():
    earth = np.asarray(Image.open(EARTH_SOURCE).convert("L"), float) / 255.0
    air = np.asarray(Image.open(AIR_SOURCE).convert("L"), float) / 255.0
    return np.stack((old_noise(), earth, air), axis=-1)


def main():
    rng = random.Random(SEED)
    channels = np.stack((walks(rng), veins(rng), old_noise()), axis=-1)
    Image.fromarray((channels * 255.0 + 0.5).astype(np.uint8), "RGB").save(OUT)
    for name, index in (("tracés", 0), ("veines", 1), ("nuage", 2)):
        c = channels[..., index]
        print(f"{name}: moyenne {c.mean():.3f}, couverture >0,5 {float((c > 0.5).mean()):.1%}")
    print(f"veines, écart aux coutures : {np.abs(channels[0, :, 1] - channels[-1, :, 1]).mean():.3f} / "
          f"{np.abs(channels[:, 0, 1] - channels[:, -1, 1]).mean():.3f}")
    print(OUT)
    plates = ice(rng)
    Image.fromarray((plates * 255.0 + 0.5).astype(np.uint8), "RGB").save(ICE_OUT)
    print(f"glace : fissures >0,6 sur {float((plates[..., 1] > 0.6).mean()):.1%}, "
          f"pans >0,7 sur {float((plates[..., 2] > 0.7).mean()):.1%}")
    print(ICE_OUT)
    Image.fromarray((supreme() * 255.0 + 0.5).astype(np.uint8), "RGB").save(SUPREME_OUT)
    print(SUPREME_OUT)


if __name__ == "__main__":
    main()
