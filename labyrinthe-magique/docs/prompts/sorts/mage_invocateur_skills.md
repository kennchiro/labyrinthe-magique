# Icônes de compétences du Mage Invocateur — prompt pour la planche d'icônes

## Ce qui existe déjà

Le Mage Invocateur (`invocateur`) possède six compétences définies dans `CharacterCatalog.invocateur()` :
1. `invoc_bolt` (Trait occulte — Attaque de base)
2. `invoc_imps` (Diablotins — Sort 1)
3. `invoc_gargoyle` (Chevalier d'ombre — Sort 2)
4. `invoc_circle` (Cercle d'invocation — Sort 3)
5. `invoc_step` (Pas du néant — Fuite)
6. `invoc_dragon` (Dragon ancien — Ultime)

Les interfaces mobile (`CombatPad`) et desktop (`ActionBar`) chargent automatiquement les icônes depuis `res://assets/icons/invocateur/<ability_id>.png` dès qu'elles sont générées et découpées.

---

## Le prompt

> Copier-coller tel quel. Le fond MAGENTA PUR (#FF00FF) est indispensable pour le détourage par teinte effectué par `tools/build_skill_icons.py`.

```
Skill icons sheet for a 2D top-down RPG game, vibrant fantasy cartoon style.
Very bright, vivid, luminous, and clear colors! Ensure the icons are highly visible and stand out brilliantly.

SUBJECT: 6 spell icons for a dark magic Summoner Mage (Invocateur), but with very BRIGHT glowing colors.
Main colors: brilliant neon violet, bright magical magenta, glowing cyan accents, radiant white core lighting.
AVOID dark or muddy colors, keep everything extremely well-lit and popping!

FORMAT:
- Aspect ratio 3:2 (1536 x 1024 pixels)
- REGULAR grid of 3 columns x 2 rows, 6 cells of 512 x 512
- PURE FLAT MAGENTA background (#FF00FF) in EVERY cell, no gradient, no drop shadow, no border/frame
- No text, no numbers, no drawn borders

THE 6 ICONS (top row 1-3, bottom row 4-6):
1. (invoc_bolt) Occult bolt: a bright glowing needle/arrow of vivid purple energy, radiating intense magical light and a brilliant neon trail.
2. (invoc_imps) Imps: two small glowing imp silhouettes wrapped in bright, luminous magical violet flames.
3. (invoc_gargoyle) Shadow Knight: a glowing, majestic helmet/head of a spectral shadow knight made of brilliant violet energy and bright cyan glowing eyes.
4. (invoc_circle) Summoning circle: an incredibly bright, glowing neon portal/vortex shining intensely with vibrant purple and white magical runes.
5. (invoc_step) Void step: a dazzling dash trail of magical violet and white energy, looking like a bright spectral teleportation.
6. (invoc_dragon) Ancient dragon: a radiant, glowing magical dragon head made of pure brilliant neon-violet light and white hot magical flames.

IMPORTANT RULES:
- Each icon is centered and occupies about 70-80% of its cell.
- The icons MUST be extremely bright and luminous so they are easily visible on a dark UI.
- Pure flat magenta background (#FF00FF) with no ground or character body.
```
