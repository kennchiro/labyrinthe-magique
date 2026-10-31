shader_type canvas_item;
render_mode blend_mix;

// LE TRAIT OCCULTE de l'Invocateur : une aiguille GÉOMÉTRIQUE. Aucun bruit, aucune
// flamme : un losange net suivi de tirets, de la magie écrite plutôt que du feu.

uniform float seed = 0.0;

void fragment() {
	float along = UV.x;
	float across = abs(UV.y - 0.5) * 2.0;
	float needle = (1.0 - abs(along - 0.82) / 0.18) * 0.9 - across;
	// Trois tirets derrière, qui défilent vers la queue et rétrécissent.
	float dash = step(0.4, fract(along * 4.0 + TIME * 7.0 + seed)) * smoothstep(0.02, 0.5, along) * step(along, 0.64);
	float line = dash * (0.32 * along - across);
	float heat = max(needle, line);
	vec3 color = mix(vec3(0.82, 0.2, 0.92), vec3(1.0, 0.92, 1.0), smoothstep(0.1, 0.32, heat));
	COLOR = vec4(color, smoothstep(0.0, 0.05, heat) * COLOR.a);
}
