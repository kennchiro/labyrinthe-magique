shader_type canvas_item;
render_mode blend_mix;

// L'ONDE DU MARTEAU : un grand croissant d'acier bordé de métal chauffé, un second plus pâle qui le
// suit, et des éclats arrachés au sol derrière lui. La pointe du dessin regarde vers la droite.

uniform float seed = 0.0;

const vec3 WHITE = vec3(1.0, 0.957, 0.878);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 STEEL = vec3(0.875, 0.902, 0.933);
const vec3 DARK = vec3(0.227, 0.267, 0.314);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float CHIPS = 7.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

// Une lame courbe : épaisse au milieu, effilée aux deux bouts.
float crescent(vec2 p, float radius, float width) {
	float a = atan(p.y, p.x);
	return width * (1.0 - pow(abs(a) / 1.25, 2.0)) - abs(length(p) - radius);
}

void fragment() {
	vec2 p = (UV - 0.5) * vec2(1.6, 1.0);
	float front = crescent(p + vec2(0.22, 0.0), 0.72, 0.1);
	float back = crescent(p + vec2(0.42, 0.0), 0.62, 0.05);
	vec3 color = DARK;
	float alpha = step(-0.012, back);
	color = back > 0.0 ? HOT : RIM;
	if (front > -0.016) {
		alpha = 1.0;
		color = front > 0.05 ? WHITE : (front > 0.022 ? STEEL : (front > 0.0 ? HOT : RIM));
	}
	for (int i = 0; i < int(CHIPS); i++) {
		float f = float(i);
		float run = fract(TIME * 2.4 + hash(f));
		vec2 at = vec2(0.2 - run * 0.95, (hash(f + 3.0) - 0.5) * 0.74);
		vec2 q = abs(p - at);
		float chip = 0.045 * (1.0 - run) + 0.008 - q.x - q.y;
		if (chip > 0.0 && alpha < 0.5) {
			color = hash(f + 6.0) > 0.5 ? HOT : STEEL;
			alpha = 1.0 - run * 0.6;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
