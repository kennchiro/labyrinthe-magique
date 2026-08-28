# fond_selection — le fond de la page « Choisis ton mage »

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.

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
