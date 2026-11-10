shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT DE L'ÉTOILE, son passage : une traînée de lumière droite qui parcourt le couloir et s'éteint par
// l'arrière. x du départ vers l'arrivée.

#include "res://assets/shaders/aurore.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float x = UV.x;
	float y = abs(UV.y - 0.5) * 2.0;
	float t = progress;
	float head = smoothstep(0.0, 0.35, t);
	float tail = smoothstep(0.3, 1.0, t);
	float on = step(x, head) * step(tail, x);
	vec4 color = a_beam(y, 0.55 * (0.4 + 0.6 * smoothstep(tail, head, x)), on);
	float spark = step(0.93, texture(noise, vec2(x * 4.0 - TIME * 2.0, UV.y * 3.0 + seed)).r) * on;
	color = a_over(vec4(A_WHITE, spark * step(y, 0.9)), color);
	COLOR = color;
}
