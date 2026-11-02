shader_type canvas_item;
render_mode blend_mix;

// LE MURMURE : un fil d'argent qui ondule de plus en plus vers sa pointe, cerné de noir pour tenir
// sur tous les sols, avec une perle magenta au bout. De petits éclats pâles restent derrière lui.

uniform float seed = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.945);
const vec3 SILVER = vec3(0.788, 0.824, 0.839);
const vec3 MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 DEEP = vec3(0.416, 0.059, 0.29);
const vec3 BLACK = vec3(0.086, 0.102, 0.11);
const float SPARKS = 5.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	float y = (UV.y - 0.5) * 2.0;
	float wave = sin(UV.x * 16.0 - TIME * 22.0 + seed * 6.0) * 0.42 * (1.0 - UV.x * 0.55) * smoothstep(0.0, 0.25, UV.x);
	float thin = min(0.1 * smoothstep(0.0, 0.5, UV.x) - abs(y - wave), 0.84 - UV.x);
	vec3 color = mix(SILVER, PALE, smoothstep(0.045, 0.075, thin));
	color = mix(BLACK, color, smoothstep(0.0, 0.03, thin));
	float alpha = smoothstep(-0.012, 0.0, thin);
	vec2 q = (UV - vec2(0.84, 0.5)) * vec2(1.9 * 2.0, 0.56 * 2.0) / 0.5;
	float pearl = 0.72 - length(q);
	float halo = 0.06 - abs(length(q) - 0.94 - 0.07 * sin(TIME * 20.0));
	if (halo > 0.0) {
		color = MAGENTA;
		alpha = 1.0;
	}
	if (pearl > -0.04) {
		color = mix(BLACK, MAGENTA, smoothstep(-0.02, 0.1, pearl));
		color = mix(color, PALE, smoothstep(0.48, 0.56, 0.72 - length(q - vec2(-0.2, -0.22))));
		alpha = max(alpha, smoothstep(-0.04, 0.0, pearl));
	}
	for (int i = 0; i < int(SPARKS); i++) {
		float f = float(i);
		float run = fract(hash(f) + TIME * (1.4 + hash(f + 1.0)));
		vec2 at = vec2(0.5 - run * 0.5, 0.5 + (hash(f + 2.0) - 0.5) * 0.7);
		vec2 d = abs((UV - at) * vec2(4.0, 1.0));
		float shape = 0.07 * (1.0 - run) - (d.x + d.y);
		if (shape > 0.0 && alpha < 0.5) {
			color = mod(f, 2.0) < 0.5 ? PALE : MAGENTA;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
