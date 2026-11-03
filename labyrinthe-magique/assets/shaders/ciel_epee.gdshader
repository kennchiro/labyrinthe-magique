shader_type canvas_item;
render_mode blend_mix;

// UNE ÉPÉE DU JUGEMENT : une épée de lumière pâle à garde d'or, pointe en bas, qui tombe à pic sur
// son sceau en accélérant. UV.y va du ciel (0) au sol (1).

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
	float tip = mix(0.32, 0.97, t * t);
	float q = tip - UV.y;
	vec3 color = PALE;
	float a = 0.0;
	float half_width = -1.0;
	int zone = 0;
	if (q >= 0.0 && q < 0.06) {
		half_width = 0.4 * q / 0.06;
		zone = 1;     // la pointe
	} else if (q >= 0.06 && q < 0.3) {
		half_width = 0.4 - (q - 0.06) * 0.25;
		zone = 1;     // la lame
	} else if (q >= 0.3 && q < 0.33) {
		half_width = 0.95;
		zone = 2;     // la garde
	} else if (q >= 0.33 && q < 0.4) {
		half_width = 0.15;
		zone = 3;     // la poignée
	} else if (q >= 0.4 && q < 0.43) {
		half_width = 0.24;
		zone = 2;     // le pommeau
	} else if (q >= 0.43 && q < 0.75) {
		half_width = 0.16 * (1.0 - (q - 0.43) / 0.32);
		zone = 4;     // la traînée
	}
	float inside = half_width - abs(x);
	if (zone > 0 && inside > -0.09) {
		a = 1.0;
		if (inside <= 0.0) {
			color = RIM;
		} else if (zone == 1) {
			color = abs(x) < 0.06 ? DEEP : (inside > half_width * 0.4 ? PALE : EMERALD);
		} else if (zone == 2) {
			color = inside > half_width * 0.5 ? GOLD : vec3(0.75, 0.55, 0.18);
		} else if (zone == 3) {
			color = DEEP;
		} else {
			color = inside > half_width * 0.5 ? PALE : EMERALD;
		}
	}
	COLOR = vec4(color, a);
}
