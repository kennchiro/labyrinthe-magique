shader_type canvas_item;
render_mode blend_mix;

// LA GRIFFURE, en quatre temps :
//   1. L'ÉCLAIR : une étoile pâle, à l'instant du contact.
//   2. LES TROIS ENTAILLES s'ouvrent l'une après l'autre, aux bords déchiquetés.
//   3. LE SANG jaillit des plaies en gerbes, et retombe. Des éclats d'or partent en étoile.
//   4. LA FIN : les plaies se referment en fils noirs. Rien ne s'estompe, tout se réduit.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float DROPS = 12.0;
const float SPARKS = 6.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 r = vec2(p.x * 0.5 - p.y * 0.866, p.x * 0.866 + p.y * 0.5);
	float best = -1.0;
	for (int i = 0; i < 3; i++) {
		float rank = float(i) - 1.0;
		float run = clamp((progress - float(i) * 0.04) / 0.16, 0.0, 1.0);
		float span = 0.76 * run;
		float along = clamp(abs(r.x) / max(span, 0.001), 0.0, 1.0);
		float open = 1.0 - smoothstep(0.42, 0.92, progress);
		float torn = (0.008 * sin(r.x * 23.0 + rank * 5.0 + seed * 9.0) + 0.004 * sin(r.x * 61.0 + rank)) * open;
		float cut = 0.1 * open * (1.0 - along * along) + 0.006 - abs(r.y - rank * 0.28 + torn);
		best = max(best, min(cut, span - abs(r.x)));
	}
	vec3 color = mix(CRIMSON, PALE, smoothstep(0.035, 0.065, best));
	color = mix(DEEP, color, smoothstep(0.006, 0.02, best));
	color = mix(BLACK, color, smoothstep(0.0, 0.006, best));
	float alpha = smoothstep(-0.006, 0.0, best);
	// Le sang : chaque goutte part à la perpendiculaire de sa plaie, puis la gravité la reprend.
	for (int i = 0; i < int(DROPS); i++) {
		float f = float(i);
		float life = clamp((progress - 0.08 - hash(f) * 0.12) / 0.75, 0.0, 1.0);
		float side = mod(f, 2.0) * 2.0 - 1.0;
		vec2 from = vec2((hash(f + 3.0) - 0.5) * 1.0, (mod(f, 3.0) - 1.0) * 0.28);
		vec2 flight = vec2(from.x * 0.5, side * (0.3 + hash(f + 5.0) * 0.5)) * life;
		vec2 at_r = from + flight;
		vec2 at = vec2(at_r.x * 0.5 + at_r.y * 0.866, -at_r.x * 0.866 + at_r.y * 0.5);
		at.y += life * life * 0.5;
		vec2 d = p - at;
		float drop = (0.05 * (1.0 - life) + 0.008) - length(d * vec2(1.0, 0.7));
		if (drop > 0.0 && life > 0.0 && life < 1.0 && alpha < 0.5) {
			color = drop > 0.024 ? CRIMSON : DEEP;
			alpha = 1.0;
		}
	}
	for (int i = 0; i < int(SPARKS); i++) {
		float f = float(i) + 40.0;
		float angle = hash(f) * TAU;
		float life = clamp(progress * 1.6 - hash(f + 2.0) * 0.15, 0.0, 1.0);
		vec2 d = abs(p - vec2(cos(angle), sin(angle)) * life * 0.85);
		float spark = 0.075 * (1.0 - life) - (d.x + d.y);
		if (spark > 0.0 && life > 0.0 && life < 1.0 && alpha < 0.5) {
			color = spark > 0.035 ? PALE : GOLD;
			alpha = 1.0;
		}
	}
	// L'éclair du contact passe devant tout.
	float flash = 1.0 - clamp(progress / 0.13, 0.0, 1.0);
	float star = flash * 0.3 - (pow(abs(p.x), 0.55) + pow(abs(p.y), 0.55)) * 0.32;
	if (star > 0.0) {
		color = PALE;
		alpha = 1.0;
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
