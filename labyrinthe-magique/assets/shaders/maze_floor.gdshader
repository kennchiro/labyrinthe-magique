shader_type spatial;
render_mode vertex_lighting;

// Le sol du labyrinthe : sa planche, sa teinte, et les nappes qui passent dessus.

#include "drift.gdshaderinc"

uniform sampler2D sheet : source_color, repeat_enable, filter_linear_mipmap;
uniform vec3 tint = vec3(1.0);
// Ce qui court sur le sol : l'endroit où deux bruits en sens contraires se croisent. Étiré,
// cela fait du sable soufflé ; à échelle égale, les reflets de l'eau.
uniform float flow = 0.0;
uniform vec3 flow_tint = vec3(1.0);
uniform vec2 flow_scale = vec2(1.0);
uniform vec2 flow_speed = vec2(0.0);

void vertex() {
	world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec3 ground = texture(sheet, UV).rgb * tint;
	if (flow > 0.0) {
		vec2 at = world_xz * flow_scale;
		float one = texture(drift_noise, at + TIME * flow_speed).r;
		float two = texture(drift_noise, at * 1.37 - TIME * flow_speed * 0.6).r;
		// Par plaques : partout à la fois, ces lignes faisaient un sol craquelé.
		float patch = smoothstep(0.50, 0.70, one);
		ground += flow_tint * flow * patch * smoothstep(0.82, 1.0, 1.0 - abs(one - two) * 5.0);
	}
	ALBEDO = ground * cloud_shade();
}
