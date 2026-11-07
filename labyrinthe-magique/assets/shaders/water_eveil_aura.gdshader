shader_type canvas_item;
render_mode blend_mix;

// Courants rasants autour du mage éveillé : une aura d'eau au sol, jamais une coque.
uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - vec2(0.5)) * 2.0;
	float angle = atan(p.y, p.x);
	float radius = length(p);
	float n = texture(noise, p * 1.8 + vec2(TIME * 0.035, -TIME * 0.025) + seed).r;
	float flow = sin(angle * 3.0 - TIME * 1.8 + n * 2.0) * 0.035
		+ sin(angle * 7.0 + TIME * 1.2) * 0.018;
	float ring_a = 0.69 + flow;
	float ring_b = 0.84 - flow * 0.7;
	float band_a = 1.0 - smoothstep(0.035, 0.075, abs(radius - ring_a));
	float band_b = 1.0 - smoothstep(0.025, 0.06, abs(radius - ring_b));
	// Les bandes s'ouvrent par endroits : on lit des courants qui tournent, pas deux cercles fixes.
	float breaks = smoothstep(-0.55, 0.3, sin(angle * 2.0 - TIME * 1.5 + n * 3.0));
	float current = max(band_a, band_b * 0.65) * breaks;
	float foam = smoothstep(0.72, 0.88, n) * band_a;
	vec3 color = mix(vec3(0.02, 0.28, 0.62), vec3(0.13, 0.82, 0.96), band_b * 0.75 + foam * 0.25);
	color = mix(color, vec3(0.78, 0.97, 1.0), foam);
	float fade_in = smoothstep(0.0, 0.08, progress);
	COLOR = vec4(color, current * (0.48 + foam * 0.3) * fade_in * COLOR.a);
}
