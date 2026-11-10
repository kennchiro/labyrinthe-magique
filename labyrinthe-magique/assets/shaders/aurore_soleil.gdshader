shader_type canvas_item;
render_mode blend_mix;

// LE SOLEIL DE MIDI : l'écran passe en plein jour, et un grand soleil à cœur d'étoile se lève au-dessus de lui et le
// suit. Il descend sur lui à la fin. Le soleil est au-dessus de sa tête, dans le haut du quad.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float rise = smoothstep(0.0, 0.08, t);
	float fall = smoothstep(0.9, 1.0, t);
	// Le plein jour s'efface vers le bord du quad : sans ça, son carré se voyait sur l'écran.
	float edge = 1.0 - smoothstep(0.75, 1.0, max(abs(p.x), abs(p.y)));
	vec4 color = vec4(A_GOLD_LIGHT, 0.16 * rise * (1.0 - fall) * edge);
	vec2 sun_at = vec2(0.0, mix(-0.32, 0.0, fall)) - vec2(0.0, 0.08 * (1.0 - rise));
	vec2 q = p - sun_at;
	float d = length(q);
	float ang = atan(q.y, q.x);
	float flames = pow(abs(cos(ang * 8.0 + TIME * 0.6)), 4.0) * 0.05 + pow(abs(cos(ang * 16.0 - TIME)), 12.0) * 0.03;
	float disc = smoothstep(0.13 + flames, 0.12 + flames, d);
	float halo = a_glow(d, 0.4) * 0.6;
	color = a_over(vec4(A_SUN, halo * rise), color);
	color = a_over(vec4(mix(A_SUN, A_WHITE, a_glow(d, 0.12)), disc * rise), color);
	color = a_over(a_star_paint(q, 0.09, TIME * 0.5, rise), color);
	// Les grands rayons qui tournent.
	float beams = pow(abs(sin(ang * 6.0 + TIME * 0.3)), 30.0) * a_glow(d, 0.9) * step(0.13, d);
	color = a_over(vec4(A_WHITE, beams * 0.35 * rise * (1.0 - fall)), color);
	color.a *= 1.0 - smoothstep(0.96, 1.0, t);
	COLOR = color;
}
