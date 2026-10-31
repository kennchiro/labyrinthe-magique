shader_type canvas_item;
render_mode blend_mix;

// LA BOURRASQUE DE FUITE : des traits de vent horizontaux, rien d'autre.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float row = floor(UV.y * 9.0);
	float r = texture(noise, vec2(row * 0.23, seed)).r;
	float head = fract(r * 3.0) * 0.4 + progress * 1.3 - 0.2;
	float length_ = 0.3 + r * 0.3;
	float on = step(UV.x, head) * step(head - length_, UV.x) * step(0.35, r);
	float y = abs(fract(UV.y * 9.0) - 0.5);
	vec3 color = mix(vec3(0.62, 0.9, 0.86), vec3(1.0), smoothstep(0.1, 0.03, y));
	COLOR = vec4(color, on * smoothstep(0.2, 0.06, y) * (1.0 - smoothstep(0.7, 1.0, progress)) * 0.85 * COLOR.a);
}
