shader_type canvas_item;
render_mode blend_mix;

// LA CATHÉDRALE DE LUMIÈRE : un cercle d'or au sol avec une rosace de vitrail en étoile à huit branches, et des colonnes
// de lumière tout autour de son bord. Elle se trace en un tour, et se referme depuis l'extérieur à la fin.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float radius_tiles = 3.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const float EDGE = 0.8;
const float COLUMNS = 10.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float drawn = clamp(phase / 0.4, 0.0, 1.0);
	float swept = step(fract((a + PI) / TAU), drawn);
	float close = smoothstep(0.12, 0.0, life);
	float reach = EDGE * (1.0 - close);
	vec4 color = vec4(0.0);
	// Le voile de lumière, et la rosace.
	color = a_over(vec4(A_GOLD_LIGHT, 0.14 * step(d, reach) * drawn), color);
	vec4 rosace = a_star_paint(p, reach * 0.62, phase * 0.15, 0.35 * drawn);
	color = a_over(rosace, color);
	float lead = smoothstep(0.012, 0.0, abs(d - reach * 0.35)) * drawn;
	color = a_over(vec4(A_GOLD, lead * 0.6), color);
	// Le cercle d'or.
	float rim = smoothstep(0.03, 0.0, abs(d - reach)) * swept;
	color = a_over(vec4(mix(A_GOLD, A_RIM, 0.2), rim), color);
	// Les colonnes : des pieds de lumière sur le bord, qui battent.
	float slot = fract((a + PI) / TAU * COLUMNS + seed);
	float column = smoothstep(0.08, 0.0, abs(slot - 0.5) / COLUMNS * TAU * reach) * smoothstep(reach + 0.12, reach, d)
		* step(reach - 0.06, d);
	float beat = 0.7 + 0.3 * sin(phase * 4.0 + floor((a + PI) / TAU * COLUMNS) * 1.7);
	color = a_over(vec4(A_WHITE, column * beat * drawn), color);
	// Le clignotement de la fin.
	color.a *= 1.0 - 0.5 * step(life, 0.2) * step(0.5, fract(phase * 4.0));
	COLOR = color;
}
