shader_type canvas_item;

// LA VIGNETTE : le monde s'assombrit vers les bords de l'écran.
//
// C'est ce qui distingue un LIEU d'une planche de tuiles. Un labyrinthe éclairé
// uniformément d'un bord à l'autre se lit comme une carte ; le même labyrinthe
// dont les bords s'éteignent se lit comme un endroit où l'on est.
//
// Composée en ALPHA ordinaire et non en multiplication : le renderer est
// `gl_compatibility`, et lire l'écran y coûte une copie du tampon. Une nappe
// sombre à alpha variable fait le même travail pour rien.

uniform vec4 tint : source_color = vec4(0.03, 0.05, 0.12, 1.0);
// Rayon où la nappe commence, et où elle atteint sa densité pleine.
uniform float inner : hint_range(0.0, 1.5) = 0.40;
uniform float outer : hint_range(0.0, 2.0) = 1.02;
// ⚠️ MESURÉE, PAS CHOISIE À L'ŒIL. À 0,74 le rapport de luminosité entre le
// centre de l'écran et ses coins atteignait 2,3 : joli sur une capture, illisible
// en jeu — on perd de vue les couloirs et les poursuivants qui y arrivent. Le
// réglage donne 1,52 sur le sable et 1,54 sur le cristal : assez pour creuser,
// pas assez pour cacher, et surtout le MÊME des deux côtés.
uniform float density : hint_range(0.0, 1.0) = 0.40;
// Respiration très lente de la lumière ambiante. Sans elle la vignette est un
// cache posé sur l'objectif ; avec elle, l'air bouge.
uniform float breath : hint_range(0.0, 0.4) = 0.06;
uniform float time_scale : hint_range(0.0, 2.0) = 0.25;

void fragment() {
	// Distance au centre, corrigée du rapport de l'écran : sans correction, la
	// vignette est un ovale sur un écran large et un cercle sur un carré.
	vec2 offset = (UV - vec2(0.5)) * vec2(2.0, 2.0);
	offset.y *= 0.62;
	float radius = length(offset);
	float shade = smoothstep(inner, outer, radius) * density;
	shade += sin(TIME * time_scale) * breath * shade;
	COLOR = vec4(tint.rgb, clamp(shade, 0.0, 1.0));
}
