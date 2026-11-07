shader_type canvas_item;
render_mode blend_mix;

// LE BASTION, porté sur lui : une carapace de plaques de roche se referme en anneau autour de lui,
// jointes par de la lave, des cristaux plantés dessus. Le dedans reste vide pour qu'on le voie. À la
// fin, les plaques s'écartent et tombent.

#include "res://assets/shaders/colosse.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

const float PLATES = 9.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.12;
	float d = length(p);
	float t = progress;
	vec3 color = C_ROCK;
	float a = 0.0;
	float close = smoothstep(0.0, 0.08, t);
	float fall = smoothstep(0.88, 1.0, t);
	float heat = 0.6 + 0.4 * sin(TIME * 5.0);
	float ang = atan(p.y, p.x);
	float sector = floor((ang + PI) / TAU * PLATES);
	float mid = (sector + 0.5) / PLATES * TAU - PI;
	// Chaque plaque arrive de loin et se plaque ; à la fin, elle s'écarte.
	float offset = (1.0 - close) * 0.45 + fall * 0.3;
	vec2 dir = vec2(cos(mid), sin(mid));
	vec2 c = dir * (0.74 + offset);
	vec2 q = c_rot(p - c, -mid);
	float half_len = 0.2;
	float half_thick = 0.13 * (1.0 - fall * 0.6);
	float plate = min(half_len - abs(q.y), half_thick - abs(q.x));
	if (plate > -0.03 && half_thick > 0.0) {
		a = 1.0;
		if (plate <= 0.0) {
			color = C_RIM;
		} else {
			color = q.x < -half_thick * 0.3 ? C_ROCK_DARK : (dot(dir, vec2(-0.6, -0.8)) > 0.0 ? C_ROCK_LIGHT : C_ROCK);
		}
	}
	// Les joints de lave, entre les plaques, quand elles sont en place.
	float seam = abs(fract((ang + PI) / TAU * PLATES) - 0.0);
	seam = min(seam, 1.0 - seam) * TAU / PLATES * d;
	if (close > 0.95 && fall < 0.05 && d > 0.6 && d < 0.88 && seam < 0.035) {
		color = seam < 0.018 ? c_lava(0.9, heat) : C_LAVA_DEEP;
		a = 1.0;
	}
	// Un cristal planté sur une plaque sur trois.
	if (mod(sector, 3.0) == 0.0 && fall < 0.5) {
		vec2 g = dir * (0.74 + offset) - vec2(0.0, 0.08);
		vec2 gq = p - g;
		float gem = c_gem(gq, 0.2 * close, 0.07);
		if (gem > -0.015) {
			color = gem <= 0.0 ? C_RIM : c_gem_shade(gq, gem, 0.07);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a * (1.0 - fall));
}
