shader_type canvas_item;
render_mode blend_mix;

// LE JUGEMENT DES SIX AILES : six ailes de lumière émeraude s'ouvrent dans son dos, trois de
// chaque côté, et battent lentement pendant que les épées tombent. Elles se replient à la fin
// en se rétractant vers lui.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float open = smoothstep(0.0, 0.14, t) * (1.0 - smoothstep(0.86, 1.0, t));
	float beat = sin(t * 18.0) * 0.07;
	vec3 color = EMERALD;
	float a = 0.0;
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		for (int i = 0; i < 3; i++) {
			float f = float(i);
			float angle = -0.95 + f * 0.62 + beat * (1.0 - f * 0.3);
			vec2 dir = vec2(cos(angle) * sgn, sin(angle));
			float len = (0.92 - f * 0.12) * open;
			vec2 q = p - vec2(0.0, -0.1);
			float along = dot(q, dir);
			float across = dot(q, vec2(-dir.y, dir.x)) * sgn;
			if (along <= 0.0 || along >= len) {
				continue;
			}
			float k = along / max(len, 0.001);
			// Bord d'attaque droit, bord de fuite festonné en plumes.
			float lead = 0.05 * (1.0 - k);
			float trail = 0.24 * sin(k * 3.1416) * (0.75 + 0.25 * abs(sin(k * 18.0)));
			float inside = min(across + lead, trail - across);
			if (inside > -0.03) {
				a = 1.0;
				if (inside <= 0.0) {
					color = RIM;
				} else if (k > 0.78) {
					color = GOLD;
				} else if (inside < 0.045) {
					color = DEEP;
				} else if (inside < 0.1) {
					color = EMERALD;
				} else {
					color = PALE;
				}
			}
		}
	}
	// Le cœur, derrière lui : un disque d'or.
	float core = 0.16 * open - length(p - vec2(0.0, -0.1));
	if (core > -0.03 && open > 0.0) {
		color = core > 0.0 ? GOLD : RIM;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
