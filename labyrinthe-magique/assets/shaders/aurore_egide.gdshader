shader_type canvas_item;
render_mode blend_mix;

// L'ÉGIDE SOLAIRE : les ailes de rayons se referment en bouclier rond autour de lui. `left` dit combien de coups
// elle tient encore : une lame s'éteint à chaque coup.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

uniform float left = 3.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float born = smoothstep(0.0, 0.06, progress);
	float fade = 1.0 - smoothstep(0.92, 1.0, progress);
	vec4 color = vec4(0.0);
	// Les lames : douze rayons pointus, refermés en cercle.
	for (int i = 0; i < 12; i++) {
		float f = float(i);
		float a = f * TAU / 12.0 + TIME * 0.4;
		vec2 dir = vec2(cos(a), sin(a));
		vec2 q = p - dir * 0.62;
		float along = dot(q, vec2(-dir.y, dir.x));
		float across = dot(q, dir);
		float blade = step(abs(across), 0.12 * (1.0 - abs(along) / 0.5)) * step(abs(along), 0.5);
		float lit = step(f, left * 4.0 - 0.5);
		color = a_over(vec4(mix(A_SUN, A_WHITE, 0.5), blade * (0.25 + 0.65 * lit)), color);
	}
	float shell = smoothstep(0.04, 0.0, abs(d - 0.85)) * 0.8 + a_glow(d, 0.85) * 0.12;
	color = a_over(vec4(A_GOLD_LIGHT, shell), color);
	color = a_over(a_star_paint(p, 0.18, TIME, 0.8), color);
	color.a *= born * fade;
	COLOR = color;
}
