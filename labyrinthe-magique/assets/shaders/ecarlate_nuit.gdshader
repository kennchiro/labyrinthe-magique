shader_type canvas_item;

// LE MONDE PERD SES COULEURS. Posé sur tout l'écran, sous l'interface : il lit l'image et la rend en
// noir et blanc très contrasté, puis de grandes coupes rouges et blanches la traversent une à une.
// C'est le seul effet du jeu qui lit l'écran, et il ne dure qu'une seconde.

uniform sampler2D screen : hint_screen_texture, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float aspect = 1.78;
// LA NUIT ÉCARLATE du Seigneur (son Éveil) : le noir et blanc vire au noir et rouge, et une immense lune de sang se
// lève en haut de l'écran, avant les coupes.
uniform float crimson = 0.0;

const vec3 WHITE = vec3(1.0, 0.965, 0.933);
const vec3 RED = vec3(0.722, 0.078, 0.078);
const float CUTS = 7.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec3 image = texture(screen, SCREEN_UV).rgb;
	float luma = dot(image, vec3(0.3, 0.59, 0.11));
	luma = smoothstep(0.08, 0.75, luma);
	float t = progress;
	float grey = smoothstep(0.0, 0.05, t);
	vec3 color = mix(image, vec3(luma * 0.92), grey);
	color *= 1.0 - 0.45 * grey * smoothstep(0.3, 1.1, length((UV - 0.5) * vec2(aspect * 0.8, 1.2)));
	vec2 p = (UV - 0.5) * vec2(aspect, 1.0) * 2.0;
	if (crimson > 0.5) {
		color = mix(color, vec3(color.r * 1.05, color.g * 0.16, color.b * 0.14), grey);
		vec2 m = p - vec2(0.0, mix(-0.2, -0.62, smoothstep(0.0, 0.3, t)));
		float moon = 0.34 - length(m);
		if (moon > -0.012) {
			// Des cratères ronds, plus sombres, et un croissant d'ombre sur son bord gauche.
			float crater = 0.0;
			for (int k = 0; k < 6; k++) {
				float fk = float(k);
				vec2 c = vec2(hash(fk + 20.0) - 0.5, hash(fk + 30.0) - 0.5) * 0.42;
				crater = max(crater, step(length(m - c), 0.03 + hash(fk + 40.0) * 0.05));
			}
			float shade = smoothstep(0.1, 0.34, length(m - vec2(0.12, -0.05)));
			color = moon <= 0.0 ? vec3(0.09, 0.02, 0.02)
				: mix(mix(RED * 1.3, RED * 0.75, shade), RED * 0.55, crater);
		}
	}
	for (int i = 0; i < int(CUTS); i++) {
		float f = float(i);
		float start = 0.08 + f * 0.085;
		float life = (t - start) / 0.18;
		if (life < 0.0) {
			continue;
		}
		float angle = hash(f) * 3.1416;
		float c = cos(angle);
		float s = sin(angle);
		vec2 centre = (vec2(hash(f + 2.0), hash(f + 4.0)) - 0.5) * 0.9;
		vec2 q = p - centre;
		q = vec2(q.x * c + q.y * s, q.y * c - q.x * s);
		float reach = min(1.0, life) * 3.2;
		float width = 0.022 * max(0.12, 1.0 - life * 0.7) * max(0.0, 1.0 - abs(q.x) / 3.2);
		float blade = width - abs(q.y);
		if (abs(q.x) < reach) {
			if (blade > 0.0) {
				color = WHITE;
			} else if (blade > -0.008) {
				color = RED;
			}
		}
	}
	if (t > 0.93) {
		color = mix(color, WHITE, (t - 0.93) / 0.07);
	}
	COLOR = vec4(color, 1.0);
}
