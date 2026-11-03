shader_type canvas_item;
render_mode blend_mix;

// LE CLAQUEMENT : deux lignes horizontales se referment l'une sur l'autre autour de lui comme une
// lame qui entre au fourreau, et l'étincelle jaillit quand elles se touchent.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.965, 0.933);
const vec3 STEEL = vec3(0.851, 0.871, 0.89);
const vec3 RED = vec3(0.722, 0.078, 0.078);
const vec3 DEEP = vec3(0.369, 0.039, 0.039);
const vec3 BLACK = vec3(0.09, 0.09, 0.102);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = WHITE;
	float a = 0.0;
	float close = smoothstep(0.0, 0.5, t);
	float gap = (1.0 - close) * 0.5;
	float span = 0.95 * (1.0 - smoothstep(0.55, 1.0, t));
	float line = abs(abs(p.y) - gap);
	if (line < 0.016 && abs(p.x) < span && span > 0.0) {
		a = 1.0;
		color = line < 0.007 ? WHITE : RED;
	}
	if (t > 0.45) {
		float size = (1.0 - smoothstep(0.45, 0.85, t)) * 0.75;
		float d = max(length(p), 0.001);
		float star = size - (abs(p.x) + abs(p.y)) * (1.0 + 12.0 * min(abs(p.x), abs(p.y)) / d);
		if (star > 0.0) {
			color = star > size * 0.3 ? WHITE : RED;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
