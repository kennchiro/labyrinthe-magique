shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE L'INVOCATEUR : un sceau frappé sur la cible, qui vole en trois éclats.
//
// Il arrive trop grand et s'écrase à sa taille, blanc sous le choc. Puis l'anneau et le
// triangle s'amincissent jusqu'à disparaître, et leurs trois sommets partent en lames.
// Il n'y a pas de fondu : c'est le trait qui fond, pour rester en aplats. Le même dessin
// que le grand cercle, mais en gros : à 2,5 cases, une couronne de marques ne se lirait pas.

uniform float seed = 0.0;
uniform float progress = 0.0;

const float RING = 0.62;
const float REACH = 0.28;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float slam = smoothstep(0.0, 0.2, progress);
	float burst = smoothstep(0.42, 1.0, progress);
	float d = length(p) * mix(1.4, 1.0, 1.0 - pow(1.0 - slam, 3.0));
	float a = atan(p.y, p.x);
	float turn = seed * TAU + slam * 0.5 + burst * 0.5;

	float swell = 0.5 + 0.5 * cos(a * 3.0 + turn * 2.0);
	float ring = 0.018 + 0.04 * swell * swell - burst * 0.1 - abs(d - RING);

	// Un côté de triangle : plein au milieu, en pointe à ses deux sommets.
	float sector = mod(a + turn, TAU / 3.0) - TAU / 6.0;
	float along = d * sin(sector) / (REACH * 1.732);
	float side = 0.058 * (1.0 - pow(min(abs(along) * 2.0, 1.0), 2.0)) + 0.004
		- burst * 0.1 - abs(d * cos(sector) - REACH);

	// Les éclats : un losange par sommet, qui file vers le bord en s'affinant.
	float vertex = mod(a + turn + TAU / 6.0, TAU / 3.0) - TAU / 6.0;
	float flight = REACH * 2.0 + burst * 0.3;
	float shard = 0.075 * (1.0 - abs(d - flight) / 0.2) * (1.0 - burst)
		- abs(d * sin(vertex)) - burst * 0.03;
	// Hors du losange, sa pente resterait à zéro le long du rayon, et le cerne y tracerait un fil.
	shard = burst > 0.0 ? min(shard, 0.2 - abs(d - flight)) : -1.0;

	float lines = max(max(ring, side), shard);
	float flash = 1.0 - smoothstep(0.08, 0.26, progress);

	vec3 color = vec3(0.16, 0.03, 0.3);
	float alpha = smoothstep(RING + 0.03, RING + 0.02, d) * 0.46 * (1.0 - smoothstep(0.42, 0.72, progress));
	color = mix(color, vec3(0.74, 0.34, 1.0), flash);
	float rim = smoothstep(-0.024, -0.014, lines);
	color = mix(color, vec3(0.1, 0.02, 0.22), rim);
	alpha = max(alpha, rim * 0.9);
	float body = smoothstep(-0.008, 0.0, lines);
	color = mix(color, vec3(0.74, 0.34, 1.0), body);
	alpha = max(alpha, body);
	color = mix(color, vec3(1.0, 0.86, 1.0), max(smoothstep(0.014, 0.024, lines), flash * body));
	COLOR = vec4(color, alpha * COLOR.a);
}
