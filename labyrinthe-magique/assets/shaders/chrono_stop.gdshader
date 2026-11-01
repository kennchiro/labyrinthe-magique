shader_type canvas_item;
render_mode blend_mix;

// L'ARRÊT DU TEMPS : un immense cadran de cuivre, fissuré de lumière turquoise, ses deux
// aiguilles figées. Il tient toute la durée du sort, assez translucide pour qu'on voie les
// couloirs, et vole en éclats à la fin : c'est là que tout repart.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;

float line(vec2 p, vec2 dir, float length_max, float width) {
	float forward = dot(p, dir);
	float side = abs(dot(p, vec2(-dir.y, dir.x)));
	return (width * (1.0 - forward / length_max * 0.7) - side) * step(0.0, forward) * step(forward, length_max);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = 1.0 - pow(1.0 - clamp(progress / 0.08, 0.0, 1.0), 3.0);
	float reach = 0.8 * open;
	float body = reach - d;
	float crack_noise = texture(noise, p * 0.9 + seed).r;
	float crack = smoothstep(0.014, 0.004, abs(crack_noise - 0.5));

	vec3 color = vec3(0.1, 0.5, 0.47);
	float alpha = 0.16;
	float ring = max(0.016 - abs(d - reach + 0.02), 0.006 - abs(d - reach * 0.8));
	float turn = fract((a + PI) / TAU * 12.0 + 0.5);
	float mark = (0.012 - abs(turn - 0.5) * 0.52 * d) * step(reach * 0.84, d) * step(d, reach * 0.96);
	float metal = max(ring, mark);
	color = mix(color, vec3(0.92, 0.56, 0.22), smoothstep(0.0, 0.004, metal));
	alpha = max(alpha, smoothstep(0.0, 0.004, metal) * 0.75);
	float hands = max(line(p, vec2(0.0, -1.0), reach * 0.68, 0.012), line(p, vec2(0.76, -0.65), reach * 0.45, 0.016));
	hands = max(hands, 0.022 - d);
	color = mix(color, vec3(1.0, 0.76, 0.38), smoothstep(0.0, 0.004, hands));
	alpha = max(alpha, smoothstep(0.0, 0.004, hands) * 0.6);
	color = mix(color, vec3(0.62, 1.0, 0.93), crack);
	alpha = max(alpha, crack * 0.55);

	// Le dernier dixième : les plaques cèdent, de la plus sombre à la plus claire.
	float shatter = smoothstep(0.9, 1.0, progress);
	float gone = step(crack_noise, shatter * 1.05);
	float flash = smoothstep(0.0, 0.06, progress) * (1.0 - smoothstep(0.06, 0.2, progress));
	color = mix(color, vec3(0.9, 1.0, 0.97), flash * 0.7);
	COLOR = vec4(color, smoothstep(0.0, 0.01, body) * (alpha + flash * 0.3) * (1.0 - gone) * COLOR.a);
}
