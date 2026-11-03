# Les icônes de sorts du Chevalier Écarlate — prompt

| créneau | sort | symbole |
|---|---|---|
| ATTAQUE | Entaille | croissant de coupe blanc, bordé de rouge |
| SKILL 1 | Pas de Lame | lame horizontale et trait de vitesse |
| SKILL 2 | Garde | sabre vertical devant un cercle fin |
| SKILL 3 | Rengaine | sabre à moitié dans son fourreau, éclat à la jointure |
| FUITE | Volte-face | flèche courbe et pétales blancs |
| EXTRA | Dernière Rengaine | cinq coupes croisées autour d'un sabre rengainé |

⚠️ Le rouge ne porte aucun bleu : le fond est magenta, et `build_skill_icons.py` rend un pixel d'autant plus
transparent qu'il a de rouge et de bleu en plus de son vert.

## Prompt

> Copier-coller tel quel, sans image jointe.

```
Planche de six icônes de sorts pour un jeu de rôle mobile, style fantasy manga,
contours nets et formes lisibles en petit. Ces symboles appartiennent à un bretteur en
armure de laque rouge, dont les coupes éclatent toutes ensemble quand il rengaine.

FORMAT exact : image 1536 x 1024 pixels, grille régulière de 3 colonnes x 2
rangées, six cases de 512 x 512. Fond magenta uni #FF00FF partout. Aucune ligne
de grille, cadre, numéro, lettre ou texte. Une icône centrée par case, environ
70 % de la case, avec une marge magenta généreuse et sans débordement.

Palette STRICTE : blanc chaud, acier clair, noir, et un seul accent ROUGE FRANC (#d81a1a), sans
aucun bleu. AUCUN rose, AUCUN bordeaux, AUCUN violet, AUCUN magenta dans les dessins. Les icônes
sont des symboles, sans personnage ni visage.

Dans l'ordre de lecture :
1. ENTAILLE — un fin croissant de coupe blanc, très net, en diagonale, bordé d'un filet rouge.
2. PAS DE LAME — une longue lame d'acier horizontale, dirigée vers la droite, suivie de
   trois traits de vitesse blancs et d'un trait rouge.
3. GARDE — un sabre vertical à poignée blanche, devant un fin cercle blanc, avec un petit
   éclat rouge à quatre branches sur sa lame.
4. RENGAINE — un sabre à moitié entré dans un fourreau noir, en diagonale, avec un éclat
   blanc et rouge à la jointure entre la lame et le fourreau.
5. VOLTE-FACE — une flèche courbe blanche qui revient en arrière, entourée de petits
   pétales blancs à bord rouge.
6. DERNIÈRE RENGAINE — un sabre rengainé vertical au centre, noir et rouge, traversé de cinq
   grandes coupes blanches qui se croisent en étoile, bordées de rouge. C'est l'icône la plus
   spectaculaire.

Pas de décor, arrière-plan illustré, ombre, flou, cadre, texte, personnage, corne,
aile ou crâne. Pas de sang. Le magenta du fond ne doit pas se refléter dans les icônes.
```

Déposer dans **`assets/peso&cover/sorts/mage_ecarlate_skills.png`**.
