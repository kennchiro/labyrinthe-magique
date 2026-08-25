# Impact de la Foudre — la FRAPPE au sol

Le dessin central de l'impact : ce qu'on voit à l'instant où le tir touche.

Celui découpé de la planche du mage a été jugé raté. Il est de toute façon
FIXE — le jeu ne peut que le faire grandir et pâlir — là où une frappe demande
à se dérouler : le trait tombe, le sol encaisse, la lumière se retire.

**Fichier attendu** : `assets/peso&cover/impact_thunder.png`
**Destination après découpe** : `assets/characters/thunder/impact_0..5.png`

---

## Prompt à copier tel quel

```
Create a single 1536x256 sprite sheet: a LIGHTNING IMPACT animation, 6 frames
in ONE row, each frame exactly 256x256 pixels, in a strict regular grid.
No gaps, no borders, no text, no numbers.

BACKGROUND: pure flat magenta #FF00FF everywhere, including between frames.
No ground, no scenery, no shadow on the background.

STYLE: 2D fantasy RPG game art, thick clean outlines, cel-shaded, bright
yellow-white lightning with violet-blue secondary arcs and a pure white core.
Readable at 56 pixels.

THE SUBJECT: the moment a lightning bolt strikes the ground, seen from a
HIGH ANGLE, slightly from above - the way a top-down game shows the floor.
The bolt comes straight down from the top of the cell into a burst of light
where it lands, with a ring of energy spreading on the ground around the
point of contact.

THE 6 FRAMES are a PROGRESSION, not a loop:
  frame 1: the bolt reaching down, thin, the ground barely lit
  frame 2: contact - a small white flash at the point of impact
  frame 3: the flash bursts open, the ground ring starts to spread, arcs
           whipping outward
  frame 4: the widest moment - a broad ring of energy on the ground, forked
           arcs radiating, the white core at its brightest
  frame 5: the bolt is gone, the ring keeps spreading and thinning, sparks
           falling
  frame 6: only a faint ring and a few dying sparks

ALIGNMENT RULE: the point of impact stays at the EXACT same spot in all 6
frames - the center of the cell. Everything grows outward from there. The
subject must never be rotated, offset or resized as a whole; only the effect
itself develops. Nothing may touch the cell edges.

VERTICAL RULE: this drawing has a top and a bottom - the bolt falls from the
top. The game will NOT rotate it. Draw it upright.
```

---

## Ce que le jeu en fera

L'impact remplacera le dessin fixe : les six images se dérouleront sur la durée
de l'effet, sans rotation, centrées sur la case touchée. Deux choses vérifiées
au découpage, comme pour les autres planches animées :

- une **boîte commune** aux six images, sinon la frappe saute d'une image à
  l'autre ;
- des **cases égales** dans la bande de sortie.

Le même prompt servira aux sept autres mages en changeant la matière et les
couleurs — c'est le premier d'une série si celui-ci convient.
