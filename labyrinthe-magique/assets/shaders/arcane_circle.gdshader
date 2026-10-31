shader_type canvas_item;
render_mode blend_mix;

// LE CERCLE D'INVOCATION : gravé, pas brûlant. Deux anneaux et une étoile à six branches
// qui tournent lentement en sens contraire. Tout est tracé au compas, sans bruit.

uniform float radius_tiles = 2.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

float triangle(vec2 p, float turn) {
	float angle = atan(p.y, p.x) + turn;
	float sector = mod(angle, TAU / 3.0) - TAU / 6.0;
	return abs(length(p) * cos(sector) - 0.36);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float open = smoothstep(0.0, 0.5, phase);
	float width = 0.02;
	float rings = min(abs(d - 0.86), abs(d - 0.72));
	float star = min(triangle(p, phase * 0.3 + seed), triangle(p, phase * 0.3 + seed + PI));
	star = d < 0.72 ? star : 1.0;
	float line = 1.0 - smoothstep(width * 0.5, width, min(rings, star));
	float glow = (1.0 - smoothstep(width, width * 5.0, min(rings, star))) * 0.45;
	float fill = smoothstep(0.87, 0.85, d) * 0.2;
	float beat = 0.8 + 0.2 * sin(phase * 3.0);
	vec3 color = mix(vec3(0.35, 0.08, 0.55), vec3(0.98, 0.66, 1.0), line * beat);
	float reveal = smoothstep(open * 3.3 - 0.1, open * 3.3 - 0.4, atan(p.y, p.x) + PI);
	float alpha = max(line, max(glow, fill)) * max(reveal, step(1.0, open));
	COLOR = vec4(color, alpha * smoothstep(0.0, 0.1, life) * COLOR.a);
}
