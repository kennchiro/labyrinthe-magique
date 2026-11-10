shader_type canvas_item;
render_mode blend_mix;

// L'ARRIVÉE DE LA NUÉE : les plumes et le gaz tournent en tourbillon serré qui se referme sur lui, puis le
// recrache dans une bouffée verte qui s'ouvre au sol.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_SHADE;
	float a = 0.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float close = 1.0 - smoothstep(0.0, 0.45, t);
	float arm = fract((ang + d * 5.0 + t * 14.0) / TAU * 4.0);
	if (d < 0.2 + 0.7 * close && d > 0.08 && arm < 0.22 && t < 0.5) {
		color = arm < 0.06 ? F_NIGHT : (arm < 0.14 ? F_VENOM : F_SHADE);
		a = 0.9;
	}
	// La bouffée qui s'ouvre au sol.
	vec2 g = (p - vec2(0.0, 0.3)) * vec2(1.0, 2.0);
	float open = smoothstep(0.4, 0.75, t);
	float wisp = texture(noise, g * 1.2 + seed).r;
	float cloud = (0.35 + 0.5 * open) * (0.8 + 0.3 * wisp) - length(g);
	if (open > 0.0 && cloud > -0.03) {
		color = cloud <= 0.0 ? F_RIM : (cloud > 0.25 ? F_BRIGHT : (cloud > 0.1 ? F_VENOM : F_SHADE));
		a = max(a, 0.85 * (1.0 - smoothstep(0.75, 1.0, t)));
	}
	COLOR = vec4(color, a);
}
