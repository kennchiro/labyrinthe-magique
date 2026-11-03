shader_type canvas_item;
render_mode blend_mix;

// LE RAPPEL : un anneau de lave se referme sur le roi en tirant des rayons, tout se tait une
// fraction de seconde, puis le souffle repart de lui.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.851, 0.627);
const vec3 EMBER = vec3(1.0, 0.604, 0.122);
const vec3 LAVA = vec3(1.0, 0.478, 0.094);
const vec3 DEEP = vec3(0.541, 0.173, 0.031);
const vec3 BLACK = vec3(0.165, 0.129, 0.094);
float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = EMBER;
	float a = 0.0;
	float close = smoothstep(0.0, 0.45, t);
	float inward = 0.95 * (1.0 - close);
	if (t < 0.45) {
		float ring = 0.05 - abs(d - inward);
		if (ring > 0.0) {
			color = ring > 0.025 ? PALE : LAVA;
			a = 1.0;
		}
		float spoke = abs(fract(angle / 6.2832 * 12.0 + t * 1.5) - 0.5);
		if (spoke < 0.05 && d > inward && d < inward + 0.34 * (1.0 - close)) {
			color = EMBER;
			a = 1.0;
		}
	}
	float blast = smoothstep(0.45, 1.0, t);
	if (t >= 0.45) {
		float front = 0.05 + blast * 0.9;
		float width = 0.13 * (1.0 - blast);
		float ring = width - abs(d - front);
		if (ring > 0.0) {
			color = ring > width * 0.5 ? PALE : EMBER;
			a = 1.0;
		}
		float rays = 1.0 - abs(fract(angle / 6.2832 * 8.0 + 0.25) - 0.5) * 2.0;
		if (rays > 0.85 + blast * 0.1 && d < front && d > front * 0.4) {
			color = LAVA;
			a = 1.0;
		}
		float core = 0.3 * (1.0 - smoothstep(0.45, 0.7, t)) - d;
		if (core > 0.0) {
			color = PALE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
