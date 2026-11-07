shader_type canvas_item;
// L'Avide : recoloré depuis braise_voile, vert bile, os et noir d'encre.
render_mode blend_mix;

// LE SOL S'ÉTEINT SOUS LES MILLE CAGES : un voile brun-noir tombe sur la carte, percé autour du
// roi. Ce sont les cages et le feu qui restent à voir. Il se lève d'un coup au dernier instant.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 NIGHT = vec3(0.02, 0.04, 0.01);
const vec3 DEEP = vec3(0.353, 0.478, 0.071);

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
