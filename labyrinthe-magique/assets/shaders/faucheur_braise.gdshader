shader_type canvas_item;
render_mode blend_mix;

// LE PAS DE L'OMBRE, son passage : une ligne de braise relie le départ à l'arrivée, par-dessus les haies, puis
// s'éteint en cendres. x du départ vers l'arrivée.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float t = progress;
	float drawn = step(x, smoothstep(0.0, 0.25, t));
	float width = 0.3 * (1.0 - smoothstep(0.4, 1.0, t));
	float line = smoothstep(width, width * 0.4, y) * drawn;
	float ash = step(0.85, texture(noise, vec2(x * 4.0 + seed, UV.y * 3.0 - TIME)).r) * smoothstep(0.4, 1.0, t) * step(y, 0.8);
	vec4 color = vec4(mix(F_EMBER, F_CORE, smoothstep(width * 0.6, 0.0, y)), line);
	color = f_over(vec4(F_ASH, ash * (1.0 - t)), color);
	COLOR = color;
}
