shader_type canvas_item;
render_mode blend_mix;

// L'ACIER EN FUSION : des langues de métal chauffé montent autour de lui, et des gouttes tombent.
// Le centre reste vide : c'est son armure teintée qui dit la chaleur, pas un voile sur le dessin.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.957, 0.878);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 DEEP = vec3(0.788, 0.235, 0.086);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float TONGUES = 11.0;
const float DROPS = 7.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float fade = smoothstep(0.0, 0.04, progress) * (1.0 - smoothstep(0.92, 1.0, progress));
	float cell = TAU / TONGUES;
	float index = floor((a + PI) / cell);
	float local = abs(fract((a + PI) / cell) - 0.5) * 2.0;
	float wave = 0.5 + 0.5 * sin(TIME * (6.0 + hash(index) * 4.0) + hash(index + 9.0) * 6.28);
	float reach = (0.68 + 0.2 * wave) * fade;
	float tongue = min(reach - local * 0.16 - d, d - 0.56);
	vec3 color = tongue > 0.05 ? WHITE : (tongue > 0.022 ? HOT : DEEP);
	color = mix(RIM, color, step(0.007, tongue));
	float alpha = step(0.0, tongue) * step(0.5, fade);
	for (int i = 0; i < int(DROPS); i++) {
		float f = float(i);
		float fall = fract(TIME * (0.6 + 0.3 * hash(f)) + hash(f + 4.0));
		vec2 at = vec2(-0.62 + 1.24 * hash(f + 8.0), 0.2 + fall * 0.72);
		float drop = 0.035 * (1.0 - fall * 0.6) - length((p - at) * vec2(1.0, 0.55));
		if (drop > 0.0) {
			color = drop > 0.012 ? WHITE : HOT;
			alpha = max(alpha, fade);
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
