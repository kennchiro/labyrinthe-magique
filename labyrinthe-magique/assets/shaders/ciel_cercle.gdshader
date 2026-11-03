shader_type canvas_item;
render_mode blend_mix;

// LE CERCLE DE LA COLONNE : il se dessine au sol et se REMPLIT depuis le centre pendant la chute,
// pour qu'on lise la zone avant que le pilier ne s'abatte. Six runes tournent sur son bord.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 DEEP = vec3(0.059, 0.478, 0.29);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float t = progress;
	float drawn = smoothstep(0.0, 0.25, t);
	vec3 color = DEEP;
	float a = 0.0;
	float fill = 0.8 * smoothstep(0.1, 1.0, t);
	if (d < fill) {
		color = d > fill - 0.05 ? EMERALD : DEEP;
		a = d > fill - 0.05 ? 1.0 : 0.5;
	}
	float ring = 0.05 - abs(d - 0.8);
	float angle = atan(p.y, p.x);
	float swept = angle + 3.1416 < drawn * 6.2832 ? 1.0 : 0.0;
	if (ring > -0.022 && swept > 0.5) {
		color = ring > 0.018 ? PALE : (ring > 0.0 ? EMERALD : RIM);
		a = 1.0;
	}
	for (int i = 0; i < 6; i++) {
		float at = float(i) / 6.0 * 6.2832 + t * 3.0 + seed;
		vec2 c = vec2(cos(at), sin(at)) * 0.8;
		float rune = 0.075 - (abs(p.x - c.x) + abs(p.y - c.y));
		if (rune > -0.025 && drawn > 0.9) {
			color = rune > 0.0 ? GOLD : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
