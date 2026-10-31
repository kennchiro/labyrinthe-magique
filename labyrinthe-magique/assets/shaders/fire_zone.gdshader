shader_type canvas_item;
render_mode blend_mix;

// LE SOL QUI BRÛLE, peint à l'écran au lieu d'être lu dans une planche.
//
// Inspiré de `peso&cover/sorts/mage_fire_skills.png`, cases 3 et 4 :
//   · `aura` à 0 : le Sol embrasé, de la roche fendue de lave cernée de flammes ;
//   · `aura` à 1 : l'Aura ardente, un cercle de feu et ses quatre pointes, qui
//     laisse voir le sol et ce qui s'y tient.
//
// Le bord du dessin tombe sur le RAYON DU SORT : le quad fait deux rayons de large,
// et le joueur lit directement jusqu'où la zone porte.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec4 core_color : source_color = vec4(1.0, 0.98, 0.78, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.78, 0.12, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.32, 0.04, 1.0);
uniform vec4 edge_color : source_color = vec4(0.55, 0.04, 0.02, 1.0);
uniform vec4 rock_color : source_color = vec4(0.2, 0.05, 0.04, 1.0);
uniform float aura = 0.0;
// Fait de la zone en cases, pour que le grain ne change pas avec le rayon.
uniform float radius_tiles = 2.0;
uniform float seed = 0.0;
// Secondes écoulées, et ce qu'il reste de vie de 1 à 0.
uniform float phase = 0.0;
uniform float life = 1.0;

const float OPEN_TIME = 0.35;
const float FADE_LIFE = 0.12;

vec3 flame_ramp(float heat) {
	vec3 color = edge_color.rgb;
	color = mix(color, flame_color.rgb, smoothstep(0.08, 0.2, heat));
	color = mix(color, hot_color.rgb, smoothstep(0.34, 0.48, heat));
	return mix(color, core_color.rgb, smoothstep(0.66, 0.8, heat));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	// Le sort s'ouvre depuis le centre, et s'éteint sur place.
	float open = smoothstep(0.0, OPEN_TIME, phase);
	float grain = radius_tiles * 0.2;
	vec2 at = p * grain;
	float wobble = texture(noise, at * 0.6 + vec2(phase * 0.05, -phase * 0.09) + seed).r - 0.5;
	float tongue = texture(noise, at * 1.1 + vec2(-phase * 0.07, phase * 0.16) + seed).r - 0.5;
	float rim = (0.84 * open - d) / 0.22 + wobble * 0.7 + tongue * 0.55;

	vec4 result;
	if (aura > 0.5) {
		// LE CERCLE, qui respire, et ses quatre pointes qui tournent lentement.
		float ring = 1.0 - abs(rim - 0.55) / 0.42;
		float angle = atan(p.y, p.x) + phase * 0.35;
		float spikes = pow(abs(cos(angle * 2.0)), 42.0);
		// Elles restent dans le quad : au-delà, elles seraient coupées net.
		ring = max(ring, spikes * smoothstep(0.2, 0.0, abs(d - 0.76 * open)) * 1.3);
		// Dedans, à peine une lueur tremblante : on doit voir qui s'y tient.
		float inner = smoothstep(0.1, 0.8, rim) * (0.13 + max(tongue, 0.0) * 0.6);
		float heat = max(ring, 0.0);
		vec3 color = mix(flame_color.rgb, flame_ramp(heat), smoothstep(0.0, 0.1, heat));
		float alpha = max(smoothstep(0.0, 0.12, heat), inner);
		result = vec4(color, alpha);
	} else {
		// LA ROCHE FENDUE : des plaques sombres, de la lave dans leurs joints, et
		// qui rougeoient davantage vers le centre.
		vec2 turn = at * 0.85 + seed * 0.61;
		float crack = abs(texture(noise, turn).r - 0.5) * 2.0;
		float pulse = 0.5 + 0.5 * sin(phase * 2.2 + wobble * 6.0);
		float vein = 1.0 - smoothstep(0.05, 0.13 + pulse * 0.04, crack);
		vec3 rock = mix(rock_color.rgb, flame_color.rgb, smoothstep(0.32, 0.16, crack) * 0.55);
		rock = mix(rock, hot_color.rgb, vein);
		// Le bord brûle : une couronne de flammes autour des plaques.
		vec3 color = mix(flame_ramp(1.0 - abs(rim - 0.45) / 0.45), rock, smoothstep(0.8, 1.05, rim));
		result = vec4(color, smoothstep(0.0, 0.1, rim) * 0.94);
	}
	COLOR = vec4(result.rgb, result.a * smoothstep(0.0, FADE_LIFE, life) * COLOR.a);
}
