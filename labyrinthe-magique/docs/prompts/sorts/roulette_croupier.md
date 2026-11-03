# La Roulette infernale du Croupier — prompt

Le jeu la fait apparaître en grand au-dessus de la carte, la fait tourner, et fait courir la bille sur son bord. Elle
doit donc être **vue exactement de dessus**, ronde et symétrique, pour tourner sans se déformer.

## Prompt

> Copier-coller tel quel, sans image jointe.

```
Une roulette de casino infernal, VUE EXACTEMENT DE DESSUS, pour un jeu de rôle mobile, style
cartoon coloré à contours nets, détails riches.

FORMAT exact : image 1024 x 1024 pixels. Fond magenta uni #FF00FF partout autour. La roue est
CENTRÉE, parfaitement RONDE, et occupe environ 92 % de la largeur. Aucun texte, aucun chiffre
en dehors des cases, aucun cadre.

LA ROUE : un anneau extérieur de bois noir laqué cerclé d'or, puis la couronne des cases :
36 cases qui alternent ROUGE BORDEAUX (#7a0f14) et NOIR (#15100f), plus UNE seule case VERTE
FONCÉE pour le zéro, séparées par de fines cloisons d'or. Dans chaque case, un chiffre ivoire
simple. Au centre, un moyeu d'or en forme de croix à quatre branches, chaque branche finie par
une petite corne recourbée, et un œil rouge au milieu. Entre les cases et le moyeu, un cône d'or
gravé d'arabesques et de petites flammes.

⚠️ RÈGLE BLOQUANTE — VUE EXACTEMENT DE DESSUS : la roue est un CERCLE parfait, jamais une ellipse,
sans perspective ni pied.

⚠️ RÈGLE BLOQUANTE — SYMÉTRIE : toutes les cases ont la même taille, régulièrement réparties.

⚠️ RÈGLE BLOQUANTE — PAS DE BILLE sur la roue : le jeu la dessine et la fait courir.

⚠️ RÈGLE BLOQUANTE — AUCUN ROSE, AUCUN VIOLET : le rouge est un bordeaux brun-rouge, le vert est
sombre. Aucun reflet du fond magenta, aucune ombre portée, aucune lueur autour.
```

Déposer dans **`assets/peso&cover/sorts/croupier_roulette.png`**.

## À vérifier sur l'image reçue

| Défaut | Conséquence en jeu |
|---|---|
| La roue est une ellipse | Elle se déformerait en tournant |
| Une bille est dessinée | Elle tournerait avec la roue au lieu de courir sur le bord |
| Plusieurs cases vertes | Le zéro ne se lirait plus comme le jackpot |
