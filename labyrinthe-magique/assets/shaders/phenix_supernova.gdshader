shader_type canvas_item;
render_mode blend_mix;

// LA SUPERNOVA : le ciel rougeoie, l'ombre immense d'un phénix passe sur l'écran, puis un éclair
// blanc éclate au centre quand il retombe. Le reste (l'onde, les météores) est celui de l'Embrasement.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 WHITE = vec3(1.0, 0.957, 0.839);
const vec3 GOLD = vec3(1.0, 0.761, 0.227);
const vec3 ORANGE = vec3(1.0, 0.416, 0.165);
const vec3 RED = vec3(0.702, 0.125, 0.059);
const vec3 RIM = vec3(0.165, 0.039, 0.02);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

float feather(vec2 q, float len, float wid) {
	// Hors de sa longueur, ce n'est plus la plume : sans ce bord, son contour filait à l'infini.
	if (abs(q.x) > len) {
		return -1.0;
	}
	float s = q.x / len;
	float half_width = wid * pow(max(0.0, 1.0 - s * s), 0.6) * (s > 0.0 ? 1.0 - s * 0.4 : 1.0);
	return half_width - abs(q.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	float sky = smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.85, 1.0, t));
	vec3 color = vec3(0.3, 0.05, 0.02);
	float a = 0.42 * sky * smoothstep(0.03, 0.12, d) * (1.0 - smoothstep(0.92, 1.0, d));
	// L'ombre du phénix, qui traverse l'écran en montant.
	vec2 b = p - vec2(mix(-0.9, 0.9, smoothstep(0.05, 0.5, t)), mix(0.4, -0.3, smoothstep(0.05, 0.5, t)));
	float shadow = -1.0;
	for (int s = 0; s < 2; s++) {
		float sgn = s == 0 ? 1.0 : -1.0;
		for (int i = 0; i < 4; i++) {
			float angle = -0.9 + float(i) * 0.3;
			vec2 dir = vec2(cos(angle) * sgn, sin(angle));
			vec2 l = vec2(dot(b, dir) - 0.16, dot(b, vec2(-dir.y, dir.x)));
			shadow = max(shadow, feather(l, 0.16, 0.035));
		}
	}
	if (shadow > 0.0 && t > 0.05 && t < 0.55) {
		color = vec3(0.12, 0.02, 0.01);
		a = 0.7;
	}
	// L'éclair blanc au retour.
	float flash = 0.3 * smoothstep(0.5, 0.56, t) * (1.0 - smoothstep(0.56, 0.75, t)) - d;
	if (flash > 0.0) {
		color = flash > 0.12 ? WHITE : GOLD;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
