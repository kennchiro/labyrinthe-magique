shader_type canvas_item;
render_mode blend_mix;

// L'ANNEAU DE FORGE : un cercle d'acier riveté, bordé d'orange, qui se resserre puis claque. C'est
// la plaque reforgée et l'ouverture de l'armure en fusion.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 STEEL = vec3(0.875, 0.902, 0.933);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float RIVETS = 8.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x) - progress * 1.2;
	float close = 1.0 - smoothstep(0.0, 0.55, progress);
	float at = 0.34 + 0.46 * close;
	float width = 0.05;
	float band = width - abs(d - at);
	vec3 color = band > 0.022 ? STEEL : HOT;
	float alpha = smoothstep(-0.012, -0.004, band);
	color = mix(RIM, color, smoothstep(0.0, 0.006, band));
	float cell = TAU / RIVETS;
	float local = (mod(a + cell * 0.5, cell) - cell * 0.5) * d;
	float rivet = 0.024 - length(vec2(local, d - at));
	if (rivet > 0.0) {
		color = RIM;
	}
	COLOR = vec4(color, alpha * (1.0 - smoothstep(0.65, 1.0, progress)) * COLOR.a);
}
