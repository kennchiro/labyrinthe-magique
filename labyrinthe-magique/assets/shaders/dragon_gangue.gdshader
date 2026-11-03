shader_type canvas_item;
// Le Dragon des Abysses : recoloré depuis geolier_gangue, rouge infernal, magma et fumée noire.
render_mode blend_mix;

// LA GANGUE DE GLACE : des cristaux poussent autour de l'ennemi figé, tiennent, puis éclatent en
// éclats qui tombent. Posée sur lui pendant tout le gel.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.416);
const vec3 EMBER = vec3(1.0, 0.353, 0.063);
const vec3 LAVA = vec3(1.0, 0.62, 0.2);
const vec3 DEEP = vec3(0.541, 0.086, 0.047);
const vec3 BLACK = vec3(0.11, 0.071, 0.063);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = LAVA;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.12, t);
	float burst = smoothstep(0.86, 1.0, t);
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float x = (f - 4.0) * 0.17 + (hash(f) - 0.5) * 0.08;
		float tall = (0.45 + hash(f + 2.0) * 0.45) * grow * (1.0 - burst);
		float base = 0.75;
		float y = (base - p.y) / max(tall, 0.001);
		float width = 0.1 * (1.0 - y);
		float crystal = width - abs(p.x - x - (y * (hash(f + 5.0) - 0.5) * 0.2));
		if (crystal > 0.0 && y > 0.0 && y < 1.0) {
			color = crystal > width * 0.55 ? PALE : (p.x < x ? LAVA : DEEP);
			a = 0.92;
		}
	}
	if (burst > 0.0) {
		for (int i = 0; i < 10; i++) {
			float f = float(i);
			float dir = hash(f + 9.0) * 6.283;
			vec2 at = vec2(cos(dir), sin(dir)) * burst * 0.8 + vec2(0.0, 0.2 + burst * burst * 0.4);
			if (0.06 * (1.0 - burst) - length(p - at) > 0.0) {
				color = PALE;
				a = 1.0;
			}
		}
	}
	COLOR = vec4(color, a);
}
