shader_type canvas_item;
render_mode blend_mix;

// LA MÉTÉORE DU JUGEMENT : un bloc de roche, et une traînée de la matière de son élément.

#include "res://assets/shaders/elements.gdshaderinc"

uniform float seed = 0.0;
uniform int kind = 0;

void fragment() {
	vec2 p = (UV - vec2(0.78, 0.5)) * vec2(2.2, 1.0);
	float d = length(p);
	float behind = clamp(-p.x / 1.7, 0.0, 1.0);
	float wide = 0.3 * (1.0 - behind) * (1.0 + behind * 0.4);
	// Devant la roche, rien : une densité nulle laisserait le bruit rallumer des éclats.
	float trail = p.x < 0.0 ? (wide - abs(p.y)) / 0.3 - behind * 0.2 - smoothstep(0.82, 0.98, behind) : -1.0;
	vec4 matter = paint_element(kind, vec2(p.x * 0.8 + seed, p.y * 0.7), TIME * 1.6 + seed, trail);
	// La roche, fendue et chauffée par la couleur de son élément.
	float rock = 0.26 + (texture(noise, p * 0.4 + seed).r - 0.5) * 0.08 - d;
	float n = texture(noise, p * 0.9 + seed).r;
	vec3 glow = kind == 0 ? vec3(1.0, 0.56, 0.1) : kind == 1 ? vec3(0.3, 0.8, 1.0) : kind == 2 ? vec3(0.62, 0.95, 0.2) : vec3(0.92, 1.0, 1.0);
	vec3 stone = mix(vec3(0.15, 0.1, 0.09), vec3(0.32, 0.25, 0.2), smoothstep(0.3, 0.7, n));
	stone = mix(glow, stone, smoothstep(0.01, 0.05, abs(n - 0.5)));
	vec3 color = mix(matter.rgb, stone, smoothstep(0.0, 0.02, rock));
	COLOR = vec4(color, max(matter.a, smoothstep(0.0, 0.02, rock)) * COLOR.a);
}
