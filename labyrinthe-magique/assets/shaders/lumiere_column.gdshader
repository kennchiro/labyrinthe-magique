shader_type canvas_item;
render_mode blend_mix;

// LA COLONNE DE L'AUBE : elle tombe du ciel sur un ennemi, plus large en haut, à cœur blanc,
// frappe, puis s'amincit. UV.y va du ciel (0) au sol (1).

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);
const vec3 RIM = vec3(0.29, 0.184, 0.071);

void fragment() {
	float y = UV.y;
	float across = abs(UV.x - 0.5) * 2.0;
	float fall = clamp(progress / 0.12, 0.0, 1.0);
	float shrink = 1.0 - smoothstep(0.2, 1.0, progress);
	float width = mix(0.28, 0.6, 1.0 - y) * shrink;
	float wobble = sin(y * 22.0 - TIME * 16.0 + seed * 7.0) * 0.03 * shrink;
	float heat = (width + wobble - across) * step(y, fall);
	vec3 color = mix(GOLD, SHINE, smoothstep(0.02, 0.1, heat));
	color = mix(color, vec3(1.0), smoothstep(0.12, 0.24, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.03, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.008, heat) * COLOR.a);
}
