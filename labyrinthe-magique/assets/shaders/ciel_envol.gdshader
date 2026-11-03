shader_type canvas_item;
render_mode blend_mix;

// L'ENVOL : ses deux grandes ailes s'ouvrent d'un coup, plume par plume, blanches aux pointes
// émeraude, pendant qu'un anneau de plumes court au sol. Puis elles se replient et disparaissent.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = PALE;
	float a = 0.0;
	// L'anneau au sol, aplati, et ses plumes chassées.
	vec2 g = vec2(p.x, (p.y - 0.55) * 2.6);
	float gd = length(g);
	float front = 0.15 + smoothstep(0.0, 0.8, t) * 0.75;
	float width = 0.07 * (1.0 - smoothstep(0.5, 1.0, t));
	float ring = width - abs(gd - front);
	if (ring > -0.025 && width > 0.0) {
		color = ring > width * 0.5 ? PALE : (ring > 0.0 ? EMERALD : RIM);
		a = 1.0;
	}
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float at = f / 10.0 * 6.2832 + hash(f) * 0.4;
		vec2 c = vec2(cos(at) * (front + 0.08), sin(at) * (front + 0.08) / 2.6 + 0.55);
		vec2 q = p - c;
		vec2 dir = vec2(cos(at + 0.6), sin(at + 0.6));
		float along = dot(q, dir);
		float side = dot(q, vec2(-dir.y, dir.x));
		float feather = 1.0 - length(vec2(along / 0.09, side / 0.03));
		if (feather > -0.25 && t < 0.9) {
			color = feather > 0.0 ? (hash(f + 7.0) > 0.5 ? PALE : GOLD) : RIM;
			a = 1.0;
		}
	}
	// Les deux ailes : cinq plumes de chaque côté, qui s'ouvrent vers le haut.
	float open = smoothstep(0.0, 0.3, t);
	float fold = 1.0 - smoothstep(0.65, 1.0, t);
	vec2 shoulder = vec2(0.0, -0.05);
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		for (int i = 0; i < 5; i++) {
			float f = float(i);
			float rest = 1.5708 + 0.25;              // repliée : vers le bas
			float spread = -0.95 + f * 0.3;           // ouverte : en éventail, vers le haut et le côté
			float angle = mix(rest, spread, open);
			vec2 dir = vec2(cos(angle) * sgn, sin(angle));
			float len = (0.9 - abs(f - 1.0) * 0.07) * fold;
			vec2 q = p - shoulder;
			float along = dot(q, dir);
			float side = abs(dot(q, vec2(-dir.y, dir.x)));
			float half_width = 0.12 * sin(clamp(along / max(len, 0.001), 0.0, 1.0) * 3.1416);
			float inside = half_width - side;
			if (along > 0.0 && along < len && inside > -0.025 && fold > 0.0) {
				float tipside = along / len;
				color = inside <= 0.0 ? RIM : (tipside > 0.68 ? EMERALD : (inside > half_width * 0.4 ? PALE : vec3(0.82, 0.9, 0.86)));
				a = 1.0;
			}
		}
	}
	COLOR = vec4(color, a);
}
