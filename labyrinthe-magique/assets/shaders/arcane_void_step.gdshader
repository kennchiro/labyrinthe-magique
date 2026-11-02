shader_type canvas_item;
render_mode blend_mix;

// LE PAS DU NÉANT : le sol s'ouvre sous le mage, et le trou se referme aussitôt.
//
// Un trou presque noir, couché au sol, bordé d'un anneau à pleins et déliés. Cinq bras
// tournent et s'y enfoncent, et quelques éclats sont aspirés depuis le bord. Le noir fait
// le néant : c'est ce que ni le sceau de l'impact ni le grand cercle n'ont.

uniform float seed = 0.0;
uniform float progress = 0.0;

const float HOLE = 0.46;
const float ARMS = 5.0;
const float MOTES = 6.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.5;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = smoothstep(0.0, 0.24, progress) * (1.0 - smoothstep(0.62, 1.0, progress));
	float r = HOLE * open;

	float swell = 0.5 + 0.5 * cos(a * 2.0 + seed * TAU + progress * 7.0);
	float ring = 0.012 + 0.036 * swell * swell - abs(d - r);

	// Les bras : effilés vers l'extérieur, et leur spirale se resserre sur le trou.
	float t = (d - r) / max(open * 0.44, 0.001);
	float spiral = fract(a / TAU * ARMS + 1.1 / (d + 0.2) + seed + progress * 2.4) - 0.5;
	float arm = (0.2 * (1.0 - t) - abs(spiral)) * TAU / ARMS * d;
	arm = t > 0.0 && t < 1.0 ? arm : -1.0;

	float mote = -1.0;
	for (float i = 0.0; i < MOTES; i += 1.0) {
		float angle = (i + seed * 7.0) * TAU / MOTES;
		float fall = fract(progress * 1.5 + i * 0.37);
		vec2 at = vec2(cos(angle + fall * 1.4), sin(angle + fall * 1.4)) * mix(0.92, r, fall * fall);
		mote = max(mote, 0.034 * (1.0 - fall) - length(p - at));
	}

	float lines = max(max(ring, arm), mote);

	vec3 color = vec3(0.03, 0.0, 0.08);
	float alpha = smoothstep(r + 0.004, r - 0.004, d) * 0.94;
	float rim = smoothstep(-0.018, -0.01, lines);
	color = mix(color, vec3(0.1, 0.02, 0.22), rim);
	alpha = max(alpha, rim * 0.9);
	float body = smoothstep(-0.006, 0.0, lines);
	color = mix(color, vec3(0.74, 0.34, 1.0), body);
	alpha = max(alpha, body);
	color = mix(color, vec3(1.0, 0.86, 1.0), smoothstep(0.012, 0.022, lines));
	// Fermé, il ne reste pas un point au sol.
	COLOR = vec4(color, alpha * smoothstep(0.0, 0.06, open) * COLOR.a);
}
