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
uniform sampler2D noise : repeat_enable, filter_linear;
// Avance dans le temps : fait rouler l'écume et onduler la crête.
uniform float phase = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float across = UV.x;
	float along = UV.y;
	float n = texture(noise, vec2(across * 0.55, along * 0.22 + phase * 0.05)).r - 0.5;

	// LE VENTRE : la lame est plus profonde au centre et s'affaisse aux bords.
	// Sans lui, les extrémités seraient aussi hautes que le milieu et le front
	// se lirait comme un rectangle.
	float belly = 1.0 - pow(abs(across - 0.5) * 2.0, 2.2);

	// LA CRÊTE ONDULE. Deux sinus de fréquences différentes plutôt qu'un seul :
	// une seule onde donne une tôle ondulée régulière, deux qui se déphasent
	// donnent une eau qui ne se répète pas.
	float ripple = sin(across * 17.0 + phase * 7.0) * 0.035
	             + sin(across * 6.0 - phase * 3.1) * 0.028;
	float front = 0.66 + belly * 0.26 + ripple + n * 0.05;

	// Profondeur dans la lame, de 0 au bord d'attaque à 1 tout au fond.
	float depth = (front - along) / max(front, 0.001);

	// ⚠️ LE DOS SE DÉCOUPE, il ne s'efface pas : l'opacité valait encore un quart au bout
	// du quad, et la lame traînait un bord droit de rectangle. Le sillage s'effiloche en
	// langues, et les côtés se referment avec le ventre.
	float wake = 0.86 - depth + n * 0.42 - (1.0 - belly) * 0.55;
	float shape = min(min(depth, wake), belly * 0.34 - 0.012);

	// LES TROIS TONS, en aplats : le mur clair derrière l'écume, le corps, le creux.
	vec3 body = mix(light_color.rgb, mix(light_color.rgb, deep_color.rgb, 0.5), smoothstep(0.26, 0.3, depth + n * 0.1));
	body = mix(body, deep_color.rgb, smoothstep(0.54, 0.58, depth + n * 0.2));
	// Les filets filent dans le sens de la course : ce sont eux qui font avancer l'eau.
	float strand = sin(across * 34.0 + n * 9.0);
	body = mix(body, light_color.rgb, smoothstep(0.72, 0.84, strand) * smoothstep(0.22, 0.34, depth));

	// L'ÉCUME : un bord net et irrégulier, puis une seconde crête cassée derrière lui.
	// C'est le BORD D'ATTAQUE qui fait lire un mur d'eau qui avance.
	float foam = 1.0 - smoothstep(0.13, 0.16, depth + n * 0.14);
	foam = max(foam, smoothstep(0.03, 0.07, n) * (1.0 - smoothstep(0.02, 0.04, abs(depth - 0.25))));
	vec3 color = mix(body, foam_color.rgb, foam);
	// Le cerne : sans lui, l'écume blanche disparaît sur les stages clairs.
	color = mix(color, deep_color.rgb, 1.0 - smoothstep(0.012, 0.022, depth));

	COLOR = vec4(color, smoothstep(0.0, 0.012, shape) * 0.94 * fade);
}
