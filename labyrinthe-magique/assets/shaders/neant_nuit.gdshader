shader_type canvas_item;
render_mode blend_mix;

// LA NUIT DE L'ÉCLIPSE, posée sur le sol de tout l'écran, SOUS les personnages : il fait noir d'un coup,
// d'un noir violacé, avec une lueur violette qui bat lentement autour de lui.

#include "res://assets/shaders/neant.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float dark = smoothstep(0.0, 0.05, t) * (1.0 - smoothstep(0.9, 1.0, t));
	float halo = (1.0 - smoothstep(0.02, 0.12, d)) * (0.5 + 0.5 * sin(TIME * 2.0));
	vec3 color = mix(N_VOID, N_DEEP, halo * 0.6);
	COLOR = vec4(color, dark * mix(0.72, 0.35, halo));
}
