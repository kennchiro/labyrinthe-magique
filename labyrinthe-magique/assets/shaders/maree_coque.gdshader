shader_type canvas_item;
render_mode blend_mix;

// MARÉE HAUTE : une bulle d'eau douce l'enveloppe comme une aura. Pas de contour dur (le joueur
// n'aimait pas le cercle, 2026-11-07) : un bord qui s'éclaircit en douceur, des reflets d'eau qui
// glissent lentement, un éclat d'écume en haut. Elle respire, et reste claire au centre pour qu'on
// voie le mage. Ovale, plus haute que large, comme son corps.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 FOAM = vec3(0.914, 1.0, 1.0);
const vec3 TEAL = vec3(0.329, 0.918, 0.859);
const vec3 BLUE = vec3(0.216, 0.776, 1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.18;
	float breath = 1.0 + 0.035 * sin(TIME * 2.2 + seed * 6.0);
	float appear = smoothstep(0.0, 0.006, progress);
	float d = length(p) / (0.8 * breath * appear + 0.0001);
	float angle = atan(p.y, p.x);
	// Le voile : presque transparent au centre, plus dense vers le bord, qui s'efface au-delà.
	float shell = smoothstep(0.35, 0.97, d) * (1.0 - smoothstep(0.97, 1.08, d));
	// Les reflets d'eau qui glissent en tournant.
	float caustic = 0.5 + 0.5 * sin(angle * 3.0 + d * 7.0 - TIME * 1.6 + seed * 4.0);
	caustic *= 0.5 + 0.5 * sin(angle * 5.0 - d * 5.0 + TIME * 1.1);
	vec3 color = mix(BLUE, TEAL, caustic);
	color = mix(color, FOAM, smoothstep(0.82, 1.0, d) * 0.6);
	float a = shell * (0.28 + 0.32 * caustic);
	// L'éclat d'écume en haut à gauche, doux lui aussi.
	vec2 g = p - vec2(-0.3, -0.42) * breath;
	float glint = 1.0 - smoothstep(0.0, 0.16, length(g * vec2(1.0, 1.6)));
	color = mix(color, FOAM, glint);
	a = max(a, glint * 0.75);
	COLOR = vec4(color, a * appear);
}
