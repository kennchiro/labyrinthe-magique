shader_type canvas_item;
render_mode blend_mix;

// LE COURANT : le mage se liquéfie, et l'eau l'avale en tourbillon.
//
// Trois bras INÉGAUX, tordus par le bruit, effilés au bout, qui se resserrent vers le
// centre. Une spirale géométrique tenait mieux du logo que de l'eau.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	// Le tourbillon se referme : le même dessin, vu de plus en plus loin.
	vec2 q = p * vec2(1.0, 1.18) / max(0.2, 1.0 - progress * progress * 0.6);
	float d = length(q);
	float a = atan(q.y, q.x);
	float n = texture(noise, vec2(cos(a), sin(a)) * 0.08 + vec2(d * 0.1 - progress * 0.3, seed)).r - 0.5;
	float spin = a + d * 5.6 - progress * 8.0 + seed * 6.0 + n * 0.55;
	float arm = 0.5 + 0.5 * cos(spin * 3.0);
	// Le bras le plus large est plus large que les autres, et tout s'affine vers le bord.
	float which = sin(floor(spin * 3.0 / TAU + 0.5) * 2.4 + seed * 9.0);
	float reach = 0.9 + which * 0.07 - d;
	float heat = arm - 0.42 + which * 0.1 - (1.0 - clamp(reach * 3.4, 0.0, 1.0)) * 0.42;
	heat = min(heat, reach * 1.2);
	// Le puits : le centre est creux, et sombre.
	float well = 0.08 + progress * 0.08 - d;
	vec3 color = mix(vec3(0.03, 0.28, 0.68), vec3(0.14, 0.58, 0.96), smoothstep(0.02, 0.06, heat));
	color = mix(color, vec3(0.72, 0.96, 1.0), smoothstep(0.1, 0.13, heat));
	color = mix(color, vec3(1.0), smoothstep(0.34, 0.37, heat));
	color = mix(color, vec3(0.02, 0.16, 0.42), smoothstep(0.0, 0.02, well));
	float alpha = max(smoothstep(0.0, 0.02, heat), smoothstep(0.0, 0.02, well));
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.76, 1.0, progress)) * COLOR.a);
}
