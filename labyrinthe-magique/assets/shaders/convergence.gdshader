shader_type canvas_item;
render_mode blend_mix;

// LA CONVERGENCE : feu, eau, terre et air tournent en quatre bras de vraie matière autour d'un cœur blanc.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = TIME + seed * 5.0;
	vec4 arms = pinwheel(p, t, 0.97, t * 2.3, 2.3);
	// LE CŒUR, et ses rayons qui battent : c'est là que les quatre se fondent.
	float rays = pow(abs(cos(atan(p.y, p.x) * 4.0 - t * 1.4)), 16.0) * 0.17;
	float core = 0.2 + rays + sin(t * 9.0) * 0.012 - d;
	vec3 color = mix(arms.rgb, vec3(1.0, 0.86, 0.46), smoothstep(-0.03, 0.03, core));
	color = mix(color, vec3(1.0, 1.0, 0.92), smoothstep(0.02, 0.11, core));
	COLOR = vec4(color, max(arms.a, smoothstep(-0.03, 0.02, core)) * COLOR.a);
}
