shader_type canvas_item;

// LE MÉTAL DU ROI DE BRAISE : ses fissures battent, et `heat` le porte au rouge jusqu'à la fusion.
// `ash` le rend gris de cendre : c'est la fausse armure de la Coquille.

uniform float heat = 0.0;
uniform float ash = 0.0;
uniform float flash = 0.0;
uniform float seed = 0.0;

const vec3 PALE = vec3(1.0, 0.851, 0.627);
const vec3 LAVA = vec3(1.0, 0.478, 0.094);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 color = tex.rgb;
	float crack = smoothstep(0.22, 0.42, tex.r - tex.g) * step(tex.b, 0.3) * step(0.5, tex.r);
	float luma = dot(color, vec3(0.3, 0.59, 0.11));
	color = mix(color, vec3(0.62, 0.6, 0.57) * (0.45 + luma * 1.3), ash * (1.0 - crack));
	float beat = 0.5 + 0.5 * sin(TIME * (3.0 + heat * 9.0) + seed * 6.283 + UV.y * 5.0);
	vec3 molten = mix(LAVA, PALE, smoothstep(0.35, 0.9, luma + heat * 0.25));
	color = mix(color, molten, heat * heat * 0.85);
	color = mix(color, mix(LAVA, PALE, beat), crack * (0.55 + 0.45 * beat));
	color = mix(color, PALE, flash);
	COLOR = vec4(color, tex.a * COLOR.a);
}
