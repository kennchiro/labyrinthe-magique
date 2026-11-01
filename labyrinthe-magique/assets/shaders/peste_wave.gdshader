shader_type canvas_item;
render_mode blend_mix;

// LA PANDÉMIE : la fiole se brise en anneau de venin, puis une onde de gaz part du mage et
// traverse tout, haies comprises. Son front est net, avec des crêtes, et elle laisse derrière
// elle un voile vert : l'écran verdit sur son passage, puis se remet.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 RIM = vec3(0.118, 0.227, 0.047);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	// Temps 1 : l'anneau de venin de la fiole, tout près du mage, qui retombe.
	float flask = smoothstep(0.0, 0.25, progress) * (1.0 - smoothstep(0.25, 0.45, progress));
	float ring = (0.005 - abs(d - 0.04 - progress * 0.2)) * step(0.001, flask);
	// Temps 2 : l'onde, dont le front porte des crêtes.
	float wave_t = clamp((progress - 0.2) / 0.62, 0.0, 1.0);
	float reach = 0.8 * (1.0 - pow(1.0 - wave_t, 2.0));
	float crest = texture(noise, vec2(cos(a), sin(a)) * 0.45 + seed + progress * 0.25).r;
	float front = reach + (crest - 0.5) * 0.09;
	float inside = front - d;
	float band = step(0.0, inside) * smoothstep(0.17, 0.0, inside);
	float swirl = texture(noise, p * 0.6 + vec2(seed, -progress * 0.4)).g;
	vec3 color = mix(SHADE, VENOM, smoothstep(0.35, 0.62, swirl));
	color = mix(color, CORE, (1.0 - smoothstep(0.0, 0.03, inside)) * step(0.0, inside));
	color = mix(RIM, color, smoothstep(0.0, 0.006, inside));
	float veil = step(0.0, inside) * 0.14;
	float gone = smoothstep(0.82, 1.0, progress);
	float alpha = max(band * (0.45 + 0.4 * swirl), veil) * step(0.001, wave_t) * (1.0 - gone);
	float flask_ring = step(0.0001, ring);
	color = mix(color, VENOM, flask_ring);
	alpha = max(alpha, flask_ring);
	COLOR = vec4(color, alpha * COLOR.a);
}
