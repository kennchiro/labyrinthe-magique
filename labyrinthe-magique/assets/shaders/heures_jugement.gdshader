shader_type canvas_item;
render_mode blend_mix;

// LE JUGEMENT DES HEURES : une horloge géante couvre l'écran, le temps s'arrête. Sa face sarcelle reste assez
// claire pour qu'on voie les couloirs. Les deux aiguilles avancent vers midi pendant toute la durée, les heures
// s'allument à leur passage, un cadran intérieur tourne à l'envers. À midi : un éclair d'or, puis tout cède.

#include "res://assets/shaders/heures.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float d = length(p);
	float open = 1.0 - pow(1.0 - clamp(t / 0.07, 0.0, 1.0), 3.0);
	float reach = 0.92 * open;
	vec3 color = H_DEEP;
	float a = 0.0;
	float inside = (d > reach + 0.02 || reach <= 0.0) ? 0.0 : 1.0;
	// La face : un voile sarcelle, plus dense au bord.
	color = mix(H_DEEP, H_TEAL, d / max(0.01, reach));
	a = 0.12 + smoothstep(0.6, 1.0, d / max(0.01, reach)) * 0.16;
	// La minute avance de trois quarts de tour jusqu'à midi ; l'heure, d'un quart.
	float minute = -1.5708 - (1.0 - t) * TAU * 0.75;
	float hour = -1.5708 - (1.0 - t) * TAU * 0.25;
	// Les heures que la minute a déjà passées s'allument.
	float ang = atan(p.y, p.x);
	float behind = mod(minute - ang, TAU);
	float passed = (1.0 - t) * TAU * 0.75;
	float swept = TAU * 0.75 - passed;
	if (d < reach * 0.82 && d > reach * 0.3 && mod(ang - (minute - swept), TAU) < swept) {
		color = mix(color, H_BRIGHT, 0.25);
		a = max(a, 0.2);
	}
	// La traîne lumineuse de la minute.
	if (d < reach * 0.84 && behind < 0.5) {
		color = mix(color, H_PALE, (0.5 - behind) * 0.9);
		a = max(a, (0.5 - behind) * 0.7);
	}
	// Le grand cadran d'or, et l'intérieur qui tourne à l'envers.
	vec3 dial = color;
	if (h_dial(p, reach - 0.05, 0.05, 0.0, dial)) {
		color = dial;
		a = 0.95;
	}
	if (h_dial(p, reach * 0.42, 0.025, t * 3.0, dial)) {
		color = dial;
		a = 0.7;
	}
	// Les chiffres : un pavé d'or par heure, plus grand aux quarts.
	float slot = floor(ang / TAU * 12.0 + 0.5);
	float mid = slot / 12.0 * TAU;
	vec2 q = h_rot(p, -mid) - vec2(reach * 0.76, 0.0);
	bool quarter = mod(slot, 3.0) < 0.5;
	vec2 size = quarter ? vec2(0.05, 0.045) : vec2(0.03, 0.025);
	vec2 box = abs(q) - size;
	float numeral = -(length(max(box, 0.0)) + min(max(box.x, box.y), 0.0));
	if (numeral > -0.008) {
		bool lit = mod(mid - (minute - swept), TAU) < swept + 0.01;
		color = numeral <= 0.0 ? H_RIM : (lit ? H_LIGHT : H_COPPER);
		a = 0.95;
	}
	// Les fissures de lumière dans la face.
	float crack_noise = texture(noise, p * 1.1 + seed).r;
	if (smoothstep(0.012, 0.004, abs(crack_noise - 0.5)) > 0.5 && d < reach * 0.95) {
		color = H_PALE;
		a = max(a, 0.4);
	}
	// Les aiguilles.
	float hand = h_hand(p, minute, reach * 0.8, 0.03);
	if (h_paint_hand(hand, 0.03, color)) {
		a = 1.0;
	}
	hand = h_hand(p, hour, reach * 0.52, 0.04);
	if (h_paint_hand(hand, 0.04, color)) {
		a = 1.0;
	}
	if (d < 0.045) {
		color = d > 0.03 ? H_RIM : H_LIGHT;
		a = 1.0;
	}
	// Midi : l'éclair d'or, puis les plaques cèdent.
	float noon = smoothstep(0.94, 0.975, t);
	color = mix(color, H_LIGHT, noon * 0.8);
	a = mix(a, max(a, 0.55), noon);
	float gone = step(crack_noise, smoothstep(0.975, 1.0, t) * 1.05);
	COLOR = vec4(color, a * (1.0 - gone) * inside);
}
