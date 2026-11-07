shader_type canvas_item;
render_mode blend_mix;

// LA CAGE ÉLECTRIQUE, la zone qui le suit : un anneau d'or au sol, un dôme de barreaux d'éclairs qui
// partent de l'anneau et se rejoignent au sommet, un voile bleu très léger dedans. Elle crépite, et
// rétrécit vers son centre quand elle s'éteint.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.0;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

const float BARS = 8.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = smoothstep(0.0, 0.25, phase);
	float edge = 0.9 * open * mix(0.4, 1.0, smoothstep(0.0, 0.15, life));
	float d = length(p);
	vec3 color = T_BLUE;
	float a = 0.0;
	if (d < edge) {
		color = T_BLUE;
		a = 0.16;
	}
	// L'anneau d'or au sol.
	float ring = 0.035 - abs(d - edge);
	if (ring > -0.015 && edge > 0.0) {
		color = ring <= 0.0 ? T_RIM : T_YELLOW;
		a = 1.0;
	}
	// Les barreaux : de l'anneau vers le sommet du dôme, un peu au-dessus du centre.
	float flick = floor(phase * 14.0);
	vec2 top = vec2(0.0, -0.25 * edge);
	for (int i = 0; i < 8; i++) {
		float f = float(i);
		float ang = f / BARS * TAU + phase * 0.6 + seed * 3.0;
		vec2 foot = vec2(cos(ang), sin(ang)) * edge;
		vec2 dir = top - foot;
		float len = length(dir);
		vec2 q = t_rot(p - foot, -atan(dir.y, dir.x));
		// Un barreau sur deux s'éteint par moments : la cage crépite.
		bool lit = t_hash(f + flick, seed) > 0.25;
		float bar = t_bolt(q, len, 0.035, 0.12, f + seed * 5.0, flick);
		if (bar > -0.015 && lit && len > 0.0) {
			color = bar <= 0.0 ? T_RIM : t_bolt_color(bar / 0.035);
			a = 1.0;
		}
	}
	// L'étincelle au sommet.
	float spark = t_star(p - top, 0.14 * open, 6.0, 4.0);
	if (spark > -0.015) {
		color = spark <= 0.0 ? T_RIM : T_WHITE;
		a = 1.0;
	}
	COLOR = vec4(color, a * smoothstep(0.0, 0.06, life));
}
