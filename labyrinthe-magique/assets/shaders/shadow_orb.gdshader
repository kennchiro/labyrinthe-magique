shader_type canvas_item;
render_mode blend_mix;

// L'ORBE D'OMBRE : une bille de nuit qui aspire la lumière. Pas de flamme ici : un
// cœur presque noir, de la fumée qui tourne autour, un mince croissant de lumière.
// Elle garde une forme ronde et lente, là où le trait du Feu file et se déchire.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform float seed = 0.0;
uniform vec2 head = vec2(0.66, 0.5);
uniform float radius = 0.27;
uniform float aspect = 1.3;

void fragment() {
	vec2 p = (UV - head) * vec2(aspect, 1.0);
	float d = length(p);
	float turn = TIME * 2.4 + seed * 6.0;
	vec2 spun = mat2(vec2(cos(turn), sin(turn)), vec2(-sin(turn), cos(turn))) * p;
	float smoke = texture(noise, spun * 0.5 + seed).r - 0.5;
	// Des volutes derrière, qui s'effilochent sans jamais former de langues.
	float behind = clamp(-p.x / (head.x * aspect), 0.0, 1.0);
	float wisp = texture(noise, vec2(p.x * 0.3 + TIME * 0.5 + seed, p.y * 0.5)).r - 0.5;
	float tail = (radius * (1.0 - behind) * 0.8 - abs(p.y + wisp * behind * 0.3)) / 0.1;
	tail = p.x < 0.0 ? tail + wisp * 1.6 - behind * 1.2 : -1.0;
	float body = (radius * 1.12 - d) / 0.06 + smoke * 2.4;

	vec3 night = vec3(0.035, 0.012, 0.075);
	vec3 smoke_color = mix(vec3(0.2, 0.06, 0.38), vec3(0.42, 0.14, 0.72), smoothstep(-0.1, 0.25, smoke));
	vec3 color = mix(smoke_color, night, smoothstep(radius * 0.92, radius * 0.68, d));
	float crescent = smoothstep(0.035, 0.0, abs(d - radius * 0.86)) * smoothstep(0.0, 0.14, spun.x);
	color = mix(color, vec3(0.93, 0.8, 1.0), crescent);
	float alpha = max(smoothstep(0.0, 0.4, body), smoothstep(0.0, 0.5, tail) * 0.72);
	COLOR = vec4(color, alpha * COLOR.a);
}
