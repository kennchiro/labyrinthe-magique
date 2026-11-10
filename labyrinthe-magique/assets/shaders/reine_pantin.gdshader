shader_type canvas_item;

// LA MARIONNETTE DU BALLET : la copie de son sprite, en argent poli cerné de noir, aux yeux d'émeraude, qui
// s'efface quand `fade` monte. Elle porte toujours la pose qu'elle avait au départ.

#include "res://assets/shaders/reine.gdshaderinc"

uniform float fade = 0.0;

void fragment() {
	vec4 src = texture(TEXTURE, UV);
	float lum = dot(src.rgb, vec3(0.3, 0.59, 0.11));
	vec3 color = mix(R_BLACK, R_SILVER, smoothstep(0.02, 0.45, lum));
	color = mix(color, R_PALE, smoothstep(0.6, 0.9, lum));
	// Ce qui est vert vif (ses yeux, son troisième œil) reste émeraude.
	if (src.g > src.r + 0.25 && src.g > src.b + 0.05) {
		color = R_EMERALD;
	}
	float shimmer = 0.5 + 0.5 * sin(TIME * 6.0 + UV.y * 30.0);
	color = mix(color, R_PALE, 0.08 * shimmer);
	COLOR = vec4(color, src.a * (1.0 - fade));
}
