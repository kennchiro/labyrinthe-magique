shader_type canvas_item;
render_mode blend_mix;

// UN ÉCLAT DE LA GÉODE, couché de la géode vers sa cible : un cristal vert taillé file d'un bout à
// l'autre en laissant trois paillettes. UV.x va de la géode (0) à la cible (1).

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	vec3 color = C_CRYSTAL;
	float a = 0.0;
	float head = mix(0.1, 0.9, smoothstep(0.0, 0.75, t));
	float show = 1.0 - smoothstep(0.75, 0.85, t);
	// Les paillettes laissées derrière.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float x = head - 0.08 - f * 0.07;
		vec2 q = vec2(p.x - x, p.y - (c_hash(f, seed) - 0.5) * 0.4) * vec2(6.0, 1.0);
		float glint = 0.14 * (1.0 - f * 0.25) * show - (abs(q.x) + abs(q.y));
		if (glint > 0.0 && x > 0.0) {
			color = glint > 0.05 ? C_WHITE : C_GLOW;
			a = 1.0;
		}
	}
	// L'éclat : un losange étiré, couché le long du trait.
	vec2 q = vec2(p.y, -(p.x - head) * 3.0);
	float gem = c_gem(q, 0.6 * show, 0.55);
	if (gem > -0.08 && show > 0.0) {
		a = 1.0;
		color = gem <= 0.0 ? C_RIM : (p.y < 0.0 ? C_GLOW : C_CRYSTAL);
	}
	COLOR = vec4(color, a);
}
