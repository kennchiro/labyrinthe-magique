shader_type canvas_item;
render_mode blend_mix;

// UNE GUEULE QUI CLAQUE : une gueule de crocs ivoire s'ouvre en grand puis se referme d'un coup sec, et deux gouttes de
// bile en jaillissent. La Faim sans fond sur chaque kill, Tout dévorer sur chaque proie, la morsure du Bond.

#include "res://assets/shaders/faim.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float open = t < 0.35 ? smoothstep(0.0, 0.3, t) : 1.0 - smoothstep(0.35, 0.45, t);
	float gone = 1.0 - smoothstep(0.75, 1.0, t);
	vec2 g = p * vec2(1.0, 1.25);
	vec3 c = color;
	if (gone > 0.0 && g_paint_maw(g, 0.75 * (0.8 + 0.2 * gone), open, 12.0, c)) {
		color = c;
		a = gone;
	}
	for (int i = 0; i < 2; i++) {
		float f = float(i);
		float k = clamp((t - 0.4) / 0.5, 0.0, 1.0);
		vec2 at = vec2((f - 0.5) * 0.6 * k, -sin(k * 3.14159) * 0.6);
		float v = g_drop(p - at, 0.07 * (1.0 - k * 0.5));
		if (k > 0.0 && k < 1.0 && v > -0.012) {
			color = v <= 0.0 ? G_INK : (v > 0.035 ? G_PALE : G_BILE);
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
