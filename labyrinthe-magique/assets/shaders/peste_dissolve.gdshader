shader_type canvas_item;
render_mode blend_mix;

// MORT PAR LE POISON : la créature ne disparaît pas comme les autres, elle se dissout en une
// flaque qui bouillonne un instant, et les dernières bulles montent.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 RIM = vec3(0.118, 0.227, 0.047);
const float BUBBLES = 7.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 flat_p = vec2(p.x, (p.y - 0.25) * 2.1);
	float d = length(flat_p);
	float a = atan(flat_p.y, flat_p.x);
	float s = seed * 37.0;
	float wobble = 0.5 + 0.3 * sin(a * 3.0 + s) + 0.17 * sin(a * 5.0 + s * 1.7);
	float grow = 1.0 - pow(1.0 - clamp(progress / 0.35, 0.0, 1.0), 3.0);
	float body = (0.3 + 0.28 * wobble) * grow * (1.0 - smoothstep(0.65, 1.0, progress) * 0.5) - d;
	vec3 color = mix(SHADE, VENOM, smoothstep(0.1, 0.02, body));
	color = mix(RIM, color, smoothstep(0.0, 0.02, body));
	float alpha = smoothstep(-0.006, 0.0, body);
	// Les bulles qui remontent de la flaque.
	for (int i = 0; i < int(BUBBLES); i++) {
		float f = float(i);
		float life = fract(progress * 1.4 + hash(f));
		vec2 at = vec2((hash(f + 3.0) - 0.5) * 0.7, 0.25 - life * 0.75);
		float size = 0.035 + 0.04 * hash(f + 9.0) * (1.0 - life);
		float bubble = size - length(p - at);
		if (bubble > 0.0) {
			color = mix(VENOM, CORE, smoothstep(0.0, size, bubble));
			alpha = max(alpha, 1.0 - life);
		}
	}
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.78, 1.0, progress)) * COLOR.a);
}
