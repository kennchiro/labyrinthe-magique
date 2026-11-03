shader_type canvas_item;
render_mode blend_mix;

// LA LANCE CÉLESTE TOUCHE : un éclat d'or à quatre branches au cœur pâle, quatre éclats émeraude
// en diagonale, et un anneau qui file. L'étoile se rétracte en un point au lieu de s'estomper.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

// Une étoile à quatre branches aux flancs creusés : l'astroïde.
float astroid(vec2 p, float size) {
	vec2 a = abs(p) / max(size, 0.0001);
	return 1.0 - (pow(a.x, 0.6) + pow(a.y, 0.6));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	vec3 color = PALE;
	float a = 0.0;
	float grow = smoothstep(0.0, 0.18, t);
	float shrink = 1.0 - smoothstep(0.3, 1.0, t);
	float size = 0.95 * grow * shrink;
	// L'anneau.
	float front = 0.15 + smoothstep(0.0, 0.7, t) * 0.7;
	float width = 0.06 * (1.0 - smoothstep(0.4, 0.85, t));
	float ring = width - abs(d - front);
	if (ring > 0.0) {
		color = ring > width * 0.45 ? EMERALD : DEEP;
		a = 1.0;
	}
	// Les éclats en diagonale, plus courts.
	float c = 0.7071;
	vec2 r = vec2(p.x * c - p.y * c, p.x * c + p.y * c);
	float diag = astroid(r, size * 0.62);
	if (diag > -0.12 && size > 0.0) {
		color = diag > 0.0 ? EMERALD : RIM;
		a = 1.0;
	}
	// L'étoile d'or, cernée, au cœur pâle.
	float star = astroid(p, size);
	if (star > -0.1 && size > 0.0) {
		color = star > 0.45 ? PALE : (star > 0.0 ? GOLD : RIM);
		a = 1.0;
	}
	// Le premier instant : un disque pâle qui se contracte.
	float flash = 0.42 * (1.0 - smoothstep(0.0, 0.16, t)) - d;
	if (flash > 0.0) {
		color = PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
