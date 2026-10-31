shader_type canvas_item;
render_mode blend_mix;

// LE CERCLE D'EAU : une mare calme, ses ondes concentriques qui partent du centre.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float n = texture(noise, p * 0.3 + seed + TIME * 0.02).r - 0.5;
	float rim = 0.88 - d + n * 0.08;
	float rings = sin((d + n * 0.1) * 26.0 - TIME * 3.4);
	vec3 color = mix(vec3(0.04, 0.3, 0.62), vec3(0.12, 0.56, 0.86), smoothstep(0.0, 0.6, n + 0.2));
	color = mix(color, vec3(0.74, 0.96, 1.0), smoothstep(0.82, 0.96, rings));
	color = mix(color, vec3(0.95, 1.0, 1.0), smoothstep(0.06, 0.0, rim));
	COLOR = vec4(color, smoothstep(0.0, 0.03, rim) * 0.76 * COLOR.a);
}
