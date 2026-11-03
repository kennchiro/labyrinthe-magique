shader_type canvas_item;
render_mode blend_mix;

// LE GLAIVE TOURNOYANT : son épée de flamme tourne vite autour de lui, et traîne derrière elle un
// arc de feu saphir à moitié ouvert, comme une roue. Elle ralentit et rentre à la fin.

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
uniform float seconds = 4.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.y *= 1.35;
	float d = length(p);
	float t = progress;
	float live = smoothstep(0.0, 0.06, t) * (1.0 - smoothstep(0.92, 1.0, t));
	float spin = t * seconds * 6.2832 * 1.8 * (1.0 - 0.3 * t);
	float angle = atan(p.y, p.x);
	vec3 color = SAPPHIRE;
	float a = 0.0;
	// L'arc de feu, derrière l'épée : il couvre la moitié du tour, épais près d'elle, et ses
	// langues partent vers l'extérieur.
	float behind = mod(spin - angle, 6.2832);
	float trail = 1.0 - behind / 3.1416;
	float tongue = 0.1 * trail * (0.6 + 0.4 * abs(sin(angle * 11.0 + t * 25.0)));
	float out_ = d - 0.66;
	float wall = (out_ > -0.06 * trail && out_ < tongue) ? min(out_ + 0.06 * trail, tongue - out_) : -1.0;
	if (behind < 3.1416 && wall > -0.025 && live > 0.0 && trail > 0.05) {
		float k = (out_ + 0.06) / (tongue + 0.06);
		color = wall <= 0.0 ? RIM : (k < 0.4 ? PALE : (trail > 0.45 ? SAPPHIRE : DEEP));
		a = 1.0;
	}
	// L'épée : une lame de flamme couchée sur le rayon, poignée de bronze vers le centre.
	vec2 dir = vec2(cos(spin), sin(spin));
	float along = dot(p, dir);
	float across = abs(dot(p, vec2(-dir.y, dir.x)));
	float blade = (along > 0.3 && along < 1.0) ? 0.14 * (1.0 - (along - 0.3) / 0.7) + 0.025
		+ 0.025 * sin(along * 30.0 - t * 60.0) - across : -1.0;
	float hilt = (along > 0.12 && along < 0.3) ? (along > 0.25 ? 0.19 : 0.05) - across : -1.0;
	if (blade > -0.025 && live > 0.0) {
		color = blade <= 0.0 ? RIM : (blade > 0.07 ? PALE : (blade > 0.03 ? SAPPHIRE : DEEP));
		a = 1.0;
	}
	if (hilt > -0.025 && live > 0.0) {
		color = hilt <= 0.0 ? RIM : BRONZE;
		a = 1.0;
	}
	COLOR = vec4(color, a);
}
