shader_type canvas_item;
render_mode blend_mix;

// LE DÉPLACEMENT DU SUPRÊME : des traînées d'or qui s'enroulent, le mage laisse sa vitesse derrière lui.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x) + d * 3.4 - progress * 4.0 + seed;
	float arms = abs(fract(a * 3.0 / TAU) - 0.5) * 2.0;
	float f = fbm(vec2(d * 0.6 - progress, a * 0.25));
	float h = (0.9 - d) * 1.2 + (f - 0.5) * 0.9 - arms * 1.15 + 0.2 - progress * 0.55;
	vec3 color = mix(vec3(0.62, 0.3, 0.05), vec3(1.0, 0.76, 0.18), smoothstep(0.0, 0.14, h));
	color = mix(color, vec3(1.0, 0.98, 0.76), smoothstep(0.14, 0.32, h));
	COLOR = vec4(color, smoothstep(0.0, 0.06, h) * (1.0 - smoothstep(0.72, 1.0, progress)) * COLOR.a);
}
