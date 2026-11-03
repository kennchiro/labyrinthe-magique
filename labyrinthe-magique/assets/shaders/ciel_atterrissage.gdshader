shader_type canvas_item;
render_mode blend_mix;

// L'ATTERRISSAGE : il retombe dans un anneau émeraude qui frappe autour de lui, et quelques plumes
// retombent après lui en tournant.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = EMERALD;
	float a = 0.0;
	float flash = 0.4 * (1.0 - smoothstep(0.0, 0.15, t)) - d;
	if (flash > 0.0) {
		color = PALE;
		a = 1.0;
	}
	float front = 0.1 + (1.0 - pow(1.0 - smoothstep(0.0, 0.6, t), 2.0)) * 0.72;
	float width = 0.09 * (1.0 - smoothstep(0.3, 0.75, t));
	float ring = width - abs(d - front);
	if (ring > -0.025 && width > 0.0) {
		color = ring > width * 0.55 ? PALE : (ring > width * 0.2 ? EMERALD : (ring > 0.0 ? DEEP : RIM));
		a = 1.0;
	}
	// Les plumes qui retombent : elles descendent en se balançant, et rapetissent.
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float at = hash(f) * 6.2832;
		float out_ = 0.25 + hash(f + 2.0) * 0.45;
		vec2 c = vec2(cos(at) * out_ + sin(t * 9.0 + f) * 0.06, -0.55 + t * 1.1 + sin(at) * 0.2);
		float spin = t * 5.0 + f;
		vec2 dir = vec2(cos(spin), sin(spin));
		vec2 q = p - c;
		float size = 1.0 - smoothstep(0.6, 1.0, t);
		float feather = size - length(vec2(dot(q, dir) / 0.1, dot(q, vec2(-dir.y, dir.x)) / 0.035));
		if (feather > -0.3 && size > 0.0 && t > 0.1) {
			color = feather > 0.0 ? (hash(f + 5.0) > 0.4 ? PALE : GOLD) : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
