shader_type canvas_item;
render_mode blend_mix;

// L'ÉVEIL DES MARÉES : une grande vague se dresse dans son dos, crête d'écume recourbée au-dessus de
// lui, puis elle retombe en éclaboussures de chaque côté.

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

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = BLUE;
	float a = 0.0;
	float h = smoothstep(0.0, 0.35, t) * (1.0 - smoothstep(0.62, 1.0, t));
	// Le dos de la vague : plus haut à droite, là où la crête s'enroule.
	float lean = (p.x + 0.85) / 1.7;
	float top = 0.85 - h * (1.05 + 0.55 * lean) + 0.04 * sin(p.x * 14.0 + t * 18.0);
	float body = min(0.85 - abs(p.x), p.y - top);
	if (body > -0.05 && p.y < 0.85) {
		float band = fract((p.y - top) * 3.5 - p.x * 0.8 - t * 2.0);
		color = body <= 0.0 ? RIM : (body < 0.07 ? FOAM : (band < 0.25 ? TEAL : (p.y > 0.45 ? ABYSS : BLUE)));
		a = 1.0;
	}
	// La crête qui s'enroule au-dessus de lui, vers la droite, avec son creux.
	vec2 c = vec2(0.5, 0.85 - h * 1.5 - 0.05);
	vec2 q = p - c;
	float outer = 0.36 * h - length(q * vec2(1.0, 1.15));
	float hollow = 0.2 * h - length((q - vec2(0.08, 0.1)) * vec2(1.0, 1.15));
	if (outer > -0.04 && hollow < 0.0 && h > 0.05) {
		color = outer <= 0.0 ? RIM : (outer < 0.08 ? FOAM : (q.y < 0.0 ? TEAL : BLUE));
		a = 1.0;
	}
	// Les éclaboussures quand elle retombe.
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float side = hash(f) > 0.5 ? 1.0 : -1.0;
		float k = smoothstep(0.6, 1.0, t);
		vec2 d = vec2(side * (0.4 + hash(f + 1.0) * 0.5) * (0.4 + k), 0.3 - k * 0.6 + k * k * 1.2 - hash(f + 2.0) * 0.3);
		float drop = 0.075 * (1.0 - k) - length(p - d);
		if (drop > -0.015 && k > 0.02) {
			color = drop <= 0.0 ? RIM : FOAM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
