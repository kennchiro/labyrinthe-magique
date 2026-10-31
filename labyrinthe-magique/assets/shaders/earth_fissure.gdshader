shader_type canvas_item;
render_mode blend_mix;

// L'ENFOUISSEMENT : le sol s'ouvre en une fente noire où le mage disparaît.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float open = sin(min(progress * 1.2, 1.0) * PI);
	float n = texture(noise, vec2(p.x * 0.5 + seed, seed * 0.3)).r - 0.5;
	float y = abs(p.y * 0.8 + n * 0.5);
	float length_ = 0.86 - abs(p.x);
	float hole = open * 0.26 * smoothstep(0.0, 0.5, length_) - y;
	float lip = open * 0.4 * smoothstep(0.0, 0.6, length_) - y;
	vec3 color = mix(vec3(0.55, 0.42, 0.28), vec3(0.04, 0.03, 0.03), smoothstep(0.0, 0.01, hole));
	COLOR = vec4(color, smoothstep(0.0, 0.015, lip) * COLOR.a);
}
