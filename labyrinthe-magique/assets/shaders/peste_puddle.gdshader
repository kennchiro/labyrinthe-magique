shader_type canvas_item;
render_mode blend_mix;

// LA FLAQUE DE LA TRAÎNÉE : une tache au bord irrégulier, jamais un cercle. Fond sombre, bord
// clair et cerné, des bulles qui éclatent. Elle se craquelle et se rétracte vers son centre.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 RIM = vec3(0.118, 0.227, 0.047);

float hash(vec2 cell) {
	return fract(sin(dot(cell, vec2(12.9898, 78.233)) + seed * 37.7) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	// Des lobes doux : un bruit lu autour du cercle donnerait des épines.
	float s = seed * 37.0;
	float wobble = 0.5 + 0.28 * sin(a * 3.0 + s) + 0.16 * sin(a * 5.0 + s * 1.7) + 0.08 * sin(a * 9.0 + s * 2.3);
	float open = 1.0 - pow(1.0 - clamp(progress / 0.06, 0.0, 1.0), 3.0);
	float shrink = 1.0 - smoothstep(0.72, 1.0, progress) * 0.85;
	float reach = (0.26 + 0.22 * wobble) * open * shrink;
	float body = reach - d;
	vec3 color = mix(SHADE, vec3(0.2, 0.38, 0.05), smoothstep(0.34, 0.6, texture(noise, p * 0.5 + seed).g));
	color = mix(color, VENOM, smoothstep(0.075, 0.03, body));
	// Les bulles : chacune gonfle, puis éclate à son tour.
	vec2 at = p * 3.4;
	vec2 cell = floor(at);
	float life = fract(TIME * (0.5 + 0.5 * hash(cell)) + hash(cell + 3.0));
	vec2 centre = vec2(hash(cell + 7.0), hash(cell + 11.0)) * 0.5 + 0.25;
	float size = 0.22 * life;
	float dist = length(fract(at) - centre);
	float ring = smoothstep(0.05, 0.0, abs(dist - size)) * step(0.5, hash(cell + 19.0)) * step(0.0, body - 0.04);
	color = mix(color, CORE, ring * 0.9);
	// Les craquelures de la fin.
	float dry = smoothstep(0.7, 0.9, progress);
	float crack = smoothstep(0.03, 0.01, abs(texture(noise, p * 0.75 + seed).r - 0.5));
	color = mix(color, RIM, crack * dry);
	color = mix(RIM, color, smoothstep(0.0, 0.022, body));
	COLOR = vec4(color, smoothstep(-0.006, 0.0, body) * 0.78 * (1.0 - smoothstep(0.93, 1.0, progress)) * COLOR.a);
}
