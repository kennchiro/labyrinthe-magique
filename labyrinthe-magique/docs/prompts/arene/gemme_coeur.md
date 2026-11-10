# gemme_coeur — la GEMME-CŒUR et ses états

Elle remplacera le dessin en code de `src/arena/arena_heart.gd`. Le jeu garde pour lui ce qui
BOUGE (le flottement, le cercle à tenir, la pulsation) ; l'image ne porte que ce qui ne bouge
pas : la gemme, le socle, et leurs couleurs.

Résultat attendu : `arene_gemme.png` dans `assets/peso&cover/decor/`.

```
Planche d'objets pour un jeu 2D vu de DESSUS, style cartoon coloré, contour
marqué, même facture et même palette que l'image de référence jointe.

FORMAT, à respecter exactement :
- image de 1024 x 512 pixels
- grille RÉGULIÈRE de 4 colonnes x 2 rangées, soit 8 cases de 256 x 256
- fond MAGENTA PUR UNI (#FF00FF) dans TOUTES les cases, sans dégradé, sans ombre
  portée sur le magenta
- aucun texte, aucun chiffre, aucune bordure dessinée, aucun trait de grille

SUJET : une GEMME GÉANTE à facettes, en forme de losange allongé, qui flotte
au-dessus d'un SOCLE circulaire de pierre gravée de runes. Vue de dessus en
légère plongée (on voit le dessus du socle et la face avant de la gemme).

LA RÈGLE QUI COMPTE PLUS QUE TOUT : la même gemme, le même socle, à la MÊME
taille et au MÊME endroit dans les huit cases. Seule la couleur change. Le jeu
passe d'une case à l'autre sur place : un objet qui bouge ou change de taille
d'une case à l'autre sursauterait à l'écran.

Rangée 1 — la gemme ET son socle :
1. LIBRE : gemme blanche nacrée, reflets arc-en-ciel discrets, runes du socle grises
2. tenue par les BLEUS : gemme bleu saphir, runes du socle allumées en bleu
3. tenue par les ROUGES : gemme rouge rubis, runes du socle allumées en rouge
4. DISPUTÉE : gemme moitié bleue, moitié rouge, fendue par une ligne de lumière
   blanche, runes du socle blanches

Rangée 2 — la gemme SEULE, sans socle, à la même place que dans la rangée 1 :
5. blanche nacrée
6. bleu saphir
7. rouge rubis
8. moitié bleue, moitié rouge

RÈGLES :
- aucune lueur ni aucun halo qui touche le bord de la case : le jeu ajoute sa
  propre lueur, celle de l'image ferait un carré
- aucune ombre portée sur le magenta : le jeu pose la sienne
- aucun personnage, aucun sol autour du socle
```

## Si ça revient mal

| Défaut | Correction |
|---|---|
| La gemme n'est pas à la même place d'une case à l'autre | c'est le défaut bloquant : redemander en joignant la case 1 et en exigeant « exactement la même position » |
| Un halo carré autour de la gemme | rappeler « aucune lueur qui touche le bord » |
| Le bleu ou le rouge ne ressemblent pas aux équipes | ce sont `#5fb4ff` et `#ff6b6b` (`ArenaRules.TEAM_COLORS`) : les donner en hexadécimal |
