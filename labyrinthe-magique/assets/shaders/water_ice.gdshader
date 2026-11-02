shader_type canvas_item;
render_mode blend_mix;

// LE CERCLE GLACÉ : le sol gèle depuis le centre, en plaques fendues, bordées de cristaux.
// À la fin, les plaques cèdent une à une : c'est ce qui dit que le piège va tomber.
//
// Le bruit est `ice_noise.png` (`tools/build_noise.py`) : R la teinte de chaque plaque,
// G ses fissures, B un pan qui accroche la lumière. Le bord du dessin tombe sur le
// rayon du sort.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 3.0;
uniform float seed = 0.0;
// Secondes écoulées, et ce qu'il reste de vie de 1 à 0.
uniform float phase = 0.0;
uniform float life = 1.0;

const float FREEZE_TIME = 0.45;
const float BREAK_LIFE = 0.14;
const float CRYSTALS = 15.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);

	// Le bord : des cristaux de tailles inégales, jamais un cercle lisse.
	float turn = (a + PI) / TAU * CRYSTALS;
	float crystal = floor(turn);
	float point = 1.0 - abs(fract(turn) * 2.0 - 1.0);
	float edge = 0.8 + point * (0.05 + 0.14 * hash(crystal));
	float grow = 1.0 - pow(1.0 - clamp(phase / FREEZE_TIME, 0.0, 1.0), 3.0);
	float body = edge * grow - d;

	vec4 ice = texture(noise, p * radius_tiles * 0.27 + seed);
	vec3 color = mix(vec3(0.3, 0.62, 0.86), vec3(0.45, 0.76, 0.93), smoothstep(0.34, 0.38, ice.r));
	color = mix(color, vec3(0.62, 0.87, 0.98), smoothstep(0.7, 0.74, ice.r));
	// Le reflet balaie la glace de temps en temps, et ne prend que sur certains pans.
	float sweep = smoothstep(0.1, 0.0, abs(fract(phase * 0.22 + p.x * 0.28 + p.y * 0.18) - 0.5));
	color = mix(color, vec3(0.93, 0.99, 1.0), smoothstep(0.76, 0.79, ice.b) * (0.12 + 0.7 * sweep));
	color = mix(color, vec3(0.2, 0.48, 0.76), smoothstep(0.42, 0.52, ice.g));
	color = mix(color, vec3(1.0), smoothstep(0.76, 0.86, ice.g));
	// Le front de gel, blanc tant qu'il avance, puis le cerne sombre qui tient sur sol clair.
	color = mix(color, vec3(1.0), smoothstep(0.1, 0.03, body) * (1.0 - grow));
	color = mix(color, vec3(0.86, 0.97, 1.0), smoothstep(0.06, 0.045, body) * grow);
	color = mix(color, vec3(0.1, 0.33, 0.6), smoothstep(0.022, 0.014, body));

	// La fin : la plaque la plus sombre cède la première.
	float broken = step(life / BREAK_LIFE, ice.r);
	// ⚠️ Translucide : la zone couvre six cases, haies comprises, et le joueur doit encore y
	// lire ses couloirs. Plus claire et plus opaque, elle éblouissait tout l'écran en jeu.
	COLOR = vec4(color, smoothstep(0.0, 0.008, body) * 0.68 * (1.0 - broken) * COLOR.a);
}
