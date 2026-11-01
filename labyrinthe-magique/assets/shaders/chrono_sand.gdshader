shader_type canvas_item;
render_mode blend_mix;

// LE SABLIER en cours : un anneau au sol, sous le mage, que le sable vide en tournant. Il
// dit combien de temps les coups comptent encore, et se ferme d'un éclair à la fin.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float turn = fract(atan(p.y, p.x) / TAU + 0.75);
	float left = 1.0 - progress;
	float ring = 0.055 - abs(d - 0.72);
	float grain = texture(noise, vec2(turn * 7.0 - TIME * 0.25, d * 2.0 + seed)).r;
	float full = step(turn, left);
	float heat = ring * mix(0.45, 1.0, full) - (1.0 - full) * 0.02;
	vec3 color = mix(vec3(0.72, 0.36, 0.12), vec3(0.2, 0.9, 0.78), full);
	color = mix(color, vec3(0.86, 1.0, 0.94), full * smoothstep(0.58, 0.74, grain));
	float closing = smoothstep(0.93, 1.0, progress);
	color = mix(color, vec3(1.0), closing);
	float open = smoothstep(0.0, 0.03, progress);
	COLOR = vec4(color, smoothstep(0.0, 0.012, heat) * open * 0.9 * COLOR.a);
}
