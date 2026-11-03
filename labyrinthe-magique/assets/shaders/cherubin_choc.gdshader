shader_type canvas_item;
render_mode blend_mix;

// LA FLAMME DU GLAIVE TOUCHE : une gerbe de flamme saphir à cœur pâle jaillit en langues
// nettes, et des éclats de bronze partent. Les langues se rétractent au lieu de s'estomper.

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
	vec3 color = SAPPHIRE;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.2, t) * (1.0 - smoothstep(0.35, 1.0, t));
	// Des langues de flamme : un rayon qui ondule avec l'angle, plus haut vers le haut de l'écran.
	float tongues = 0.55 + 0.25 * sin(angle * 7.0 + seed * 9.0 + t * 6.0) + 0.15 * sin(angle * 13.0 - t * 10.0);
	tongues += 0.2 * max(0.0, -sin(angle));
	float r = tongues * grow;
	float inside = r - d;
	if (inside > -0.05 && grow > 0.0) {
		color = inside > r * 0.55 ? PALE : (inside > r * 0.25 ? SAPPHIRE : (inside > 0.0 ? DEEP : RIM));
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float at = f / 6.0 * 6.2832 + hash(f) * 0.8;
		vec2 c = vec2(cos(at), sin(at)) * (0.2 + smoothstep(0.05, 0.9, t) * 0.7);
		vec2 q = p - c;
		float size = 0.07 * (1.0 - smoothstep(0.5, 1.0, t));
		float spark = size - (abs(q.x) + abs(q.y) * 1.5);
		if (spark > -0.02 && size > 0.0 && t > 0.08) {
			color = spark > 0.0 ? BRONZE : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
