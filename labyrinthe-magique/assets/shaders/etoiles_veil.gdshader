shader_type canvas_item;
render_mode blend_mix;

// LE VOILE DE LUNE : un grand croissant d'argent se referme autour d'elle, et un voile ondule entre
// ses pointes. Il se déchire en points à la fin. Il laisse voir le corps, qui reste dessous.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float closing = 1.0 - pow(1.0 - clamp(progress / 0.12, 0.0, 1.0), 3.0);
	float tear = smoothstep(0.84, 1.0, progress);
	float outer = 0.74 - length(p);
	float inner = length(p - vec2(0.1 * closing, 0.0)) - 0.68;
	float moon = min(outer, inner) * step(0.02, closing);
	vec3 color = mix(SHINE, vec3(1.0), smoothstep(0.02, 0.06, moon));
	color = mix(RIM, color, smoothstep(0.0, 0.012, moon));
	float alpha = smoothstep(-0.01, 0.0, moon);
	float sway = sin(p.y * 7.0 + TIME * 3.4 + seed) * 0.05;
	float veil = 0.72 + sway - length(p);
	float band = sin((p.x + sway) * 16.0 - TIME * 2.6) * 0.5 + 0.5;
	if (alpha < 0.5 && veil > 0.0) {
		color = mix(BLUE, SHINE, band);
		alpha = 0.12 + 0.12 * band;
	}
	float scrap = fract(sin(floor(p.x * 26.0) * 12.9898 + floor(p.y * 26.0) * 78.233 + seed) * 43758.5453);
	alpha *= step(tear, scrap);
	COLOR = vec4(color, alpha * closing * COLOR.a);
}
