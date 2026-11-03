shader_type canvas_item;
render_mode blend_mix;

// L'ŒIL QUI GARDE : un œil d'or en amande, à iris saphir, s'ouvre au-dessus de l'ennemi touché
// et reste ouvert, le regard tourné vers lui. Il cligne de loin en loin.

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
	float open = smoothstep(0.0, 0.02, t);
	float blink = 1.0 - 0.9 * step(0.94, fract(TIME * 0.45 + seed));
	float lid = 0.42 * open * blink;
	vec3 color = BRONZE;
	float a = 0.0;
	// L'amande : deux arcs qui se rejoignent aux coins.
	float edge = lid * (1.0 - pow(abs(p.x) / 0.8, 2.0));
	float inside = edge - abs(p.y);
	if (abs(p.x) < 0.86 && inside > -0.08) {
		color = inside <= 0.0 ? RIM : (inside < 0.06 ? BRONZE : vec3(0.98, 0.96, 0.9));
		a = 1.0;
	}
	float iris = 0.26 - length(p - vec2(sin(TIME * 0.7 + seed) * 0.08, 0.0));
	if (iris > 0.0 && inside > 0.06) {
		color = iris > 0.14 ? DEEP : SAPPHIRE;
		if (length(p - vec2(-0.07, -0.07)) < 0.05) {
			color = PALE;
		}
		a = 1.0;
	}
	// Quatre petits rayons d'or au-dessus, comme sur la roue.
	for (int i = 0; i < 3; i++) {
		float x = (float(i) - 1.0) * 0.32;
		float ray = 0.03 - abs(p.x - x * (1.0 + (-p.y - 0.5) * 0.6));
		if (p.y < -0.5 && p.y > -0.85 && ray > -0.02 && open > 0.5) {
			color = ray > 0.0 ? BRONZE : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
