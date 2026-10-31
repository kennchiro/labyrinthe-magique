shader_type canvas_item;
render_mode blend_mix;

// LA CHUTE DU JUGEMENT : un trait d'or s'abat, le sol se fend en cercle et la poussière saute.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 g = p / vec2(1.0, 0.56);
	float d = length(g);
	float a = atan(g.y, g.x);
	float grow = 1.0 - pow(1.0 - progress, 2.5);
	float fade = 1.0 - smoothstep(0.62, 1.0, progress);
	// Les anneaux d'or au sol, irréguliers : un cratère, pas un compas.
	float n = fbm(g * 0.4 + seed) - 0.5;
	float ring = max(0.04 * fade - abs(d - grow * 0.9 + n * 0.1), 0.022 * fade - abs(d - grow * 0.55 + n * 0.08));
	// Les fissures rayonnantes.
	float sector = floor((a + PI) / TAU * 9.0);
	float mid = (sector + 0.5) / 9.0 * TAU - PI + (texture(noise, vec2(d * 0.5, sector * 0.3 + seed)).r - 0.5) * 0.5;
	float crack = (0.02 * (1.0 - d) + 0.006 - d * abs(sin(a - mid))) * step(d, grow * 0.92) * fade;
	// La poussière et les éclats projetés.
	float dust = paint_fire(vec2(d * 1.5 - progress, a * 0.5 + seed), progress * 2.0 + seed, (0.2 - abs(d - grow * 0.72) * 2.0) * fade).a;
	// Le trait de lumière : il s'affine vers le ciel et il est le premier à mourir.
	float beam = (0.24 * (1.0 - progress * 1.7) * (0.2 + (p.y + 1.0) * 0.5) - abs(p.x)) * step(p.y, 0.1);
	vec3 color = mix(vec3(0.55, 0.26, 0.08), vec3(1.0, 0.72, 0.2), step(0.0, ring));
	color = mix(color, vec3(0.13, 0.07, 0.04), step(0.0, crack));
	color = mix(color, vec3(1.0, 0.99, 0.86), smoothstep(0.0, 0.05, beam));
	float alpha = max(max(smoothstep(0.0, 0.012, ring), smoothstep(0.0, 0.006, crack)), max(dust * 0.72, smoothstep(0.0, 0.02, beam)));
	COLOR = vec4(color, alpha * COLOR.a);
}
