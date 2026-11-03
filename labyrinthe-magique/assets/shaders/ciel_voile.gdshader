shader_type canvas_item;
render_mode blend_mix;

// LE CIEL S'ASSOMBRIT : un voile vert presque noir tombe sur la carte pendant le Jugement, percé
// autour de l'Archange. Les épées et les sceaux d'or restent seuls éclairés, et il se lève d'un coup.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 NIGHT = vec3(0.016, 0.055, 0.035);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	float fall = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.95, 1.0, t));
	float hole = smoothstep(0.03, 0.08, d);
	vec3 color = mix(DEEP * 0.6, NIGHT, smoothstep(0.03, 0.18, d));
	COLOR = vec4(color, 0.64 * fall * hole * (1.0 - smoothstep(0.92, 1.0, d)));
}
