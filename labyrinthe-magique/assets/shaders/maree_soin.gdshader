shader_type canvas_item;
render_mode blend_mix;

// LA BULLE A TENU : elle se dissout en une spirale d'eau claire qui monte autour de lui, et trois
// gouttes d'argent remontent : il reprend un point de vie.

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
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = TEAL;
	float a = 0.0;
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float k = fract(f / 14.0 + t * 0.6);
		float at = f * 0.9 + t * 9.0;
		vec2 c = vec2(cos(at) * 0.6 * (1.0 - k * 0.4), 0.6 - k * 1.4);
		float size = 0.07 * (1.0 - t * 0.8);
		float drop = size - length((p - c) * vec2(1.0, 0.75));
		if (drop > -0.015) {
			color = drop <= 0.0 ? RIM : (hash(f) > 0.5 ? FOAM : TEAL);
			a = 1.0;
		}
	}
	float plus = (abs(p.x) < 0.06 && abs(p.y + 0.15) < 0.22) || (abs(p.y + 0.15) < 0.06 && abs(p.x) < 0.22) ? 1.0 : 0.0;
	if (plus > 0.5 && t > 0.3 && t < 0.9) {
		color = SILVER;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
