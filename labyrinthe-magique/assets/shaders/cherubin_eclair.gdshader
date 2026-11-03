shader_type canvas_item;
render_mode blend_mix;

// COMME L'ÉCLAIR : un éclat d'éclair saphir aux deux bouts de la course. Quatre traits en zigzag
// partent du centre, et ses quatre ailes s'ouvrent une fraction de seconde derrière.

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
	float t = progress;
	vec3 color = SAPPHIRE;
	float a = 0.0;
	float live = 1.0 - smoothstep(0.55, 1.0, t);
	// Les quatre ailes, deux de chaque côté, en éventail.
	float open = smoothstep(0.0, 0.25, t) * live;
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		for (int i = 0; i < 2; i++) {
			float angle = -0.7 + float(i) * 0.75;
			vec2 dir = vec2(cos(angle) * sgn, sin(angle));
			float len = 0.85 * open;
			float along = dot(p, dir);
			float across = abs(dot(p, vec2(-dir.y, dir.x)));
			float hw = 0.16 * sin(clamp(along / max(len, 0.001), 0.0, 1.0) * 3.1416);
			float inside = hw - across;
			if (along > 0.0 && along < len && inside > -0.03) {
				color = inside <= 0.0 ? RIM : (along / len > 0.7 ? SAPPHIRE : PALE);
				a = 1.0;
			}
		}
	}
	// Les éclairs.
	for (int i = 0; i < 4; i++) {
		float at = float(i) * 1.5708 + 0.785 + seed;
		vec2 dir = vec2(cos(at), sin(at));
		float along = dot(p, dir);
		float across = dot(p, vec2(-dir.y, dir.x));
		float zig = 0.07 * (abs(fract(along * 4.5 + seed) - 0.5) * 4.0 - 1.0);
		float reach = 0.95 * smoothstep(0.0, 0.18, t) * live;
		float bolt = 0.045 * live - abs(across - zig);
		if (along > 0.0 && along < reach && bolt > -0.02) {
			color = bolt > 0.02 ? PALE : (bolt > 0.0 ? SAPPHIRE : RIM);
			a = 1.0;
		}
	}
	float core = 0.3 * (1.0 - smoothstep(0.0, 0.25, t)) - d;
	if (core > 0.0) {
		color = PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
