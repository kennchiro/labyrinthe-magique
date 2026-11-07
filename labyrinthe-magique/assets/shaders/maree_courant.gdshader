shader_type canvas_item;
render_mode blend_mix;

// LE TORRENT : un courant d'eau file le long du couloir, crêtes d'écume qui roulent vers l'avant,
// puis il s'amincit et se retire. UV.x : départ (0), arrivée (1).

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
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	float t = progress;
	float body = 0.55 * (1.0 - smoothstep(0.35, 1.0, t)) * smoothstep(0.0, 0.1, t);
	vec3 color = BLUE;
	float a = 0.0;
	float wave = sin(p.x * 12.0 - t * 25.0 + seed * 7.0) * 0.12;
	float inside = body - abs(p.y - wave);
	if (inside > -0.06 && body > 0.0) {
		float crest = fract(p.x * 3.0 - t * 4.0);
		color = inside <= 0.0 ? RIM : (crest < 0.2 && inside > body * 0.3 ? FOAM : (inside > body * 0.5 ? TEAL : ABYSS));
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
