shader_type canvas_item;
render_mode blend_mix;

// LA FLÈCHE DE LA BOUSSOLE : une pointe taillée, dessinée vers +x.
//
// Elle est cernée de sombre et sa moitié haute est plus claire, ce qui la détache d'un
// mur clair comme d'un sol sombre. Elle garde la couleur de la gemme visée. Le reflet
// qui court de la queue à la pointe dit le sens, même d'un coup d'œil.

uniform vec4 tint : source_color = vec4(1.0);
uniform vec4 outline_color : source_color = vec4(0.04, 0.05, 0.1, 1.0);

const vec2 TIP = vec2(0.92, 0.0);
const vec2 WING = vec2(-0.78, 0.74);
const vec2 NOTCH = vec2(-0.3, 0.0);
const float OUTLINE = 0.15;

// Distance signée à la droite a->b, positive à gauche du sens de lecture vu de dessus.
float edge(vec2 p, vec2 a, vec2 b) {
	vec2 along = normalize(b - a);
	return dot(p - a, vec2(along.y, -along.x));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	vec2 q = vec2(p.x, abs(p.y));
	float d = max(edge(q, TIP, WING), -edge(q, NOTCH, WING));
	float soft = fwidth(p.x) * 1.2;

	vec3 fill = tint.rgb;
	vec3 light = mix(tint.rgb, vec3(1.0), 0.45);
	vec3 color = mix(light, fill * 0.82, smoothstep(-soft, soft, p.y));
	float glint = smoothstep(0.22, 0.0, abs(p.x - (fract(TIME * 0.7) * 2.6 - 1.2)));
	color = mix(color, vec3(1.0), glint * 0.75);
	color = mix(color, outline_color.rgb, smoothstep(-OUTLINE - soft, -OUTLINE + soft, d));
	COLOR = vec4(color, 1.0 - smoothstep(-soft, soft, d));
}
