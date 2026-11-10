shader_type canvas_item;
render_mode blend_mix;

// LA FLAQUE DU SILLAGE PESTILENT : plus large et plus lourde que la flaque ordinaire, son cœur sombre bouillonne
// à gros bouillons, son bord clair est cerné, et des fils gluants la relient au sol. Elle se rétracte à la fin.

#include "res://assets/shaders/fleau.gdshaderinc"

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform float progress = 0.0;
uniform float solid = 0.0;
uniform float rays = 0.0;

float hash2(vec2 c) {
	return fract(sin(dot(c, vec2(12.9898, 78.233)) + seed * 37.7) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float ang = atan(p.y, p.x);
	float s = seed * 37.0;
	float wobble = 0.5 + 0.28 * sin(ang * 3.0 + s) + 0.16 * sin(ang * 5.0 + s * 1.7) + 0.08 * sin(ang * 9.0 + s * 2.3);
	float open = 1.0 - pow(1.0 - clamp(progress / 0.06, 0.0, 1.0), 3.0);
	float shrink = 1.0 - smoothstep(0.75, 1.0, progress) * 0.85;
	float reach = (0.36 + 0.24 * wobble) * open * shrink;
	float body = reach - d;
	vec3 color = mix(F_SHADE, vec3(0.16, 0.3, 0.04), smoothstep(0.3, 0.6, texture(noise, p * 0.6 + seed).g));
	color = mix(color, F_VENOM, smoothstep(0.08, 0.03, body));
	float a = step(0.0, body);
	if (body > -0.025 && body <= 0.0) {
		color = F_RIM;
		a = 1.0;
	}
	// Les gros bouillons : chacun gonfle en dôme clair, puis crève en anneau.
	vec2 at = p * 2.6;
	vec2 cell = floor(at);
	float life = fract(TIME * (0.6 + 0.6 * hash2(cell)) + hash2(cell + 3.0));
	vec2 centre = vec2(hash2(cell + 7.0), hash2(cell + 11.0)) * 0.5 + 0.25;
	float dist = length(fract(at) - centre);
	float size = 0.28 * life;
	if (body > 0.05 && step(0.45, hash2(cell + 19.0)) > 0.0) {
		if (life < 0.8 && dist < size) {
			color = mix(F_BRIGHT, F_CORE, smoothstep(size, 0.0, dist) * 0.6);
		} else if (life >= 0.8 && abs(dist - size) < 0.04) {
			color = F_CORE;
		}
	}
	COLOR = vec4(color, a * 0.92);
}
