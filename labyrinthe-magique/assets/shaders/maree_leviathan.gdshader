shader_type canvas_item;
render_mode blend_mix;

// LE LÉVIATHAN : un serpent d'eau géant traverse le labyrinthe d'un bord à l'autre en ondulant,
// gueule ouverte devant, corps d'écailles turquoise cerné, crête d'écume sur le dos, et il emporte
// une gerbe d'eau dans son sillage. UV.x : le bord de départ (0), celui d'arrivée (1) ; le nœud
// retourne le quad quand il nage vers la gauche.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 FOAM = vec3(0.914, 1.0, 1.0);
const vec3 TEAL = vec3(0.329, 0.918, 0.859);
const vec3 BLUE = vec3(0.216, 0.776, 1.0);
const vec3 ABYSS = vec3(0.027, 0.345, 0.741);
const vec3 SILVER = vec3(0.784, 0.839, 0.898);
const vec3 RIM = vec3(0.024, 0.169, 0.384);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = vec2(UV.x, (UV.y - 0.5) * 2.0);
	float t = progress;
	float head = mix(-0.08, 1.25, t);
	float length_ = 0.75;
	vec3 color = ABYSS;
	float a = 0.0;
	float behind = head - p.x;
	// Le corps : une sinusoïde qui s'amincit vers la queue.
	if (behind > 0.0 && behind < length_) {
		float k = behind / length_;
		float spine = 0.35 * sin(p.x * 16.0 - t * 30.0 + seed);
		float thick = 0.32 * (1.0 - k * 0.85);
		float inside = thick - abs(p.y - spine);
		if (inside > -0.05) {
			a = 1.0;
			float scale_ = fract(p.x * 40.0 + (p.y - spine) * 3.0);
			if (inside <= 0.0) {
				color = RIM;
			} else if (p.y - spine < -thick * 0.55) {
				color = FOAM;
			} else if (inside < thick * 0.25) {
				color = ABYSS;
			} else {
				color = scale_ < 0.5 ? TEAL : BLUE;
			}
		}
		// Les nageoires, de loin en loin sur le dos.
		float fin_at = fract(behind * 6.0);
		vec2 f = vec2(fin_at - 0.5, p.y - spine + thick + 0.1);
		float fin = (0.12 - abs(f.x) * 0.5) - abs(f.y + f.x * 0.3);
		if (fin > -0.02 && k < 0.85) {
			color = fin <= 0.0 ? RIM : SILVER;
			a = 1.0;
		}
	}
	// La tête : un museau en coin, gueule ouverte, un œil d'écume.
	vec2 h = vec2(p.x - head, p.y - 0.35 * sin(head * 16.0 - t * 30.0 + seed));
	float skull = (h.x > -0.07 && h.x < 0.05) ? (0.36 - (h.x + 0.07) * 3.2) - abs(h.y) : -1.0;
	float jaw = (h.x > -0.02 && h.x < 0.07) ? 0.06 - abs(h.y - 0.08 - (h.x + 0.02) * 2.0) : -1.0;
	float gape = (h.x > -0.01 && h.x < 0.07) ? 0.05 - abs(h.y - 0.0) : -1.0;
	if (max(skull, jaw) > -0.04) {
		color = max(skull, jaw) <= 0.0 ? RIM : (skull > 0.18 ? BLUE : TEAL);
		a = 1.0;
		if (gape > 0.0 && skull < 0.2) {
			color = RIM;
		}
		if (length(h - vec2(-0.035, -0.12)) < 0.035) {
			color = FOAM;
		}
	}
	// Le sillage : une gerbe d'écume derrière la tête.
	for (int i = 0; i < 10; i++) {
		float fi = float(i);
		float k = fract(hash(fi) + t * 2.0);
		vec2 c = vec2(head - 0.05 - k * 0.25, (hash(fi + 1.0) - 0.5) * 1.4 * k);
		float drop = 0.025 * (1.0 - k) - length((p - c) * vec2(1.0, 0.25));
		if (drop > 0.0) {
			color = FOAM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
