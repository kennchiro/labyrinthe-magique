shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE L'AIR : deux coupures nettes qui se croisent, puis plus rien.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float cut1 = abs(p.x * 0.8 + p.y * 0.6);
	float cut2 = abs(p.x * 0.6 - p.y * 0.8);
	float len1 = abs(p.x * 0.6 - p.y * 0.8);
	float len2 = abs(p.x * 0.8 + p.y * 0.6);
	float grow = smoothstep(0.0, 0.3, progress) * 0.9;
	float thin = 0.05 * (1.0 - progress);
	float s1 = (thin * (1.0 - len1 / max(grow, 0.01)) - cut1);
	float s2 = (thin * (1.0 - len2 / max(grow * 0.8, 0.01)) - cut2);
	vec3 color = mix(vec3(0.1, 0.42, 0.42), vec3(1.0), smoothstep(0.002, 0.012, max(s1, s2)));
	COLOR = vec4(color, smoothstep(0.0, 0.008, max(s1, s2)) * (1.0 - smoothstep(0.7, 1.0, progress)) * COLOR.a);
}
