shader_type canvas_item;
render_mode blend_mix;

// LA CHARGE, aux deux bouts : le sol se fend en éclats d'acier gris qui s'écartent, autour d'un
// anneau de poussière. Aucune flamme : c'est le poids qui parle ici, pas la chaleur.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 STEEL = vec3(0.875, 0.902, 0.933);
const vec3 DARK = vec3(0.227, 0.267, 0.314);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float SHARDS = 9.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float grown = 0.66 * (1.0 - pow(1.0 - progress, 2.0));
	float dust = 0.05 * (1.0 - progress) - abs(d - grown);
	vec3 color = DARK;
	float alpha = smoothstep(-0.006, 0.006, dust) * (1.0 - progress);
	for (int i = 0; i < int(SHARDS); i++) {
		float f = float(i);
		float a = TAU * (f + hash(f) * 0.7) / SHARDS;
		vec2 dir = vec2(cos(a), sin(a));
		vec2 q = p - dir * (0.1 + 0.68 * sqrt(progress) * (0.65 + 0.35 * hash(f + 2.0)));
		float along = abs(dot(q, dir));
		float across = abs(dot(q, vec2(-dir.y, dir.x)));
		float size = 0.11 * (1.0 - progress * 0.75);
		float shard = size - along - across * 2.4;
		if (shard > -0.012) {
			color = shard > 0.03 ? STEEL : (shard > 0.0 ? HOT : RIM);
			alpha = 1.0 - smoothstep(0.7, 1.0, progress);
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
