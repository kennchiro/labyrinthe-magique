shader_type canvas_item;
render_mode blend_mix;

// L'ANNEAU D'ÉTOILES : il s'élargit au sol, semé de petites étoiles sur son tour. C'est l'explosion
// du trait, l'ouverture de la Pluie et le pied d'une comète.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);
const float STARS = 10.0;
const float EDGE = 0.8;

float star(vec2 v, float size) {
	return size - pow(pow(abs(v.x), 0.6) + pow(abs(v.y), 0.6), 1.67);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x) + progress * 0.8;
	float grown = EDGE * (1.0 - pow(1.0 - progress, 3.0));
	float width = 0.03 * (1.0 - progress) + 0.006;
	float ring = width - abs(d - grown);
	vec3 color = mix(BLUE, SHINE, smoothstep(0.0, 0.016, ring));
	float rim = width + 0.012 - abs(d - grown);
	float alpha = smoothstep(0.0, 0.004, rim);
	color = mix(RIM, color, smoothstep(0.0, 0.004, ring));
	float step_a = TAU / STARS;
	vec2 local = vec2(mod(a + step_a * 0.5, step_a) - step_a * 0.5, 0.0);
	vec2 at = vec2(local.x * d, d - grown);
	float mark = star(at, 0.09 * (1.0 - progress * 0.7));
	if (mark > -0.006) {
		color = mark > 0.0 ? vec3(1.0) : RIM;
		alpha = 1.0;
	}
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.65, 1.0, progress)) * COLOR.a);
}
