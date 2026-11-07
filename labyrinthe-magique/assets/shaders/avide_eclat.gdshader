shader_type canvas_item;
// L'Avide : recoloré depuis geolier_eclat, vert bile, os et noir d'encre.
render_mode blend_mix;

// L'ÉCLAT DE GIVRE : l'éclair blanc, les lobes de flamme froide, le front et les rayons, puis la
// fumée sombre criblée d'éclats, qui se réduit.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.949, 1.0, 0.69);
const vec3 EMBER = vec3(0.784, 0.91, 0.188);
const vec3 LAVA = vec3(0.88, 0.96, 0.45);
const vec3 DEEP = vec3(0.353, 0.478, 0.071);
const vec3 BLACK = vec3(0.067, 0.063, 0.078);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = EMBER;
	float a = 0.0;
	float lobes = 0.14 * sin(angle * 7.0 + seed * 9.0) + 0.08 * sin(angle * 13.0 - seed * 5.0);
	float grow = pow(smoothstep(0.0, 0.42, t), 0.6);
	float radius = grow * (0.68 + lobes);
	float smoke = smoothstep(0.42, 0.95, t);
	float fill = radius * (1.0 - smoke) - d;
	float hole = d - radius * smoothstep(0.3, 0.7, t);
	if (radius - d > 0.0 && hole > 0.0 && smoke < 1.0) {
		color = BLACK * (0.55 + 0.45 * smoke);
		a = 1.0;
	}
	if (fill > 0.0) {
		float heat = fill / max(radius, 0.01);
		color = heat > 0.55 ? PALE : (heat > 0.28 ? EMBER : (heat > 0.1 ? LAVA : DEEP));
		a = 1.0;
	}
	float front = 0.1 + smoothstep(0.03, 0.7, t) * 0.85;
	float width = 0.07 * (1.0 - smoothstep(0.1, 0.75, t));
	if (width - abs(d - front) > 0.0) {
		color = PALE;
		a = 1.0;
	}
	float ray = 1.0 - abs(fract(angle / 6.2832 * 12.0 + seed) - 0.5) * 2.0;
	float raylife = 1.0 - smoothstep(0.08, 0.42, t);
	if (ray > 1.0 - 0.16 * raylife && d < 0.98 * smoothstep(0.0, 0.2, t) && raylife > 0.0) {
		color = PALE;
		a = 1.0;
	}
	if (t < 0.1 && (1.0 - t / 0.1) * 0.6 - d > 0.0) {
		color = vec3(1.0);
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float dir = hash(f) * 6.283;
		vec2 at = vec2(cos(dir), sin(dir)) * (0.2 + smoothstep(0.1, 1.0, t) * (0.45 + hash(f + 5.0) * 0.45));
		at.y += t * t * 0.2;
		if (0.05 * (1.0 - t) - length(p - at) > 0.0) {
			color = mod(f, 2.0) < 0.5 ? PALE : EMBER;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
