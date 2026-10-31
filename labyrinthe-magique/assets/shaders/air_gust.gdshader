shader_type canvas_item;
render_mode blend_mix;

// LE GRAND SOUFFLE : un cône d'arcs de vent qui part devant le mage et pousse.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	float r = length(p);
	float a = atan(p.y, p.x);
	float cone = step(abs(a), 0.62);
	float n = texture(noise, vec2(a * 0.5 + seed, r * 0.5)).r - 0.5;
	float rings = fract(r * 6.0 - progress * 6.5 + n * 0.5);
	float line = smoothstep(0.72, 0.8, rings) * smoothstep(1.0, 0.92, rings);
	float reach = smoothstep(0.0, 0.5, progress) * 1.05;
	vec3 color = mix(vec3(0.1, 0.42, 0.42), vec3(1.0), line);
	float body = cone * step(r, reach) * smoothstep(0.03, 0.14, r);
	COLOR = vec4(color, body * max(line, 0.24 * (1.0 - r)) * (1.0 - smoothstep(0.65, 1.0, progress)) * COLOR.a);
}
