shader_type canvas_item;
render_mode blend_mix;

// LE SÉISME : une onde de sol fendu qui soulève des plaques sur son passage.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float front = (1.0 - pow(1.0 - progress, 2.0)) * 0.84;
	float n = texture(noise, p * 0.6 + seed).r;
	float band = 1.0 - abs(d - front) / (0.2 + 0.1 * (1.0 - progress));
	float plates = smoothstep(0.06, 0.1, abs(n - 0.5));
	vec3 color = mix(vec3(0.08, 0.05, 0.03), mix(vec3(0.42, 0.3, 0.2), vec3(0.68, 0.54, 0.36), n), plates);
	COLOR = vec4(color, smoothstep(0.0, 0.14, band) * (1.0 - smoothstep(0.72, 1.0, progress)) * COLOR.a);
}
