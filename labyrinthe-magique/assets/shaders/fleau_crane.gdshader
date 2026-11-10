shader_type canvas_item;
render_mode blend_mix;

// LE MALADE DE L'ÉPIDÉMIE : un petit crâne vert acide surgit au-dessus de la victime, ses orbites sombres, une
// goutte qui coule de la mâchoire ; il gonfle, tient, puis se dissout vers le bas.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	float pop = smoothstep(0.0, 0.12, t) * (1.0 + 0.25 * sin(clamp(t / 0.25, 0.0, 1.0) * PI));
	float melt = smoothstep(0.65, 1.0, t);
	vec2 q = (p - vec2(0.0, -0.35 + melt * 0.25)) / max(0.01, 0.42 * pop);
	vec3 color = F_VENOM;
	float a = 0.0;
	// Le crâne : un dôme, une mâchoire, deux orbites, un nez.
	float dome = 0.62 - length(q * vec2(1.0, 1.08));
	vec2 jq = q - vec2(0.0, 0.45);
	vec2 jaw_box = abs(jq) - vec2(0.36, 0.2);
	float jaw = -(length(max(jaw_box, 0.0)) + min(max(jaw_box.x, jaw_box.y), 0.0)) + 0.06;
	float skull = max(dome, jaw);
	if (skull > -0.06) {
		color = skull <= 0.0 ? F_RIM : mix(F_BRIGHT, F_SHADE, smoothstep(-0.2, 0.7, q.y) * 0.6);
		a = 1.0;
		for (int s = -1; s <= 1; s += 2) {
			if (length((q - vec2(float(s) * 0.24, 0.02)) * vec2(1.0, 0.85)) < 0.17) {
				color = F_NIGHT;
			}
		}
		if (abs(q.x) < 0.06 - (q.y - 0.22) * 0.25 && q.y > 0.2 && q.y < 0.34) {
			color = F_NIGHT;
		}
		if (jq.y > 0.0 && abs(fract(q.x * 4.0) - 0.5) < 0.08 && abs(q.x) < 0.3) {
			color = F_RIM;
		}
		if (length(q - vec2(-0.25, -0.35)) < 0.1) {
			color = F_CORE;
		}
	}
	vec3 drip = color;
	if (f_paint_drop(q - vec2(0.12, 0.85 + melt * 0.6), 0.12, drip)) {
		color = drip;
		a = 1.0;
	}
	COLOR = vec4(color, a * (1.0 - melt));
}
