shader_type canvas_item;
render_mode blend_mix;

// UN RAYON DU PAS DES ÉLÉMENTS : il jaillit d'un trait le long du couloir, de la matière de son élément sur un fil
// d'or, puis s'amincit et s'éteint. x le long du couloir.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform int kind = 0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float t = progress;
	float reach = smoothstep(0.0, 0.25, t);
	float width = mix(1.0, 0.45, smoothstep(0.3, 1.0, t)) * smoothstep(1.0, 0.85, x / max(0.01, reach));
	float h = (width - y) * 1.3 * step(x, reach);
	vec4 color = paint_element(kind, vec2(x * 4.0 - TIME * 2.0 + seed, (UV.y - 0.5) * 0.7), TIME * 1.8, h);
	float thread = clamp(1.0 - y / max(0.02, width * 0.2), 0.0, 1.0) * step(x, reach);
	color = p_over(vec4(mix(P_GOLD, P_WHITE, thread), thread * 0.9), color);
	color.a *= 1.0 - smoothstep(0.7, 1.0, t);
	COLOR = color;
}
