shader_type canvas_item;
render_mode blend_mix;

// LE TRIDENT, le projectile : trois pointes d'eau en trident devant une hampe de courant, avec un
// sillage d'écume. UV.x va de la queue (0) à la pointe (1).

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 FOAM = vec3(0.914, 1.0, 1.0);
const vec3 TEAL = vec3(0.329, 0.918, 0.859);
const vec3 BLUE = vec3(0.216, 0.776, 1.0);
const vec3 ABYSS = vec3(0.027, 0.345, 0.741);
const vec3 SILVER = vec3(0.784, 0.839, 0.898);
const vec3 RIM = vec3(0.024, 0.169, 0.384);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

// Une vague enroulée : une crête qui se recourbe sur elle-même, > 0 dedans. q centré sur sa base,
// x vers l avant de la vague, y vers le haut (négatif à l écran).
float curl(vec2 q, float size) {
	vec2 u = q / max(size, 0.001);
	float body = (u.y > -1.0 && u.y < 0.0 && u.x > -1.0 && u.x < 0.6) ? 0.12 + 0.88 * (1.0 + u.y) * 0.5 - abs(u.x + 0.2 - (u.y + 1.0) * 0.35) * 0.9 : -1.0;
	vec2 c = u - vec2(0.25, -0.95);
	float lip = 0.35 - length(c);
	float hole = 0.18 - length(c - vec2(0.05, 0.05));
	float crest = (u.y < -0.6) ? max(lip, body) : body;
	return hole > 0.0 && u.y < -0.75 ? -0.05 : crest;
}

void fragment() {
	vec2 p = vec2(UV.x * 2.0 - 1.0, (UV.y - 0.5) * 2.0);
	vec3 color = BLUE;
	float a = 0.0;
	// La hampe et le sillage.
	float wave = sin(p.x * 14.0 - TIME * 30.0 + seed * 4.0) * 0.06 * (1.0 - (p.x + 1.0) * 0.4);
	float shaft = (p.x < 0.45) ? (0.16 * (p.x + 1.1) / 1.55) - abs(p.y - wave) : -1.0;
	if (shaft > -0.05) {
		color = shaft <= 0.0 ? RIM : (shaft > 0.09 ? FOAM : (shaft > 0.04 ? TEAL : BLUE));
		a = 1.0;
	}
	// Les trois pointes.
	for (int i = 0; i < 3; i++) {
		float y0 = (float(i) - 1.0) * 0.48;
		float start = i == 1 ? 0.35 : 0.42;
		float k = (p.x - start) / (0.95 - start);
		float hw = 0.16 * (1.0 - k) * step(0.0, k) * step(k, 1.0);
		float prong = hw - abs(p.y - y0 * (1.0 - k * 0.2));
		if (prong > -0.05 && k > -0.05 && k < 1.0) {
			color = prong <= 0.0 ? RIM : (prong > hw * 0.5 ? FOAM : TEAL);
			a = 1.0;
		}
	}
	// La traverse qui relie les pointes.
	float bar = (p.x > 0.3 && p.x < 0.45) ? 0.62 - abs(p.y) : -1.0;
	if (bar > -0.05) {
		color = bar <= 0.0 ? RIM : SILVER;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
