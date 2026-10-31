shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE LA FOUDRE : une étoile de fissures électriques, qui claque et disparaît d'un coup.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float flick = step(0.5, fract(progress * 9.0));
	float branches = 6.0;
	float sector = floor((a + PI) / TAU * branches);
	float bend = (texture(noise, vec2(d * 0.5 + sector * 0.31, seed + floor(progress * 10.0) * 0.1)).r - 0.5) * 0.46;
	float mid = (sector + 0.5) / branches * TAU - PI + bend;
	float line = d * abs(sin(a - mid));
	float reach = 0.95 * smoothstep(0.0, 0.3, progress);
	float bolt = (0.035 * (1.0 - d) + 0.008 - line) * step(d, reach);
	float core = 0.2 * (1.0 - progress) - d;
	float heat = max(bolt, core);
	vec3 color = mix(vec3(0.25, 0.36, 1.0), vec3(1.0, 1.0, 0.86), smoothstep(0.004, 0.012, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.004, heat) * (0.8 + 0.2 * flick) * (1.0 - step(0.86, progress)) * COLOR.a);
}
