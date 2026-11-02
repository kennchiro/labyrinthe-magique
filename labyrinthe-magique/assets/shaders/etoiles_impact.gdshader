shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT D'ÉTOILE : une croix fine qui s'ouvre et se referme, et des points blancs qui s'écartent.
// Le même éclat sert aux deux bouts de l'Étoile filante.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);
const float DOTS = 8.0;

float star(vec2 v, float size) {
	return size - pow(pow(abs(v.x), 0.6) + pow(abs(v.y), 0.6), 1.67);
}

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = smoothstep(0.0, 0.25, progress) * (1.0 - smoothstep(0.4, 1.0, progress));
	float turn = progress * 0.9;
	vec2 r = vec2(p.x * cos(turn) - p.y * sin(turn), p.x * sin(turn) + p.y * cos(turn));
	float heat = star(r, 0.42 * open);
	float alpha = smoothstep(-0.016, -0.002, heat) * step(0.001, open);
	vec3 color = mix(BLUE, SHINE, smoothstep(0.0, 0.03, heat));
	color = mix(color, vec3(1.0), smoothstep(0.04, 0.12, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.016, heat));
	for (int i = 0; i < int(DOTS); i++) {
		float f = float(i);
		float a = TAU * (f + hash(f)) / DOTS;
		vec2 at = vec2(cos(a), sin(a)) * (0.2 + 0.62 * sqrt(progress) * (0.7 + 0.3 * hash(f + 3.0)));
		float dot_size = 0.04 * (1.0 - progress) + 0.006 - length(p - at);
		if (dot_size > 0.0 && alpha < 0.5) {
			color = vec3(1.0);
			alpha = 1.0 - progress * progress;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
