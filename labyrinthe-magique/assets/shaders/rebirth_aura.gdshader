shader_type canvas_item;
render_mode blend_mix;

// LA RENAISSANCE : la vie repousse. Des ondes d'or et de vert au sol, une lumière qui monte, des feuilles qui s'élèvent.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = TIME + seed * 5.0;
	// Le sol, en plongée : des ondes qui partent des pieds.
	vec2 g = (p - vec2(0.0, 0.72)) / vec2(0.82, 0.24);
	float gd = length(g);
	float ripple = smoothstep(0.55, 0.95, sin(gd * 15.0 - t * 4.2)) * smoothstep(1.05, 0.8, gd);
	vec3 color = mix(vec3(0.46, 0.84, 0.2), vec3(1.0, 0.92, 0.42), ripple);
	float alpha = ripple * 0.9;
	// La lumière qui monte, toute en filets.
	float f = fbm(vec2(p.x * 0.42 + seed, p.y * 0.22 + t * 0.34));
	float beam = (0.56 - abs(p.x) * (1.0 + (p.y + 1.0) * 0.1)) * 1.3 + (f - 0.5) * 1.2;
	float up = smoothstep(-0.95, 0.5, p.y) * smoothstep(0.86, 0.6, p.y);
	float light = smoothstep(0.0, 0.5, beam) * up;
	if (light * 0.56 > alpha) {
		color = mix(vec3(0.62, 0.9, 0.3), vec3(1.0, 0.98, 0.72), smoothstep(0.2, 0.75, beam));
		alpha = light * 0.56;
	}
	// LES FEUILLES : chacune suit sa colonne, monte en oscillant et disparaît en haut.
	for (int i = 0; i < 7; i++) {
		float k = float(i);
		float rise = fract(t * (0.16 + k * 0.017) + k * 0.37);
		vec2 at = vec2(sin(k * 2.4) * 0.66 + sin(t * 1.6 + k) * 0.08, 0.64 - rise * 1.6);
		vec2 q = p - at;
		float turn = k + t * 1.3;
		q = mat2(vec2(cos(turn), sin(turn)), vec2(-sin(turn), cos(turn))) * q;
		float leaf = 0.07 * (1.0 - smoothstep(0.0, 0.09, abs(q.x)) * 0.98) - abs(q.y);
		if (leaf > 0.0 && abs(q.x) < 0.09) {
			color = mix(vec3(0.3, 0.72, 0.14), vec3(0.76, 1.0, 0.34), step(0.0, q.y));
			alpha = smoothstep(1.0, 0.7, rise);
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
