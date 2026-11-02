shader_type canvas_item;
render_mode blend_mix;

// LE PASSAGE : son corps part en plumes noires liserées d'os, et une onde rouge s'élargit au sol.
// Le même éclat sert aux deux bouts, comme les autres fuites peintes.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 BLACK = vec3(0.078, 0.075, 0.11);
const vec3 RED = vec3(0.886, 0.22, 0.165);
const vec3 BONE = vec3(0.902, 0.875, 0.792);
const float FEATHERS = 12.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec3 color = BLACK;
	float alpha = 0.0;
	// L'anneau au sol, vu de biais.
	vec2 flat_p = vec2(p.x, (p.y - 0.42) * 2.4);
	float grown = 0.2 + 0.6 * (1.0 - pow(1.0 - progress, 3.0));
	float ring = 0.028 * (1.0 - progress) + 0.006 - abs(length(flat_p) - grown);
	if (ring > 0.0) {
		color = RED;
		alpha = 1.0 - smoothstep(0.6, 1.0, progress);
	}
	// Les plumes : chacune monte en se balançant.
	for (int i = 0; i < int(FEATHERS); i++) {
		float f = float(i);
		float life = clamp(progress * 1.25 - hash(f) * 0.25, 0.0, 1.0);
		vec2 at = vec2((hash(f + 2.0) - 0.5) * 0.7 + sin(life * 9.0 + f) * 0.07, 0.45 - life * 1.15);
		float tilt = sin(life * 6.0 + f * 2.0) * 0.7;
		vec2 v = p - at;
		vec2 r = vec2(v.x * cos(tilt) - v.y * sin(tilt), v.x * sin(tilt) + v.y * cos(tilt));
		float body = 0.03 * (1.0 - pow(abs(r.y) / 0.1, 2.0)) - abs(r.x);
		if (body > -0.008 && abs(r.y) < 0.1 && life > 0.0 && life < 1.0) {
			color = body > 0.0 ? BLACK : BONE;
			alpha = max(alpha, 1.0 - smoothstep(0.7, 1.0, life));
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
