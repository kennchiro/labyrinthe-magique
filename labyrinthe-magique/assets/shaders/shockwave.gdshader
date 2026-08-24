shader_type canvas_item;
render_mode blend_add;

// Onde de choc « toon » : un anneau qui s'écarte, à bords NETS.
//
// Pourquoi un shader plutôt qu'un draw_arc : l'anneau est quantifié en trois
// paliers d'intensité (le rendu cartoon), avec un cœur blanc, une couronne
// colorée et une frange sombre. Un arc dessiné donnerait un dégradé lisse —
// joli, mais fondu dans le décor. C'est la NETTETÉ qui fait « coup porté ».
//
// Aucune lecture d'écran (pas de SCREEN_TEXTURE) : ça marcherait mal en
// gl_compatibility sur mobile, et le jeu vise l'iPhone en priorité.

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 core_color : source_color = vec4(1.0, 0.95, 0.75, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.42, 0.10, 1.0);
// Épaisseur de l'anneau au départ, en fraction du rayon.
uniform float thickness : hint_range(0.02, 0.6) = 0.22;
// Opacité maximale de l'anneau. Réglée BAS après essai : à pleine opacité,
// l'onde d'un ultime (rayon 5,5) noyait tout l'écran et le labyrinthe
// disparaissait sous un voile blanc. Une onde de choc doit ÉBLOUIR une
// fraction de seconde, pas cacher le jeu — on doit continuer à voir où l'on
// court pendant qu'elle passe.
uniform float strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 centred = UV * 2.0 - 1.0;
	float radius = length(centred);

	// L'anneau s'écarte vite puis ralentit : une onde perd son élan.
	float wave = 1.0 - pow(1.0 - progress, 2.2);
	// Et il s'AMINCIT en s'écartant, comme une onde qui se dilue.
	float band = thickness * (1.0 - 0.65 * progress);
	float distance_to_ring = abs(radius - wave);
	float intensity = clamp(1.0 - distance_to_ring / max(band, 0.001), 0.0, 1.0);

	// Trois paliers : c'est ce qui donne le trait de dessin animé.
	float toon = floor(intensity * 3.0) / 3.0;
	toon = max(toon, intensity * 0.35);   // un souffle de dégradé sous les paliers

	vec3 tint = mix(edge_color.rgb, core_color.rgb, pow(intensity, 1.8));
	// Le disque intérieur reste sombre : sans ça l'anneau se remplit et devient
	// une boule, ce qui écrase le personnage au centre.
	float hollow = smoothstep(wave - band, wave, radius);
	float fade = 1.0 - smoothstep(0.45, 1.0, progress);
	float alpha = toon * fade * mix(0.08, 1.0, hollow) * strength;
	alpha *= step(radius, 1.0);           // rien hors du cercle

	COLOR = vec4(tint, alpha);
}
