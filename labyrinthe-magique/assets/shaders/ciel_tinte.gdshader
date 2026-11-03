shader_type canvas_item;
render_mode blend_mix;

// LE TINTEMENT : la cloche s'illumine d'or et se balance, et trois arcs nets partent de chaque
// côté d'elle. C'est le signal de la Cloche céleste, avant que l'onde ne déferle.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float swing = sin(t * 28.0) * 0.35 * (1.0 - t);
	vec2 q = vec2(p.x * cos(swing) - p.y * sin(swing), p.x * sin(swing) + p.y * cos(swing));
	vec3 color = GOLD;
	float a = 0.0;
	float live = 1.0 - smoothstep(0.75, 1.0, t);
	// La cloche : un dôme qui s'évase, et son battant.
	float y = q.y + 0.05;
	float half_width = y < -0.28 ? -1.0 : 0.13 + 0.17 * smoothstep(-0.28, 0.2, y);
	float body = half_width - abs(q.x);
	if (y < 0.22 && body > -0.045 && live > 0.0) {
		color = body > half_width * 0.55 ? PALE : (body > 0.0 ? GOLD : RIM);
		a = 1.0;
	}
	float clapper = 0.07 - length(q - vec2(0.0, 0.27));
	if (clapper > -0.035 && live > 0.0) {
		color = clapper > 0.0 ? GOLD : RIM;
		a = 1.0;
	}
	// Trois arcs de chaque côté.
	float d = length(p);
	float side = abs(atan(p.y, abs(p.x)));
	for (int i = 0; i < 3; i++) {
		float r = 0.42 + float(i) * 0.17 + t * 0.25;
		float arc = 0.03 * live - abs(d - r);
		if (arc > -0.015 && side < 0.55 && t > float(i) * 0.08) {
			color = arc > 0.0 ? EMERALD : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
