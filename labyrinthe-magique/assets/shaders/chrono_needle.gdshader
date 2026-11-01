shader_type canvas_item;
render_mode blend_mix;

// L'AIGUILLE du Chronomancien : une aiguille d'horloge en cuivre, nette, suivie de sable
// turquoise. La pointe est à droite, comme tout projectile du jeu.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;

void fragment() {
	float along = UV.x;
	float across = abs(UV.y - 0.5) * 2.0;
	// La lame et le petit disque de son axe.
	float blade = (1.0 - abs(along - 0.8) / 0.2) * 0.62 - across;
	float hub = 0.11 - length(vec2((along - 0.6) * 3.6, across * 0.72));
	float metal = max(blade, hub);
	vec3 color = mix(vec3(0.5, 0.2, 0.06), vec3(0.95, 0.58, 0.22), smoothstep(0.0, 0.12, metal));
	color = mix(color, vec3(1.0, 0.9, 0.62), smoothstep(0.2, 0.3, metal));
	// Le sable : des grains qui défilent vers la queue et se perdent.
	float grain = texture(noise, vec2(along * 1.6 - TIME * 1.5 + seed, UV.y * 1.1 + seed)).r;
	float fade = smoothstep(0.0, 0.5, along) * step(along, 0.62);
	float sand = step(0.5 - fade * 0.2, grain) * step(across, 0.2 + along * 0.7) * fade;
	vec3 sand_color = mix(vec3(0.1, 0.66, 0.6), vec3(0.72, 1.0, 0.92), smoothstep(0.55, 0.72, grain));
	float solid = smoothstep(0.0, 0.04, metal);
	COLOR = vec4(mix(sand_color, color, solid), max(solid, sand * 0.9) * COLOR.a);
}
