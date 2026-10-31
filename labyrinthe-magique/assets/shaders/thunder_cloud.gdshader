shader_type canvas_item;
render_mode blend_mix;

// LE NUAGE DU JUGEMENT : une masse sombre qui bouillonne, zébrée d'éclairs de l'intérieur.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float n = texture(noise, p * vec2(0.35, 0.5) + vec2(TIME * 0.05, seed)).r;
	float m = texture(noise, p * 0.8 + vec2(-TIME * 0.09, seed * 0.3)).r;
	float body = 0.85 - length(p * vec2(1.0, 1.75)) + (n - 0.5) * 0.65;
	vec3 color = mix(vec3(0.07, 0.08, 0.17), vec3(0.3, 0.32, 0.5), smoothstep(0.34, 0.72, m - p.y * 0.3));
	float flash = step(0.9, texture(noise, vec2(floor(TIME * 7.0) * 0.137, seed)).r);
	float vein = smoothstep(0.03, 0.0, abs(m - 0.5)) * flash;
	color = mix(color, vec3(0.9, 0.95, 1.0), vein);
	COLOR = vec4(color, smoothstep(0.0, 0.08, body) * 0.94 * COLOR.a);
}
