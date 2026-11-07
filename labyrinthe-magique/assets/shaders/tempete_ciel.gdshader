shader_type canvas_item;
render_mode blend_mix;

// LE CIEL NOIR DE LA COLÈRE, posé sur le sol de tout l'écran, SOUS les personnages : il s'assombrit
// d'un coup, des lueurs d'orage passent, puis il s'éclaircit. Les éclairs tombent par-dessus.

#include "res://assets/shaders/tempete.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	float t = progress;
	vec2 p = (UV - 0.5) * 2.0;
	float dark = smoothstep(0.0, 0.08, t) * (1.0 - smoothstep(0.8, 1.0, t));
	// Une lueur d'orage traverse le ciel de temps en temps.
	float flash = step(0.82, t_hash(floor(TIME * 6.0), seed)) * 0.35;
	vec3 color = mix(T_NIGHT * 0.6, T_BLUE_DEEP, flash);
	COLOR = vec4(color, dark * (0.62 - flash * 0.4) * (1.0 - smoothstep(0.6, 1.2, length(p))));
}
