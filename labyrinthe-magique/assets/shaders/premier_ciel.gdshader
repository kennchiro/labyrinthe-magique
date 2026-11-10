shader_type canvas_item;
render_mode blend_mix;

// LE CIEL EN FEU : l'écran vire au rouge sombre et des braises tombent en biais sur toute la salle. L'ombre du dragon
// immense est la silhouette dessinée de sa forme de base, que le `Level` fait passer par-dessus. Le voile reste clair
// au centre pour qu'on voie les couloirs.

#include "res://assets/shaders/premier.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float show = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.9, 1.0, t));
	float edge = max(abs(p.x), abs(p.y));
	vec3 color = mix(P_BLOOD * 0.6, P_OBSIDIAN, smoothstep(0.3, 1.0, edge));
	float a = (0.18 + smoothstep(0.35, 1.0, edge) * 0.36) * show;
	float drift = texture(noise, p * 0.7 + vec2(TIME * 0.02, -TIME * 0.03) + seed).r;
	if (drift > 0.63) {
		color = mix(color, P_MAGMA * 0.6, 0.5);
		a = max(a, 0.26 * show);
	}
	vec2 r = vec2(p.x + p.y * 0.3, p.y) * vec2(30.0, 4.0);
	float col = floor(r.x);
	float fall = fract(r.y * 0.25 - TIME * (0.6 + p_hash(col, 3.0) * 0.6) + p_hash(col, 7.0));
	if (step(0.84, p_hash(col, 11.0)) * step(abs(fract(r.x) - 0.5), 0.18) * step(fall, 0.05) > 0.0) {
		color = p_hash(col, 13.0) > 0.5 ? P_YELLOW : P_MAGMA;
		a = max(a, 0.85 * show);
	}
	COLOR = vec4(color, a);
}
