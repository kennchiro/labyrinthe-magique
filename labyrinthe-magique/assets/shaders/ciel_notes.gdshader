shader_type canvas_item;
render_mode blend_mix;

// L'ÉTOURDI : trois petites notes d'or tournent au-dessus de sa tête tant que l'étourdissement
// dure. Elles se rétractent d'un coup à la fin.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float size = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.9, 1.0, t));
	vec3 color = GOLD;
	float a = 0.0;
	for (int i = 0; i < 3; i++) {
		float at = float(i) / 3.0 * 6.2832 + t * 14.0 + seed;
		vec2 c = vec2(cos(at) * 0.62, sin(at) * 0.2 - 0.1);
		vec2 q = (p - c) / max(size, 0.001);
		// La tête de la note, un peu penchée.
		vec2 h = vec2(q.x * 0.9 + q.y * 0.45, q.y * 0.9 - q.x * 0.45);
		float head = 0.11 - length(h * vec2(1.0, 1.45));
		// La hampe et son crochet.
		float stem = (q.y <= 0.0 && q.y >= -0.36) ? 0.025 - abs(q.x - 0.085) : -1.0;
		float flag = (q.x >= 0.085 && q.x <= 0.2) ? 0.035 - abs(q.y + 0.33 - (q.x - 0.085) * 0.6) : -1.0;
		float note = max(head, max(stem, flag));
		if (note > -0.03 && size > 0.0) {
			color = note > 0.04 ? PALE : (note > 0.0 ? GOLD : RIM);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
