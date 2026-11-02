shader_type canvas_item;
render_mode blend_mix;

// LE GEYSER : l'eau jaillit du sol, s'ouvre en couronne au sommet et retombe en gouttes.
//
// ⚠️ Pas de cœur blanc au milieu du jet : c'est la structure d'une flamme, et la colonne
// se lisait comme un feu bleu. Ici le corps reste bleu, strié de filets, et le blanc est
// réservé à l'écume : le dessus de la couronne, les gouttes, le bord de la flaque.
//
// Tout se calcule en CASES depuis le point d'impact : le quad fait 2,2 x 4,4 cases, et un
// rond doit y rester rond. Le pied est décollé du bas du quad pour ne pas y être coupé.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

const float PEAK = 3.0;
const int DROPS = 12;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 q = vec2((UV.x - 0.5) * 2.2, (1.0 - UV.y - 0.07) * 4.4);
	float rise = 1.0 - pow(1.0 - clamp(progress / 0.3, 0.0, 1.0), 3.0);
	// ⚠️ La poussée finie, tout retombe d'un bloc dans la flaque. Une colonne qui se vidait
	// par le bas laissait sa couronne flotter en l'air, comme une méduse.
	float fall = smoothstep(0.52, 0.94, progress);
	float top = PEAK * rise * (1.0 - fall * fall);
	float standing = 1.0 - smoothstep(0.86, 1.0, progress);

	float n = texture(noise, vec2(q.x * 0.22 + seed, q.y * 0.16 - progress * 1.5)).r - 0.5;
	float width = 0.2 + 0.07 * q.y + n * 0.2;
	float along = min(q.y, top - q.y);
	float column = min(width - abs(q.x), along * 0.5) * standing;

	// La couronne : un parasol d'eau qui retombe de chaque côté, fin à ses extrémités.
	float open = smoothstep(0.02, 0.42, progress) * standing;
	float span = 0.3 + 0.72 * open;
	float reach = abs(q.x) / span;
	float arch = top + 0.14 - reach * reach * (0.5 + 0.5 * open) + n * 0.34;
	float crown = (0.17 * (1.0 - reach * reach) + 0.012) * smoothstep(0.0, 0.12, open) - abs(q.y - arch);
	crown = reach < 1.0 ? crown : -1.0;

	// Les gouttes partent de la couronne, en cloche, et rapetissent en retombant.
	float drops = -1.0;
	for (int i = 0; i < DROPS; i++) {
		// Un seul sinus par goutte, le reste s'en déduit : ce calcul tourne à chaque pixel
		// de neuf colonnes à la fois.
		float h = hash(float(i));
		float age = progress - 0.2 - h * 0.28;
		if (age > 0.0) {
			float side = fract(h * 7.13) * 2.0 - 1.0;
			vec2 at = vec2(side * (0.3 + 1.9 * age), PEAK - 0.2 + (2.8 + fract(h * 3.71) * 2.4) * age - 11.0 * age * age);
			drops = max(drops, (0.12 - fract(h * 11.3) * 0.04) * (1.0 - age * 0.8) - length(q - at));
		}
	}

	// Au pied : une flaque en ellipse, et l'onde qu'elle pousse devant elle.
	vec2 flat_q = q * vec2(1.0, 2.5);
	float pool = (0.24 + 0.2 * rise + n * 0.1) * standing - length(flat_q);
	float ripple_at = 0.5 + progress * 0.62;
	float ripple = 0.035 * (1.0 - progress) - abs(length(flat_q) - ripple_at);

	float heat = max(column, max(crown, max(drops, max(pool, ripple))));
	// Les filets remontent le jet : ce sont eux qui le font couler au lieu de brûler.
	float strand = sin(q.x * 19.0 + n * 7.0 + q.y * 1.2);
	vec3 color = mix(vec3(0.03, 0.27, 0.68), vec3(0.08, 0.5, 0.94), smoothstep(0.012, 0.03, heat));
	color = mix(color, vec3(0.5, 0.87, 1.0), smoothstep(0.35, 0.55, strand) * smoothstep(0.04, 0.08, column));
	// L'écume : le dessus du parasol, le cœur des gouttes, un liseré cassé autour de la flaque.
	float crest = smoothstep(0.05, 0.09, crown) * step(arch, q.y + 0.03);
	float lip = smoothstep(0.015, 0.035, pool) * smoothstep(0.1, 0.07, pool) * smoothstep(-0.1, 0.02, n);
	color = mix(color, vec3(1.0), max(crest, max(smoothstep(0.03, 0.06, drops), lip)));
	COLOR = vec4(color, smoothstep(0.0, 0.012, heat) * COLOR.a);
}
