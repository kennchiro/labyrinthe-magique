shader_type canvas_item;
render_mode blend_mix;

// LA GEÔLE AU SOL : un grand cercle de runes de flamme froide, tracé d'un trait, qui bat pendant
// toute la prise et se brise à la fin. Il est creux : on voit ce qui se passe dedans.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.902, 0.992, 1.0);
const vec3 EMBER = vec3(0.086, 0.878, 0.91);
const vec3 LAVA = vec3(0.4, 0.94, 0.97);
const vec3 DEEP = vec3(0.039, 0.435, 0.478);
const vec3 BLACK = vec3(0.078, 0.094, 0.122);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x) / 6.2832 + 0.5;
	float t = progress;
	vec3 color = EMBER;
	float a = 0.0;
	float drawn = smoothstep(0.0, 0.12, t);
	float beat = 0.5 + 0.5 * sin(t * 40.0);
	float broken = smoothstep(0.92, 1.0, t);
	bool lit = angle < drawn;
	float outer = 0.92;
	float band = abs(d - outer);
	if (band < 0.009 && lit) {
		color = band < 0.004 ? PALE : EMBER;
		a = 1.0;
	}
	float inner = abs(d - 0.8);
	if (inner < 0.005 && lit) {
		color = EMBER;
		a = 1.0;
	}
	float rune = abs(fract(angle * 24.0) - 0.5);
	if (d > 0.848 && d < 0.872 && rune < 0.1 && lit && fract(angle * 24.0 * 0.5 + hash(floor(angle * 24.0))) < 0.7) {
		color = mix(EMBER, PALE, beat);
		a = 1.0;
	}
	if (broken > 0.0) {
		float gap = step(broken * 0.6, abs(fract(angle * 9.0 + seed) - 0.5) * 2.0);
		a *= gap * (1.0 - broken);
	}
	COLOR = vec4(color, a);
}
