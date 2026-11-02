shader_type spatial;
render_mode unshaded, depth_draw_never, cull_disabled, shadows_disabled;

// Le portail de l'îlot : sa PROPRE spirale peinte, reprise et tournée. Elle reste dans
// l'ellipse de l'ouverture, et son bord se fond dans le dessin immobile en dessous.

uniform sampler2D island : source_color, filter_linear, repeat_disable;
uniform vec2 centre = vec2(0.5);
uniform vec2 radii = vec2(0.1);
uniform float phase = 0.0;
uniform float open = 0.0;
uniform vec3 sealed = vec3(0.3);

const float OPEN_GLOW = 1.2;

void fragment() {
	vec2 at = (UV - 0.5) * 2.0;
	float turn_sin = sin(phase);
	float turn_cos = cos(phase);
	vec2 turned = vec2(at.x * turn_cos - at.y * turn_sin, at.x * turn_sin + at.y * turn_cos);
	vec4 painted = texture(island, centre + turned * radii);
	ALBEDO = painted.rgb * mix(sealed, vec3(OPEN_GLOW), open);
	ALPHA = painted.a * smoothstep(1.0, 0.72, length(at));
}
