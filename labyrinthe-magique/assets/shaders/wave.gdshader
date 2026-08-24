shader_type canvas_item;
render_mode blend_mix;

// LE FRONT DE VAGUE, en shader : un mur d'eau vu de dessus qui déferle.
//
// Pourquoi un shader plutôt que des traits dessinés : une vague n'est pas une
// barre. Elle a un VENTRE (plus haute au centre, elle s'affaisse aux bords),
// une crête d'écume au bord d'attaque, et un dos qui s'étale derrière. Trois
// traits empilés donnaient une masse, pas une lame — il manquait le PROFIL.
//
// Le blending est NORMAL et non additif : de l'eau assombrit et teinte ce
// qu'elle recouvre, elle ne l'éclaire pas. C'est l'inverse du feu, et c'est ce
// qui distingue les deux au premier coup d'œil.
//
// Repère : UV.x traverse la lame (0 à 1 d'un bord à l'autre),
//          UV.y suit la course (0 = l'arrière, 1 = le bord d'attaque).

uniform vec4 deep_color : source_color = vec4(0.06, 0.35, 0.62, 1.0);
uniform vec4 light_color : source_color = vec4(0.35, 0.78, 1.0, 1.0);
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// Avance dans le temps : fait rouler l'écume et onduler la crête.
uniform float phase = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float across = UV.x;
	float along = UV.y;

	// LE VENTRE : la lame est plus profonde au centre et s'affaisse aux bords.
	// Sans lui, les extrémités seraient aussi hautes que le milieu et le front
	// se lirait comme un rectangle.
	float belly = 1.0 - pow(abs(across - 0.5) * 2.0, 2.2);

	// LA CRÊTE ONDULE. Deux sinus de fréquences différentes plutôt qu'un seul :
	// une seule onde donne une tôle ondulée régulière, deux qui se déphasent
	// donnent une eau qui ne se répète pas.
	float ripple = sin(across * 17.0 + phase * 7.0) * 0.035
	             + sin(across * 6.0 - phase * 3.1) * 0.028;
	float front = 0.66 + belly * 0.26 + ripple;

	// Rien devant le bord d'attaque.
	if (along > front) {
		COLOR = vec4(0.0);
	} else {
		// Profondeur dans la lame, de 0 au bord d'attaque à 1 tout au fond.
		float depth = clamp((front - along) / max(front, 0.001), 0.0, 1.0);

		// L'ÉCUME : une bande claire juste derrière le bord, quantifiée en
		// paliers — le même parti pris « dessin animé » que l'onde de choc du
		// feu, pour que les deux éléments appartiennent au même jeu.
		// Bande d'écume plus large et plus franche : c'est le BORD D'ATTAQUE
		// qui fait lire un tsunami. Trop fine, la lame ressemblait à une nappe
		// diffuse qui glisse ; c'est le contraste net entre l'écume et l'eau
		// derrière qui donne l'impression d'un mur qui avance.
		float foam = 1.0 - smoothstep(0.0, 0.32, depth);
		foam = floor(foam * 3.0) / 3.0 + foam * 0.35;

		// Le corps : clair près de l'écume, profond au fond, et il s'efface en
		// s'éloignant — c'est le dos de la vague qui s'étale.
		vec3 body = mix(light_color.rgb, deep_color.rgb, smoothstep(0.1, 0.9, depth));
		vec3 tint = mix(body, foam_color.rgb, clamp(foam, 0.0, 1.0));

		float alpha = (0.80 - 0.55 * smoothstep(0.30, 1.0, depth)) * belly;
		alpha = max(alpha, foam * 0.98 * belly);
		COLOR = vec4(tint, alpha * fade);
	}
}
