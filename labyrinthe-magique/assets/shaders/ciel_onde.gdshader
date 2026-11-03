shader_type canvas_item;
render_mode blend_mix;

// L'ONDE DE LA CLOCHE : trois anneaux émeraude, nets et espacés, partent de lui à vol d'oiseau et
// passent par-dessus les haies. Chacun s'amincit en avançant au lieu de s'estomper.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	vec3 color = EMERALD;
	float a = 0.0;
	for (int i = 0; i < 3; i++) {
		float start = float(i) * 0.16;
		float k = clamp((progress - start) / 0.62, 0.0, 1.0);
		if (k <= 0.0 || k >= 1.0) {
			continue;
		}
		float front = 0.06 + (1.0 - pow(1.0 - k, 2.0)) * 0.74;
		float width = 0.045 * (1.0 - k) + 0.006;
		float ring = width - abs(d - front);
		if (ring > -0.012) {
			color = ring > width * 0.5 ? PALE : (ring > 0.0 ? EMERALD : RIM);
			a = 1.0;
		}
		// Les notes d'or posées sur le premier anneau.
		if (i == 0) {
			for (int n = 0; n < 8; n++) {
				float at = float(n) / 8.0 * 6.2832 + seed * 3.0;
				vec2 c = vec2(cos(at), sin(at)) * front;
				float dot_ = 0.032 * (1.0 - k) + 0.01 - length(p - c);
				if (dot_ > -0.012) {
					color = dot_ > 0.0 ? GOLD : RIM;
					a = 1.0;
				}
			}
		}
	}
	COLOR = vec4(color, a);
}
