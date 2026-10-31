shader_type canvas_item;
render_mode blend_mix;

// LE DARD DE FOUDRE : un trait brisé qui change de forme à chaque image, jamais courbe.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float x = UV.x;
	float step_t = floor(TIME * 24.0);
	float seg = floor(x * 7.0);
	float n0 = texture(noise, vec2(seg * 0.137, step_t * 0.073 + seed)).r - 0.5;
	float n1 = texture(noise, vec2((seg + 1.0) * 0.137, step_t * 0.073 + seed)).r - 0.5;
	float line = mix(n0, n1, fract(x * 7.0)) * 0.72 * (1.0 - smoothstep(0.82, 1.0, x));
	float y = abs(UV.y - 0.5 - line * 0.5) * 2.0;
	float core = 0.13 * smoothstep(0.0, 0.2, x) - y;
	float halo = 0.34 * smoothstep(0.0, 0.3, x) - y;
	vec3 color = mix(vec3(0.3, 0.42, 1.0), vec3(1.0, 1.0, 0.9), smoothstep(0.0, 0.03, core));
	COLOR = vec4(color, max(smoothstep(0.0, 0.03, core), smoothstep(0.0, 0.3, halo) * 0.55) * COLOR.a);
}
