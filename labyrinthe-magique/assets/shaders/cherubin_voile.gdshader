shader_type canvas_item;
render_mode blend_mix;

// LES AILES VOILÉES : sa seconde paire d'ailes se referme devant lui comme une coque blanche, aux
// yeux d'or ouverts, cernée d'une flamme saphir. Elle se rouvre à la fin.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.933, 0.953, 1.0);
const vec3 SAPPHIRE = vec3(0.239, 0.42, 1.0);
const vec3 DEEP = vec3(0.102, 0.184, 0.62);
const vec3 BRONZE = vec3(0.878, 0.627, 0.29);
const vec3 RIM = vec3(0.078, 0.102, 0.18);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float close = smoothstep(0.0, 0.15, t) * (1.0 - smoothstep(0.85, 1.0, t));
	vec3 color = PALE;
	float a = 0.0;
	// Deux ailes qui se referment l'une sur l'autre : chacune large en haut, effilée en bas, le bord
	// extérieur festonné en plumes, les rangs de plumes en chevrons.
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		float x = p.x * sgn;
		float gap = 0.4 * (1.0 - close);
		float u = x - gap;
		float y = p.y;
		float k = clamp((y + 0.85) / 1.75, 0.0, 1.0);          // 0 en haut, 1 en bas
		float width = 0.72 * sin(3.1416 * clamp(k * 0.95 + 0.05, 0.0, 1.0)) * (1.0 - 0.45 * k);
		width *= 0.86 + 0.14 * abs(sin(y * 9.0));
		float inside = min(u + 0.04, width - u);
		if (k > 0.0 && k < 1.0 && inside > -0.04 && close > 0.0) {
			a = 1.0;
			if (inside <= 0.0) {
				color = RIM;
			} else if (k > 0.72 || u > width - 0.12) {
				color = SAPPHIRE;
			} else {
				color = fract(y * 4.0 - u * 2.0) < 0.5 ? PALE : vec3(0.84, 0.87, 0.95);
			}
			vec2 q = vec2(u - 0.3, y + 0.25);
			float lid = 0.11 * (1.0 - pow(abs(q.x) / 0.2, 2.0)) - abs(q.y);
			if (abs(q.x) < 0.21 && lid > -0.03) {
				color = lid <= 0.0 ? RIM : (length(q) < 0.06 ? DEEP : BRONZE);
			}
		}
	}
	// La flamme qui la cerne.
	float d = length(p * vec2(0.9, 0.85));
	float fire = 0.05 * close - abs(d - 0.86 - 0.04 * sin(atan(p.y, p.x) * 12.0 + TIME * 16.0));
	if (fire > -0.02 && close > 0.0) {
		color = fire > 0.02 ? PALE : (fire > 0.0 ? SAPPHIRE : RIM);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
