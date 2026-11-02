shader_type spatial;
render_mode vertex_lighting;

// Les haies : leur atlas, le vent dans le feuillage, et les nappes qui passent dessus.
//
// Le vent ne déplace AUCUN sommet : une haie qui bouge ne dirait plus où est le mur. Il
// fait glisser le dessin d'un pixel et passe des bouffées de lumière, seulement dessus.

#include "drift.gdshaderinc"

uniform sampler2D atlas : source_color, repeat_enable, filter_linear_mipmap;
uniform float gain = 1.0;
// 0 : haie immobile. 1 : le réglage de la Forêt.
uniform float wind = 0.0;
// Éclats du cristal, de la glace ou de l'or : chacun s'allume à son heure, puis s'éteint.
uniform float sparkle = 0.0;

varying float top;

void vertex() {
	world_xz = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
	top = step(0.5, NORMAL.y);
}

void fragment() {
	vec4 drawn = texture(atlas, UV);
	float light = 1.0;
	if (wind > 0.0 && top > 0.5) {
		float gust = texture(drift_noise, world_xz * 0.09 + TIME * vec2(0.055, 0.021)).r;
		float wave = TIME * 1.7 + gust * 6.28;
		vec2 slip = vec2(sin(wave + world_xz.x * 3.1), cos(wave * 0.8 + world_xz.y * 2.7));
		vec4 shifted = texture(atlas, UV + slip * 0.0045 * wind);
		// Hors de la silhouette, l'atlas est vide : on y garde le dessin d'origine.
		drawn = mix(drawn, shifted, shifted.a);
		light += smoothstep(0.52, 0.78, gust) * 0.16 * wind;
	}
	if (sparkle > 0.0 && top > 0.5) {
		float grain = texture(drift_noise, world_xz * 0.73).r;
		float beat = sin(TIME * 2.2 + grain * 90.0);
		light += sparkle * smoothstep(0.58, 0.66, grain) * smoothstep(0.86, 1.0, beat);
	}
	ALBEDO = drawn.rgb * COLOR.rgb * gain * light * cloud_shade();
}
