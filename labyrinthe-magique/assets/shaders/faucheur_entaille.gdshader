shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DU CROISSANT, ou d'une âme gardienne : deux entailles rouges en croix, qui laissent une braise.

#include "res://assets/shaders/faucheur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec4 color = vec4(0.0);
	float reach = smoothstep(0.0, 0.25, t);
	for (int k = 0; k < 2; k++) {
		float a = (k == 0 ? 0.6 : -0.6) + seed;
		vec2 dir = vec2(cos(a), sin(a));
		float along = dot(p, dir);
		float across = abs(dot(p, vec2(-dir.y, dir.x)));
		float width = 0.09 * (1.0 - abs(along) / 0.9) * (1.0 - t);
		float cut = step(across, width) * step(abs(along), 0.9 * reach);
		color = f_over(vec4(mix(F_EMBER, F_CORE, step(across, width * 0.4)), cut), color);
	}
	color = f_over(vec4(F_EMBER, f_glow(length(p), 0.5) * (1.0 - t) * 0.5), color);
	COLOR = color;
}
