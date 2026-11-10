shader_type canvas_item;
render_mode blend_mix;

// LE FIL QUI FILE : un fil d'argent à cœur magenta file d'un bout à l'autre et se tend, puis se détend. Quad étiré,
// x le long du trait. Avec `eye` à 1, c'est LA CONTAGION : un petit œil émeraude glisse le long du fil, d'un pantin
// mort à son voisin.

#include "res://assets/shaders/reine.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float eye = 0.0;

void fragment() {
	float t = progress;
	float x = UV.x;
	float y = (UV.y - 0.5) * 2.0;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float head = clamp(t * 2.4, 0.0, 1.0);
	float tail = clamp(t * 2.4 - 1.2, 0.0, 1.0);
	float slack = sin(x * 3.14159) * 0.35 * (1.0 - smoothstep(0.0, 0.4, t)) + sin(x * 30.0 - t * 20.0) * 0.05;
	float w = 0.13;
	float v = w - abs(y - slack);
	if (x >= tail && x <= head && v > -0.08) {
		color = v <= 0.0 ? R_BLACK : (v > w * 0.55 ? R_MAGENTA : R_SILVER);
		a = 1.0;
	}
	// La pointe : une aiguille d'argent.
	vec2 n = vec2((x - head) * 9.0, y - slack);
	float needle = 0.25 - abs(n.y) * 2.0 - abs(n.x) * 0.6;
	if (head < 1.0 && n.x < 0.4 && n.x > -0.6 && needle > -0.08) {
		color = needle > 0.0 ? R_PALE : R_BLACK;
		a = 1.0;
	}
	if (eye > 0.5) {
		vec3 e = color;
		vec2 q = vec2((x - head) * 6.0, y - slack);
		if (r_paint_eye(q, vec2(0.75, 0.42), 1.0, e)) {
			color = e;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
