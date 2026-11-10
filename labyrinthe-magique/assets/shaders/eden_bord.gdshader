shader_type canvas_item;
render_mode blend_mix;

// L'ÉPÉE QUI TOURNOIE SUR LE BORD DE L'ÉDEN, couchée au sol : une épée de flamme saphir posée sur le cercle, la pointe
// vers l'extérieur, fait le tour en GARDEN_SWORD_PERIOD (3 s), traînant un arc de flamme. `seconds` est la durée de
// l'Éden : l'angle se compte en secondes, comme dans le CombatSystem. Le quad couvre le rayon du cercle.

#include "res://assets/shaders/eden.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float seconds = 10.0;

const float PERIOD = 3.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float born = smoothstep(0.0, 0.03, progress) * (1.0 - smoothstep(0.97, 1.0, progress));
	float angle = progress * seconds * TAU / PERIOD;
	float r = 0.92;
	float a = atan(p.y, p.x);
	float behind = mod(angle - a, TAU);
	float d = length(p);
	vec4 color = vec4(0.0);
	// L'arc de flamme qu'elle laisse derrière elle.
	float arc = smoothstep(0.06, 0.0, abs(d - r)) * (1.0 - smoothstep(0.0, 1.6, behind));
	color = e_over(vec4(e_flame(0.7 - behind * 0.3), arc * 0.9), color);
	// L'épée : une lame de flamme le long du rayon, la garde vers le centre.
	vec2 dir = vec2(cos(angle), sin(angle));
	vec2 side = vec2(-dir.y, dir.x);
	vec2 q = p - dir * r;
	float along = dot(q, dir);
	float across = abs(dot(q, side));
	float half_w = 0.045 * (0.15 - along) / 0.31 + 0.008;
	float blade = step(-0.16, along) * step(along, 0.15) * smoothstep(half_w, half_w * 0.6, across);
	color = e_over(vec4(E_RIM, step(-0.17, along) * step(along, 0.16) * smoothstep(half_w + 0.012, half_w, across)), color);
	color = e_over(vec4(e_flame(0.95 - across / half_w * 0.6), blade), color);
	float guard = step(abs(along + 0.18), 0.018) * step(across, 0.065);
	color = e_over(vec4(E_BRONZE, guard), color);
	color.a *= born;
	COLOR = color;
}
