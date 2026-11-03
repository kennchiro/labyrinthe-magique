shader_type canvas_item;
render_mode blend_mix;

// UNE ROUE D'ÉZÉCHIEL : deux roues d'or emboîtées en croix, la jante couverte d'yeux, dans un
// anneau de flamme saphir. Le nœud la fait rouler et tourner ; elle naît et s'éteint ici.

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

float eye(vec2 q, float size) {
	float edge = size * (1.0 - pow(abs(q.x) / (size * 1.8), 2.0));
	return edge - abs(q.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float size = smoothstep(0.0, 0.1, t) * (1.0 - smoothstep(0.88, 1.0, t));
	p /= max(size, 0.001);
	float d = length(p);
	float angle = atan(p.y, p.x);
	vec3 color = SAPPHIRE;
	float a = 0.0;
	// L'anneau de flamme, aux langues tournées vers l'extérieur.
	float flame = 0.9 + 0.08 * sin(angle * 10.0 + TIME * 14.0 + seed * 5.0);
	float fire = 0.14 - abs(d - flame + 0.07);
	if (fire > -0.03 && size > 0.0) {
		color = fire <= 0.0 ? RIM : (fire > 0.08 ? PALE : SAPPHIRE);
		a = 1.0;
	}
	// La roue d'or, vue de face, et la seconde, aplatie en travers : une roue dans une roue.
	float rim1 = 0.07 - abs(d - 0.6);
	vec2 e = vec2(p.x, p.y / 0.35);
	float rim2 = 0.07 - abs(length(e) - 0.6);
	if ((rim1 > -0.025 || (rim2 > -0.025 && abs(p.y) < 0.3)) && size > 0.0) {
		color = max(rim1, rim2) <= 0.0 ? RIM : BRONZE;
		a = 1.0;
	}
	for (int i = 0; i < 8; i++) {
		float at = float(i) * 0.785;
		vec2 dir = vec2(cos(at), sin(at));
		float spoke = 0.03 - abs(dot(p, vec2(-dir.y, dir.x)));
		if (spoke > -0.02 && dot(p, dir) > 0.12 && d < 0.55 && size > 0.0) {
			color = spoke > 0.0 ? BRONZE : RIM;
			a = 1.0;
		}
	}
	// Quatre yeux sur la jante.
	for (int i = 0; i < 4; i++) {
		float at = float(i) * 1.5708 + 0.785;
		vec2 c = vec2(cos(at), sin(at)) * 0.6;
		float lid = eye(p - c, 0.11);
		if (lid > -0.03 && size > 0.0) {
			color = lid <= 0.0 ? RIM : (length(p - c) < 0.06 ? DEEP : vec3(0.98, 0.96, 0.9));
			a = 1.0;
		}
	}
	float hub = 0.12 - d;
	if (hub > -0.025 && size > 0.0) {
		color = hub <= 0.0 ? RIM : BRONZE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
