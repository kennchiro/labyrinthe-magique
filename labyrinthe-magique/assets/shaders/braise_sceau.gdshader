shader_type canvas_item;
render_mode blend_mix;

// LE SCEAU DU LEURRE : couché sous la fausse armure, un compte à rebours qu'on lit d'un coup d'œil.
// L'anneau se remplit comme une horloge, et il bat de plus en plus vite avant l'explosion.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.851, 0.627);
const vec3 EMBER = vec3(1.0, 0.604, 0.122);
const vec3 LAVA = vec3(1.0, 0.478, 0.094);
const vec3 DEEP = vec3(0.541, 0.173, 0.031);
const vec3 BLACK = vec3(0.165, 0.129, 0.094);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 2.2;
	float d = length(p);
	float angle = atan(p.x, -p.y) / 6.2832 + 0.5;
	float t = progress;
	vec3 color = LAVA;
	float a = 0.0;
	float beat = 0.5 + 0.5 * sin(t * t * 70.0);
	float born = smoothstep(0.0, 0.1, t);
	float outer = 0.85 * born;
	if (0.07 - abs(d - outer) > 0.0) {
		bool lit = fract(angle) < t;
		color = lit ? mix(EMBER, PALE, beat * t) : DEEP;
		a = 1.0;
	}
	if (0.025 - abs(d - outer * 0.68) > 0.0) {
		color = EMBER;
		a = 1.0;
	}
	float runes = abs(fract(angle * 8.0 - TIME * 0.2) - 0.5);
	if (runes < 0.14 && abs(d - outer * 0.84) < 0.04 && born > 0.5) {
		color = PALE;
		a = 1.0;
	}
	if (d < outer * 0.66 && t > 0.6) {
		color = mix(DEEP, LAVA, beat);
		a = 0.45 * (t - 0.6) / 0.4 + 0.3 * beat;
	}
	COLOR = vec4(color, a);
}
