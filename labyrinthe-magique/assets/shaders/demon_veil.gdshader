shader_type canvas_item;
render_mode blend_mix;

// LE RÉPIT DU PACTE : tant qu'il est intouchable, un sceau d'or à quatre pointes tourne autour de
// lui, gradué, avec un filet intérieur en sens inverse et des gouttes en orbite. Le centre reste
// vide : on doit le voir, à 1 PV. Le sceau clignote juste avant de céder.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 PALE = vec3(1.0, 0.914, 0.659);
const vec3 GOLD = vec3(0.847, 0.663, 0.227);
const vec3 CRIMSON = vec3(0.784, 0.078, 0.235);
const vec3 DEEP = vec3(0.42, 0.039, 0.122);
const vec3 BLACK = vec3(0.078, 0.039, 0.055);
const float ORBIT = 6.0;
const float TICKS = 36.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float base = atan(p.y, p.x);
	float a = base + TIME * 1.3 + seed;
	float spike = pow(abs(cos(a * 2.0)), 18.0) * 0.16;
	float ring = 0.022 + spike * 0.5 - abs(d - 0.66 - spike * 0.5);
	float ticks = min(0.02 - abs(d - 0.74), abs(fract(a * TICKS / TAU) - 0.5) * 0.14 - 0.022);
	float back = base - TIME * 0.9 + seed;
	float gaps = abs(fract(back * 3.82) - 0.5) - 0.15;
	float inner = min(0.012 - abs(d - 0.52), gaps);
	float line = max(max(ring, ticks), inner);
	vec3 color = mix(CRIMSON, GOLD, smoothstep(0.0, 0.012, line));
	color = mix(color, PALE, smoothstep(0.02, 0.04, line));
	color = mix(BLACK, color, smoothstep(-0.008, 0.0, line));
	float alpha = smoothstep(-0.012, -0.004, line);
	for (int i = 0; i < int(ORBIT); i++) {
		float f = float(i);
		float angle = f / ORBIT * TAU - TIME * 2.1;
		vec2 at = vec2(cos(angle), sin(angle)) * 0.6;
		vec2 tangent = vec2(-sin(angle), cos(angle));
		vec2 q = p - at;
		vec2 r = vec2(dot(q, tangent), dot(q, at / 0.6));
		float drop = 0.045 - length(vec2(r.x * 0.55, r.y));
		if (drop > 0.0) {
			color = mix(CRIMSON, PALE, smoothstep(0.022, 0.04, drop));
			alpha = 1.0;
		}
	}
	float blink = progress > 0.8 ? step(0.5, fract(progress * 22.0)) : 1.0;
	float grow = smoothstep(0.0, 0.03, progress);
	COLOR = vec4(color, alpha * blink * grow * COLOR.a);
}
