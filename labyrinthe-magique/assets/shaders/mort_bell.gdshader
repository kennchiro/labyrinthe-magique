shader_type canvas_item;
render_mode blend_mix;

// LE GLAS : un cercle rouge qui s'ouvre d'un coup, cerné d'os, un voile sombre, une onde qui repart
// du centre à chaque coup de cloche et de fines volutes noires. Son bord tombe sur le rayon du sort.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.6;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const vec3 RED = vec3(0.886, 0.22, 0.165);
const vec3 DEEP = vec3(0.478, 0.078, 0.078);
const vec3 BLACK = vec3(0.078, 0.075, 0.11);
const vec3 BONE = vec3(0.902, 0.875, 0.792);
const float EDGE = 0.8;
const float TOLL = 1.4;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float open = 1.0 - pow(1.0 - clamp(phase / 0.3, 0.0, 1.0), 3.0);
	float close = smoothstep(0.1, 0.0, life);
	float reach = EDGE * open * (1.0 - close);
	vec3 color = BLACK;
	float alpha = 0.3 * step(d, reach);
	// Les volutes : des traits nets qui montent du sol.
	float rise = texture(noise, vec2(p.x * radius_tiles * 0.4 + seed, p.y * 0.3 + phase * 0.16)).r;
	float smoke = smoothstep(0.62, 0.66, rise) * step(d, reach * 0.94);
	alpha = max(alpha, smoke * 0.3);
	// L'onde de chaque coup de cloche.
	float beat = fract(phase / TOLL);
	float wave = 0.012 + 0.018 * (1.0 - beat) - abs(d - reach * beat);
	if (wave > 0.0 && d < reach) {
		color = mix(RED, DEEP, beat);
		alpha = max(alpha, 1.0 - beat * beat);
	}
	float ring = 0.018 - abs(d - reach);
	float rim = 0.03 - abs(d - reach);
	if (rim > 0.0) {
		color = BONE;
		alpha = 0.95;
	}
	if (ring > 0.0) {
		color = RED;
		alpha = 1.0;
	}
	float dying = life < 0.2 ? 0.55 + 0.45 * step(0.5, fract(phase * 6.0)) : 1.0;
	COLOR = vec4(color, alpha * dying * step(0.001, reach) * COLOR.a);
}
