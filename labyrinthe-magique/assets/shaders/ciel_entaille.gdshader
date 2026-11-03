shader_type canvas_item;
render_mode blend_mix;

// UNE PLUME TOUCHE : une entaille nette en travers, et la plume se brise en trois éclats d'or
// qui partent en s'écartant.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(0.957, 1.0, 0.973);
const vec3 EMERALD = vec3(0.204, 0.878, 0.478);
const vec3 GOLD = vec3(0.949, 0.757, 0.306);
const vec3 RIM = vec3(0.063, 0.149, 0.11);

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float t = progress;
	vec3 color = PALE;
	float a = 0.0;
	float slant = 0.6 + seed;
	vec2 dir = vec2(cos(slant), sin(slant));
	float along = dot(p, dir);
	float across = abs(dot(p, vec2(-dir.y, dir.x)));
	float reach = 0.85 * smoothstep(0.0, 0.25, t);
	float thin = 0.09 * (1.0 - smoothstep(0.25, 0.85, t)) * (1.0 - abs(along) / max(reach, 0.001));
	float cut = thin - across;
	if (abs(along) < reach && cut > -0.03 && thin > 0.0) {
		color = cut > thin * 0.45 ? PALE : (cut > 0.0 ? EMERALD : RIM);
		a = 1.0;
	}
	for (int i = 0; i < 3; i++) {
		float f = float(i);
		float at = slant + 1.5708 + (f - 1.0) * 0.9 + hash(f) * 0.3;
		vec2 c = vec2(cos(at), sin(at)) * (0.1 + smoothstep(0.1, 1.0, t) * 0.65);
		vec2 q = p - c;
		float size = 0.11 * (1.0 - smoothstep(0.5, 1.0, t));
		float shard = size - (abs(q.x) + abs(q.y) * 1.6);
		if (shard > -0.03 && t > 0.1 && size > 0.0) {
			color = shard > 0.0 ? GOLD : RIM;
			a = 1.0;
		}
	}
	COLOR = vec4(color, a);
}
