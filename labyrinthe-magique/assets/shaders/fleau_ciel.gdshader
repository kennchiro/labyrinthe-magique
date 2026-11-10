shader_type canvas_item;
render_mode blend_mix;

// LA GRANDE PESTE : le ciel vire au vert sombre sur tout l'écran, une pluie pestilente de gouttes vert acide
// tombe en biais, et au début un grand masque crâne-bec se dessine dans le ciel, ses yeux brûlants, avant de
// s'effacer. Le voile reste clair au centre pour qu'on voie les couloirs.

#include "res://assets/shaders/fleau.gdshaderinc"

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
	// Le voile : vert sombre, plus dense vers les bords.
	vec3 color = mix(F_SHADE, F_NIGHT, smoothstep(0.3, 1.0, edge));
	float a = (0.14 + smoothstep(0.35, 1.0, edge) * 0.3) * show;
	// Les nappes de miasme qui dérivent.
	float drift = texture(noise, p * 0.7 + vec2(TIME * 0.03, 0.0) + seed).r;
	if (drift > 0.6) {
		color = mix(color, F_VENOM, 0.35);
		a = max(a, 0.22 * show);
	}
	// La pluie : des traits en biais qui tombent, chacun sur sa colonne.
	vec2 r = vec2(p.x + p.y * 0.25, p.y) * vec2(28.0, 3.0);
	float col = floor(r.x);
	float fall = fract(r.y * 0.25 - TIME * (1.4 + f_hash(col, 3.0)) + f_hash(col, 7.0));
	float streak = step(0.82, f_hash(col, 11.0)) * step(abs(fract(r.x) - 0.5), 0.12) * smoothstep(0.0, 0.25, fall) * step(fall, 0.3);
	if (streak > 0.0) {
		color = fall > 0.27 ? F_CORE : F_BRIGHT;
		a = max(a, 0.75 * show);
	}
	// Le masque dans le ciel, au début : une capuche pointue, deux yeux brûlants et le bec de bronze, haut dans
	// le ciel et assez petit pour ne jamais couvrir le mage (à la taille de l'écran, il l'écrasait).
	float mask_t = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.22, 0.34, t));
	vec2 m = (p - vec2(0.0, -0.3)) / 0.16;
	vec2 hq = vec2(abs(m.x), m.y);
	float hood = (m.y > -1.3 && m.y < 0.75) ? (0.8 - hq.x - max(0.0, -m.y) * 0.62) : -1.0;
	float beak = (m.y > 0.05 && m.y < 1.25) ? (0.22 * (1.0 - (m.y - 0.05) / 1.2) - abs(m.x - (m.y - 0.05) * 0.12)) : -1.0;
	float shape = max(hood, beak);
	if (mask_t > 0.0 && shape > -0.05) {
		vec3 mask_color = shape <= 0.0 ? F_RIM : (beak > hood - 0.05 && m.y > 0.05 ? F_BRONZE : F_NIGHT);
		if (hood > 0.0 && abs(hood - 0.06) < 0.05) {
			mask_color = F_VENOM;
		}
		for (int s = -1; s <= 1; s += 2) {
			float eye = length(m - vec2(float(s) * 0.26, -0.12));
			if (eye < 0.15) {
				mask_color = eye < 0.08 ? F_CORE : F_BRIGHT;
			}
		}
		color = mix(color, mask_color, mask_t);
		a = max(a, 0.75 * mask_t);
	}
	COLOR = vec4(color, a);
}
