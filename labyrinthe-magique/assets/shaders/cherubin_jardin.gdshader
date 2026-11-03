shader_type canvas_item;
render_mode blend_mix;

// LE JARDIN GARDÉ : un grand cercle de flammes saphir jaillit autour de l'épée plantée, haut comme
// une haie, et des yeux d'or s'ouvrent sur lui, tournés vers le dehors. À la fin il se resserre.
// Le cercle tombe aux quatre cinquièmes du quad : c'est là qu'est le rayon du sort.

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
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = progress;
	float rise = smoothstep(0.0, 0.06, t);
	float shrink = 1.0 - smoothstep(0.93, 1.0, t);
	float radius = 0.8 * mix(0.15, 1.0, rise) * mix(0.0, 1.0, shrink);
	vec3 color = SAPPHIRE;
	float a = 0.0;
	// Le sol du jardin : un aplat bleu nuit, léger.
	if (d < radius - 0.05) {
		color = DEEP;
		a = 0.22;
	}
	// Le mur de flammes : des langues qui montent vers l'extérieur, et dansent.
	float tongue = 0.09 + 0.06 * abs(sin(angle * 18.0 + TIME * 7.0 + seed)) + 0.03 * sin(angle * 31.0 - TIME * 11.0);
	float out_ = d - radius;
	float wall = (out_ > -0.05 && out_ < tongue) ? tongue - out_ : -1.0;
	if (wall > -0.025 && shrink > 0.0) {
		float k = (out_ + 0.05) / (tongue + 0.05);
		color = wall <= 0.0 ? RIM : (k < 0.35 ? PALE : (k < 0.75 ? SAPPHIRE : DEEP));
		a = 1.0;
	}
	// Huit yeux sur le cercle, qui regardent dehors.
	for (int i = 0; i < 8; i++) {
		float at = float(i) * 0.785 + seed;
		vec2 dir = vec2(cos(at), sin(at));
		vec2 q = p - dir * (radius - 0.02);
		vec2 l = vec2(dot(q, vec2(-dir.y, dir.x)), dot(q, dir));
		float open = smoothstep(0.08, 0.2, t) * shrink;
		float lid = 0.05 * open * (1.0 - pow(abs(l.x) / 0.1, 2.0)) - abs(l.y);
		if (abs(l.x) < 0.105 && lid > -0.015 && open > 0.0) {
			color = lid <= 0.0 ? RIM : (length(l - vec2(0.0, 0.012)) < 0.03 ? DEEP : BRONZE);
			a = 1.0;
		}
	}
	// L'instant où l'épée se plante : un éclair pâle au centre.
	float flash = 0.25 * (1.0 - smoothstep(0.0, 0.05, t)) - d;
	if (flash > 0.0) {
		color = PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
