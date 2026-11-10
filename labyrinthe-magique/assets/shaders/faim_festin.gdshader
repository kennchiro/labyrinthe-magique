shader_type canvas_item;
render_mode blend_mix;

// LE GRAND FESTIN : l'écran s'assombrit en vert profond sur les bords, et derrière lui s'ouvre une GUEULE IMMENSE à
// trois rangées de crocs ivoire, la gorge de bile au fond, qui respire tant que dure le festin. Le centre reste creux.

#include "res://assets/shaders/faim.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float show = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.92, 1.0, t));
	float edge = max(abs(p.x), abs(p.y));
	vec3 color = mix(G_DEEP * 0.4, G_INK, smoothstep(0.4, 1.0, edge));
	float a = (0.12 + smoothstep(0.45, 1.0, edge) * 0.4) * show;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float breathe = 0.06 * sin(TIME * 3.0);
	for (int k = 0; k < 3; k++) {
		float row = float(k);
		float r_out = 0.98 - row * 0.12 + breathe;
		float n = 18.0 + row * 4.0;
		float tooth_t = abs(fract((ang + row * 0.3) * n / TAU) - 0.5) * 2.0;
		float tip = r_out - 0.13 * (1.0 - tooth_t);
		if (d < r_out && d > tip && show > 0.0) {
			color = d < tip + 0.012 ? G_INK : G_IVORY;
			a = max(a, 0.92 * show);
		}
	}
	COLOR = vec4(color, a);
}
