shader_type canvas_item;
render_mode blend_mix;

// LA TRAÎNÉE DE L'ÉCLAIR : trois langues de flamme saphir posées au sol, qui dansent et
// rapetissent jusqu'à disparaître.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.933, 0.953, 1.0);
const vec3 SAPPHIRE = vec3(0.239, 0.42, 1.0);
const vec3 DEEP = vec3(0.102, 0.184, 0.62);
const vec3 BRONZE = vec3(0.878, 0.627, 0.29);
const vec3 RIM = vec3(0.078, 0.102, 0.18);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = SAPPHIRE;
	float a = 0.0;
	float size = smoothstep(0.0, 0.12, t) * (1.0 - smoothstep(0.4, 1.0, t));
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float x0 = (f - 1.0) * 0.38 + (hash(f) - 0.5) * 0.15;
		float h = (0.75 + hash(f + 4.0) * 0.4) * size;
		float y = 0.55 - p.y;           // hauteur au-dessus du pied
		float k = clamp(y / max(h, 0.001), 0.0, 1.0);
		float sway = sin(t * 20.0 + f * 2.0 + y * 6.0) * 0.06 * k;
		float hw = 0.2 * size * (1.0 - k * k) * (0.6 + 0.4 * (1.0 - k));
		float inside = hw - abs(p.x - x0 - sway);
		if (y > 0.0 && y < h && inside > -0.03) {
			color = inside <= 0.0 ? RIM : (inside > hw * 0.5 ? PALE : (k > 0.6 ? DEEP : SAPPHIRE));
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
