shader_type canvas_item;
render_mode blend_mix;

// LE SANCTUAIRE : un cercle d'or gravé, tracé comme au compas, avec des plumes stylisées sur
// son pourtour qui tournent lentement, et un voile de lumière translucide. Il clignote à la
// fin, puis se referme depuis l'extérieur. Son bord tombe sur le rayon du sort.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float radius_tiles = 2.4;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;
uniform float aura = 0.0;

const vec3 SHINE = vec3(1.0, 0.945, 0.722);
const vec3 GOLD = vec3(1.0, 0.812, 0.353);
const vec3 DEEP = vec3(0.788, 0.541, 0.169);
const vec3 RIM = vec3(0.29, 0.184, 0.071);
const float EDGE = 0.8;
const float FEATHERS = 12.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	// Le compas : le cercle se trace en un tour.
	float draw_t = clamp(phase / 0.3, 0.0, 1.0);
	float swept = step(fract((a + PI) / TAU), draw_t);
	float close = smoothstep(0.1, 0.0, life);
	float reach = EDGE * (1.0 - close);
	float outer = 0.014 - abs(d - reach);
	float inner = 0.008 - abs(d - reach * 0.76);
	// Les plumes entre les deux anneaux : des losanges courbés qui tournent.
	float turn = (a + PI) / TAU * FEATHERS + phase * 0.5;
	float across = abs(fract(turn) - 0.5) * 2.0;
	float t = clamp((d - reach * 0.78) / (reach * 0.2), 0.0, 1.0);
	float feather = (0.62 * sin(t * PI) - across) * step(0.001, t) * step(t, 0.999);
	float metal = max(max(outer, inner), feather * 0.03) * swept;
	vec3 color = GOLD;
	float alpha = 0.16 * step(d, reach) * smoothstep(0.1, 0.3, phase);
	// Des filets de lumière montent du sol, sans bruit lissé : des traits nets.
	float rise = texture(noise, vec2(p.x * radius_tiles * 0.5 + seed, p.y * 0.25 + phase * 0.2)).r;
	float rays = smoothstep(0.66, 0.7, rise) * step(d, reach * 0.74);
	color = mix(color, SHINE, rays);
	alpha = max(alpha, rays * 0.2);
	color = mix(color, feather > 0.0 ? GOLD : DEEP, step(0.0001, metal));
	alpha = max(alpha, step(0.0001, metal) * 0.95);
	float rim = step(0.0001, 0.02 - abs(d - reach - 0.018)) * swept;
	color = mix(color, RIM, rim * (1.0 - step(0.0001, metal)));
	alpha = max(alpha, rim * 0.8);
	float dying = life < 0.2 ? 0.55 + 0.45 * step(0.5, fract(phase * 6.0)) : 1.0;
	COLOR = vec4(color, alpha * dying * COLOR.a);
}
