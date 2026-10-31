shader_type canvas_item;
render_mode blend_mix;

// LA PLUIE DU GEYSER : une goutte en larme, pointe vers l'arrière. Rien à voir avec la
// météore : petite, claire, et trente en tombent ensemble.

uniform float seed = 0.0;

void fragment() {
	vec2 p = (UV - vec2(0.68, 0.5)) * vec2(1.7, 1.0);
	float d = length(p);
	float behind = clamp(-p.x / 1.1, 0.0, 1.0);
	float body = p.x < 0.0 ? 0.27 * pow(1.0 - behind, 1.8) - abs(p.y) : 0.27 - d;
	vec3 color = mix(vec3(0.08, 0.46, 0.9), vec3(0.62, 0.92, 1.0), smoothstep(0.03, 0.15, body));
	color = mix(color, vec3(1.0), smoothstep(0.1, 0.05, length(p - vec2(0.05, -0.08))));
	COLOR = vec4(color, smoothstep(0.0, 0.02, body) * COLOR.a);
}
