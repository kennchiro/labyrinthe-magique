shader_type canvas_item;
render_mode blend_mix;

// REJETÉ : une petite onde saphir et une gerbe de flammèches, là où l'ennemi est renvoyé.

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
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	vec3 color = SAPPHIRE;
	float a = 0.0;
	float front = 0.15 + smoothstep(0.0, 0.7, t) * 0.65;
	float width = 0.09 * (1.0 - smoothstep(0.3, 0.9, t));
	float ring = width - abs(d - front - 0.05 * sin(angle * 8.0 + seed * 4.0));
	if (ring > -0.025 && width > 0.0) {
		color = ring <= 0.0 ? RIM : (ring > width * 0.5 ? PALE : SAPPHIRE);
		a = 1.0;
	}
	for (int i = 0; i < 7; i++) {
		float f = float(i);
		float at = f / 7.0 * 6.2832 + hash(f);
		vec2 c = vec2(cos(at), sin(at)) * (front + 0.1);
		float size = 0.07 * (1.0 - t);
		float spark = size - length((p - c) * vec2(1.0, 0.6));
		if (spark > -0.015 && size > 0.0) {
			color = spark > 0.0 ? (hash(f + 2.0) > 0.5 ? PALE : BRONZE) : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
