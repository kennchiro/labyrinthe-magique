shader_type canvas_item;
render_mode blend_mix;

// L'HEURE DERNIÈRE, tout l'écran : le décor tombe dans une éclipse, un disque noir couronné de
// rouge se lève au-dessus du mage, puis UNE FAUX GÉANTE traverse d'un bord à l'autre et laisse une
// longue entaille de braise. L'éclipse se retire ensuite depuis cette entaille.
// ⚠️ Le quad couvre deux fois l'écran : `s` ramène l'écran vers ±1,2 de large et ±0,66 de haut.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 EMBER = vec3(1.0, 0.416, 0.169);
const vec3 RED = vec3(0.886, 0.22, 0.165);
const vec3 DEEP = vec3(0.478, 0.078, 0.078);
const vec3 BLACK = vec3(0.04, 0.035, 0.06);
const vec3 BONE = vec3(0.902, 0.875, 0.792);
const float SWEEP_FROM = 0.25;
const float SWEEP_TO = 0.62;

void fragment() {
	vec2 s = (UV - 0.5) * 4.4;
	float t = clamp((progress - SWEEP_FROM) / (SWEEP_TO - SWEEP_FROM), 0.0, 1.0);
	float blade_x = mix(-2.0, 2.0, t);
	// L'éclipse tombe, puis se retire à partir de l'entaille.
	float fall = smoothstep(0.0, 0.22, progress);
	float leave = clamp((progress - 0.68) / 0.32, 0.0, 1.0);
	float cleared = step(abs(s.y + s.x * 0.18), leave * leave * 1.3);
	vec3 color = mix(BLACK, DEEP, 0.28);
	float alpha = 0.74 * fall * (1.0 - cleared);
	// Le disque : un cercle noir à couronne rouge, dont les rayons palpitent.
	vec2 sky = s - vec2(0.0, -0.36);
	float d = length(sky);
	float a = atan(sky.y, sky.x);
	float flare = 0.03 * sin(a * 17.0 + seed * 5.0 + progress * 8.0) + 0.02 * sin(a * 41.0 - progress * 11.0);
	float crown = 0.22 + flare * 0.6 - d;
	float risen = smoothstep(0.08, 0.26, progress) * (1.0 - leave);
	if (crown > 0.0 && risen > 0.0) {
		color = mix(RED, EMBER, smoothstep(0.0, 0.08, crown));
		alpha = max(alpha, risen);
		if (d < 0.17) {
			color = mix(BLACK, EMBER, smoothstep(0.155, 0.17, d));
		}
	}
	// L'entaille : elle reste derrière la lame et s'efface lentement.
	float slit_y = s.y + s.x * 0.18;
	float behind = step(s.x, blade_x);
	float slit_life = (1.0 - smoothstep(0.62, 0.95, progress)) * step(0.0, t);
	float slit = (0.028 * slit_life) - abs(slit_y);
	if (slit > 0.0 && behind > 0.5) {
		color = mix(RED, BONE, smoothstep(0.012, 0.03, slit));
		alpha = 1.0;
	}
	// La faux : un croissant énorme, à contre-jour, le tranchant vers l'avant.
	if (t > 0.0 && t < 1.0) {
		vec2 b = vec2(s.x - blade_x, slit_y);
		float outer = 0.72 - length(b - vec2(-0.5, 0.0));
		float inner = length(b - vec2(-0.72, 0.0)) - 0.72;
		float blade = min(outer, inner);
		float haft = min(0.02 - abs(b.y - 0.62 - (b.x + 0.5) * 0.15), min(b.x + 1.5, -0.32 - b.x));
		if (haft > 0.0) {
			color = BONE;
			alpha = 1.0;
		}
		if (blade > -0.012) {
			color = blade > 0.0 ? BLACK : BONE;
			if (outer < 0.07 && blade > 0.0) {
				color = outer < 0.03 ? EMBER : RED;
			}
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
