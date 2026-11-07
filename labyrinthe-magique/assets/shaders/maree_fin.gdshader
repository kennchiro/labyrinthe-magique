shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL : la marée se retire, l'eau retombe autour de lui en une flaque qui se résorbe
// vers le centre, et quelques bulles remontent.

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
	vec2 g = vec2(p.x, (p.y - 0.55) * 2.8);
	float pool = 0.75 * (1.0 - t) - length(g);
	if (pool > -0.04) {
		color = pool <= 0.0 ? RIM : (pool < 0.06 ? FOAM : (pool > 0.3 ? ABYSS : BLUE));
		a = pool > 0.0 ? 0.85 : 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		vec2 c = vec2((hash(f) - 0.5) * 1.0, 0.4 - t * (0.6 + hash(f + 1.0) * 0.8));
		float bubble = 0.05 * (1.0 - t * 0.5) - length(p - c);
		float hollow = 0.03 * (1.0 - t * 0.5) - length(p - c);
		if (bubble > -0.01 && hollow < 0.0) {
			color = bubble <= 0.0 ? RIM : FOAM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
