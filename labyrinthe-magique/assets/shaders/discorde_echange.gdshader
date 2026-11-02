shader_type canvas_item;
render_mode blend_mix;

// L'ÉCHANGE, joué sur les deux cases à la fois :
//   1. LA CARTE : un losange de lumière pâle se dresse et se retourne sur place, argent au revers.
//   2. LES ANNEAUX : deux anneaux d'argent s'écartent en sens opposés, gradués.
//   3. LES ÉCLATS : de petits éclats magenta tombent, et tout se réduit.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.945);
const vec3 SILVER = vec3(0.788, 0.824, 0.839);
const vec3 MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 DEEP = vec3(0.416, 0.059, 0.29);
const vec3 BLACK = vec3(0.086, 0.102, 0.11);
const float SHARDS = 8.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = MAGENTA;
	float alpha = 0.0;
	float flip = cos(t * 6.283);
	float width = max(0.02, abs(flip)) * 0.3 * (1.0 - smoothstep(0.55, 0.8, t));
	float card = 0.55 * (1.0 - smoothstep(0.55, 0.8, t)) - (abs(p.x) / max(width, 0.01) * 0.55 + abs(p.y));
	if (card > -0.02) {
		vec3 face = flip > 0.0 ? PALE : SILVER;
		color = mix(BLACK, face, smoothstep(-0.02, 0.03, card));
		color = mix(color, MAGENTA, smoothstep(0.2, 0.24, card));
		alpha = 1.0;
	}
	float d = length(p);
	float grow = smoothstep(0.12, 0.85, t);
	for (int i = 0; i < 2; i++) {
		float side = float(i) * 2.0 - 1.0;
		vec2 q = vec2(p.x + side * 0.0, p.y + side * grow * 0.32);
		float dq = length(q * vec2(1.0, 2.6));
		float ring = 0.03 * (1.0 - grow) + 0.006 - abs(dq - 0.2 - grow * 0.6);
		if (ring > 0.0 && t > 0.12) {
			color = mix(BLACK, SILVER, smoothstep(0.0, 0.012, ring));
			alpha = 1.0;
		}
	}
	float fall = smoothstep(0.4, 1.0, t);
	if (fall > 0.0) {
		for (int i = 0; i < int(SHARDS); i++) {
			float f = float(i);
			vec2 at = vec2((hash(f) - 0.5) * 1.3, -0.3 + hash(f + 1.0) * 0.3 + fall * (0.5 + hash(f + 2.0) * 0.5));
			vec2 s = abs(p - at);
			float shard = 0.06 * (1.0 - fall) - (s.x + s.y * 0.55);
			if (shard > 0.0) {
				color = mod(f, 2.0) < 0.5 ? MAGENTA : PALE;
				alpha = 1.0;
			}
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
