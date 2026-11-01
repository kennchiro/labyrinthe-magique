# Les icônes de sorts du Mage de la Peste — prompt

## Ses six sorts, et ce que chaque icône doit dire

| créneau | sort | ce qu'il fait |
|---|---|---|
| ATTAQUE | Dard venimeux | trait faible : chaque coup ajoute une dose de poison, jusqu'à 3 |
| SKILL 1 | Traînée toxique | pendant 6 s, il laisse du poison sur les cases où il passe |
| SKILL 2 | Contagion | le poison d'une cible passe aux ennemis proches |
| SKILL 3 | Transfusion | il reprend de la vie selon le nombre d'ennemis empoisonnés |
| FUITE | Brume | saut de quelques cases, avec un nuage toxique à son point de départ |
| EXTRA | Pandémie | tous les ennemis de la carte sont empoisonnés, et ceux qui en meurent éclatent |

---

## Le prompt

> Copier-coller tel quel. Aucune image à joindre.

```
Planche de six ICÔNES DE SORTS pour un jeu de rôle mobile, style cartoon coloré,
contours nets, lisibles en tout petit.

PERSONNAGE : le Mage de la Peste, un alchimiste du poison. Sa couleur est le VERT ACIDE
tirant sur le jaune (#b4f02a), avec des reflets jaune très clair (#f2ff9e), un vert foncé
pour les ombres et du bois noir. Couleurs VIVES et CLAIRES, contour net : les icônes seront
vues à 60 pixels sur un bouton rond et sombre.

FORMAT, à respecter exactement :
- image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 2 rangées, soit 6 cases de 512 x 512
- fond MAGENTA UNI #FF00FF partout, y compris entre les cases, sans dégradé
- NE PAS dessiner les lignes de la grille, ni cadre, ni numéro, ni texte
- une seule icône par case, CENTRÉE, occupant environ 70 % de sa case
- une forme à peu près aussi large que haute, qui tiendrait dans un cercle
- au moins 40 pixels de vide magenta tout autour de chaque icône
- rien ne dépasse sur la case voisine, ni en haut ni en bas

LES SIX ICÔNES, dans cet ordre de lecture :

1. DARD VENIMEUX — une grosse goutte de venin effilée, très pointue, qui file vers la
   droite, cœur jaune clair, suivie de trois petites gouttes de plus en plus petites.

2. TRAÎNÉE TOXIQUE — une botte de cuir sombre vue de profil, qui marche vers la droite, et
   derrière elle TROIS FLAQUES vertes bouillonnantes en file, de plus en plus petites.

3. CONTAGION — une grosse goutte de venin au centre, d'où partent TROIS filets sinueux vers
   trois petites gouttes écartées. On doit lire que le poison SE PROPAGE d'un point à
   plusieurs autres.

4. TRANSFUSION — un petit CŒUR lumineux vert clair au centre, vers lequel TROIS filets de
   gouttes convergent en courbe depuis les bords, leurs pointes tournées vers le cœur. Une
   icône plus calme : c'est la seule du lot qui soigne.

5. BRUME — une silhouette encapuchonnée qui se dissout de bas en haut en volutes de gaz vert
   à bord net, les volutes partant vers la gauche. Le long bec de son masque se voit de
   profil, tourné vers la droite.

6. PANDÉMIE — une grosse FIOLE RONDE en train d'exploser en éclats de verre, d'où jaillit une
   large onde de gaz vert en anneau, avec une petite tête de mort claire au centre du gaz.
   C'est l'icône la plus spectaculaire du lot.

À NE PAS FAIRE : pas d'arrière-plan, pas de décor, pas de sol dessiné, pas d'ombre portée,
pas de cadre, pas de texte, pas de flou, aucune case vide, AUCUN ROSE, AUCUN VIOLET et aucun
pourpre : ils se confondraient avec le fond magenta. Ce sont des SYMBOLES, pas des scènes.
```

---

## À vérifier sur la planche reçue

| Défaut | Pourquoi c'est gênant |
|---|---|
| Les icônes 3 et 4 se ressemblent | L'une part du centre, l'autre y revient : les pointes des filets doivent le montrer |
| Du gaz flou et sans contour | Il deviendrait une tache verte à 60 pixels |
| Du violet ou du rose dans le dessin | Le détourage les prendrait pour le fond et y ferait des trous |
| Une icône trop sombre | Elle deviendrait une tache sur le bouton sombre |
| Un dessin qui déborde en haut ou en bas de sa case | Un morceau se collerait à l'icône voisine |

L'ordre des cases n'a pas d'importance : je relève ce que chaque case montre avant de la
découper.

Déposer dans **`assets/peso&cover/sorts/mage_peste_skills.png`**.
