shader_type canvas_item;
render_mode blend_mix;

// LE COUP DE MARTEAU : un éclat dentelé blanc et orange au sol, un anneau d'acier qui s'élargit, et
// une gerbe d'étincelles. Le même dessin sert au coup, à la lame qui touche et à la plaque arrachée.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.957, 0.878);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 STEEL = vec3(0.875, 0.902, 0.933);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float SPARKS = 11.0;
const float TEETH = 9.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = smoothstep(0.0, 0.18, progress) * (1.0 - smoothstep(0.3, 0.7, progress));
	float tooth = abs(fract(a / TAU * TEETH + seed) - 0.5) * 2.0;
	float heat = (0.1 + 0.14 * tooth) * open - d;
	float alpha = smoothstep(-0.018, -0.002, heat) * step(0.001, open);
	vec3 color = mix(HOT, WHITE, smoothstep(0.015, 0.09, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.016, heat));
	float grown = 0.82 * (1.0 - pow(1.0 - progress, 3.0));
	float width = 0.016 * (1.0 - progress) + 0.004;
	float ring = width - abs(d - grown);
	if (ring > -0.012 && alpha < 0.5) {
		color = ring > 0.0 ? STEEL : RIM;
		alpha = 1.0 - smoothstep(0.55, 1.0, progress);
	}
	for (int i = 0; i < int(SPARKS); i++) {
		float f = float(i);
		float sa = TAU * (f + hash(f)) / SPARKS;
		vec2 dir = vec2(cos(sa), sin(sa));
		float run = 0.12 + (0.5 + 0.35 * hash(f + 5.0)) * sqrt(progress);
		vec2 q = p - dir * run;
		float along = dot(q, dir);
		float across = abs(dot(q, vec2(-dir.y, dir.x)));
		float spark = 0.018 * (1.0 - progress) + 0.004 - across - abs(along) * 0.14;
		if (spark > 0.0 && abs(along) < 0.09 && alpha < 0.5) {
			color = HOT;
			alpha = 1.0 - progress * progress;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
