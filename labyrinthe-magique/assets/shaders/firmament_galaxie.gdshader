shader_type canvas_item;
render_mode blend_mix;

// NAISSANCE D'UNE GALAXIE, tout l'écran par-dessus la nuit : une galaxie en spirale bleu nuit et blanche, au cœur
// d'or pâle, tourne lentement au centre, grandit, puis se retire.
// ⚠️ Le quad couvre deux fois l'écran, comme la Nuit éternelle : `s` ramène l'écran vers ±1,2 de large.

#include "res://assets/shaders/firmament.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 s = (UV - 0.5) * 4.4;
	s.y *= 1.6;
	float t = progress;
	float grow = smoothstep(0.0, 0.3, t);
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	float d = length(s) / max(0.05, grow);
	float a = atan(s.y, s.x) - TIME * 0.6;
	// Deux bras qui s'enroulent.
	float arm = pow(0.5 + 0.5 * cos(2.0 * a + log(max(d, 0.02)) * 5.0), 3.0);
	float body = arm * r_glow(d, 1.1);
	vec3 c = mix(R_NIGHT, R_BLUE, arm);
	c = mix(c, R_SHINE, smoothstep(0.6, 1.0, arm) * r_glow(d, 0.8));
	vec4 color = vec4(c, body * 0.75);
	// Le semis d'étoiles dans les bras.
	vec2 cell = floor(s * 9.0);
	float h = r_hash(cell.x + seed, cell.y);
	if (h > 0.8) {
		vec2 local = fract(s * 9.0) - 0.5;
		float lit = smoothstep(0.0, 0.03, r_star_field(local, 0.16 * h)) * r_glow(d, 1.3);
		color = r_over(vec4(R_SHINE, lit * (0.6 + 0.4 * sin(TIME * 4.0 + h * 30.0))), color);
	}
	color = r_over(vec4(R_GOLD, r_glow(d, 0.28)), color);
	color = r_over(vec4(R_SHINE, r_glow(d, 0.1)), color);
	color.a *= fade * grow;
	COLOR = color;
}
