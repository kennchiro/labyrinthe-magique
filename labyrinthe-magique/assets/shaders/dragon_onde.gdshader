shader_type canvas_item;
// Le Dragon des Abysses : recoloré depuis braise_onde, rouge infernal, magma et fumée noire.
render_mode blend_mix;

// L'ONDE QUI TRAVERSE L'ÉCRAN : fine, nette, double, et suivie d'une frange de flamme découpée.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.416);
const vec3 EMBER = vec3(1.0, 0.353, 0.063);
const vec3 LAVA = vec3(0.82, 0.125, 0.047);
const vec3 DEEP = vec3(0.541, 0.086, 0.047);
const vec3 BLACK = vec3(0.11, 0.071, 0.063);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	float front = pow(t, 0.55) * 0.95;
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	vec3 color = PALE;
	float a = 0.0;
	if (0.006 * fade - abs(d - front) > 0.0) {
		a = 1.0;
	}
	float fringe = (0.008 + 0.008 * sin(angle * 40.0 + seed * 7.0) + 0.006 * sin(angle * 97.0)) * fade;
	if (d < front && d > front - fringe - 0.006 * fade) {
		color = EMBER;
		a = 1.0;
	}
	if (0.003 * fade - abs(d - front * 0.72) > 0.0) {
		color = LAVA;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
