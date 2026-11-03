shader_type canvas_item;
render_mode blend_mix;

// LE SCEAU DU JUGEMENT : un sceau d'or apparaît au sol sous chaque ennemi désigné, quatre petites
// ailes sur son bord, et tourne en attendant son épée. Il se referme d'un coup quand elle tombe.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	float t = progress;
	float open = smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.9, 1.0, t));
	vec2 p = (UV - 0.5) * 2.0 / max(open, 0.001);
	float d = length(p);
	float turn = atan(p.y, p.x) + t * 4.0 + seed * 6.0;
	vec3 color = GOLD;
	float a = 0.0;
	float ring = 0.07 - abs(d - 0.64);
	if (ring > -0.025) {
		color = ring > 0.03 ? PALE : (ring > 0.0 ? GOLD : RIM);
		a = 1.0;
	}
	// Quatre petites ailes posées sur l'anneau.
	float sector = fract(turn / 1.5708);
	float wing = (0.16 - abs(d - 0.8)) - abs(sector - 0.5) * 0.5;
	if (wing > -0.02 && d > 0.66 && d < 0.98) {
		color = wing > 0.0 ? GOLD : RIM;
		a = 1.0;
	}
	float inner = 0.02 - abs(d - 0.42);
	if (inner > 0.0) {
		color = EMERALD;
		a = 1.0;
	}
	float diamond = 0.17 - (abs(p.x) + abs(p.y) * 0.8);
	if (diamond > -0.035) {
		color = diamond > 0.07 ? PALE : (diamond > 0.0 ? EMERALD : RIM);
		a = 1.0;
	}
	COLOR = vec4(color, a * step(0.001, open));
}
