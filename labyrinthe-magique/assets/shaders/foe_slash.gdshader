shader_type canvas_item;
render_mode blend_mix;

// LE COUP DE LAME OU DE GRIFFE D'UN ENNEMI, vers la droite du quad : un croissant qui balaie
// d'un bord à l'autre, effilé aux deux bouts, puis des étincelles qui s'en détachent.
// `claws` trace plusieurs griffures parallèles.

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec3 light = vec3(1.0);
uniform vec3 mid = vec3(0.8);
uniform vec3 deep = vec3(0.2);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}
uniform float claws = 1.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = mid;
	float a = 0.0;
	float sweep = smoothstep(0.0, 0.35, t) * 1.25;
	float thin = 1.0 - smoothstep(0.35, 0.8, t);
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		if (f >= claws) {
			break;
		}
		vec2 q = p - vec2(-0.45, (f - (claws - 1.0) * 0.5) * 0.32);
		float r = length(q);
		float angle = atan(q.y, q.x);
		float along = clamp(abs(angle + 0.6 - sweep) / 1.25, 0.0, 1.0);
		float inside = step(angle, sweep - 0.6) * step(-0.6 - 0.65, angle);
		float width = 0.14 * thin * (1.0 - along * along) / max(claws * 0.6, 1.0);
		float band = width - abs(r - 0.8);
		if (band > 0.0 && inside > 0.0) {
			color = band > width * 0.45 ? light : mid;
			a = 1.0;
		}
		float rim = width * 1.6 - abs(r - 0.8);
		if (a < 0.5 && rim > 0.0 && inside > 0.0 && t < 0.6) {
			color = deep;
			a = 1.0;
		}
	}
	for (int i = 0; i < 9; i++) {
		float f = float(i);
		float angle = (hash(f) - 0.5) * 1.6;
		float born = 0.25 + hash(f + 4.0) * 0.2;
		float life = clamp((t - born) / (1.0 - born), 0.0, 1.0);
		vec2 at = vec2(-0.45, 0.0) + vec2(cos(angle), sin(angle)) * (0.8 + life * (0.25 + hash(f + 7.0) * 0.3));
		at.y += life * life * 0.2;
		float s = 0.05 * (1.0 - life) * step(born, t) - length(p - at);
		if (s > 0.0) {
			color = mod(f, 3.0) < 1.0 ? light : mid;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
