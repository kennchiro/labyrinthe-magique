# Le Chronomancien — toutes les images à générer

> Élément **Temps** · teinte du jeu `#2fd6b8` · turquoise et cuivre, sablier dans le dos.

Cinq images, **dans cet ordre** : la première sert de modèle aux autres.

| # | image | prompt | à déposer dans `assets/peso&cover/` | images à joindre |
|---|---|---|---|---|
| 1 | le modèle du personnage | ci-dessous | `refonte/chrono.png` | `refonte/foudre.png` |
| 2 | la marche | [mages_animes/chrono](../mages_animes/chrono.md), prompt 1 | `mages/chrono_marche.png` | `refonte/chrono.png` et `guide_marche.png` |
| 3 | l'attaque | [mages_animes/chrono](../mages_animes/chrono.md), prompt 2 | `mages/chrono_attaque.png` | `refonte/chrono.png` |
| 4 | les six icônes de sorts | [sorts/icones_chrono](../sorts/icones_chrono.md) | `sorts/mage_chrono_skills.png` | aucune |
| 5 | le portrait du menu | [menu/portrait_chrono](../menu/portrait_chrono.md) | `interface/portraits/portrait_chrono.png` | `ref_carte.png` et `refonte/chrono.png` |

Les images 1 à 3 se vérifient avant de passer à la suivante : un défaut du modèle se
retrouve sur les deux planches.

**Aucune image à demander pour les effets de ses sorts.** Son projectile, ses zones et
ses éclats seront peints au shader, comme ceux des autres mages.

---

## Image 1 — le modèle du personnage

Joindre `assets/peso&cover/refonte/foudre.png`, seulement pour le style.

```
Fiche de modèle d'un personnage pour un jeu 2D vu de DESSUS EN LÉGÈRE PLONGÉE, style
cartoon coloré à contours nets, effets lumineux, même facture que les sprites d'un jeu
de rôle mobile. L'image jointe sert UNIQUEMENT de référence de style et de proportions :
ne copie ni son personnage, ni ses couleurs, ni sa mise en page.

FORMAT, à respecter exactement :
- UNE image de 1536 x 1024 pixels
- grille RÉGULIÈRE de 3 colonnes x 1 rangée, soit 3 cases de 512 x 1024
- fond MAGENTA PUR UNI (#FF00FF) partout : un aplat, sans dégradé ni texture
- dans chaque case, le personnage est CENTRÉ, ENTIER, et occupe environ 60 % de la hauteur
- rien ne dépasse sur la case voisine
- aucun texte, aucun chiffre, aucun trait de grille, aucun sol, aucun décor

LES TROIS CASES, de gauche à droite :
1. vu DE FACE, immobile
2. vu DE DOS, immobile : le sablier se voit en entier
3. vu DE PROFIL, TOURNÉ VERS LA DROITE, immobile

LE PERSONNAGE — le Chronomancien. Longue robe turquoise sombre à liserés de cuivre, haut
col de cuivre, cheveux argentés courts coiffés en arrière, visage découvert. Un GRAND
SABLIER de cuivre au sable turquoise est fixé DANS SON DOS et dépasse au-dessus de ses
épaules. Il tient de la main droite un BÂTON en forme de GRANDE AIGUILLE D'HORLOGE en
cuivre, surmonté d'un petit cadran turquoise. Des bottes de cuir cuivré dépassent de la
robe. Corps COMPACT, tête un peu large, silhouette lisible en très petit. L'aura reste
COLLÉE au corps : pas de halo large, pas de nuage de particules autour.

⚠️ RÈGLE BLOQUANTE — LES COULEURS. Le turquoise reste VERT-BLEU et le cuivre reste ORANGÉ,
jamais rose : ils ne doivent pas se confondre avec le fond magenta.

⚠️ RÈGLE BLOQUANTE — MÊME PERSONNAGE dans les trois cases : même taille, mêmes couleurs,
même sablier, même bâton, toujours dans la main droite.

⚠️ RÈGLE BLOQUANTE — AUCUNE OMBRE PORTÉE, AUCUN CADRE.
```

### À vérifier avant de continuer

| Défaut | Pourquoi c'est gênant |
|---|---|
| Le sablier est petit ou change de forme | Il fait toute sa silhouette : on le confondrait avec les autres mages |
| La robe tire vers le bleu pur | Il ressemblerait au Mage de l'Eau |
| Le cuivre tire vers le doré | Il ressemblerait au Sorcier Suprême ou au Mage de la Foudre |
| Le bâton ressemble à une lance | L'idée d'horloge se perd : garder l'aiguille et son petit cadran |

---

## Quand les images sont là

Il suffit de les déposer et de me le dire : je les découpe, je contrôle chaque planche et
je programme le mage.
