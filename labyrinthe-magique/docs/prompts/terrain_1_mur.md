# terrain_1_mur — les MURS du stage 1 (La Forêt)

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts.py`. Ne pas l'éditer à la
> main : corriger une consigne se fait dans la table de l'outil, puis on relance.
> Sinon la correction ne profite qu'à un stage sur dix.

Si le modèle rend mieux en anglais, demande-lui de **traduire ce prompt** avant
de générer : ça évite de maintenir soixante blocs en deux langues.

**Joins `ref/ref_1_mur.png` à ChatGPT** — c'est le panneau de labyrinthe de
`assets/stages/stage_1.png` — et dis : « refais-moi ce jeu de pièces au
complet, même style, même palette ».

Ce n'est **pas une matière**, c'est un **jeu de 16 pièces** — un autotile. La
planche du stage en contient déjà l'essentiel : droits, coins, T, croix,
culs-de-sac. C'est ce qui donne au mur une SILHOUETTE, et c'est de loin ce qui
manque le plus au jeu aujourd'hui (le moteur pose un carré plein par case, sans
bord ni coin).

Résultat attendu : `terrain_1_mur.png` dans `assets/peso&cover/terrain/`.

```
Planche de tuiles pour un jeu 2D vu de DESSUS, style cartoon coloré, contour
marqué, même facture et même palette que l'image de référence jointe.

SUJET : une haie de buis taillée, feuillage vert vif et lumineux, semée de petites fleurs blanches, jaunes et rouges, vu de dessus. Le mur a une ÉPAISSEUR : on voit une fine
tranche plus sombre le long de son bord BAS, et une ombre douce portée sur le sol
sous ce bord.

FORMAT, à respecter exactement :
- image de 1024 x 1024 pixels
- grille RÉGULIÈRE de 4 colonnes x 4 rangées, soit 16 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
- aucun texte, aucun chiffre, aucune bordure dessinée, aucun trait de grille

LA RÈGLE QUI COMPTE PLUS QUE TOUT — LE RACCORD :
chaque pièce est un tronçon de mur de MÊME LARGEUR, toujours CENTRÉ dans sa case.
Quand un tronçon rejoint un bord de case, il doit TOUCHER ce bord et le remplir
sur toute sa largeur, sans arrondi et sans magenta résiduel : deux cases posées
côte à côte dans le jeu doivent former un mur continu, sans décrochement ni
bosse. Là où un tronçon NE rejoint PAS un bord, il se termine par un bout
ARRONDI, et le magenta reste visible jusqu'au bord.

LES 16 CASES, de gauche à droite puis de haut en bas. « ouvert vers X » = le
tronçon touche ce bord de la case.

Rangée 1
1. bloc ISOLÉ : une masse ronde au centre, qui ne touche AUCUN bord
2. cul-de-sac ouvert vers le HAUT (arrondi en bas)
3. cul-de-sac ouvert vers la DROITE (arrondi à gauche)
4. cul-de-sac ouvert vers le BAS (arrondi en haut)

Rangée 2
5. cul-de-sac ouvert vers la GAUCHE (arrondi à droite)
6. tronçon DROIT vertical : ouvert vers le haut ET vers le bas
7. tronçon DROIT horizontal : ouvert vers la gauche ET vers la droite
8. COIN ouvert vers le HAUT et vers la DROITE

Rangée 3
9.  COIN ouvert vers la DROITE et vers le BAS
10. COIN ouvert vers le BAS et vers la GAUCHE
11. COIN ouvert vers la GAUCHE et vers le HAUT
12. T ouvert vers le HAUT, la DROITE et le BAS (fermé à gauche)

Rangée 4
13. T ouvert vers la DROITE, le BAS et la GAUCHE (fermé en haut)
14. T ouvert vers le BAS, la GAUCHE et le HAUT (fermé à droite)
15. T ouvert vers la GAUCHE, le HAUT et la DROITE (fermé en bas)
16. CROIX : ouvert vers les QUATRE bords

COULEURS : vert vif lumineux, presque jaune-vert au soleil, avec des creux d'ombre bleutés entre les feuilles. Le mur doit se DÉTACHER franchement du sol de
la référence : c'est lui qu'on suit des yeux quand on cherche son chemin. Donne-
lui une LUMINOSITÉ nettement différente de celle du sol — plus claire ou plus
sombre, peu importe, mais jamais la même valeur.

AUTRES RÈGLES :
- exactement la MÊME largeur de tronçon, la MÊME matière et le MÊME niveau de
  détail dans les 16 cases. Une pièce plus épaisse que sa voisine se verrait à
  chaque jonction du labyrinthe
- la lumière vient toujours du HAUT, jamais de côté : le dessus est clair, la
  tranche du bas est plus sombre. Ne fais pas tourner cet éclairage d'une pièce
  à l'autre
- les détails (fleurs, cristaux, fissures, gemmes) sont ÉPARS et jamais aux mêmes
  endroits d'une case à l'autre
- rien ne dépasse sur la case voisine
- aucun personnage, aucun sol, aucun décor, aucun objet posé
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| Les tronçons n'ont pas tous la même largeur | c'est **le** défaut bloquant : relancer en insistant sur « MÊME largeur, toujours CENTRÉ » |
| Du magenta au bord d'une case ouverte | rappeler « toucher le bord et le remplir sur toute sa largeur » |
| L'éclairage tourne d'une pièce à l'autre | rappeler « la lumière vient toujours du HAUT » |
| Des pièces manquent ou sont dans le désordre | redemander la case fautive seule, en 256 x 256 sur magenta |
| Frange colorée autour du magenta | rien à faire côté prompt, je dégorge au découpage |

**Si le modèle ne tient pas les 16 d'un coup** : demande-lui les deux premières
rangées (8 cases, 1024 x 512), puis les deux dernières dans la MÊME conversation
en disant « même style, même largeur de mur que la planche précédente ».

⚠️ Ce jeu de pièces demande une modification du moteur (`MazeRenderer` choisit
aujourd'hui une seule tuile pleine). C'est prévu, c'est de mon côté. Voir
[../PROMPT_TERRAIN.md](../PROMPT_TERRAIN.md).
