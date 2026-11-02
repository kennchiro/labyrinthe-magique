shader_type canvas_item;
render_mode blend_mix;

// LA COLONNE DU CERCLE D'INVOCATION : la lumière monte du sol quand il s'ouvre, puis il n'en
// reste qu'un voile. C'est elle qui donne de la hauteur à un dessin couché par terre.
//
// Le quad descend sous le centre du cercle, pour que le pied de la colonne suive l'ellipse
// du sol : coupé droit, il faisait un rectangle. Le voile reste très léger : il passe devant
// les couloirs pendant six secondes, et le joueur doit encore les lire.

uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

const int MOTES = 7;
// Le centre du cercle, en hauteur de quad, et l'aplatissement du pied.
const float FOOT = 0.16;

void fragment() {
	float x = (UV.x - 0.5) * 2.0;
	// Le pied en ellipse : au milieu il touche le bas du quad, sur les côtés il remonte.
	float foot = FOOT * sqrt(max(0.0, 1.0 - x * x / 0.5));
	float up = (1.0 - UV.y - FOOT) / (1.0 - FOOT);
	float surge = smoothstep(0.0, 0.32, phase);
	float settled = 1.0 - smoothstep(0.32, 1.3, phase);
	float top = surge * (0.55 + 0.45 * settled);

	// Le fût se resserre en montant, et ses bords ne se fondent pas.
	float wide = 0.7 - up * 0.3;
	float shaft = smoothstep(wide, wide - 0.03, abs(x)) * smoothstep(top, top * 0.72, up) * step(-foot, up);
	// Trois paliers de lumière plutôt qu'un dégradé, et des rais qui remontent.
	float rays = sin(x * 15.0 + seed * 9.0 + sin(x * 7.0 + phase * 1.4) * 1.3);
	float tier = 0.42 + 0.3 * step(0.55, rays) + 0.28 * step(abs(x), 0.22 * (1.0 - up));
	float strength = shaft * tier * (0.06 + 0.84 * settled);

	vec3 color = mix(vec3(0.62, 0.3, 1.0), vec3(1.0, 0.86, 1.0), step(0.7, tier));

	// Des éclats montent tant que le cercle vit.
	float motes = 0.0;
	for (int i = 0; i < MOTES; i++) {
		float h = fract(sin((float(i) + 1.0) * 12.9898 + seed * 78.233) * 43758.5453);
		float climb = fract(phase * (0.16 + h * 0.14) + h * 3.7);
		vec2 at = vec2((fract(h * 7.13) - 0.5) * 1.1, climb * 0.82);
		vec2 q = vec2(x, up * 2.2) - at * vec2(1.0, 2.2);
		motes = max(motes, smoothstep(0.024, 0.016, abs(q.x) + abs(q.y)) * sin(climb * PI));
	}
	color = mix(color, vec3(1.0, 0.9, 1.0), motes);
	float alpha = max(strength, motes * surge);
	COLOR = vec4(color, alpha * smoothstep(0.0, 0.12, life) * COLOR.a);
}
