shader_type canvas_item;
render_mode blend_mix;

// LE REMBOBINAGE : le temps tourne à l'envers autour de lui. Trois bras de flèches sarcelle tournent en sens
// inverse des aiguilles et se resserrent, les éclats d'or de ses blessures remontent en spirale jusqu'à son
// cœur, puis une bouffée de lumière claire : les PV sont revenus.

#include "res://assets/shaders/heures.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = H_TEAL;
	float a = 0.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float outer = 0.9 - t * 0.45;
	float fade = 1.0 - smoothstep(0.75, 1.0, t);
	// Les trois bras qui tournent à l'envers.
	float arm = fract((ang - d * 3.5 + t * 11.0) / TAU * 3.0);
	if (d > 0.14 && d < outer && arm < 0.16) {
		float edge = min(arm, 0.16 - arm);
		color = edge < 0.02 ? H_RIM : (edge > 0.05 ? H_PALE : H_BRIGHT);
		a = fade * smoothstep(outer, outer - 0.15, d);
		// La tête de flèche, en chevron, au bout du bras.
	}
	float chevron = fract((ang - d * 3.5 + t * 11.0) / TAU * 3.0 + 0.04);
	if (d > outer - 0.14 && d < outer && abs(chevron - 0.12) < 0.1 * (outer - d) / 0.14) {
		color = H_GOLD;
		a = fade;
	}
	// Le cadran qui recule.
	if (h_dial(p, outer + 0.02, 0.05, -t * 9.0, color)) {
		a = fade * 0.95;
	}
	// Les éclats d'or qui remontent vers lui.
	for (int i = 0; i < 14; i++) {
		float f = float(i);
		float life = fract(f * 0.137 + t * 1.6);
		float rr = mix(0.95, 0.05, life);
		float aa = f * 2.39 - life * 3.0;
		vec2 at = vec2(cos(aa), sin(aa)) * rr;
		vec2 q = h_rot(p - at, -aa);
		float bar = 0.03 - abs(q.x) * 0.4 - abs(q.y);
		if (bar > -0.008 && abs(q.x) < 0.08) {
			color = bar <= 0.0 ? H_RIM : H_LIGHT;
			a = max(a, fade);
		}
	}
	float bloom = smoothstep(0.55, 0.8, t) * (1.0 - smoothstep(0.85, 1.0, t));
	if (d < 0.55 * bloom) {
		color = mix(H_WHITE, H_BRIGHT, d / max(0.01, 0.55 * bloom));
		a = max(a, bloom * (1.0 - d / max(0.01, 0.55 * bloom)));
	}
	COLOR = vec4(color, a);
}
