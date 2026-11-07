shader_type canvas_item;
render_mode blend_mix;

// LA MORSURE, vers la droite du quad : deux mâchoires en dents de scie qui se referment,
// l'éclair au point où elles claquent, puis des gouttes qui tombent.

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec3 light = vec3(1.0);
uniform vec3 mid = vec3(0.8);
uniform vec3 deep = vec3(0.2);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = mid;
	float a = 0.0;
	float shut = smoothstep(0.0, 0.3, t);
	float open = 0.55 * (1.0 - shut) + 0.04;
	float fade = 1.0 - smoothstep(0.45, 0.75, t);
	float x = p.x + 0.2;
	if (x > 0.05 && x < 0.65 && fade > 0.0) {
		float teeth = abs(fract(x * 4.0) - 0.5) * 0.36;
		float upper = p.y + open - teeth;
		float lower = p.y - open + teeth;
		float span = 0.12 * fade;
		if (upper < 0.0 && upper > -span) {
			color = upper > -span * 0.45 ? light : mid;
			a = 1.0;
		}
		if (lower > 0.0 && lower < span) {
			color = lower < span * 0.45 ? light : mid;
			a = 1.0;
		}
		if (a < 0.5 && (upper < -span && upper > -span * 1.6 || lower > span && lower < span * 1.6)) {
			color = deep;
			a = 1.0;
		}
	}
	vec2 c = p - vec2(0.3, 0.0);
	float flash = smoothstep(0.22, 0.32, t) * (1.0 - smoothstep(0.32, 0.6, t));
	float star = flash * 0.5 - (abs(c.x) * 0.6 + abs(c.y)) * (1.0 + 5.0 * min(abs(c.x), abs(c.y)) / max(length(c), 0.01));
	if (star > 0.0) {
		color = star > flash * 0.2 ? light : mid;
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float f = float(i);
		float life = clamp((t - 0.3) / 0.7, 0.0, 1.0);
		vec2 at = vec2(0.3 + (hash(f) - 0.5) * 0.5, life * (0.4 + hash(f + 2.0) * 0.4));
		vec2 q = p - at;
		q.y *= 0.7;
		float s = 0.06 * (1.0 - life) * step(0.3, t) - length(q);
		if (s > 0.0) {
			color = mod(f, 2.0) < 1.0 ? mid : deep;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
