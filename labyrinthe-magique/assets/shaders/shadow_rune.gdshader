shader_type canvas_item;
render_mode blend_mix;

// LA RUNE DES TÉNÈBRES : un piège qui retient. Une flaque de nuit où l'on s'englue,
// des griffes de fumée qui rampent vers le centre, et un anneau de signes qui tourne.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float open = smoothstep(0.0, 0.4, phase);
	float angle = atan(p.y, p.x);
	// Le bruit RENTRE vers le centre : c'est ce qui se lit comme une aspiration.
	vec2 at = vec2(cos(angle), sin(angle)) * 0.35 + vec2(d * 0.5 + phase * 0.14, seed);
	float claw = texture(noise, at).r - 0.5;
	float pool = (0.72 * open - d) / 0.2 + claw * 1.8;

	float ring = abs(d - 0.84 * open);
	float glyphs = step(0.5, fract((angle + phase * 0.5) * 12.0 / TAU + texture(noise, vec2(floor((angle + phase * 0.5) * 12.0 / TAU) * 0.13, seed)).r));
	float band = smoothstep(0.012, 0.004, abs(ring - 0.07)) + smoothstep(0.05, 0.03, ring) * glyphs;

	vec3 color = mix(vec3(0.05, 0.015, 0.1), vec3(0.3, 0.09, 0.52), smoothstep(0.0, 0.5, 1.0 - pool * 0.5));
	color = mix(color, vec3(0.86, 0.62, 1.0), clamp(band, 0.0, 1.0));
	float alpha = max(smoothstep(0.0, 0.5, pool) * 0.82, clamp(band, 0.0, 1.0));
	COLOR = vec4(color, alpha * smoothstep(0.0, 0.1, life) * COLOR.a);
}
