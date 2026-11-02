shader_type canvas_item;
render_mode blend_mix;

// LE JUGEMENT CÉLESTE, à l'instant où il part : la foudre tombe du ciel sur le mage, et
// le sol encaisse. Un flash, un trait épais et fourchu qui maigrit, puis ce qui reste :
// le sol fendu, noirci, et l'onde qui s'en va.
//
// Tout se calcule en CASES depuis le point d'impact (le quad en fait 7,5 de côté). Le sol
// est vu en biais, donc ses ronds sont des ellipses. Le bruit est `thunder_noise.png`.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

const float SKY = 3.75;
const float SQUASH = 1.9;

void fragment() {
	vec2 q = (UV - 0.5) * SKY * 2.0;

	// LE TRAIT : une rangée du bruit par instant, il change de forme en claquant.
	float row = (mod(floor(progress * 16.0) * 37.0 + floor(seed * 256.0), 256.0) + 0.5) / 256.0;
	float along = clamp((q.y + SKY) / SKY, 0.0, 1.0);
	float line = (texture(noise, vec2(along * 0.5 + seed, row)).r - 0.5) * 1.7;
	line *= 1.0 - smoothstep(0.82, 1.0, along);
	float width = 0.2 * (1.0 - smoothstep(0.1, 0.5, progress)) * (0.5 + 0.5 * along);
	float x = abs(q.x - line);
	float bolt = width - x;
	// Deux fourches qui suivent ses cassures et s'en écartent : aucune lecture de plus.
	for (int i = 0; i < 2; i++) {
		float side = i == 0 ? -1.0 : 1.0;
		float t = (along - 0.3 - fract(row * (17.3 + float(i) * 23.0)) * 0.3) / 0.36;
		if (t > 0.0 && t < 1.0) {
			bolt = max(bolt, width * 0.55 * (1.0 - t) - abs(q.x - line - side * t * 1.2));
		}
	}
	float aloft = step(q.y, 0.0);
	float halo = (width * 3.2 - x) * aloft;
	bolt *= aloft;

	// LE SOL : il noircit, il se fend, et l'onde part devant.
	vec2 g = q * vec2(1.0, SQUASH);
	float d = length(g);
	float t = 1.0 - pow(1.0 - progress, 2.6);
	float reach = t * 3.3;
	float crack = texture(noise, g * 0.17 + seed).g * smoothstep(reach, reach * 0.5, d);
	crack *= 1.0 - smoothstep(0.62, 0.98, progress);
	float scorch = smoothstep(reach * 0.72, reach * 0.62, d) * (1.0 - smoothstep(0.5, 1.0, progress));
	float shock = 0.085 * (1.0 - progress) - abs(d - reach);
	float echo = 0.05 * (1.0 - progress) - abs(d - max(0.0, t - 0.2) * 2.9);
	float wave = max(shock, echo);
	float flash = (1.15 * (1.0 - progress / 0.16)) - d;

	vec3 color = vec3(0.04, 0.06, 0.2);
	float alpha = scorch * 0.3;
	float blue = max(smoothstep(0.3, 0.42, crack), smoothstep(0.0, 0.012, wave));
	color = mix(color, vec3(0.2, 0.34, 1.0), blue);
	alpha = max(alpha, blue * 0.92);
	float white = max(smoothstep(0.58, 0.72, crack), smoothstep(0.016, 0.04, wave));
	white = max(white, max(smoothstep(0.0, 0.02, flash), smoothstep(0.0, 0.012, bolt)));
	float glow = smoothstep(0.0, 0.3, halo) * 0.5;
	color = mix(color, vec3(0.3, 0.45, 1.0), step(alpha, glow));
	alpha = max(alpha, glow);
	color = mix(color, vec3(1.0, 1.0, 0.9), white);
	alpha = max(alpha, white);
	COLOR = vec4(color, alpha * COLOR.a);
}
