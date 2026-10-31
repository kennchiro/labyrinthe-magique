shader_type canvas_item;
render_mode blend_mix;

// LE BOUCLIER D'EAU : une bulle tendue, sa surface parcourue de reflets qui glissent.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float n = texture(noise, p * 0.45 + vec2(TIME * 0.09, -TIME * 0.06) + seed).r - 0.5;
	float shell = smoothstep(0.92, 0.86, d + n * 0.05);
	float rim = shell * smoothstep(0.62, 0.86, d);
	float shine = smoothstep(0.32, 0.26, length(p - vec2(-0.34, -0.42)));
	vec3 color = mix(vec3(0.14, 0.58, 0.96), vec3(0.86, 0.98, 1.0), max(rim * 0.8, shine));
	COLOR = vec4(color, max(shell * 0.16, max(rim * 0.82, shine * 0.75)) * COLOR.a);
}
