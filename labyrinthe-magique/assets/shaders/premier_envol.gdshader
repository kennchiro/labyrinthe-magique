shader_type canvas_item;
render_mode blend_mix;

// L'ENVOL DU DRAGON : ses ailes s'ouvrent dans son dos en deux grandes membranes rouge sang bordées de flammes, dans
// une bourrasque de braises, puis se replient. Quad centré à hauteur d'épaules.

#include "res://assets/shaders/premier.gdshaderinc"

uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = vec3(0.0);
	float a = 0.0;
	float open = smoothstep(0.0, 0.3, t) * (1.0 - smoothstep(0.75, 1.0, t));
	vec2 q = vec2(abs(p.x), p.y);
	// L'aile : un éventail de trois doigts, déchiré entre eux.
	float wing = -1.0;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float an = -0.35 + f * 0.45;
		vec2 dir = vec2(cos(an), sin(an));
		float along = dot(q - vec2(0.1, -0.1), dir);
		float side = abs(dot(q - vec2(0.1, -0.1), vec2(-dir.y, dir.x)));
		float reach = 0.85 * open * (1.0 - f * 0.12);
		wing = max(wing, min(0.2 * (1.0 - along / max(reach, 0.01)) - side, min(along, reach - along)));
	}
	if (wing > -0.02 && open > 0.02) {
		color = wing <= 0.0 ? P_OBSIDIAN : (wing < 0.035 ? P_MAGMA : P_BLOOD);
		a = 1.0;
	}
	// Les braises de la bourrasque.
	for (int i = 0; i < 10; i++) {
		float f = float(i);
		float an = f * TAU / 10.0 + seed;
		vec2 at = vec2(cos(an), sin(an) * 0.5) * (0.3 + t * 0.8);
		float s = p_shard(p_rot(p - at, an + t * 6.0), 0.03, 0.05);
		if (s > 0.0 && t < 0.9) {
			color = mod(f, 2.0) < 1.0 ? P_YELLOW : P_MAGMA;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
