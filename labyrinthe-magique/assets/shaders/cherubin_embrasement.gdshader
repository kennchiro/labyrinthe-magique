shader_type canvas_item;
render_mode blend_mix;

// L'ŒIL S'EMBRASE : il s'écarquille, puis éclate en une gerbe de flamme saphir qui monte et
// enveloppe l'ennemi, avant de retomber.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.933, 0.953, 1.0);
const vec3 SAPPHIRE = vec3(0.239, 0.42, 1.0);
const vec3 DEEP = vec3(0.102, 0.184, 0.62);
const vec3 BRONZE = vec3(0.878, 0.627, 0.29);
const vec3 RIM = vec3(0.078, 0.102, 0.18);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = SAPPHIRE;
	float a = 0.0;
	// La gerbe : des langues qui montent du sol.
	float rise = smoothstep(0.05, 0.3, t) * (1.0 - smoothstep(0.55, 1.0, t));
	float y = 0.85 - p.y;
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		float x0 = (f - 2.0) * 0.24;
		float h = (1.1 + hash(f) * 0.6 - abs(f - 2.0) * 0.18) * rise;
		float k = clamp(y / max(h, 0.001), 0.0, 1.0);
		float sway = sin(t * 18.0 + f * 1.7 + y * 5.0) * 0.07 * k;
		float hw = 0.2 * (1.0 - k * k);
		float inside = hw - abs(p.x - x0 - sway);
		if (y > 0.0 && y < h && inside > -0.035) {
			color = inside <= 0.0 ? RIM : (inside > hw * 0.5 ? PALE : (k > 0.65 ? DEEP : SAPPHIRE));
			a = 1.0;
		}
	}
	// L'œil qui s'écarquille, au début.
	float wide = 1.0 - smoothstep(0.1, 0.25, t);
	vec2 q = p - vec2(0.0, -0.45);
	float almond = 0.3 * wide * (1.0 - pow(abs(q.x) / 0.55, 2.0)) - abs(q.y);
	if (abs(q.x) < 0.58 && almond > -0.05 && wide > 0.0) {
		color = almond <= 0.0 ? RIM : (length(q) < 0.15 ? SAPPHIRE : BRONZE);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
