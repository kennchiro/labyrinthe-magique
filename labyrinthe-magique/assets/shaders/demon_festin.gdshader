shader_type canvas_item;
render_mode blend_mix;

// LE FESTIN, en quatre temps :
//   1. LA GUEULE s'ouvre : deux gencives striées, un fond noir, deux rangées de crocs décalés.
//   2. LE CLAQUEMENT : elle se referme d'un coup, très vite, et les crocs s'emboîtent.
//   3. LE SANG jaillit de la ligne de morsure, avec une onde qui part au rayon du sort.
//   4. ELLE SE RETIRE vers le haut et le bas, et une goutte file vers lui : c'est le soin.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 IVORY = vec3(0.984, 0.937, 0.827);
const vec3 SHADE = vec3(0.776, 0.651, 0.51);
const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float FANGS = 3.2;
const float EDGE = 0.8;
const float GUM = 0.2;
const float FANG = 0.42;
const float SNAP = 0.26;
const float DROPS = 14.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float close_in = clamp(progress / SNAP, 0.0, 1.0);
	float after = smoothstep(0.62, 1.0, progress);
	float gap = mix(0.7, 0.08, close_in * close_in * close_in) + after * 0.72;
	float shift = p.y < 0.0 ? 0.0 : 0.5;
	float u = abs(p.y) - gap;
	float inside = EDGE - length(p);
	float phase = fract(p.x * FANGS * 0.5 + shift);
	float cell = abs(phase - 0.5) * 2.0;
	float tooth_top = GUM - FANG * (1.0 - cell);
	float gum = min(u - GUM, inside);
	float tooth = min(min(u - tooth_top, GUM + 0.02 - u), inside);
	vec3 color = BLACK;
	float alpha = 0.0;
	// Le fond de la gueule, entre les deux rangées.
	if (inside > 0.0 && after < 0.5) {
		color = mix(BLACK, DEEP, 0.35 * smoothstep(0.0, gap + 0.1, abs(p.y)));
		alpha = 0.42 * smoothstep(0.0, 0.1, progress);
	}
	if (tooth > 0.0) {
		vec3 ivory = phase < 0.5 ? IVORY : SHADE;
		// Le bout des crocs rougit après la morsure.
		float stained = smoothstep(SNAP, SNAP + 0.08, progress) * smoothstep(0.14, 0.02, u - tooth_top);
		color = mix(BLACK, mix(ivory, CRIMSON, stained), smoothstep(0.0, 0.018, tooth));
		alpha = 1.0;
	}
	if (gum > -0.006) {
		float ridge = abs(sin(p.x * 13.0 + seed)) * smoothstep(0.34, 0.0, u - GUM);
		vec3 flesh = mix(DEEP, CRIMSON, smoothstep(0.34, 0.02, u - GUM));
		flesh = mix(flesh, BLACK, smoothstep(0.82, 1.0, ridge) * 0.7);
		color = mix(BLACK, flesh, smoothstep(0.0, 0.02, gum));
		alpha = 1.0;
	}
	float t = clamp((progress - SNAP) / 0.42, 0.0, 1.0);
	// L'onde et le sang partent de la ligne de morsure, à l'instant du claquement.
	float wave = 0.035 * (1.0 - t) - abs(length(p) - EDGE * t);
	if (t > 0.0 && t < 1.0 && wave > 0.0 && alpha < 0.9) {
		color = mix(CRIMSON, PALE, smoothstep(0.012, 0.022, wave));
		alpha = 1.0;
	}
	for (int i = 0; i < int(DROPS); i++) {
		float f = float(i);
		float side = mod(f, 2.0) * 2.0 - 1.0;
		float life = clamp(t * 1.15 - hash(f) * 0.15, 0.0, 1.0);
		vec2 at = vec2(side * (0.1 + life * (0.35 + hash(f + 2.0) * 0.45)),
			(hash(f + 3.0) - 0.5) * 0.22 - life * (hash(f + 4.0) * 0.6) + life * life * 0.65);
		vec2 q = p - at;
		float drop = 0.05 * (1.0 - life) + 0.008 - length(q * vec2(0.8, 1.0));
		if (drop > 0.0 && life > 0.0 && life < 1.0) {
			color = drop > 0.026 ? CRIMSON : DEEP;
			alpha = 1.0;
		}
	}
	// L'éclair du claquement, au centre.
	float flash = 1.0 - clamp(abs(progress - SNAP) / 0.05, 0.0, 1.0);
	float bar = flash * 0.09 - abs(p.y) - abs(p.x) * 0.09;
	if (bar > 0.0) {
		color = PALE;
		alpha = 1.0;
	}
	// La goutte qui lui revient.
	float back = clamp((progress - 0.55) / 0.35, 0.0, 1.0);
	if (back > 0.0 && back < 1.0) {
		vec2 q = p - vec2(0.0, mix(0.68, 0.0, back * back));
		float drop = 0.09 * (1.0 - back * 0.5) - length(q * vec2(1.0, 0.75));
		if (drop > 0.0) {
			color = mix(CRIMSON, PALE, smoothstep(0.04, 0.07, drop));
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * smoothstep(1.0, 0.86, progress) * COLOR.a);
}
