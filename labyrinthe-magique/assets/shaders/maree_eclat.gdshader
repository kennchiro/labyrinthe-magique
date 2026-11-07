shader_type canvas_item;
render_mode blend_mix;

// L'EAU ÉCLATE : une gerbe d'écume en étoile, un anneau d'eau qui court au sol, et des gouttes
// projetées. La coque qui cède, les deux bouts du Torrent, l'éclosion.

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
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = BLUE;
	float a = 0.0;
	float burst = 0.5 * (1.0 - smoothstep(0.1, 0.6, t)) * (0.55 + 0.45 * abs(sin(angle * 5.0 + seed * 2.0))) - d;
	if (burst > -0.04) {
		color = burst <= 0.0 ? RIM : (burst > 0.18 ? FOAM : TEAL);
		a = 1.0;
	}
	float front = 0.15 + smoothstep(0.0, 0.7, t) * 0.7;
	float width = 0.07 * (1.0 - smoothstep(0.4, 1.0, t));
	float ring = width - abs(d - front);
	if (ring > -0.025 && width > 0.0) {
		color = ring <= 0.0 ? RIM : (ring > width * 0.5 ? FOAM : BLUE);
		a = 1.0;
	}
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float at = f / 8.0 * 6.2832 + hash(f) * 0.5;
		vec2 c = vec2(cos(at), sin(at)) * (0.3 + t * 0.6) + vec2(0.0, t * t * 0.4);
		float drop = 0.06 * (1.0 - t) - length(p - c);
		if (drop > -0.015) {
			color = drop <= 0.0 ? RIM : FOAM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
