shader_type canvas_item;
render_mode blend_mix;

// LA BULLE DE LENTEUR : une sphère translucide où une spirale de sable tourne au ralenti,
// avec des grains suspendus. Son bord tombe sur le rayon du sort. Elle clignote à la fin,
// pour dire qu'elle va céder.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.6;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const float OPEN_TIME = 0.3;
const float EDGE = 0.8;

float hash(vec2 cell) {
	return fract(sin(dot(cell, vec2(12.9898, 78.233)) + seed * 37.7) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float grow = 1.0 - pow(1.0 - clamp(phase / OPEN_TIME, 0.0, 1.0), 3.0);
	float reach = EDGE * grow;
	float body = reach - d;

	float arm = fract((a + d * 5.0 - phase * 0.35 + seed) / TAU * 3.0);
	float spiral = smoothstep(0.2, 0.0, abs(arm - 0.5)) * smoothstep(0.02, 0.2, d);
	float dust = texture(noise, p * radius_tiles * 0.3 + seed).r;
	spiral *= smoothstep(0.34, 0.5, dust);

	// Les grains suspendus : ils bougent à peine, c'est le temps qui est lent.
	vec2 at = p * radius_tiles * 2.4 + vec2(seed, phase * 0.04);
	vec2 cell = floor(at);
	vec2 centre = vec2(hash(cell), hash(cell + 7.0)) * 0.6 + 0.2;
	float grain = step(0.86, hash(cell + 13.0)) * smoothstep(0.17, 0.11, length(fract(at) - centre));

	vec3 color = vec3(0.1, 0.62, 0.58);
	float alpha = 0.2;
	color = mix(color, vec3(0.45, 0.95, 0.85), spiral);
	alpha = mix(alpha, 0.5, spiral);
	color = mix(color, vec3(0.86, 1.0, 0.94), grain);
	alpha = max(alpha, grain * 0.9);
	// Le reflet en haut à gauche, puis le filet clair et le cerne qui tient sur sol clair.
	float shine = smoothstep(0.17, 0.06, length(p - vec2(-0.32, -0.36)));
	color = mix(color, vec3(0.92, 1.0, 0.98), shine * 0.8);
	alpha = max(alpha, shine * 0.55);
	float rim = smoothstep(0.075, 0.02, body);
	color = mix(color, vec3(0.62, 1.0, 0.92), rim);
	alpha = max(alpha, rim * 0.92);
	color = mix(color, vec3(0.03, 0.27, 0.27), smoothstep(0.018, 0.008, body));

	float dying = life < 0.16 ? 0.55 + 0.45 * step(0.5, fract(phase * 7.0)) : 1.0;
	COLOR = vec4(color, smoothstep(0.0, 0.008, body) * alpha * dying * COLOR.a);
}
