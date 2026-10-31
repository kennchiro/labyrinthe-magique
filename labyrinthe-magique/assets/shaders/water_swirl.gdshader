shader_type canvas_item;
render_mode blend_mix;

// LE COURANT : l'eau tourbillonne et avale le mage, en spirale.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float spin = a + d * 7.0 - progress * 9.0 + seed;
	float arms = 0.5 + 0.5 * cos(spin * 3.0);
	float rim = (0.86 - d) * (1.0 - progress);
	float heat = arms - 0.62 + rim * 0.5;
	vec3 color = mix(vec3(0.05, 0.38, 0.8), vec3(0.7, 0.96, 1.0), smoothstep(0.05, 0.28, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.06, heat) * step(d, 0.92) * (1.0 - smoothstep(0.7, 1.0, progress)) * COLOR.a);
}
