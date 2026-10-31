shader_type canvas_item;
render_mode blend_mix;

// LA BOULE DE FEU, peinte à l'écran au lieu d'être lue dans une planche.
//
// Inspirée de `peso&cover/sorts/mage_fire_skills.png`, case 2 : un noyau de roche
// en fusion, un croissant brûlant devant, et une chevelure de flammes derrière.
//
// Repère : la boule vole vers la droite, le noyau est en `head`.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec4 core_color : source_color = vec4(1.0, 0.98, 0.78, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.78, 0.12, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.32, 0.04, 1.0);
uniform vec4 edge_color : source_color = vec4(0.55, 0.04, 0.02, 1.0);
uniform vec4 rock_color : source_color = vec4(0.5, 0.08, 0.03, 1.0);
uniform vec2 head = vec2(0.72, 0.5);
uniform float radius = 0.2;
uniform float seed = 0.0;
uniform float flow = 0.9;
// Largeur sur hauteur du quad : le noyau doit rester rond à l'écran.
uniform float aspect = 1.6;

void fragment() {
	vec2 p = (UV - head) * vec2(aspect, 1.0);
	float d = length(p);
	float reach = head.x * aspect;
	// 0 sur le noyau et devant lui, 1 tout au bout de la traînée.
	float behind = clamp(-p.x / reach, 0.0, 1.0);

	// LA CHEVELURE. Un bruit très étiré le long du vol fait des LANGUES et non des
	// taches, et il mord d'autant plus qu'on s'éloigne du noyau.
	vec2 streak = vec2(p.x * 0.16 + TIME * flow + seed, p.y * 0.72 + seed * 0.37);
	float tongue = texture(noise, streak).r - 0.5;
	float bend = texture(noise, streak * vec2(0.5, 0.35) + 0.31).r - 0.5;
	float y = p.y + bend * behind * 0.22;
	// La goutte : large contre le noyau, nulle au bout de la traînée.
	float wide = radius * 1.28 * (1.0 + behind * 0.5) * (1.0 - behind * behind * behind);
	float tail = 1.0 - abs(y) / max(wide, 0.001);
	tail += tongue * (0.35 + behind * 1.5) - behind * 0.28;
	// Devant, seul le disque compte : la traînée ne dépasse pas la boule.
	float heat = p.x < 0.0 ? tail : -1.0;
	heat = max(heat, 1.0 - d / (radius * 1.32));

	// Trois aplats aux bords fondus sur deux pixels : assez net pour se lire comme
	// un dessin, assez doux pour ne pas crénelé en mouvement.
	vec3 color = edge_color.rgb;
	color = mix(color, flame_color.rgb, smoothstep(0.1, 0.19, heat));
	color = mix(color, hot_color.rgb, smoothstep(0.36, 0.47, heat));
	color = mix(color, core_color.rgb, smoothstep(0.66, 0.78, heat) * (1.0 - behind));

	// LE NOYAU : une roche sombre parcourue de fissures, qui chauffe jusqu'au blanc
	// en son centre. Le croissant du front reste brûlant, côté vol.
	float inside = smoothstep(radius, radius * 0.92, d);
	vec2 turn = p * 0.85 + vec2(TIME * -0.03, seed * 0.61);
	float crack = abs(texture(noise, turn).r - 0.5) * 2.0;
	vec3 rock = mix(hot_color.rgb, rock_color.rgb, smoothstep(0.06, 0.16, crack));
	rock = mix(rock, core_color.rgb, smoothstep(radius * 0.46, radius * 0.1, d));
	rock = mix(rock, hot_color.rgb, smoothstep(0.55, 1.0, p.x / radius) * 0.85);
	color = mix(color, rock, inside);

	COLOR = vec4(color, smoothstep(0.0, 0.09, heat) * COLOR.a);
}
