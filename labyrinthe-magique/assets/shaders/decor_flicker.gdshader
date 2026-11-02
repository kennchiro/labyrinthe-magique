shader_type canvas_item;

// Ce qui éclaire vacille : flammes, lanternes, runes.
//
// Un seul appel de dessin pour tous : la phase vient de la position du dessin dans le
// monde, donc deux lanternes voisines ne battent pas ensemble.

varying float beat;

void vertex() {
	vec2 at = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	float phase = floor(at.x / 32.0) * 1.7 + floor(at.y / 32.0) * 2.3;
	beat = sin(TIME * 7.0 + phase) * 0.5 + sin(TIME * 13.0 + phase * 1.6) * 0.3
		+ sin(TIME * 2.1 + phase * 0.7) * 0.5;
}

void fragment() {
	COLOR.rgb *= 1.04 + beat * 0.13;
}
