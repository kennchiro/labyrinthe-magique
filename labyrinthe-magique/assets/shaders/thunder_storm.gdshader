shader_type canvas_item;
render_mode blend_mix;

// L'ORAGE : le petit nuage qui suit le mage. Clair et chargé, là où celui du Jugement est
// lourd et noir : ses bouffées TOURNENT autour d'un cœur qui se remplit d'électricité, et
// il blanchit quand il frappe. Coordonnées en cases : le quad en fait 2,6 x 1,7.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
// 1 à l'instant de la décharge, puis retombe.
uniform float flash = 0.0;
// 1 dans sa dernière seconde : les bouffées s'écartent, le sort s'achève.
uniform float breaking = 0.0;

const int PUFFS = 6;

void fragment() {
	vec2 q = (UV - 0.5) * vec2(2.6, 1.7);
	float body = 0.34 - length(q * vec2(0.9, 1.25));
	// La même masse, descendue : ce qu'elle ne couvre plus est le haut, éclairé.
	float lower = 0.34 - length((q - vec2(0.0, 0.1)) * vec2(0.9, 1.25));
	for (int i = 0; i < PUFFS; i++) {
		float k = float(i);
		float angle = k / float(PUFFS) * TAU + TIME * 0.45;
		float spread = 0.52 + 0.28 * breaking;
		vec2 at = vec2(cos(angle), sin(angle) * 0.46) * spread;
		float radius = 0.27 + mod(k, 2.0) * 0.07 + sin(angle) * 0.04;
		body = max(body, radius * (1.0 - breaking * 0.4) - length(q - at));
		lower = max(lower, radius * (1.0 - breaking * 0.4) - length(q - at - vec2(0.02, 0.1)));
	}
	// Il se charge : la veine revient par à-coups, puis reste allumée quand il frappe.
	float step_t = floor(TIME * 9.0);
	float pulse = smoothstep(0.55, 0.9, sin(TIME * 3.0) * 0.5 + 0.5);
	vec2 vein_uv = q * 0.26 + vec2(step_t * 0.37, step_t * 0.61 + seed);
	float vein = smoothstep(0.46, 0.64, texture(noise, vein_uv).g);
	vein *= smoothstep(0.05, 0.14, body) * max(pulse, flash);

	vec3 color = mix(vec3(0.1, 0.13, 0.32), vec3(0.24, 0.3, 0.56), smoothstep(0.012, 0.03, body));
	color = mix(color, vec3(0.5, 0.58, 0.86), 1.0 - smoothstep(-0.012, 0.012, lower));
	color = mix(color, vec3(0.8, 0.88, 1.0), flash * 0.7);
	color = mix(color, vec3(1.0, 1.0, 0.86), vein);
	COLOR = vec4(color, smoothstep(0.0, 0.012, body) * COLOR.a);
}
