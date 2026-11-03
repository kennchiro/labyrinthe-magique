shader_type canvas_item;
render_mode blend_mix;

// LA LANCE QUI TOMBE : une lance de lumière pâle bordée d'émeraude, pointe d'or en bas, qui tombe
// à pic sur son sceau en accélérant, suivie d'une courte traînée. UV.y va du ciel (0) au sol (1),
// et la pointe touche le sol à la fin, sur la case de la cible.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	float x = (UV.x - 0.5) * 2.0;
	float t = progress;
	float tip = mix(0.3, 0.97, t * t);
	float q = tip - UV.y; // > 0 au-dessus de la pointe
	vec3 color = PALE;
	float a = 0.0;
	float half_width = -1.0;
	float zone = 0.0;
	if (q >= 0.0 && q < 0.07) {
		half_width = 0.5 * q / 0.07;
		zone = 1.0; // la pointe
	} else if (q >= 0.07 && q < 0.09) {
		half_width = 0.72;
		zone = 2.0; // la garde
	} else if (q >= 0.09 && q < 0.3) {
		half_width = 0.26;
		zone = 3.0; // la hampe de lumière
	} else if (q >= 0.3 && q < 0.62) {
		half_width = 0.2 * (1.0 - (q - 0.3) / 0.32);
		zone = 4.0; // la traînée
	}
	float inside = half_width - abs(x);
	if (zone > 0.0 && inside > -0.09) {
		a = 1.0;
		if (inside <= 0.0) {
			color = RIM;
		} else if (zone == 1.0 || zone == 2.0) {
			color = inside > half_width * 0.45 ? PALE : GOLD;
		} else if (zone == 3.0) {
			color = inside > half_width * 0.5 ? PALE : EMERALD;
		} else {
			color = inside > half_width * 0.5 ? EMERALD : DEEP;
		}
	}
	COLOR = vec4(color, a);
}
