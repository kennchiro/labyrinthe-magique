shader_type canvas_item;
render_mode blend_mix;

// LE PORTAIL, peint à l'écran au lieu d'être lu dans huit images.
//
// Vu de dessus et de l'extérieur vers le centre : un liseré sombre qui le détache
// de n'importe quel sol, une couronne de runes qui tourne dans un sens, un puits
// dont les bras s'enroulent dans l'autre, et une lumière tout au fond.
//
// ⚠️ COMPOSITION NORMALE, pas additive : l'additif ne sait qu'éclaircir, et sur le
// sable du stage 3 l'ancien portail devenait une tache pâle. C'est le puits SOMBRE qui
// le fait lire sur un sol clair, et sa lumière sur un sol sombre.
//
// Le bord du dessin tombe sur le bord du quad : le portail tient dans sa case.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec4 rim_color : source_color = vec4(0.03, 0.06, 0.2, 1.0);
uniform vec4 deep_color : source_color = vec4(0.03, 0.05, 0.24, 1.0);
uniform vec4 arm_color : source_color = vec4(0.05, 0.42, 0.9, 1.0);
uniform vec4 glow_color : source_color = vec4(0.32, 0.9, 1.0, 1.0);
uniform vec4 core_color : source_color = vec4(0.9, 1.0, 1.0, 1.0);
uniform float seed = 0.0;
// Tour accumulé par le script : changer de cadence ne doit pas faire sauter le dessin.
uniform float spin = 0.0;
// Secondes écoulées, pour ce qui respire sans suivre la rotation.
uniform float phase = 0.0;
// 0 au repos, 1 quand le mage peut l'emprunter.
uniform float energy = 0.0;
// 1 à l'instant du saut, retombe à 0.
uniform float burst = 0.0;

const float RIM_OUT = 0.95;
const float RIM_IN = 0.73;
const float RUNES = 12.0;

// Un signe gravé par secteur de la couronne : barres et encoches changent d'un secteur
// à l'autre. `x` court le long de l'anneau, `y` en travers, tous deux de -1 à 1.
float rune(vec2 q, float id) {
	float pick = fract(id * 0.618 + 0.13);
	float stem = 1.0 - smoothstep(0.16, 0.26, abs(q.x - (pick - 0.5) * 0.7));
	float bar = 1.0 - smoothstep(0.14, 0.24, abs(q.y - (fract(pick * 7.0) - 0.5) * 1.1));
	bar *= 1.0 - smoothstep(0.4, 0.5, abs(q.x + (pick - 0.5) * 0.5));
	float mark = max(stem, bar);
	// Rien ne déborde du secteur : les signes restent séparés.
	return mark * (1.0 - smoothstep(0.62, 0.72, abs(q.x))) * (1.0 - smoothstep(0.6, 0.72, abs(q.y)));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	// Le saut gonfle le portail vers son bord, il ne sort jamais du quad.
	float scale = 1.0 - 0.04 * burst;
	d /= scale;

	// LE PUITS. La coordonnée log fait se resserrer les bras vers le centre, comme une eau
	// qu'on aspire, sans que leur vitesse apparente dépende du rayon.
	float depth = log(max(d, 0.02));
	float swirl = angle * 3.0 + depth * 5.6 + spin * 1.5 + seed;
	// ⚠️ Le bruit se lit dans le plan, pas en angle : l'angle saute d'un tour à ±π et
	// couperait la spirale. Faible et large, il ondule les bras sans les déchirer.
	float wobble = texture(noise, p * 0.16 + vec2(spin * 0.012, -spin * 0.008) + seed).r - 0.5;
	float arms = 0.5 + 0.5 * sin(swirl + wobble * 2.0);
	// Aplats nets, sans dégradé : le fond, le bras, son arête de lumière.
	float band_arm = smoothstep(0.5, 0.56, arms);
	float band_light = smoothstep(0.87, 0.92, arms);

	float lit = mix(0.42, 1.0, energy) + burst * 0.5;
	vec3 color = deep_color.rgb;
	color = mix(color, arm_color.rgb * mix(0.62, 1.0, energy), band_arm);
	color = mix(color, glow_color.rgb, band_light * clamp(lit, 0.0, 1.0));

	// La lumière du fond, en deux marches, qui respire un peu. Petite : c'est un point
	// au bout du puits, pas un disque posé dessus.
	float breath = 0.5 + 0.5 * sin(phase * 2.6 + seed * 6.0);
	float core_size = 0.065 + 0.015 * breath + 0.035 * energy + 0.13 * burst;
	color = mix(color, glow_color.rgb, 1.0 - smoothstep(core_size * 1.7, core_size * 1.9, d));
	color = mix(color, core_color.rgb, 1.0 - smoothstep(core_size * 0.82, core_size, d));

	// LA COURONNE, qui tourne à contre-sens du puits.
	float ring = smoothstep(RIM_IN - 0.015, RIM_IN + 0.015, d);
	if (ring > 0.0) {
		vec3 stone = mix(rim_color.rgb, arm_color.rgb, 0.28);
		float turn = fract((angle / TAU) * RUNES - spin * 0.09 + seed);
		float id = floor((angle / TAU + 0.5) * RUNES - spin * 0.09 + seed);
		vec2 q = vec2(turn * 2.0 - 1.0, ((d - RIM_IN) / (RIM_OUT - RIM_IN)) * 2.0 - 1.0);
		float mark = rune(q, mod(id, RUNES));
		// Les signes s'allument l'un après l'autre : au repos une lueur passe, sous
		// le mage ils brillent tous.
		float chase = 0.5 + 0.5 * sin(angle * 2.0 + phase * 1.6 + seed * 6.0);
		float bright = mix(0.3 + 0.55 * chase, 1.0, energy) + burst;
		stone = mix(stone, glow_color.rgb, mark * clamp(bright, 0.0, 1.0));
		color = mix(color, stone, ring);
	}

	// Deux filets clairs tiennent la couronne, puis le liseré sombre tout autour.
	float inner_line = 1.0 - smoothstep(0.012, 0.03, abs(d - RIM_IN));
	float outer_line = 1.0 - smoothstep(0.012, 0.03, abs(d - (RIM_OUT - 0.05)));
	color = mix(color, glow_color.rgb, max(inner_line, outer_line) * mix(0.55, 1.0, max(energy, burst)));
	color = mix(color, rim_color.rgb, smoothstep(RIM_OUT - 0.03, RIM_OUT - 0.01, d));

	// L'éclat du saut part du centre et traverse le puits jusqu'à la couronne.
	float wave = 1.0 - smoothstep(0.0, 0.1, abs(d - (1.0 - burst) * 0.9));
	color = mix(color, core_color.rgb, wave * burst);

	COLOR = vec4(color, 1.0 - smoothstep(RIM_OUT, RIM_OUT + 0.03, d));
}
