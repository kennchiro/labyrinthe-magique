shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE L'EAU, et chaque goutte de la pluie du Geyser : une couronne qui se lève, des
// gouttes inégales qui montent puis retombent, et les ondes qui s'écartent au sol.
//
// Le sol est vu en biais : les ondes sont des ellipses, et une goutte en vol s'élève à
// l'écran. Onze ronds identiques autour d'un cercle se lisaient comme un cadran d'horloge.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

const int DROPS = 8;
const float SQUASH = 1.9;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 ground = p * vec2(1.0, SQUASH);
	float d = length(ground);
	float a = atan(ground.y, ground.x);
	float t = 1.0 - pow(1.0 - progress, 2.2);
	float n = texture(noise, vec2(a * 0.16 + seed, d * 0.3)).r - 0.5;

	// Deux ondes, la seconde en retard, cassées par endroits : jamais un anneau parfait.
	float first = (0.062 * (1.0 - progress) - abs(d - t * 0.78)) * smoothstep(-0.3, -0.05, n);
	float second = (0.044 * (1.0 - progress) - abs(d - max(0.0, t - 0.28) * 0.72)) * smoothstep(-0.15, 0.05, n);

	// La couronne : un disque festonné qui s'ouvre puis se creuse par le milieu.
	float crown_at = t * 0.56;
	float lobes = crown_at * (1.0 + 0.22 * sin(a * 7.0 + seed * 40.0));
	float crown = (lobes - d) * (1.0 - smoothstep(0.16, 0.5, progress));
	crown = min(crown, d - crown_at * smoothstep(0.06, 0.3, progress) * 0.72);

	float drops = -1.0;
	for (int i = 0; i < DROPS; i++) {
		float h = fract(sin((float(i) + 1.0) * 12.9898 + seed * 78.233) * 43758.5453);
		float angle = (float(i) + fract(h * 5.37) * 0.8) / float(DROPS) * TAU;
		float speed = 0.34 + fract(h * 3.71) * 0.46;
		float rise = 4.0 * progress * (1.0 - progress) * (0.14 + fract(h * 9.17) * 0.26);
		vec2 at = vec2(cos(angle), sin(angle) / SQUASH) * t * (0.3 + speed) - vec2(0.0, rise);
		drops = max(drops, (0.06 + h * 0.065) * (1.0 - progress * 0.6) - length(p - at));
	}

	float heat = max(max(first, second), max(crown, drops));
	vec3 color = mix(vec3(0.05, 0.36, 0.8), vec3(0.42, 0.82, 1.0), smoothstep(0.004, 0.018, heat));
	color = mix(color, vec3(1.0), smoothstep(0.018, 0.04, max(crown, drops)));
	COLOR = vec4(color, smoothstep(0.0, 0.006, heat) * (1.0 - smoothstep(0.84, 1.0, progress)) * COLOR.a);
}
