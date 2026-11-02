#!/usr/bin/env python3
"""La fiche du Diablotin, serviteur du premier sort de l'Invocateur.

    tools/.venv/bin/python tools/build_prompt_diablotin.py     # DEPUIS LA RACINE

Même gabarit que les ennemis, donc même fabrique. Seule la fin diffère : il n'est pas
dans le bestiaire, c'est `build_invocateur.py` qui le découpe.
"""

from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from build_prompts_enemies import fiche

OUT = Path("docs/prompts/sorts/diablotin.md")

BEAST = {
    "file": "diablotin", "id": "imp", "name": "Diablotin",
    "worst": "Le sort s'appelle Diablotins et invoque deux chevaliers en armure, sans"
             " vrai pas : leurs jambes bougent à peine, ils glissent, et ils ressemblent"
             " au Chevalier Noir qu'on combat. Il faut un petit serviteur qui trottine,"
             " qu'on ne prenne pour aucun ennemi.",
    "look": "UN DIABLOTIN SERVITEUR. Un petit démon trapu, nettement plus petit qu'un"
            " homme, à la peau violet sombre et au ventre lilas clair. Grosse tête, deux"
            " petites cornes dorées recourbées, grandes oreilles pointues, yeux jaune or,"
            " large sourire plein de crocs. Deux bras courts aux griffes dorées, deux"
            " jambes courtes bien visibles. Une longue queue fine terminée en pointe de"
            " flèche. Un pagne violet foncé et, au cou, une petite amulette d'or à orbe"
            " violette. SANS AILES, SANS ARMURE, SANS ARME.",
    "walk": "un TROT rapide et sautillant, la queue balancée en sens inverse des pas",
    "strike": [
        "il se ramasse sur ses jambes, les griffes reculent, la queue se dresse",
        "il se tasse encore, les yeux s'allument, la gueule s'ouvre",
        "il bondit vers l'avant, griffes droites levées, sans quitter sa case",
        "la griffe droite s'abat, une courte traînée violette part DEVANT lui",
        "la griffe est au bout du geste, la traînée est à son plus large",
        "la griffe gauche suit, la traînée s'efface",
        "il retombe sur ses deux pieds, bras ouverts",
        "il se redresse et rejoint la pose de marche",
    ],
}

END = """## Ce que je fais quand elles arrivent

Les déposer sous les noms `diablotin_marche.png` et `diablotin_attaque.png` dans
`assets/peso&cover/creatures/`, puis :

1. **découpe** : `tools/.venv/bin/python tools/build_invocateur.py`. Tant que les deux
   planches ne sont pas là, il garde le chevalier ;
2. **import** : `godot --headless --path . --import` ;
3. **contrôle** : `godot --path . --resolution 1200x390 --script
   res://tools/preview_summons.gd -- /tmp/summons.png`, puis une capture en jeu.

Sortie : `assets/allies/imp_{down,up,left,right}.png`. La créature garde son identifiant
`imp` : ni ses chiffres ni ses règles ne changent.

*Fiche produite par `tools/build_prompt_diablotin.py`.*
"""


def main() -> None:
    text = fiche(BEAST)
    text = text[:text.index("## Ce que je fais quand elles arrivent")] + END
    text = text.replace("""    aujourd'hui   4 pas · 1 pose de coup
    demain        4 orientations · 8 pas · 8 poses de coup
""", """    aujourd'hui   un chevalier · 4 images sans vrai pas
    demain        un diablotin · 8 pas · 8 poses de coup
""")
    OUT.write_text(text, encoding="utf-8")
    print("fiche écrite :", OUT)


if __name__ == "__main__":
    main()
