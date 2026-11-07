shader_type canvas_item;
render_mode blend_mix;

// LE TRIDENT TOUCHE : une gerbe d'eau en couronne, des gouttes qui s'envolent, et un anneau d'écume.

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
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = BLUE;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.25, t) * (1.0 - smoothstep(0.45, 1.0, t));
	float crown = 0.55 * grow * (0.6 + 0.4 * abs(sin(angle * 4.0 + seed * 3.0))) - d;
	if (crown > -0.05 && grow > 0.0) {
		color = crown <= 0.0 ? RIM : (crown > 0.25 ? FOAM : (crown > 0.1 ? TEAL : BLUE));
		a = 1.0;
	}
	float front = 0.2 + smoothstep(0.1, 0.8, t) * 0.65;
	float width = 0.05 * (1.0 - smoothstep(0.5, 1.0, t));
	float ring = width - abs(d - front);
	if (ring > -0.02 && width > 0.0) {
		color = ring <= 0.0 ? RIM : FOAM;
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float at = f / 6.0 * 6.2832 + hash(f);
		vec2 c = vec2(cos(at), sin(at) - t * 0.4) * (0.25 + t * 0.6);
		float drop = 0.07 * (1.0 - t) - length((p - c) * vec2(1.0, 0.7));
		if (drop > -0.015 && t > 0.1) {
			color = drop <= 0.0 ? RIM : (drop > 0.03 ? FOAM : BLUE);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
