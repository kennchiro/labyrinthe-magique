shader_type canvas_item;
render_mode blend_mix;

// LE CERCLE D'INVOCATION : gravé au sol, tout au compas, sans bruit.
//
// Du bord au centre : un anneau à pleins et déliés, une couronne de marques, deux triangles
// aux traits effilés qui tournent en sens contraire, et trois lames au cœur. Ce sont les
// PLEINS qui le font exister : des traits fins de même épaisseur ne faisaient qu'un dessin
// au fil de fer, perdu sur les sols clairs. Un disque sombre et un cerne le tiennent partout.
//
// Le bord du dessin tombe sur le rayon du sort. Il se trace en tournant à l'ouverture.

uniform float radius_tiles = 2.0;
uniform float seed = 0.0;
uniform float phase = 0.0;
uniform float life = 1.0;

const float OPEN_TIME = 0.5;

// Un côté de triangle : plein au milieu, en pointe à ses deux sommets. Positif dedans.
float blade_triangle(vec2 p, float turn, float reach) {
	float angle = atan(p.y, p.x) + turn;
	float sector = mod(angle, TAU / 3.0) - TAU / 6.0;
	float r = length(p);
	float along = r * sin(sector) / (reach * 1.732);
	float side = r * cos(sector) - reach;
	return 0.034 * (1.0 - pow(min(abs(along) * 2.0, 1.0), 2.0)) + 0.003 - abs(side);
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	float a = atan(p.y, p.x);
	float open = smoothstep(0.0, OPEN_TIME, phase);
	float slow = phase * 0.3 + seed;

	// L'anneau : ses trois pleins tournent, et il s'affine jusqu'au délié entre eux.
	float swell = 0.5 + 0.5 * cos(a * 3.0 + slow * 1.4);
	float outer = 0.012 + 0.04 * swell * swell - abs(d - 0.89);
	float thin = 0.007 - abs(d - 0.75);

	// La couronne de marques, entre les deux anneaux, à contresens.
	float marks = 24.0;
	float mark_angle = fract((a - slow * 0.8) / TAU * marks) - 0.5;
	float long_mark = step(0.5, fract(floor((a - slow * 0.8) / TAU * marks) / 3.0));
	float mark = min(0.1 - abs(mark_angle), 0.024 + 0.018 * long_mark - abs(d - 0.81));

	float star = max(blade_triangle(p, slow, 0.36), blade_triangle(p, -slow + PI, 0.36));
	star = d < 0.73 ? star : -1.0;

	// Le cœur : trois lames fermées, comme un sceau, autour d'un point.
	float heart_turn = (a + slow * 1.8) / TAU * 3.0;
	float across = (fract(heart_turn) - 0.5) / 3.0 * TAU;
	float k = clamp((d - 0.06) / 0.27, 0.0, 1.0);
	float blade = d < 0.33 ? (0.56 * pow(k, 0.5) * (1.0 - k) - abs(across + k * 0.45)) * min(d, 0.3) : -1.0;
	float dot_core = 0.05 - d;
	float heart = max(blade, dot_core);

	float lines = max(max(outer, thin), max(mark, max(star, heart)));
	float beat = 0.86 + 0.14 * sin(phase * 3.0);

	vec3 color = vec3(0.16, 0.03, 0.3);
	float alpha = smoothstep(0.91, 0.9, d) * 0.42;
	// Une couronne plus claire sous les marques : le disque n'est pas un aplat.
	float band = smoothstep(0.74, 0.75, d) * smoothstep(0.89, 0.88, d);
	color = mix(color, vec3(0.36, 0.1, 0.6), band);
	alpha = max(alpha, band * 0.52);
	// Le cerne foncé, puis le corps violet, puis le cœur du trait.
	float rim = smoothstep(-0.018, -0.01, lines);
	color = mix(color, vec3(0.1, 0.02, 0.22), rim);
	alpha = max(alpha, rim * 0.9);
	float body = smoothstep(-0.006, 0.0, lines);
	color = mix(color, vec3(0.74, 0.34, 1.0), body);
	alpha = max(alpha, body);
	color = mix(color, vec3(1.0, 0.86, 1.0) * beat, smoothstep(0.005, 0.012, lines));

	// Il se trace en tournant, puis il s'éteint avec la zone.
	float reveal = smoothstep(open * 6.6 - 0.2, open * 6.6 - 0.5, a + PI);
	alpha *= max(reveal, step(1.0, open));
	COLOR = vec4(color, alpha * smoothstep(0.0, 0.1, life) * COLOR.a);
}
