shader_type canvas_item;
render_mode blend_mix;

// L'ENCLUME FANTÔME : elle tombe du ciel, écrase le sol et s'efface en éclats. Sa silhouette est
// faite de trois boîtes : c'est elle qu'on doit lire, même très petite.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 STEEL = vec3(0.875, 0.902, 0.933);
const vec3 DARK = vec3(0.227, 0.267, 0.314);
const vec3 WHITE = vec3(1.0, 0.957, 0.878);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float LAND = 0.28;

float box(vec2 q, vec2 half_size) {
	vec2 e = abs(q) - half_size;
	return max(e.x, e.y);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float fall = clamp(progress / LAND, 0.0, 1.0);
	vec2 q = p + vec2(0.0, 0.95 * (1.0 - fall * fall));
	float top = box(q - vec2(0.02, -0.22), vec2(0.42, 0.09));
	float horn = max(box(q - vec2(-0.5, -0.24), vec2(0.17, 0.07)), -(q.x + 0.68) - (q.y + 0.17) * 3.0);
	float neck = box(q - vec2(0.03, -0.03), vec2(0.17, 0.12));
	float foot = box(q - vec2(0.03, 0.15), vec2(0.32, 0.07));
	float shape = min(min(min(top, horn), neck), foot);
	float fade = 1.0 - smoothstep(0.5, 0.95, progress);
	vec3 color = q.y < -0.2 ? STEEL : mix(STEEL, DARK, 0.55);
	color = mix(RIM, color, step(shape, -0.02));
	float alpha = step(shape, 0.0) * fade;
	if (fall >= 1.0) {
		float hit = 1.0 - smoothstep(LAND, LAND + 0.3, progress);
		float d = length(p - vec2(0.03, 0.26));
		float a = atan(p.y - 0.26, p.x - 0.03);
		float jag = abs(fract(a / TAU * 8.0 + seed) - 0.5) * 2.0;
		float flash = (0.22 + 0.42 * jag) * hit - d;
		if (flash > 0.0 && shape > -0.02) {
			color = flash > 0.08 ? WHITE : HOT;
			alpha = 1.0;
		}
	}
	COLOR = vec4(color, alpha * COLOR.a);
}
