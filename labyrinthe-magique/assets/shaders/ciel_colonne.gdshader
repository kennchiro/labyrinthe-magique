shader_type canvas_item;
render_mode blend_mix;

// LA COLONNE DU CIEL : un pilier de lumière pâle, cerné d'émeraude, s'abat d'en haut, large comme
// la zone. Il tient, parcouru de stries qui descendent, puis se resserre en un trait fin et remonte.
// UV.y va du ciel (0) au sol (1) ; un anneau d'or marque son pied.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	float x = (UV.x - 0.5) * 2.0;
	float y = UV.y;
	float t = progress;
	float bottom = mix(0.0, 0.97, smoothstep(0.0, 0.12, t));
	float top = 0.97 * smoothstep(0.82, 1.0, t);
	float narrow = 1.0 - 0.88 * smoothstep(0.6, 0.85, t);
	float width = 0.6 * narrow * (1.0 + 0.3 * (1.0 - y));
	width += 0.03 * sin(y * 30.0 - t * 40.0 + seed * 5.0) * narrow;
	vec3 color = PALE;
	float a = 0.0;
	float inside = width - abs(x);
	if (y < bottom && y > top && inside > -0.07) {
		a = 1.0;
		float streak = step(0.75, fract(y * 9.0 - t * 14.0 + abs(x) * 2.0));
		if (inside <= 0.0) {
			color = RIM;
		} else if (inside < width * 0.22) {
			color = DEEP;
		} else if (inside < width * 0.5) {
			color = streak > 0.5 ? PALE : EMERALD;
		} else {
			color = PALE;
		}
	}
	// L'instant où elle touche : un éclat pâle, aplati, au pied.
	float slam = smoothstep(0.08, 0.12, t) * (1.0 - smoothstep(0.14, 0.3, t));
	vec2 f = vec2(x / 1.0, (y - 0.97) / 0.06);
	if (slam > 0.0 && length(f) < slam && y > 0.88) {
		color = length(f) < slam * 0.7 ? PALE : EMERALD;
		a = 1.0;
	}
	// L'anneau d'or au pied, aplati par la vue.
	float ground = smoothstep(0.08, 0.14, t) * (1.0 - smoothstep(0.75, 0.95, t));
	vec2 e = vec2(x / 0.95, (y - 0.97) / 0.03);
	float r = length(e);
	float band = 0.16 - abs(r - 0.85 * ground);
	if (band > -0.09 && ground > 0.0 && y > 0.9) {
		color = band > 0.0 ? GOLD : RIM;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
