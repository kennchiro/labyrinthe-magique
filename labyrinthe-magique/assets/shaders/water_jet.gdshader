shader_type canvas_item;
render_mode blend_mix;

// LE JET D'EAU : un filet lisse qui ondule, jamais déchiré, suivi de gouttes rondes.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float x = UV.x;
	float wave = sin(x * 15.0 - TIME * 26.0 + seed * 6.0) * 0.1 * (1.0 - x);
	float y = abs(UV.y - 0.5 + wave) * 2.0;
	float width = 0.55 * smoothstep(0.32, 0.72, x) * smoothstep(1.0, 0.84, x) + 0.06 * smoothstep(0.32, 0.5, x);
	float jet = width - y;
	vec2 cell = vec2(fract(x * 4.5 + TIME * 5.0) - 0.5, (UV.y - 0.5 + sin(floor(x * 4.5 + TIME * 5.0) * 2.7) * 0.2) * 1.0);
	float drop = (0.2 - length(cell * vec2(1.0, 2.6))) * step(x, 0.42) * smoothstep(0.0, 0.2, x);
	float heat = max(jet, drop);
	vec3 color = mix(vec3(0.05, 0.36, 0.78), vec3(0.42, 0.84, 1.0), smoothstep(0.03, 0.14, heat));
	color = mix(color, vec3(0.95, 1.0, 1.0), smoothstep(0.24, 0.32, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.03, heat) * COLOR.a);
}
