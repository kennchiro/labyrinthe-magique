shader_type canvas_item;
render_mode blend_mix;

// UN ARC DE FOUDRE couché entre deux points (la Tempête en chaîne, le Saut d'éclair) : il crépite
// d'un bout à l'autre, puis s'amincit et s'éteint. UV.x va du départ (0) à l'arrivée (1).

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	vec3 color = T_BLUE;
	float a = 0.0;
	float fade = 1.0 - smoothstep(0.4, 1.0, t);
	float flick = floor(TIME * 20.0);
	float main = t_bolt(p, 1.0, 0.16 * fade, 0.9, seed, flick);
	if (main > -0.06 && fade > 0.0) {
		color = main <= 0.0 ? T_RIM : t_bolt_color(main / 0.16);
		a = 1.0;
	}
	float thin = t_bolt(p, 1.0, 0.05 * fade, 1.4, seed + 3.0, flick + 1.0);
	if (thin > 0.0 && fade > 0.0) {
		color = T_BLUE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
