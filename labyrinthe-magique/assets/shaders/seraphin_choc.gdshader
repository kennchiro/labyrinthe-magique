shader_type canvas_item;
render_mode blend_mix;

// L'ÉPÉE GÉANTE FRAPPE : un éclair blanc, une onde d'or qui court au sol à vol d'oiseau, six traits de lumière qui
// partent en étoile, et des plumes qui retombent.

#include "res://assets/shaders/seraphin.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = vec2(p.x, p.y * 2.0);
	float d = length(g);
	vec4 color = vec4(0.0);
	float fade = 1.0 - smoothstep(0.55, 1.0, t);
	color = s_over(vec4(S_GOLD, smoothstep(0.06, 0.0, abs(d - sqrt(t) * 0.95)) * (1.0 - t)), color);
	color = s_over(vec4(S_EMERALD, smoothstep(0.1, 0.0, abs(d - sqrt(t) * 0.75)) * (1.0 - t) * 0.6), color);
	float spokes = pow(abs(cos(atan(g.y, g.x) * 3.0)), 30.0) * s_glow(d, sqrt(t) * 1.0 + 0.05) * fade;
	color = s_over(vec4(S_CORE, spokes), color);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		vec2 at = vec2((s_hash(f, seed) - 0.5) * 1.6, -0.6 + t * 1.0 + s_hash(f, 3.0) * 0.3);
		color = s_over(s_wing(p, at, t * 5.0 + f, 0.1, 0.12, 1, fade * step(0.15, t)), color);
	}
	float flash = 1.0 - smoothstep(0.0, 0.3, t);
	color = s_over(vec4(S_CORE, s_glow(length(p), 0.9) * flash), color);
	COLOR = color;
}
