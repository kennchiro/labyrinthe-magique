shader_type canvas_item;
render_mode blend_mix;

// LE NUAGE DU JUGEMENT : une masse lourde, ventrue, au dessous plat, zébrée d'éclairs.
//
// ⚠️ Sa silhouette vient de lobes ronds et non du bruit : seuillé, le bruit dessinait une
// tache d'encre. Le canal B de `thunder_noise.png` dit quand il tonne, le G dessine les
// veines. Coordonnées en cases : le quad en fait 3 x 1,9.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

const int LOBES = 7;

void fragment() {
	vec2 q = (UV - 0.5) * vec2(3.0, 1.9);
	float body = -1.0;
	// La même masse, descendue : ce qu'elle ne couvre plus est le haut du nuage, éclairé.
	// Un reflet par lobe faisait une grappe de raisin.
	float lower = -1.0;
	float lowest = -1.0;
	for (int i = 0; i < LOBES; i++) {
		float k = float(i) / float(LOBES - 1);
		float h = fract(sin((float(i) + 1.0) * 12.9898 + seed * 78.233) * 43758.5453);
		// Les plus gros au milieu, et chacun respire à son rythme.
		float radius = 0.28 + 0.26 * sin(k * PI) + h * 0.08;
		vec2 at = vec2((k - 0.5) * 2.1, 0.12 - sin(k * PI) * 0.26 + (h - 0.5) * 0.14);
		at += vec2(sin(TIME * 0.5 + h * 9.0), cos(TIME * 0.7 + h * 5.0)) * 0.025;
		float lobe = radius - length(q - at);
		body = max(body, lobe);
		lower = max(lower, radius - length(q - at - vec2(0.02, 0.09)));
		lowest = max(lowest, radius - length(q - at - vec2(0.04, 0.22)));
	}
	// Le ventre plat : la base d'un nuage d'orage est une ligne.
	body = min(body, 0.42 - q.y);

	float flash_step = floor(TIME * 7.0);
	float flash = step(0.9, texture(noise, vec2(flash_step * 0.137, seed)).b);
	vec2 vein_uv = q * vec2(0.3, 0.32) + vec2(flash_step * 0.37, flash_step * 0.61 + seed);
	float vein = smoothstep(0.42, 0.62, texture(noise, vein_uv).g) * flash * smoothstep(0.03, 0.12, body);

	vec3 color = mix(vec3(0.05, 0.06, 0.15), vec3(0.11, 0.12, 0.26), smoothstep(0.012, 0.03, body));
	color = mix(color, vec3(0.23, 0.25, 0.44), 1.0 - smoothstep(-0.012, 0.012, lowest));
	color = mix(color, vec3(0.42, 0.45, 0.68), 1.0 - smoothstep(-0.012, 0.012, lower));
	color = mix(color, vec3(0.3, 0.44, 1.0) * (1.0 + flash * 0.4), flash * 0.34);
	color = mix(color, vec3(1.0, 1.0, 0.9), vein);
	COLOR = vec4(color, smoothstep(0.0, 0.012, body) * 0.96 * COLOR.a);
}
