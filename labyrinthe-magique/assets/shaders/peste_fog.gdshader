shader_type canvas_item;
render_mode blend_mix;

// LE NUAGE TOXIQUE : trois ou quatre masses de gaz à bord NET, qui tournent lentement sur
// elles-mêmes, translucides pour qu'on lise les couloirs. Il s'effiloche à la fin.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 1.4;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 RIM = vec3(0.118, 0.227, 0.047);
const float EDGE = 0.8;

vec2 turned(vec2 p, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return vec2(p.x * c - p.y * s, p.x * s + p.y * c);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float grow = 1.0 - pow(1.0 - clamp(phase / 0.35, 0.0, 1.0), 3.0);
	float fray = smoothstep(0.28, 0.0, life);
	float gas = -1.0;
	float height = 0.0;
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float spin = phase * (0.28 + f * 0.09) * (mod(f, 2.0) < 0.5 ? 1.0 : -1.0);
		vec2 hub = turned(vec2(0.3 + f * 0.04, 0.0), f * 1.75 + phase * 0.14 + seed * 6.0);
		vec2 q = turned(p - hub, spin);
		float n = texture(noise, q * 0.42 + vec2(f * 0.31, seed)).r;
		float lobe = (0.3 + 0.35 * n) * grow - length(q);
		if (lobe > gas) {
			gas = lobe;
			height = n + f * 0.1;
		}
	}
	// Elle ne déborde jamais du rayon du sort : c'est là que le poison s'arrête.
	gas = min(gas, EDGE * grow - d);
	float frayed = texture(noise, p * 0.9 + vec2(phase * 0.08, seed)).g;
	gas -= fray * (0.1 + frayed * 0.5);
	vec3 color = mix(SHADE, VENOM, smoothstep(0.42, 0.62, height));
	color = mix(color, CORE, smoothstep(0.86, 0.98, height) * 0.3);
	color = mix(SHADE * 0.6, color, smoothstep(0.0, 0.09, gas) * 0.5 + 0.5);
	color = mix(RIM, color, smoothstep(0.0, 0.02, gas));
	COLOR = vec4(color, smoothstep(-0.006, 0.0, gas) * 0.72 * COLOR.a);
}
