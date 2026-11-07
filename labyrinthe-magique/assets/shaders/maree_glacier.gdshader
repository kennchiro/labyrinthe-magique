shader_type canvas_item;
render_mode blend_mix;

// LE GLACIER : un cercle de glace bleu pâle, fendu, hérissé de pics de glace qui sortent du sol en
// couronne. Ce qui entre y est gelé net. Il fond en se réduisant vers le centre.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 3.0;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

const vec3 FOAM = vec3(0.914, 1.0, 1.0);
const vec3 TEAL = vec3(0.329, 0.918, 0.859);
const vec3 BLUE = vec3(0.216, 0.776, 1.0);
const vec3 ABYSS = vec3(0.027, 0.345, 0.741);
const vec3 SILVER = vec3(0.784, 0.839, 0.898);
const vec3 RIM = vec3(0.024, 0.169, 0.384);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float open = smoothstep(0.0, 0.4, phase);
	float edge = 0.92 * mix(0.5, 1.0, life) * open;
	vec3 color = SILVER;
	float a = 0.0;
	if (d < edge) {
		float crack = abs(fract(texture(noise, p * 0.7 + vec2(seed)).r * 4.0) - 0.5);
		color = crack < 0.04 ? RIM : (crack < 0.1 ? BLUE : (d < edge * 0.6 ? FOAM : SILVER));
		a = 0.75;
	}
	// La couronne de pics.
	float sector = fract(angle / 6.2832 * 14.0 + 0.5 + phase * 0.02) - 0.5;
	float spike = (0.16 * open * mix(0.6, 1.0, life)) - (abs(d - edge + 0.05) + abs(sector) * 0.25);
	float height = edge - 0.08 - d;
	if (spike > -0.02 && d > edge * 0.7) {
		color = spike <= 0.0 ? RIM : (sector < 0.0 ? FOAM : TEAL);
		a = 1.0;
	}
	float rim = 0.03 - abs(d - edge);
	if (rim > 0.0) {
		color = RIM;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
