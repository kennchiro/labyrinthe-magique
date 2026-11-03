shader_type canvas_item;
render_mode blend_mix;

// UNE PLUME-LAME : une plume d'or au bord émeraude, taillée en lame, avec sa nervure. Le nœud qui
// la porte la fait voler et tourner ; le dessin reste le même.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	// x le long de la plume (pointe à droite), y en travers.
	vec2 p = (UV - 0.5) * 2.0;
	float s = clamp(p.x / 0.92, -1.0, 1.0);
	// Un vane large près de la base, effilé en lame vers la pointe.
	float half_width = 0.82 * pow(max(0.0, 1.0 - s * s), 0.55) * (s > 0.0 ? 1.0 - s * 0.45 : 1.0);
	// Trois encoches obliques sur le bord de fuite : c'est une plume, pas une feuille.
	if (p.y > 0.0) {
		half_width -= 0.22 * step(0.62, fract(s * 2.6 - p.y * 1.2 + 0.2)) * step(-0.7, s) * step(s, 0.6);
	}
	float inside = half_width - abs(p.y);
	vec3 color = GOLD;
	float a = 0.0;
	if (abs(p.x) < 0.92 && inside > -0.12) {
		a = 1.0;
		if (inside <= 0.0) {
			color = RIM;
		} else if (inside < 0.16) {
			color = EMERALD;
		} else if (abs(p.y) < 0.07) {
			color = DEEP;
		} else {
			color = p.y < 0.0 ? PALE : GOLD;
		}
	}
	// La hampe dépasse derrière.
	if (p.x < -0.8 && p.x > -0.99 && abs(p.y) < 0.12) {
		color = abs(p.y) < 0.06 ? GOLD : RIM;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
