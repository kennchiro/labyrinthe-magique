shader_type canvas_item;
render_mode blend_mix;

// LE CLOUÉ : un anneau d'or tourne au sol sous l'ennemi tant qu'il ne peut pas bouger, quatre
// pointes tournées vers lui. Il se resserre d'un coup quand l'ennemi est libéré.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	float t = progress;
	float size = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.9, 1.0, t));
	vec2 p = (UV - 0.5) * 2.0 / max(size, 0.001);
	p.y *= 2.2;
	float d = length(p);
	float turn = atan(p.y, p.x) - t * 9.0 + seed;
	vec3 color = GOLD;
	float a = 0.0;
	float ring = 0.06 - abs(d - 0.72);
	if (ring > -0.03) {
		color = ring > 0.025 ? PALE : (ring > 0.0 ? GOLD : RIM);
		a = 1.0;
	}
	float inner = 0.022 - abs(d - 0.52);
	if (inner > 0.0) {
		color = EMERALD;
		a = 1.0;
	}
	// Quatre pointes qui piquent vers le centre.
	float sector = abs(fract(turn / 1.5708 + 0.5) - 0.5) * 1.5708;
	float spike = (0.66 - d) * 0.35 - sector * d;
	if (d > 0.36 && d < 0.68 && spike > -0.02) {
		color = spike > 0.0 ? GOLD : RIM;
		a = 1.0;
	}
	COLOR = vec4(color, a * step(0.001, size));
}
