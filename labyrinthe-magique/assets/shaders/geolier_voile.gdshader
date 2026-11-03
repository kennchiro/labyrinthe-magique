shader_type canvas_item;
render_mode blend_mix;

// LA NUIT DE LA GEÔLE : un voile bleu-noir tombe sur la carte, percé autour du Geôlier. Seuls le
// cercle, les chaînes et la flamme froide restent éclairés, et il se lève d'un coup à la fin.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 NIGHT = vec3(0.008, 0.035, 0.05);
const vec3 DEEP = vec3(0.039, 0.435, 0.478);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	float fall = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.96, 1.0, t));
	float hole = smoothstep(0.03, 0.09, d);
	float a = 0.68 * fall * hole;
	vec3 color = mix(DEEP * 0.55, NIGHT, smoothstep(0.03, 0.2, d));
	COLOR = vec4(color, a * (1.0 - smoothstep(0.92, 1.0, d)));
}
