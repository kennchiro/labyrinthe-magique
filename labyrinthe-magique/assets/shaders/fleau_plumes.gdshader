shader_type canvas_item;
render_mode blend_mix;

// LE DÉPART DE LA NUÉE : il éclate en plumes. Une bouffée de gaz vert, et quatorze plumes noir bleuté à pointe
// vert acide qui partent en tournoyant.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

// Une plume : une feuille allongée le long de +x, de longueur `len`. > 0 dedans.
float feather(vec2 q, float len) {
	if (q.x < 0.0 || q.x > len) {
		return -1.0;
	}
	float k = q.x / len;
	return len * 0.22 * sin(k * PI) - abs(q.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = F_SHADE;
	float a = 0.0;
	float d = length(p);
	float puff = (0.3 + 0.45 * smoothstep(0.0, 0.4, t)) - d;
	float wisp = texture(noise, p * 1.3 + seed).r;
	if (puff > 0.0 && wisp > 0.4 + t * 0.5) {
		color = wisp > 0.62 ? F_VENOM : F_SHADE;
		a = 0.75 * (1.0 - t);
	}
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float ca = f / 14.0 * TAU + seed * 5.0;
		float k = clamp(t * 1.2, 0.0, 1.0);
		vec2 at = vec2(cos(ca), sin(ca)) * (0.1 + k * 0.8) + vec2(0.0, k * k * 0.25);
		vec2 q = f_rot(p - at, -(ca + t * 8.0 * (f_hash(f, 2.0) - 0.5)));
		float v = feather(q + vec2(0.1, 0.0), 0.2);
		if (v > -0.012 && k < 1.0) {
			color = v <= 0.0 ? F_RIM : (q.x > 0.08 ? F_VENOM : F_NIGHT);
			a = 1.0 - k * 0.6;
		}
	}
	COLOR = vec4(color, a);
}
