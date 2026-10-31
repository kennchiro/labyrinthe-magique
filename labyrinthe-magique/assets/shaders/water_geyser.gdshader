shader_type canvas_item;
render_mode blend_mix;

// LE GEYSER : une colonne d'eau qui jaillit du sol et retombe en s'écartant.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform vec4 tint : source_color = vec4(1.0);

void fragment() {
	float x = abs(UV.x - 0.5) * 2.0;
	float y = 1.0 - UV.y;
	float rise = sin(min(progress * 1.25, 1.0) * PI);
	float n = texture(noise, vec2(UV.x * 0.8 + seed, y * 0.35 - progress * 1.4)).r - 0.5;
	float top = rise * 0.96;
	float width = 0.2 + 0.32 * y + n * 0.2;
	float column = (width - x) * smoothstep(top, top - 0.12, y);
	float foot = 0.2 - length(vec2(x * 0.9, (y - 0.03) * 5.0));
	float heat = max(column, foot * step(0.02, rise));
	vec3 color = mix(vec3(0.06, 0.42, 0.86), vec3(0.5, 0.88, 1.0), smoothstep(0.03, 0.12, heat));
	color = mix(color, vec3(1.0), smoothstep(0.2, 0.3, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.03, heat) * COLOR.a);
}
