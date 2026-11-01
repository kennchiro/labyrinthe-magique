shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE LA LUMIÈRE : une étoile à quatre pointes fines et une petite croix claire,
// qui s'ouvrent d'un coup et se referment très vite.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);
const vec3 RIM = vec3(0.29, 0.184, 0.071);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = 1.0 - pow(1.0 - clamp(progress / 0.3, 0.0, 1.0), 3.0);
	float shut = smoothstep(0.45, 1.0, progress);
	float size = 0.46 * open * (1.0 - shut);
	float angle = seed * 3.0;
	float c = cos(angle);
	float s = sin(angle);
	vec2 q = vec2(p.x * c - p.y * s, p.x * s + p.y * c);
	float star = size - pow(pow(abs(q.x), 0.55) + pow(abs(q.y), 0.55), 1.82);
	vec2 q2 = vec2(q.x + q.y, q.x - q.y) * 0.71;
	float cross_star = size * 0.5 - pow(pow(abs(q2.x), 0.55) + pow(abs(q2.y), 0.55), 1.82);
	float heat = max(star, cross_star);
	vec3 color = mix(GOLD, SHINE, smoothstep(0.015, 0.05, heat));
	color = mix(color, vec3(1.0), smoothstep(0.07, 0.14, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.012, heat));
	COLOR = vec4(color, smoothstep(-0.004, 0.0, heat) * COLOR.a);
}
