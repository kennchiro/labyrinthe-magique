shader_type canvas_item;
render_mode blend_mix;

// LE BOUCLIER D'EAU : une coque d'eau qui respire autour du mage.
//
// Sa surface bouge lentement, et ce sont les reflets qui font la bulle : un croissant en
// haut à gauche, son rappel en bas à droite, posés sur le BORD. Le mage reste au centre
// pendant trente secondes : rien de franc ne doit passer devant lui.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

float crescent(vec2 p, vec2 at, float size, vec2 away) {
	return min(size - length(p - at), length(p - at - away) - size * 0.96);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float a = atan(p.y, p.x);
	// Deux ondes lentes sur le pourtour : la bulle se déforme sans jamais trembler.
	float swell = sin(a * 3.0 + TIME * 1.7 + seed * 6.0) * 0.016 + sin(a * 5.0 - TIME * 2.3) * 0.009;
	float d = length(p) + swell;
	float shell = 0.9 - d;

	// Des lueurs d'eau glissent dans la coque, surtout près du bord.
	float n = texture(noise, p * 0.2 + vec2(TIME * 0.05, -TIME * 0.035) + seed).r;
	float caustic = smoothstep(0.045, 0.02, abs(n - 0.5)) * smoothstep(0.4, 0.74, d);

	float band = smoothstep(0.78, 0.8, d);
	vec3 color = mix(vec3(0.3, 0.72, 1.0), vec3(0.2, 0.6, 0.98), band);
	float alpha = mix(0.12, 0.26, band);
	color = mix(color, vec3(0.62, 0.92, 1.0), caustic);
	alpha = max(alpha, caustic * 0.7);
	// Le liseré clair, puis le cerne qui tient sur les sols clairs.
	float line = smoothstep(0.05, 0.035, shell);
	color = mix(color, vec3(0.8, 0.97, 1.0), line);
	alpha = max(alpha, line * 0.9);
	color = mix(color, vec3(0.06, 0.34, 0.74), smoothstep(0.014, 0.008, shell));

	float shine = max(crescent(p, vec2(-0.4, -0.4), 0.42, vec2(0.1, 0.11)),
		crescent(p, vec2(0.46, 0.46), 0.3, vec2(-0.06, -0.07)));
	float glint = 0.05 - length(p - vec2(-0.2, -0.68));
	float white = smoothstep(0.0, 0.012, max(shine, glint));
	color = mix(color, vec3(1.0), white);
	alpha = max(alpha, white * 0.92);

	COLOR = vec4(color, alpha * smoothstep(0.0, 0.01, shell) * COLOR.a);
}
