shader_type canvas_item;
render_mode blend_mix;

// LA GARDE : un cercle fin qui se referme lentement, gradué de huit traits. On lit d'un coup d'œil le
// temps qu'il reste : tant qu'il n'a pas touché le chevalier, le prochain coup est paré.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.965, 0.933);
const vec3 STEEL = vec3(0.851, 0.871, 0.89);
const vec3 RED = vec3(0.722, 0.078, 0.078);
const vec3 DEEP = vec3(0.369, 0.039, 0.039);
const vec3 BLACK = vec3(0.09, 0.09, 0.102);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	float front = 0.9 - t * 0.55;
	vec3 color = WHITE;
	float a = 0.0;
	float ring = abs(d - front);
	if (ring < 0.03) {
		color = ring < 0.014 ? WHITE : RED;
		a = 1.0;
	}
	float tick = abs(fract(angle / 6.2832 * 8.0 + t * 0.5) - 0.5);
	if (tick < 0.06 && d > front && d < front + 0.09) {
		color = RED;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
