shader_type canvas_item;
render_mode blend_mix;

// L'ÉTOILE FILANTE, aux deux bouts du saut : une étoile haute et fine se resserre sur elle-même,
// un anneau se referme, et des traits courts filent vers le centre.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);
const float STREAKS = 7.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float shrink = 1.0 - progress;
	vec2 tall = vec2(p.x * 2.4, p.y);
	float heat = 0.5 * shrink - pow(pow(abs(tall.x), 0.6) + pow(abs(tall.y), 0.6), 1.67);
	vec3 color = mix(BLUE, vec3(1.0), smoothstep(0.0, 0.05, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.015, heat));
	float alpha = smoothstep(-0.014, -0.002, heat);
	float d = length(p);
	float ring = 0.014 * shrink + 0.004 - abs(d - 0.74 * shrink);
	if (ring > 0.0 && alpha < 0.5) {
		color = SHINE;
		alpha = shrink;
	}
	float a = atan(p.y, p.x) + seed;
	float slice = abs(fract(a / TAU * STREAKS) - 0.5);
	float lit = step(slice, 0.03) * step(0.4 * shrink, d) * step(d, 0.4 * shrink + 0.22);
	if (lit > 0.5 && alpha < 0.5) {
		color = vec3(1.0);
		alpha = shrink;
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
