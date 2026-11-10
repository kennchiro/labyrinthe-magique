shader_type canvas_item;
render_mode blend_mix;

// LA GENÈSE : le ciel vire à la nuit étoilée, un immense anneau d'or aux quatre runes tourne au-dessus de lui ; ses
// runes s'allument au rythme des météores. Au moment de la nova (`nova_at`, en part de sa vie), l'anneau se resserre
// en un point blanc, puis tout s'éclaire.

#include "res://assets/shaders/primordial.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;
uniform float nova_at = 0.85;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float rise = smoothstep(0.0, 0.08, t);
	float collapse = smoothstep(nova_at - 0.06, nova_at, t);
	float after = smoothstep(nova_at, 1.0, t);
	// La nuit : un voile bleu nuit, plus dense sur les bords, qui laisse voir le jeu.
	float edge = smoothstep(0.2, 1.0, length(p));
	vec4 color = vec4(P_NIGHT, (0.32 + 0.3 * edge) * rise * (1.0 - after));
	// Les étoiles, qui scintillent.
	vec2 cell = floor(UV * 46.0);
	float star = p_hash(cell.x, cell.y + seed * 10.0);
	vec2 inside_cell = fract(UV * 46.0) - 0.5;
	float twinkle = 0.5 + 0.5 * sin(TIME * 3.0 + star * 40.0);
	float dot_star = step(0.93, star) * p_glow(length(inside_cell), 0.18) * twinkle;
	color = p_over(vec4(P_GOLD_LIGHT, dot_star * rise * (1.0 - after)), color);
	// L'anneau, au-dessus de lui, qui tourne ; ses runes à tour de rôle.
	vec2 r = (p - vec2(0.0, -0.25)) * vec2(1.0, 1.25);
	float k = floor(TIME * 3.0);
	vec4 lit = vec4(mod(k, 4.0) < 0.5 ? 1.0 : 0.3, abs(mod(k, 4.0) - 1.0) < 0.5 ? 1.0 : 0.3,
		abs(mod(k, 4.0) - 2.0) < 0.5 ? 1.0 : 0.3, abs(mod(k, 4.0) - 3.0) < 0.5 ? 1.0 : 0.3);
	float radius = mix(0.21, 0.02, collapse) * smoothstep(0.0, 0.15, t);
	vec4 ring = p_ring(r, radius, 0.016, TIME * 0.5, lit);
	ring.a *= rise * (1.0 - collapse);
	color = p_over(ring, color);
	// Le point blanc de l'origine.
	float point = p_glow(length(r), 0.06 + 0.2 * collapse) * collapse * (1.0 - after);
	color = p_over(vec4(P_WHITE, point), color);
	// Le blanc qui recouvre l'écran, puis s'efface.
	float white = smoothstep(nova_at, nova_at + 0.03, t) * (1.0 - after);
	color = p_over(vec4(P_GOLD_LIGHT, white * 0.55), color);
	COLOR = color;
}
