shader_type canvas_item;
render_mode blend_mix;

// LE SAUT DE L'ÉPIDÉMIE : un trait de venin file d'un malade à l'autre, gonflé de gouttes, et laisse derrière lui
// un filet qui s'égoutte. Quad étiré, x le long du saut.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	float x = UV.x;
	float y = (UV.y - 0.5) * 2.0;
	vec3 color = F_VENOM;
	float a = 0.0;
	float head = clamp(t * 2.6, 0.0, 1.0);
	float tail = clamp(t * 2.6 - 0.9, 0.0, 1.0);
	float lit = step(tail, x) * step(x, head);
	// Le filet : épais près de la tête, fin vers la queue, qui ondule.
	float k = clamp((x - tail) / max(0.01, head - tail), 0.0, 1.0);
	float w = 0.08 + 0.32 * k;
	float wave = y + sin(x * 25.0 + seed * 9.0) * 0.12 * (1.0 - k);
	float v = w - abs(wave);
	if (lit > 0.0 && v > -0.06) {
		color = v <= 0.0 ? F_RIM : (v > w * 0.6 ? F_CORE : (v > w * 0.3 ? F_BRIGHT : F_VENOM));
		a = 1.0;
	}
	// La tête : une grosse goutte qui file.
	vec2 q = vec2((x - head) * 7.0, y);
	vec3 drop = color;
	if (head < 1.0 && f_paint_drop(vec2(q.y, -q.x), 0.42, drop)) {
		color = drop;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
