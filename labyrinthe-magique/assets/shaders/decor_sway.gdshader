shader_type canvas_item;

// Le vent dans les plantes : le haut du dessin balance, le pied reste planté.
//
// Tout le décor tient dans un seul appel de dessin : rien à animer côté moteur, et le
// décalage de phase vient de la position, donc les voisins ne battent pas ensemble.

// Déplacement du sommet du dessin, en pixels du monde.
uniform float strength = 2.4;

void vertex() {
	vec2 at = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	float phase = at.x * 0.021 + at.y * 0.013;
	float push = sin(TIME * 1.3 + phase) * 0.65 + sin(TIME * 3.1 + phase * 2.3) * 0.35;
	VERTEX.x += push * (1.0 - UV.y) * strength;
}
