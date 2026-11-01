shader_type canvas_item;
render_mode blend_mix;

// L'IMPACT du Temps : un petit cadran s'ouvre, ses douze graduations marquent le coup, et
// son aiguille fait un tour avant de s'effacer. Rien de rond et de plein : c'est écrit.

uniform float seed = 0.0;
uniform float progress = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = 1.0 - pow(1.0 - clamp(progress / 0.35, 0.0, 1.0), 3.0);
	float reach = 0.8 * open;
	float ring = 0.018 - abs(d - reach);
	float turn = fract((a + PI) / TAU * 12.0 + 0.5);
	float mark = (0.024 - abs(turn - 0.5) * 0.52 * d) * step(reach - 0.16, d) * step(d, reach);
	float angle = progress * TAU * 1.2 + seed * TAU;
	vec2 hand_dir = vec2(cos(angle), sin(angle));
	float forward = dot(p, hand_dir);
	float hand = (0.022 - abs(dot(p, vec2(-hand_dir.y, hand_dir.x)))) * step(0.0, forward) * step(forward, reach * 0.9);
	float metal = max(ring, max(mark, hand));
	vec3 color = mix(vec3(0.14, 0.72, 0.64), vec3(0.9, 1.0, 0.94), smoothstep(0.0, 0.03, metal));
	color = mix(color, vec3(1.0, 0.68, 0.3), step(0.0, hand) * step(hand, 1.0));
	float fade = 1.0 - smoothstep(0.62, 1.0, progress);
	COLOR = vec4(color, smoothstep(0.0, 0.012, metal) * fade * COLOR.a);
}
