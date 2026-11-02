shader_type canvas_item;
render_mode blend_mix;

// LA NUIT ÉTERNELLE, tout l'écran : le décor tombe dans le bleu nuit, les étoiles s'allument une à
// une, des traits les relient en grande constellation, et le ciel se retire depuis les bords.
// ⚠️ Le quad couvre deux fois l'écran : `s` ramène l'écran vers ±1,2 de large et ±0,66 de haut.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 NIGHT = vec3(0.039, 0.063, 0.2);
const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);
const vec2 CHART[10] = vec2[10](vec2(-1.02, -0.42), vec2(-0.72, -0.5), vec2(-0.5, -0.24), vec2(-0.16, -0.46),
	vec2(0.12, -0.26), vec2(0.42, -0.5), vec2(0.78, -0.36), vec2(1.04, -0.52), vec2(0.62, 0.38), vec2(-0.74, 0.34));

float star(vec2 v, float size) {
	return size - pow(pow(abs(v.x), 0.6) + pow(abs(v.y), 0.6), 1.67);
}

float hash(vec2 v) {
	return fract(sin(dot(v, vec2(12.9898, 78.233)) + seed) * 43758.5453);
}

float segment(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	return length(p - a - ab * clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0));
}

void fragment() {
	vec2 s = (UV - 0.5) * 4.4;
	float fall = smoothstep(0.0, 0.2, progress);
	float reach = 3.2 * (1.0 - smoothstep(0.78, 1.0, progress));
	float inside = 1.0 - step(reach, length(s));
	vec3 color = NIGHT;
	float alpha = 0.78 * fall;
	// Le semis : une étoile possible par cellule, qui s'allume à son heure et scintille.
	vec2 cell = floor(s * 8.0);
	float h = hash(cell);
	if (h > 0.62) {
		vec2 local = fract(s * 8.0) - 0.5 - (vec2(hash(cell + 1.0), hash(cell + 2.0)) - 0.5) * 0.5;
		float lit = step(hash(cell + 3.0) * 0.26, progress);
		float twinkle = 0.6 + 0.4 * sin(TIME * 5.0 + h * 40.0);
		float dot_star = star(local, 0.09 + 0.1 * h);
		if (dot_star > 0.0 && lit > 0.5) {
			color = mix(SHINE, vec3(1.0), twinkle);
			alpha = max(alpha, twinkle * fall);
		}
	}
	// La constellation : ses traits se dessinent l'un après l'autre.
	float drawn = clamp((progress - 0.2) / 0.2, 0.0, 1.0) * 7.0;
	for (int i = 0; i < 7; i++) {
		float part = clamp(drawn - float(i), 0.0, 1.0);
		if (part > 0.0) {
			float line = segment(s, CHART[i], mix(CHART[i], CHART[i + 1], part));
			if (line < 0.01) {
				color = SHINE;
				alpha = 1.0;
			}
		}
	}
	for (int i = 0; i < 10; i++) {
		float big = star(s - CHART[i], 0.075);
		if (big > -0.004 && progress > 0.14 + float(i) * 0.012) {
			color = big > 0.0 ? vec3(1.0) : RIM;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * inside * COLOR.a);
}
