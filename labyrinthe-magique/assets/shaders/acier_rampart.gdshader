shader_type canvas_item;
render_mode blend_mix;

// LE REMPART : ses ailes se referment lame après lame en une couronne autour de lui. Les joints
// luisent en orange, et le centre reste ouvert : le mage doit rester visible dedans.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 STEEL = vec3(0.682, 0.725, 0.780);
const vec3 MID = vec3(0.333, 0.380, 0.439);
const vec3 HOT = vec3(1.0, 0.541, 0.165);
const vec3 RIM = vec3(0.086, 0.106, 0.133);
const float BLADES = 14.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.x, -p.y) + PI;
	float closed = smoothstep(0.0, 0.05, progress);
	float opened = smoothstep(0.94, 1.0, progress);
	float cell = TAU / BLADES;
	float index = floor(a / cell);
	float mid_turn = abs((index + 0.5) / BLADES - 0.5) * 2.0;
	float here = step(mid_turn, closed) * (1.0 - step(1.0 - opened, mid_turn));
	float local = (fract(a / cell) - 0.5) * 2.0;
	float tip = 0.9 - abs(local) * 0.16;
	float blade = min(tip - d, d - 0.5 - abs(local) * 0.06);
	vec3 color = mix(STEEL, MID, smoothstep(-0.4, 0.5, local));
	float joint = smoothstep(0.82, 0.9, abs(local));
	float pulse = 0.65 + 0.35 * sin(TIME * 7.0 + index);
	color = mix(color, HOT, joint * pulse);
	color = mix(RIM, color, step(0.014, blade));
	COLOR = vec4(color, step(0.0, blade) * here * COLOR.a);
}
