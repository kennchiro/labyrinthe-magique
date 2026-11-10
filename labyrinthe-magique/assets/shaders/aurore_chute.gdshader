shader_type canvas_item;
render_mode blend_mix;

// UN RAYON DU SOLEIL DE MIDI : il tombe droit du ciel sur un ennemi, et éclate en étoile à ses pieds. Debout.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float down = smoothstep(0.0, 0.3, t);
	float column = clamp(1.0 - abs(p.x) / (0.22 * (1.0 - t * 0.5)), 0.0, 1.0) * step(p.y, mix(-1.0, 0.85, down));
	vec4 color = vec4(mix(A_SUN, A_WHITE, column), column * (1.0 - smoothstep(0.55, 1.0, t)));
	vec2 g = vec2(p.x, (p.y - 0.85) * 3.0);
	color = a_over(a_star_paint(g, 0.6 * step(0.3, t), t * 3.0, 1.0 - smoothstep(0.7, 1.0, t)), color);
	COLOR = color;
}
