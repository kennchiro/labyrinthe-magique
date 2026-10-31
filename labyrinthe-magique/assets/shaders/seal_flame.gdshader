shader_type canvas_item;
render_mode blend_mix;

// LES QUATRE SCEAUX DU SUPRÊME : la flamme de la Boule de feu, dressée à la verticale.
//
// C'est la même flamme pour les quatre, À LA DEMANDE DU JOUEUR : ce qu'il aime, c'est la
// chevelure de la boule, en aplats nets, et l'eau, la terre et l'air doivent la reprendre
// dans leurs couleurs. Ici la palette n'est donc pas une facilité, c'est le dessin voulu.
//
// Du sol vers le haut : un halo, une onde et des braises, le socle gravé qui tourne,
// deux petites flammes de côté, la grande au centre, et les étincelles qui s'échappent.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
// 0 feu, 1 eau, 2 terre, 3 air.
uniform int kind = 0;

const vec2 BASE = vec2(0.0, 0.5);
const vec2 RING = vec2(0.68, 0.34);

// La traînée de `fire_ball.gdshader`, redressée : `up` monte le long de la flamme.
float flame(vec2 p, float at, float reach, float radius, float t, float phase) {
	float up = BASE.y - p.y;
	float x = p.x - at;
	float behind = clamp(up / reach, 0.0, 1.0);
	vec2 streak = vec2(-up * 0.09 + t * 0.95 + phase, x * 0.36 + phase * 0.37);
	float tongue = texture(noise, streak).r - 0.5;
	float bend = texture(noise, streak * vec2(0.5, 0.35) + 0.31).r - 0.5;
	float y = x + bend * behind * 0.42;
	// Effilée : c'est sa pointe qui fait la chevelure de la boule.
	float wide = radius * 1.28 * (1.0 + behind * 0.35) * pow(1.0 - behind, 1.1);
	float heat = 1.0 - abs(y) / max(wide, 0.001);
	heat += tongue * (0.35 + behind * 1.7) - behind * 0.28;
	// Sous le socle, un pied arrondi qui prolonge exactement la flamme, sans couture.
	if (up < 0.0) {
		heat = 1.0 - length(vec2(x, up * 2.4)) / (radius * 1.28) + tongue * 0.35;
	}
	// Au-delà de sa hauteur, la chaleur tombe : un zéro laisserait la lueur s'y allumer
	// et dessinerait un rectangle.
	return heat - smoothstep(0.86, 1.0, up / reach) * 3.0 - step(1.0, up / reach) * 3.0;
}

void fragment() {
	vec3 core_color = vec3(1.0, 0.98, 0.78);
	vec3 hot_color = vec3(1.0, 0.78, 0.12);
	vec3 flame_color = vec3(1.0, 0.32, 0.04);
	vec3 edge_color = vec3(0.55, 0.04, 0.02);
	if (kind == 1) {
		core_color = vec3(0.92, 1.0, 1.0); hot_color = vec3(0.3, 0.8, 1.0);
		flame_color = vec3(0.05, 0.42, 0.98); edge_color = vec3(0.02, 0.12, 0.52);
	} else if (kind == 2) {
		core_color = vec3(0.97, 1.0, 0.66); hot_color = vec3(0.72, 0.88, 0.18);
		flame_color = vec3(0.44, 0.62, 0.1); edge_color = vec3(0.2, 0.11, 0.03);
	} else if (kind == 3) {
		core_color = vec3(1.0); hot_color = vec3(0.86, 0.96, 1.0);
		flame_color = vec3(0.56, 0.76, 0.86); edge_color = vec3(0.22, 0.34, 0.44);
	}

	vec2 p = (UV - 0.5) * 2.0;
	float t = TIME + seed * 7.0;
	vec2 q = (p - BASE) / RING;
	float d = length(q);
	vec3 color = edge_color;
	float alpha = 0.0;

	// LE HALO SUR LE SOL, et ses ondes qui partent du pied de la flamme.
	float pool = smoothstep(1.3, 0.55, d);
	float wave = smoothstep(0.7, 1.0, sin(d * 13.0 - t * 4.4)) * smoothstep(1.1, 0.5, d);
	color = mix(flame_color, hot_color, wave);
	alpha = pool * 0.34 + wave * 0.5;

	// LES BRAISES DU SOCLE : elles battent sous la flamme.
	float ember = texture(noise, p * 0.34 + vec2(t * 0.03, seed)).r;
	float embers = smoothstep(0.58, 0.72, ember) * smoothstep(0.96, 0.76, d);
	color = mix(color, hot_color, embers);
	alpha = max(alpha, embers * 0.85);

	// LE SOCLE GRAVÉ : deux anneaux et des signes qui tournent en sens contraire.
	float angle = atan(q.y, q.x);
	float rings = min(abs(d - 0.97), abs(d - 0.74));
	float signs = step(0.45, fract((angle + t * 0.5) * 12.0 / TAU)) * smoothstep(0.1, 0.06, abs(d - 0.855));
	float spikes = pow(abs(cos((angle - t * 0.3) * 2.0)), 40.0) * smoothstep(0.22, 0.0, abs(d - 1.05));
	float line = max(max(smoothstep(0.036, 0.014, rings), signs), spikes);
	color = mix(color, mix(hot_color, core_color, 0.5), line);
	alpha = max(alpha, line);

	// LES FLAMMES : deux petites de côté, la grande devant elles.
	float side_a = flame(p, -0.44, 0.86, 0.13, t * 1.15, 0.31 + seed);
	float side_b = flame(p, 0.45, 1.02, 0.15, t * 1.05, 0.67 + seed);
	float main_heat = flame(p, 0.0, 1.46, 0.3, t, seed);
	float heat = max(main_heat, max(side_a, side_b));

	// Sa lueur autour d'elle, d'abord, pour qu'elle se détache du sol.
	float aura = smoothstep(-0.34, 0.0, heat) * 0.3;
	if (aura > alpha) {
		color = flame_color;
		alpha = aura;
	}
	float behind = clamp((BASE.y - p.y) / 1.42, 0.0, 1.0);
	vec3 body = edge_color;
	body = mix(body, flame_color, smoothstep(0.1, 0.19, heat));
	body = mix(body, hot_color, smoothstep(0.36, 0.47, heat));
	body = mix(body, core_color, smoothstep(0.66, 0.78, heat) * (1.0 - behind));
	float solid = smoothstep(0.0, 0.08, heat);
	color = mix(color, body, solid);
	alpha = max(alpha, solid);

	// LES ÉTINCELLES : chacune monte en oscillant et s'éteint en route.
	for (int i = 0; i < 7; i++) {
		float k = float(i);
		float rise = fract(t * (0.34 + k * 0.03) + k * 0.41);
		vec2 at = vec2(sin(k * 2.7) * 0.62 + sin(t * 2.0 + k) * 0.06, BASE.y - rise * 1.4);
		float spark = smoothstep(0.034, 0.012, length(p - at)) * smoothstep(1.0, 0.65, rise);
		if (spark > 0.0) {
			color = mix(color, core_color, spark);
			alpha = max(alpha, spark);
		}
	}
	// Rien n'atteint le bord du quad.
	alpha *= smoothstep(1.0, 0.92, abs(p.x)) * smoothstep(1.0, 0.94, abs(p.y));
	COLOR = vec4(color, alpha * COLOR.a);
}
