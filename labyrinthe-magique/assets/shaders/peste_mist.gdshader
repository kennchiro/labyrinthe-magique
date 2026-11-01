shader_type canvas_item;
render_mode blend_mix;

// LA BRUME : il se dissout de bas en haut en volutes vertes, puis l'inverse à l'arrivée. Les
// volutes s'enroulent en spirale autour de l'endroit où il se tenait.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 RIM = vec3(0.118, 0.227, 0.047);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.35;
	float d = length(p);
	float a = atan(p.y, p.x);
	float arms = sin(a * 3.0 + d * 8.0 - progress * 9.0 + seed * 6.0);
	float rise = 0.7 - progress * 1.5;
	float band = smoothstep(0.75, 0.2, abs(p.y - rise));
	float n = texture(noise, vec2(p.x * 0.5 + seed, p.y * 0.4 + progress * 0.7)).r;
	float gas = (arms * 0.2 + n * 0.5 - 0.1) * band - d * 0.28;
	vec3 color = mix(SHADE, VENOM, smoothstep(0.02, 0.1, gas));
	color = mix(color, CORE, smoothstep(0.2, 0.26, gas) * 0.7);
	color = mix(RIM, color, smoothstep(0.0, 0.015, gas));
	float fade = smoothstep(0.0, 0.1, progress) * (1.0 - smoothstep(0.72, 1.0, progress));
	COLOR = vec4(color, smoothstep(-0.004, 0.0, gas) * 0.92 * fade * COLOR.a);
}
