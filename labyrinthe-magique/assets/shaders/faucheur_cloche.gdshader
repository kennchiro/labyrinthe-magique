shader_type canvas_item;
render_mode blend_mix;

// LE GLAS FUNÈBRE : une cloche spectrale, noire à liseré d'os, au-dessus de lui ; elle se balance à chaque coup.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

uniform float tolls = 3.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float life = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.88, 1.0, t));
	float swing = sin(t * tolls * TAU) * 0.25 * (1.0 - t);
	vec2 q = p - vec2(0.0, -0.55);
	q = mat2(vec2(cos(swing), sin(swing)), vec2(-sin(swing), cos(swing))) * (q - vec2(0.0, -0.25)) + vec2(0.0, -0.25);
	// La robe de la cloche : plus large en bas.
	float half_w = mix(0.14, 0.32, smoothstep(-0.25, 0.25, q.y));
	float body = step(abs(q.x), half_w) * step(-0.25, q.y) * step(q.y, 0.25);
	float dome = smoothstep(0.15, 0.14, length(q - vec2(0.0, -0.25)));
	float bell = max(body, dome);
	float rim = bell - step(abs(q.x), half_w - 0.03) * step(-0.22, q.y) * step(q.y, 0.22) * (1.0 - dome * 0.0);
	vec4 color = vec4(F_BLACK, bell * 0.92 * life);
	color = f_over(vec4(F_BONE, clamp(rim, 0.0, 1.0) * life), color);
	float clapper = smoothstep(0.06, 0.05, length(q - vec2(0.0, 0.3)));
	color = f_over(vec4(F_EMBER, clapper * life), color);
	COLOR = color;
}
