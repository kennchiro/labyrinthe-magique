# cadre_carte — le cadre des huit cartes

> ⚠️ **Fichier GÉNÉRÉ** par `tools/build_prompts_menu.py`. Ne pas l'éditer à
> la main : une consigne se corrige dans la table de l'outil, puis on relance —
> sinon elle ne profite qu'à un mage sur huit.

**Joins `../ref/ref_carte.png` à ChatGPT** et dis « le CADRE seul de cette
carte, sans le personnage ni le texte ».

⚠️ **Une seule image pour les huit mages.** C'est la décision qui tient tout
l'écran : demander « le mage du Feu dans son cadre » huit fois donnerait huit
cadres différents — épaisseurs, gemmes, coins et vignes ne tomberaient jamais
deux fois pareil — et une rangée de huit cartes mal assorties est PIRE qu'une
rangée sans cadre. Le jeu teinte ce cadre unique à la couleur de chaque élément.

Résultat attendu : `cadre_carte.png` dans
`assets/peso&cover/interface/portraits/`.

```
Élément d'interface pour un jeu de rôle mobile, style cartoon coloré à contours
nets, même facture que l'image de référence jointe.

FORMAT : une seule image de 1024 x 1365 pixels (rapport 3:4, debout).

SUJET : un CADRE DE CARTE VIDE, vu de face. Bordure de pierre grise sculptée
rehaussée d'or, angles renforcés, quelques vignes qui courent sur les côtés. Au
MILIEU DU BORD SUPÉRIEUR, un sertissage rond vide destiné à recevoir une gemme —
dessine le sertissage, PAS la gemme. Le cadre a une légère épaisseur, éclairée
par le haut.

L'INTÉRIEUR DU CADRE EST ENTIÈREMENT MAGENTA PUR UNI (#FF00FF), sans dégradé et
sans ombre : c'est la fenêtre où le jeu posera le portrait, et le magenta se
détoure au pixel près. Le magenta remplit aussi les quatre coins autour du cadre.

RÈGLES ABSOLUES :
- le cadre est GRIS et OR, sans aucune couleur d'élément : le jeu le teinte
  lui-même en rouge, bleu, vert, violet selon le mage. Un cadre déjà coloré
  donnerait huit teintes fausses
- la bordure fait environ un vingtième de la largeur de l'image, RÉGULIÈRE sur
  les quatre côtés
- aucun texte, aucune plaque de nom, aucun chiffre
- aucun personnage, aucun décor, aucun objet dans la fenêtre
```

---

## Si ça revient mal

| Défaut | Correction |
|---|---|
| L'intérieur n'est pas magenta | c'est bloquant : sans lui, pas de fenêtre. Relancer |
| Le cadre est doré-rouge ou coloré | rappeler « GRIS et OR, le jeu le teinte » |
| Une gemme est dessinée dans le sertissage | rappeler « le sertissage, PAS la gemme » |
| La bordure est plus épaisse en bas | rappeler « RÉGULIÈRE sur les quatre côtés » |
