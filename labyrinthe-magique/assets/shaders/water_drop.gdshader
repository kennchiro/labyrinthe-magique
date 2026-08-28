shader_type canvas_item;

// La goutte qui tombe : elle ONDULE et son cœur brille.
//
// Une goutte d'eau n'est pas un caillou : sa surface bouge pendant la chute.
// Le dessin, lui, est fixe — c'est le shader qui lui rend sa vie, en étirant
// légèrement l'image selon la hauteur et en faisant courir un reflet clair sur
// son flanc.
//
// Deux effets, et pas un de plus : la goutte est petite à l'écran (moins d'une
// demi-case), tout ce qui serait plus fin s'y perdrait.

uniform float phase = 0.0;
// Amplitude de l'ondulation, en fraction de la largeur.
uniform float wobble = 0.06;

void fragment() {
	vec2 uv = UV;
	// Ondulation latérale, plus forte vers le bas : la pointe fouette, la tête
	// reste stable.
	uv.x += sin(phase * 9.0 + UV.y * 7.0) * wobble * UV.y;
	vec4 col = texture(TEXTURE, clamp(uv, vec2(0.001), vec2(0.999)));
	// Le reflet qui descend le long de la goutte.
	float sheen = smoothstep(0.35, 0.0, abs(fract(phase * 0.9) - UV.y));
	col.rgb += vec3(0.35, 0.55, 0.7) * sheen * col.a * 0.7;
	COLOR = col * COLOR;
}
