shader_type canvas_item;
render_mode blend_mix;

// LA MOISSON : un arc de lame qui balaie devant lui, de gauche à droite de son regard (l'axe +x
// du quad). Le tranchant extérieur est de braise, le corps noir s'effiloche en plumes à l'arrière,
// et l'arc se défait ensuite en lambeaux. Son bord tombe sur le rayon du sort.

uniform float seed = 0.0;
uniform float progress = 0.0;

const vec3 EMBER = vec3(1.0, 0.416, 0.169);
const vec3 RED = vec3(0.886, 0.22, 0.165);
const vec3 BLACK = vec3(0.078, 0.075, 0.11);
const vec3 BONE = vec3(0.902, 0.875, 0.792);
const float HALF_ARC = 1.31;
const float EDGE = 0.8;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float t = clamp((progress - 0.04) / 0.46, 0.0, 1.0);
	float head = mix(-HALF_ARC, HALF_ARC, t * t * (3.0 - 2.0 * t));
	float tail = 0.25 + 2.35 * t;
	float behind = head - a;
	float kept = clamp(1.0 - behind / tail, 0.0, 1.0) * step(0.0, behind);
	kept *= step(abs(a), HALF_ARC + 0.02);
	// L'arc s'épaissit vers le tranchant, et ses plumes s'effilochent au bord intérieur.
	float frayed = 0.05 * sin(a * 31.0 + seed * 7.0) * (1.0 - kept);
	float thick = 0.46 * pow(kept, 0.55);
	float blade = min(EDGE - d, d - (EDGE - thick) + frayed);
	blade = min(blade, kept * 0.3);
	vec3 color = BLACK;
	color = mix(color, RED, smoothstep(0.1, 0.05, EDGE - d));
	color = mix(color, EMBER, smoothstep(0.05, 0.018, EDGE - d));
	color = mix(BONE, color, smoothstep(0.0, 0.012, blade));
	float alpha = smoothstep(-0.003, 0.003, blade) * step(0.001, kept);
	// La fin : l'arc se défait par lambeaux qui s'allument avant de partir.
	float gone = smoothstep(0.5, 1.0, progress);
	float scrap = fract(sin(floor(a * 46.0) * 12.9898 + floor(d * 70.0) * 78.233 + seed) * 43758.5453);
	color = mix(color, EMBER, step(scrap, gone + 0.08) * step(0.001, gone));
	alpha *= step(gone, scrap);
	COLOR = vec4(color, alpha * COLOR.a);
}
