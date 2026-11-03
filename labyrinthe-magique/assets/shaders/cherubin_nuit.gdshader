shader_type canvas_item;
render_mode blend_mix;

// L'ÉPÉE SE LÈVE : le décor s'assombrit d'un voile bleu nuit, percé autour du Chérubin, pendant
// qu'il plante l'épée. Seul le jardin naissant reste éclairé ; le voile se lève d'un coup.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 NIGHT = vec3(0.02, 0.03, 0.09);
const vec3 DEEP = vec3(0.102, 0.184, 0.62);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	float fall = smoothstep(0.0, 0.15, t) * (1.0 - smoothstep(0.75, 1.0, t));
	float hole = smoothstep(0.05, 0.12, d);
	vec3 color = mix(DEEP * 0.5, NIGHT, smoothstep(0.05, 0.25, d));
	COLOR = vec4(color, 0.55 * fall * hole * (1.0 - smoothstep(0.92, 1.0, d)));
}
