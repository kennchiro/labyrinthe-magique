shader_type canvas_item;
render_mode blend_mix;

// L'EXTRA DE LA FOUDRE : deux éclairs croisés qui s'impriment dans le ciel, tenus un instant.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	// Chaque branche se casse en zigzag autour de sa diagonale, sans jamais se couper.
	float zig = (abs(fract(d * 3.2 + seed) - 0.5) - 0.25) * 0.26;
	float ax = abs(p.x * 0.707 + p.y * 0.707 + zig);
	float ay = abs(p.x * 0.707 - p.y * 0.707 + zig);
	float width = 0.055 * sin(min(progress * 2.4, 1.0) * PI * 0.5) * (1.0 - d * 0.55);
	float bolts = (width - min(ax, ay)) * step(d, 0.84);
	float ring = 0.012 - abs(d - 0.86);
	float heat = max(bolts, ring);
	vec3 color = mix(vec3(0.34, 0.46, 1.0), vec3(1.0, 1.0, 0.86), smoothstep(0.0, 0.03, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.006, heat) * (1.0 - smoothstep(0.65, 1.0, progress)) * COLOR.a);
}
