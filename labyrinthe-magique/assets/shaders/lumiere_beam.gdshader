shader_type canvas_item;
render_mode blend_mix;

// LA LANCE SOLAIRE, posée sur un ruban qui suit les couloirs. UV.x va du mage au bout du trajet,
// UV.y traverse le ruban. Un cœur blanc qui palpite, une bande d'or où filent des paquets de
// lumière, deux arcs brisés qui crépitent autour, et un halo. `run` est la tête, `gone` la queue, `body` l'épaisseur.
// `length_tiles` garde tout à la même taille, quelle que soit la longueur du trajet.

uniform float seed = 0.0;
uniform float run = 1.0;
uniform float gone = 0.0;
uniform float body = 1.0;
uniform float length_tiles = 6.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.76, 0.26);
const vec3 AMBER = vec3(0.91, 0.56, 0.16);
const vec3 RIM = vec3(0.29, 0.184, 0.071);

void fragment() {
	float tiles = UV.x * length_tiles;
	float side = UV.y - 0.5;
	float across = abs(side) * 2.0;
	float lead = clamp((run - UV.x) * length_tiles / 1.6, 0.0, 1.0);
	float tail = clamp((UV.x - gone) * length_tiles / 1.2, 0.0, 1.0);
	float shape = sqrt(lead * tail) * body;

	float pulse = sin(tiles * 2.6 - TIME * 24.0 + seed) * 0.5 + 0.5;
	float width = 0.42 * shape * (0.84 + 0.16 * pulse);
	float heat = width - across;

	// Deux arcs d'énergie brisés qui crépitent le long du cœur, pas une courbe régulière.
	float reach = 0.31 * shape;
	float jolt_a = sin(tiles * 7.3 - TIME * 31.0 + seed) * 0.6 + sin(tiles * 16.1 + TIME * 23.0) * 0.4;
	float jolt_b = sin(tiles * 5.9 + TIME * 27.0 + seed * 2.0) * 0.6 + sin(tiles * 13.7 - TIME * 37.0) * 0.4;
	float coil = 1.0 - smoothstep(0.006, 0.02, min(abs(side - reach * jolt_a), abs(side - reach * jolt_b)));
	coil *= step(0.04, shape) * step(0.15, sin(tiles * 1.7 - TIME * 9.0 + seed) + 0.4);

	float halo = 1.0 - smoothstep(0.0, 0.98, across);
	halo *= halo * 0.55 * shape;

	// Des paquets de lumière qui filent du mage vers le bout, dans la bande d'or.
	float flow = step(0.5, sin(tiles * 4.2 - TIME * 38.0 + sin(UV.y * 17.0 + seed) * 1.2));

	vec3 color = mix(AMBER, GOLD, smoothstep(0.015, 0.05, heat));
	color = mix(color, SHINE, smoothstep(0.1, 0.17, heat) + flow * smoothstep(0.03, 0.08, heat) * 0.9);
	color = mix(color, vec3(1.0), smoothstep(0.2, 0.27, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.02, heat));
	float solid = smoothstep(0.0, 0.006, heat);

	vec3 glow = mix(GOLD, SHINE, coil);
	float outside = max(halo, coil);
	COLOR = vec4(mix(glow, color, solid), max(solid, outside) * COLOR.a);
}
