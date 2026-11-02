shader_type canvas_item;
render_mode blend_mix;

// LE CHAMP DE FOUDRE : un sol sous tension. Le disque est à peine teinté, des veines y
// claquent par saccades, et un arc électrique court sur le bord, qui dit où le champ mord.
//
// ⚠️ Composé NORMALEMENT et non en additif : en additif, sur l'herbe et la neige, il
// brûlait en un disque jaune qui masquait le labyrinthe et effaçait ses propres traits.
// La veine tient par son cerne bleu, sur n'importe quel sol.
//
// Le bruit est `thunder_noise.png` : G les veines, R le tracé de l'arc du bord.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float phase = 0.0;
// Vie restante de la zone : le champ PÂLIT en s'épuisant.
uniform float life : hint_range(0.0, 1.0) = 1.0;

const float OPEN_TIME = 0.25;
const float RIM = 0.92;

float hash(float x) {
	return fract(sin(x * 127.1) * 43758.5453);
}

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = smoothstep(0.0, OPEN_TIME, phase);

	// Deux réseaux de veines, à deux cadences : jamais deux fois le même dessin.
	float fast = floor(phase * 11.0);
	float slow = floor(phase * 6.0);
	float first = texture(noise, p * 0.46 + vec2(hash(fast), hash(fast + 9.0))).g;
	float second = texture(noise, p * 0.62 + vec2(hash(slow + 3.0), hash(slow + 5.0))).g * step(0.4, hash(slow + 7.0));
	float vein = max(first, second) * smoothstep(RIM, RIM - 0.1, d) * open;

	// L'arc du bord : brisé, il rampe, et laisse des trous.
	float row = (mod(fast * 37.0, 256.0) + 0.5) / 256.0;
	float bend = (texture(noise, vec2(a / TAU, row)).r - 0.5) * 0.09;
	float gaps = smoothstep(-0.5, -0.3, sin(a * 5.0 + phase * 2.6));
	float rim = 0.018 * open - abs(d - RIM * open - bend);

	vec3 color = vec3(0.05, 0.1, 0.34);
	float alpha = smoothstep(RIM + 0.02, RIM, d / max(open, 0.01)) * 0.2;
	float blue = max(smoothstep(0.3, 0.42, vein), smoothstep(-0.012, 0.0, rim) * gaps);
	color = mix(color, vec3(0.2, 0.34, 1.0), blue);
	alpha = max(alpha, blue * 0.9);
	float white = max(smoothstep(0.58, 0.72, vein), smoothstep(0.0, 0.01, rim) * gaps);
	color = mix(color, vec3(1.0, 1.0, 0.88), white);
	alpha = max(alpha, white);
	COLOR = vec4(color, alpha * smoothstep(0.0, 0.1, life) * (0.72 + 0.28 * life));
}
