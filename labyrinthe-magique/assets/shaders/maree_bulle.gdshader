shader_type canvas_item;
render_mode blend_mix;

// LA BULLE DES ABYSSES : une sphère d'eau cernée d'argent l'enveloppe, parcourue de courants qui
// tournent, avec deux reflets d'écume. Elle reste translucide au centre pour qu'on le voie.

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
	float live = smoothstep(0.0, 0.04, progress) * (1.0 - smoothstep(0.96, 1.0, progress));
	float r = 0.82 * live;
	vec3 color = BLUE;
	float a = 0.0;
	if (d < r && live > 0.0) {
		float swirl = sin(angle * 3.0 + d * 9.0 - TIME * 3.0 + seed);
		color = swirl > 0.6 ? TEAL : ABYSS;
		a = mix(0.18, 0.4, smoothstep(r * 0.5, r, d));
		if (swirl > 0.85 && d > r * 0.55) {
			color = FOAM;
			a = 0.7;
		}
	}
	float rim = 0.06 - abs(d - r);
	if (rim > -0.025 && live > 0.0) {
		color = rim <= 0.0 ? RIM : (rim > 0.03 ? SILVER : TEAL);
		a = 1.0;
	}
	float glint = 0.1 - length(p - vec2(-0.32, -0.38) * live);
	if (glint > 0.0 && live > 0.0) {
		color = FOAM;
		a = 0.9;
	}
	COLOR = vec4(color, a);
}
