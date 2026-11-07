shader_type canvas_item;
render_mode blend_mix;

// LE MAGMA du Soleil captif : une nappe de roche noire fendue de veines de lave, qui palpite et se
// refroidit en se réduisant vers le centre. Le bord du dessin tombe sur le rayon du sort.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.0;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

const vec3 WHITE = vec3(1.0, 0.957, 0.839);
const vec3 GOLD = vec3(1.0, 0.761, 0.227);
const vec3 ORANGE = vec3(1.0, 0.416, 0.165);
const vec3 RED = vec3(0.702, 0.125, 0.059);
const vec3 ROCK = vec3(0.16, 0.05, 0.03);
const vec3 RIM = vec3(0.165, 0.039, 0.02);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float edge = 0.92 * mix(0.55, 1.0, life) + 0.05 * sin(atan(p.y, p.x) * 7.0 + seed * 5.0);
	vec3 color = ROCK;
	float a = 0.0;
	if (d < edge) {
		a = 1.0;
		float n = texture(noise, p * 0.6 + vec2(seed, phase * 0.04)).r;
		float vein = abs(fract(n * 5.0 + phase * 0.3) - 0.5);
		float heat = life * (0.7 + 0.3 * sin(phase * 5.0 + n * 9.0));
		if (vein < 0.08 * heat) {
			color = vein < 0.03 * heat ? WHITE : GOLD;
		} else if (vein < 0.16 * heat) {
			color = ORANGE;
		} else {
			color = mix(ROCK, RED, 0.25 * heat);
		}
		if (d > edge - 0.06) {
			color = RIM;
		}
	}
	COLOR = vec4(color, a);
}
