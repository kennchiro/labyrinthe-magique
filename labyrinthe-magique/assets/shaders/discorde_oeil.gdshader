shader_type canvas_item;
render_mode blend_mix;

// LE MAUVAIS ŒIL, vif et aux aguets, au-dessus du possédé :
//   1. L'OUVERTURE : il claque en un sixième de seconde, dépasse sa taille et se rattrape, dans un
//      éclair à quatre branches et un anneau qui part.
//   2. L'EMPRISE : le regard saute d'un point à l'autre sans glisser, la pupille se serre à chaque
//      saut, l'iris tourne et bat, des cils d'argent le hérissent, et des anneaux partent.
//   3. LA FIN : il tremble pendant une demi-seconde, puis se ferme d'un coup en une seule ligne.
// Tout est compté en secondes, et non en part de la durée : sinon il s'ouvrait en une demi-seconde.

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float seconds = 5.0;

const vec3 PALE = vec3(1.0, 0.89, 0.945);
const vec3 SILVER = vec3(0.788, 0.824, 0.839);
const vec3 MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 DEEP = vec3(0.416, 0.059, 0.29);
const vec3 BLACK = vec3(0.086, 0.102, 0.11);
const float SIZE = 0.44;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	float spent = progress * seconds;
	float left = seconds - spent;
	vec2 p = (UV - 0.5) * 2.0 / SIZE;
	p.y += sin(TIME * 3.4 + seed * 7.0) * 0.07;
	if (left < 0.5) {
		p.x += sin(TIME * 70.0) * 0.05;
	}
	float x = clamp(spent / 0.16, 0.0, 1.0) - 1.0;
	float pop = 1.0 + 2.7 * x * x * x + 1.7 * x * x;
	float close = clamp(left / 0.12, 0.0, 1.0);
	float cycle = fract(TIME * 0.42 + seed * 3.0);
	float blink = 1.0 - 0.95 * (1.0 - smoothstep(0.0, 0.035, abs(cycle - 0.5)));
	float lid = max(0.018, 0.6 * pop * close * blink);
	float edge = lid * (1.0 - p.x * p.x) - abs(p.y);
	vec3 color = BLACK;
	float alpha = 0.0;
	float beat = fract(TIME * 1.1 + seed);
	// Les anneaux qui partent, et celui de l'ouverture, plus large.
	vec2 flat_p = p * vec2(1.0, 1.55);
	float d = length(flat_p);
	float wave = 0.045 * (1.0 - beat) - abs(d - 0.95 - beat * 0.95);
	float gaps = abs(fract(atan(flat_p.y, flat_p.x) * 8.0 / TAU + TIME * 0.5) - 0.5) - 0.12;
	if (min(wave, gaps) > 0.0) {
		color = MAGENTA;
		alpha = 1.0;
	}
	float burst = spent / 0.3;
	if (burst < 1.0) {
		float ring = 0.09 * (1.0 - burst) - abs(d - burst * 2.0);
		float star = (1.0 - burst) * (1.5 * pow(abs(cos(atan(p.y, p.x) * 2.0)), 14.0) + 0.1) - length(p);
		if (ring > 0.0 || star > 0.0) {
			color = PALE;
			alpha = 1.0;
		}
	}
	// Les cils : des pointes d'argent au-dessus de la paupière, plus longues au centre.
	float top = lid * (1.0 - p.x * p.x);
	float tooth = 1.0 - abs(fract(p.x * 4.5 + 0.5) - 0.5) * 2.0;
	float lash = min(top + 0.1 + 0.34 * pop * close * (1.0 - p.x * p.x) * tooth * tooth + p.y, -p.y - top);
	if (lash > -0.035 && abs(p.x) < 0.92 && lid > 0.1) {
		color = lash > 0.0 ? mix(SILVER, PALE, smoothstep(0.03, 0.09, lash)) : BLACK;
		alpha = 1.0;
	}
	if (edge > -0.075 && abs(p.x) < 1.04) {
		color = BLACK;
		alpha = 1.0;
	}
	if (edge > 0.0) {
		float step_id = floor(TIME * 2.3 + seed * 9.0);
		float jump = fract(TIME * 2.3 + seed * 9.0);
		vec2 gaze = vec2(hash(step_id) - 0.5, (hash(step_id + 4.0) - 0.5) * 0.28) * 0.74;
		vec2 q = p - gaze;
		float size = 0.47 + 0.035 * sin(TIME * 11.0);
		float iris = size - length(q);
		float vein = abs(sin(atan(q.y, q.x) * 6.0 + sin(length(q) * 11.0 + seed * 9.0))) - 0.13;
		color = mix(DEEP, BLACK, smoothstep(0.35, 0.95, length(q)));
		if (vein < 0.0) {
			color = MAGENTA;
		}
		if (iris > 0.0) {
			float angle = atan(q.y, q.x);
			float rays = 0.5 + 0.5 * cos(angle * 14.0 + TIME * 4.0);
			color = mix(DEEP, MAGENTA, smoothstep(0.0, 0.07, iris));
			color = mix(color, PALE, smoothstep(0.12, 0.4, iris) * (0.25 + 0.75 * rays));
			float tight = mix(0.045, 0.13, smoothstep(0.0, 0.35, jump));
			float pupil = tight * (1.0 - q.y * q.y * 4.4) - abs(q.x);
			if (pupil > 0.0) {
				color = BLACK;
			}
			if (length(q - vec2(-0.15, -0.17)) < 0.075) {
				color = vec3(1.0);
			}
		}
		if (edge < 0.035) {
			color = SILVER;
		}
	}
	// Trois éclats en orbite, qui disent qu'il est sous emprise même de loin.
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float angle = f * TAU / 3.0 + TIME * 3.0;
		vec2 at = vec2(cos(angle) * 1.22, sin(angle) * 0.62);
		vec2 s = abs(p - at);
		if (0.105 - (s.x + s.y) > 0.0 && close > 0.5) {
			color = mod(f, 2.0) < 0.5 ? PALE : MAGENTA;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
