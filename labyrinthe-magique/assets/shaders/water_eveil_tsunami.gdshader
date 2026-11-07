shader_type canvas_item;
render_mode blend_mix;

// Le Raz-de-marée éveillé : une lame plus haute, plus épaisse et plus écumante
// que la Vague normale, avec une crête cassée et des filets turquoise visibles.
uniform vec4 deep_color : source_color = vec4(0.015, 0.18, 0.48, 1.0);
uniform vec4 light_color : source_color = vec4(0.18, 0.72, 0.96, 1.0);
uniform vec4 foam_color : source_color = vec4(0.86, 0.98, 1.0, 1.0);
uniform sampler2D noise : repeat_enable, filter_linear;
uniform float phase = 0.0;
uniform float fade : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float across = UV.x;
	float along = UV.y;
	float n = texture(noise, vec2(across * 0.7, along * 0.28 + phase * 0.07)).r - 0.5;
	float belly = 1.0 - pow(abs(across - 0.5) * 2.0, 1.7);
	float crest_wave = sin(across * 21.0 + phase * 6.0) * 0.065
		+ sin(across * 9.0 - phase * 3.4) * 0.045;
	// La crête monte haut au centre, retombe en langues sur les côtés.
	float crest = 0.72 + belly * 0.25 + crest_wave + n * 0.045;
	float depth = (crest - along) / max(crest, 0.001);
	float back = 0.9 - depth + n * 0.48 - (1.0 - belly) * 0.42;
	float shape = min(min(depth, back), belly * 0.4 - 0.01);
	float body_mix = smoothstep(0.18, 0.82, depth + n * 0.12);
	vec3 body = mix(light_color.rgb, deep_color.rgb, body_mix);
	float streak = sin(across * 39.0 + phase * 2.0 + n * 8.0);
	body = mix(body, light_color.rgb, smoothstep(0.68, 0.91, streak) * smoothstep(0.2, 0.62, depth));
	float foam = 1.0 - smoothstep(0.12, 0.19, depth + n * 0.2);
	float spray = smoothstep(0.18, 0.42, n + sin(across * 46.0 + phase * 4.0) * 0.15)
		* (1.0 - smoothstep(0.2, 0.38, abs(depth - 0.31)));
	vec3 color = mix(body, foam_color.rgb, max(foam, spray * 0.8));
	color = mix(color, deep_color.rgb, 1.0 - smoothstep(0.012, 0.026, depth));
	COLOR = vec4(color, smoothstep(0.0, 0.014, shape) * 0.98 * fade);
}
