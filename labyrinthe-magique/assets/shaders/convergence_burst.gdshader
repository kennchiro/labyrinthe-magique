shader_type canvas_item;
render_mode blend_mix;

// LE COUP DE LA CONVERGENCE : les quatre bras se détendent d'un coup, et chacun emporte sa matière.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = TIME + seed * 5.0;
	float reach = 0.28 + (1.0 - pow(1.0 - progress, 3.0)) * 0.72;
	vec4 arms = pinwheel(p, t * 1.2, reach, progress * 1.2 + seed, 1.5 * (1.0 - progress));
	// Elle se défait par le centre et se déchire sur ses bords.
	float tear = fbm(p * 0.55 + seed) - 0.5;
	float gone = pow(progress, 3.0) * 1.5 - tear * 0.34 - (d * 0.2);
	float alive = 1.0 - smoothstep(0.0, 0.1, gone);
	float flash = (1.0 - smoothstep(0.0, 0.3, progress)) * smoothstep(0.42, 0.3, d);
	vec3 color = mix(arms.rgb, vec3(1.0, 0.99, 0.9), flash);
	COLOR = vec4(color, max(arms.a * alive, flash) * COLOR.a);
}
