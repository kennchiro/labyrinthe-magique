shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAT D'OMBRE SE REFERME au lieu de s'ouvrir : l'anneau part de loin et rentre au
// centre, puis un point de lumière claque. C'est l'inverse exact de l'explosion du Feu.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float front = 0.86 * pow(1.0 - progress, 1.6);
	float frayed = texture(noise, p * 0.7 + seed).r - 0.5;
	float ring = 1.0 - abs(d - front + frayed * 0.09) / (0.05 + 0.16 * (1.0 - progress));
	float inside = smoothstep(front + 0.02, front - 0.08, d) * 0.55;
	float spark = smoothstep(0.75, 1.0, progress) * smoothstep(0.26, 0.05, d);
	vec3 color = mix(vec3(0.03, 0.01, 0.07), vec3(0.45, 0.16, 0.8), smoothstep(0.0, 0.5, ring));
	color = mix(color, vec3(0.94, 0.82, 1.0), max(smoothstep(0.55, 0.9, ring), spark));
	float alpha = max(max(smoothstep(0.0, 0.2, ring), inside), spark);
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.92, 1.0, progress)) * COLOR.a);
}
