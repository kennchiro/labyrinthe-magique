shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DU VENIN : la goutte s'écrase en étoile d'éclaboussures, qui se rétractent en
// laissant une tache verte qui s'efface.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 RIM = vec3(0.118, 0.227, 0.047);
const float ARMS = 6.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float turn = (a + PI) / TAU * ARMS;
	float arm = floor(turn);
	float across = abs(fract(turn) - 0.5) * 2.0;
	float out_t = 1.0 - pow(1.0 - clamp(progress / 0.35, 0.0, 1.0), 3.0);
	float back = smoothstep(0.35, 0.8, progress);
	float reach = (0.26 + 0.2 * hash(arm)) * out_t * (1.0 - back * 0.6);
	// Chaque bras s'affine vers son bout, où pend une goutte ronde.
	float spike = (reach - d) * 1.0 - across * d * 0.42;
	float bead_at = reach + 0.02;
	float bead = 0.05 * out_t - length(vec2(d - bead_at, across * d * 0.5));
	float stain = (0.15 * out_t * (1.0 - 0.3 * back)) - d;
	float heat = max(max(spike, bead), stain);
	vec3 color = mix(VENOM, SHADE, (1.0 - smoothstep(0.1, 0.3, d)) * back);
	color = mix(color, CORE, (1.0 - smoothstep(0.03, 0.11, d)) * (1.0 - back));
	color = mix(RIM, color, smoothstep(0.0, 0.025, heat));
	float fade = 1.0 - smoothstep(0.72, 1.0, progress);
	COLOR = vec4(color, smoothstep(-0.008, 0.0, heat) * fade * COLOR.a);
}
