shader_type canvas_item;
render_mode blend_mix;

// LA COLONNE RESTÉE ALLUMÉE, debout : un pilier de lumière blanche plus fin, qui crépite de flammes émeraude à sa base
// et s'amincit jusqu'à s'éteindre. SKY_GROUND = 0,97 : la base tombe à 0,94.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.75, 1.0, t));
	float width = 0.22 * (1.0 - t * 0.5);
	float shimmer = 0.85 + 0.15 * sin(p.y * 20.0 - TIME * 12.0);
	vec4 color = vec4(S_GOLD, smoothstep(width * 1.6, width, abs(p.x)) * step(p.y, 0.94) * 0.45 * life);
	color = s_over(vec4(S_CORE, smoothstep(width, width * 0.5, abs(p.x)) * step(p.y, 0.94) * shimmer * life), color);
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		vec2 base = vec2((f - 2.0) * 0.12, 0.94);
		vec2 q = p - base;
		float h = 0.35 * (0.7 + 0.3 * sin(TIME * 8.0 + f * 1.7));
		float y = clamp(-q.y / h, 0.0, 1.0);
		float tongue = step(-h, q.y) * step(q.y, 0.0) * smoothstep(0.07 * (1.0 - y), 0.03 * (1.0 - y), abs(q.x + sin(y * 6.0 + TIME * 7.0) * 0.03));
		color = s_over(vec4(mix(S_EMERALD, S_CORE, y * 0.5), tongue * life), color);
	}
	COLOR = color;
}
