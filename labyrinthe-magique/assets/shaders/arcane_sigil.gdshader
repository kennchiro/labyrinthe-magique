shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT DE L'INVOCATEUR : un sceau qui s'imprime et se dissout en un trait. Un
// triangle et un cercle fins, sans matière, qui disent où le coup a porté.

uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float grow = 1.0 - pow(1.0 - progress, 2.5);
	float angle = atan(p.y, p.x) + seed + progress * 2.0;
	float tri = abs(d * cos(mod(angle, TAU / 3.0) - TAU / 6.0) - 0.34 * grow);
	float ring = abs(d - 0.74 * grow);
	float width = 0.035 * (1.0 - progress) + 0.006;
	float line = 1.0 - smoothstep(width * 0.5, width, min(tri, ring));
	vec3 color = mix(vec3(0.6, 0.14, 0.82), vec3(1.0, 0.88, 1.0), 1.0 - progress);
	COLOR = vec4(color, line * (1.0 - smoothstep(0.7, 1.0, progress)) * COLOR.a);
}
