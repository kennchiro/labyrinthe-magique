shader_type canvas_item;

// L'OMBRE DU SEIGNEUR DU NÉANT : son propre sprite, peint en silhouette noire au liseré violet. Ses yeux
// restent allumés. `glow` l'embrase quand elle frappe, `fade` la fait apparaître et se dissoudre.

uniform float glow = 0.0;
uniform float fade = 1.0;

const vec3 VOID = vec3(0.07, 0.04, 0.11);
const vec3 VIOLET = vec3(0.78, 0.49, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * 1.5;
	float around = min(min(texture(TEXTURE, UV + vec2(px.x, 0.0)).a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a),
		min(texture(TEXTURE, UV + vec2(0.0, px.y)).a, texture(TEXTURE, UV - vec2(0.0, px.y)).a));
	vec3 color = VOID;
	if (tex.a > 0.5 && around < 0.5) {
		color = VIOLET;
	}
	// Ses yeux : ce qui est très lumineux dans son sprite reste allumé.
	float light = dot(tex.rgb, vec3(0.3, 0.59, 0.11));
	if (light > 0.62) {
		color = mix(VIOLET, vec3(1.0), 0.5);
	}
	color = mix(color, VIOLET, glow * 0.45);
	COLOR = vec4(color, tex.a * 0.88 * fade);
}
