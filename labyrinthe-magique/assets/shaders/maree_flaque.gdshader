shader_type canvas_item;
render_mode blend_mix;

// LE COURANT DU TORRENT : une petite flaque d'eau vive au sol, des rides qui courent dessus. Elle
// ralentit ce qui la traverse, et se résorbe en se réduisant.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 0.6;
uniform float aura = 0.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

const vec3 FOAM = vec3(0.914, 1.0, 1.0);
const vec3 TEAL = vec3(0.329, 0.918, 0.859);
const vec3 BLUE = vec3(0.216, 0.776, 1.0);
const vec3 RIM = vec3(0.024, 0.169, 0.384);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p * vec2(1.0, 1.3));
	float edge = 0.9 * life + 0.05 * sin(atan(p.y, p.x) * 5.0 + seed * 6.0);
	vec3 color = BLUE;
	float a = 0.0;
	if (d < edge) {
		float ripple = abs(fract(d * 3.0 - phase * 1.5) - 0.5);
		color = ripple < 0.08 ? FOAM : (ripple < 0.18 ? TEAL : BLUE);
		a = 0.7;
		if (d > edge - 0.08) {
			color = RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
