shader_type canvas_item;

// Le halo d'un projectile de la Terre : un liseré de couleur autour du dessin,
// qui palpite pendant le vol.
//
// Il est fait en SHADER et non en dessinant le sprite plusieurs fois : le
// liseré doit épouser la silhouette exacte de la pierre — un rocher rond et une
// gemme pointue n'ont pas le même contour, et un halo circulaire posé derrière
// les trahirait tous les deux.
//
// La couleur vient du sort : verte pour la gemme, brune pour le rocher. C'est
// ce qui dit, avant même qu'on distingue la forme, ce qui vient d'être lancé.

uniform vec4 rim_color : source_color = vec4(0.45, 1.0, 0.4, 1.0);
// Épaisseur du liseré, en pixels de la texture.
uniform float rim_width = 2.5;
// Va de 0 à 1 pendant le vol : le halo respire une fois par jet.
uniform float phase = 0.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 step = TEXTURE_PIXEL_SIZE * rim_width;
	float around = 0.0;
	// Huit directions suffisent : au-delà, le liseré ne change plus à l'œil et
	// chaque échantillon coûte sur mobile.
	for (int i = 0; i < 8; i++) {
		float angle = float(i) * 0.7853981;
		vec2 offset = vec2(cos(angle), sin(angle)) * step;
		around = max(around, texture(TEXTURE, UV + offset).a);
	}
	float rim = clamp(around - base.a, 0.0, 1.0);
	float beat = 0.65 + 0.35 * sin(phase * 12.566);
	vec3 tinted = base.rgb + rim_color.rgb * rim * beat * 1.4;
	// Le cœur du dessin reçoit lui aussi un souffle de couleur, sinon la pierre
	// reste terne au milieu de son halo.
	tinted += rim_color.rgb * base.a * 0.18 * beat;
	float alpha = max(base.a, rim * rim_color.a * beat);
	COLOR = vec4(tinted, alpha) * COLOR;
}
