shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE L'EAU : une couronne de gouttes qui part du centre et retombe.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float front = (1.0 - pow(1.0 - progress, 2.2)) * 0.74;
	float count = 11.0;
	float sector = floor((a + PI) / TAU * count);
	float mid = (sector + 0.5) / count * TAU - PI;
	float jitter = texture(noise, vec2(sector * 0.17, seed)).r;
	vec2 at = vec2(cos(mid), sin(mid)) * front * (0.7 + jitter * 0.45);
	float drop = (0.1 * (1.0 - progress) + 0.03) - length(p - at);
	float ring = 0.03 * (1.0 - progress) - abs(d - front * 0.72);
	float heat = max(drop, ring);
	vec3 color = mix(vec3(0.1, 0.5, 0.92), vec3(0.88, 0.98, 1.0), smoothstep(0.0, 0.05, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.012, heat) * (1.0 - smoothstep(0.8, 1.0, progress)) * COLOR.a);
}
