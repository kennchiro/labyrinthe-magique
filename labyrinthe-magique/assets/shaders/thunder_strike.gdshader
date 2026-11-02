shader_type canvas_item;
render_mode blend_mix;

// LE FLASH : le mage part dans un seul éclair vertical, qui s'éteint aussitôt.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	// Une rangée du bruit est un tracé entier : en changer redessine tout l'éclair.
	float row = (mod(floor(progress * 8.0) * 37.0 + floor(seed * 256.0), 256.0) + 0.5) / 256.0;
	float line = (texture(noise, vec2(UV.y * 0.6 + seed, row)).r - 0.5) * 0.55;
	float x = abs((UV.x - 0.5) * 2.0 - line);
	float width = 0.09 * (1.0 - progress);
	// La fourche suit les cassures de l'éclair et s'en écarte : aucune lecture de plus.
	float along = (UV.y - 0.2 - fract(row * 61.7) * 0.3) / 0.34;
	float side = fract(row * 17.3) < 0.5 ? -1.0 : 1.0;
	float fork_x = abs((UV.x - 0.5) * 2.0 - line - side * along * 0.5);
	float fork = along > 0.0 && along < 1.0 ? width * 0.7 * (1.0 - along) - fork_x : -1.0;
	float halo = 0.3 * (1.0 - progress) - x;
	float core = max(width - x, fork);
	vec3 color = mix(vec3(0.36, 0.48, 1.0), vec3(1.0, 1.0, 0.92), smoothstep(0.0, 0.02, core));
	COLOR = vec4(color, max(smoothstep(0.0, 0.015, core), smoothstep(0.0, 0.3, halo) * 0.45) * COLOR.a);
}
