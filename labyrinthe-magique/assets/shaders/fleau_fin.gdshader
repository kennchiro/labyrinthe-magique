shader_type canvas_item;
render_mode blend_mix;

// LA FIN DE L'ÉVEIL DU SEIGNEUR DU FLÉAU : le miasme retombe en flaque à ses pieds, la flaque sèche en se
// craquelant et se rétracte.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec2 g = (p - vec2(0.0, 0.4)) * vec2(1.0, 2.2);
	float d = length(g);
	float ang = atan(g.y, g.x);
	vec3 color = F_SHADE;
	float a = 0.0;
	// Le miasme qui retombe : des gouttes qui tombent de partout vers la flaque.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float k = clamp(t * 2.5 - f_hash(f, 4.0) * 0.6, 0.0, 1.0);
		vec2 at = vec2((f_hash(f, 1.0) - 0.5) * 1.1, mix(-0.75, 0.4, k * k));
		vec3 drop = color;
		if (k > 0.0 && k < 1.0 && f_paint_drop(p - at, 0.05, drop)) {
			color = drop;
			a = 1.0;
		}
	}
	// La flaque qui sèche.
	float lobe = 0.6 + 0.08 * sin(ang * 5.0 + seed * 7.0);
	float reach = lobe * smoothstep(0.1, 0.35, t) * (1.0 - smoothstep(0.55, 1.0, t) * 0.8);
	float pool = reach - d;
	if (pool > -0.03 && reach > 0.0) {
		color = pool <= 0.0 ? F_RIM : mix(F_VENOM, vec3(0.42, 0.45, 0.2), smoothstep(0.4, 0.9, t));
		float crack = texture(noise, g * 1.4 + seed).r;
		if (t > 0.5 && smoothstep(0.02, 0.006, abs(crack - 0.5)) > 0.5) {
			color = F_RIM;
		}
		a = 1.0 - smoothstep(0.85, 1.0, t);
	}
	COLOR = vec4(color, a);
}
