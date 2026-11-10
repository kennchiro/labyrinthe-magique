shader_type canvas_item;
render_mode blend_mix;

// LA COURONNE DES SCEAUX, au lancer : quatre cercles runiques de leurs éléments s'allument aux points cardinaux, reliés
// à lui par un fil d'or, puis le fil se tend et s'éteint.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = 1.0 - smoothstep(0.65, 1.0, t);
	vec4 color = vec4(0.0);
	// L'ordre des sceaux : feu à droite, eau en bas, terre à gauche, air en haut.
	for (int k = 0; k < 4; k++) {
		float ang = float(k) * TAU / 4.0;
		vec2 dir = vec2(cos(ang), sin(ang));
		float reach = 0.78 * smoothstep(0.0, 0.35, t);
		float along = dot(p, dir);
		float across = length(p - dir * along);
		float thread = step(0.0, along) * step(along, reach) * clamp(1.0 - across / 0.025, 0.0, 1.0);
		color = p_over(vec4(P_GOLD_LIGHT, thread * life), color);
		vec2 q = p - dir * reach;
		float dq = length(q);
		float circle = 0.03 - abs(dq - 0.17);
		float fill = p_glow(dq, 0.17);
		color = p_over(vec4(p_element(k), fill * 0.6 * life), color);
		if (circle > 0.0) {
			color = p_over(vec4(mix(P_GOLD, p_element(k), 0.4), life), color);
		}
	}
	float core = p_glow(length(p), 0.3) * (1.0 - smoothstep(0.0, 0.4, t));
	color = p_over(vec4(P_WHITE, core), color);
	COLOR = color;
}
