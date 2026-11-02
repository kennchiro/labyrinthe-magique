shader_type canvas_item;
render_mode blend_mix;

// L'EXPLOSION DE FEU, en quatre temps, comme une explosion animée à la main.
//
//   1. L'ÉCLAIR : une étoile fine et très vive, de biais. Rien n'a encore de volume.
//   2. LE GONFLEMENT : de gros lobes arrondis, pleins de lumière.
//   3. LE CREUSEMENT : des trous sombres s'ouvrent dedans, la lumière ne tient plus
//      que sur les bords.
//   4. LA FUMÉE : il reste des filets sombres, qui s'effilent et disparaissent.
//
// ⚠️ C'est le DÉCOUPAGE DANS LE TEMPS qui fait l'explosion, et la silhouette en lobes
// qui la rend lisible à petite taille. Le bruit ne sert qu'à casser le compas : un
// bruit fin à la place des lobes donne une bouillie qui grésille.
// Elle ne s'estompe JAMAIS : elle se réduit, et garde ses aplats jusqu'au bout.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
// Avancement, de 0 à 1.
uniform float progress = 0.0;
// 1 : la petite gerbe du coup de tous les jours, en trois lobes.
uniform float solid = 0.0;
// 1 : l'Extra, en neuf lobes, avec ses rayons qu'aucun autre sort ne doit imiter.
uniform float rays = 0.0;

const float FLASH_END = 0.16;

float smin(float a, float b, float k) {
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float tilt = seed * TAU;
	vec2 lean = vec2(cos(tilt), sin(tilt));
	// Le bruit tord les lobes, à très basse fréquence : il ne les découpe pas.
	vec2 warp = vec2(texture(noise, p * 0.2 + seed).r, texture(noise, p * 0.2 + seed + 0.5).r) - 0.5;
	vec2 q = p + warp * 0.3;

	float grow = 1.0 - pow(1.0 - clamp((progress - 0.05) / 0.3, 0.0, 1.0), 3.0);
	float count = rays > 0.5 ? 9.0 : (solid > 0.5 ? 3.0 : 6.0);
	float size = rays > 0.5 ? 0.86 : (solid > 0.5 ? 1.25 : 1.0);
	float open = smoothstep(0.24, 0.8, progress) * 0.92;
	float body = 10.0;
	float holes = 10.0;
	for (float k = 0.0; k < count; k += 1.0) {
		float angle = k * 2.399 + tilt;
		float reach = 0.16 + 0.44 * fract(k * 0.37 + seed * 1.7);
		float radius = (0.21 + 0.17 * fract(k * 0.618 + seed * 3.1)) * size * grow;
		// Tout penche d'un côté : c'est ce qui donne une direction au coup.
		vec2 center = (vec2(cos(angle), sin(angle)) * reach + lean * 0.1) * grow;
		float lobe = length(q - center) - radius;
		body = smin(body, lobe, 0.09);
		// Son trou : décalé vers l'extérieur, il laisse un croissant côté centre.
		vec2 away = center + normalize(center + vec2(0.001)) * radius * 0.16;
		holes = min(holes, length(q - away) - radius * open);
	}
	float carved = min(-body, holes);
	// LA FUMÉE : ce qui reste s'amincit, de façon inégale, jusqu'à disparaître.
	float fray = texture(noise, q * 0.42 + seed * 0.7).r;
	carved -= pow(smoothstep(0.56, 1.0, progress), 1.6) * (0.012 + fray * 0.15);

	// La chaleur vient de la profondeur, et elle retombe avec le temps.
	float depth = clamp(carved / 0.2, 0.0, 1.0);
	float heat = depth * (1.25 - smoothstep(0.14, 0.72, progress) * 1.25);
	vec3 color = vec3(0.13, 0.045, 0.05);
	color = mix(color, vec3(0.5, 0.05, 0.03), smoothstep(0.03, 0.09, heat));
	color = mix(color, vec3(1.0, 0.32, 0.04), smoothstep(0.18, 0.28, heat));
	color = mix(color, vec3(1.0, 0.76, 0.12), smoothstep(0.42, 0.54, heat));
	color = mix(color, vec3(1.0, 0.98, 0.8), smoothstep(0.72, 0.86, heat));
	float alpha = smoothstep(0.0, 0.012, carved) * step(0.04, grow);

	// L'ÉCLAIR : deux lames croisées, très fines, qui naissent avant toute matière.
	vec2 s = mat2(vec2(lean.x, -lean.y), vec2(lean.y, lean.x)) * p;
	float life = 1.0 - clamp(progress / FLASH_END, 0.0, 1.0);
	float span = (solid > 0.5 ? 0.46 : 0.86) * sqrt(clamp(progress / 0.05, 0.0, 1.0));
	float blade_a = 0.075 * life * (1.0 - abs(s.x) / max(span, 0.01)) - abs(s.y);
	float blade_b = 0.05 * life * (1.0 - abs(s.y) / max(span * 0.62, 0.01)) - abs(s.x);
	float star = max(blade_a, blade_b);
	if (star > 0.0) {
		color = mix(vec3(1.0, 0.78, 0.18), vec3(1.0, 1.0, 0.9), smoothstep(0.0, 0.016, star));
		alpha = 1.0;
	}

	// LES RAYONS DE L'EXTRA : longs, droits, le temps du gonflement seulement.
	if (rays > 0.5) {
		float a = atan(s.y, s.x);
		float d = length(s);
		float beam = pow(abs(cos(a * 5.5 + seed * 3.0)), 26.0);
		float out_at = smoothstep(0.03, 0.26, progress) * 0.98;
		// Ils s'effilent jusqu'à une pointe : à largeur constante, ils finissaient en bâton.
		float blaze = (beam - 0.42 - 0.56 * clamp(d / max(out_at, 0.05), 0.0, 1.0)) * (1.0 - smoothstep(0.18, 0.42, progress)) * smoothstep(0.1, 0.34, d) * step(d, out_at);
		if (blaze > 0.0 && alpha < 0.5) {
			color = mix(vec3(1.0, 0.42, 0.05), vec3(1.0, 0.92, 0.5), smoothstep(0.0, 0.3, blaze));
			alpha = smoothstep(0.0, 0.05, blaze);
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
