shader_type canvas_item;
render_mode blend_add;

// LE CHAMP ÉLECTRIFIÉ : un disque au sol parcouru de filaments qui serpentent.
//
// Pourquoi un shader et non des particules : l'électricité n'est pas faite de
// grains qui volent, elle est faite de TRAITS qui relient. Des particules
// donnent des étincelles — jolies, mais elles ne disent pas « ce sol est sous
// tension ». Des filaments qui rampent du centre vers le bord, si.
//
// Le tracé est calculé par pixel en coordonnées POLAIRES : chaque branche part
// du centre, et son serpentement dépend du rayon et du temps. C'est ce qui la
// fait onduler sans jamais se répéter, là où un motif dessiné tournerait en
// boucle visible au bout de deux secondes.
//
// Blending ADDITIF, comme le feu : l'électricité émet sa propre lumière. C'est
// l'eau qui fait exception dans ce jeu, parce qu'elle teinte au lieu d'éclairer.

uniform vec4 arc_color : source_color = vec4(0.85, 0.92, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.35, 0.55, 1.0, 1.0);
uniform float phase = 0.0;
// Vie restante de la zone : le champ PÂLIT en s'épuisant.
uniform float life : hint_range(0.0, 1.0) = 1.0;
// Nombre de branches. Impair de préférence : un nombre pair produit des
// symétries que l'œil repère aussitôt.
uniform float branches = 9.0;

float hash(float x) {
	return fract(sin(x * 127.1) * 43758.5453);
}

void fragment() {
	vec2 centred = UV * 2.0 - 1.0;
	float radius = length(centred);
	if (radius > 1.0) {
		COLOR = vec4(0.0);
	} else {
		float angle = atan(centred.y, centred.x) / 6.28318 + 0.5;

		// Chaque branche a son propre serpentement, tiré de son numéro : sans
		// ce décalage, les neuf filaments ondulent à l'unisson et le champ se
		// lit comme une roue qui tourne.
		float slot = angle * branches;
		float id = floor(slot);
		float local = fract(slot) - 0.5;
		float wiggle = sin(radius * 11.0 + phase * 5.0 + hash(id) * 24.0) * 0.20
		             + sin(radius * 23.0 - phase * 3.0) * 0.07;
		float filament = 1.0 - smoothstep(0.0, 0.11, abs(local - wiggle));

		// Les branches s'AMINCISSENT en s'éloignant du centre et meurent avant
		// le bord : une décharge part d'un point, elle ne remplit pas un disque.
		filament *= smoothstep(1.0, 0.55, radius) * smoothstep(0.0, 0.18, radius);
		// Paliers nets : le même parti pris « dessin animé » que l'onde de choc
		// du Feu et l'écume de la Vague.
		filament = floor(filament * 3.0) / 3.0 + filament * 0.3;

		// Le CRÉPITEMENT : certaines branches s'éteignent puis se rallument.
		float flicker = 0.55 + 0.45 * sin(phase * 9.0 + hash(id) * 30.0);
		filament *= flicker;

		// Halo au sol TRÈS faible. À 0,16 il recouvrait le labyrinthe d'un
		// aplat jaune et l'on ne voyait plus où l'on courait : une zone doit
		// marquer un sol, pas le remplacer.
		float halo = (1.0 - smoothstep(0.25, 1.0, radius)) * 0.07;
		// Bord net : c'est une information de jeu, il dit où le champ mord.
		float rim = (1.0 - smoothstep(0.0, 0.05, abs(radius - 0.93)))
		          * (0.28 + 0.22 * sin(phase * 7.0));

		// Les filaments tirent vers le BLANC BLEUTÉ et non vers la couleur de
		// l'élément : une décharge est blanche en son cœur, quelle que soit la
		// teinte de son halo. C'est ce contraste qui la fait lire comme de
		// l'électricité plutôt que comme une flaque lumineuse.
		vec3 tint = mix(glow_color.rgb, arc_color.rgb,
			clamp(filament * 1.4, 0.0, 1.0));
		float alpha = clamp(filament * 0.62 + halo + rim, 0.0, 1.0) * life;
		COLOR = vec4(tint, alpha);
	}
}
