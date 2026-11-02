shader_type canvas_item;
render_mode blend_mix;

// L'ÉCLAT STELLAIRE : une petite étoile à quatre branches qui tourne en volant, suivie de trois
// points qui s'éteignent. Cernée de bleu très sombre pour tenir sur les sols clairs.

uniform float seed = 0.0;

const vec3 SHINE = vec3(0.859, 0.902, 1.0);
const vec3 BLUE = vec3(0.498, 0.635, 1.0);
const vec3 RIM = vec3(0.039, 0.063, 0.188);

float star(vec2 v, float size) {
	return size - pow(pow(abs(v.x), 0.6) + pow(abs(v.y), 0.6), 1.67);
}

void fragment() {
	vec2 q = vec2(UV.x * 2.4, (UV.y - 0.5));
	vec2 v = q - vec2(1.8, 0.0);
	float turn = TIME * 7.0 + seed;
	vec2 r = vec2(v.x * cos(turn) - v.y * sin(turn), v.x * sin(turn) + v.y * cos(turn));
	float heat = star(r, 0.34);
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		heat = max(heat, 0.075 - f * 0.018 - length(q - vec2(1.28 - f * 0.34, 0.0)));
	}
	vec3 color = mix(BLUE, SHINE, smoothstep(0.0, 0.03, heat));
	color = mix(color, vec3(1.0), smoothstep(0.03, 0.09, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.016, heat));
	COLOR = vec4(color, smoothstep(-0.012, -0.002, heat) * COLOR.a);
}
