shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE LA TERRE : le sol se fend en étoile et des éclats de pierre sautent.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float sector = floor((a + PI) / TAU * 7.0);
	float bend = (texture(noise, vec2(d * 0.4, sector * 0.21 + seed)).r - 0.5) * 0.5;
	float mid = (sector + 0.5) / 7.0 * TAU - PI + bend;
	float line = d * abs(sin(a - mid));
	float reach = smoothstep(0.0, 0.35, progress) * 0.9;
	float crack = (0.03 * (1.0 - d) + 0.006 - line) * step(d, reach);
	float at = progress * 0.72;
	float chip = (0.1 * (1.0 - progress)) - abs(fract((a + seed) / TAU * 9.0) - 0.5) * d * 0.8 - abs(d - at);
	vec3 color = mix(vec3(0.14, 0.09, 0.06), vec3(0.62, 0.48, 0.32), step(0.0, chip));
	COLOR = vec4(color, max(smoothstep(0.0, 0.006, crack), smoothstep(0.0, 0.01, chip)) * (1.0 - smoothstep(0.72, 1.0, progress)) * COLOR.a);
}
