shader_type canvas_item;
render_mode blend_mix;

// L'ÉPÉE PLANTÉE : elle tombe et s'enfonce au centre du jardin, poignée de bronze en haut, lame de
// flamme saphir qui brûle debout tant que le jardin tient, puis elle remonte. UV.y : ciel (0), sol (1).

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
	float x = (UV.x - 0.5) * 2.0;
	float y = UV.y;
	float t = progress;
	// La pointe s'enfonce dans le sol, en bas du quad, en tombant d'en haut.
	float drop = mix(-0.6, 0.0, smoothstep(0.0, 0.05, t)) - smoothstep(0.93, 1.0, t) * 1.2;
	float q = 0.97 - y + drop;   // hauteur au-dessus du sol, en part du quad
	vec3 color = SAPPHIRE;
	float a = 0.0;
	float hw = -1.0;
	int zone = 0;
	if (q > 0.0 && q < 0.5) {
		float k = q / 0.5;
		hw = 0.3 + 0.1 * sin(q * 30.0 - TIME * 14.0 + seed) * k - 0.12 * k;
		hw *= (q < 0.05 ? q / 0.05 : 1.0);
		zone = 1;
	} else if (q >= 0.5 && q < 0.54) {
		hw = 0.75;
		zone = 2;
	} else if (q >= 0.54 && q < 0.66) {
		hw = 0.12;
		zone = 3;
	} else if (q >= 0.66 && q < 0.71) {
		hw = 0.2;
		zone = 2;
	}
	float inside = hw - abs(x);
	if (zone > 0 && inside > -0.08) {
		a = 1.0;
		if (inside <= 0.0) {
			color = RIM;
		} else if (zone == 1) {
			color = inside > hw * 0.55 ? PALE : (inside > hw * 0.2 ? SAPPHIRE : DEEP);
		} else if (zone == 2) {
			color = BRONZE;
		} else {
			color = DEEP;
		}
	}
	// Les flammèches qui s'en échappent vers le ciel.
	for (int i = 0; i < 4; i++) {
		float f = float(i);
		float rise_ = fract(TIME * 0.9 + hash(f));
		vec2 c = vec2((hash(f + 3.0) - 0.5) * 0.7, 0.97 + drop - 0.1 - rise_ * 0.5);
		float spark = 0.12 * (1.0 - rise_) - length(vec2((x - c.x) * 0.5, (y - c.y) * 3.0));
		if (spark > 0.0 && t > 0.06 && t < 0.93) {
			color = spark > 0.06 ? PALE : SAPPHIRE;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
