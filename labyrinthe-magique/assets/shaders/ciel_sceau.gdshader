shader_type canvas_item;
render_mode blend_mix;

// LE SCEAU DE LA LANCE : il s'ouvre au sol sous la cible avant que la lance ne tombe. Anneau
// émeraude cerné, huit traits de rune, un losange d'or au centre. Il se referme d'un coup.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	float t = progress;
	float open = smoothstep(0.0, 0.3, t) * (1.0 - smoothstep(0.82, 1.0, t));
	vec2 p = (UV - 0.5) * 2.0 / max(open, 0.001);
	float d = length(p);
	float turn = atan(p.y, p.x) + t * 2.5 + seed * 6.0;
	vec3 color = EMERALD;
	float a = 0.0;
	float ring = 0.075 - abs(d - 0.66);
	if (ring > -0.025) {
		color = ring > 0.03 ? PALE : (ring > 0.0 ? EMERALD : RIM);
		a = 1.0;
	}
	float inner = 0.022 - abs(d - 0.46);
	if (inner > 0.0) {
		color = DEEP;
		a = 1.0;
	}
	// Huit traits de rune entre les deux anneaux.
	float tick = abs(sin(turn * 4.0));
	if (d > 0.49 && d < 0.6 && tick < 0.16) {
		color = tick < 0.08 ? EMERALD : RIM;
		a = 1.0;
	}
	float diamond = 0.2 - (abs(p.x) + abs(p.y));
	if (diamond > -0.04) {
		color = diamond > 0.08 ? PALE : (diamond > 0.0 ? GOLD : RIM);
		a = 1.0;
	}
	COLOR = vec4(color, a * step(0.001, open));
}
