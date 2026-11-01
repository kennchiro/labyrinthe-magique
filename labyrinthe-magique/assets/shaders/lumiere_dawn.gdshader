shader_type canvas_item;
render_mode blend_mix;

// L'AUBE, tout l'écran : une petite étoile grossit, éclate, et le blanc envahit tout d'un seul
// éclair. Ce voile se retire ensuite du centre vers les bords, en laissant une lueur dorée.
// ⚠️ Un seul éclair : un effet qui clignote serait pénible, et dangereux pour certains joueurs.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	// Temps 1 : l'étoile qui grossit au-dessus de lui, et le décor qui s'assombrit un peu.
	float gather = clamp(progress / 0.26, 0.0, 1.0);
	float star = 0.1 * gather * gather - pow(pow(abs(p.x), 0.6) + pow(abs(p.y), 0.6), 1.67);
	vec3 color = vec3(0.06, 0.05, 0.12);
	float alpha = 0.2 * smoothstep(0.0, 0.26, progress) * (1.0 - step(0.26, progress));
	if (star > 0.0 && progress < 0.26) {
		color = vec3(1.0);
		alpha = 1.0;
	}
	// Temps 2 : l'éclair, qui se retire depuis le centre avec un bord à rayons.
	if (progress >= 0.26) {
		float t = (progress - 0.26) / 0.74;
		float rays = 0.03 * sin(a * 14.0 + seed * 9.0) + 0.02 * sin(a * 31.0);
		float hole = pow(t, 1.25) * 0.62 + rays * smoothstep(0.0, 0.1, t);
		float veil = smoothstep(0.0, 0.05, d - hole);
		color = mix(SHINE, vec3(1.0), 1.0 - smoothstep(0.0, 0.3, t));
		color = mix(GOLD, color, veil);
		alpha = max(veil * (1.0 - smoothstep(0.7, 1.0, t)), 0.12 * (1.0 - t));
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
