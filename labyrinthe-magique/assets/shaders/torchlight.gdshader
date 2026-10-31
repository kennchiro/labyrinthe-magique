shader_type canvas_item;
// ⚠️ LE MODE DE COMPOSITION SE DÉCLARE ICI. Sur un ShaderMaterial, poser un
// CanvasItemMaterial en `next_pass` n'y change rien : ça AJOUTE une passe, ça ne
// change pas la composition de la première. Le halo restait donc en alpha
// ordinaire — il voilait le décor de blanc au lieu de l'éclairer.
render_mode blend_add;

// LE HALO DU MAGE : le monde s'éclaire autour de lui.
//
// C'est le signal le plus fort de tous — le décor RÉAGIT au personnage. Sans
// lui, le sol sous ses pieds est exactement celui de vingt cases plus loin, et
// rien ne dit qu'il porte une lumière.
//
// Additif, et c'est le bon choix ici : une lumière AJOUTE. Le piège de la flaque
// d'ombre était l'inverse — on ne peut pas peindre du noir en additif.

uniform vec2 focus = vec2(0.5, 0.5);
uniform vec4 glow : source_color = vec4(1.0, 0.92, 0.72, 1.0);
uniform float reach : hint_range(0.02, 1.0) = 0.46;
uniform float strength : hint_range(0.0, 1.0) = 0.15;
// Battement du halo : une flamme ne brûle pas d'un éclat constant.
uniform float flicker : hint_range(0.0, 0.5) = 0.05;

void fragment() {
	vec2 offset = UV - focus;
	// Même correction de rapport que la vignette, sinon le halo est un ovale.
	offset.x *= 1.62;
	float radius = length(offset);
	// ⚠️ CHUTE DOUCE, PAS QUADRATIQUE. Élevée au carré, la lumière faisait un
	// noyau blanc serré cerclé de nuit : le contraste entre la flaque et son
	// bord se voyait plus que la flaque elle-même. Mesuré, le rapport
	// centre/bord de l'écran montait à 2,3 — un labyrinthe se lit mal quand ses
	// coins perdent la moitié de leur lumière.
	float fall = 1.0 - smoothstep(0.0, reach, radius);
	float beat = 1.0 + sin(TIME * 5.3) * flicker + sin(TIME * 2.1) * flicker * 0.6;
	COLOR = vec4(glow.rgb, clamp(fall * strength * beat, 0.0, 1.0));
}
