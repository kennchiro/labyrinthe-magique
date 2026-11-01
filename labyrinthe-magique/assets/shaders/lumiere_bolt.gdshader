shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT D'AUBE : un trait effilé à cœur blanc et bords d'or, cerné de brun pour tenir sur
// les sols clairs, qui se termine en petite étoile. Des plumes minuscules s'en détachent.

uniform float seed = 0.0;

const vec3 CORE = vec3(1.0);
const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);
const vec3 RIM = vec3(0.29, 0.184, 0.071);

void fragment() {
	float along = UV.x;
	vec2 q = vec2(along, (UV.y - 0.5) * 2.0);
	float body = along * 0.55 - abs(q.y) - 0.02;
	body = min(body, (1.0 - along) * 3.0);
	// L'étoile à quatre pointes vers l'avant.
	vec2 s = (q - vec2(0.8, 0.0)) * vec2(5.0, 1.0);
	float star = 0.34 - pow(pow(abs(s.x), 0.62) + pow(abs(s.y), 0.62), 1.6);
	float heat = max(body, star);
	// Les plumes : des tirets qui défilent vers la queue.
	float flow = fract(along * 3.5 + TIME * 3.0 + seed);
	float bit = step(0.72, flow) * step(along, 0.55) * (0.1 * along - abs(abs(q.y) - 0.22 * along));
	vec3 color = mix(GOLD, SHINE, smoothstep(0.02, 0.08, heat));
	color = mix(color, CORE, smoothstep(0.1, 0.17, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.025, heat));
	float alpha = smoothstep(-0.01, 0.0, heat);
	color = mix(GOLD, color, alpha);
	COLOR = vec4(color, max(alpha, step(0.0001, bit)) * COLOR.a);
}
