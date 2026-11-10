shader_type canvas_item;
render_mode blend_mix;

// L'EMPIRE DES CENDRES : l'écran se voile de cendre brune, des cendres tombent en biais sur toute la salle, et une
// IMMENSE COURONNE DE LAVE ET D'OR descend du haut du ciel puis s'abat d'un coup, dans un éclair. Le voile reste clair
// au centre pour qu'on voie les couloirs, et la couronne reste haute : elle ne couvre jamais le héros.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float show = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.9, 1.0, t));
	float edge = max(abs(p.x), abs(p.y));
	vec3 color = mix(E_DEEP * 0.5, E_BLACK, smoothstep(0.3, 1.0, edge));
	float a = (0.18 + smoothstep(0.35, 1.0, edge) * 0.36) * show;
	float drift = texture(noise, p * 0.7 + vec2(TIME * 0.02, -TIME * 0.03) + seed).r;
	if (drift > 0.63) {
		color = mix(color, E_ASH, 0.5);
		a = max(a, 0.26 * show);
	}
	// Les cendres qui tombent en biais.
	vec2 r = vec2(p.x - p.y * 0.3, p.y) * vec2(34.0, 4.0);
	float col = floor(r.x);
	float fall = fract(r.y * 0.25 - TIME * (0.5 + e_hash(col, 3.0) * 0.5) + e_hash(col, 7.0));
	float flake = step(0.82, e_hash(col, 11.0)) * step(abs(fract(r.x) - 0.5), 0.18) * step(fall, 0.04);
	if (flake > 0.0) {
		color = e_hash(col, 13.0) > 0.7 ? E_EMBER : E_ASH_LIGHT;
		a = max(a, 0.85 * show);
	}
	// La couronne : elle descend, puis s'abat en un éclair.
	float fallk = smoothstep(0.02, 0.2, t);
	float slam = smoothstep(0.2, 0.24, t);
	float gone = 1.0 - smoothstep(0.32, 0.42, t);
	vec2 c = vec2(0.0, mix(-0.5, -0.2, fallk) + slam * 0.04);
	vec2 q = (p - c) / (0.11 * (1.0 + slam * 0.15));
	float band = min(0.28 - abs(q.y - 0.25), 1.0 - abs(q.x));
	float sector = fract((q.x + 1.0) * 2.5) - 0.5;
	float point = min(1.0 - abs(q.x), (0.9 - abs(sector) * 1.6) - (-q.y + 0.1));
	point = min(point, q.y < 0.05 ? 1.0 : -1.0);
	float crown = max(band, point);
	if (crown > -0.08 && gone > 0.0) {
		vec3 cc = crown <= 0.0 ? E_BLACK : (crown > 0.16 ? E_GOLD : E_EMBER);
		if (band > 0.0 && abs(q.y - 0.25 + sin(q.x * 9.0) * 0.06) < 0.05) {
			cc = E_LAVA;
		}
		color = mix(color, cc, gone);
		a = max(a, gone * show);
	}
	float flash = slam * gone * (1.0 - smoothstep(0.24, 0.32, t));
	if (flash > 0.0 && length((p - c) * vec2(1.0, 2.0)) < 0.5 * flash) {
		color = E_PALE;
		a = max(a, flash);
	}
	COLOR = vec4(color, a);
}
