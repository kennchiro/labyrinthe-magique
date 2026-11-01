shader_type canvas_item;
render_mode blend_mix;

// LES AILES GARDIENNES : deux grandes ailes de lumière refermées devant lui, un cocon
// translucide à plumes bien dessinées qui respire lentement. On le voit à travers.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);
const vec3 RIM = vec3(0.29, 0.184, 0.071);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float close = smoothstep(0.0, 0.04, progress);
	float breath = 1.0 + 0.018 * sin(TIME * 2.2);
	p /= breath;
	// Une aile par côté, autour de son épaule : le bord extérieur est festonné de plumes, et
	// les deux ailes se rejoignent devant lui une fois refermées.
	vec2 q = vec2(abs(p.x) * 1.45, p.y * 0.72);
	float gap = mix(0.42, 0.015, close);
	vec2 v = q - vec2(gap, -0.42);
	float r = length(v);
	float a = atan(v.x, v.y);
	float opening = clamp(a / 1.45, 0.0, 1.0);
	float scallop = abs(sin(a * 8.5));
	float edge_r = (0.7 + 0.42 * sin(opening * PI * 0.92)) * (1.0 - 0.12 * opening) + 0.05 * scallop;
	float body = min(edge_r - r, q.x - gap);
	body = min(body, 1.45 - a);
	body = min(body, v.y + 0.06);
	// Trois rangées de plumes : des festons de plus en plus petits vers l'épaule.
	float rows = fract(r * 3.4 - scallop * 0.3);
	float line_row = smoothstep(0.86, 0.95, rows);
	float line_quill = smoothstep(0.92, 0.99, abs(cos(a * 8.5))) * smoothstep(0.3, 0.6, r);
	float lines = max(line_row, line_quill);
	float edge = smoothstep(0.0, 0.022, body);
	vec3 color = mix(vec3(1.0), GOLD, lines);
	color = mix(RIM, color, edge);
	float alpha = smoothstep(-0.006, 0.0, body) * mix(0.95, 0.42 + lines * 0.45, edge);
	float fade = 1.0 - smoothstep(0.96, 1.0, progress);
	COLOR = vec4(color, alpha * fade * COLOR.a);
}
