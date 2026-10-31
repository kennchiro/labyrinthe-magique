shader_type canvas_item;
render_mode blend_mix;

// L'EXPLOSION DE FEU, peinte à l'écran. Elle remplace le vortex rond de `impact.png`.
//
// Un éclair blanc au centre, un front de flammes qui s'ouvre et se déchire, et plus
// rien au bout de sa vie : elle se défait au lieu de s'estomper, ce qui la garde en
// aplats jusqu'au bout.

uniform sampler2D noise : repeat_enable, filter_linear;
uniform vec4 core_color : source_color = vec4(1.0, 0.98, 0.78, 1.0);
uniform vec4 hot_color : source_color = vec4(1.0, 0.78, 0.12, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.32, 0.04, 1.0);
uniform vec4 edge_color : source_color = vec4(0.55, 0.04, 0.02, 1.0);
uniform float seed = 0.0;
// Avancement, de 0 à 1.
uniform float progress = 0.0;
// 1 : une gerbe pleine et brève, sans anneau, pour le coup de tous les jours.
uniform float solid = 0.0;
// Des rayons qui jaillissent : réservés à l'ultime, qu'aucun autre sort ne doit imiter.
uniform float rays = 0.0;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float d = length(p);
	// Vite au début, lent à la fin : c'est ce qui donne le coup à une explosion.
	float front = (1.0 - pow(1.0 - progress, 3.0)) * 0.78;
	// Un grain fin devant la taille de l'explosion : à grosses taches, le bruit en
	// mange tout un côté, et l'anneau s'ouvre en « C ».
	vec2 at = p * 0.95 + seed;
	float tongue = texture(noise, at + vec2(0.0, -progress * 0.25)).r - 0.5;
	float tatter = texture(noise, at * 2.1 - seed).r - 0.5;

	// Ce qui est encore derrière le front brûle ; le centre se vide en fin de vie.
	float heat = (front - d) / 0.3 + tongue * 0.8;
	float hollow = (d - progress * progress * 0.85) / 0.22 + tatter * 0.7;
	heat = min(heat, mix(hollow, 10.0, solid));
	heat += rays * pow(abs(cos(atan(p.y, p.x) * 7.0 + seed)), 10.0) * (1.0 - progress) * smoothstep(0.08, 0.3, d);
	// Il se déchire et finit en lambeaux.
	heat -= progress * progress * 0.65;

	vec3 color = edge_color.rgb;
	color = mix(color, flame_color.rgb, smoothstep(0.06, 0.18, heat));
	color = mix(color, hot_color.rgb, smoothstep(0.32, 0.46, heat));
	color = mix(color, core_color.rgb, smoothstep(0.62, 0.76, heat));
	// L'éclair du premier instant.
	float flash = (1.0 - smoothstep(0.0, 0.2, progress)) * smoothstep(0.3, 0.24, d);
	color = mix(color, core_color.rgb, flash);

	COLOR = vec4(color, max(smoothstep(0.0, 0.08, heat), flash) * COLOR.a);
}
