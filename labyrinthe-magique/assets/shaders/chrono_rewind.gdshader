shader_type canvas_item;
render_mode blend_mix;

// LE RETOUR : un arc de sable qui tourne à l'envers des aiguilles d'une montre, avec sa
// pointe de flèche. C'est la seule fuite du jeu qui tourne : elle revient, elle ne part pas.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	// De 0 à 1, dans le sens inverse des aiguilles à l'écran (l'axe y descend).
	float turn = fract(-atan(p.y, p.x) / TAU + 0.5);
	float head = fract(progress * 1.25 + seed);
	float behind = fract(head - turn);
	float tail = 1.0 - behind / 0.7;
	float band = (0.03 + 0.11 * max(tail, 0.0)) - abs(d - 0.66);
	float grain = texture(noise, vec2(turn * 5.0 + seed, d * 1.7 - progress)).r;
	float body = band * step(behind, 0.7) * step(0.14 + (1.0 - tail) * 0.4, grain);
	// La pointe : un triangle plein devant le bout de l'arc.
	float ahead = fract(turn - head);
	float tip = (0.17 - ahead * 2.1) - abs(d - 0.66);
	tip *= step(ahead, 0.09);
	float heat = max(body, tip);
	vec3 color = mix(vec3(0.03, 0.42, 0.42), vec3(0.2, 0.86, 0.76), smoothstep(0.0, 0.03, heat));
	color = mix(color, vec3(0.8, 1.0, 0.94), smoothstep(0.075, 0.1, heat));
	float fade = smoothstep(0.0, 0.12, progress) * (1.0 - smoothstep(0.7, 1.0, progress));
	COLOR = vec4(color, smoothstep(0.0, 0.012, heat) * fade * COLOR.a);
}
