shader_type canvas_item;
render_mode blend_mix;

// LA TRANSFUSION reçue : un anneau de bulles qui remonte le long du mage, puis s'efface.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 CORE = vec3(0.949, 1.0, 0.62);
const vec3 VENOM = vec3(0.706, 0.941, 0.165);
const vec3 RIM = vec3(0.118, 0.227, 0.047);
const float BUBBLES = 11.0;

float hash(float x) {
	return fract(sin(x * 12.9898 + seed * 78.233) * 43758.5453);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float rise = 0.62 - progress * 1.35;
	// L'anneau est vu de biais : une ellipse qui monte.
	vec2 q = vec2(p.x, (p.y - rise) * 3.0);
	float a = atan(q.y, q.x);
	float turn = (a + PI) / TAU * BUBBLES;
	float slot = floor(turn);
	float at_turn = (slot + 0.5) / BUBBLES * TAU - PI;
	vec2 hub = vec2(cos(at_turn), sin(at_turn)) * 0.62;
	float size = 0.07 + 0.05 * hash(slot);
	float dist = length(vec2(q.x - hub.x, (q.y - hub.y) / 3.0));
	float heat = size - dist;
	float wire = 0.012 - abs(length(q) - 0.62);
	vec3 color = mix(VENOM, CORE, smoothstep(size * 0.3, size * 0.75, heat));
	color = mix(RIM, color, smoothstep(0.0, 0.012, heat));
	float alpha = smoothstep(-0.004, 0.0, heat);
	color = mix(color, VENOM, (1.0 - alpha) * step(0.0, wire));
	alpha = max(alpha, step(0.0, wire) * 0.6);
	float fade = smoothstep(0.0, 0.1, progress) * (1.0 - smoothstep(0.7, 1.0, progress));
	COLOR = vec4(color, alpha * fade * COLOR.a);
}
