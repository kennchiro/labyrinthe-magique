shader_type canvas_item;
render_mode blend_mix;

// LE REGARD DU TRÔNE, toute la minute, couché au sol : un cercle de flamme saphir à deux cases dit jusqu'où porte son
// regard, avec quatre yeux d'or qui veillent aux quatre points et tournent lentement.
// ⚠️ Le quad fait 2,1 cases de rayon : le cercle tombe à 0,95 de son bord, soit à THRONE_REACH.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = vec2(p.x, p.y * 2.0);
	float born = smoothstep(0.0, 0.03, progress);
	float d = length(g);
	float a = atan(g.y, g.x) + TIME * 0.25;
	float flicker = 0.75 + 0.25 * sin(a * 12.0 + TIME * 4.0);
	vec4 color = vec4(e_flame(0.55), smoothstep(0.04, 0.0, abs(d - 0.76)) * flicker * 0.85);
	color = e_over(vec4(E_SAPPHIRE, smoothstep(0.2, 0.0, abs(d - 0.76)) * 0.18), color);
	for (int i = 0; i < 4; i++) {
		float b = float(i) * TAU / 4.0 - TIME * 0.25;
		vec2 at = vec2(cos(b), sin(b)) * 0.76;
		color = e_over(e_eye(vec2(g.x - at.x, (g.y - at.y) * 0.5), 0.09, 0.8 + 0.2 * sin(TIME * 2.0 + float(i)), 1.0), color);
	}
	color.a *= born;
	COLOR = color;
}
