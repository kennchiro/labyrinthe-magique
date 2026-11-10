shader_type canvas_item;
render_mode blend_mix;

// LE DÉVOREUR : une GUEULE DE FEU géante, à crocs d'obsidienne et gorge de magma, se referme sur la proie d'un coup,
// puis des flammes débordent de la gueule close et la gueule se défait en fumée.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float shut = smoothstep(0.1, 0.35, t);
	float gone = 1.0 - smoothstep(0.75, 1.0, t);
	float gap = mix(0.55, 0.0, shut);
	for (int side = 0; side < 2; side++) {
		float sgn = side == 0 ? -1.0 : 1.0;
		vec2 q = vec2(p.x, (p.y - sgn * gap) * sgn);
		// La mâchoire : un croissant de magma cerné.
		float jaw = min(0.85 - length(vec2(q.x, q.y * 2.0 - 0.5)), q.y - 0.02) * gone;
		if (jaw > -0.03) {
			color = jaw <= 0.0 ? P_OBSIDIAN : (jaw > 0.25 ? P_BLOOD : P_MAGMA);
			a = 1.0;
		}
		// Les crocs.
		for (int i = 0; i < 6; i++) {
			float f = float(i);
			float x = (f / 5.0 - 0.5) * 1.1;
			float fang = p_shard(vec2(q.x - x, q.y - 0.02), 0.07, 0.2) * gone;
			if (fang > -0.15 && q.y > -0.2 && q.y < 0.22) {
				color = fang <= 0.0 ? P_OBSIDIAN : P_CORE;
				a = 1.0;
			}
		}
	}
	// Les flammes qui débordent quand elle se ferme.
	float spill = smoothstep(0.35, 0.5, t) * (1.0 - smoothstep(0.7, 0.95, t));
	for (int i = 0; i < 5; i++) {
		float f = float(i);
		vec3 c = color;
		if (spill > 0.02 && p_paint_tongue(p - vec2((f / 4.0 - 0.5) * 1.2, -0.05), 0.1, 0.5 * spill, c)) {
			color = c;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
