shader_type canvas_item;
render_mode blend_mix;

// LE GRAND ŒIL DE LA DISCORDE, plein et menaçant, qui flotte au-dessus d'elle :
//   1. LA DÉCHIRURE : une fente de lumière s'ouvre dans l'air, de son centre vers ses bords.
//   2. L'OUVERTURE : l'œil s'ouvre d'un coup, dépasse sa taille, dans un éclair, et l'ombre tombe.
//   3. LE REGARD : la pupille se serre brutalement, l'iris brûle et tourne, les veines battent, les
//      cils se hérissent, les fils descendent, et des aiguilles partent en étoile.
//   4. LA FIN : il se ferme d'un coup en une seule ligne, qui se réduit à rien.
// Ce sont les fils tracés par le jeu (DiscordThreads) qui portent le sort jusqu'aux ennemis.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.945);
const vec3 SILVER = vec3(0.788, 0.824, 0.839);
const vec3 MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 DEEP = vec3(0.416, 0.059, 0.29);
const vec3 BLACK = vec3(0.086, 0.102, 0.11);
const float NEEDLES = 16.0;
const float STRINGS = 9.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = BLACK;
	float alpha = 0.0;
	vec2 e = p / 0.82;
	float tear = smoothstep(0.0, 0.12, t);
	float x = clamp((t - 0.1) / 0.13, 0.0, 1.0) - 1.0;
	float pop = 1.0 + 2.7 * x * x * x + 1.7 * x * x;
	float close = 1.0 - smoothstep(0.8, 0.88, t);
	float vanish = 1.0 - smoothstep(0.88, 1.0, t);
	float open = pop * close;
	float wide = 1.0 - e.x * e.x;

	// L'ombre qui tombe : deux plaques franches, sans dégradé.
	float shade = length(p * vec2(1.0, 1.5));
	float dark = open * (shade < 0.96 ? 0.28 : 0.0) + open * (shade < 0.72 ? 0.24 : 0.0);
	if (dark > 0.0) {
		color = BLACK;
		alpha = dark;
	}

	// Les aiguilles et l'anneau qui part.
	float go = smoothstep(0.2, 0.8, t);
	float d = length(e);
	if (go > 0.0 && go < 1.0) {
		for (int i = 0; i < int(NEEDLES); i++) {
			float f = float(i);
			float a = f / NEEDLES * TAU + seed;
			vec2 dir = vec2(cos(a), sin(a));
			float along = dot(e, dir);
			float across = abs(dot(e, vec2(-dir.y, dir.x)));
			float tip = 0.42 + (0.3 + 0.5 * fract(f * 0.618)) * go;
			float needle = min((tip - along) * 0.08, 0.018 * (1.0 - go) + 0.002 - across);
			if (needle > 0.0 && along > tip - 0.26) {
				color = mod(f, 3.0) < 0.5 ? MAGENTA : SILVER;
				alpha = 1.0;
			}
		}
		float ring = 0.016 * (1.0 - go) + 0.002 - abs(d - 0.3 - go * 0.8);
		if (ring > 0.0) {
			color = PALE;
			alpha = 1.0;
		}
	}

	// Les fils qui pendent de la paupière basse, chacun avec son poids en losange.
	float lid = 0.5 * open;
	float low = lid * 0.78 * wide;
	float fall = smoothstep(0.2, 0.55, t) * close;
	for (int i = 0; i < int(STRINGS); i++) {
		float f = float(i);
		float at = (f / (STRINGS - 1.0) - 0.5) * 1.5;
		float reach = (1.0 - at * at) * lid * 0.78 + fall * (0.2 + 0.26 * fract(f * 0.73 + seed));
		float sway = sin(e.y * 9.0 + TIME * 4.0 + f) * 0.012;
		float string = 0.008 - abs(e.x - at - sway);
		if (string > 0.0 && e.y > low && e.y < reach) {
			color = SILVER;
			alpha = 1.0;
		}
		vec2 s = abs(e - vec2(at, reach));
		float weight = 0.04 * fall - (s.x * 1.3 + s.y * 0.8);
		if (weight > -0.012 && fall > 0.05) {
			color = weight > 0.0 ? MAGENTA : BLACK;
			alpha = 1.0;
		}
	}

	// Les cils : de longues pointes qui s'écartent vers les bords de l'œil.
	float high = lid * wide;
	float bent = e.x * (1.0 + e.y * 0.9);
	float tooth = 1.0 - abs(fract(bent * 5.5 + 0.5) - 0.5) * 2.0;
	float lash = high + 0.09 + 0.34 * open * wide * tooth * tooth + e.y;
	if (lash > -0.014 && e.y < -high && abs(e.x) < 0.94 && lid > 0.06) {
		color = lash > 0.0 ? mix(SILVER, PALE, smoothstep(0.03, 0.1, lash)) : BLACK;
		alpha = 1.0;
	}

	// La fente, avant que l'œil s'ouvre, et la ligne dans laquelle il se ferme.
	float span = t < 0.5 ? tear : vanish;
	float slit = (0.022 * sqrt(max(wide, 0.0)) + 0.002) - abs(e.y);
	if (slit > 0.0 && abs(e.x) < span && lid < 0.1) {
		color = mix(MAGENTA, PALE, smoothstep(0.0, 0.012, slit));
		alpha = 1.0;
	}

	// L'œil lui-même : un globe sombre, et non un contour.
	bool inside = e.y > -high && e.y < low && abs(e.x) < 1.0;
	if (inside && lid > 0.02) {
		float clench = 0.018 + 0.1 * smoothstep(0.3, 0.8, t) + 0.09 * (1.0 - smoothstep(0.16, 0.3, t));
		vec2 q = e - vec2(sin(TIME * 2.3 + seed * 5.0) * 0.05, 0.0);
		float r = length(q);
		float angle = atan(q.y, q.x);
		// Le blanc de l'œil est noir, veiné : c'est ce qui le rend méchant.
		color = mix(DEEP, BLACK, smoothstep(0.3, 0.85, r));
		float vein = abs(sin(angle * 7.0 + sin(r * 14.0 + seed * 9.0) * 1.2)) - 0.1;
		float pulse = 0.55 + 0.45 * sin(TIME * 9.0 - r * 10.0);
		if (vein < 0.0 && r > 0.3) {
			color = mix(color, MAGENTA, pulse);
		}
		float size = 0.34 + 0.018 * sin(TIME * 14.0);
		float iris = size - r;
		if (iris > -0.018) {
			float rays = 0.5 + 0.5 * cos(angle * 18.0 + TIME * 7.0 + sin(angle * 5.0) * 2.0);
			color = mix(BLACK, DEEP, smoothstep(-0.018, 0.012, iris));
			color = mix(color, MAGENTA, smoothstep(0.012, 0.06, iris + rays * 0.05));
			color = mix(color, PALE, smoothstep(0.17, 0.3, iris + rays * 0.09));
			float pupil = clench * (1.0 - q.y * q.y * 8.5) - abs(q.x);
			if (pupil > -0.012) {
				color = pupil > 0.0 ? BLACK : PALE;
			}
			if (length(q - vec2(-0.11, -0.13)) < 0.04) {
				color = vec3(1.0);
			}
		}
		// L'ombre de la paupière, en plaque franche.
		if (e.y < -high + 0.05 * wide) {
			color *= 0.45;
		}
		alpha = 1.0;
	}

	// Les paupières : un bandeau d'argent épais, effilé vers les coins, gravé d'un filet magenta.
	float band = 0.05 * wide + 0.006;
	float upper = band - abs(e.y + high + band * 0.5);
	float lower = band * 0.6 - abs(e.y - low - band * 0.3);
	float lids = max(upper, lower);
	if (lids > -0.012 && abs(e.x) < 1.02 && lid > 0.02) {
		color = lids > 0.0 ? SILVER : BLACK;
		if (upper > band * 0.32) {
			color = MAGENTA;
		} else if (lids > 0.0 && e.y < -high) {
			color = PALE;
		}
		alpha = 1.0;
	}

	// L'éclair de l'ouverture : quatre branches qui passent devant tout.
	float flash = 1.0 - smoothstep(0.1, 0.3, t);
	if (t > 0.08) {
		float star = flash * (1.1 * pow(abs(cos(atan(e.y, e.x) * 2.0)), 16.0) + 0.12) - d;
		if (star > 0.0) {
			color = PALE;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
