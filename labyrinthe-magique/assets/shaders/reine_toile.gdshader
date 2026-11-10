shader_type canvas_item;
render_mode blend_mix;

// LA TOILE DE SOUFFRANCE : une toile d'argent à cinq branches se tisse d'un coup autour de son centre, ses fils
// vibrent, des perles magenta courent le long des rayons, puis elle se resserre et s'efface. Le jeu tend ensuite
// les fils entre les cinq enchaînés.

#include "res://assets/shaders/reine.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float grow = smoothstep(0.0, 0.3, t);
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	float d = length(p);
	float ang = atan(p.y, p.x) + 1.5708;
	// Le pentagone : la distance au bord d'un polygone à cinq côtés.
	float sector = TAU / 5.0;
	float local = mod(ang + sector * 0.5, sector) - sector * 0.5;
	float poly = d * cos(local) / cos(sector * 0.5);
	float vib = sin(TIME * 30.0 + d * 20.0) * 0.008;
	// Les cinq rayons.
	float spoke = abs(local) * d;
	if (spoke < 0.012 && poly < 0.92 * grow) {
		color = R_SILVER;
		a = fade;
	}
	// Les tours de la toile.
	for (int i = 1; i <= 4; i++) {
		float r = float(i) * 0.23 * grow;
		float ring = 0.011 - abs(poly - r + vib);
		if (ring > 0.0) {
			color = i == 4 ? R_PALE : R_SILVER;
			a = fade;
		}
	}
	// Les perles qui courent le long des rayons, vers le centre.
	for (int i = 0; i < 5; i++) {
		float ai = float(i) * sector - 1.5708;
		float k = fract(t * 2.0 + float(i) * 0.2);
		vec2 c = vec2(cos(ai), sin(ai)) * 0.9 * grow * (1.0 - k);
		float bead = 0.05 - length(p - c);
		if (bead > -0.012) {
			color = bead > 0.0 ? R_MAGENTA : R_BLACK;
			a = fade;
		}
		// Les cinq nœuds corail au bout des rayons.
		vec2 n = vec2(cos(ai), sin(ai)) * 0.92 * grow;
		float node = 0.075 - length(p - n);
		if (node > -0.014 && grow > 0.5) {
			color = node > 0.0 ? (node > 0.04 ? R_PALE : R_MAGENTA) : R_BLACK;
			a = fade;
		}
	}
	vec3 eye = color;
	if (r_paint_eye(p, vec2(0.22, 0.11), grow * fade, eye)) {
		color = eye;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
