shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT DE FLAMME, peint à l'écran au lieu d'être lu dans une planche.
//
// Inspiré de `peso&cover/sorts/mage_fire_skills.png`, case 1 : une flèche de feu à
// la pointe nette et blanche, dont le corps se déchire en langues vers l'arrière.
//
// Le blending est NORMAL : en additif, le feu se délave sur les stages clairs et
// perd ses aplats. Ce sont ces aplats qui lui donnent l'allure des dessins du jeu.
//
// Repère : UV.x va de la queue (0) à la pointe (1), UV.y traverse le trait.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec4 core_color : source_color = vec4(1.0, 0.98, 0.78, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.78, 0.12, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.32, 0.04, 1.0);
uniform vec4 edge_color : source_color = vec4(0.55, 0.04, 0.02, 1.0);
// Décale le dessin d'un tir à l'autre : deux traits ne sont jamais identiques.
uniform float seed = 0.0;
// Vitesse à laquelle les langues filent vers l'arrière.
uniform float flow = 2.4;

void fragment() {
	float along = UV.x;
	float across = abs(UV.y - 0.5) * 2.0;

	// LA SILHOUETTE : pointe de flèche à droite, corps qui s'effile vers la queue.
	float tip = smoothstep(1.0, 0.72, along);
	float tail = pow(along, 0.8);
	float body = tip * tail;

	// LES LANGUES. Le bruit est étiré le long du trait et défile vers l'arrière.
	// Elles ne mordent que la queue : la pointe doit rester nette pour dire où
	// part le coup.
	vec2 at = vec2(along * 0.22 + TIME * flow * 0.5 + seed, UV.y * 0.5 + seed * 0.37);
	float tongue = texture(noise, at).r;
	float shred = (1.0 - along) * 1.05;

	float heat = body - across + (tongue - 0.5) * shred;

	// DES APLATS ET NON UN DÉGRADÉ : c'est ce qui sépare un dessin d'une lueur.
	vec3 color = edge_color.rgb;
	color = mix(color, flame_color.rgb, smoothstep(0.04, 0.12, heat));
	color = mix(color, hot_color.rgb, smoothstep(0.18, 0.28, heat));
	color = mix(color, core_color.rgb, smoothstep(0.36, 0.48, heat));

	COLOR = vec4(color, smoothstep(0.0, 0.07, heat) * COLOR.a);
}
