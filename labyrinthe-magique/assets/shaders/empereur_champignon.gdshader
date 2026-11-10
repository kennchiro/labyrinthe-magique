shader_type canvas_item;
render_mode blend_mix;

// L'EXPLOSION DE LA FORGE : un éclair, puis un champignon de feu monte : un pied de flammes et une tête ronde qui
// roule sur elle-même, sur un anneau de lave au sol, et le tout retombe en fumée.

#include "res://assets/shaders/empereur.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float smoke = smoothstep(0.55, 0.9, t);
	float gone = 1.0 - smoothstep(0.85, 1.0, t);
	// L'anneau au sol.
	vec2 g = (p - vec2(0.0, 0.6)) * vec2(1.0, 2.6);
	float ring = 0.05 * gone - abs(length(g) - smoothstep(0.0, 0.4, t) * 0.9);
	if (ring > 0.0) {
		color = ring > 0.025 ? E_EMBER : E_LAVA;
		a = 1.0;
	}
	// Le pied.
	float rise = smoothstep(0.0, 0.35, t);
	float stem = min(0.14 - abs(p.x + sin(p.y * 8.0 + TIME * 6.0) * 0.02), min(p.y - (0.6 - rise * 0.9), 0.6 - p.y));
	// La tête.
	vec2 head = (p - vec2(0.0, 0.6 - rise * 1.05)) * vec2(1.0, 1.5);
	float cap = (0.18 + rise * 0.22) - length(head) + sin(atan(head.y, head.x) * 8.0 + TIME * 4.0) * 0.03;
	float body = max(stem, cap) * gone;
	if (body > -0.016) {
		vec3 hot = body > 0.12 ? E_PALE : (body > 0.05 ? E_EMBER : E_LAVA);
		color = body <= 0.0 ? E_BLACK : mix(hot, body > 0.05 ? E_ASH_LIGHT : E_ASH, smoke);
		a = 1.0;
	}
	float flash = 0.55 * (1.0 - smoothstep(0.0, 0.18, t)) - length(p - vec2(0.0, 0.5));
	if (flash > 0.0) {
		color = E_PALE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
