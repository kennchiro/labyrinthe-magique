shader_type canvas_item;

// L'EAU QUI COURT DANS LA COLONNE.
//
// Les six images d'une éruption disent la FORME — elle monte, culmine,
// retombe — mais pas la MATIÈRE : entre deux images, l'eau reste figée. Ce
// shader la remet en mouvement sans rien redessiner.
//
// ⚠️ Il DÉFORME, il ne fait pas défiler. Un décalage d'UV qui boucle sur une
// image non répétable ramène son bord opposé en plein milieu du dessin — c'est
// ce qui avait transformé la tornade de l'Air en bouillie bleue. Ici les
// décalages valent quelques millièmes et sont bornés : la silhouette ne bouge
// pas, seule sa surface ondule.
//
// Trois mouvements, et chacun a sa raison :
//   · l'ondulation horizontale est plus forte EN HAUT — la crête fouette,
//     la base est tenue par le sol ;
//   · l'ondulation verticale donne le bouillonnement ;
//   · un reflet clair REMONTE la colonne, ce qui dit le sens de l'eau.

uniform float phase = 0.0;
uniform float force = 1.0;

void fragment() {
	vec2 uv = UV;
	// UV.y vaut 0 en haut de l'image : la crête est donc en (1.0 - UV.y).
	float crest = 1.0 - UV.y;
	uv.x += sin(phase * 7.0 + UV.y * 15.0) * 0.014 * force * crest;
	uv.y += sin(phase * 9.0 + UV.x * 11.0) * 0.008 * force;
	vec4 col = texture(TEXTURE, clamp(uv, vec2(0.002), vec2(0.998)));

	// Le reflet qui remonte. `fract` ne boucle QUE sur la position du reflet,
	// jamais sur les coordonnées de la texture — rien ne se replie.
	float travel = fract(UV.y + phase * 0.8);
	float sheen = smoothstep(0.16, 0.0, abs(travel - 0.5));
	col.rgb += vec3(0.22, 0.48, 0.72) * sheen * col.a * 0.55 * force;
	COLOR = col * COLOR;
}
