# Orbe du Sorcier Suprême — la SPHÈRE

La seule orbe RONDE : les sept éléments tiennent dedans.

**Fichier attendu** : `assets/peso&cover/orb_supreme.png`
**Destination après découpe** : `assets/characters/supreme/orb.png` + `orb.json`

---

## Prompt à copier tel quel

```
Create a single 1536x384 sprite sheet: a magic PROJECTILE, 4 frames in ONE row,
each frame exactly 384x384 pixels, in a strict regular grid. No gaps, no
borders, no text, no numbers.

BACKGROUND: pure flat magenta #FF00FF everywhere, including between frames.
No shadows on the background, no ground, no scenery.

STYLE: 2D fantasy RPG game art, thick clean dark outlines, cel-shaded, bright
saturated colors with a white-hot core, strong rim light. Readable at 32 pixels.

DIRECTION RULE - the most important one: the projectile FLIES TO THE RIGHT.
Its nose/point faces the RIGHT edge of the cell, its tail faces the LEFT edge.
The game rotates the sprite along its flight path, so anything drawn facing
another way will fly sideways.

ANIMATION RULE: this is NOT a loop. The 4 frames are a PROGRESSION, from the
projectile being born (frame 1) to its full power (frame 4). It grows and gains
detail, tail and light with each frame. Frame 4 is the one the player sees
most - it must be the most impressive.

ALIGNMENT RULE: the projectile's NOSE stays at the same spot in all 4 frames
(right of center), and it grows BACKWARD to the left as its tail develops.
Nothing may touch the cell edges.

The subject: an elemental sphere. Frame 1: a single point of golden light. Frame 2: the point swells, one thin ring forming around it. Frame 3: a golden-white sphere with two crossing rings. Frame 4: the sphere orbited by four rings - red, blue, green and violet - radiant sparks all around.
```

---

## Ce que le jeu en fait

L'orbe est le PROJECTILE en vol : l'image qui voyage entre le mage et sa
cible pour toute compétence de forme `PROJECTILE`. Elle est découpée en bande
horizontale de quatre images de même largeur, et le jeu :

- l'ORIENTE le long de sa trajectoire (angle 0 = vers la droite — d'où la
  règle de direction du prompt) ;
- déroule les quatre images UNE fois en 0,22 s, puis tient la dernière jusqu'à
  l'impact (`"mode": "grow"` dans `orb.json`) ;
- la met à l'échelle sur 0,95 case, multipliée par le `projectile_scale` du
  sort ;
- garde ses couleurs telles quelles — la teinte de l'élément ne s'applique
  qu'à la bille générique de repli.
