shader_type canvas_item;
render_mode blend_mix;

// L'ANNEAU DE L'ARCHIMAGE, à ses pieds pendant la minute : il tourne lentement, et la rune de l'orbe en tête brûle
// de son élément.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform int lead = 0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p * vec2(1.0, 2.2);
	vec4 lit = vec4(0.12);
	if (lead == 0) { lit.x = 1.0; } else if (lead == 1) { lit.y = 1.0; } else if (lead == 2) { lit.z = 1.0; } else { lit.w = 1.0; }
	vec4 ring = p_ring(g, 0.66, 0.045, TIME * 0.6 + seed, lit);
	// Une lueur de l'élément en tête, sous l'anneau.
	float glow = p_glow(abs(length(g) - 0.66), 0.22) * 0.35;
	vec4 color = p_over(ring, vec4(p_element(lead), glow));
	color.a *= smoothstep(0.0, 0.015, progress) * (1.0 - smoothstep(0.985, 1.0, progress)) * 0.92;
	COLOR = color;
}
