shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAT D'UN SAUT, d'une gemme ou d'une potion : une étoile qui claque, une onde fine
// et des étincelles projetées.
//
// ⚠️ Composition normale, comme le portail : en additif, il disparaissait sur le sable.
// L'onde et l'étoile portent un cerne sombre, qui les garde lisibles sur un sol clair.

uniform vec4 tint : source_color = vec4(0.56, 0.9, 1.0, 1.0);
uniform vec4 core_color : source_color = vec4(1.0);
uniform float seed = 0.0;
// De 0 à la naissance à 1 à la disparition.
uniform float progress = 0.0;

const float SPARKS = 11.0;

float hash(float n) {
	return fract(sin(n * 12.9898 + seed * 7.0) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float angle = atan(p.y, p.x);
	float t = 1.0 - (1.0 - progress) * (1.0 - progress);

	// L'ÉTOILE à quatre branches : elle jaillit vite, et se résorbe tout de suite.
	float clap = sin(PI * clamp(progress * 2.1, 0.0, 1.0));
	float turned = angle + seed + progress * 0.5;
	float branches = pow(abs(cos(turned * 2.0)), 6.0);
	float star_edge = clap * (0.1 + 0.62 * branches) - d;
	float star = smoothstep(0.0, 0.02, star_edge);
	float star_shade = smoothstep(-0.05, -0.02, star_edge) * step(0.01, clap);
	float star_core = smoothstep(0.03, 0.06, star_edge);

	// L'ONDE, fine et qui s'affine encore.
	float radius = 0.12 + 0.8 * t;
	float width = 0.01 + 0.035 * (1.0 - progress);
	float ring = 1.0 - smoothstep(width * 0.7, width, abs(d - radius));
	float ring_shade = 1.0 - smoothstep(width * 1.3, width * 2.2, abs(d - radius));

	// LES ÉTINCELLES : un losange par secteur, à sa propre vitesse.
	float sector = floor((angle / TAU + 0.5) * SPARKS);
	float pick = hash(sector + 1.0);
	float mid = (sector + 0.5 + (pick - 0.5) * 0.5) / SPARKS * TAU - PI;
	float reach = t * (0.5 + 0.42 * hash(sector + 5.0));
	vec2 spark_at = vec2(cos(mid), sin(mid)) * (0.08 + reach);
	vec2 off = p - spark_at;
	float size = (0.035 + 0.07 * hash(sector + 9.0)) * (1.0 - progress * 0.7);
	float spark = 1.0 - smoothstep(size * 0.8, size, abs(off.x) + abs(off.y));

	vec3 color = tint.rgb * 0.22;
	float alpha = max(ring_shade, star_shade) * 0.6;
	float lit = max(max(star, ring), spark);
	color = mix(color, tint.rgb, lit);
	alpha = max(alpha, lit);
	color = mix(color, core_color.rgb, max(star_core, spark * 0.6));

	COLOR = vec4(color, alpha * (1.0 - progress * progress * progress));
}
