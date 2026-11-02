// CE QUI PASSE SUR LE LABYRINTHE, partagé par le sol et les haies.
//
// Lu en coordonnées du MONDE : une nappe d'ombre traverse le sol et monte sur la haie
// sans couture, ce qu'aucun effet posé sur l'un des deux seulement ne ferait.
//
// Deux lectures de bruit par pixel et rien d'autre : pas de lecture de l'écran, pas de
// passe en plus. `cloud_depth` à zéro, le stage garde exactement son image fixe.

uniform sampler2D drift_noise : repeat_enable, filter_linear;
// Part de lumière retirée au cœur d'une nappe.
uniform float cloud_depth = 0.0;
// Lueur des éclairs lointains. Toutes les quinze secondes environ, jamais un flash franc.
uniform float flash = 0.0;

varying vec2 world_xz;

float cloud_shade() {
	float slow = texture(drift_noise, world_xz * 0.031 + TIME * vec2(0.011, 0.005)).r;
	float fine = texture(drift_noise, world_xz * 0.083 - TIME * vec2(0.009, 0.014)).r;
	float lightning = pow(max(0.0, sin(TIME * 0.41) * sin(TIME * 1.73)), 16.0);
	return 1.0 - cloud_depth * smoothstep(0.42, 0.68, slow * 0.72 + fine * 0.28) + flash * lightning;
}
