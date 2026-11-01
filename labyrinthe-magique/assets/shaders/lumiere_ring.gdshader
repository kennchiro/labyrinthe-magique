shader_type canvas_item;
render_mode blend_mix;

// LE PIED D'UNE COLONNE, et les ailes qui cèdent : un anneau d'or qui s'élargit au sol, vu de
// biais, avec quatre petits rayons et une lueur courte au centre.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);
const vec3 RIM = vec3(0.29, 0.184, 0.071);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 q = vec2(p.x, p.y * 2.0);
	float d = length(q);
	float grown = 0.82 * (1.0 - pow(1.0 - progress, 3.0));
	float width = 0.03 * (1.0 - progress) + 0.006;
	float ring = width - abs(d - grown);
	float glow = 0.26 * (1.0 - smoothstep(0.0, 0.45, progress)) - d;
	float heat = max(ring, glow);
	vec3 color = mix(GOLD, SHINE, smoothstep(0.0, 0.03, heat));
	color = mix(color, vec3(1.0), smoothstep(0.06, 0.14, glow));
	float rim = step(0.0001, width + 0.012 - abs(d - grown)) * (1.0 - step(0.0, heat));
	color = mix(color, RIM, rim);
	float alpha = max(smoothstep(0.0, 0.006, heat), rim * 0.8);
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.65, 1.0, progress)) * COLOR.a);
}
