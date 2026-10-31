shader_type canvas_item;
render_mode blend_mix;

// LE VOILE D'AIR : pas de bulle, trois rubans de vent qui tournent autour du mage.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float alpha = 0.0;
	for (int i = 0; i < 3; i++) {
		float r = 0.5 + float(i) * 0.17;
		float way = (i == 1) ? -1.0 : 1.0;
		float arc = fract((a + TIME * way * (2.5 - float(i) * 0.5) + float(i) * 2.0) / TAU);
		alpha = max(alpha, smoothstep(0.034, 0.012, abs(d - r)) * smoothstep(0.0, 0.5, arc) * step(arc, 0.62));
	}
	COLOR = vec4(mix(vec3(0.1, 0.42, 0.42), vec3(0.96, 1.0, 0.98), alpha * alpha), alpha * COLOR.a);
}
