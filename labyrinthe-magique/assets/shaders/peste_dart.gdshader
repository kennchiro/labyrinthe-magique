shader_type canvas_item;
render_mode blend_mix;

// LE DARD VENIMEUX : une goutte effilée, pointe en avant, cœur clair, suivie de trois petites
// gouttes qui se détachent et tombent peu à peu.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 SHADE = vec3(0.306, 0.541, 0.071);
const vec3 RIM = vec3(0.118, 0.227, 0.047);

void fragment() {
	float along = UV.x;
	vec2 q = vec2(along, (UV.y - 0.5) * 2.0);
	// La goutte : ronde à l'arrière, effilée vers la droite.
	float t = clamp((along - 0.42) / 0.58, 0.0, 1.0);
	float width = sqrt(max(0.0, 1.0 - pow(t * 2.0 - 1.0, 2.0) * step(t, 0.5))) * pow(1.0 - t, 0.9) * 0.82;
	float body = (width - abs(q.y)) * step(0.42, along);
	// Les gouttes qui suivent, de plus en plus petites, avec un léger balancement.
	float tail = -1.0;
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float drift = sin(TIME * 7.0 + f * 2.1 + seed * 6.0) * 0.09;
		vec2 at = vec2(0.31 - f * 0.11, drift + (f - 1.0) * 0.28);
		tail = max(tail, (0.15 - f * 0.032) - length((q - at) * vec2(4.2, 1.0)) * 0.42);
	}
	float heat = max(body, tail);
	vec3 color = mix(VENOM, SHADE, smoothstep(0.08, 0.0, heat) * 0.55);
	color = mix(color, CORE, smoothstep(0.22, 0.34, body));
	color = mix(RIM, color, smoothstep(0.0, 0.05, heat));
	COLOR = vec4(color, smoothstep(-0.02, 0.0, heat) * COLOR.a);
}
