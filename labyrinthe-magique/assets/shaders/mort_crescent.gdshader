shader_type canvas_item;
render_mode blend_mix;

// LE CROISSANT NOIR : une lame en croissant, tranchant rouge braise vers l'avant, corps noir et
// liseré couleur d'os, avec deux filets rouges qui traînent derrière.

uniform float seed = 0.0;

const vec3 EMBER = vec3(1.0, 0.416, 0.169);
const vec3 RED = vec3(0.886, 0.22, 0.165);
const vec3 BLACK = vec3(0.078, 0.075, 0.11);
const vec3 BONE = vec3(0.902, 0.875, 0.792);

void fragment() {
	vec2 q = vec2(UV.x * 2.0, (UV.y - 0.5) * 1.0);
	float outer = 0.48 - length(q - vec2(1.42, 0.0));
	float inner = length(q - vec2(1.14, 0.0)) - 0.5;
	float blade = min(outer, inner);
	vec3 color = BLACK;
	color = mix(color, RED, smoothstep(0.1, 0.05, outer));
	color = mix(color, EMBER, smoothstep(0.045, 0.015, outer));
	color = mix(BONE, color, smoothstep(0.0, 0.016, blade));
	float alpha = smoothstep(-0.004, 0.004, blade);
	// Les filets : ils s'affinent vers la queue et ondulent à peine.
	float bend = sin(UV.x * 9.0 - TIME * 18.0 + seed) * 0.012;
	float a = 0.02 * UV.x - abs(q.y - 0.14 * UV.x - bend);
	float b = 0.02 * UV.x - abs(q.y + 0.14 * UV.x + bend);
	float tail = max(a, b) * step(UV.x, 0.72);
	if (alpha < 0.5 && tail > 0.0) {
		color = RED;
		alpha = smoothstep(0.1, 0.6, UV.x);
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
