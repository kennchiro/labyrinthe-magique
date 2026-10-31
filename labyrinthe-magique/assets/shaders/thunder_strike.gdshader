shader_type canvas_item;
render_mode blend_mix;

// LE FLASH : le mage part dans un seul éclair vertical, qui s'éteint aussitôt.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float seg = floor(UV.y * 8.0);
	float n0 = texture(noise, vec2(seg * 0.17, seed + floor(progress * 8.0) * 0.2)).r - 0.5;
	float n1 = texture(noise, vec2((seg + 1.0) * 0.17, seed + floor(progress * 8.0) * 0.2)).r - 0.5;
	float line = mix(n0, n1, fract(UV.y * 8.0)) * 0.55;
	float x = abs((UV.x - 0.5) * 2.0 - line);
	float width = 0.09 * (1.0 - progress);
	float halo = 0.3 * (1.0 - progress) - x;
	vec3 color = mix(vec3(0.36, 0.48, 1.0), vec3(1.0, 1.0, 0.92), smoothstep(0.0, 0.02, width - x));
	COLOR = vec4(color, max(smoothstep(0.0, 0.015, width - x), smoothstep(0.0, 0.3, halo) * 0.45) * COLOR.a);
}
