shader_type canvas_item;
render_mode blend_mix;

// L'ENTAILLE EN VOL : un croissant fin et net, blanc, bordé d'un filet rouge et cerné de noir.

uniform float seed = 0.0;

const vec3 WHITE = vec3(1.0, 0.965, 0.933);
const vec3 STEEL = vec3(0.851, 0.871, 0.89);
const vec3 RED = vec3(0.722, 0.078, 0.078);
const vec3 DEEP = vec3(0.369, 0.039, 0.039);
const vec3 BLACK = vec3(0.09, 0.09, 0.102);

void fragment() {
	vec2 p = (UV - vec2(0.42, 0.5)) * vec2(2.0, 2.0);
	float outer = length(p - vec2(-0.36, 0.0)) - 0.86;
	float inner = length(p - vec2(-0.72, 0.0)) - 0.98;
	float shape = max(outer, -inner);
	vec3 color = WHITE;
	float a = 0.0;
	if (shape < 0.0) {
		a = 1.0;
		color = shape > -0.02 ? BLACK : (shape > -0.06 ? RED : WHITE);
	}
	float tail = UV.x;
	if (abs(p.y) < 0.018 && UV.x < 0.45) {
		color = RED;
		a = smoothstep(0.0, 0.45, tail);
	}
	COLOR = vec4(color, a);
}
