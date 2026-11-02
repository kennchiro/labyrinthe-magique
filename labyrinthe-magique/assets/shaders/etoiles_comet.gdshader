shader_type canvas_item;
render_mode blend_mix;

// LA COMÈTE, debout : une étoile tombe en biais du haut du quad jusqu'à son pied avec une longue
// traînée, à 45 % de sa vie, puis une gerbe jaillit et la traînée s'efface. Elle sert à la Pluie
// d'étoiles et à la Nuit éternelle.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);
const float LAND = 0.45;
const vec2 FOOT = vec2(0.0, 0.86);
const vec2 FROM = vec2(0.42, -0.95);

float star(vec2 v, float size) {
	return size - pow(pow(abs(v.x), 0.6) + pow(abs(v.y), 0.6), 1.67);
}

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float run = clamp(progress / LAND, 0.0, 1.0);
	run *= run;
	vec2 head = mix(FROM, FOOT, run);
	vec2 along = normalize(FOOT - FROM);
	vec2 rel = p - head;
	float back = -dot(rel, along);
	float across = abs(rel.x * along.y - rel.y * along.x);
	float reach = 1.5 * smoothstep(0.0, 0.5, run) * (1.0 - smoothstep(LAND, 0.72, progress));
	float tail = (0.085 * (1.0 - clamp(back / max(reach, 0.01), 0.0, 1.0))) - across;
	tail = min(tail, back + 0.02);
	float alpha = smoothstep(-0.012, 0.0, tail) * step(back, reach) * step(0.001, reach);
	vec3 color = mix(BLUE, SHINE, smoothstep(0.012, 0.035, tail));
	color = mix(color, vec3(1.0), smoothstep(0.04, 0.07, tail));
	color = mix(RIM, color, smoothstep(0.0, 0.01, tail));
	if (progress < LAND) {
		float s = star(rel, 0.22);
		if (s > -0.01) {
			color = s > 0.0 ? vec3(1.0) : RIM;
			alpha = 1.0;
		}
	}
	float after = clamp((progress - LAND) / (1.0 - LAND), 0.0, 1.0);
	if (after > 0.0) {
		float flash = star(p - FOOT, 0.34 * (1.0 - after));
		if (flash > -0.01) {
			color = flash > 0.0 ? vec3(1.0) : RIM;
			alpha = 1.0;
		}
		for (int i = 0; i < 10; i++) {
			float f = float(i);
			vec2 way = vec2((hash(f) - 0.5) * 1.4, -0.3 - hash(f + 4.0) * 0.7);
			vec2 at = FOOT + way * sqrt(after) + vec2(0.0, after * after * 0.5);
			float bit = 0.028 * (1.0 - after) + 0.005 - length(p - at);
			if (bit > 0.0) {
				color = hash(f + 8.0) > 0.5 ? vec3(1.0) : BLUE;
				alpha = 1.0 - after * after;
			}
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
