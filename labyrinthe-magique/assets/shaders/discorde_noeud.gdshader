shader_type canvas_item;
render_mode blend_mix;

// LE NŒUD, à l'impact et dans la mêlée, en trois temps :
//   1. L'ÉCLAIR : une étoile pâle, à l'instant du contact.
//   2. LE FIL S'ENROULE : une spirale d'argent se serre vers le centre, sur un cœur magenta.
//   3. LA RUPTURE : la boucle casse, et ses bouts partent en étoile. Tout se réduit, rien ne s'estompe.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.89, 0.945);
const vec3 SILVER = vec3(0.788, 0.824, 0.839);
const vec3 MAGENTA = vec3(0.91, 0.188, 0.561);
const vec3 DEEP = vec3(0.416, 0.059, 0.29);
const vec3 BLACK = vec3(0.086, 0.102, 0.11);
const float ENDS = 9.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x) + seed * 6.0;
	float t = progress;
	vec3 color = MAGENTA;
	float alpha = 0.0;
	float wind = smoothstep(0.08, 0.55, t);
	float reach = mix(0.62, 0.24, wind) * (1.0 - smoothstep(0.72, 0.92, t));
	float spiral = fract(a / TAU + d * 4.0 - wind * 2.0);
	float strand = min(0.2 - abs(spiral - 0.5), reach - d) * 0.55;
	if (strand > -0.01) {
		color = mix(BLACK, SILVER, smoothstep(0.0, 0.02, strand));
		color = mix(color, PALE, smoothstep(0.045, 0.07, strand));
		alpha = 1.0;
	}
	float heart = 0.08 * smoothstep(0.1, 0.4, t) * (1.0 - smoothstep(0.66, 0.84, t)) - d;
	if (heart > -0.015) {
		color = mix(BLACK, MAGENTA, smoothstep(-0.015, 0.012, heart));
		color = mix(color, PALE, smoothstep(0.06, 0.09, heart));
		alpha = 1.0;
	}
	float go = smoothstep(0.04, 0.6, t);
	float shock = 0.03 * (1.0 - go) + 0.003 - abs(d - 0.15 - go * 0.7);
	if (shock > 0.0 && go < 1.0) {
		color = mix(MAGENTA, PALE, step(0.5, 1.0 - go));
		alpha = 1.0;
	}
	float flash = (1.0 - smoothstep(0.0, 0.16, t)) * 0.75;
	float star = flash * pow(abs(cos(atan(p.y, p.x) * 2.0 + seed)), 10.0) + flash * 0.16 - d;
	if (star > 0.0) {
		color = PALE;
		alpha = 1.0;
	}
	float burst = smoothstep(0.42, 1.0, t);
	if (burst > 0.0) {
		for (int i = 0; i < int(ENDS); i++) {
			float f = float(i);
			float angle = f / ENDS * TAU + hash(f) * 0.7;
			vec2 dir = vec2(cos(angle), sin(angle));
			float along = dot(p, dir);
			float across = abs(dot(p, vec2(-dir.y, dir.x)));
			float tip = 0.22 + burst * 0.62;
			float shard = min(0.028 * (1.0 - burst) + 0.004 - across, min(along - tip + 0.2 * (1.0 - burst), tip - along));
			if (shard > 0.0) {
				color = mod(f, 2.0) < 0.5 ? SILVER : MAGENTA;
				alpha = 1.0;
			}
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
