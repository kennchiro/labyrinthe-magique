shader_type canvas_item;
render_mode blend_mix;

// UNE ÂME GARDIENNE part de lui et frappe ce qui l'a approché : une âme pâle à traînée rouge. x de lui vers sa cible.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float x = UV.x;
	float y = (UV.y - 0.5) * 2.0;
	float t = progress;
	float head = smoothstep(0.0, 0.7, t);
	vec4 color = vec4(0.0);
	float trail = step(x, head) * smoothstep(head - 0.5, head, x) * f_glow(abs(y), 0.35);
	color = f_over(vec4(F_EMBER, trail * (1.0 - t)), color);
	color = f_over(f_soul(vec2((x - head) * 3.0, y), 0.45, vec2(-1.0, 0.0), 1.0 - smoothstep(0.75, 1.0, t)), color);
	COLOR = color;
}
