shader_type canvas_item;
render_mode blend_mix;

// LE GLAIVE TOUCHE : une entaille de flamme courbe, saphir à cœur pâle, qui se referme vite.

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
	float start = seed * 6.2832;
	float d = length(p - vec2(0.0, 0.5));
	float angle = atan(p.y - 0.5, p.x);
	float arc = mod(angle - start, 6.2832);
	float sweep = 2.2 * smoothstep(0.0, 0.3, t);
	float width = 0.11 * (1.0 - smoothstep(0.3, 1.0, t)) * sin(clamp(arc / max(sweep, 0.001), 0.0, 1.0) * 3.1416);
	float cut = width - abs(d - 0.75);
	vec3 color = SAPPHIRE;
	float a = 0.0;
	if (arc < sweep && cut > -0.025 && width > 0.0) {
		color = cut <= 0.0 ? RIM : (cut > width * 0.5 ? PALE : SAPPHIRE);
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
