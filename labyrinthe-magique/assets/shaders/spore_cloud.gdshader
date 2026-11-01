shader_type canvas_item;

// Le nuage de la Vesse-de-Loup, sur une case. Des bouffées qui roulent lentement, et de
// grosses spores qui flottent dedans, comme sur sa planche.

uniform float fade = 1.0;
uniform float seed = 0.0;
uniform vec3 mist = vec3(0.66, 0.78, 0.18);
uniform vec3 spore = vec3(0.92, 1.0, 0.42);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 at = UV - 0.5;
	float rim = smoothstep(0.5, 0.22, length(at));
	vec2 drift = vec2(TIME * 0.09, -TIME * 0.06) + seed;
	float puff = noise(at * 5.0 + drift) * 0.65 + noise(at * 11.0 - drift * 1.7) * 0.35;
	float body = smoothstep(0.34, 0.68, puff) * rim;
	vec2 grid_at = (at + vec2(seed, -TIME * 0.05)) * 7.0;
	vec2 cell_id = floor(grid_at);
	vec2 centre = vec2(hash(cell_id), hash(cell_id + 7.0)) * 0.6 + 0.2;
	float dot_at = smoothstep(0.17, 0.09, length(fract(grid_at) - centre));
	dot_at *= step(0.62, hash(cell_id + 3.0)) * rim;
	COLOR.rgb = mix(mist, spore, dot_at);
	COLOR.a = clamp(body * 0.62 + dot_at * 0.9, 0.0, 1.0) * fade;
}
