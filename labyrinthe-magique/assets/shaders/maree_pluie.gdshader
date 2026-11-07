shader_type canvas_item;
render_mode blend_mix;

// LA PLUIE QUI SOIGNE : après le Léviathan, un voile bleu tombe sur l'écran et une pluie fine,
// en traits nets d'écume, tombe en biais. Elle s'arrête d'un coup.

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
	float t = progress;
	float live = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.9, 1.0, t));
	vec3 color = ABYSS * 0.6;
	float a = 0.25 * live * (1.0 - smoothstep(0.9, 1.0, d));
	vec2 q = vec2(p.x + p.y * 0.25, p.y) * 22.0;
	vec2 cell = floor(q);
	vec2 f = fract(q);
	float n = fract(sin(dot(cell, vec2(12.9, 78.2)) + seed) * 43758.5);
	float fall_ = fract(n + t * 6.0);
	if (n > 0.55 && abs(f.x - 0.5) < 0.06 && abs(f.y - fall_) < 0.35 && live > 0.0 && d < 0.95) {
		color = n > 0.8 ? FOAM : TEAL;
		a = 0.85 * live;
	}
	COLOR = vec4(color, a);
}
