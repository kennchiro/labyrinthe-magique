shader_type canvas_item;
render_mode blend_mix;

// L'ABÎME : un GOUFFRE NOIR s'ouvre sous l'écran autour de lui, cerclé de flammes froides et d'une chaîne qui tourne,
// avec un trou de serrure lumineux tout au fond. Le gouffre est creux : on voit le sol sous les ennemis, assombri. À
// la fin, il se referme vers le centre.

#include "res://assets/shaders/abime.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float open = smoothstep(0.0, 0.12, t);
	float close = smoothstep(0.86, 1.0, t);
	float r = 0.62 * open * (1.0 - close);
	vec2 g = p * vec2(1.0, 1.25);
	float d = length(g);
	float ang = atan(g.y, g.x);
	// Le fond : un noir d'abîme qui tourne en spirale, translucide.
	if (d < r) {
		float swirl = texture(noise, vec2(ang / TAU * 3.0 + TIME * 0.05, d * 2.0 - TIME * 0.2) + seed).r;
		// Un voile sombre, plus léger au centre : on doit toujours lire les couloirs et les ennemis.
		color = mix(A_VOID, A_DEEP, step(0.7, swirl) * 0.5);
		a = mix(0.22, 0.46, smoothstep(0.0, r, d));
		float hole = a_keyhole(g, 0.12 * open);
		if (hole > 0.0) {
			color = A_PALE;
			a = 0.9;
		} else if (hole > -0.03) {
			color = A_CYAN;
			a = 0.85;
		}
	}
	// La chaîne qui fait le tour du bord, en tournant.
	vec2 rg = a_rot(g, TIME * 0.25);
	float rang = atan(rg.y, rg.x);
	float n = 28.0;
	float k = floor(rang * n / TAU + 0.5);
	float at_ang = k * TAU / n;
	vec2 c = vec2(cos(at_ang), sin(at_ang)) * r;
	vec2 q = a_rot(rg - c, -at_ang - 1.5708);
	vec3 col = color;
	if (r > 0.05 && a_paint_link(mod(k, 2.0) > 0.5 ? vec2(q.x, q.y * 2.0) : q, 0.09, 0.05, col)) {
		color = col;
		a = 1.0;
	}
	// Les flammes froides du bord, vers l'extérieur.
	float tongue = (0.1 + 0.06 * sin(ang * 13.0 + TIME * 7.0 + seed)) - (d - r - 0.03);
	if (r > 0.05 && d > r + 0.03 && tongue > 0.0) {
		color = tongue > 0.07 ? A_PALE : A_CYAN;
		a = 0.95;
	}
	COLOR = vec4(color, a);
}
