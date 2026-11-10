class_name CombatSystem
extends RefCounted

## Exécute les compétences : visée, temps de vol, dégâts, zones, murs, soins.
##
## Il remplace SpellSystem, dont il garde ce qui avait été mesuré et prouvé —
## la visée sur l'ennemi le plus proche EN DISTANCE DE CHEMIN, le trajet de
## l'orbe le long des couloirs, et l'impact différé par le temps de vol.
## Ce qui change : un coup au but ne « bannit » plus l'ennemi dix secondes, il
## lui retire des points de vie. Le bannissement n'avait plus de sens dès lors
## qu'on compte les ennemis éliminés.
##
## Aucune dépendance au moteur de scène : le Level écoute ses signaux pour
## fabriquer les orbes et les explosions, la simulation d'équilibrage les ignore.

signal projectile_launched(ability: Ability, target: int, path: Array, duration: float)
signal projectile_hit(ability: Ability, target: int, cell: Vector2i)
## L'ARÈNE seulement (`CombatContext.dodge_rule`) : la cible a quitté la ligne du tir, il se perd là où
## elle était. En campagne, aucune règle n'est posée et l'attaque ne rate jamais.
signal projectile_dodged(ability: Ability, target: int, cell: Vector2i)
signal blast_fired(ability: Ability, cell: Vector2i)
## Un front DÉFERLE : le chemin qu'il va parcourir et le temps qu'il y mettra.
## Émis au lancement pour que le jeu puisse l'animer d'un bout à l'autre.
signal wave_launched(ability: Ability, path: Array, duration: float)
## La gerbe de pierre PART : le chemin entier et le temps qu'elle met à le
## parcourir. Le Level anime la course ; les dégâts, eux, sont appliqués case
## par case ici.
signal line_erupted(ability: Ability, path: Array, duration: float)
## Un cristal est PLANTÉ, il tire, puis il s'éteint.
signal turret_planted(id: int, ability: Ability, cell: Vector2i)
signal turret_fired(id: int, ability: Ability, cell: Vector2i, index: int)
signal turret_faded(id: int)
## LE SÉISME. Le sol tremble pendant `duration`, puis des pans de mur cèdent :
## chaque éboulement est un coup à part entière, à l'endroit où il tombe.
signal quake_started(duration: float, ability: Ability)
signal quake_slide(cell: Vector2i, ability: Ability)
## Une colonne d'eau jaillit sur cette case. Toutes partent au même instant :
## c'est une SALVE, pas une pluie — la pluie, c'est l'autre moitié du sort.
signal geyser_erupted(cell: Vector2i, ability: Ability)
## La zone qui AVANCE a changé de case. Le rendu la suit ; les dégâts, eux,
## sont appliqués ici comme pour n'importe quelle zone.
signal zone_moved(id: int, cell: Vector2i)
signal zone_created(zone_id: int, ability: Ability, cell: Vector2i)
## L'INCANTATION des Quatre Sceaux, émise UNE fois par lancement.
##
## `zone_created` part quatre fois — une par sceau — et la charge ne doit se
## jouer qu'une. C'est donc un signal à part plutôt qu'un compteur côté
## affichage : le Level n'a pas à deviner que quatre zones nées dans la même
## frame sont un seul sort.
signal seals_cast(cell: Vector2i)
signal zone_expired(zone_id: int)
signal wall_raised(cell: Vector2i)
signal wall_fell(cell: Vector2i)
signal blink_performed(from: Vector2i, to: Vector2i)
signal summon_spawned(id: int, kind_id: String, position: Vector2)
signal summon_moved(id: int, position: Vector2, facing: Vector2i)
signal summon_struck(id: int, target_index: int)
signal summon_projectile_launched(id: int, target_index: int, from: Vector2,
	to: Vector2, duration: float, ability: Ability)
signal summon_projectile_hit(id: int, target_index: int, cell: Vector2i, ability: Ability)
signal summon_expired(id: int)
## Un ennemi a frappé une créature invoquée, et ce qu'il lui reste à encaisser.
signal summon_hurt(id: int, hits_left: int, hits_max: int)
## Elle est tombée sous les coups, avant la fin de sa vie.
signal summon_slain(id: int)
signal enemy_damaged(index: int, dealt: int, ability: Ability)
signal enemy_killed(index: int)
signal hero_transformation_requested
signal comet_performed(from: Vector2i, to: Vector2i)
signal player_healed(amount: int)
## Le bouclier est posé, avec sa durée. Il en avait une dans sa fiche (8 s) et
## le code l'IGNORAIT : une fois posé, il tenait jusqu'à ce qu'on le consomme,
## éventuellement une partie entière.
signal player_shielded(amount: int, duration: float)
## Il est tombé — épuisé par les coups, ou arrivé à échéance.
signal player_shield_faded
## Le mage devient INTOUCHABLE pour la durée annoncée.
signal player_made_immune(duration: float)
signal player_immunity_faded
## Émis quand le geste est refusé, avec la raison : l'interface le dit au joueur
## au lieu de laisser croire à un bug.
signal use_refused(reason: String)
## Traits élémentaires — voir le bloc TRAITS plus bas. Les quatre premiers
## informent le Level (visuels) ET la simulation (physique) ; les deux derniers
## ne servent qu'aux visuels, la physique étant déjà appliquée ici même.
## Le facteur accompagne la durée : la trempe de l'élément Eau et le givre du
## Cercle glacé ralentissent tous deux, mais pas d'autant. Un signal qui ne
## porterait que la durée obligerait chaque récepteur à deviner de quel
## ralentissement il s'agit.
signal enemy_soaked(index: int, duration: float, factor: float)
signal enemy_staggered(index: int, duration: float)
signal enemy_pushed(index: int, cell: Vector2i)
## PROJETÉE CONTRE UNE PAROI : sa course a été bloquée avant la fin. L'interface
## s'en sert pour le flash sec du choc — c'est lui qui apprend au joueur, en une
## partie, que la pierre fait mal.
signal enemy_slammed(index: int, cell: Vector2i)
## RAMENÉE vers le mage, et non écartée. Signal distinct de `enemy_pushed` alors
## que les deux ne font que déplacer une créature : ce ne sont pas les mêmes
## événements pour le joueur, donc pas le même effet à l'écran — un souffle
## éclate à l'arrivée, une aspiration laisse une traînée derrière elle.
signal enemy_hauled(index: int, cell: Vector2i)
signal enemy_burning(index: int, duration: float)
## EMPOISONNÉE. Le signal porte la durée, comme la brûlure : c'est au Level de
## décider combien de temps la créature doit être vue verdir.
signal enemy_poisoned(index: int, duration: float)
## UNE FAILLE S'OUVRE sur cette case. Le signal ne porte pas les créatures qui
## en sortent : elles arrivent par `summon_spawned` comme toutes les autres, et
## le Level n'a pas à savoir laquelle vient de quelle porte.
signal rift_opened(cell: Vector2i)
## Un arc SAUTE d'une créature à l'autre. `from_index` vaut -1 pour le premier
## trait, qui part du mage lui-même.
signal chain_arced(from_index: int, to_index: int)
## L'orage se lève au-dessus du mage, et il le suit.
signal storm_gathered(ability: Ability, duration: float)
signal storm_dispersed
## Une décharge tombe du nuage sur une créature.
signal storm_struck(index: int, ability: Ability)
## Un nuage du JUGEMENT se forme quelque part sur la carte, puis se dissipe.
signal sky_cloud_formed(cell: Vector2i, duration: float, ability: Ability)
signal sky_cloud_faded(cell: Vector2i)
## Il foudroie une créature sous lui.
signal sky_bolt(cell: Vector2i, index: int, ability: Ability)
## Une météore est en route : la case visée et le temps qu'elle met à tomber.
## Émis À L'AVANCE pour que le jeu puisse montrer la chute et marquer le sol —
## un rocher qui apparaît au sol sans prévenir n'est pas un événement, c'est un
## dégât inexpliqué.
signal meteor_incoming(cell: Vector2i, delay: float, ability: Ability)
## L'INCANTATION d'une pluie, émise UNE fois par lancement — même raison que
## `seals_cast` : `meteor_incoming` part douze fois, le geste ne se fait qu'une.
signal incantation_cast(cell: Vector2i, ability: Ability)
signal meteor_landed(cell: Vector2i, ability: Ability)
## La météore qui vient d'être annoncée (`meteor_incoming`) suit la créature `index` jusqu'au sol : une pluie qui
## vise ne tombe pas là où la proie était.
signal meteor_aimed(index: int)
## Le mage est EXALTÉ : ses coups portent plus fort pendant `duration`.
## L'interface doit le montrer — un bonus invisible n'est pas un pouvoir, c'est
## une bizarrerie de chiffres.
signal player_empowered(bonus: int, duration: float)
signal player_calmed
## Le double de l'Écho part : les cases de son trajet et l'instant de chacune.
signal echo_walked(ability: Ability, cells: Array, times: Array)
signal hourglass_turned(duration: float)
signal hourglass_ended(healed: int)
signal time_stopped(duration: float)
## LE SEIGNEUR DES HEURES (l'Éveil du Chronomancien).
## Temps accéléré : ses recharges filent plus vite, tant que dure l'Éveil.
signal haste_changed(active: bool)
## Le Dôme de stase vient de figer une créature qui y entrait.
signal stasis_caught(index: int, seconds: float)
## Un double du Paradoxe explose en onde d'horloge au bout de son trajet.
signal echo_burst(cell: Vector2i, radius: float)
## Le Rembobinage : les PV rendus (zéro si rien à reprendre).
signal wounds_rewound(healed: int)
## La bombe-horloge du Saut temporel : posée, puis sonnée.
signal clock_bomb_set(bomb_id: int, cell: Vector2i, delay: float)
signal clock_bomb_rang(bomb_id: int, cell: Vector2i, radius: float)
## Le Jugement des Heures : un coup s'ajoute au total accumulé sur une créature, puis tout tombe à midi.
signal judgement_stacked(index: int, total: int)
signal judgement_fell(hits: Dictionary)
## LE SEIGNEUR DU FLÉAU (l'Éveil du Mage de la Peste).
## Le Miasme : l'aura monte ou retombe, et elle vient de mordre une créature collée à lui.
signal miasma_changed(active: bool)
signal miasma_bit(index: int)
## L'Épidémie saute d'une case à l'autre (la première part du mage).
signal epidemic_jumped(from: Vector2i, to: Vector2i)
## La Saignée : les cases qui éclatent, les doses de chacune, et les PV repris.
signal bled(cells: Array, doses: Array, healed: int)
## La Nuée de corbeaux passe d'une case à l'autre.
signal flock_flew(from: Vector2i, to: Vector2i)
## La Grande Peste tombe sur la carte.
signal great_plague(duration: float)
## L'ARCHIMAGE PRIMORDIAL (l'Éveil du Sorcier Suprême).
## La Roue des éléments monte ou retombe, puis tourne : `rank` est l'orbe en tête (0 feu, 1 eau, 2 terre, 3 air).
signal wheel_changed(active: bool)
signal wheel_turned(rank: int)
## La Grande Convergence se brise : un éclat par cible, chacun de son rang d'élément.
signal element_shards_flew(from: Vector2i, targets: Array, ranks: Array)
## Le Pas des éléments : les rayons partis de l'arrivée, un chemin et un rang par couloir.
signal element_rays_cast(from: Vector2i, paths: Array, ranks: Array)
## Une météore de la Genèse touche le sol, de son rang d'élément.
signal element_meteor_struck(cell: Vector2i, rank: int, radius: float)
## La lumière de l'origine, au bout de la Genèse.
signal primal_nova(cell: Vector2i, radius: float)
## L'ÉTOILE DU MATIN (l'Éveil du Porte-Lumière) : l'Éblouissement commence ou s'achève.
signal dazzle_changed(active: bool)
## LE FAUCHEUR DES ÂMES (l'Éveil de l'Ange de la Mort) : la Récolte commence ou s'achève.
signal harvest_changed(active: bool)
## La Reine du Firmament (l'Éveil de l'Ange des Étoiles).
signal firmament_changed(active: bool)
## Le Forgeron Céleste (l'Éveil de l'Archange d'Acier).
signal forge_changed(active: bool)
## Le Gardien du Trône (l'Éveil du Chérubin).
signal throne_changed(active: bool)
## Le Séraphin (l'Éveil de l'Archange du Ciel).
signal skies_changed(active: bool)
signal column_lingered(cell: Vector2i, seconds: float, radius: float)
signal great_sword_falling(cell: Vector2i, lead: float, radius: float)
signal great_sword_struck(cell: Vector2i, radius: float)
signal throne_eyes_opened(cell: Vector2i, radius: float)
signal garden_sword_struck(cell: Vector2i)
signal plate_shattered(cell: Vector2i)
signal hammer_stunned(cell: Vector2i, radius: float)
signal anvil_falling(cell: Vector2i, lead: float, radius: float)
signal anvil_dropped(cell: Vector2i, radius: float)
signal bastion_opened(cell: Vector2i, radius: float)
## La figure fermée de ses cinq étoiles, en cases (le contour, sans répéter le premier point) ; vide = ouverte.
signal figure_changed(points: Array)
signal big_meteor_falling(cell: Vector2i, lead: float, radius: float)
signal big_meteor_struck(cell: Vector2i, radius: float)
signal eclipse_ended(cell: Vector2i, radius: float)
## Les étoiles de la galaxie (cases) et leurs liens (paires d'indices dans `cells`).
signal galaxy_changed(cells: Array, links: Array)
## Une âme en orbite part frapper ce qui est arrivé à son contact.
signal soul_guarded(from: Vector2i, to: Vector2i)
## Le Croissant de l'au-delà revient vers lui par ce chemin.
signal crescent_returned(path: Array, duration: float)
## Un coup du Glas funèbre.
signal toll_rang(cell: Vector2i, radius: float)
## Un coup sur une créature aveuglée a porté son supplément.
signal dazzle_struck(cell: Vector2i)
## La Lance de l'Aurore reste allumée sur ces cases pendant `seconds`.
signal light_wall_raised(cells: Array, seconds: float)
## La Cathédrale de lumière vient de lui rendre un PV.
signal sanctuary_healed(cell: Vector2i)
## L'Égide solaire a encaissé un coup et le renvoie en rayon.
signal aegis_ray(from: Vector2i, to: Vector2i)
## Le Soleil de midi se lève pour `seconds`, lance ses rayons, puis tombe.
signal sun_risen(seconds: float)
signal sun_rays(cells: Array)
signal sun_set(cell: Vector2i, radius: float)
## Le venin d'une créature a changé. Zéro dose : elle est guérie.
signal enemy_venomed(index: int, doses: int, duration: float)
signal trail_started(duration: float)
signal puddle_laid(cell: Vector2i, life: float)
signal puddle_stepped(cell: Vector2i)
signal contagion_spread(from: Vector2i, to: Vector2i)
signal transfused(cells: Array, healed: int)
signal pandemic_cast(cell: Vector2i)
signal venom_killed(cell: Vector2i)
signal enemy_blinded(index: int, duration: float)
signal beam_fired(from: Vector2i, cells: Array)
signal enemy_star_marks(index: int, count: int)
signal astre_burst(cell: Vector2i)
signal stars_changed(cells: Array)
signal star_falling(cell: Vector2i, lead: float)
signal star_trail(from: Vector2i, to: Vector2i)
signal enemy_sentenced(index: int)
signal enemy_marked(index: int, duration: float)
signal souls_changed(count: int)
signal soul_sent(path: Array, duration: float)
signal soul_struck(cell: Vector2i)
signal last_hour_cast(cell: Vector2i)
signal last_hour_struck(cell: Vector2i)
signal wings_burst(cell: Vector2i)
signal plates_changed(count: int)
signal blades_thrown(from: Vector2i, directions: Array, reach: int)
signal blade_cut(cell: Vector2i)
## Les liens du parcours en largeur : chacun va de `from` à `to`, à `steps` cases du lanceur.
signal anvil_struck(cell: Vector2i, links: Array)
signal rampart_reflected(cell: Vector2i)
signal molten_started(duration: float)
signal molten_ended
signal pact_signed(cell: Vector2i)
signal enemy_possessed(index: int, duration: float)
## Le champ qui mène les possédés à leur proie. Vide, ils errent : ils n'ont personne.
signal possession_field(field: PackedInt32Array)
signal great_discord_cast(cell: Vector2i)
## LA REINE DE LA DISCORDE (l'Éveil de la Démone) : la Discorde contagieuse commence ou s'achève.
signal contagion_changed(active: bool)
## Un pantin possédé est mort, et ses fils sautent sur son voisin.
signal possession_jumped(from: Vector2i, to: Vector2i)
## L'Œil de la Reine s'ouvre au-dessus de sa cible, et ses fils tombent sur ces cases.
signal queen_eye_opened(cell: Vector2i, cells: Array)
## Un lien (Lien ou Toile de Souffrance) vient d'enchaîner ces ennemis.
signal web_spun(indices: Array)
## Un ennemi est mort pendant le Grand Bal : ses fils éclatent sur ses voisins.
signal ball_burst(cell: Vector2i, radius: float)
signal brawl_struck(cell: Vector2i)
signal bond_struck(cell: Vector2i)
signal enemy_swapped(index: int, cell: Vector2i)
## Le Roi de Braise : ce que le jeu met en scène. Les pièces, elles, se lisent dans `pieces()`.
signal piece_ejected(cell: Vector2i)
signal piece_struck(cell: Vector2i)
signal piece_recalled(cell: Vector2i)
signal piece_returned(recalled: bool)
signal chest_posed(cell: Vector2i)
signal chest_bit(cell: Vector2i, seconds: float)
signal chest_spat(cell: Vector2i)
signal recall_cast(cell: Vector2i)
signal hunters_cast(cell: Vector2i)
signal decoy_posed(cell: Vector2i, seconds: float)
signal decoy_blew(cell: Vector2i, radius: float)
## Le champ qui attire les ennemis vers le leurre. Vide, ils reviennent au mage.
signal decoy_field(field: PackedInt32Array)
signal cages_cast(cell: Vector2i, indices: Array, seconds: float)
signal cages_crushed(cells: Array)
## L'EMPEREUR DES CENDRES (l'Éveil du Roi de Braise) : le Sillage de cendres commence ou s'achève.
signal ashes_changed(active: bool)
## Un gantelet de l'Empereur crache sa gerbe de lave.
signal gauntlet_splashed(cell: Vector2i, radius: float)
## La Forge impériale aspire, puis explose.
signal forge_pulled(cell: Vector2i)
signal forge_blew(cell: Vector2i, radius: float)
## Le Retour de l'Empire : les trois pièces sont rentrées ensemble, l'onde de cendres part.
signal empire_wave(cell: Vector2i, radius: float)
## L'Empire des Cendres : une cage éclate en colonne de lave.
signal cage_burst(cell: Vector2i, radius: float)
## Le Chevalier Écarlate.
signal enemy_cuts(index: int, count: int)
signal dash_cut(from: Vector2i, to: Vector2i)
signal guard_raised(seconds: float)
signal guard_parried(cell: Vector2i)
signal sheathe_begun(cell: Vector2i, cells: Array, seconds: float, final: bool)
signal cut_burst(cell: Vector2i, count: int)
signal sheathe_ended(final: bool)
## LE SEIGNEUR ÉCARLATE (l'Éveil du Chevalier) : la Lame affûtée commence ou s'achève, et un ennemi arrivé au
## bout de ses entailles les ouvre de lui-même.
signal keen_changed(active: bool)
## LE GARDIEN DE L'ABÎME (l'Éveil du Geôlier) : le Poids des chaînes commence ou s'achève.
signal abyss_changed(active: bool)
## LE DRAGON PRIMORDIAL (l'Éveil du Dragon) : le Feu primordial commence ou s'achève, et ce qui meurt dans le
## feu explose en le répandant.
signal primal_changed(active: bool)
## LE MAÎTRE DU CASINO (l'Éveil du Croupier) : la Maison gagne toujours commence ou s'achève, et chaque Coup
## de chance paie une gerbe de jetons sur les voisins.
signal house_changed(active: bool)
## FAIM SANS FOND (l'Éveil de l'Avide) : la Faim sans fond commence ou s'achève.
signal endless_changed(active: bool)
signal house_payout(cell: Vector2i, radius: float)
## Les Dés du Diable : le troisième dé, et le brelan.
signal devil_die(from: Vector2i, cells: Array, value: int, triple: bool)
signal primal_burst(cell: Vector2i)
## Les Chaînes de l'Abîme cèdent en se resserrant : ces ennemis sont pris dans la glace.
signal chains_snapped(indices: Array, seconds: float)
## L'onde de givre du Pas de l'Abîme, à l'arrivée.
signal frost_wave(cell: Vector2i, radius: float)
## L'Abîme se referme sur ses prisonniers.
signal abyss_closed(cells: Array)
signal keen_burst(cell: Vector2i, count: int)
## La lame fantôme repasse sur le couloir du Pas des Mille Lames.
signal dash_echoed(from: Vector2i, to: Vector2i)
## La Rengaine écarlate projette ses pétales-lames d'un éclat vers un voisin.
signal petals_flung(from: Vector2i, to: Vector2i)
## Le Geôlier.
signal enemy_shackled(index: int, seconds: float)
signal enemy_hooked(index: int, from: Vector2i, to: Vector2i)
signal enemies_frozen(indices: Array, seconds: float)
signal soul_chains_cast(indices: Array, seconds: float)
signal gaol_cast(cell: Vector2i, indices: Array, radius: float, seconds: float)
signal gaol_ended(cells: Array)
signal dawn_cast(cell: Vector2i)
signal dawn_struck(cell: Vector2i)
## L'Archange du Ciel. Les ennemis étourdis ou cloués, avec le sort qui l'a fait : ses deux sorts
## de contrôle ne se dessinent pas pareil, alors que `enemies_frozen` ne dit pas lequel a frappé.
signal enemies_dazed(indices: Array, seconds: float, ability: Ability)
## L'Envol : il s'élève, puis retombe. L'atterrissage est rapporté APRÈS que le jeu l'a reposé.
signal flight_started(duration: float, ability: Ability)
signal flight_ended
signal flight_landed(cell: Vector2i, ability: Ability)
## Le Chérubin. Un œil s'ouvre ou se ferme sur un ennemi ; il s'embrase au contact.
signal enemy_eyed(index: int, open: bool)
## L'Éveil du Phénix : la seconde explosion du Soleil captif, les piliers, les braises de sa traînée.
signal echo_blasted(cell: Vector2i, ability: Ability)
signal pillars_erupted(cells: Array, ability: Ability)
signal ember_laid(cell: Vector2i, life: float)
## L'Éveil du Seigneur des Marées : le rebond du Trident, la Bulle tenue, le Léviathan.
signal water_bounced(from: Vector2i, to: Vector2i)
signal shield_held(healed: int)
signal leviathan_cast(cell: Vector2i, ability: Ability, direction: int)
## L'Éveil du Colosse : un ennemi piétiné, une colonne de lave du Cataclysme, l'Éruption.
signal trampled(index: int, cell: Vector2i)
signal lava_column(cell: Vector2i, ability: Ability)
signal eruption_burst(cell: Vector2i, ability: Ability)
signal colossus_step(cell: Vector2i)
## L'Éveil de l'Avatar de la Tempête : ses charges de Surtension, la foudre qui tombe à la cinquième, le
## Saut d'éclair (les cases touchées, du départ à l'arrivée), un éclair de la Colère du ciel.
signal surge_changed(charges: int)
signal surge_struck(cell: Vector2i)
signal lightning_hopped(cells: Array)
signal wrath_bolt(cell: Vector2i, index: int)
## L'Éveil du Seigneur du Néant : son ombre répète un coup, un trou noir s'ouvre puis s'effondre,
## l'orbe ouvre un gouffre, l'éclipse tombe.
signal double_struck(index: int, ability: Ability)
signal hole_opened(cell: Vector2i, seconds: float, ability: Ability)
signal hole_collapsed(cell: Vector2i, ability: Ability)
signal void_opened(cell: Vector2i)
signal eclipse_fell(seconds: float)
## LE MAÎTRE DES LÉGIONS (l'Éveil de l'Invocateur) : la Légion commence ou finit, une proie est
## marquée, un diablotin explose, une gargouille tombe, il échange sa place, le dragon passe.
signal legion_changed(active: bool)
signal prey_marked(index: int, seconds: float)
signal summon_burst(id: int, cell: Vector2i, radius: float)
signal summon_dropped(id: int, cell: Vector2i, radius: float)
signal summon_swapped(id: int, from: Vector2i, to: Vector2i)
signal dragon_flyover(cell: Vector2i, reach: float, width: float)
signal eye_burst(cell: Vector2i)
signal whirl_started(duration: float, radius: float)
signal whirl_cut(cell: Vector2i)
signal veil_repelled(cell: Vector2i)
signal garden_planted(cell: Vector2i, radius: float, seconds: float)
signal garden_repelled(cell: Vector2i)
signal garden_ended(cell: Vector2i)
# Le Dragon des Abysses : le sol qui brûle, et ses cinq sorts.
signal ground_ignited(cells: Array, seconds: float)
signal ground_faded(cells: Array)
signal breath_cast(from: Vector2i, cells: Array, seconds: float)
signal dragon_bit(index: int, cell: Vector2i, devoured: bool)
signal scales_raised(seconds: float)
signal scales_burst(cell: Vector2i, count: int, radius: float)
signal wings_beaten(cell: Vector2i, radius: float)
signal dragon_shadow_cast(cell: Vector2i, direction: Vector2i, indices: Array, delay: float)
signal shadow_column(cell: Vector2i, first: bool)
signal shadow_ended
# Le Croupier des Enfers : le hasard, tiré ici avec la graine de la partie.
signal lucky_hit(index: int, cell: Vector2i)
signal dice_rolled(from: Vector2i, cells: Array, first: int, second: int)
signal trap_posed(cell: Vector2i, seconds: float)
signal trap_faded(cell: Vector2i)
signal trap_flipped(cell: Vector2i, suit: int, targets: Array)
signal coin_flipped(face: bool)
signal doubled_spent
signal roulette_spun(cell: Vector2i, result: int, seconds: float)
signal roulette_landed(result: int, cells: Array)
# L'Avide : ses bouchées, et ce qu'il avale.
signal bites_changed(count: int, gained: bool)
signal gulf_opened(cell: Vector2i, radius: float, seconds: float)
signal gulf_closed(cell: Vector2i, cells: Array)
signal devoured(index: int, cell: Vector2i, swallowed: bool)
signal regurgitated(from: Vector2i, cells: Array)
signal leap_landed(cell: Vector2i, radius: float)
signal feast_started(seconds: float)
signal feast_bite(index: int, cell: Vector2i, killed: bool)
signal feast_ended
## L'Archidémon du Pacte : le Prix du Sang commence ou s'arrête ; sa vie vient de couler ; un kill la lui rend
## (la case de la proie) ; une serre de l'Apocalypse s'abat.
signal blood_price_changed(active: bool)
signal blood_price_paid(remaining: int)
signal blood_fed(cell: Vector2i)
signal pact_claw_struck(cell: Vector2i)

## Vitesse des projectiles, en cases par seconde. Trois fois le joueur : le tir
## se voit partir et arriver, sans jamais laisser le temps de fuir.
const PROJECTILE_SPEED := 16.0
## Recul appliqué aux structures dans le choix de cible. Plus grand que la plus
## longue portée du jeu : aucun ennemi à portée ne peut donc passer derrière une
## maison, quelle que soit la distance.
const STRUCTURE_PENALTY := 100
## Fréquence des dégâts d'une zone persistante.
const ZONE_TICK := 0.5
## Délai minimal entre deux charges d'un même sort.
##
## Court, mais pas nul : sur téléphone, une pression un peu longue est lue comme
## deux appuis, et sans ce garde-fou le joueur viderait deux charges sur la même
## case sans l'avoir voulu. Il ne se sent pas en jeu — on ne peut pas taper plus
## vite que ça utilement — mais il protège les charges des fausses manœuvres.
const CHARGE_GAP := 0.35

## --- INVOCATIONS ------------------------------------------------------------
##
## Les créatures de l'Invocateur. Elles vivent ICI et non dans le Level, pour la
## même raison que les projectiles et les zones : la simulation d'équilibrage
## doit les faire chasser en headless avec exactement les règles du jeu.
##
## Les marcheurs (imp, gargouille) descendent un champ de distances calculé
## depuis TOUS les ennemis vivants — le plus proche en chemin, pas à vol
## d'oiseau. Le dragon VOLE : il ignore les murs et va droit sur sa proie —
## c'est ce qui fait de lui l'ultime, aucun couloir ne le retarde.
##
##   speed   en cases/s ; reach  distance de frappe (cases, continue)
##   period  secondes entre deux coups ; damage  dégâts par coup
const SUMMON_KINDS := {
	"imp": {"speed": 2.8, "damage": 10, "period": 0.9, "reach": 1.1, "flies": false},
	"gargouille": {"speed": 4.0, "damage": 18, "period": 1.1, "reach": 1.1, "flies": false},
	"dragon": {"speed": 3.6, "damage": 34, "period": 1.3, "reach": 10.0,
		"min_reach": 3.0, "projectile_speed": 0.65, "flies": true},
	# L'OMBRE MALÉFIQUE de la Faille des ténèbres. Elle ne mord pas : elle
	# SOUFFLE un gaz violet, d'où une portée d'une case et demie là où les
	# marcheurs frappent au contact. Ses dégâts sont modestes et son poison fait
	# le reste — c'est une créature qui use, pas qui exécute, et elles sont six.
	"ombre": {"speed": 4.2, "damage": 12, "period": 1.1, "reach": 1.5,
		"flies": false, "poison": 3},
	# LE CYCLONE de l'ultime de l'Air. Il VOLE — c'est-à-dire qu'il va droit sur
	# sa proie, haies comprises. Rien d'autre chez ce mage ne traverse un mur,
	# et c'est ce qui en fait un ultime ; la colonne monte plus haut que les
	# haies, donc ça se voit.
	#
	# Lent (3 cases/s contre 4,5 à 5 aux poursuivants) : il ne rattrape personne
	# à la course. Ce qu'il rattrape, c'est ce qui s'attarde — et il coupe au
	# plus court pendant que sa proie fait le tour.
	"cyclone": {"speed": 3.0, "damage": 18, "period": 1.5, "reach": 1.4,
		"flies": true},
}
## LES ENNEMIS SE DÉFENDENT. Ce qu'une créature encaisse, en coups : un coup d'ennemi en
## retire un, comme au mage, un coup de boss `BOSS_BLOW`. Absente d'ici, elle est hors d'atteinte :
## le dragon tire de loin en volant, le cyclone n'est qu'une colonne de vent.
##
## Sans ça, l'Invocateur et la Faille des ténèbres jouaient avec une armée intouchable : les
## créatures chassaient pendant que les ennemis leur passaient au travers.
const SUMMON_HITS := {"imp": 3, "gargouille": 6, "ombre": 3}
## La Légion de l'Éveil encaisse deux fois plus : elle est censée tenir la ligne.
const LEGION_HITS := 2.0
const BOSS_BLOW := 3

## Créatures simultanées au maximum. Au-delà, la PLUS ANCIENNE disparaît : une
## armée sans plafond viderait le labyrinthe à la place du joueur.
const MAX_SUMMONS := 4
## Rayon de l'explosion de la boule de feu du Roi-Dragon embrasé (l'Éveil de l'Invocateur).
const ROYAL_FIREBALL_RADIUS := 1.3
## Cadence de recalcul du champ des proies. 0,35 s comme l'IA ennemie : les
## invocations n'ont pas besoin d'être plus réactives que ce qu'elles chassent.
const SUMMON_FIELD_REFRESH := 0.35

## --- TRAITS ÉLÉMENTAIRES ---------------------------------------------------
##
## Chaque élément MARQUE ses coups d'un effet propre. C'est ce qui fait sept
## mages réellement différents : avant, tous tiraient le même projectile sous
## sept couleurs, et le choix du personnage était un choix de teinte.
##
##   FEU      brûlure — 30 % des dégâts en plus, étalés sur 1,5 s
##   EAU      trempe — la cible ralentit de 38 % pendant 2,2 s
##   TERRE    ébranlement — la cible s'arrête net 0,7 s
##   TÉNÈBRES ponction — le mage récupère 22 % des dégâts en vie
##   FOUDRE   arc — le coup saute au voisin (moitié des dégâts)
##   AIR      bourrasque — la cible est repoussée de 2 cases
##   SUPRÊME  écho — 40 % des dégâts se répètent 0,6 s plus tard
##
## Deux garde-fous, tous deux nés du papier avant la première partie :
##   - les ZONES ne déclenchent PAS de trait : une zone tique toutes les 0,5 s,
##     et un ébranlement par tick serait une paralysie permanente ;
##   - les STRUCTURES n'en reçoivent aucun : repousser une maison n'a pas de
##     sens, et la brûlure en aurait trop — un DoT gratuit sur un objectif fixe.
const BURN_RATIO := 0.30
const BURN_TICKS := 3
const BURN_TICK := 0.5
## Le poison prélève UNE FOIS PAR SECONDE. Pas au demi-tick des zones : sur des
## dégâts entiers et petits, un demi-tick arrondi à 1 doublerait silencieusement
## le chiffre annoncé au joueur — « 1 PV » deviendrait 2 PV par seconde.
const POISON_TICK := 1.0
const SOAK_FACTOR := 0.62
const SOAK_DURATION := 2.2
const STAGGER_DURATION := 0.7
## Un même ennemi ne peut être ébranlé qu'une fois toutes les 3 s : sans ce
## verrou, le mage de Terre enchaînerait les arrêts et l'ennemi ne jouerait plus.
const STAGGER_LOCK := 3.0
## LA PONCTION REND UN POINT DE VIE, PAS UNE PART DES DÉGÂTS.
##
## ⚠️ Elle rendait `22 % des dégâts infligés`, et c'était un défaut d'UNITÉS :
## `dealt` se compte en points de vie d'ENNEMI — 16 pour une orbe, 110 pour un
## ultime — quand le mage en a TROIS. Une orbe à 16 dégâts rendait donc 4 PV sur
## un maximum de 3 : le Sorcier des Ténèbres se remettait à fond à chaque coup
## porté, et sa fiche annonçait « encaisse mal ».
##
## Le trait garde son sens — il aspire la vie de ce qu'il frappe — mais il le
## fait à l'échelle du mage : un point, et pas plus souvent que toutes les dix
## secondes. C'est de quoi se relever d'une erreur, pas de quoi ne plus jamais
## en payer une.
const LEECH_HEAL := 1
const LEECH_LOCK := 10.0
const CHAIN_RANGE := 4
const CHAIN_RATIO := 0.5
const PUSH_CELLS := 2
const ECHO_RATIO := 0.40
const ECHO_DELAY := 0.6
## Le trait du Temps : aussi fort que la Trempe mais plus court, c'est un accroc. Mesuré :
## à 72 % pendant 1 s, le bot expert mourait 75 % du temps au Bois d'Épine.
const RETARD_DURATION := 1.4
const RETARD_FACTOR := 0.6
## La trace gardée, en secondes : assez pour le plus long sort qui la relit.
const TRAIL_KEEP := 11.0   # le second double du Paradoxe rejoue 10 s
## Le venin : des doses qui s'additionnent et prélèvent ensemble, une fois par seconde.
## Mesuré aux bots, comme le reste : voir la note du catalogue.
const VENOM_MAX := 3
const VENOM_DAMAGE := 7
const VENOM_DURATION := 5.0
const VENOM_TICK := 1.0
## Au troisième coup, les étoiles de la cible explosent pour ces dégâts.
const ASTRE_MARKS := 3
const ASTRE_DAMAGE := 26
## Une quatrième étoile remplace la plus ancienne. Un rayon touche à cette distance, en cases.
const STAR_MAX := 3
const STAR_REACH := 0.75
const STAR_TICK := 0.25
## L'écart entre deux étoiles qui tombent, et l'avance que prend leur dessin sur leur impact.
const STAR_FALL_GAP := 0.22
const STAR_FALL_LEAD := 0.34
## LE FIRMAMENT de la Reine : cinq étoiles au lieu de trois, des rayons 50 % plus forts, deux étoiles éphémères au
## plus. Le gros météore s'annonce plus tôt que les petites étoiles, et tombe un peu après la dernière.
const FIRMAMENT_STARS := 5
const FIRMAMENT_RAY := 1.5
const SPARK_MAX := 2
const BIG_METEOR_LEAD := 0.9
const BIG_METEOR_PAUSE := 0.35
## Une étoile de la galaxie se relie à ses deux voisines les plus proches, jusqu'à cette distance en cases.
const GALAXY_LINK := 8.0
const GALAXY_NEIGHBOURS := 2

## Le gain de force du Démon du Pacte, atteint à 1 PV quel que soit le stage.
const RAGE_MAX := 0.5
## La Démone : un possédé frappe ses voisins à cette cadence, et leur riposte suit.
const POSSESS_GAP := 0.7
const POSSESS_FIELD_REFRESH := 0.4
const WHISPER_MARKS := 3
const TROUBLE_SECONDS := 4.0
const TROUBLE_FACTOR := 0.7
const TROUBLE_BONUS := 2.0
## La Discorde contagieuse : un pantin mort passe ses fils au plus proche à cette distance, par les couloirs,
## pour le temps qui lui restait et au moins `CONTAGION_MIN` secondes.
const CONTAGION_REACH := 3
const CONTAGION_MIN := 2.0
## L'échangé reste sonné un instant : sinon il frappait à l'arrivée, sans qu'on puisse fuir.
const SWAP_STUN := 0.7

enum Piece { ORBIT, HUNT, POSED, BITE, LOOSE, RETURN, RECALL }
## Deux gantelets et un plastron. Les plaques de `Health` comptent ceux qui sont en orbite.
const PIECES_MAX := 3
const GAUNTLETS: Array[int] = [0, 1]
const CHEST_PIECE := 2
## Sans ordre, une pièce rentre seule après ce temps : on n'a jamais à aller la chercher.
const PIECE_AUTO_RETURN := 8.0
## Ce que chaque pièce lancée ajoute à son allure : de 4,4 à 5,6.
const PIECE_SPEED_BONUS := 0.4
const HUNT_SPEED := 7.0
const HUNT_GAP := 0.7
const HUNT_REACH := 1.1
const RETURN_SPEED := 9.0
const RECALL_SPEED := 13.0
const RECALL_REACH := 0.9
const PIECE_HOME := 0.6
const LOOSE_THROW := 2.5
## La pièce éjectée par un coup blesse autour de lui, à ce rayon.
const EJECT_DAMAGE := 16
const EJECT_RADIUS := 2.0
## Le boss ne se laisse pas retenir : il prend ce coup, et le plastron repart.
const CHEST_BOSS_BITE := 40
## LE SILLAGE DE CENDRES de l'Empereur : chaque pièce qui vole laisse ses cases en cendres ardentes
## ce temps-là (les cases en feu du Dragon, `FIRE_CELL_DAMAGE` par seconde), et une pièce arrachée
## par un coup revient en `ASH_RETURN` au lieu de `PIECE_AUTO_RETURN`.
const ASH_SECONDS := 2.0
const ASH_RETURN := 4.0
## La Forge impériale aspire d'une case à cet intervalle.
const FORGE_PULL_GAP := 0.5

## Le Chevalier Écarlate : ce qu'un ennemi porte d'entailles, et combien de temps elles tiennent.
const CUTS_MAX := 5
const CUT_SECONDS := 8.0
## La Lame affûtée : une entaille de plus par coup, jusqu'à `KEEN_CUTS_MAX`, et à ce compte elles s'ouvrent seules
## pour `KEEN_CUT_DAMAGE` chacune. La Garde du Seigneur ne riposte qu'une fois par `PARRY_LOCK`.
const KEEN_CUTS_MAX := 8
const KEEN_CUT_DAMAGE := 18
const PARRY_LOCK := 0.3
## Le silence entre le claquement du fourreau et l'éclat : c'est lui qui fait le geste.
const SHEATHE_SILENCE := 0.28

## Le Geôlier : au troisième poing sur le même ennemi, une entrave le cloue au sol ce temps-là.
const SHACKLE_HITS := 3
const SHACKLE_SECONDS := 1.5
## LE POIDS DES CHAÎNES du Gardien : entravé au deuxième coup, et ce qui est entravé, figé ou cloué prend
## `ABYSS_HELD_BONUS` de dégâts en plus de ses coups.
const ABYSS_SHACKLE_HITS := 2
const ABYSS_HELD_BONUS := 0.4
## Sous cette part de ses PV, un ennemi touché par l'Ange de la Mort est achevé.
const PLATE_MAX := 3
## LA FORGE VIVANTE du Forgeron Céleste : cinq plaques, et une plaque qui casse blesse ce qui est à son contact.
const FORGE_PLATES := 5
const FORGE_SHARD_DAMAGE := 30
const FORGE_SHARD_REACH := 1.5
## L'enclume s'annonce ce temps avant de tomber.
const ANVIL_DROP_LEAD := 0.7
## Les kills qu'il faut pour reforger une plaque.
const PLATE_KILLS := 2
## Le Chérubin : ce que brûle l'œil qui s'embrase, à quelle distance, et après combien de temps
## un nouvel œil peut s'ouvrir sur le même ennemi. Sans ce délai, un ennemi collé à lui brûlerait
## à chaque coup, et son attaque doublerait au contact.
const EYE_DAMAGE := 20
const EYE_REACH := 1.05
const EYE_LOCK := 3.0
## Le Jardin gardé ne brûle un même ennemi qu'une fois par ce délai, même s'il revient sans cesse.
const GARDEN_LOCK := 0.5
## LE REGARD DU TRÔNE : l'œil brûle à cette distance au lieu du contact, plus fort, et se rallume plus vite.
const THRONE_REACH := 2.1
## LES YEUX DU CIEL du Séraphin : ce que ses coups touchent prend ce bonus, ce temps.
const SKY_MARK_BONUS := 0.2
const SKY_MARK_SECONDS := 3.0
## L'épée géante du Jugement dernier tombe ce temps après la dernière épée, et s'annonce `GREAT_SWORD_LEAD` avant.
const GREAT_SWORD_PAUSE := 0.6
const GREAT_SWORD_LEAD := 1.0
## Les lances de l'Ascension cherchent jusqu'à cette distance, à vol d'oiseau.
const FLIGHT_LANCE_REACH := 6.0
const THRONE_EYE_DAMAGE := 35
const THRONE_EYE_LOCK := 1.5
## L'épée du bord de l'Éden fait un tour en ce temps, et frappe à cette distance de sa pointe.
const GARDEN_SWORD_PERIOD := 3.0
const GARDEN_SWORD_REACH := 1.2
const GARDEN_SWORD_LOCK := 1.0
## Les Ailes voilées ne repoussent un même ennemi qu'une fois par ce délai.
const VEIL_LOCK := 0.6
## Le Dragon : une case en feu dure FIRE_CELL_SECONDS et ronge FIRE_CELL_DAMAGE par seconde ce
## qui s'y tient. Lui y gagne INFERNO_SPEED de son allure.
const FIRE_CELL_SECONDS := 4.0
const FIRE_CELL_DAMAGE := 10
## LE FEU PRIMORDIAL du Dragon éveillé : ses cases brûlent `PRIMAL_FIRE_LONGER` fois plus longtemps et rongent
## `PRIMAL_FIRE_DAMAGE`, et ce qui meurt dans le feu explose (`PRIMAL_BURST_DAMAGE`, `PRIMAL_BURST_RADIUS`).
const PRIMAL_FIRE_LONGER := 2.0
const PRIMAL_FIRE_DAMAGE := 15
const PRIMAL_BURST_DAMAGE := 20
const PRIMAL_BURST_RADIUS := 1.2
const INFERNO_SPEED := 0.2
## L'Ombre du Dragon : la première colonne attend que l'ombre soit passée, puis elles se suivent.
const SHADOW_DELAY := 1.2
const SHADOW_GAP := 0.12
## Le Croupier : la chance d'un coup critique, et ce qu'il multiplie.
const LUCK_CHANCE := 0.2
const LUCK_MULT := 3
## Les figures de la Carte piège.
enum Suit { FIRE, ICE, THUNDER, JOKER }
## LA MAISON GAGNE TOUJOURS : le Coup de chance tombe `HOUSE_LUCK` fois plus souvent, et chacun paie une gerbe de
## jetons (`PAYOUT_DAMAGE`, `PAYOUT_RADIUS`) sur les voisins.
const HOUSE_LUCK := 2.0
const PAYOUT_DAMAGE := 15
const PAYOUT_RADIUS := 1.2
## Le Roi de foudre saute à ce nombre d'ennemis en plus, à cette distance de la carte.
const TRAP_CHAIN := 2
const TRAP_REACH := 4
const TRAP_BURN_SECONDS := 3.0
## La Roulette tourne ce temps avant que la bille tombe. Le Zéro sort une fois sur sept.
const ROULETTE_SPIN := 1.8
const ROULETTE_ZERO := 1.0 / 7.0
enum Slot { ZERO, RED, BLACK }
## L'Avide : ses bouchées, ce que chacune ajoute, et le temps qu'il faut pour en perdre une.
const BITES_MAX := 5
const BITE_DAMAGE := 0.08
const BITE_SIZE := 0.06
const BITE_DECAY := 10.0
## LA FAIM SANS FOND : tant qu'elle dure, il garde jusqu'à `ENDLESS_BITES` bouchées, qui ne fondent plus, et chaque
## kill lui en donne `ENDLESS_GAIN`.
const ENDLESS_BITES := 8
const ENDLESS_GAIN := 2
## Le Gouffre tire d'une case à cet intervalle, et mord ce qui est à ce rayon de son centre.
const GULF_PULL_GAP := 0.4
const GULF_BITE_RADIUS := 1.5
## Le Festin avale un ennemi à cet intervalle, après une première attente, et soigne au plus trois fois.
const FEAST_GAP := 0.6
const FEAST_FIRST := 0.45
const FEAST_HEALS := 3
const FEAST_SIZE := 1.8
const BLADE_OUT := 0.4
const BLADE_BACK := 0.35
const BLADE_FAN := 30.0
const BLADE_REACH := 0.8
## Cases par seconde de l'onde d'enclume.
const ANVIL_SPEED := 14.0
## Le Rempart ne rend qu'un coup à la fois, à ce qui est à sa portée.
const REFLECT_GAP := 0.3
const REFLECT_REACH := 2
const MOLTEN_DAMAGE := 1.5
const MOLTEN_PUSH := 1
const SENTENCE_BELOW := 0.15
## Ce que le marqué du Glas prend de dégâts en plus.
const MARK_BONUS := 0.4
const SOUL_MAX := 3
## Cases parcourues par seconde, et l'écart entre deux âmes lâchées.
const SOUL_SPEED := 13.0
const SOUL_GAP := 0.08
## L'Heure dernière : l'attente avant la faux, sa traversée, et la part de PV qu'elle prend.
const HOUR_DELAY := 0.95
const HOUR_SWEEP := 0.7
const HOUR_SHARE := 0.5

## L'éblouissement du trait : court, et jamais deux fois de suite sur la même créature.
## Le verrou empêche qu'un ennemi reste aveuglé en permanence : il doit pouvoir revenir.
const GLARE_SECONDS := 1.2
const BLIND_LOCK := 5.0
## L'Aube laisse le temps de l'éclair, puis frappe ennemi après ennemi.
const DAWN_DELAY := 0.65
const DAWN_GAP := 0.09

var grid: MazeGrid
var stats: CharacterStats
var health: Health
## SORTS ILLIMITÉS — le mode démo. Aucune recharge : on vient y regarder les
## sorts sous toutes les coutures, pas les rationner. La campagne, elle, garde
## ses recharges ; ce drapeau n'est posé que par un LevelConfig en `is_demo`.
var free_use := false
var hero_transform_allowed := false

var _cooldowns := {}        # id de compétence -> secondes restantes
var _charges := {}          # id -> charges restantes (sorts à charges)
var _refills := {}          # id -> charges à rendre quand la recharge finit
var _recover := {}          # id -> délai avant la charge suivante
var _in_flight: Array[Dictionary] = []
var _last_free_shot := 0
var _summon_projectiles: Array[Dictionary] = []
var _zones: Array[Dictionary] = []
var _walls: Array[Dictionary] = []
var _next_zone_id := 1
var _summons: Array[Dictionary] = []
var _next_summon_id := 1
## Champ de distances vers les proies, partagé par tous les marcheurs.
var _summon_field := PackedInt32Array()
## Le coup de chaque ennemi contre les créatures, au même index que les ennemis.
var _foe_swings := {}
var _summon_field_timer := 0.0
var _burning := {}                     # index -> {ticks, timer, damage}
var _poisoned := {}                    # index -> {time_left, timer, damage}
var _echoes: Array[Dictionary] = []
var _stagger_locks := {}               # index -> secondes avant le prochain ébranlement
## index -> secondes avant qu'un piège de zone puisse le reprendre. Sans ce
## verrou, une créature immobilisée dans les flammes serait re-piégée à chaque
## tick et ne repartirait JAMAIS.
var _snare_locks := {}
## Temps restant avant que la Ponction puisse rendre un point de vie. Sans ce
## verrou, un trait qui rend 1 PV à chaque coup reste une immortalité — juste
## un peu plus lente.
var _leech_left := 0.0
var _meteors: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()
var _empower_bonus := 0
var _empower_left := 0.0
var _shield_left := 0.0
## Temps d'intouchabilité restant, pour le bouclier de la Terre.
var _immune_left := 0.0
var _waves: Array[Dictionary] = []
## Les gerbes de pierre en cours de course.
var _lines: Array[Dictionary] = []
## Les séismes en cours. Un seul à la fois en pratique, mais la file coûte le
## même prix qu'un champ et se relit comme les autres effets.
var _quakes: Array[Dictionary] = []
## Les cristaux plantés qui tirent tout seuls.
var _turrets: Array[Dictionary] = []
var _next_turret_id := 1
var _chains: Array[Dictionary] = []
var _storm := {}
var _sky: Array[Dictionary] = []
var _clock := 0.0
var _trail: Array[Dictionary] = []     # {cell, time}, du plus ancien au plus récent
var _walkers: Array[Dictionary] = []
var _hourglass_left := 0.0
var _hourglass_health := 0
var _hourglass_ratio := 0.5
var _time_stop_left := 0.0
var _haste_left := 0.0
var _haste_factor := 1.0
var _health_log: Array = []            # [instant, PV], à chaque changement : le Rembobinage
var _clock_bombs: Array[Dictionary] = []   # {id, cell, left, ability}
var _next_bomb := 0
var _judgement_left := 0.0
var _judgement_ability: Ability = null
var _judgement_bank := {}              # index -> dégâts accumulés pendant l'arrêt
var _miasma_left := 0.0
var _miasma_tick := 0.0
var _miasma_every := 1.0
var _miasma_cap := VENOM_MAX
var _puddle_doses := 1                 # le Sillage pestilent : doses et ralentissement de ses flaques
var _puddle_slow := 0.0
var _wheel_left := 0.0                 # la Roue des éléments de l'Archimage
var _wheel_rank := 0
var _wheel_hit := -1                   # le rang que porte le tir qui touche ; -1 = la roue telle qu'elle est
var _double_echo_left := 0.0           # l'Apothéose : son Écho frappe deux fois
var _harvest := false                  # la Récolte du Faucheur des Âmes
var _firmament := false                # le Firmament de la Reine
var _forge := false                    # la Forge vivante du Forgeron
var _throne := false                   # le Regard du Trône du Gardien
var _skies := false                    # les Yeux du ciel du Séraphin
var _sky_marks := {}                   # index -> secondes de marque du ciel
var _columns: Array[Dictionary] = []   # {cell, left, tick, ability}
var _flight_lance_timer := 0.0
var _great_swords: Array[Dictionary] = []  # {cell, time_left, warned, ability}
var _throne_veil: Ability = null
var _sword_locks := {}                 # index -> secondes, l'épée du bord de l'Éden
var _shards_pending := 0
var _hammer_count := 0
var _anvil_drops: Array[Dictionary] = []  # {cell, time_left, ability}
var _bastion: Ability = null
var _molten_steps := 0.0
var _step_cell := Vector2i(-1, -1)
var _sparks: Array[Dictionary] = []    # {cell, time_left} : les étoiles éphémères du Trait de comète
var _figure_closed := false
var _eclipse: Ability = null
var _galaxy: Array[Dictionary] = []    # {cell, time_left}
var _galaxy_links: Array = []          # [a, b] dans `_galaxy`
var _galaxy_ability: Ability = null
var _galaxy_tick := 0.0
var _guard_locks := {}                 # index -> secondes avant qu'une âme en orbite le frappe de nouveau
var _returns: Array[Dictionary] = []   # {cells, time_left, ability} : les croissants sur le chemin du retour
var _tolls: Array[Dictionary] = []     # {left, timer, ability} : les coups du Glas funèbre à venir
var _dazzle_left := 0.0               # l'Éblouissement de l'Étoile du Matin
var _contact := {}                     # index -> secondes passées collé à lui, pendant l'Éblouissement
var _glare_count := 0                  # les coups du Trait solaire, pour en aveugler un sur `blind_every`
var _light_walls: Array[Dictionary] = []   # {cells, time_left, tick, ability} : la Lance de l'Aurore restée allumée
var _aegis: Ability = null             # l'Égide solaire en place
var _aegis_seen := 0                   # le bouclier qu'elle avait à l'image d'avant
var _sun: Dictionary = {}              # {left, tick, ability} : le Soleil de midi
var _novas: Array[Dictionary] = []     # {time_left, ability} : la lumière de l'origine, au bout de la Genèse
var _venom := {}                       # index -> {doses, time_left, timer, plague}
var _venom_locks := {}                 # index -> secondes avant la dose de sol suivante
var _plague: Ability = null            # l'ultime : ce qui éclate laisse son nuage
var _seep_left := 0.0
var _seep_life := 0.0
var _puddles := {}                     # case -> secondes restantes
var _blind_locks := {}                 # index -> secondes avant le prochain aveuglement
var _dawn: Array[Dictionary] = []      # {index, time_left, ability}
var _star_marks := {}                  # index -> étoiles posées par le trait
var _stars: Array[Dictionary] = []     # {cell, time_left, ability}
var _star_tick := 0.0
var _falling: Array[Dictionary] = []   # {cell, time_left, warned, ability}
var _forge_kills := 0                  # kills vers la prochaine plaque
var _volleys: Array[Dictionary] = []   # {from, directions, time, hit, returning, ability}
var _anvils: Array[Dictionary] = []    # {field, time, hit, ability}
var _rampart: Ability = null
var _reflect_waiting := false
var _reflect_lock := 0.0
var _molten_left := 0.0
var _possessed := {}                   # index -> {left, timer, strike}
var _foyer := -1
var _foyer_timer := 0.0
var _whispers := {}                    # index -> murmures reçus, avant le trouble
var _troubled := {}                    # index -> secondes de trouble
var _bond := {}                        # {members, left, share}
var _bond_relaying := false
var _pieces: Array[Dictionary] = []
var _torn_pending := 0
var _decoy := {}                       # {cell, left, ability}
var _ashes := false                    # le Sillage de cendres de l'Empereur, tant qu'il dure
var _empire_wave: Ability = null       # le Retour de l'Empire attend ses trois pièces
var _contagious := false               # la Discorde contagieuse de la Reine, tant qu'elle dure
var _jumps_pending: Array = []         # [{cell, left, strike}] : les fils des pantins morts, à passer
var _ball := {}                        # le Grand Bal : {left, ability}
var _bursts_pending: Array = []        # les cases des morts du bal, à faire éclater
var _caged := {}                       # index -> vrai
var _cage_left := 0.0
var _cage_ability: Ability = null
var _cuts := {}                        # index -> {count, left}
var _guard: Ability = null
var _parry_pending := false
var _keen := false                     # la Lame affûtée du Seigneur Écarlate, tant qu'elle dure
var _keen_pending: Array = []          # les ennemis arrivés au bout de leurs entailles, à ouvrir
var _dash_echo := {}                   # {left, from, to, cells, ability} : la lame fantôme qui repasse
var _parry_lock := 0.0
var _sheathe := {}                     # {left, targets, ability}
var _shackle_hits := {}                # index -> poings reçus, avant l'entrave
var _soul_chains := {}                 # {members, left, tick, ability}
var _gaol := {}                        # {members, left, tick, ability}
var _abyss := false                    # le Poids des chaînes du Gardien, tant qu'il dure
var _primal := false                   # le Feu primordial du Dragon, tant qu'il dure
var _primal_pending: Array = []        # les cases où un ennemi est mort dans le feu, à faire exploser
var _house := false                    # la Maison gagne toujours du Maître du Casino, tant qu'elle dure
var _endless := false                  # la Faim sans fond de l'Avide, tant qu'elle dure
var _payouts: Array = []               # les cases où un Coup de chance doit payer ses jetons
var _held := {}                        # index -> secondes : ce qui est entravé, figé ou cloué
var _blast_hits := 0                   # ennemis touchés par le souffle en cours
var _pact_owed := 0                    # PV rendus à la fin du Dernier Pacte
var _blood_left := 0.0                 # le Prix du Sang de l'Archidémon, tant qu'il dure
var _blood_every := 8.0
var _blood_timer := 0.0
var _blood_rage := 1.0
var _claw_ability: Ability = null      # l'Apocalypse de Sang, tant que tombent ses serres
var _claw_timer := 0.0
var _souls := 0                        # âmes récoltées par l'Ange de la Mort
var _marked := {}                      # index -> secondes de marque du Glas
var _flying: Array[Dictionary] = []    # {index, time_left, ability}
var _hour: Array[Dictionary] = []      # {index, time_left, ability}
var _wings: Ability = null             # la coque en place, quand elle aveugle en cédant
var _wings_cell := Vector2i.ZERO
var _flight: Ability = null            # l'Envol en cours, nul au sol
var _eyes := {}                        # index -> vrai : l'œil du Chérubin est ouvert sur lui
var _echo_blasts: Array[Dictionary] = []   # {cell, time_left, ability} : la seconde explosion
var _embers := {}                      # case -> secondes : la traînée du Phénix
var _ember_left := 0.0                 # tant qu'elle dure, il en laisse une derrière lui
var _ember_damage := 0
var _ember_life := 0.0
var _ember_tick := 0.0
var _ember_from := Vector2i(-9999, -9999)
var _held_heal := 0                    # PV rendus si la bulle en cours tient jusqu'au bout
var _leviathan := {}                   # {origin, direction, time, hit, ability}
var _trample_left := 0.0               # Piétinement du Colosse, tant qu'il dure
var _trample_damage := 0
var _trample_cells := 0
var _trample_locks := {}               # index -> secondes avant qu'il puisse le repiétiner
var _trample_from := Vector2i(-9999, -9999)
var _trample_lock := 1.0
var _trample_slow := 0.0
var _lava := []                        # colonnes du Cataclysme à venir : {ability, time_left}
var _surge_left := 0.0                 # Surtension de l'Avatar, tant qu'elle dure
var _surge_charges := 0
var _surge_max := 0
var _surge_damage := 0
var _surge_radius := 0.0
var _wrath := []                       # éclairs de la Colère du ciel à venir : {index, time_left, ability}
var _double_left := 0.0                # le Double du Seigneur du Néant, tant qu'il dure
var _double_delay := 0.25
var _double_ratio := 0.5
var _doubles := []                     # coups de l'ombre à venir : {index, time_left, ability}
var _holes := []                       # trous noirs ouverts : {cell, time_left, tick, ability}
var _legion_left := 0.0                # la Légion du Maître des Légions, tant qu'elle dure
var _legion_ratio := 1.0               # facteur de dégâts de ses créatures
var _legion_cap := 0                   # plafond de créatures pendant la Légion
var _legion_mark := {}                 # {index, left} : la proie marquée
var _eye_locks := {}                   # index -> secondes avant qu'un nouvel œil s'ouvre
var _whirl := {}                       # {left, tick, ability}
var _veil: Ability = null              # les Ailes voilées, tant qu'elles tiennent
var _veil_locks := {}                  # index -> secondes
var _garden := {}                      # {cell, left, tick, ability}
var _garden_locks := {}                # index -> secondes
var _fire_cells := {}                  # case -> secondes de feu restantes
var _fire_tick := 0.0
var _scales: Ability = null            # les Écailles de magma, tant qu'elles tiennent
var _scales_tick := 0.0
var _shadow: Array[Dictionary] = []    # {index, left, first, ability} : les colonnes à venir
var _dragon_cell := Vector2i(-1, -1)   # où il se tenait à la dernière mise à jour
var _traps: Array[Dictionary] = []     # {cell, left, ability} : les cartes pièges au sol
var _doubled_left := 0                 # coups doublés qu'il reste après Pile
var _roulette := {}                    # {left, result, ability}
var _bites := 0                        # bouchées de l'Avide
var _bite_decay := 0.0                 # secondes avant qu'une bouchée fonde
var _gulf := {}                        # {cell, left, pull, ability}
var _feast := {}                       # {left, gap, eaten, heals, ability}
var _flight_left := 0.0


## `p_seed` : la pluie de météores tire au sort ses cases. Le tirage doit être
## REPRODUCTIBLE — sinon la simulation d'équilibrage mesure un ultime différent
## à chaque partie, et deux captures du même sort ne se comparent plus.
func _init(p_grid: MazeGrid, p_stats: CharacterStats, p_health: Health,
		p_seed: int = 0) -> void:
	grid = p_grid
	stats = p_stats
	# Tout ce qui sonne un ennemi passe par ce signal : le Poids des chaînes y lit ce qui ne peut plus fuir.
	enemy_staggered.connect(_note_held)
	health = p_health
	health.plates = maxi(health.plates, stats.base_plates)
	_rng.seed = p_seed if p_seed != 0 else 60611
	if stats.element == Element.Kind.STEEL:
		health.plates = PLATE_MAX
		health.plate_torn.connect(_on_plate_torn)
		health.deflected.connect(func() -> void: _reflect_waiting = _rampart != null)
	if stats.element == Element.Kind.BLADE:
		health.deflected.connect(func() -> void: _parry_pending = _guard != null)
	if stats.element == Element.Kind.EMBER:
		health.plates = PIECES_MAX
		health.plate_torn.connect(func() -> void: _torn_pending += 1)
		for i in PIECES_MAX:
			_pieces.append({"state": Piece.ORBIT, "pos": Vector2.ZERO, "left": 0.0, "timer": 0.0,
				"prey": -1, "hit": {}, "ability": null, "throw": Vector2.ZERO})


# --- Ressources ------------------------------------------------------------------

## Charges restantes, ou -1 si le sort n'en a pas. L'interface s'en sert pour
## afficher « 3/5 » : sans ce compte à l'écran, le joueur ne peut pas savoir
## combien de brasiers il lui reste, et il découvre la recharge par surprise.
func charges_left(ability: Ability) -> int:
	if ability == null or ability.charges <= 1:
		return -1
	if free_use:
		return ability.charges
	return int(_charges.get(ability.id, ability.charges))


func cooldown_left(ability: Ability) -> float:
	if ability == null or free_use:
		return 0.0
	# Tant qu'il reste une charge, le sort est PRÊT : la recharge d'un sort à
	# charges ne court qu'une fois la dernière dépensée.
	if ability.charges > 1 and charges_left(ability) > 0:
		return float(_recover.get(ability.id, 0.0))
	return float(_cooldowns.get(ability.id, 0.0))


func cooldown_ratio(ability: Ability) -> float:
	if ability == null or ability.cooldown <= 0.0:
		return 1.0
	return clampf(1.0 - cooldown_left(ability) / ability.cooldown, 0.0, 1.0)


## Le geste est-il possible MAINTENANT ?
##
## Seule la RECHARGE compte. Le mana a disparu avec la règle « un sort débloqué
## l'est pour toujours » : une compétence n'est plus un consommable, c'est un
## pouvoir. Ce qui reste hors de portée de cette classe : le déblocage (Progress)
## et la charge de l'ultime (KillSystem), que le GameManager consulte à part.
func can_use(ability: Ability) -> bool:
	if ability == null:
		return false
	if not _can_pay(ability):
		return false
	return cooldown_left(ability) <= 0.0


# --- Boucle ----------------------------------------------------------------------

func update(delta: float, context: CombatContext) -> void:
	_record_trail(delta, context)
	_record_health()
	_time_stop_left = maxf(0.0, _time_stop_left - delta)
	_update_hours(delta, context)
	_update_walkers(delta, context)
	_update_hourglass(delta)
	_update_venom(delta, context)
	_update_miasma(delta, context)
	_update_wheel(delta)
	_update_puddles(delta, context)
	_update_light(delta, context)
	_update_death(delta, context)
	_update_stars(delta, context)
	_update_steel(delta, context)
	_update_discord(delta, context)
	_update_king(delta, context)
	_update_blade(delta, context)
	_update_gaoler(delta, context)
	_update_cherubin(delta, context)
	_update_phoenix(delta, context)
	_update_colossus(delta, context)
	_update_tempest(delta, context)
	_update_void(delta, context)
	_update_legion(delta, context)
	if not _leviathan.is_empty():
		_swim_leviathan(delta, context)
	_update_dragon(delta, context)
	_update_croupier(delta, context)
	_update_avide(delta, context)
	_update_archdemon(delta, context)
	_leech_left = maxf(0.0, _leech_left - delta)
	# TEMPS ACCÉLÉRÉ : ses recharges courent plus vite que le monde.
	var spent := delta * (_haste_factor if _haste_left > 0.0 else 1.0)
	for id in _cooldowns.keys():
		var left: float = _cooldowns[id] - spent
		if left <= 0.0:
			_cooldowns.erase(id)
			# La recharge d'un sort à charges les rend TOUTES.
			if _refills.has(id):
				_charges[id] = int(_refills[id])
		else:
			_cooldowns[id] = left
	for id in _recover.keys():
		var gap: float = _recover[id] - spent
		if gap <= 0.0:
			_recover.erase(id)
		else:
			_recover[id] = gap

	_update_projectiles(delta, context)
	_update_summon_projectiles(delta, context)
	_update_summons(delta, context)
	_update_zones(delta, context)
	_update_walls(delta)
	_update_burns(delta, context)
	_update_poisons(delta, context)
	_update_echoes(delta, context)
	_update_meteors(delta, context)
	_update_novas(delta, context)
	_update_morning_star(delta, context)
	_update_harvest(delta, context)
	_update_waves(delta, context)
	_update_lines(delta, context)
	_update_turrets(delta, context)
	_update_quakes(delta, context)
	_update_chains(delta, context)
	_update_storm(delta, context)
	_update_sky(delta, context)
	if _empower_left > 0.0:
		_empower_left = maxf(0.0, _empower_left - delta)
		if _empower_left <= 0.0:
			_empower_bonus = 0
			player_calmed.emit()
	if _flight != null:
		_flight_left = maxf(0.0, _flight_left - delta)
		if _flight_left <= 0.0:
			_land(context)
	if _immune_left > 0.0:
		_immune_left = maxf(0.0, _immune_left - delta)
		if _immune_left <= 0.0:
			health.immune = false
			_rampart = null
			_veil = null
			if _eclipse != null:
				_end_eclipse(_eclipse, context)
			_eclipse = null
			if _bastion != null:
				_open_bastion(_bastion, context)
			_bastion = null
			if _throne_veil != null:
				_open_throne_eyes(_throne_veil, context)
			_throne_veil = null
			_guard = null
			if _pact_owed > 0:
				player_healed.emit(health.heal(_pact_owed))
				_pact_owed = 0
			player_immunity_faded.emit()
	if _shield_left > 0.0:
		_shield_left = maxf(0.0, _shield_left - delta)
		# Il tombe de DEUX façons : l'échéance, ou les coups qui l'ont vidé.
		# Les deux comptent — un bouclier à zéro qui resterait affiché mentirait
		# autant qu'un bouclier éternel.
		if _aegis != null and health.shield < _aegis_seen:
			for _hit in _aegis_seen - health.shield:
				_answer_aegis(context)
		_aegis_seen = health.shield
		if _wings != null and health.shield <= 0 and _shield_left > 0.0:
			_burst_wings(context)
		if _shield_left <= 0.0 or health.shield <= 0:
			# La Bulle des abysses : tenue jusqu'à l'échéance, elle rend ses PV.
			if _shield_left <= 0.0 and health.shield > 0 and _held_heal > 0:
				var healed := health.heal(_held_heal)
				if healed > 0:
					player_healed.emit(healed)
				shield_held.emit(healed)
			_held_heal = 0
			_wings = null
			_aegis = null
			_shield_left = 0.0
			health.shield = 0
			player_shield_faded.emit()
	for index in _stagger_locks.keys():
		var lock: float = _stagger_locks[index] - delta
		if lock <= 0.0:
			_stagger_locks.erase(index)
		else:
			_stagger_locks[index] = lock
	for index in _snare_locks.keys():
		var snare_lock: float = _snare_locks[index] - delta
		if snare_lock <= 0.0:
			_snare_locks.erase(index)
		else:
			_snare_locks[index] = snare_lock


func _update_projectiles(delta: float, context: CombatContext) -> void:
	for i in range(_in_flight.size() - 1, -1, -1):
		_wheel_hit = int(_in_flight[i].get("wheel", -1))
		_in_flight[i]["time_left"] = float(_in_flight[i]["time_left"]) - delta
		if _in_flight[i].has("path"):
			if _fly_free_shot(_in_flight[i], context):
				_in_flight.remove_at(i)
			continue
		if float(_in_flight[i]["time_left"]) > 0.0:
			continue
		var shot: Dictionary = _in_flight[i]
		_in_flight.remove_at(i)
		var index := int(shot["target"])
		var ability: Ability = shot["ability"]
		if not context.enemy_alive(index):
			continue
		var lane: Array = shot.get("lane", [])
		if not lane.is_empty() and context.dodges(index, ability, lane):
			projectile_dodged.emit(ability, index, lane[-1])
			continue
		var cell: Vector2i = context.enemy_cells[index]
		projectile_hit.emit(ability, index, cell)
		# Le Poing impérial laisse ses cendres là où il frappe.
		if _ashes and ability == stats.attack:
			_ignite_cells([cell], ASH_SECONDS)
		# La Bombe de magma met le feu à tout son rayon.
		if ability.ground_fire > 0.0 and ability.radius > 0.0 and ability.kind == Ability.Kind.PROJECTILE:
			_ignite_cells(_floor_within(cell, ability.radius), ability.ground_fire)
		if ability.prey_mark_seconds > 0.0 and not context.is_structure(index):
			_mark_prey(index, ability.prey_mark_seconds)
		# La flamme du Chérubin brûle aussi ce qu'elle a croisé en chemin, une fois chacun.
		if shot.has("line") and ability.line_fire > 0.0:
			_ignite_cells(shot["line"], ability.line_fire)
		if shot.has("line"):
			var line: Array = shot["line"]
			for other in context.enemy_cells.size():
				if other != index and context.enemy_alive(other) and line.has(context.enemy_cells[other]):
					_apply_damage(other, ability, context)
					# Le Croissant d'ouragan rejette ce qu'il traverse.
					_shove(other, ability.pierce_push, context)
			_shove(index, ability.pierce_push, context)
		# La Colonne du ciel cloue ce qu'elle entoure, AVANT ses dégâts : un ennemi qu'elle tue
		# ne doit pas être compté parmi les cloués.
		if ability.column_linger > 0.0:
			_columns.append({"cell": cell, "left": ability.column_linger, "tick": 0.0, "ability": ability})
			column_lingered.emit(cell, ability.column_linger, ability.radius)
		if ability.stun_every > 0:
			_hammer_count += 1
			if _hammer_count % ability.stun_every == 0:
				_stun_within(cell, ability.radius, ability.stun_seconds, context)
				hammer_stunned.emit(cell, ability.radius)
		elif ability.stun_seconds > 0.0:
			_freeze_around(ability, context, cell)
		# Le Soleil captif : une seconde explosion au même endroit, et du magma qui reste.
		if ability.echo_damage > 0:
			_echo_blasts.append({"cell": cell, "time_left": ability.echo_delay, "ability": ability})
		if ability.magma_duration > 0.0:
			_pour_magma(ability, cell)
		# Un projectile à rayon (boule de feu) explose : il touche aussi les
		# voisins. À rayon nul, il ne concerne que sa cible.
		if ability.radius > 0.0:
			_apply_area(ability, cell, context)
		else:
			_apply_damage(index, ability, context)
		if ability.bounces > 0:
			_bounce_from(index, cell, ability, context)
		# L'Orbe du néant s'ouvre en gouffre là où il frappe.
		if ability.impact_pull > 0.0:
			void_opened.emit(cell)
			_pull_toward(cell, 0.0, ability.impact_pull, context)
		# La Grande Convergence se brise en éclats d'élément.
		if ability.element_shards > 0:
			_break_into_shards(cell, ability, context)
		# Le Croissant de l'au-delà revient vers lui, et frappe ce qu'il croise au retour.
		if ability.returns:
			var back := trajectory(cell, context.player_cell)
			if back.size() >= 2:
				var flight := float(back.size() - 1) / (PROJECTILE_SPEED * maxf(0.15, ability.projectile_speed))
				_returns.append({"cells": back, "time_left": flight, "ability": ability})
				crescent_returned.emit(back, flight)
	_wheel_hit = -1


## LE TRIDENT rebondit d'ennemi en ennemi, par les couloirs, en perdant de sa force à chaque saut.
func _bounce_from(first: int, start: Vector2i, ability: Ability, context: CombatContext) -> void:
	var visited := {first: true}
	var from := start
	var damage := float(ability.damage)
	for _jump in ability.bounces:
		var field := _field_from(from)
		var next := -1
		var best := ability.bounce_range + 1
		for i in context.enemy_cells.size():
			if visited.has(i) or not context.enemy_alive(i) or context.is_structure(i):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance >= 0 and distance < best:
				best = distance
				next = i
		if next < 0:
			return
		visited[next] = true
		damage *= ability.bounce_falloff
		var to: Vector2i = context.enemy_cells[next]
		water_bounced.emit(from, to)
		_apply_damage(next, Ability.make({"id": ability.id + "_rebond", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": maxi(1, roundi(damage))}), context, false, true)
		from = to


func _update_zones(delta: float, context: CombatContext) -> void:
	for i in range(_zones.size() - 1, -1, -1):
		var zone: Dictionary = _zones[i]
		zone["time_left"] = float(zone["time_left"]) - delta
		zone["tick"] = float(zone["tick"]) - delta
		if zone.has("path"):
			_walk_zone(zone, delta, context)
		# La Cage électrique de l'Avatar le suit, et l'œil de l'ouragan du Souverain.
		if (zone["ability"] as Ability).zone_follows and zone["cell"] != context.player_cell:
			zone["cell"] = context.player_cell
			zone_moved.emit(int(zone["id"]), context.player_cell)
		# La Couronne des sceaux : chaque sceau garde son point cardinal autour de lui, sans passer les haies.
		if zone.has("orbit"):
			var held := _seal_cell(context.player_cell, zone["orbit"], int(zone["ring"]))
			if held != zone["cell"]:
				zone["cell"] = held
				zone_moved.emit(int(zone["id"]), held)
		# La Porte des abysses fait sortir ses diablotins, tant qu'il y a quelque chose à chasser.
		var gate: Ability = zone["ability"]
		if gate.zone_spawn_every > 0.0:
			zone["spawn"] = float(zone.get("spawn", 0.0)) - delta
			if float(zone["spawn"]) <= 0.0:
				zone["spawn"] = gate.zone_spawn_every
				if not _closest_prey(1, context).is_empty():
					_spawn_summon(gate.summon_id, zone["cell"], gate.zone_spawn_life, gate)
					_trim_summons(context)
					_summon_field_timer = 0.0
		# Le Grand vortex aspire ce qui l'entoure, au rythme des tics.
		var pulling: Ability = zone["ability"]
		if pulling.zone_pull > 0.0 and float(zone["tick"]) <= 0.0:
			_pull_toward(zone["cell"], pulling.radius, pulling.zone_pull, context)
		# L'englu SOUTENU se réarme à CHAQUE frame, pas au tick de la zone : sa
		# traînée est plus courte que l'intervalle des ticks, sans quoi l'ennemi
		# retrouverait son allure deux fois par seconde entre deux passages. Les
		# dégâts, eux, restent sur le tick — c'est une usure, pas une rafale.
		var held: Ability = zone["ability"]
		# LA CATHÉDRALE DE LUMIÈRE lui rend un PV toutes les `zone_heal_every` secondes passées dedans.
		if held.zone_heal_every > 0.0:
			var inside := Pathfinder.value_at(grid, _field_from(zone["cell"]), context.player_cell)
			if inside >= 0 and float(inside) <= held.radius:
				zone["heal"] = float(zone.get("heal", held.zone_heal_every)) - delta
				if float(zone["heal"]) <= 0.0:
					zone["heal"] = held.zone_heal_every
					var healed := health.heal(1)
					if healed > 0:
						player_healed.emit(healed)
					sanctuary_healed.emit(context.player_cell)
		if held.slow_sustained and held.slow_duration > 0.0:
			_apply_chill(held, zone["cell"], context)
		if held.entry_freeze > 0.0:
			_freeze_entrants(zone, context)
		if float(zone["tick"]) <= 0.0:
			zone["tick"] = ZONE_TICK
			# Les dégâts d'une zone sont exprimés PAR SECONDE : on n'en applique
			# que la fraction écoulée, sinon la cadence des ticks changerait la
			# puissance du sort.
			var ability: Ability = zone["ability"]
			var slice := Ability.make({
				"id": ability.id, "kind": ability.kind, "element": ability.element,
				"damage": int(round(ability.damage * ZONE_TICK)), "radius": ability.radius,
			})
			if ability.discord_bonus > 0.0:
				var crowd := _creatures_within(zone["cell"], ability.radius, context)
				zone["members"] = crowd
				slice.damage = int(round(float(slice.damage)
					* (1.0 + ability.discord_bonus * float(maxi(0, crowd.size() - 1)))))
			# NI TRAIT NI EXALTATION, exactement comme un tic de brûlure : une
			# nappe qui ronge n'est pas un coup porté par le mage. C'est une
			# usure, posée une fois et qui travaille toute seule.
			#
			# ⚠️ CE N'EST PAS UN DÉTAIL DE COHÉRENCE, c'est ce qui rend une
			# exaltation dosable. Une zone tique deux fois par seconde : le
			# bonus s'y ajoutait à CHAQUE tic, si bien que +10 valait +20 par
			# seconde et par zone. Les Quatre Sceaux en posent quatre à la
			# fois — l'exaltation y aurait valu +80/s, contre +10 sur un trait
			# élémentaire. Le même bonus ne peut pas valoir huit fois plus
			# selon le sort qui le reçoit.
			if ability.damage > 0:
				_apply_area(slice, zone["cell"], context, ability, true, false)
			if ability.venom_doses > 0:
				_apply_zone_venom(ability, zone["cell"], context)
			if ability.blind_seconds > 0.0:
				_apply_zone_blind(ability, zone["cell"], context)
			if ability.mark_seconds > 0.0:
				_apply_zone_mark(ability, zone["cell"], context)
			if ability.snare > 0.0:
				_apply_snare(ability, zone["cell"], context)
			if ability.slow_duration > 0.0 and not ability.slow_sustained:
				_apply_chill(ability, zone["cell"], context)
			if ability.poison_duration > 0.0:
				_apply_poison(ability, zone["cell"], context)
		if float(zone["time_left"]) <= 0.0:
			_zones.remove_at(i)
			zone_expired.emit(int(zone["id"]))


## La zone qui marche : elle avance d'une case, et EMPORTE ce qu'elle tient.
##
## Les créatures happées sont replacées sur la case de la tornade elle-même.
## C'est brutal, et c'est voulu : une tornade ne traîne pas ses victimes
## derrière elle, elle les tient dedans. Elles ressortent là où elle meurt —
## loin, et en tas.
func _walk_zone(zone: Dictionary, delta: float, context: CombatContext) -> void:
	var path: Array = zone["path"]
	zone["walk"] = float(zone["walk"]) - delta
	if float(zone["walk"]) > 0.0:
		return
	zone["walk"] = float(zone["step"])
	var index := int(zone["index"])
	if index >= path.size():
		# Au bout de sa course, elle s'éteint sans attendre sa durée : une
		# tornade qui tournerait sur place au fond d'un cul-de-sac ne serait
		# plus qu'une zone immobile de plus.
		zone["time_left"] = minf(float(zone["time_left"]), 0.2)
		return
	zone["index"] = index + 1
	var cell: Vector2i = path[index]
	var ability: Ability = zone["ability"]
	if ability.zone_carries:
		var field := Pathfinder.distance_field(grid, [zone["cell"]] as Array[Vector2i])
		for prey in context.enemy_cells.size():
			if not context.enemy_alive(prey) or context.is_structure(prey):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[prey])
			if distance < 0 or float(distance) > ability.radius:
				continue
			context.enemy_cells[prey] = cell
			enemy_pushed.emit(prey, cell)
	zone["cell"] = cell
	zone_moved.emit(int(zone["id"]), cell)


## Le piège du brasier : ce qui entre est RETENU, puis repart en brûlant.
##
## Le verrou couvre l'immobilisation ET la brûlure qui suit, plus une seconde de
## grâce : sans elle, une créature libérée au bord des flammes serait reprise
## dans la foulée et le piège deviendrait une prison à vie.
func _apply_snare(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _snare_locks.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_snare_locks[i] = ability.snare + ability.snare_burn + 1.0
		enemy_staggered.emit(i, ability.snare)
		if ability.snare_burn > 0.0:
			# La brûlure part APRÈS la libération : on la programme, elle ne
			# commence pas pendant que la créature est encore prise.
			_echoes.append({"index": i, "time_left": ability.snare,
				"damage": 0, "ability": ability, "burn": ability.snare_burn})


## Champ de distances depuis une case, mis en cache le temps d'une frame : une
## zone à englu soutenu le redemande à chaque frame, et le recalculer coûterait
## un BFS complet par zone et par frame.
var _field_cache := {}
var _field_frame := -1


func _field_from(centre: Vector2i) -> PackedInt32Array:
	var frame := Engine.get_process_frames()
	if frame != _field_frame:
		_field_frame = frame
		_field_cache.clear()
	if not _field_cache.has(centre):
		_field_cache[centre] = Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	return _field_cache[centre]


func _apply_chill(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	# Le champ passe par le CACHE : un englu soutenu appelle cette fonction à
	# chaque frame, et un BFS complet par zone et par frame se paierait.
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or (context.is_structure(i)
				or (_snare_locks.has(i) and not ability.slow_sustained)):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		if not ability.slow_sustained:
			_snare_locks[i] = ability.slow_duration + 0.5
		enemy_soaked.emit(i, ability.slow_duration, ability.slow_factor)


func _update_walls(delta: float) -> void:
	for i in range(_walls.size() - 1, -1, -1):
		_walls[i]["time_left"] = float(_walls[i]["time_left"]) - delta
		if float(_walls[i]["time_left"]) > 0.0:
			continue
		var cell: Vector2i = _walls[i]["cell"]
		_walls.remove_at(i)
		grid.set_cell(cell.x, cell.y, MazeGrid.Cell.FLOOR)
		wall_fell.emit(cell)


# --- Utilisation d'une compétence ------------------------------------------------

## Bonus de dégâts en cours, 0 quand le mage n'est pas exalté. L'interface s'en
## sert pour afficher les chiffres RÉELS de la barre d'action.
func empower_bonus() -> int:
	return _empower_bonus


func empower_left() -> float:
	return _empower_left


## Absorption restante, pour l'interface. Le joueur doit voir FONDRE sa coque :
## un bouclier qu'on ne voit pas s'user ne se gère pas.
func shield_left() -> int:
	return health.shield if health != null else 0


## Retourne true si la compétence est réellement partie. Sinon AUCUNE ressource
## n'est consommée — rater faute de cible n'est pas une faute du joueur.
func use(ability: Ability, context: CombatContext) -> bool:
	if ability == null:
		return false
	if cooldown_left(ability) > 0.0:
		use_refused.emit("recharge")
		return false
	if not _can_pay(ability):
		use_refused.emit("pacte")
		return false
	if stats.id == "ael" and ability == stats.attack and ability.kind == Ability.Kind.BLAST:
		var target := find_target(ability, context)
		if target >= 0:
			var toward := context.enemy_cells[target] - context.player_cell
			context.player_facing = Vector2i(signi(toward.x), 0) if absi(toward.x) > absi(toward.y) else Vector2i(0, signi(toward.y))
	# LA ROUE : le tir de l'attaque emporte l'élément de l'orbe en tête, puis elle tourne.
	var wheel_shot := ability == stats.attack and _wheel_left > 0.0
	var fired := false
	match ability.kind:
		Ability.Kind.HERO_TRANSFORM:
			if not hero_transform_allowed:
				return false
			_cast_blast(ability, context)
			hero_transformation_requested.emit()
			fired = true
		Ability.Kind.COMET, Ability.Kind.TRANSMISSION:
			fired = _cast_prism_move(ability, context)
		Ability.Kind.PROJECTILE:
			fired = _cast_projectile(ability, context)
		Ability.Kind.BLAST:
			if ability.toll_count > 0:
				_tolls.append({"left": ability.toll_count, "timer": 0.0, "ability": ability})
				fired = true
			else:
				fired = _cast_blast(ability, context)
		Ability.Kind.ZONE:
			fired = _cast_zone(ability, context)
		Ability.Kind.SHIELD:
			# DEUX boucliers dans le jeu, et ils ne se jouent pas pareil. Celui
			# de l'Eau ABSORBE une quantité de dégâts : il tombe quand il est
			# vidé, même avant l'échéance. Celui de la Terre rend INTOUCHABLE :
			# il ne tombe qu'à l'heure dite, quoi qu'il encaisse. C'est la
			# différence entre une réserve et un répit.
			if ability.immune:
				health.immune = true
				_immune_left = ability.duration
				_rampart = ability if ability.reflect_damage > 0 else null
				_veil = ability if ability.repel_cells > 0 else null
				_eclipse = ability if ability.moon_ring_radius > 0.0 else null
				_bastion = ability if ability.bastion_burst_damage > 0 else null
				_throne_veil = ability if ability.veil_eyes_radius > 0.0 else null
				player_made_immune.emit(ability.duration)
			else:
				health.add_shield(ability.damage)
				_shield_left = ability.duration
				_held_heal = ability.heal_if_held
				# L'Égide solaire renvoie chaque coup ; elle n'éclate pas comme les Ailes gardiennes.
				_aegis = ability if ability.aegis_ray_damage > 0 else null
				_aegis_seen = health.shield
				_wings = ability if ability.blind_seconds > 0.0 and _aegis == null else null
				player_shielded.emit(ability.damage, ability.duration)
			fired = true
		Ability.Kind.HEAL:
			player_healed.emit(health.heal(ability.damage))
			fired = true
		Ability.Kind.WALL:
			fired = _cast_wall(ability, context)
		Ability.Kind.BLINK:
			fired = _cast_blink(ability, context)
		Ability.Kind.WAVE:
			fired = _cast_wave(ability, context)
		Ability.Kind.LINE:
			fired = _cast_line(ability, context)
		Ability.Kind.TURRET:
			fired = _cast_turret(ability, context)
		Ability.Kind.CHAIN:
			fired = _cast_chain(ability, context)
		Ability.Kind.STORM:
			fired = _cast_storm(ability, context)
		Ability.Kind.SUMMON:
			fired = _cast_summon(ability, context)
		Ability.Kind.ECHO:
			fired = _cast_echo(ability)
		Ability.Kind.HOURGLASS when ability.rewind_heal_seconds > 0.0:
			_rewind_wounds(ability)
			fired = true
		Ability.Kind.HOURGLASS:
			_hourglass_left = ability.duration
			_hourglass_health = health.current
			_hourglass_ratio = ability.hourglass_ratio
			hourglass_turned.emit(ability.duration)
			fired = true
		Ability.Kind.TIME_STOP:
			_stop_time(ability, context)
			fired = true
		Ability.Kind.TRAIL:
			_seep_left = ability.duration
			_seep_life = ability.trail_life
			_puddle_doses = maxi(1, ability.trail_doses)
			_puddle_slow = ability.trail_slow
			trail_started.emit(ability.duration)
			fired = true
		Ability.Kind.CONTAGION:
			fired = _cast_contagion(ability, context)
		Ability.Kind.TRANSFUSION:
			fired = _cast_transfusion(ability, context)
		Ability.Kind.PANDEMIC:
			_cast_pandemic(ability, context)
			fired = true
		Ability.Kind.CONSTELLATION:
			fired = _cast_constellation(ability, context)
		Ability.Kind.STARFALL:
			fired = _cast_starfall(ability, context)
		Ability.Kind.PACT:
			pact_signed.emit(context.player_cell)
			# Le Pacte écarlate : l'onde de sang part de lui au moment du sacrifice.
			if ability.damage > 0 and ability.radius > 0.0:
				_apply_area(Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST,
					"element": ability.element, "damage": ability.damage, "radius": ability.radius}),
					context.player_cell, context, ability)
			fired = true
		Ability.Kind.POSSESS:
			fired = _cast_possess(ability, context)
		Ability.Kind.BOND:
			fired = _cast_bond(ability, context)
		Ability.Kind.SWAP:
			fired = _cast_swap(ability, context)
		Ability.Kind.HUNTERS:
			fired = _cast_hunters(ability, context)
		Ability.Kind.CHEST:
			fired = _cast_chest(ability, context)
		Ability.Kind.RECALL:
			fired = _cast_recall(ability, context)
		Ability.Kind.CAGES:
			fired = _cast_cages(ability, context)
		Ability.Kind.DASH:
			fired = _cast_dash(ability, context)
		Ability.Kind.GUARD:
			fired = _cast_guard(ability)
		Ability.Kind.SHEATHE:
			fired = _cast_sheathe(ability, context)
		Ability.Kind.HOOK:
			fired = _cast_hook(ability, context)
		Ability.Kind.SOUL_CHAINS:
			fired = _cast_soul_chains(ability, context)
		Ability.Kind.GAOL:
			fired = _cast_gaol(ability, context)
		Ability.Kind.BLADES:
			fired = _rain_feathers(ability, context) if ability.feather_rain > 0 else _cast_blades(ability, context)
		Ability.Kind.ANVIL:
			fired = _cast_anvil(ability, context)
		Ability.Kind.SOULS:
			fired = _cast_souls(ability, context)
		Ability.Kind.LAST_HOUR:
			_cast_last_hour(ability, context)
			fired = true
		Ability.Kind.BEAM:
			fired = _cast_beam(ability, context)
		Ability.Kind.DAWN:
			if ability.sun_seconds > 0.0:
				_cast_sun(ability)
			else:
				_cast_dawn(ability, context)
			fired = true
		Ability.Kind.FLIGHT:
			fired = _cast_flight(ability)
		Ability.Kind.WHIRL:
			fired = _cast_whirl(ability)
		Ability.Kind.PILLARS:
			fired = _cast_pillars(ability, context)
		Ability.Kind.LEVIATHAN:
			fired = _cast_leviathan(ability, context)
		Ability.Kind.WHEELS:
			fired = _cast_wheels(ability, context)
		Ability.Kind.GARDEN:
			fired = _cast_garden(ability, context)
		Ability.Kind.BREATH:
			fired = _cast_breath(ability, context)
		Ability.Kind.BITE:
			fired = _cast_bite(ability, context)
		Ability.Kind.MAGMA_SCALES:
			fired = _cast_scales(ability)
		Ability.Kind.WINGBEAT:
			fired = _cast_wingbeat(ability, context)
		Ability.Kind.DRAGON_SHADOW:
			fired = _cast_dragon_shadow(ability, context)
		Ability.Kind.DICE:
			fired = _cast_dice(ability, context)
		Ability.Kind.TRAP_CARD:
			fired = _cast_trap(ability, context)
		Ability.Kind.COIN:
			fired = _cast_coin(ability)
		Ability.Kind.ROULETTE:
			fired = _cast_roulette(ability, context)
		Ability.Kind.GULF:
			fired = _cast_gulf(ability, context)
		Ability.Kind.DEVOUR:
			fired = _cast_devour(ability, context)
		Ability.Kind.REGURGITATE:
			fired = _cast_regurgitate(ability, context)
		Ability.Kind.LEAP:
			fired = _cast_leap(ability, context)
		Ability.Kind.FEAST:
			fired = _cast_feast(ability)

	# L'EXALTATION EST RENDUE PAR LE SORT, PAS PAR SON GENRE.
	#
	# Ce bloc vivait DANS `_cast_blast`, ce qui marchait tant que le seul sort
	# exaltant du jeu était l'ultime de l'Eau — un souffle. Renaissance est un
	# SOIN : elle portait `empower_bonus: 8` et ne l'a jamais accordé, parce
	# qu'un soin ne passe pas par le souffle. Le sort partait, le soin tombait,
	# et il ne se passait rien d'autre — pas de bonus, donc pas d'aura.
	#
	# `empower_bonus` est une propriété de la COMPÉTENCE. N'importe laquelle
	# peut donc en porter une, et c'est ici, au tronc commun, qu'on la lit.
	if fired and wheel_shot:
		if not _in_flight.is_empty():
			_in_flight[-1]["wheel"] = _wheel_rank
		_turn_wheel()
	if fired and ability.double_echo:
		_double_echo_left = ability.empower_duration
	if fired and ability.eye_seconds > 0.0:
		_open_eye(ability, context)
	if fired and ability.eclipse_seconds > 0.0:
		_fall_eclipse(ability, context)
	if fired and _double_left > 0.0:
		_shadow_repeats(ability, context)
	if fired and ability == stats.attack and _surge_left > 0.0 and _surge_charges >= _surge_max:
		_release_surge(ability, context)
	if fired and ability.empower_bonus > 0 and ability.empower_duration > 0.0:
		# Relancer l'exaltation la REMET à neuf plutôt que de l'additionner :
		# deux lancers coup sur coup ne doivent pas donner +16.
		_empower_bonus = ability.empower_bonus
		_empower_left = ability.empower_duration
		player_empowered.emit(_empower_bonus, _empower_left)
		# LA DÉFENSE VIENT AVEC, quand le sort en porte une. Elle emprunte la
		# coque existante plutôt que d'inventer une seconde mécanique : c'est
		# déjà la façon dont ce jeu dit « il encaisse mieux », l'interface sait
		# l'afficher, et `add_shield` la REMET à neuf au lieu de l'empiler.
		#
		# Elle dure exactement le temps du bonus de dégâts : une exaltation est
		# UN état, pas deux qui s'éteindraient l'un après l'autre.
		if ability.empower_shield > 0:
			health.add_shield(ability.empower_shield)
			_shield_left = ability.empower_duration
			player_shielded.emit(ability.empower_shield, ability.empower_duration)
	if not fired:
		return false
	health.sacrifice(ability.self_cost)
	if not free_use:
		_spend(ability)
	return true


## Ce que coûte un lancer. Un sort ordinaire part en recharge ; un sort à
## charges en consomme une, et n'entre en recharge qu'à la DERNIÈRE.
func _spend(ability: Ability) -> void:
	if ability.charges <= 1:
		_cooldowns[ability.id] = ability.cooldown
		return
	var left := charges_left(ability) - 1
	_charges[ability.id] = left
	_refills[ability.id] = ability.charges
	if left > 0:
		_recover[ability.id] = CHARGE_GAP
	else:
		_cooldowns[ability.id] = ability.cooldown


## Index de l'ennemi qui serait visé, -1 s'il n'y en a aucun à portée.
## Sert aussi à l'interface : elle grise le bouton plutôt que de laisser le
## joueur gaspiller un tir dans le vide.
func find_target(ability: Ability, context: CombatContext) -> int:
	var best := -1
	var best_distance := ability.range + 1 + STRUCTURE_PENALTY
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or _already_targeted(i):
			continue
		var distance := _sky_distance(context.player_cell, context.enemy_cells[i]) \
			if ability.from_sky else Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance < 0 or distance > ability.range:
			continue
		# L'arène a choisi sa cible : à portée, elle passe avant le plus proche.
		if i == context.focus:
			return i
		# Une maison ne poursuit personne. Entre un ennemi sur les talons et un
		# repaire à abattre, c'est TOUJOURS l'ennemi qui prime : on l'obtient en
		# reculant les structures derrière toutes les créatures à portée, sans
		# les rendre inaccessibles pour autant.
		var score := distance + (STRUCTURE_PENALTY if context.is_structure(i) else 0)
		if score < best_distance:
			best_distance = score
			best = i
	return best


## Une cible déjà visée par un projectile en vol n'est pas re-visée : sans cette
## règle, deux orbes partiraient sur un ennemi qui n'en demandait qu'un, pendant
## que son voisin avance tranquillement.
##
## Elle SAUTE en démo. La règle protège d'un tir gaspillé pendant la recharge ;
## sans recharge il n'y a rien à gaspiller, et la refuser rendait le bouton mort
## dès qu'une orbe était en l'air — le joueur appuyait, rien ne partait.
func _already_targeted(index: int) -> bool:
	if free_use:
		return false
	for shot in _in_flight:
		if int(shot["target"]) == index:
			return true
	return false


func _cast_projectile(ability: Ability, context: CombatContext) -> bool:
	# LA VOLÉE DU PHÉNIX : un tir par cible, sur les plus proches, chacune la sienne.
	if ability.volley > 1:
		var targets := _volley_targets(ability, context)
		if targets.is_empty():
			if ability == stats.attack:
				return _cast_free_shot(ability, context)
			use_refused.emit("cible")
			return false
		for prey in targets:
			_launch_at(ability, prey, context)
		return true
	var target := find_target(ability, context)
	if target < 0:
		if ability == stats.attack:
			return _cast_free_shot(ability, context)
		use_refused.emit("cible")
		return false
	# CE QUI TOMBE DU CIEL ne remonte pas le couloir : il part de lui et tombe sur la cible, après
	# le même temps de chute à toute distance. Le chemin n'a donc que ses deux bouts.
	if ability.from_sky:
		_sky_drop(ability, target, context)
		if ability.sky_twin:
			var twin := _sky_neighbour(target, float(ability.range), context)
			if twin >= 0:
				_sky_drop(ability, twin, context)
		return true
	var path := trajectory(context.player_cell, context.enemy_cells[target])
	if path.size() < 2:
		return false
	# La vitesse vient de la COMPÉTENCE : une boule de feu lourde met deux fois
	# plus de temps à arriver qu'une flèche, et ce délai est jouable — l'ennemi
	# a le temps de tourner le coin. La simulation le voit comme le joueur.
	# LA FLAMME DU CHÉRUBIN NE S'ARRÊTE PAS À SA CIBLE : la cible étant la plus proche, personne ne
	# se tient avant elle. Elle continue le long du couloir jusqu'au bout de sa portée, et brûle
	# ceux qui se pressent derrière.
	var lane := path.duplicate()
	if ability.pierce_line and path.size() >= 2:
		path.append_array(_rolling_path(path[-1], path[-1] - path[-2], ability.range - (path.size() - 1)))
	var speed := PROJECTILE_SPEED * maxf(0.15, ability.projectile_speed)
	var duration := float(path.size() - 1) / speed
	var shot := {"ability": ability, "target": target, "time_left": duration, "lane": lane}
	if ability.pierce_line:
		shot["line"] = path
	_in_flight.append(shot)
	projectile_launched.emit(ability, target, path, duration)
	return true


## Les `volley` cibles les plus proches à portée, par les couloirs ; les repaires après les créatures.
func _volley_targets(ability: Ability, context: CombatContext) -> Array[int]:
	var scored: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance < 0 or distance > ability.range:
			continue
		scored.append([distance + (STRUCTURE_PENALTY if context.is_structure(i) else 0), i])
	scored.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	var out: Array[int] = []
	for entry: Array in scored.slice(0, ability.volley):
		out.append(int(entry[1]))
	return out


func _launch_at(ability: Ability, target: int, context: CombatContext) -> void:
	var path := trajectory(context.player_cell, context.enemy_cells[target])
	if path.size() < 2:
		path.append(context.enemy_cells[target])
	# Les Langues voraces : chaque langue de la volée transperce aussi ce qui se tient derrière sa cible.
	var lane := path.duplicate()
	if ability.pierce_line and path.size() >= 2 and path[-1] != path[-2]:
		path.append_array(_rolling_path(path[-1], path[-1] - path[-2], ability.range - (path.size() - 1)))
	var speed := PROJECTILE_SPEED * maxf(0.15, ability.projectile_speed)
	var duration := float(path.size() - 1) / speed
	var shot := {"ability": ability, "target": target, "time_left": duration, "lane": lane}
	if ability.pierce_line:
		shot["line"] = path
	_in_flight.append(shot)
	projectile_launched.emit(ability, target, path, duration)


## Personne à viser : l'attaque de base part quand même, droit devant le mage, jusqu'à
## la première haie ou au bout de sa portée. Elle frappe ce qu'elle croise en chemin.
## Son numéro est négatif : il ne désigne aucun ennemi, seulement le tir en vol.
func _cast_free_shot(ability: Ability, context: CombatContext) -> bool:
	var path: Array[Vector2i] = [context.player_cell]
	while path.size() <= ability.range and grid.is_floor_v(path[-1] + context.player_facing):
		path.append(path[-1] + context.player_facing)
	var landing: Vector2i = path[-1]
	# Collé à une haie, le tir s'y écrase : le geste reste visible.
	if path.size() < 2:
		path.append(landing + context.player_facing)
	var speed := PROJECTILE_SPEED * maxf(0.15, ability.projectile_speed)
	var duration := float(path.size() - 1) / speed
	# Ce qui tombe du ciel tombe d'un coup au bout de sa course, sans la parcourir.
	if ability.from_sky:
		path = [context.player_cell, landing]
		duration = ability.sky_fall
	_last_free_shot -= 1
	_in_flight.append({"ability": ability, "target": _last_free_shot, "time_left": duration,
		"duration": duration, "path": path, "landing": landing, "from": 0})
	projectile_launched.emit(ability, _last_free_shot, path, duration)
	return true


## Avance un tir libre, et dit s'il est fini. La case où il se trouve est relue à chaque
## image : un ennemi qui y entre après lui se fait quand même toucher.
func _fly_free_shot(shot: Dictionary, context: CombatContext) -> bool:
	var ability: Ability = shot["ability"]
	# Ce qui tombe du ciel ne frappe qu'en touchant le sol, pas à mi-chute.
	if ability.from_sky and float(shot["time_left"]) > 0.0:
		return false
	var path: Array[Vector2i] = shot["path"]
	var left := maxf(0.0, float(shot["time_left"]))
	var reached := roundi((1.0 - left / float(shot["duration"])) * (path.size() - 1))
	for step in range(int(shot["from"]), reached + 1):
		for index in context.enemy_cells.size():
			if context.enemy_alive(index) and context.enemy_cells[index] == path[step]:
				projectile_hit.emit(ability, int(shot["target"]), path[step])
				if ability.radius > 0.0:
					_apply_area(ability, path[step], context)
				else:
					_apply_damage(index, ability, context)
				return true
	shot["from"] = reached
	if left > 0.0:
		return false
	projectile_hit.emit(ability, int(shot["target"]), path[-1])
	if ability.radius > 0.0:
		_apply_area(ability, shot["landing"], context)
	return true


func _cast_blast(ability: Ability, context: CombatContext) -> bool:
	if ability.hole_seconds > 0.0:
		return _open_hole(ability, context)
	if ability.stun_seconds > 0.0:
		_freeze_around(ability, context)
	# L'Hiver de l'Abîme laisse une plaque de givre qui ralentit tant qu'on s'y tient.
	if ability.frost_seconds > 0.0:
		_cast_zone(Ability.make({"id": ability.id + "_givre", "display_name": ability.display_name,
			"kind": Ability.Kind.ZONE, "element": ability.element, "damage": 0,
			"radius": ability.radius, "duration": ability.frost_seconds,
			"slow_factor": ability.slow_factor, "slow_duration": 0.6, "slow_sustained": true,
			"zone_style": "givre_abime"}), context)
	blast_fired.emit(ability, context.player_cell)
	if ability.follow_wave > 0:
		var wave := ability.duplicate() as Ability
		wave.kind = Ability.Kind.WAVE
		wave.range = ability.follow_wave
		wave.damage = maxi(1, ability.damage / 3)
		wave.follow_wave = 0
		_cast_wave(wave, context)
	# L'ASPIRATION PASSE AVANT LES DÉGÂTS, sinon elle ne sert à rien : ce qu'elle
	# ramène doit encore trouver l'explosion en arrivant.
	if ability.pull_radius > 0.0:
		_haul_in(ability, context)
	_blast_hits = 0
	# Un sort qui PROJETTE ne déclenche pas la poussée de son élément : les deux
	# s'additionneraient, et la course réelle ne serait plus celle qu'annonce le
	# sort. Voir l'en-tête de `_apply_area`.
	_apply_area(ability, context.player_cell, context, null,
		ability.blow_cells <= 0)
	# LE SOUFFLE PROJETTE, APRÈS les dégâts.
	#
	# Avant, il enverrait ses victimes hors du rayon de l'explosion et le sort
	# ne blesserait plus personne. C'est l'ordre inverse de l'aspiration de
	# l'Ombre, et pour la même raison.
	if ability.blow_cells > 0:
		_blow_away(ability, context)
	# L'OMBRE RESTE APRÈS LE COUP. Posée ici et non dans `_cast_zone` : c'est une
	# conséquence de l'explosion, pas un sort de zone déguisé — et elle doit
	# naître APRÈS `_apply_area`, sinon la créature qui vient d'être ramenée
	# serait empoisonnée avant d'avoir encaissé.
	if ability.residue_duration > 0.0:
		var residue := _residue_of(ability)
		var id := _next_zone_id
		_next_zone_id += 1
		_zones.append({"id": id, "ability": residue, "cell": context.player_cell,
			"time_left": residue.duration, "tick": 0.0})
		zone_created.emit(id, residue, context.player_cell)
	if ability.rain_count > 0:
		_summon_rain(ability, context)
		if ability.great_sword_damage > 0:
			_great_swords.append({"cell": context.player_cell, "warned": false, "ability": ability,
				"time_left": ability.rain_delay + ability.rain_duration + ability.rain_fall + GREAT_SWORD_PAUSE})
	# LES GEYSERS, tous en même temps et au hasard du labyrinthe.
	if ability.geyser_count > 0:
		var floor_cells := grid.all_floor_cells()
		var seen := {}
		for i in ability.geyser_count:
			if floor_cells.is_empty():
				break
			var cell: Vector2i = floor_cells[_rng.randi_range(0, floor_cells.size() - 1)]
			# Deux geysers sur la même case seraient un seul geyser qui frappe
			# deux fois : on tire jusqu'à trouver une case libre, sans insister.
			if seen.has(cell):
				continue
			seen[cell] = true
			geyser_erupted.emit(cell, ability)
			_apply_area(Ability.make({
				"id": ability.id, "kind": Ability.Kind.BLAST,
				"element": ability.element, "damage": ability.geyser_damage,
				"radius": ability.geyser_radius,
			}), cell, context, ability)
	# LE SÉISME ATTEND LA PREMIÈRE MÉTÉORE. Déclenché au lancement, il tremblait
	# pendant que le ciel était encore vide : le joueur sentait la secousse avant
	# d'en voir la cause, et les deux ne se reliaient plus. C'est l'IMPACT qui
	# ébranle le sol, donc c'est lui qui l'ouvre.
	#
	# Seules les pluies qui VISENT attendent : une éruption volcanique tremble
	# dès le départ, et c'est très bien — elle n'a pas de première météore, elle
	# en a quatorze qui tombent n'importe où.
	if ability.quake_duration > 0.0 and not (ability.rain_hunts and ability.rain_count > 0):
		_start_quake(ability)
	if ability.sky_clouds > 0:
		_gather_sky(ability)
	if ability.wrath_damage > 0:
		_summon_wrath(ability, context)
	if ability.heal_self > 0 and (not ability.heal_needs_hit or _blast_hits > 0):
		var owed := mini(ability.heal_self, _blast_hits) if ability.heal_per_hit else ability.heal_self
		var gained := health.heal(owed)
		if gained > 0:
			player_healed.emit(gained)
	if ability.molten_seconds > 0.0:
		_molten_left = ability.molten_seconds
		_molten_steps = ability.molten_steps_seconds
		health.plates = plate_cap()
		plates_changed.emit(health.plates)
		molten_started.emit(ability.molten_seconds)
	if ability.last_pact_seconds > 0.0:
		_pact_owed = ceili(health.sacrifice(health.current - 1) * ability.last_pact_return)
		health.immune = true
		_immune_left = ability.last_pact_seconds
		player_made_immune.emit(ability.last_pact_seconds)
		if ability.pact_claw_damage > 0:
			_claw_ability = ability
			_claw_timer = ability.pact_claw_gap * 0.5
	return true


## La pluie de météores. Les cases sont tirées au sort parmi les praticables, et
## les délais étalés sur toute la durée : tombées ensemble, douze météores
## feraient un seul gros dégât et pas une pluie.
func _summon_rain(ability: Ability, context: CombatContext) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	# LA PLUIE QUI VISE. Les cibles sont les ennemis VIVANTS, prises à tour de
	# rôle : le nombre de météores étant fixe, moins il en reste, plus chacun en
	# reçoit. Deux poursuivants sous six météores chacun, c'est un jugement ;
	# douze météores éparpillées sur un labyrinthe vide, c'est un feu d'artifice.
	#
	# Repli sur le tirage au sort quand il n'y a personne : l'ultime doit partir
	# même lancé dans le vide, sinon le joueur perd ses huit kills sans rien voir.
	var hunted: Array[Vector2i] = []
	if ability.rain_hunts:
		# Les STRUCTURES vivent dans les mêmes tableaux que les ennemis (voir
		# CombatContext) : une maison de repaire ne se poursuit pas du ciel, on
		# s'arrête donc là où les ennemis s'arrêtent.
		var last := context.structures_from if context.structures_from >= 0 \
			else context.enemy_cells.size()
		for i in mini(last, context.enemy_cells.size()):
			if context.enemy_health[i].is_alive():
				hunted.append(context.enemy_cells[i])
	# LE GESTE D'ABORD, LE CIEL ENSUITE. Tous les instants de chute sont décalés
	# de la durée de l'incantation : la première pierre part quand le mage a fini
	# de lever les éléments, pas pendant. Le séisme suit tout seul — il s'ouvre
	# au premier impact, donc il attend avec elles.
	if ability.rain_delay > 0.0:
		incantation_cast.emit(context.player_cell, ability)
	for i in ability.rain_count:
		var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		if not hunted.is_empty():
			cell = hunted[i % hunted.size()]
		# UNE PAR UNE, et non toutes ensemble. Les deux pluies existantes tirent
		# leurs délais au hasard : c'est ce qui convient à une averse, où
		# l'important est qu'il en tombe partout. Celle-ci DÉSIGNE ses cibles —
		# elle doit donc s'égrener, pour qu'on voie chaque météore partir, tomber
		# et frapper avant que la suivante ne s'annonce.
		var when := float(i) * ability.rain_duration / float(maxi(1, ability.rain_count)) \
			if ability.rain_hunts else _rng.randf_range(0.0, ability.rain_duration)
		var fall := ability.rain_delay + when + ability.rain_fall
		var meteor := {"cell": cell, "time_left": fall, "ability": ability}
		# LA GENÈSE : chaque météore prend l'élément suivant de la roue.
		if ability.rain_elements:
			meteor["rank"] = i % SEAL_ORDER.size()
		# LA PLUIE QUI VISE CHOISIT SA PROIE AU DÉPART, pas au lancement : la dernière météore part plusieurs
		# secondes après le geste, et les ennemis ont bougé. Elle est annoncée quand elle commence à tomber.
		if ability.rain_hunts:
			meteor["turn"] = i
			_meteors.append(meteor)
			continue
		_meteors.append(meteor)
		meteor_incoming.emit(cell, fall, ability)
	if ability.nova_damage > 0:
		_novas.append({"ability": ability, "time_left": ability.rain_delay
			+ ability.rain_duration + ability.rain_fall + NOVA_PAUSE})


## Ouvre le séisme d'un sort. Sorti de `_cast_blast` parce qu'il n'y part plus
## toujours : la pluie qui vise le déclenche à son premier impact.
func _start_quake(ability: Ability) -> void:
	if ability.quake_duration <= 0.0:
		return
	for quake in _quakes:
		if quake["ability"] != ability:
			continue
		# CHAQUE MÉTÉORE SECOUE À NOUVEAU. Le séisme n'est pas EMPILÉ — douze
		# séismes superposés multiplieraient par douze les dégâts de tremblement —
		# il est REMIS À NEUF : sa durée repart de zéro et la secousse d'écran
		# reprend à pleine amplitude. On sent donc un coup par impact, et le sol
		# ne s'apaise jamais tant qu'il en tombe.
		quake["time_left"] = ability.quake_duration
		quake_started.emit(ability.quake_duration, ability)
		return
	# LE CATACLYSME du Colosse : les colonnes de lave jaillissent une à une pendant le séisme.
	for k in ability.lava_columns:
		_lava.append({"ability": ability, "time_left": LAVA_DELAY
			+ ability.quake_duration * 0.85 * float(k) / float(ability.lava_columns)})
	_quakes.append({
		"ability": ability, "time_left": ability.quake_duration, "tick": 0.0,
	})
	quake_started.emit(ability.quake_duration, ability)


func _update_meteors(delta: float, context: CombatContext) -> void:
	for i in range(_meteors.size() - 1, -1, -1):
		_meteors[i]["time_left"] = float(_meteors[i]["time_left"]) - delta
		if _meteors[i].has("turn") and float(_meteors[i]["time_left"]) <= (_meteors[i]["ability"] as Ability).rain_fall:
			_aim_meteor(_meteors[i], context)
		# Elle suit sa proie jusqu'au sol ; morte en route, elle tombe là où celle-ci est tombée.
		var prey := int(_meteors[i].get("target", -1))
		if context.enemy_alive(prey) and prey < context.enemy_cells.size():
			_meteors[i]["cell"] = context.enemy_cells[prey]
		if float(_meteors[i]["time_left"]) > 0.0:
			continue
		var meteor: Dictionary = _meteors[i]
		_meteors.remove_at(i)
		var source: Ability = meteor["ability"]
		var cell: Vector2i = meteor["cell"]
		# LA PREMIÈRE QUI TOUCHE OUVRE LE SÉISME. Les onze suivantes retombent
		# sur un sol déjà en train de trembler.
		if source.rain_hunts:
			_start_quake(source)
		# Chaque météore est une petite explosion à part entière : mêmes règles
		# de rayon que n'importe quel sort de zone, avec ses propres chiffres.
		var strike := Ability.make({
			"id": source.id + "_meteore", "display_name": "Météore",
			"kind": Ability.Kind.BLAST, "element": source.element,
			"damage": source.rain_damage, "radius": source.rain_radius,
			"is_ultimate": true,
		})
		if meteor.has("rank"):
			strike.element = rank_element(int(meteor["rank"]))
			element_meteor_struck.emit(cell, int(meteor["rank"]), source.rain_radius)
		meteor_landed.emit(cell, source)
		_apply_area(strike, cell, context)


## Une météore de la pluie qui vise part : elle prend pour proie, à tour de rôle, les ennemis VIVANTS à cet
## instant, du plus proche du mage au plus loin. Le nombre de météores étant fixe, moins il en reste, plus chacun
## en reçoit. Personne : elle tombe près du mage, pour que l'ultime se voie.
## Le champ visible autour du mage, en cases de chaque côté (la vue fait environ 40 x 22).
const HUNT_VIEW := Vector2i(12, 7)


func _aim_meteor(meteor: Dictionary, context: CombatContext) -> void:
	var turn := int(meteor["turn"])
	meteor.erase("turn")
	var source: Ability = meteor["ability"]
	var last := context.structures_from if context.structures_from >= 0 else context.enemy_cells.size()
	# Ceux qu'on VOIT d'abord : une météore sur un ennemi hors de l'écran est une météore perdue pour le joueur.
	var alive: Array = []
	var far: Array = []
	for i in mini(last, context.enemy_cells.size()):
		if context.enemy_alive(i):
			var offset := context.enemy_cells[i] - context.player_cell
			var entry := [offset.length_squared(), i]
			if absi(offset.x) <= HUNT_VIEW.x and absi(offset.y) <= HUNT_VIEW.y:
				alive.append(entry)
			else:
				far.append(entry)
	if alive.is_empty():
		alive = far
	alive.sort_custom(func(a: Array, b: Array) -> bool:
		return int(a[0]) < int(b[0]) or (int(a[0]) == int(b[0]) and int(a[1]) < int(b[1])))
	var index := -1
	if not alive.is_empty():
		index = int(alive[turn % alive.size()][1])
		meteor["target"] = index
		meteor["cell"] = context.enemy_cells[index]
	else:
		var near: Array[Vector2i] = []
		for cell in grid.all_floor_cells():
			if absi(cell.x - context.player_cell.x) <= 8 and absi(cell.y - context.player_cell.y) <= 5:
				near.append(cell)
		if not near.is_empty():
			meteor["cell"] = near[_rng.randi_range(0, near.size() - 1)]
	meteor_incoming.emit(meteor["cell"], maxf(0.0, float(meteor["time_left"])), source)
	if index >= 0:
		meteor_aimed.emit(index)


## LES QUATRE SCEAUX du Sorcier Suprême, dans l'ordre où ils se posent.
##
## L'élément est ATTACHÉ à la direction, et il ne change jamais : c'est ce qui
## rend le sort jouable. Un joueur qui a appris que le feu part à droite pose ses
## sceaux en sachant lequel gardera quel couloir ; des éléments tirés au hasard
## en feraient une loterie décorative.
const SEAL_ORDER := [
	{"step": Vector2i.RIGHT, "element": Element.Kind.FIRE},
	{"step": Vector2i.DOWN, "element": Element.Kind.WATER},
	{"step": Vector2i.LEFT, "element": Element.Kind.EARTH},
	{"step": Vector2i.UP, "element": Element.Kind.AIR},
]


## Un sceau, dérivé du sort de base : même durée, même rayon, mais l'effet de SON
## élément. Les quatre se partagent les dégâts du sort — c'est un contrôle de
## terrain, pas quatre fois la même zone.
##
## Chaque élément garde ici le trait qu'il a partout ailleurs dans le jeu, et
## c'est la seule règle qui compte : le joueur n'a rien de neuf à apprendre.
##   FEU    brûle — les dégâts les plus lourds, et ça continue après la sortie
##   EAU    trempe — ralentit tant qu'on reste dessus
##   TERRE  ébranle — arrête net, une fois par passage
##   AIR    bourrasque — le plus large, mais le moins mordant
func _seal_of(base: Ability, element: Element.Kind) -> Ability:
	var seal := {
		"id": base.id + "_seal", "kind": Ability.Kind.ZONE, "element": element,
		"display_name": base.display_name,
		"damage": base.damage, "radius": base.radius, "duration": base.duration,
		# ⚠️ LE STYLE SE RECOPIE. Les quatre sceaux sont fabriqués depuis un
		# dictionnaire, pas clonés : tout ce qu'on n'écrit pas ici retombe à sa
		# valeur par défaut. L'oublier a fait poser quatre zones ORDINAIRES —
		# le dessin du sceau ne sortait pas, et on ne voyait que les anneaux
		# tracés en code.
		"zone_style": base.zone_style,
	}
	match element:
		Element.Kind.FIRE:
			seal["damage"] = int(round(base.damage * 1.35))
			seal["poison_duration"] = 3.0
		Element.Kind.WATER:
			seal["slow_duration"] = 2.0
			seal["slow_sustained"] = true
		Element.Kind.EARTH:
			seal["snare"] = 0.9
		Element.Kind.AIR:
			seal["damage"] = int(round(base.damage * 0.7))
			seal["radius"] = base.radius * 1.35
	return Ability.make(seal)


## Écart minimal entre deux sceaux, en cases.
##
## C'est le DIAMÈTRE d'un sceau plus une marge. Deux cercles qui se touchent se
## lisent comme une seule flaque, et tout l'intérêt du sort — savoir quel élément
## garde quel passage — disparaît avec eux.
const SEAL_SPACING := 3
## Au-delà de deux voisins libres, le mage n'est plus dans un couloir.
const SEAL_OPEN_SIDES := 3


## Où tombe un sceau autour du mage : la case libre la plus LOIN dans sa
## direction, sans dépasser l'anneau demandé. `player_cell` si tout est bouché,
## ce que l'appelant écarte.
func _seal_cell(origin: Vector2i, step: Vector2i, ring: int) -> Vector2i:
	var cell := origin
	for _i in maxi(1, ring):
		var next: Vector2i = cell + step
		if not grid.is_floor_v(next):
			break
		cell = next
	return cell


## LE CARREFOUR : un sceau par point cardinal, en couronne.
##
## Une direction bouchée est ABANDONNÉE plutôt que rabattue sur le mage : un
## sceau replié sur la case centrale chevaucherait les trois autres, et on
## perdrait la lecture qu'on cherche justement à obtenir.
func _seal_ring_cells(ability: Ability, context: CombatContext) -> Array:
	var out: Array = []
	for entry in SEAL_ORDER:
		var cell := _seal_cell(context.player_cell, entry["step"], ability.seal_ring)
		out.append(cell if cell != context.player_cell else null)
	return out


## LE COULOIR : les quatre sceaux en enfilade DEVANT le mage, espacés.
##
## Dans un couloir d'une case — c'est-à-dire presque partout dans ce labyrinthe —
## deux des quatre directions sont des haies, et la couronne s'effondrait sur
## elle-même. Le sort devient alors un BALAYAGE : il grave le passage sur toute
## sa longueur, ce qui est exactement ce qu'on veut d'un sort de terrain dans un
## couloir.
##
## Le chemin suit les VIRAGES (`_corridor_ahead`), donc le balayage tourne avec
## le couloir au lieu de s'arrêter au premier coude. Et s'il n'y a pas assez de
## place devant, il se poursuit DERRIÈRE : le mage se retrouve encadré plutôt que
## de perdre la moitié de son sort.
func _seal_sweep_cells(_ability: Ability, context: CombatContext) -> Array:
	var reach := SEAL_SPACING * SEAL_ORDER.size()
	var out: Array = []
	for facing in [context.player_facing, -context.player_facing]:
		if facing == Vector2i.ZERO:
			continue
		var path := _corridor_ahead(context.player_cell, facing, reach)
		var index := 1
		while out.size() < SEAL_ORDER.size() and index < path.size():
			out.append(path[index])
			index += SEAL_SPACING
	while out.size() < SEAL_ORDER.size():
		out.append(null)
	return out


func _cast_seals(ability: Ability, context: CombatContext) -> bool:
	seals_cast.emit(context.player_cell)
	var sides := 0
	for entry in SEAL_ORDER:
		if grid.is_floor_v(context.player_cell + entry["step"]):
			sides += 1
	var cells: Array = _seal_ring_cells(ability, context) \
		if sides >= SEAL_OPEN_SIDES or ability.seals_follow else _seal_sweep_cells(ability, context)

	var planted := 0
	for rank in SEAL_ORDER.size():
		var cell: Variant = cells[rank] if rank < cells.size() else null
		# LA COURONNE garde ses quatre sceaux : bouché, un sceau se serre contre lui au lieu de disparaître.
		if cell == null and ability.seals_follow:
			cell = context.player_cell
		if cell == null:
			continue
		var id := _next_zone_id
		_next_zone_id += 1
		var seal := _seal_of(ability, SEAL_ORDER[rank]["element"])
		var placed := {"id": id, "ability": seal, "cell": cell,
			"time_left": seal.duration, "tick": 0.0}
		if ability.seals_follow:
			placed["orbit"] = SEAL_ORDER[rank]["step"]
			placed["ring"] = ability.seal_ring
		_zones.append(placed)
		zone_created.emit(id, seal, cell)
		planted += 1
	return planted > 0


func _cast_zone(ability: Ability, context: CombatContext) -> bool:
	if ability.seal_ring > 0:
		return _cast_seals(ability, context)
	var centre := context.player_cell
	if ability.zone_on_prey:
		var prey := find_target(ability, context)
		if prey < 0 or context.is_structure(prey):
			use_refused.emit("cible")
			return false
		centre = context.enemy_cells[prey]
	var id := _next_zone_id
	_next_zone_id += 1
	var zone := {
		"id": id, "ability": ability, "cell": centre,
		"time_left": ability.duration, "tick": 0.0,
	}
	# LA TORNADE REMONTE LE COULOIR. Le chemin est calculé D'UN COUP au
	# lancement, virages compris — recalculé en route, elle changerait d'avis à
	# chaque carrefour et le joueur ne pourrait plus prévoir où elle emmène ses
	# poursuivants.
	if ability.zone_travel > 0.0:
		var reach := ability.range if ability.range > 0 else 7
		zone["path"] = _corridor_ahead(context.player_cell,
			context.player_facing, reach)
		zone["step"] = 1.0 / maxf(0.1, ability.zone_travel)
		zone["walk"] = float(zone["step"])
		zone["index"] = 0
	_zones.append(zone)
	zone_created.emit(id, ability, centre)
	return true


## Le mur se dresse DERRIÈRE le mage, jamais devant : un joueur qui se mure la
## route et meurt le nez contre sa propre pierre ne comprendrait pas.
func _cast_wall(ability: Ability, context: CombatContext) -> bool:
	var cell: Vector2i = context.player_cell - context.player_facing
	if not grid.is_floor_v(cell) or grid.is_occupied(cell):
		use_refused.emit("place")
		return false
	grid.set_cell(cell.x, cell.y, MazeGrid.Cell.WALL)
	_walls.append({"cell": cell, "time_left": ability.duration})
	wall_raised.emit(cell)
	return true


## LE JUGEMENT CÉLESTE : des nuages se forment un peu partout et restent.
##
## Ils sont posés AU HASARD sur les cases praticables, comme la pluie du Feu —
## mais là où une météore tombe une fois et disparaît, un nuage s'installe et
## frappe tant qu'il est là. C'est la différence entre une averse et un ciel
## d'orage.
##
## Leurs instants de première décharge sont ÉTALÉS : formés en même temps, ils
## frapperaient tous à l'unisson et le ciel entier clignoterait au même rythme.
func _gather_sky(ability: Ability) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	for i in ability.sky_clouds:
		var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
		_sky.append({
			"cell": cell, "ability": ability,
			"time_left": ability.sky_duration,
			"timer": _rng.randf_range(0.0, ability.sky_interval),
		})
		sky_cloud_formed.emit(cell, ability.sky_duration, ability)


func _update_sky(delta: float, context: CombatContext) -> void:
	for i in range(_sky.size() - 1, -1, -1):
		var cloud: Dictionary = _sky[i]
		cloud["time_left"] = float(cloud["time_left"]) - delta
		if float(cloud["time_left"]) <= 0.0:
			var gone: Vector2i = cloud["cell"]
			_sky.remove_at(i)
			sky_cloud_faded.emit(gone)
			continue
		cloud["timer"] = float(cloud["timer"]) - delta
		if float(cloud["timer"]) > 0.0:
			continue
		var ability: Ability = cloud["ability"]
		cloud["timer"] = ability.sky_interval

		# Chaque nuage ne voit que SOUS lui : c'est ce qui fait du Jugement un
		# ciel et non une frappe téléguidée. Un ennemi qui reste à découvert est
		# puni, un ennemi qui bouge peut passer entre les nuages.
		var centre: Vector2i = cloud["cell"]
		var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
		var best := -1
		var best_distance := ability.sky_reach + 1
		for j in context.enemy_cells.size():
			if not context.enemy_alive(j) or context.is_structure(j):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[j])
			if distance >= 0 and distance < best_distance:
				best_distance = distance
				best = j
		if best < 0:
			continue
		sky_bolt.emit(centre, best, ability)
		var strike := Ability.make({
			"id": ability.id + "_foudre", "display_name": ability.display_name,
			"kind": Ability.Kind.PROJECTILE, "element": ability.element,
			"damage": maxi(1, int(round(float(ability.damage) * 0.18))),
			"is_ultimate": true,
		})
		# Coup d'origine : chaque frappe du ciel peut donc rebondir sur un
		# voisin, comme tout ce que lance ce mage.
		_apply_damage(best, strike, context)


## L'ORAGE : un nuage qui suit le mage et foudroie tout seul.
##
## Relancer l'orage le REMET à neuf plutôt que d'en ouvrir un second : deux
## nuages superposés doubleraient la cadence sans que rien ne le montre à
## l'écran, et le joueur ne comprendrait pas pourquoi sa deuxième invocation
## semble plus forte que la première.
func _cast_storm(ability: Ability, context: CombatContext) -> bool:
	_storm = {
		"ability": ability, "time_left": ability.duration,
		# La première décharge tombe TOUT DE SUITE : un sort qui ne fait rien
		# pendant sa première seconde se lit comme un sort raté.
		"timer": 0.0,
	}
	storm_gathered.emit(ability, ability.duration)
	return true


func _update_storm(delta: float, context: CombatContext) -> void:
	if _storm.is_empty():
		return
	var ability: Ability = _storm["ability"]
	_storm["time_left"] = float(_storm["time_left"]) - delta
	if float(_storm["time_left"]) <= 0.0:
		_storm.clear()
		storm_dispersed.emit()
		return

	_storm["timer"] = float(_storm["timer"]) - delta
	if float(_storm["timer"]) > 0.0:
		return
	_storm["timer"] = ability.storm_interval

	# La cible est la plus proche DU MAGE : le nuage est au-dessus de lui et
	# frappe ce qui l'entoure. Un orage qui bombarderait la carte entière ne
	# récompenserait plus le fait de rester mobile — il jouerait tout seul.
	# L'Œil du cyclone de l'Avatar a trois nuages : chacun frappe sa cible, les plus proches d'abord.
	var scored: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance <= ability.storm_range:
			scored.append([distance, i])
	if scored.is_empty():
		return
	scored.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	for entry: Array in scored.slice(0, maxi(1, ability.storm_clouds)):
		var best := int(entry[1])
		storm_struck.emit(best, ability)
		# La décharge est un coup À PART ENTIÈRE : elle déclenche donc le trait de
		# l'élément, et chaque éclair peut rebondir sur un voisin. C'est ce qui rend
		# l'orage redoutable au milieu d'un groupe, et anodin sur un isolé.
		_apply_damage(best, ability, context)


## LA CHAÎNE D'ÉCLAIRS : elle saute d'une créature à l'autre, de proche en
## proche, en s'épuisant à chaque relais.
##
## Le parcours est calculé D'UN COUP au lancement, puis joué relais par relais.
## Le recalculer à chaque saut aurait laissé les ennemis bouger entre-temps : la
## chaîne aurait pu revenir en arrière ou changer d'avis en vol, ce qu'un éclair
## ne fait pas. Ici le trajet est décidé à l'instant du tir, et il s'accomplit.
##
## Chaque créature n'est touchée QU'UNE FOIS : sans cette mémoire, la chaîne
## ferait des allers-retours entre deux ennemis voisins jusqu'à épuisement du
## compteur de sauts.
func _cast_chain(ability: Ability, context: CombatContext) -> bool:
	var first := find_target(ability, context)
	if first < 0:
		use_refused.emit("cible")
		return false

	var hops: Array[int] = [first]
	var visited := {first: true}
	var current := first
	for jump in ability.chain_jumps:
		var next := _nearest_unvisited(current, visited, ability.chain_range, context)
		if next < 0:
			break
		visited[next] = true
		hops.append(next)
		current = next

	_chains.append({
		"ability": ability, "hops": hops, "index": 0, "timer": 0.0,
	})
	return true


## Créature vivante la plus proche de `origin` qui n'a pas encore été touchée.
## La distance se mesure en CHEMIN : la foudre suit les couloirs comme tout le
## reste du jeu — un arc qui traverserait une haie serait le privilège d'un
## ultime, pas d'un sort de rang 1.
func _nearest_unvisited(origin: int, visited: Dictionary, reach: int,
		context: CombatContext) -> int:
	var field := Pathfinder.distance_field(grid,
		[context.enemy_cells[origin]] as Array[Vector2i])
	var best := -1
	var best_distance := reach + 1
	for i in context.enemy_cells.size():
		if visited.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	return best


func _update_chains(delta: float, context: CombatContext) -> void:
	for i in range(_chains.size() - 1, -1, -1):
		var chain: Dictionary = _chains[i]
		chain["timer"] = float(chain["timer"]) - delta
		if float(chain["timer"]) > 0.0:
			continue
		var ability: Ability = chain["ability"]
		var hops: Array = chain["hops"]
		var index := int(chain["index"])
		if index >= hops.size():
			_chains.remove_at(i)
			continue
		chain["index"] = index + 1
		chain["timer"] = ability.chain_delay

		var target := int(hops[index])
		# Le trait part du mage pour le premier relais, de la victime
		# précédente pour les suivants.
		chain_arced.emit(int(hops[index - 1]) if index > 0 else -1, target)
		if not context.enemy_alive(target):
			continue
		# La chaîne s'ÉPUISE : sans cette décroissance, grouper cinq ennemis
		# reviendrait à les tuer tous pour le prix d'un.
		var power := int(round(float(ability.damage) * pow(ability.chain_falloff, index)))
		var relay := Ability.make({
			"id": "%s_relais_%d" % [ability.id, index],
			"display_name": ability.display_name,
			"kind": Ability.Kind.PROJECTILE, "element": ability.element,
			"damage": maxi(1, power),
		})
		# JAMAIS le trait : ce sort EST la chaîne de l'élément Foudre. Le laisser
		# déclencher en plus l'arc du trait ferait partir un arc de trop et
		# frapperait un maillon deux fois — mesuré : 5 arcs pour 3 relais.
		# L'exaltation, elle, s'applique au premier maillon comme à tout coup
		# d'origine.
		_apply_damage(target, relay, context, false, index == 0)
		# La Tempête en chaîne paralyse chaque maillon un instant ; un boss n'en a cure.
		if ability.chain_stun > 0.0 and context.enemy_alive(target) and not context.bosses.has(target) \
				and not context.is_structure(target):
			enemy_staggered.emit(target, ability.chain_stun)


## LA VAGUE : un front qui part droit devant et balaie tout son chemin.
##
## Elle ne vise pas — elle prend le couloir. C'est ce qui la sépare du
## projectile, qui cherche une cible, et du souffle, qui frappe tout d'un coup
## autour du lanceur. Ici l'ennemi VOIT venir, et peut encore s'écarter dans une
## intersection : la vague récompense le joueur qui l'aligne sur un couloir
## droit, pas celui qui appuie au hasard.
func _cast_wave(ability: Ability, context: CombatContext) -> bool:
	# LA VAGUE VA CHERCHER L'ENNEMI, elle ne part pas droit devant.
	#
	# Première version : elle suivait le regard du mage. Défaut de conception —
	# en FUYANT, on tourne le dos à ses poursuivants, et le sort partait donc
	# systématiquement du mauvais côté. Il fallait s'arrêter et se retourner
	# pour s'en servir : exactement ce qu'un sort de fuite doit éviter.
	#
	# Elle remonte désormais le COULOIR jusqu'à l'ennemi le plus proche, comme
	# un projectile — mais en frappant tout ce qu'elle croise en chemin. À
	# défaut de cible, elle part devant : un sort qui refuserait de sortir
	# faute d'ennemi visible serait un bouton mort.
	var path: Array[Vector2i] = []
	var target := find_target(ability, context)
	if target >= 0:
		var route := trajectory(context.player_cell, context.enemy_cells[target])
		for i in range(1, route.size()):
			if path.size() >= ability.range:
				break
			path.append(route[i])
	if path.is_empty():
		var cell := context.player_cell
		for step in ability.range:
			var next: Vector2i = cell + context.player_facing
			if not grid.is_floor_v(next):
				break
			cell = next
			path.append(cell)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var duration := float(path.size()) / maxf(1.0, ability.wave_speed)
	_waves.append({
		"ability": ability, "path": path, "index": 0,
		"step": duration / float(path.size()), "timer": 0.0,
		# Chaque ennemi n'est frappé QU'UNE FOIS par vague : sans cette mémoire,
		# un ennemi qui recule devant le front encaisserait à chaque case.
		"hit": {},
	})
	wave_launched.emit(ability, path, duration)
	return true


func _update_waves(delta: float, context: CombatContext) -> void:
	for i in range(_waves.size() - 1, -1, -1):
		var wave: Dictionary = _waves[i]
		wave["timer"] = float(wave["timer"]) - delta
		if float(wave["timer"]) > 0.0:
			continue
		wave["timer"] = float(wave["step"])
		var path: Array = wave["path"]
		var index := int(wave["index"])
		if index >= path.size():
			_waves.remove_at(i)
			continue
		wave["index"] = index + 1
		_break_on_wave(wave, path[index], context)


## Le front est arrivé sur une case : il frappe ce qui s'y trouve, et ce qui est
## à portée de sa largeur.
func _break_on_wave(wave: Dictionary, cell: Vector2i, context: CombatContext) -> void:
	var ability: Ability = wave["ability"]
	var already: Dictionary = wave["hit"]
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or already.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		already[i] = true
		_apply_damage(i, ability, context)
		# Le Raz-de-marée EMPORTE ce qu'il frappe, et le plaque contre la paroi qui l'arrête.
		if ability.blow_cells > 0 and context.enemy_alive(i) and not context.is_structure(i) \
				and not context.bosses.has(i):
			var travelled := _push_away(i, context, ability.blow_cells)
			if travelled < ability.blow_cells and ability.slam_damage > 0 and context.enemy_alive(i):
				enemy_slammed.emit(i, context.enemy_cells[i])
				_apply_damage(i, Ability.make({"id": ability.id + "_paroi", "kind": Ability.Kind.BLAST,
					"element": ability.element, "damage": ability.slam_damage}), context, false, false)


## PICS DE TERRE : la gerbe COURT DANS LE COULOIR, elle n'entoure pas le mage.
##
## C'était un souffle circulaire de plus — la même mécanique que trois autres
## sorts du jeu, dessinée avec l'éclat générique. Le Mage de la Terre est le
## lent, le résistant, celui qui ferme un couloir : il lui fallait un geste à
## lui. C'est la LIGNE, comme la Foudre a la chaîne.
##
## Deux temps. La gerbe part des pieds du mage et file devant, de case en case,
## en frappant tout ce qu'elle croise. Puis les pointes RESTENT plantées : ce
## qui passe dessus est mordu et ralenti. Le premier temps est une attaque, le
## second est du terrain — et c'est le second qui le distingue du Feu (dont le
## brasier cloue sur place) et de l'Eau (dont le cercle englue sans blesser).
func _cast_line(ability: Ability, context: CombatContext) -> bool:
	if ability.line_cross:
		return _cast_cross(ability, context)
	var path := _corridor_ahead(context.player_cell, context.player_facing,
		ability.range)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var duration := float(path.size()) / maxf(1.0, ability.line_speed)
	var line := {
		"ability": ability, "path": path, "index": 0,
		"step": duration / float(path.size()), "timer": 0.0,
		# Comme la vague : chaque créature n'encaisse l'éruption QU'UNE FOIS,
		# même si elle recule devant la gerbe qui monte.
		"hit": {},
		"plant": _plant_of(ability),
	}
	line_erupted.emit(ability, path, duration)

	# D'UN COUP quand la vitesse est NULLE.
	#
	# La boucle d'entretien consomme le temps ÉCOULÉ, ce qui est juste pour une
	# gerbe qui court : elle avance de ce que le temps permet. Mais aucune
	# vitesse, si haute soit-elle, ne lève dix cases dans la même image par ce
	# chemin — la Faille, censée surgir, se voyait courir. Une vitesse de zéro
	# dit donc « simultané » : on lève tout ici même et la ligne n'entre jamais
	# dans la file. C'est une valeur qui se lit dans le catalogue, là où un
	# seuil en secondes aurait été un chiffre magique de plus.
	if ability.line_speed <= 0.0:
		for cell in path:
			_erupt(line, cell, context)
		return true
	_lines.append(line)
	return true


## Le couloir DEVANT le mage, virages compris.
##
## Une ligne qui s'arrêterait au premier mur serait inutilisable dans un
## labyrinthe : on y voit rarement plus de trois cases devant soi. La gerbe suit
## donc le couloir — tant qu'il n'y a qu'une seule façon de continuer. À une
## intersection elle s'arrête : au-delà, « tout droit » ne veut plus rien dire,
## et une gerbe qui choisirait sa route à la place du joueur serait un sort
## qu'on ne peut pas viser.
func _corridor_ahead(from: Vector2i, facing: Vector2i, limit: int) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cell := from
	var dir := facing
	for step in limit:
		var next: Vector2i = cell + dir
		if not grid.is_floor_v(next):
			var options: Array[Vector2i] = []
			for side in [Vector2i(dir.y, dir.x), Vector2i(-dir.y, -dir.x)]:
				if grid.is_floor_v(cell + side):
					options.append(side)
			if options.size() != 1:
				break
			dir = options[0]
			next = cell + dir
		cell = next
		path.append(cell)
	return path


## Le sort DÉRIVÉ des pics plantés : une zone d'une seule case.
##
## Les pointes qui restent sont une zone comme les autres — elles mordent par
## seconde, elles ralentissent, elles expirent. Plutôt que d'écrire un second
## mécanisme qui ferait la même chose, on fabrique le sort correspondant et on
## laisse tourner celui qui existe et qui est éprouvé.
func _plant_of(ability: Ability) -> Ability:
	# La durée des GERBES, distincte de celle du sort : un orbe qui tient trente
	# secondes ne doit pas laisser trente secondes de pierres derrière chaque
	# balayage, sinon le couloir se referme pour de bon.
	var life := ability.spike_life if ability.spike_life > 0.0 else ability.duration
	return Ability.make({
		"id": ability.id + "_plant", "display_name": ability.display_name,
		"kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": ability.line_bite, "radius": 0.5, "duration": life,
		"slow_duration": ability.slow_duration, "slow_factor": ability.slow_factor,
		"zone_style": ability.plant_style if ability.plant_style != "" else
			("eruption" if ability.spike_anim else "pics"),
	})


func _update_lines(delta: float, context: CombatContext) -> void:
	for i in range(_lines.size() - 1, -1, -1):
		var line: Dictionary = _lines[i]
		line["timer"] = float(line["timer"]) - delta
		if float(line["timer"]) > 0.0:
			continue
		var path: Array = line["path"]
		# TOUT CE QUE LE TEMPS ÉCOULÉ PERMET, et pas une case par image.
		#
		# La gerbe des Pics court à douze cases par seconde : une case par
		# image suffisait. La Faille, elle, se lève D'UN COUP — cent cases par
		# seconde — et une case par image l'aurait étalée sur dix images, soit
		# un sixième de seconde de retard sur la dernière. On consomme donc le
		# temps accumulé, ce qui rend la cadence indépendante du framerate.
		var budget := 32
		while float(line["timer"]) <= 0.0 and budget > 0:
			budget -= 1
			line["timer"] = float(line["timer"]) + float(line["step"])
			var index := int(line["index"])
			if index >= path.size():
				break
			line["index"] = index + 1
			_erupt(line, path[index], context)
		if int(line["index"]) >= path.size():
			_lines.remove_at(i)


## Une case se soulève : elle frappe, puis elle reste.
func _erupt(line: Dictionary, cell: Vector2i, context: CombatContext) -> void:
	var ability: Ability = line["ability"]
	var already: Dictionary = line["hit"]
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or already.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		already[i] = true
		_apply_damage(i, ability, context)
	var plant: Ability = line["plant"]
	if plant.duration <= 0.0:
		return
	var id := _next_zone_id
	_next_zone_id += 1
	_zones.append({
		"id": id, "ability": plant, "cell": cell,
		"time_left": plant.duration, "tick": 0.0,
	})
	zone_created.emit(id, plant, cell)


## ÉCLATS DE CRISTAL : il PLANTE le cristal, et le cristal se bat tout seul.
##
## Le sort MENTAIT : il annonçait « trois éclats » et en tirait un. C'était un
## Rocher plus faible, plus lointain, et huit fois plus lent — strictement
## moins bon que l'attaque de base du même mage. Aucune raison d'appuyer.
##
## Le cristal fiché dans le sol est la seule chose du jeu qui attaque SANS le
## joueur. L'Invocateur a des créatures, mais elles CHASSENT ; le cristal ne
## bouge jamais, et c'est ce qui les sépare à l'œil nu. Il récompense le seul
## mage qui ne peut pas fuir : il plante, il hérisse le couloir de pics, il
## s'entoure de son égide, et il tient.
func _cast_turret(ability: Ability, context: CombatContext) -> bool:
	# Devant lui de préférence — un cristal posé sur ses propres pieds ne dit
	# pas au joueur qu'il vient de tenir un couloir. Mais le nez au mur, il le
	# plante sur place plutôt que de refuser : un bouton qui ne part pas parce
	# qu'on regarde la pierre serait incompréhensible.
	var cell: Vector2i = context.player_cell + context.player_facing
	if not grid.is_floor_v(cell):
		cell = context.player_cell
	var id := _next_turret_id
	_next_turret_id += 1
	_turrets.append({
		"id": id, "ability": ability, "cell": cell,
		"time_left": ability.duration,
		# Le PREMIER éclat part tout de suite. Un cristal qui reste muet une
		# seconde et demie après avoir été planté se lit comme un sort raté.
		"tick": 0.0,
	})
	turret_planted.emit(id, ability, cell)
	return true


func _update_turrets(delta: float, context: CombatContext) -> void:
	for i in range(_turrets.size() - 1, -1, -1):
		var turret: Dictionary = _turrets[i]
		turret["time_left"] = float(turret["time_left"]) - delta
		turret["tick"] = float(turret["tick"]) - delta
		var ability: Ability = turret["ability"]
		# LE CRISTAL SUIT LE MAGE. Il est fiché dans le sol à ses pieds et
		# repart avec lui : c'est ce que demande le mage le plus lent du jeu,
		# qui ne peut pas revenir chercher ce qu'il a laissé derrière.
		if ability.turret_follows:
			turret["cell"] = context.player_cell
		if float(turret["tick"]) <= 0.0:
			turret["tick"] = maxf(0.1, ability.turret_interval)
			var cell: Vector2i = turret["cell"]
			var prey := _nearest_in_reach(cell, ability.range, context)
			if prey >= 0:
				turret_fired.emit(int(turret["id"]), ability, cell, prey)
				if ability.turret_sweep:
					# L'ORBE N'ENVOIE RIEN : IL OUVRE LE SOL.
					#
					# Une faille se lève dans le couloir, du mage jusqu'à sa
					# proie, et frappe tout ce qui s'y trouve. C'est le balayage
					# des Pics de terre — déclenché tout seul, dès qu'une
					# créature entre à portée, au lieu d'être visé à la main.
					_sweep_to(ability, cell, context.enemy_cells[prey], context)
				else:
					# Coup D'ORIGINE : il déclenche donc le trait de la Terre,
					# comme s'il venait du mage.
					_apply_damage(prey, ability, context)
					# LA TOUR DE CRISTAL du Colosse tire sur plusieurs à la fois : les suivants après le premier.
					if ability.turret_volley > 1:
						for other in _turret_volley(cell, prey, ability, context):
							turret_fired.emit(int(turret["id"]), ability, cell, other)
							_apply_damage(other, ability, context)
		if float(turret["time_left"]) <= 0.0:
			_turrets.remove_at(i)
			turret_faded.emit(int(turret["id"]))


## LE SÉISME : le sol tremble, et la pierre CÈDE par pans.
##
## Ce qui le sépare de la pluie de météores du Feu n'est PAS l'endroit où ça
## tombe — mesuré : 97 à 99 % des cases d'un labyrinthe touchent un mur, donc
## une règle « les pans cèdent au pied des parois » aurait été décorative. Une
## première version la posait quand même, avec un commentaire qui promettait
## qu'y longer un mur serait dangereux : c'était faux.
##
## La vraie différence est la TEXTURE. Le Feu lâche quatorze météores lourdes
## étalées sur sa durée ; la Terre fait crouler des pans par vagues de trois, et
## la CADENCE s'emballe au début puis se calme — les premières secondes sont une
## avalanche, les dernières un grondement. Un test garde cette décroissance.
func _update_quakes(delta: float, context: CombatContext) -> void:
	for i in range(_quakes.size() - 1, -1, -1):
		var quake: Dictionary = _quakes[i]
		var ability: Ability = quake["ability"]
		quake["time_left"] = float(quake["time_left"]) - delta
		quake["tick"] = float(quake["tick"]) - delta
		# LE TREMBLEMENT LUI-MÊME BLESSE, partout, tant qu'il dure.
		#
		# Sans lui, l'ultime était un spectacle : mesuré, vingt-sept
		# éboulements tirés au sort sur six cents cases ne touchaient presque
		# jamais une créature donnée. Les pans qui cèdent restent la grosse
		# frappe, locale et aléatoire ; la secousse est le fond continu qui
		# n'épargne personne.
		if ability.quake_tremor > 0:
			quake["grind"] = float(quake.get("grind", 0.0)) - delta
			if float(quake["grind"]) <= 0.0:
				quake["grind"] = ZONE_TICK
				var slice := Ability.make({
					"id": ability.id, "kind": Ability.Kind.BLAST,
					"element": ability.element,
					"damage": maxi(1, int(round(ability.quake_tremor * ZONE_TICK))),
				})
				for prey in context.enemy_cells.size():
					if context.enemy_alive(prey):
						_apply_damage(prey, slice, context, false, false)
		if float(quake["tick"]) <= 0.0:
			# Au début, une vague tombe deux fois plus vite qu'à la fin.
			var left := clampf(float(quake["time_left"]) / maxf(0.1,
				ability.quake_duration), 0.0, 1.0)
			quake["tick"] = ability.quake_interval * (1.6 - 0.6 * left)
			for slide in ability.quake_slides:
				_collapse(ability, context)
		if float(quake["time_left"]) <= 0.0:
			_quakes.remove_at(i)


## Un pan cède, quelque part sur le sol du labyrinthe.
func _collapse(ability: Ability, context: CombatContext) -> void:
	var cells := grid.all_floor_cells()
	if cells.is_empty():
		return
	var cell: Vector2i = cells[_rng.randi_range(0, cells.size() - 1)]
	quake_slide.emit(cell, ability)
	var blow := Ability.make({
		"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.quake_damage, "radius": ability.quake_radius,
	})
	_apply_area(blow, cell, context, ability)


## Le balayage automatique de l'orbe : une faille du mage jusqu'à sa proie.
##
## Le chemin est celui du COULOIR, virages compris — la faille contourne la
## pierre, elle ne la traverse pas. Elle se lève d'un coup : rien à faire
## avancer, donc rien à mettre dans la file des lignes.
func _sweep_to(ability: Ability, from: Vector2i, prey: Vector2i,
		context: CombatContext) -> void:
	var route := trajectory(from, prey)
	var path: Array[Vector2i] = []
	for i in range(1, route.size()):
		if path.size() >= ability.range:
			break
		path.append(route[i])
	if path.is_empty():
		return
	var line := {
		"ability": ability, "path": path, "index": 0, "step": 0.0, "timer": 0.0,
		"hit": {}, "plant": _plant_of(ability),
	}
	line_erupted.emit(ability, path, 0.0)
	for cell in path:
		_erupt(line, cell, context)


## La proie la plus proche d'une CASE, en distance de chemin — pas à vol
## d'oiseau. Un ennemi à deux cases derrière un mur est à dix cases de marche :
## le cristal ne doit pas tirer à travers la pierre.
func _nearest_in_reach(cell: Vector2i, reach: int, context: CombatContext) -> int:
	var field := Pathfinder.distance_field(grid, [cell] as Array[Vector2i])
	var best := -1
	var best_distance := reach + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or distance > reach or distance >= best_distance:
			continue
		best_distance = distance
		best = i
	return best


## LA TRANSLATION GLISSE, LE PASSAGE TRAVERSE.
##
## Deux translations dans le même kit avaient besoin de deux comportements —
## sinon la plus courte n'est qu'une version ratée de l'autre. Le Sorcier des
## Ténèbres avait exactement ça : une Translation de 4 cases toutes les 9 s à
## côté d'un Pas de l'ombre de 6 cases toutes les 6,5 s. Plus courte, plus lente,
## sur le même geste : elle n'avait aucune raison d'exister.
##
## `pierces_walls` la sépare pour de bon. Elle FRANCHIT une haie et se pose de
## l'autre côté, là où le Pas de l'ombre glisse jusqu'au mur et s'arrête. C'est
## la seule chose du jeu qui coupe à travers le labyrinthe, et ça va au mage des
## passages — la topologie du labyrinthe est TOUT le jeu, et rien dans son kit
## ne s'en servait.
##
## Elle vise la case la plus LOINTAINE praticable, et non la première :
## s'arrêter au premier sol franchi la remettrait dans le couloir d'où elle
## vient dès que le mage est collé à une haie.
func _cast_blink(ability: Ability, context: CombatContext) -> bool:
	if player_rooted():
		use_refused.emit("immobile")
		return false
	if ability.hop_count > 0 and _hop(ability, context):
		return true
	if ability.swap_with_summon and _swap_with_summon(context):
		return true
	var destination := context.player_cell
	var facing := -context.player_facing if ability.backward else context.player_facing
	if ability.rewind_seconds > 0.0:
		destination = cell_at_past(ability.rewind_seconds)
		if destination == context.player_cell:
			use_refused.emit("immobile")
			return false
		if ability.clock_bomb_delay > 0.0:
			_set_clock_bomb(context.player_cell, ability)
		blink_performed.emit(context.player_cell, destination)
		return true
	if ability.follows_corridor:
		# LE TORRENT suit le couloir et tourne avec lui, et laisse un courant qui ralentit.
		var route := _rolling_path(context.player_cell, facing, ability.range)
		if not route.is_empty():
			destination = route[-1]
			if ability.wake_seconds > 0.0:
				_lay_wake(ability, [context.player_cell] + route)
	elif ability.pierces_walls:
		for step in range(ability.range, 0, -1):
			var far: Vector2i = context.player_cell + facing * step
			if grid.is_floor_v(far) and not grid.is_occupied(far):
				destination = far
				break
		# LE PAS DE L'OMBRE marque tout ce qui se tient sur la ligne du passage, haies comprises.
		if ability.blink_mark_seconds > 0.0 and destination != context.player_cell:
			var crossed := []
			var at: Vector2i = context.player_cell
			while at != destination:
				at += facing
				crossed.append(at)
			for i in context.enemy_cells.size():
				if context.enemy_alive(i) and not context.is_structure(i) and crossed.has(context.enemy_cells[i]):
					_marked[i] = ability.blink_mark_seconds
					enemy_marked.emit(i, ability.blink_mark_seconds)
	else:
		for step in ability.range:
			var next: Vector2i = destination + facing
			if not grid.is_floor_v(next):
				break
			destination = next
	if destination == context.player_cell:
		use_refused.emit("mur")
		return false
	if ability.cloud_duration > 0.0:
		_cloud_zone(destination if ability.cloud_at_arrival else context.player_cell, ability)
	blink_performed.emit(context.player_cell, destination)
	if ability.flock_damage > 0:
		_flock_strike(context.player_cell, destination, ability, context)
	# La Plongée du phénix explose là où il part, puis là où il arrive.
	if ability.end_blast_damage > 0:
		var blast := Ability.make({"id": ability.id + "_eclat", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.end_blast_damage,
			"radius": ability.end_blast_radius})
		if not ability.end_blast_arrival_only:
			_apply_area(blast, context.player_cell, context)
		if ability.end_blast_push > 0:
			_erupt_at(blast, destination, ability, context)
		else:
			_apply_area(blast, destination, context)
		# Le Pas de l'Abîme : l'onde de givre fige ce qui l'attendait.
		if ability.end_blast_stun > 0.0:
			frost_wave.emit(destination, ability.end_blast_radius)
			_freeze_around(Ability.make({"id": ability.id + "_onde", "kind": Ability.Kind.BLAST,
				"element": ability.element, "radius": ability.end_blast_radius,
				"stun_seconds": ability.end_blast_stun}), context, destination)
	if ability.blind_radius > 0:
		_blind_around(destination, ability, context)
	if ability.trail_damage > 0:
		_burn_trail(context.player_cell, destination, ability, context)
	if ability.blink_star and _constellation_ability() != null and not _star_at(destination):
		_plant_star(destination, _constellation_ability())
	if ability.decoy_seconds > 0.0:
		_pose_decoy(context.player_cell, ability)
	if ability.element_ray_damage > 0:
		_cast_element_rays(destination, ability, context)
	return true


# --- Le temps : la trace du mage ----------------------------------------------------

func _record_trail(delta: float, context: CombatContext) -> void:
	_clock += delta
	if _trail.is_empty() or _trail[-1]["cell"] != context.player_cell:
		if _seep_left > 0.0 and not _trail.is_empty():
			_puddles[_trail[-1]["cell"]] = _seep_life
			puddle_laid.emit(_trail[-1]["cell"], _seep_life)
		_trail.append({"cell": context.player_cell, "time": _clock})
	# On garde la dernière case d'AVANT la limite : c'est là qu'il était à cet instant.
	while _trail.size() > 1 and float(_trail[1]["time"]) < _clock - TRAIL_KEEP:
		_trail.pop_front()


## La trace depuis `seconds` : son premier élément est la case où il se tenait alors.
func _trail_since(seconds: float) -> Array[Dictionary]:
	var cutoff := _clock - seconds
	var first := 0
	for i in _trail.size():
		if float(_trail[i]["time"]) <= cutoff:
			first = i
	return _trail.slice(first)


## Où était le mage il y a `seconds`. Plus tôt que le début du niveau : son départ.
func cell_at_past(seconds: float) -> Vector2i:
	var recent := _trail_since(seconds)
	return recent[0]["cell"] if not recent.is_empty() else Vector2i.ZERO


func _cast_echo(ability: Ability) -> bool:
	var recent := _trail_since(ability.echo_seconds)
	if recent.size() < 2:
		use_refused.emit("immobile")
		return false
	var cells: Array = []
	var times: Array = []
	var start := float(recent[1]["time"]) - 0.2
	for i in recent.size():
		cells.append(recent[i]["cell"])
		times.append(maxf(0.0, float(recent[i]["time"]) - start) if i > 0 else 0.0)
	_walkers.append({"ability": ability, "cells": cells, "times": times,
		"elapsed": 0.0, "at": 0, "hit": {}})
	echo_walked.emit(ability, cells, times)
	# LE PARADOXE : un second double rejoue une marche plus longue, en même temps que le premier.
	if ability.echo_second_seconds > 0.0:
		_walk_double(ability, ability.echo_second_seconds)
	return true


func _walk_double(ability: Ability, seconds: float) -> void:
	var recent := _trail_since(seconds)
	if recent.size() < 2:
		return
	var cells: Array = []
	var times: Array = []
	var start := float(recent[1]["time"]) - 0.2
	for i in recent.size():
		cells.append(recent[i]["cell"])
		times.append(maxf(0.0, float(recent[i]["time"]) - start) if i > 0 else 0.0)
	_walkers.append({"ability": ability, "cells": cells, "times": times,
		"elapsed": 0.0, "at": 0, "hit": {}})
	echo_walked.emit(ability, cells, times)


## Le double frappe ce qui se tient sur sa case ou la touche, une seule fois par créature.
func _update_walkers(delta: float, context: CombatContext) -> void:
	for w in range(_walkers.size() - 1, -1, -1):
		var walker: Dictionary = _walkers[w]
		walker["elapsed"] = float(walker["elapsed"]) + delta
		var times: Array = walker["times"]
		while int(walker["at"]) + 1 < times.size() \
				and float(times[int(walker["at"]) + 1]) <= float(walker["elapsed"]):
			walker["at"] = int(walker["at"]) + 1
		var cell: Vector2i = walker["cells"][int(walker["at"])]
		var hit: Dictionary = walker["hit"]
		for i in context.enemy_cells.size():
			if hit.has(i) or not context.enemy_alive(i):
				continue
			var gap: Vector2i = context.enemy_cells[i] - cell
			if absi(gap.x) + absi(gap.y) <= 1:
				hit[i] = true
				_apply_damage(i, walker["ability"], context)
		if float(walker["elapsed"]) >= float(times[-1]):
			_walkers.remove_at(w)
			var source: Ability = walker["ability"]
			if source.echo_end_damage > 0:
				var last: Vector2i = walker["cells"][-1]
				echo_burst.emit(last, source.echo_end_radius)
				_apply_area(Ability.make({"id": source.id + "_onde", "kind": Ability.Kind.BLAST,
					"element": source.element, "damage": source.echo_end_damage,
					"radius": source.echo_end_radius}), last, context, null, false, false)


func _update_hourglass(delta: float) -> void:
	if _hourglass_left <= 0.0:
		return
	_hourglass_left -= delta
	if _hourglass_left > 0.0:
		return
	var lost := maxi(0, _hourglass_health - health.current)
	var gained := health.heal(ceili(lost * _hourglass_ratio)) if lost > 0 else 0
	if gained > 0:
		player_healed.emit(gained)
	hourglass_ended.emit(gained)


## L'arrêt passe par l'ébranlement existant : la simulation d'équilibrage et le jeu savent
## déjà qu'une créature ébranlée ne bouge ni ne frappe. Les projectiles et les repaires,
## eux, lisent `time_factor_at` et `time_stop_left`.
func _stop_time(ability: Ability, context: CombatContext) -> void:
	_time_stop_left = ability.duration
	if ability.judgement_ratio > 0.0:
		_judgement_left = ability.duration
		_judgement_ability = ability
		_judgement_bank.clear()
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			enemy_staggered.emit(i, ability.duration)
	time_stopped.emit(ability.duration)


func time_stop_left() -> float:
	return _time_stop_left


## L'allure du temps sur une case, pour un projectile ennemi : 0 quand tout est figé.
func time_factor_at(cell: Vector2i) -> float:
	if _time_stop_left > 0.0:
		return 0.0
	var factor := 1.0
	for zone in _zones:
		var ability: Ability = zone["ability"]
		if ability.time_factor < factor and Vector2(cell).distance_to(
				Vector2(zone["cell"] as Vector2i)) <= ability.radius:
			factor = ability.time_factor
	return factor


# --- Le Seigneur des Heures (l'Éveil du Chronomancien) -----------------------------

## TEMPS ACCÉLÉRÉ : pendant `seconds`, ses recharges courent à `factor` fois l'allure du monde.
func start_haste(seconds: float, factor: float) -> void:
	_haste_left = seconds
	_haste_factor = factor
	haste_changed.emit(true)


func stop_haste() -> void:
	if _haste_left <= 0.0:
		return
	_haste_left = 0.0
	haste_changed.emit(false)


func haste_active() -> bool:
	return _haste_left > 0.0


func _update_hours(delta: float, context: CombatContext) -> void:
	if _haste_left > 0.0:
		_haste_left = maxf(0.0, _haste_left - delta)
		if _haste_left <= 0.0:
			haste_changed.emit(false)
	for i in range(_clock_bombs.size() - 1, -1, -1):
		var bomb: Dictionary = _clock_bombs[i]
		bomb["left"] = float(bomb["left"]) - delta
		if float(bomb["left"]) > 0.0:
			continue
		_clock_bombs.remove_at(i)
		var source: Ability = bomb["ability"]
		var cell: Vector2i = bomb["cell"]
		clock_bomb_rang.emit(int(bomb["id"]), cell, source.clock_bomb_radius)
		var ring := Ability.make({"id": source.id + "_bombe", "kind": Ability.Kind.BLAST,
			"element": source.element, "damage": source.clock_bomb_damage,
			"radius": source.clock_bomb_radius, "stun_seconds": source.clock_bomb_stun})
		# Figées AVANT les dégâts : une créature que la sonnerie tue n'est pas comptée parmi les figées.
		if source.clock_bomb_stun > 0.0:
			_freeze_around(ring, context, cell)
		_apply_area(ring, cell, context, null, false, false)
	if _judgement_left > 0.0:
		_judgement_left = maxf(0.0, _judgement_left - delta)
		if _judgement_left <= 0.0:
			_release_judgement(context)


## Midi sonne : chaque créature reçoit d'un coup tout ce qui s'est accumulé sur elle, multiplié.
func _release_judgement(context: CombatContext) -> void:
	var ability := _judgement_ability
	var bank := _judgement_bank.duplicate()
	_judgement_bank.clear()
	_judgement_ability = null
	if ability == null:
		return
	var hits := {}
	for index: int in bank:
		if context.enemy_alive(index):
			hits[index] = maxi(1, int(round(float(bank[index]) * ability.judgement_ratio)))
	judgement_fell.emit(hits)
	for index: int in hits:
		_apply_damage(index, Ability.make({"id": ability.id + "_midi", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": int(hits[index])}), context, false, false)


func judgement_left() -> float:
	return _judgement_left


func _set_clock_bomb(cell: Vector2i, ability: Ability) -> void:
	_next_bomb += 1
	_clock_bombs.append({"id": _next_bomb, "cell": cell, "left": ability.clock_bomb_delay,
		"ability": ability})
	clock_bomb_set.emit(_next_bomb, cell, ability.clock_bomb_delay)


## Les PV, notés à chaque changement : le Rembobinage lit ce qu'il avait il y a quelques secondes.
func _record_health() -> void:
	if health == null:
		return
	if _health_log.is_empty() or int(_health_log[-1][1]) != health.current:
		_health_log.append([_clock, health.current])
	while _health_log.size() > 1 and float(_health_log[1][0]) < _clock - TRAIL_KEEP:
		_health_log.pop_front()


## Les PV qu'il avait il y a `seconds`. Plus tôt que le premier relevé : le premier relevé.
func health_at_past(seconds: float) -> int:
	if _health_log.is_empty():
		return health.current
	var cutoff := _clock - seconds
	var value := int(_health_log[0][1])
	for entry: Array in _health_log:
		if float(entry[0]) <= cutoff:
			value = int(entry[1])
	return value


func _rewind_wounds(ability: Ability) -> void:
	_record_health()
	var lost := maxi(0, health_at_past(ability.rewind_heal_seconds) - health.current)
	var healed := health.heal(lost) if lost > 0 else 0
	if healed > 0:
		player_healed.emit(healed)
	# Le relevé repart d'ici : un second Rembobinage ne rend pas deux fois les mêmes blessures.
	_health_log = [[_clock, health.current]]
	wounds_rewound.emit(healed)


## LE DÔME DE STASE fige net, une fois, chaque créature qui entre ; les boss ne se figent pas.
func _freeze_entrants(zone: Dictionary, context: CombatContext) -> void:
	var ability: Ability = zone["ability"]
	if not zone.has("frozen"):
		zone["frozen"] = {}
	var frozen: Dictionary = zone["frozen"]
	var field := _field_from(zone["cell"])
	for i in context.enemy_cells.size():
		if frozen.has(i) or not context.enemy_alive(i) or context.is_structure(i) \
				or context.bosses.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		frozen[i] = true
		enemy_staggered.emit(i, ability.entry_freeze)
		stasis_caught.emit(i, ability.entry_freeze)


# --- Le Seigneur du Fléau (l'Éveil du Mage de la Peste) ------------------------------

## LE MIASME : pendant `seconds`, chaque créature collée à lui prend une dose toutes les `every` secondes, et
## le poison monte à `cap` doses.
func start_miasma(seconds: float, every: float, cap: int) -> void:
	_miasma_left = seconds
	_miasma_every = every
	_miasma_tick = every
	_miasma_cap = cap
	miasma_changed.emit(true)


func stop_miasma() -> void:
	if _miasma_left <= 0.0:
		return
	_miasma_left = 0.0
	_miasma_cap = VENOM_MAX
	miasma_changed.emit(false)


func miasma_active() -> bool:
	return _miasma_left > 0.0


## Le plafond des doses : 3, ou celui du Miasme tant qu'il dure.
func venom_cap() -> int:
	return _miasma_cap if _miasma_left > 0.0 else VENOM_MAX


func _update_miasma(delta: float, context: CombatContext) -> void:
	if _miasma_left <= 0.0:
		return
	_miasma_left -= delta
	if _miasma_left <= 0.0:
		_miasma_left = 0.0
		_miasma_cap = VENOM_MAX
		miasma_changed.emit(false)
		return
	_miasma_tick -= delta
	if _miasma_tick > 0.0:
		return
	_miasma_tick = _miasma_every
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var gap: Vector2i = context.enemy_cells[i] - context.player_cell
		if absi(gap.x) + absi(gap.y) <= 1:
			_add_venom(i, context)
			miasma_bit.emit(i)


# --- L'Archimage Primordial (l'Éveil du Sorcier Suprême) ------------------------------

## La lumière de l'origine attend ce temps après la dernière météore.
const NOVA_PAUSE := 0.4
## Les éclats de la Grande Convergence vont chercher leurs cibles jusqu'à cette distance de l'impact.
const SHARD_RANGE := 6


## LA ROUE DES ÉLÉMENTS : pendant `seconds`, chaque coup porte le trait de l'orbe en tête, et l'attaque fait
## tourner la roue. Elle part du feu.
func start_wheel(seconds: float) -> void:
	_wheel_left = seconds
	_wheel_rank = 0
	wheel_changed.emit(true)
	wheel_turned.emit(_wheel_rank)


func stop_wheel() -> void:
	if _wheel_left <= 0.0:
		return
	_wheel_left = 0.0
	wheel_changed.emit(false)


func wheel_active() -> bool:
	return _wheel_left > 0.0


## L'orbe en tête : 0 feu, 1 eau, 2 terre, 3 air, l'ordre des Quatre Sceaux.
func wheel_rank() -> int:
	return _wheel_rank


static func rank_element(rank: int) -> Element.Kind:
	return SEAL_ORDER[posmod(rank, SEAL_ORDER.size())]["element"]


func _turn_wheel() -> void:
	_wheel_rank = (_wheel_rank + 1) % SEAL_ORDER.size()
	wheel_turned.emit(_wheel_rank)


func _update_wheel(delta: float) -> void:
	if _double_echo_left > 0.0:
		_double_echo_left = maxf(0.0, _double_echo_left - delta)
	if _wheel_left <= 0.0:
		return
	_wheel_left -= delta
	if _wheel_left <= 0.0:
		_wheel_left = 0.0
		wheel_changed.emit(false)


## LA GRANDE CONVERGENCE se brise : un éclat par élément, chacun sur une créature proche de l'impact, par les
## couloirs. Moins de cibles que d'éclats : les mêmes en prennent plusieurs.
func _break_into_shards(cell: Vector2i, ability: Ability, context: CombatContext) -> void:
	var field := _field_from(cell)
	var scored: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or distance > SHARD_RANGE:
			continue
		scored.append([distance, i])
	scored.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	var targets: Array = []
	var ranks: Array = []
	var struck: Array[int] = []
	for k in ability.element_shards:
		if scored.is_empty():
			break
		var index := int(scored[k % scored.size()][1])
		targets.append(context.enemy_cells[index])
		ranks.append(k % SEAL_ORDER.size())
		struck.append(index)
	element_shards_flew.emit(cell, targets, ranks)
	for k in struck.size():
		_apply_damage(struck[k], Ability.make({"id": ability.id + "_eclat", "display_name": "Éclat",
			"kind": Ability.Kind.PROJECTILE, "element": rank_element(int(ranks[k])),
			"damage": ability.element_shard_damage}), context, true, false)


## LE PAS DES ÉLÉMENTS : de la case d'arrivée, un rayon de chaque élément part dans chaque couloir ouvert, et
## frappe une fois chaque créature qu'il traverse, avec le trait de son élément.
func _cast_element_rays(from: Vector2i, ability: Ability, context: CombatContext) -> void:
	var paths: Array = []
	var ranks: Array = []
	var hit := {}
	for rank in SEAL_ORDER.size():
		var step: Vector2i = SEAL_ORDER[rank]["step"]
		if not grid.is_floor_v(from + step):
			continue
		var path := _corridor_ahead(from, step, ability.element_ray_range)
		if path.is_empty():
			continue
		paths.append(path)
		ranks.append(rank)
		var ray := Ability.make({"id": ability.id + "_rayon", "display_name": "Rayon",
			"kind": Ability.Kind.LINE, "element": rank_element(rank),
			"damage": ability.element_ray_damage})
		for i in context.enemy_cells.size():
			if hit.has(i) or not context.enemy_alive(i) or not path.has(context.enemy_cells[i]):
				continue
			hit[i] = true
			_apply_damage(i, ray, context, true, false)
	element_rays_cast.emit(from, paths, ranks)


## LA LUMIÈRE DE L'ORIGINE : quand la dernière météore de la Genèse est tombée, tout ce qui est autour de lui,
## à vol d'oiseau, la prend.
func _update_novas(delta: float, context: CombatContext) -> void:
	for i in range(_novas.size() - 1, -1, -1):
		_novas[i]["time_left"] = float(_novas[i]["time_left"]) - delta
		if float(_novas[i]["time_left"]) > 0.0:
			continue
		var source: Ability = _novas[i]["ability"]
		_novas.remove_at(i)
		primal_nova.emit(context.player_cell, source.nova_radius)
		_apply_area(Ability.make({"id": source.id + "_nova", "display_name": "Lumière de l'origine",
			"kind": Ability.Kind.BLAST, "element": source.element, "damage": source.nova_damage,
			"radius": source.nova_radius, "pierces_walls": true, "is_ultimate": true}),
			context.player_cell, context)


# --- L'Étoile du Matin (l'Éveil du Porte-Lumière) ----------------------------------

## L'Éblouissement : un coup sur une créature aveuglée fait autant en plus.
const DAZZLE_BONUS := 0.3
## Collée à lui plus longtemps que ça, une créature est aveuglée (sans passer outre `_blind_locks`).
const DAZZLE_CONTACT := 1.0
const DAZZLE_BLIND := 2.0
## Le Soleil de midi frappe à ce rythme, tout ce qui est dans ce champ autour du mage (la vue fait environ 40 x 22).
const SUN_EVERY := 1.0
const SUN_VIEW := Vector2i(12, 7)
const SUN_BLIND := 1.4


func start_dazzle(seconds: float) -> void:
	_dazzle_left = seconds
	_contact.clear()
	dazzle_changed.emit(true)


func stop_dazzle() -> void:
	if _dazzle_left <= 0.0:
		return
	_dazzle_left = 0.0
	_contact.clear()
	dazzle_changed.emit(false)


func dazzle_active() -> bool:
	return _dazzle_left > 0.0


## Cette créature est-elle aveuglée en ce moment ? Le verrou porte la durée de l'aveuglement PLUS `BLIND_LOCK`.
func is_blinded(index: int) -> bool:
	return float(_blind_locks.get(index, 0.0)) > BLIND_LOCK


func _cast_sun(ability: Ability) -> void:
	_sun = {"left": ability.sun_seconds, "tick": 0.0, "ability": ability}
	sun_risen.emit(ability.sun_seconds)


## L'Égide a encaissé un coup : un rayon part vers la créature la plus proche, la blesse et l'aveugle.
func _answer_aegis(context: CombatContext) -> void:
	var attacker := _nearest_in_reach(context.player_cell, REFLECT_REACH, context)
	if attacker < 0 or _aegis == null:
		return
	aegis_ray.emit(context.player_cell, context.enemy_cells[attacker])
	_apply_damage(attacker, Ability.make({"id": _aegis.id + "_rayon", "kind": Ability.Kind.PROJECTILE,
		"element": _aegis.element, "damage": _aegis.aegis_ray_damage}), context, false, false)
	if _aegis.blind_seconds > 0.0:
		_blind(attacker, _aegis.blind_seconds, context)


func _update_morning_star(delta: float, context: CombatContext) -> void:
	if _dazzle_left > 0.0:
		_dazzle_left -= delta
		if _dazzle_left <= 0.0:
			stop_dazzle()
		else:
			for i in context.enemy_cells.size():
				if not context.enemy_alive(i) or context.is_structure(i):
					_contact.erase(i)
					continue
				var gap := context.enemy_cells[i] - context.player_cell
				if absi(gap.x) + absi(gap.y) > 1:
					_contact.erase(i)
					continue
				_contact[i] = float(_contact.get(i, 0.0)) + delta
				if float(_contact[i]) >= DAZZLE_CONTACT:
					_contact[i] = 0.0
					_blind(i, DAZZLE_BLIND, context)
	for w in range(_light_walls.size() - 1, -1, -1):
		var wall: Dictionary = _light_walls[w]
		wall["time_left"] = float(wall["time_left"]) - delta
		wall["tick"] = float(wall["tick"]) - delta
		if float(wall["time_left"]) <= 0.0:
			_light_walls.remove_at(w)
			continue
		if float(wall["tick"]) > 0.0:
			continue
		wall["tick"] = ZONE_TICK
		var lance: Ability = wall["ability"]
		var burn := Ability.make({"id": lance.id + "_mur", "kind": Ability.Kind.ZONE, "element": lance.element,
			"damage": int(round(lance.linger_damage * ZONE_TICK))})
		var cells: Array = wall["cells"]
		for i in context.enemy_cells.size():
			if context.enemy_alive(i) and not context.is_structure(i) and cells.has(context.enemy_cells[i]):
				_apply_damage(i, burn, context, false, false)
				_blind(i, lance.blind_seconds, context)
	if _sun.is_empty():
		return
	_sun["left"] = float(_sun["left"]) - delta
	_sun["tick"] = float(_sun["tick"]) - delta
	var sun: Ability = _sun["ability"]
	if float(_sun["tick"]) <= 0.0 and float(_sun["left"]) > 0.0:
		_sun["tick"] = SUN_EVERY
		var ray := Ability.make({"id": sun.id + "_rayon", "kind": Ability.Kind.PROJECTILE, "element": sun.element,
			"damage": sun.sun_damage, "is_ultimate": true})
		var struck: Array = []
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or context.is_structure(i):
				continue
			var offset := context.enemy_cells[i] - context.player_cell
			if absi(offset.x) > SUN_VIEW.x or absi(offset.y) > SUN_VIEW.y:
				continue
			struck.append(context.enemy_cells[i])
			_apply_damage(i, ray, context, false, false)
			_blind(i, SUN_BLIND, context, true)
		sun_rays.emit(struck)
	if float(_sun["left"]) <= 0.0:
		_sun = {}
		sun_set.emit(context.player_cell, sun.sun_end_radius)
		_apply_area(Ability.make({"id": sun.id + "_vague", "display_name": "Vague de midi",
			"kind": Ability.Kind.BLAST, "element": sun.element, "damage": sun.sun_end_damage,
			"radius": sun.sun_end_radius, "pierces_walls": true, "is_ultimate": true}),
			context.player_cell, context)


# --- Le Faucheur des Âmes (l'Éveil de l'Ange de la Mort) --------------------------------

## La Récolte : la Sentence achève sous ce seuil, et il garde jusqu'à `HARVEST_SOULS` âmes.
const HARVEST_BELOW := 0.25
const HARVEST_SOULS := 6
## Une âme en orbite frappe pour autant, et ne revient sur la même créature qu'après ce temps.
const HARVEST_SOUL_DAMAGE := 30
const HARVEST_GUARD_LOCK := 1.0
## Minuit : le temps entre l'aller et le retour de la faux.
const HOUR_RETURN_GAP := 0.6


func start_harvest() -> void:
	_harvest = true
	_guard_locks.clear()
	harvest_changed.emit(true)


func stop_harvest() -> void:
	if not _harvest:
		return
	_harvest = false
	_guard_locks.clear()
	if _souls > SOUL_MAX:
		_souls = SOUL_MAX
		souls_changed.emit(_souls)
	harvest_changed.emit(false)


func harvest_active() -> bool:
	return _harvest


# --- Le Séraphin (l'Éveil de l'Archange du Ciel) -----------------------------------------

func start_skies() -> void:
	_skies = true
	skies_changed.emit(true)


func stop_skies() -> void:
	if not _skies:
		return
	_skies = false
	_sky_marks.clear()
	skies_changed.emit(false)


func skies_active() -> bool:
	return _skies


## CE QUI TOMBE DU CIEL ne remonte pas le couloir : il part de lui et tombe sur la cible, après le même temps de
## chute à toute distance. Le chemin n'a donc que ses deux bouts.
func _sky_drop(ability: Ability, target: int, context: CombatContext) -> void:
	var drop: Array[Vector2i] = [context.player_cell, context.enemy_cells[target]]
	_in_flight.append({"ability": ability, "target": target, "time_left": ability.sky_fall, "lane": drop})
	projectile_launched.emit(ability, target, drop, ability.sky_fall)


## L'ennemi le plus proche de lui, à vol d'oiseau et à portée, autre que `skip`.
func _sky_neighbour(skip: int, reach: float, context: CombatContext) -> int:
	var best := -1
	var nearest := reach + 0.5
	for i in context.enemy_cells.size():
		if i == skip or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := float(_sky_distance(context.player_cell, context.enemy_cells[i]))
		if distance < nearest:
			nearest = distance
			best = i
	return best


## LA PLUIE DE PLUMES : une plume tombe du ciel sur chacun des plus proches, à vol d'oiseau.
func _rain_feathers(ability: Ability, context: CombatContext) -> bool:
	var prey: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := _sky_distance(context.player_cell, context.enemy_cells[i])
		if distance <= ability.range:
			prey.append([distance, i])
	if prey.is_empty():
		use_refused.emit("cible")
		return false
	prey.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	var feather := Ability.make({"id": ability.id, "kind": Ability.Kind.PROJECTILE, "element": ability.element,
		"damage": ability.damage, "from_sky": true, "sky_fall": 0.4, "projectile_visual": "plume_seraphin"})
	for n in mini(ability.feather_rain, prey.size()):
		_sky_drop(feather, int(prey[n][1]), context)
	return true


func _update_skies(delta: float, context: CombatContext) -> void:
	for index in _sky_marks.keys():
		_sky_marks[index] = float(_sky_marks[index]) - delta
		if float(_sky_marks[index]) <= 0.0:
			_sky_marks.erase(index)
	# La colonne restée allumée brûle ce qui est sur sa case et autour, une fois par tick.
	for c in range(_columns.size() - 1, -1, -1):
		var column: Dictionary = _columns[c]
		column["left"] = float(column["left"]) - delta
		column["tick"] = float(column["tick"]) - delta
		var ability: Ability = column["ability"]
		if float(column["tick"]) <= 0.0:
			column["tick"] = ZONE_TICK
			var burn := Ability.make({"id": ability.id + "_reste", "kind": Ability.Kind.ZONE,
				"element": ability.element, "damage": maxi(1, int(round(float(ability.column_burn) * ZONE_TICK)))})
			for i in _creatures_within(column["cell"], 1.0, context):
				_apply_damage(i, burn, context, false, false)
		if float(column["left"]) <= 0.0:
			_columns.remove_at(c)
	# Les lances de l'Ascension, tant qu'il vole.
	if _flight != null and _flight.flight_lance_gap > 0.0:
		_flight_lance_timer -= delta
		if _flight_lance_timer <= 0.0:
			_flight_lance_timer = _flight.flight_lance_gap
			var prey := _sky_neighbour(-1, FLIGHT_LANCE_REACH, context)
			if prey >= 0:
				_sky_drop(Ability.make({"id": _flight.id + "_lance", "kind": Ability.Kind.PROJECTILE,
					"element": _flight.element, "damage": _flight.flight_lance_damage, "from_sky": true,
					"sky_fall": 0.35, "projectile_visual": "lance_celeste"}), prey, context)
	else:
		_flight_lance_timer = 0.0
	# L'épée géante : elle s'annonce, puis frappe tout autour de lui à vol d'oiseau.
	for g in range(_great_swords.size() - 1, -1, -1):
		var sword: Dictionary = _great_swords[g]
		sword["time_left"] = float(sword["time_left"]) - delta
		var ability: Ability = sword["ability"]
		if not bool(sword["warned"]) and float(sword["time_left"]) <= GREAT_SWORD_LEAD:
			sword["warned"] = true
			sword["cell"] = context.player_cell
			great_sword_falling.emit(sword["cell"], GREAT_SWORD_LEAD, ability.great_sword_radius)
		if float(sword["time_left"]) > 0.0:
			continue
		_great_swords.remove_at(g)
		great_sword_struck.emit(sword["cell"], ability.great_sword_radius)
		var cut := Ability.make({"id": ability.id + "_epee", "kind": Ability.Kind.BLAST, "element": ability.element,
			"damage": ability.great_sword_damage})
		for i in _creatures_in_sky(sword["cell"], ability.great_sword_radius, context):
			_apply_damage(i, cut, context, false, false)


# --- Le Gardien du Trône (l'Éveil du Chérubin) -------------------------------------------

func start_throne() -> void:
	_throne = true
	throne_changed.emit(true)


func stop_throne() -> void:
	if not _throne:
		return
	_throne = false
	throne_changed.emit(false)


func throne_active() -> bool:
	return _throne


## LES AILES DU TRÔNE S'OUVRENT : un œil sur tout ce qui est à portée, comme si chacun avait été frappé.
func _open_throne_eyes(ability: Ability, context: CombatContext) -> void:
	throne_eyes_opened.emit(context.player_cell, ability.veil_eyes_radius)
	for i in _creatures_within(context.player_cell, ability.veil_eyes_radius, context):
		_add_eye(i, context)


## L'ÉPÉE QUI TOURNOIE sur le bord de l'Éden (Genèse 3:24) : sa pointe fait le tour en `GARDEN_SWORD_PERIOD`, et
## frappe ce qui est près d'elle, une fois par `GARDEN_SWORD_LOCK`. Le `Level` la dessine au même angle.
func _swing_garden_sword(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var angle := (ability.duration - float(_garden["left"])) * TAU / GARDEN_SWORD_PERIOD
	var tip := Vector2(centre) + Vector2.from_angle(angle) * ability.radius
	var cut := Ability.make({"id": ability.id + "_epee", "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.garden_sword_damage})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _sword_locks.has(i):
			continue
		if Vector2(context.enemy_cells[i]).distance_to(tip) > GARDEN_SWORD_REACH:
			continue
		_sword_locks[i] = GARDEN_SWORD_LOCK
		garden_sword_struck.emit(context.enemy_cells[i])
		_apply_damage(i, cut, context, false, false)


# --- Le Forgeron Céleste (l'Éveil de l'Archange d'Acier) ---------------------------------

func start_forge() -> void:
	_forge = true
	_forge_kills = 0
	health.plates = FORGE_PLATES
	forge_changed.emit(true)
	plates_changed.emit(health.plates)


## À la fin, il garde au plus ses trois plaques ordinaires.
func stop_forge() -> void:
	if not _forge:
		return
	_forge = false
	_shards_pending = 0
	if health.plates > PLATE_MAX:
		health.plates = PLATE_MAX
	forge_changed.emit(false)
	plates_changed.emit(health.plates)


func forge_active() -> bool:
	return _forge


func plate_cap() -> int:
	return FORGE_PLATES if _forge else PLATE_MAX


func _on_plate_torn() -> void:
	plates_changed.emit(health.plates)
	if _forge:
		_shards_pending += 1


## Les éclats des plaques cassées, l'enclume qui tombe, et les pas en fusion du Cœur de la forge.
func _update_forge(delta: float, context: CombatContext) -> void:
	while _shards_pending > 0:
		_shards_pending -= 1
		plate_shattered.emit(context.player_cell)
		var shard := Ability.make({"id": "forge_eclats", "kind": Ability.Kind.BLAST, "element": Element.Kind.STEEL,
			"damage": FORGE_SHARD_DAMAGE})
		for i in _creatures_within(context.player_cell, FORGE_SHARD_REACH, context):
			_apply_damage(i, shard, context, false, false)
	for d in range(_anvil_drops.size() - 1, -1, -1):
		var drop: Dictionary = _anvil_drops[d]
		drop["time_left"] = float(drop["time_left"]) - delta
		if float(drop["time_left"]) > 0.0:
			continue
		_anvil_drops.remove_at(d)
		var ability: Ability = drop["ability"]
		var cell: Vector2i = drop["cell"]
		anvil_dropped.emit(cell, ability.anvil_drop_radius)
		var hit := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
			"damage": ability.anvil_drop_damage, "radius": ability.anvil_drop_radius})
		_apply_area(hit, cell, context, null, false, false)
		_stun_within(cell, ability.anvil_drop_radius, ability.anvil_drop_stun, context)
		_anvil_wave(ability, cell)
	if _molten_left > 0.0 and _molten_steps > 0.0 and context.player_cell != _step_cell:
		_step_cell = context.player_cell
		_ignite_cells([context.player_cell], _molten_steps)


func _stun_within(cell: Vector2i, radius: float, seconds: float, context: CombatContext) -> void:
	if seconds <= 0.0:
		return
	for i in _creatures_within(cell, radius, context):
		if context.enemy_alive(i) and not context.bosses.has(i):
			enemy_staggered.emit(i, seconds)


## LE BASTION S'OUVRE : une gerbe de lames en fusion autour de lui, et une plaque reforgée.
func _open_bastion(ability: Ability, context: CombatContext) -> void:
	bastion_opened.emit(context.player_cell, ability.bastion_burst_radius)
	var burst := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.bastion_burst_damage, "radius": ability.bastion_burst_radius})
	_apply_area(burst, context.player_cell, context, null, false, false)
	if health.plates < plate_cap():
		health.plates = mini(plate_cap(), health.plates + ability.bastion_plates)
		plates_changed.emit(health.plates)


# --- La Reine du Firmament (l'Éveil de l'Ange des Étoiles) --------------------------------

func start_firmament() -> void:
	_firmament = true
	firmament_changed.emit(true)
	_report_stars()


## À la fin, seules ses trois dernières étoiles restent, et les éphémères s'éteignent.
func stop_firmament() -> void:
	if not _firmament:
		return
	_firmament = false
	while _stars.size() > STAR_MAX:
		_stars.pop_front()
	_sparks.clear()
	_report_stars()
	firmament_changed.emit(false)


func firmament_active() -> bool:
	return _firmament


## Le sort qui pose ses étoiles, dans sa forme du moment : il donne leurs dégâts aux étoiles éphémères et à la figure.
func _constellation_ability() -> Ability:
	for ability in stats.abilities:
		if ability.kind == Ability.Kind.CONSTELLATION:
			return ability
	return null


func _star_at(cell: Vector2i) -> bool:
	for list: Array[Dictionary] in [_stars, _sparks]:
		for star in list:
			if star["cell"] == cell:
				return true
	return false


func _light_spark(cell: Vector2i, seconds: float) -> void:
	if _star_at(cell):
		return
	if _sparks.size() >= SPARK_MAX:
		_sparks.pop_front()
	_sparks.append({"cell": cell, "time_left": seconds})
	_report_stars()


## LA FIGURE FERMÉE : quand ses cinq étoiles sont posées, leur contour (l'enveloppe, pour qu'une figure croisée ne
## laisse pas de trou). Vide hors du Firmament, avec moins de cinq étoiles, ou si elles sont presque alignées.
func _figure_hull() -> PackedVector2Array:
	if not _firmament or _stars.size() < FIRMAMENT_STARS:
		return PackedVector2Array()
	var points := PackedVector2Array()
	for star in _stars:
		points.append(Vector2(star["cell"]))
	var hull := Geometry2D.convex_hull(points)
	if hull.size() >= 2 and hull[0] == hull[-1]:
		hull.remove_at(hull.size() - 1)
	if hull.size() < 3:
		return PackedVector2Array()
	return hull


## L'ANNEAU DE LUNE à la fin de l'Éclipse : il blesse et ralentit ce qu'il touche, par les couloirs.
func _end_eclipse(ability: Ability, context: CombatContext) -> void:
	eclipse_ended.emit(context.player_cell, ability.moon_ring_radius)
	var field := _field_from(context.player_cell)
	var ring := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.moon_ring_damage})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.moon_ring_radius:
			continue
		_apply_damage(i, ring, context, false, false)
		if context.enemy_alive(i) and ability.moon_ring_slow < 1.0:
			enemy_soaked.emit(i, ability.moon_ring_slow_seconds, ability.moon_ring_slow)


## NAISSANCE D'UNE GALAXIE : chaque impact de comète devient une étoile, reliée à ses deux voisines les plus proches.
func _light_galaxy_star(cell: Vector2i, ability: Ability) -> void:
	_galaxy_ability = ability
	_galaxy.append({"cell": cell, "time_left": ability.galaxy_seconds})
	_report_galaxy()


func _report_galaxy() -> void:
	_galaxy_links.clear()
	var seen := {}
	for a in _galaxy.size():
		var from := Vector2(_galaxy[a]["cell"])
		var near: Array = []
		for b in _galaxy.size():
			var reach := from.distance_to(Vector2(_galaxy[b]["cell"]))
			if b != a and reach <= GALAXY_LINK:
				near.append([reach, b])
		near.sort_custom(func(x: Array, y: Array) -> bool: return x[0] < y[0])
		for n in mini(GALAXY_NEIGHBOURS, near.size()):
			var b := int(near[n][1])
			var key := Vector2i(mini(a, b), maxi(a, b))
			if not seen.has(key):
				seen[key] = true
				_galaxy_links.append([key.x, key.y])
	var cells: Array = []
	for star in _galaxy:
		cells.append(star["cell"])
	galaxy_changed.emit(cells, _galaxy_links.duplicate())


func _update_galaxy(delta: float, context: CombatContext) -> void:
	if _galaxy.is_empty():
		return
	var faded := false
	for i in range(_galaxy.size() - 1, -1, -1):
		_galaxy[i]["time_left"] = float(_galaxy[i]["time_left"]) - delta
		if float(_galaxy[i]["time_left"]) <= 0.0:
			_galaxy.remove_at(i)
			faded = true
	if faded:
		_report_galaxy()
	_galaxy_tick -= delta
	if _galaxy_tick > 0.0 or _galaxy.is_empty() or _galaxy_ability == null:
		return
	_galaxy_tick = STAR_TICK
	var slice := Ability.make({"id": _galaxy_ability.id, "kind": Ability.Kind.ZONE,
		"element": _galaxy_ability.element,
		"damage": int(round(float(_galaxy_ability.galaxy_damage) * STAR_TICK))})
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i) \
				and _on_galaxy(Vector2(context.enemy_cells[i])):
			_apply_damage(i, slice, context, false, false)


func _on_galaxy(at: Vector2) -> bool:
	for star in _galaxy:
		if at.distance_to(Vector2(star["cell"])) <= STAR_REACH:
			return true
	for link: Array in _galaxy_links:
		var closest := Geometry2D.get_closest_point_to_segment(at, Vector2(_galaxy[link[0]]["cell"]),
			Vector2(_galaxy[link[1]]["cell"]))
		if at.distance_to(closest) <= STAR_REACH:
			return true
	return false


## Combien d'âmes il peut garder : trois, six pendant la Récolte.
func soul_cap() -> int:
	return HARVEST_SOULS if _harvest else SOUL_MAX


func souls() -> int:
	return _souls


func _update_harvest(delta: float, context: CombatContext) -> void:
	for index in _guard_locks.keys():
		_guard_locks[index] = float(_guard_locks[index]) - delta
		if float(_guard_locks[index]) <= 0.0:
			_guard_locks.erase(index)
	# LES ÂMES EN ORBITE gardent le Faucheur : ce qui arrive à son contact en prend une.
	if _harvest and _souls > 0:
		for i in context.enemy_cells.size():
			if _souls <= 0:
				break
			if not context.enemy_alive(i) or context.is_structure(i) or _guard_locks.has(i):
				continue
			var gap := context.enemy_cells[i] - context.player_cell
			if absi(gap.x) + absi(gap.y) > 1:
				continue
			_guard_locks[i] = HARVEST_GUARD_LOCK
			_souls -= 1
			souls_changed.emit(_souls)
			soul_guarded.emit(context.player_cell, context.enemy_cells[i])
			_apply_damage(i, Ability.make({"id": "mort_eveil_ame", "display_name": "Âme gardienne",
				"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.DEATH,
				"damage": HARVEST_SOUL_DAMAGE}), context, true, false)
	for r in range(_returns.size() - 1, -1, -1):
		var back: Dictionary = _returns[r]
		back["time_left"] = float(back["time_left"]) - delta
		if float(back["time_left"]) > 0.0:
			continue
		_returns.remove_at(r)
		var cells: Array = back["cells"]
		for i in context.enemy_cells.size():
			if context.enemy_alive(i) and cells.has(context.enemy_cells[i]):
				_apply_damage(i, back["ability"], context)
	for t in range(_tolls.size() - 1, -1, -1):
		var toll: Dictionary = _tolls[t]
		toll["timer"] = float(toll["timer"]) - delta
		if float(toll["timer"]) > 0.0:
			continue
		var bell: Ability = toll["ability"]
		toll["left"] = int(toll["left"]) - 1
		toll["timer"] = bell.toll_gap
		if int(toll["left"]) <= 0:
			_tolls.remove_at(t)
		toll_rang.emit(context.player_cell, bell.radius)
		var field := _field_from(context.player_cell)
		var ring := Ability.make({"id": bell.id, "kind": Ability.Kind.ZONE, "element": bell.element,
			"damage": bell.damage})
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or context.is_structure(i):
				continue
			# Le Carillon céleste passe les haies, comme la Cloche de l'Archange du Ciel.
			var distance := _sky_distance(context.player_cell, context.enemy_cells[i]) if bell.pierces_walls \
				else Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance < 0 or float(distance) > bell.radius:
				continue
			_apply_damage(i, ring, context, false, true)
			if context.enemy_alive(i) and bell.stun_seconds > 0.0 and not context.bosses.has(i):
				enemy_staggered.emit(i, bell.stun_seconds)
			if context.enemy_alive(i) and bell.mark_seconds > 0.0:
				_marked[i] = bell.mark_seconds
				enemy_marked.emit(i, bell.mark_seconds)
				if bell.toll_slow < 1.0:
					enemy_soaked.emit(i, bell.slow_duration, bell.toll_slow)


## L'ÉPIDÉMIE part du malade le plus proche (ou, faute de malade, de la créature la plus proche), puis saute de
## proche en proche par les couloirs, sans repasser deux fois par la même.
func _cast_epidemic(ability: Ability, context: CombatContext) -> bool:
	var start := -1
	var best := ability.range + 1
	for index: int in _venom.keys():
		if not context.enemy_alive(index):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[index])
		if distance >= 0 and distance < best:
			best = distance
			start = index
	if start < 0:
		start = find_target(ability, context)
	if start < 0 or context.is_structure(start):
		use_refused.emit("cible")
		return false
	var visited := {start: true}
	_epidemic_hit(start, context.player_cell, ability, context)
	var current := start
	var at: Vector2i = context.enemy_cells[start]
	for _jump in ability.epidemic_jumps:
		var field := _field_from(at)
		var next := -1
		var nearest := ability.chain_range + 1
		for i in context.enemy_cells.size():
			if visited.has(i) or not context.enemy_alive(i) or context.is_structure(i):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance >= 0 and distance < nearest:
				nearest = distance
				next = i
		if next < 0:
			break
		visited[next] = true
		_epidemic_hit(next, at, ability, context)
		current = next
		at = context.enemy_cells[current]
	return true


func _epidemic_hit(index: int, from: Vector2i, ability: Ability, context: CombatContext) -> void:
	epidemic_jumped.emit(from, context.enemy_cells[index])
	_apply_damage(index, ability, context, false, true)
	_add_venom(index, context, ability.epidemic_doses)


## LA SAIGNÉE : chaque dose portée dans le rayon éclate pour `bleed_per_dose`, et le poison s'en va avec.
func _cast_bleed(ability: Ability, context: CombatContext) -> bool:
	var targets: Array[int] = []
	var cells: Array = []
	var doses: Array = []
	var total := 0
	for index: int in _venom.keys():
		if not context.enemy_alive(index) or context.is_structure(index):
			continue
		if Vector2(context.enemy_cells[index] - context.player_cell).length() > ability.radius:
			continue
		var count := int(_venom[index]["doses"])
		targets.append(index)
		cells.append(context.enemy_cells[index])
		doses.append(count)
		total += count
	if targets.is_empty():
		use_refused.emit("sain")
		return false
	for index in targets:
		_venom.erase(index)
		enemy_venomed.emit(index, 0, 0.0)
	var healed := health.heal(total / maxi(1, ability.transfuse_per))
	if healed > 0:
		player_healed.emit(healed)
	bled.emit(cells, doses, healed)
	for k in targets.size():
		_apply_damage(targets[k], Ability.make({"id": ability.id + "_eclat", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": int(doses[k]) * ability.bleed_per_dose}),
			context, false, true)
	return true


## LA NUÉE DE CORBEAUX pique ce qui se trouve sous sa route, haies comprises : à moins d'une case du trait.
func _flock_strike(from: Vector2i, to: Vector2i, ability: Ability, context: CombatContext) -> void:
	flock_flew.emit(from, to)
	var a := Vector2(from)
	var b := Vector2(to)
	var line := b - a
	var length_sq := maxf(0.001, line.length_squared())
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var p := Vector2(context.enemy_cells[i])
		var k := clampf((p - a).dot(line) / length_sq, 0.0, 1.0)
		if p.distance_to(a + line * k) > 0.8:
			continue
		_apply_damage(i, Ability.make({"id": ability.id + "_bec", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.flock_damage}), context, false, true)
		_add_venom(i, context, ability.flock_doses)


# --- Le venin ---------------------------------------------------------------------

func _add_venom(index: int, context: CombatContext, doses: int = 1,
		duration: float = VENOM_DURATION) -> void:
	if not context.enemy_alive(index) or context.is_structure(index):
		return
	var venom: Dictionary = _venom.get(index,
		{"doses": 0, "time_left": 0.0, "timer": VENOM_TICK, "plague": false})
	venom["doses"] = mini(venom_cap(), int(venom["doses"]) + doses)
	venom["time_left"] = maxf(float(venom["time_left"]), duration)
	_venom[index] = venom
	enemy_venomed.emit(index, int(venom["doses"]), float(venom["time_left"]))


## Doses qui prélèvent ensemble. Ni trait ni exaltation : ce n'est pas un coup porté.
func _update_venom(delta: float, context: CombatContext) -> void:
	for index in _venom_locks.keys():
		_venom_locks[index] = float(_venom_locks[index]) - delta
		if float(_venom_locks[index]) <= 0.0:
			_venom_locks.erase(index)
	for index in _venom.keys():
		if not context.enemy_alive(index):
			_venom.erase(index)
			continue
		var venom: Dictionary = _venom[index]
		venom["time_left"] = float(venom["time_left"]) - delta
		venom["timer"] = float(venom["timer"]) - delta
		if float(venom["timer"]) <= 0.0:
			venom["timer"] = VENOM_TICK
			_apply_damage(index, Ability.make({"id": "venin", "display_name": "Venin",
				"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.POISON,
				"damage": int(venom["doses"]) * VENOM_DAMAGE}), context, false, false)
			if not context.enemy_alive(index):
				venom_killed.emit(context.enemy_cells[index])
				if bool(venom["plague"]) and _plague != null:
					_cloud_zone(context.enemy_cells[index], _plague)
				_venom.erase(index)
				continue
		if float(venom["time_left"]) <= 0.0:
			_venom.erase(index)
			enemy_venomed.emit(index, 0, 0.0)


## Une flaque ne pose qu'une dose par seconde : la traverser coûte moins que s'y attarder.
func _update_puddles(delta: float, context: CombatContext) -> void:
	_seep_left = maxf(0.0, _seep_left - delta)
	if _puddles.is_empty():
		return
	for cell in _puddles.keys():
		_puddles[cell] = float(_puddles[cell]) - delta
		if float(_puddles[cell]) <= 0.0:
			_puddles.erase(cell)
	for i in context.enemy_cells.size():
		if _venom_locks.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		if _puddles.has(context.enemy_cells[i]):
			_venom_locks[i] = VENOM_TICK
			_add_venom(i, context, _puddle_doses)
			# Le Sillage pestilent colle : ce qui y marche s'y traîne.
			if _puddle_slow > 0.0:
				enemy_soaked.emit(i, VENOM_TICK + 0.3, _puddle_slow)
			puddle_stepped.emit(context.enemy_cells[i])


func _apply_zone_venom(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if _venom_locks.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_venom_locks[i] = VENOM_TICK
		_add_venom(i, context, ability.venom_doses)


## Le nuage que laissent la Brume et ce qui éclate : une zone sans dégâts, qui empoisonne.
func _cloud_zone(cell: Vector2i, source: Ability) -> void:
	var id := _next_zone_id
	_next_zone_id += 1
	var cloud := Ability.make({"id": "nuage_toxique", "kind": Ability.Kind.ZONE,
		"element": Element.Kind.POISON, "radius": source.cloud_radius,
		"duration": source.cloud_duration, "venom_doses": maxi(1, source.cloud_venom_doses),
		"zone_style": "gaz_peint"})
	_zones.append({"id": id, "ability": cloud, "cell": cell,
		"time_left": source.cloud_duration, "tick": 0.0})
	zone_created.emit(id, cloud, cell)


## Le foyer est l'ennemi empoisonné le plus proche du mage, dans la portée du sort.
func _cast_contagion(ability: Ability, context: CombatContext) -> bool:
	if ability.epidemic_jumps > 0:
		return _cast_epidemic(ability, context)
	var source := -1
	var best := ability.range + 1
	for index: int in _venom.keys():
		if not context.enemy_alive(index):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[index])
		if distance >= 0 and distance < best:
			best = distance
			source = index
	if source < 0:
		use_refused.emit("sain")
		return false
	var field := _field_from(context.enemy_cells[source])
	var spread := false
	for i in context.enemy_cells.size():
		if i == source or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or distance > ability.chain_range:
			continue
		_add_venom(i, context, int(_venom[source]["doses"]))
		contagion_spread.emit(context.enemy_cells[source], context.enemy_cells[i])
		spread = true
	if not spread:
		use_refused.emit("sain")
	return spread


func _cast_transfusion(ability: Ability, context: CombatContext) -> bool:
	if ability.bleed_per_dose > 0:
		return _cast_bleed(ability, context)
	if health.current >= health.maximum:
		use_refused.emit("pleine")
		return false
	var cells: Array = []
	for index: int in _venom.keys():
		if context.enemy_alive(index):
			cells.append(context.enemy_cells[index])
	if cells.is_empty():
		use_refused.emit("sain")
		return false
	var gained := health.heal(ceili(float(cells.size()) / float(maxi(1, ability.transfuse_per))))
	player_healed.emit(gained)
	transfused.emit(cells, gained)
	return true


func _cast_pandemic(ability: Ability, context: CombatContext) -> void:
	_plague = ability
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			_add_venom(i, context, venom_cap(), ability.duration)
			_venom[i]["plague"] = true
			# LA GRANDE PESTE ralentit tout ce qu'elle charge.
			if ability.plague_slow < 1.0:
				enemy_soaked.emit(i, ability.duration, ability.plague_slow)
	pandemic_cast.emit(context.player_cell)
	if ability.plague_slow < 1.0:
		great_plague.emit(ability.duration)


## Combien de doses porte cette créature ? L'interface et les tests s'en servent.
func venom_doses(index: int) -> int:
	return int(_venom[index]["doses"]) if _venom.has(index) else 0


# --- La lumière -------------------------------------------------------------------

## `force` passe le verrou : seule l'Aube y a droit, c'est son privilège d'ultime.
func _blind(index: int, duration: float, context: CombatContext, force: bool = false) -> void:
	if not context.enemy_alive(index) or context.is_structure(index):
		return
	if _blind_locks.has(index) and not force:
		return
	_blind_locks[index] = duration + BLIND_LOCK
	enemy_blinded.emit(index, duration)


func _update_light(delta: float, context: CombatContext) -> void:
	for index in _blind_locks.keys():
		_blind_locks[index] = float(_blind_locks[index]) - delta
		if float(_blind_locks[index]) <= 0.0:
			_blind_locks.erase(index)
	for i in range(_dawn.size() - 1, -1, -1):
		var strike: Dictionary = _dawn[i]
		strike["time_left"] = float(strike["time_left"]) - delta
		if float(strike["time_left"]) > 0.0:
			continue
		var index := int(strike["index"])
		var ability: Ability = strike["ability"]
		_dawn.remove_at(i)
		if not context.enemy_alive(index):
			continue
		dawn_struck.emit(context.enemy_cells[index])
		if ability.galaxy_seconds > 0.0:
			_light_galaxy_star(context.enemy_cells[index], ability)
		_apply_damage(index, ability, context, false)
		if ability.blind_seconds > 0.0:
			_blind(index, ability.blind_seconds, context, true)


func _blind_around(cell: Vector2i, ability: Ability, context: CombatContext) -> void:
	var field := _field_from(cell)
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance <= ability.blind_radius:
			_blind(i, ability.blind_seconds, context)


func _apply_zone_blind(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and float(distance) <= ability.radius:
			_blind(i, ability.blind_seconds, context)


## La coque a absorbé son coup : l'éclair aveugle ce qui se tient au contact.
func _burst_wings(context: CombatContext) -> void:
	wings_burst.emit(context.player_cell)
	_blind_around(context.player_cell, _wings, context)


func _cast_beam(ability: Ability, context: CombatContext) -> bool:
	var cells: Array[Vector2i] = []
	if ability.pierces_walls:
		for step in range(1, ability.range + 1):
			var cell := context.player_cell + context.player_facing * step
			if cell.x < 0 or cell.y < 0 or cell.x >= grid.cols or cell.y >= grid.rows:
				break
			cells.append(cell)
	else:
		cells = _beam_path(ability.range, context)
	if cells.is_empty():
		use_refused.emit("mur")
		return false
	beam_fired.emit(context.player_cell, cells)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and cells.has(context.enemy_cells[i]):
			_apply_damage(i, ability, context)
	# LA LANCE DE L'AURORE reste allumée : un mur de lumière qui brûle et aveugle ce qui le traverse.
	if ability.beam_linger > 0.0:
		_light_walls.append({"cells": cells, "time_left": ability.beam_linger, "tick": 0.0, "ability": ability})
		light_wall_raised.emit(cells, ability.beam_linger)
	return true


## Le trajet de la Lance : elle part là où regarde le mage, puis file vers la proie la plus
## proche par les couloirs, en passe à la suivante, et sans proie continue devant elle. Elle ne
## repasse jamais sur ses pas : le regard du mage décide donc du côté qu'elle prend.
func _beam_path(limit: int, context: CombatContext) -> Array[Vector2i]:
	var prey := {}
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			prey[context.enemy_cells[i]] = true
	var path: Array[Vector2i] = []
	var walked := {context.player_cell: true}
	var cell: Vector2i = context.player_cell
	var dir: Vector2i = context.player_facing
	if grid.is_floor_v(cell + dir):
		cell += dir
		path.append(cell)
		walked[cell] = true
		prey.erase(cell)
	while path.size() < limit:
		var leg := _beam_leg(cell, walked, prey, limit - path.size())
		if leg.is_empty():
			var onward := _beam_onward(cell, dir, walked)
			if onward == Vector2i.ZERO:
				break
			leg.append(cell + onward)
		for step in leg:
			dir = step - cell
			cell = step
			path.append(cell)
			walked[cell] = true
			prey.erase(cell)
	return path


## Le plus court chemin libre jusqu'à la proie la plus proche, vide s'il n'y en a pas à portée.
func _beam_leg(from: Vector2i, walked: Dictionary, prey: Dictionary, limit: int) -> Array[Vector2i]:
	var came := {from: from}
	var frontier: Array[Vector2i] = [from]
	for depth in limit:
		var next: Array[Vector2i] = []
		for cell in frontier:
			for neighbour in grid.floor_neighbors(cell):
				if came.has(neighbour) or walked.has(neighbour):
					continue
				came[neighbour] = cell
				if prey.has(neighbour):
					var leg: Array[Vector2i] = []
					var back: Vector2i = neighbour
					while back != from:
						leg.push_front(back)
						back = came[back]
					return leg
				next.append(neighbour)
		frontier = next
	return []


## La direction sans proie : tout droit, sinon le virage libre, sinon demi-tour au départ.
func _beam_onward(cell: Vector2i, dir: Vector2i, walked: Dictionary) -> Vector2i:
	for way: Vector2i in [dir, Vector2i(dir.y, dir.x), Vector2i(-dir.y, -dir.x), -dir]:
		if grid.is_floor_v(cell + way) and not walked.has(cell + way):
			return way
	return Vector2i.ZERO


func _cast_dawn(ability: Ability, context: CombatContext) -> void:
	dawn_cast.emit(context.player_cell)
	var wait := DAWN_DELAY
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			_dawn.append({"index": i, "time_left": wait, "ability": ability})
			wait += DAWN_GAP


# --- Les étoiles -------------------------------------------------------------------

func _add_star_mark(index: int, ability: Ability, context: CombatContext) -> void:
	if not context.enemy_alive(index):
		return
	var count := int(_star_marks.get(index, 0)) + 1
	if count < ASTRE_MARKS:
		_star_marks[index] = count
		enemy_star_marks.emit(index, count)
		return
	_star_marks.erase(index)
	enemy_star_marks.emit(index, 0)
	astre_burst.emit(context.enemy_cells[index])
	if ability.spark_seconds > 0.0:
		_light_spark(context.enemy_cells[index], ability.spark_seconds)
	var burst := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
		"damage": ASTRE_DAMAGE})
	# Sans trait : l'explosion ne doit pas reposer une étoile sur la cible qu'elle vient de vider.
	_apply_damage(index, burst, context, false, false)


func _cast_constellation(ability: Ability, context: CombatContext) -> bool:
	for star in _stars:
		if star["cell"] == context.player_cell:
			use_refused.emit("occupé")
			return false
	_plant_star(context.player_cell, ability)
	return true


## Une étoile posée, la plus ancienne cédant sa place au-delà du plafond (trois, cinq sous le Firmament).
func _plant_star(cell: Vector2i, ability: Ability) -> void:
	while _stars.size() >= star_cap():
		_stars.pop_front()
	_stars.append({"cell": cell, "time_left": ability.duration, "ability": ability})
	_report_stars()


func star_cap() -> int:
	return FIRMAMENT_STARS if _firmament else STAR_MAX


func _report_stars() -> void:
	var cells: Array = []
	for star in _stars:
		cells.append(star["cell"])
	for spark in _sparks:
		cells.append(spark["cell"])
	stars_changed.emit(cells)
	var hull := _figure_hull()
	if not hull.is_empty() or _figure_closed:
		_figure_closed = not hull.is_empty()
		var points: Array = []
		for at in hull:
			points.append(at)
		figure_changed.emit(points)


func _update_stars(delta: float, context: CombatContext) -> void:
	for i in range(_falling.size() - 1, -1, -1):
		var fall: Dictionary = _falling[i]
		fall["time_left"] = float(fall["time_left"]) - delta
		if fall.get("big", false):
			if not fall["warned"] and float(fall["time_left"]) <= BIG_METEOR_LEAD:
				fall["warned"] = true
				var prey := int(fall["prey"])
				if prey >= 0 and context.enemy_alive(prey):
					fall["cell"] = context.enemy_cells[prey]
				big_meteor_falling.emit(fall["cell"], BIG_METEOR_LEAD, float(fall["ability"].radius))
		elif not fall["warned"] and float(fall["time_left"]) <= STAR_FALL_LEAD:
			fall["warned"] = true
			star_falling.emit(fall["cell"], STAR_FALL_LEAD)
		if float(fall["time_left"]) <= 0.0:
			_falling.remove_at(i)
			if fall.get("big", false):
				big_meteor_struck.emit(fall["cell"], float(fall["ability"].radius))
			_apply_area(fall["ability"], fall["cell"], context, null, false, false)
	_update_galaxy(delta, context)
	if _stars.is_empty() and _sparks.is_empty():
		return
	var faded := false
	for list: Array[Dictionary] in [_stars, _sparks]:
		for i in range(list.size() - 1, -1, -1):
			list[i]["time_left"] = float(list[i]["time_left"]) - delta
			if float(list[i]["time_left"]) <= 0.0:
				list.remove_at(i)
				faded = true
	if faded:
		_report_stars()
	_star_tick -= delta
	if _star_tick > 0.0 or (_stars.is_empty() and _sparks.is_empty()):
		return
	_star_tick = STAR_TICK
	var ability: Ability = _stars[0]["ability"] if not _stars.is_empty() else _constellation_ability()
	if ability == null:
		return
	# Comme une zone : l'usure est exprimée par seconde, et n'a ni trait ni exaltation.
	var power := FIRMAMENT_RAY if _firmament else 1.0
	var slice := Ability.make({"id": ability.id, "kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": int(round(float(ability.damage) * power * STAR_TICK))})
	var hull := _figure_hull()
	var figure := _constellation_ability()
	var fill: Ability = null
	if not hull.is_empty() and figure != null and figure.figure_damage > 0:
		fill = Ability.make({"id": figure.id, "kind": Ability.Kind.ZONE, "element": figure.element,
			"damage": int(round(float(figure.figure_damage) * STAR_TICK))})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var at := Vector2(context.enemy_cells[i])
		if _on_star_ray(at):
			_apply_damage(i, slice, context, false, false)
		elif fill != null and Geometry2D.is_point_in_polygon(at, hull):
			_apply_damage(i, fill, context, false, false)


## À vol d'oiseau : les rayons passent par-dessus les haies, et le joueur juge à ce qu'il voit.
func _on_star_ray(at: Vector2) -> bool:
	var points: Array[Vector2] = []
	for star in _stars:
		points.append(Vector2(star["cell"]))
	for spark in _sparks:
		points.append(Vector2(spark["cell"]))
	for a in points.size():
		var from := points[a]
		if at.distance_to(from) <= STAR_REACH:
			return true
		for b in range(a + 1, points.size()):
			var closest := Geometry2D.get_closest_point_to_segment(at, from, points[b])
			if at.distance_to(closest) <= STAR_REACH:
				return true
	return false


## Les ennemis à portée d'abord, puis des cases libres du cercle tirées au sort.
func _cast_starfall(ability: Ability, context: CombatContext) -> bool:
	var field := _field_from(context.player_cell)
	var targets: Array[Vector2i] = []
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if context.enemy_alive(i) and not context.is_structure(i) \
				and distance >= 0 and float(distance) <= ability.radius:
			targets.append(context.enemy_cells[i])
	var floor_cells: Array[Vector2i] = []
	var reach := int(ceil(ability.radius))
	for y in range(-reach, reach + 1):
		for x in range(-reach, reach + 1):
			var cell: Vector2i = context.player_cell + Vector2i(x, y)
			var distance := Pathfinder.value_at(grid, field, cell)
			if distance > 0 and float(distance) <= ability.radius:
				floor_cells.append(cell)
	if floor_cells.is_empty():
		use_refused.emit("mur")
		return false
	var noise := RandomNumberGenerator.new()
	noise.seed = hash(context.player_cell) + _next_zone_id
	var hit := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.damage, "radius": 1.0})
	for n in ability.star_falls:
		var cell: Vector2i = targets[n] if n < targets.size() \
			else floor_cells[noise.randi() % floor_cells.size()]
		_falling.append({"cell": cell, "ability": hit, "warned": false,
			"time_left": STAR_FALL_LEAD + float(n) * STAR_FALL_GAP})
	if ability.big_meteor_damage > 0:
		_drop_big_meteor(ability, context, field, floor_cells[noise.randi() % floor_cells.size()])
	return true


## LE GROS MÉTÉORE de la Pluie de météores tombe en dernier sur l'ennemi le plus solide à portée. Il vise au moment
## de s'annoncer, pas au lancer : la proie a eu trois secondes pour bouger.
func _drop_big_meteor(ability: Ability, context: CombatContext, field: PackedInt32Array, fallback: Vector2i) -> void:
	var prey := -1
	var best := -1
	for i in context.enemy_cells.size():
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if not context.enemy_alive(i) or context.is_structure(i) or distance < 0 \
				or float(distance) > ability.radius:
			continue
		if context.enemy_health[i].current > best:
			best = context.enemy_health[i].current
			prey = i
	var hit := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.big_meteor_damage, "radius": ability.big_meteor_radius})
	_falling.append({"cell": context.enemy_cells[prey] if prey >= 0 else fallback, "ability": hit,
		"warned": false, "big": true, "prey": prey,
		"time_left": BIG_METEOR_LEAD + float(ability.star_falls) * STAR_FALL_GAP + BIG_METEOR_PAUSE})


func _burn_trail(from: Vector2i, to: Vector2i, ability: Ability, context: CombatContext) -> void:
	star_trail.emit(from, to)
	var burn := Ability.make({"id": ability.id, "kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": ability.trail_damage})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var at := Vector2(context.enemy_cells[i])
		var closest := Geometry2D.get_closest_point_to_segment(at, Vector2(from), Vector2(to))
		if at.distance_to(closest) <= STAR_REACH:
			_apply_damage(i, burn, context, false, false)
			if ability.blow_cells > 0 and context.enemy_alive(i):
				_push_away(i, context, ability.blow_cells)
			if ability.trail_stun > 0.0 and context.enemy_alive(i):
				enemy_staggered.emit(i, ability.trail_stun)
	if ability.molten_trail_seconds > 0.0:
		_ignite_cells(trajectory(from, to), ability.molten_trail_seconds)


# --- Le pacte ---------------------------------------------------------------------

## La force gagnée par le Démon du Pacte : rien à pleine vie, `RAGE_MAX` à 1 PV.
func rage_bonus() -> float:
	if stats.element != Element.Kind.BLOOD or health.maximum <= 1:
		return 0.0
	var rage := RAGE_MAX * (_blood_rage if _blood_left > 0.0 else 1.0)
	return rage * float(health.maximum - health.current) / float(health.maximum - 1)


# --- L'Archidémon du Pacte (l'Éveil du Démon du Pacte) -------------------------------

## LE PRIX DU SANG : pendant `seconds`, sa vie coule d'1 PV toutes les `every` secondes (jamais le dernier,
## `Health.sacrifice`), chaque ennemi tué lui en rend 1, et sa Rage est multipliée par `rage_factor`.
func start_blood_price(seconds: float, every: float, rage_factor: float) -> void:
	_blood_left = seconds
	_blood_every = maxf(0.5, every)
	_blood_timer = _blood_every
	_blood_rage = rage_factor
	blood_price_changed.emit(true)


func stop_blood_price() -> void:
	if _blood_left <= 0.0:
		return
	_blood_left = 0.0
	blood_price_changed.emit(false)


func blood_pricing() -> bool:
	return _blood_left > 0.0


## Un kill pendant le Prix du Sang : 1 PV rendu, et la traînée part de la proie.
func _feed_blood(cell: Vector2i) -> void:
	blood_fed.emit(cell)
	var gained := health.heal(1)
	if gained > 0:
		player_healed.emit(gained)


func _update_archdemon(delta: float, context: CombatContext) -> void:
	if _blood_left > 0.0:
		_blood_left = maxf(0.0, _blood_left - delta)
		_blood_timer -= delta
		if _blood_timer <= 0.0:
			_blood_timer += _blood_every
			# Intouchable (le Dernier Pacte), il ne paie rien : il est déjà à 1 PV.
			if not health.immune and health.sacrifice(1) > 0:
				blood_price_paid.emit(health.current)
		if _blood_left <= 0.0:
			blood_price_changed.emit(false)
	if _claw_ability == null:
		return
	if _immune_left <= 0.0:
		_claw_ability = null
		return
	_claw_timer -= delta
	if _claw_timer > 0.0:
		return
	_claw_timer += maxf(0.2, _claw_ability.pact_claw_gap)
	var claw := Ability.make({"id": _claw_ability.id + "_serre", "kind": Ability.Kind.BLAST,
		"element": _claw_ability.element, "damage": _claw_ability.pact_claw_damage, "radius": 1.0,
		"range": int(ceil(_claw_ability.radius)) + 3})
	var target := find_target(claw, context)
	if target < 0:
		return
	var cell := context.enemy_cells[target]
	pact_claw_struck.emit(cell)
	_apply_area(claw, cell, context, _claw_ability)


# --- La Démone de la Discorde ---------------------------------------------------------

func _cast_possess(ability: Ability, context: CombatContext) -> bool:
	if ability.is_ultimate:
		for i in context.enemy_cells.size():
			if _possessable(i, context):
				_possess(i, ability, context)
		if ability.ball_burst_damage > 0:
			_ball = {"left": ability.possess_seconds, "ability": ability}
		great_discord_cast.emit(context.player_cell)
		return true
	var target := _nearest_possessable(ability.range, context)
	if target < 0:
		use_refused.emit("cible")
		return false
	_possess(target, ability, context)
	if ability.possess_neighbors > 0:
		_possess_neighbors(target, ability, context)
	return true


## L'ŒIL DE LA REINE : ses deux plus proches voisins, par les couloirs depuis la cible, sont pris avec elle.
func _possess_neighbors(target: int, ability: Ability, context: CombatContext) -> void:
	var cell: Vector2i = context.enemy_cells[target]
	var field := _field_from(cell)
	var near := []
	for i in _creatures_within(cell, ability.radius, context):
		if i != target and _possessable(i, context) and not _possessed.has(i):
			near.append(i)
	near.sort_custom(func(a: int, b: int) -> bool:
		return Pathfinder.value_at(grid, field, context.enemy_cells[a]) \
			< Pathfinder.value_at(grid, field, context.enemy_cells[b]))
	near.resize(mini(near.size(), ability.possess_neighbors))
	var cells := [cell]
	for i: int in near:
		_possess(i, ability, context)
		cells.append(context.enemy_cells[i])
	queen_eye_opened.emit(cell, cells)


func _possessable(index: int, context: CombatContext) -> bool:
	return context.enemy_alive(index) and not context.is_structure(index) \
		and not context.bosses.has(index)


## Le plus proche qu'on peut retourner. Un déjà possédé ne vaut pas un second sort.
func _nearest_possessable(reach: int, context: CombatContext) -> int:
	var best := -1
	var best_distance := reach + 1
	for i in context.enemy_cells.size():
		if not _possessable(i, context) or _possessed.has(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	return best


func _possess(index: int, ability: Ability, context: CombatContext) -> void:
	var seconds := ability.possess_seconds + (TROUBLE_BONUS if _troubled.has(index) else 0.0)
	var strike := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
		"damage": ability.possess_strike})
	_possess_for(index, seconds, strike)


func _possess_for(index: int, seconds: float, strike: Ability) -> void:
	_possessed[index] = {"left": seconds, "timer": 0.0, "strike": strike}
	_foyer_timer = 0.0
	enemy_possessed.emit(index, seconds)


## LA DISCORDE CONTAGIEUSE : pendant `seconds`, chaque coup trouble, et la possession d'un pantin mort saute sur
## son plus proche voisin. `Awakening` la lance et l'arrête ; rien n'en dépend hors de l'Éveil.
func start_contagion() -> void:
	_contagious = true
	contagion_changed.emit(true)


func stop_contagion() -> void:
	if not _contagious:
		return
	_contagious = false
	_jumps_pending.clear()
	contagion_changed.emit(false)


func contagious() -> bool:
	return _contagious


## Les fils des pantins morts passent au plus proche qu'on peut retourner, à `CONTAGION_REACH` au plus.
func _spread_possessions(context: CombatContext) -> void:
	while not _jumps_pending.is_empty():
		var jump: Dictionary = _jumps_pending.pop_front()
		var from: Vector2i = jump["cell"]
		var field := _field_from(from)
		var best := -1
		var best_distance := CONTAGION_REACH + 1
		for i in context.enemy_cells.size():
			if not _possessable(i, context) or _possessed.has(i):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance >= 0 and distance < best_distance:
				best_distance = distance
				best = i
		if best < 0:
			continue
		_possess_for(best, maxf(CONTAGION_MIN, float(jump["left"])), jump["strike"])
		possession_jumped.emit(from, context.enemy_cells[best])


## LE GRAND BAL : chaque mort fait éclater ses fils sur ses voisins. L'éclat attend l'image suivante : une mort
## qu'il provoque éclate à son tour, en cascade, sans jamais rappeler `_apply_area` depuis lui-même.
func _update_ball(delta: float, context: CombatContext) -> void:
	if _ball.is_empty():
		_bursts_pending.clear()
		return
	var ability: Ability = _ball["ability"]
	var cells := _bursts_pending.duplicate()
	_bursts_pending.clear()
	for cell: Vector2i in cells:
		var burst := Ability.make({"id": ability.id + "_eclat", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.ball_burst_damage,
			"radius": ability.ball_burst_radius})
		ball_burst.emit(cell, ability.ball_burst_radius)
		_apply_area(burst, cell, context, null, false, false)
	_ball["left"] = float(_ball["left"]) - delta
	if float(_ball["left"]) <= 0.0:
		_ball = {}


func ball_dancing() -> bool:
	return not _ball.is_empty()


## Les possédés marchent tous vers un même foyer : un seul champ à calculer, même quand toute la
## carte est retournée, et une vraie mêlée à regarder.
func _aim_possessed(context: CombatContext) -> void:
	var first := int(_possessed.keys()[0])
	if _foyer == first or not context.enemy_alive(_foyer) or context.is_structure(_foyer):
		_foyer = -1
		var field := _field_from(context.enemy_cells[first])
		var best := -1
		for i in context.enemy_cells.size():
			if i == first or not context.enemy_alive(i) or context.is_structure(i):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance >= 0 and (best < 0 or distance < best):
				best = distance
				_foyer = i
	possession_field.emit(PackedInt32Array() if _foyer < 0
		else _field_from(context.enemy_cells[_foyer]))


func _brawl_prey(index: int, context: CombatContext) -> int:
	var here: Vector2i = context.enemy_cells[index]
	for i in context.enemy_cells.size():
		if i == index or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var gap: Vector2i = context.enemy_cells[i] - here
		if absi(gap.x) + absi(gap.y) <= 1:
			return i
	return -1


func _update_discord(delta: float, context: CombatContext) -> void:
	if stats.element == Element.Kind.CHARM:
		_spread_possessions(context)
		_update_ball(delta, context)
		# Le pantin du Ballet est un leurre comme celui du Roi de Braise, qui le tient avec ses pièces.
		if _pieces.is_empty():
			_update_decoy(delta, context)
	for index in _troubled.keys():
		_troubled[index] = float(_troubled[index]) - delta
		if float(_troubled[index]) <= 0.0:
			_troubled.erase(index)
	if not _bond.is_empty():
		_bond["left"] = float(_bond["left"]) - delta
		if float(_bond["left"]) <= 0.0:
			_bond.clear()
	if _possessed.is_empty():
		_foyer = -1
		return
	for index: int in _possessed.keys():
		if not _possessed.has(index):
			continue
		var entry: Dictionary = _possessed[index]
		entry["left"] = float(entry["left"]) - delta
		entry["timer"] = float(entry["timer"]) - delta
		if float(entry["left"]) <= 0.0 or not context.enemy_alive(index):
			_possessed.erase(index)
			continue
		if float(entry["timer"]) > 0.0:
			continue
		var prey := _brawl_prey(index, context)
		if prey < 0:
			continue
		entry["timer"] = POSSESS_GAP
		brawl_struck.emit(context.enemy_cells[prey])
		var answers := not _possessed.has(prey)
		_apply_damage(prey, entry["strike"], context, false, false)
		if answers:
			_apply_damage(index, entry["strike"], context, false, false)
	if _possessed.is_empty():
		possession_field.emit(PackedInt32Array())
		return
	_foyer_timer -= delta
	if _foyer_timer <= 0.0:
		_foyer_timer = POSSESS_FIELD_REFRESH
		_aim_possessed(context)


func _add_whisper(index: int, context: CombatContext) -> void:
	if not context.enemy_alive(index):
		return
	var count := int(_whispers.get(index, 0)) + 1
	# La Discorde contagieuse : chaque coup trouble, au lieu d'un sur trois.
	if count < WHISPER_MARKS and not _contagious:
		_whispers[index] = count
		return
	_whispers.erase(index)
	_troubled[index] = TROUBLE_SECONDS
	enemy_soaked.emit(index, TROUBLE_SECONDS, TROUBLE_FACTOR)


## Les créatures dans un rayon, par les couloirs. Un repaire ne se bat avec personne.
## Les créatures à vol d'oiseau, par-dessus les haies. Les repaires n'en sont pas.
func _creatures_in_sky(centre: Vector2i, radius: float, context: CombatContext) -> Array[int]:
	var out: Array[int] = []
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i) \
				and Vector2(context.enemy_cells[i] - centre).length() <= radius:
			out.append(i)
	return out


func _creatures_within(centre: Vector2i, radius: float, context: CombatContext) -> Array[int]:
	var field := _field_from(centre)
	var out: Array[int] = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and float(distance) <= radius:
			out.append(i)
	return out


func _cast_bond(ability: Ability, context: CombatContext) -> bool:
	var first := -1
	var best := ability.range + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance < best:
			best = distance
			first = i
	if first < 0:
		use_refused.emit("cible")
		return false
	var field := _field_from(context.enemy_cells[first])
	var near := _creatures_within(context.enemy_cells[first], ability.radius, context)
	near.sort_custom(func(a: int, b: int) -> bool:
		return Pathfinder.value_at(grid, field, context.enemy_cells[a]) \
			< Pathfinder.value_at(grid, field, context.enemy_cells[b]))
	near.resize(mini(near.size(), ability.bond_count))
	# Un seul maillon ne relie rien : le sort reste prêt pour un vrai groupe.
	if near.size() < 2:
		use_refused.emit("cible")
		return false
	_bond = {"members": near, "left": ability.duration, "share": ability.bond_share,
		"ability": ability}
	web_spun.emit(near)
	return true


## La part qui passe aux autres. Elle ne relance jamais le lien : sinon trois enchaînés se
## renverraient le même coup jusqu'à la mort.
func _relay_bond(index: int, dealt: int, ability: Ability, context: CombatContext) -> void:
	if _bond.is_empty() or index not in _bond["members"]:
		return
	var share := maxi(1, int(round(float(dealt) * float(_bond["share"]))))
	var relay := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
		"damage": share})
	_bond_relaying = true
	for other: int in _bond["members"]:
		if other != index and context.enemy_alive(other):
			bond_struck.emit(context.enemy_cells[other])
			_apply_damage(other, relay, context, false, false)
	_bond_relaying = false


func _cast_swap(ability: Ability, context: CombatContext) -> bool:
	if player_rooted():
		use_refused.emit("immobile")
		return false
	var target := -1
	var best := ability.range + 1
	for i in context.enemy_cells.size():
		if not _possessable(i, context):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance > 0 and distance < best:
			best = distance
			target = i
	if target < 0:
		use_refused.emit("cible")
		return false
	var from := context.player_cell
	var to: Vector2i = context.enemy_cells[target]
	context.enemy_cells[target] = from
	enemy_swapped.emit(target, from)
	enemy_staggered.emit(target, SWAP_STUN)
	blink_performed.emit(from, to)
	# Le Ballet des pantins : sa marionnette reste là où elle était, et les ennemis s'y acharnent.
	if ability.decoy_seconds > 0.0:
		_pose_decoy(from, ability)
	return true


## Ce que le jeu dessine : les possédés, les enchaînés et les toiles des cercles.
func possessed_indices() -> Array:
	return _possessed.keys()


func bond_members() -> Array:
	return [] if _bond.is_empty() else _bond["members"]


func discord_webs() -> Array:
	var webs := []
	for zone in _zones:
		if zone.has("members"):
			webs.append(zone["members"])
	return webs


func whispers_on(index: int) -> int:
	return WHISPER_MARKS if _troubled.has(index) else int(_whispers.get(index, 0))


# --- Le Roi de Braise -----------------------------------------------------------------

## Tout se joue en coordonnées de case, à vol d'oiseau : ses pièces volent par-dessus les haies.
func _update_king(delta: float, context: CombatContext) -> void:
	if _pieces.is_empty():
		return
	while _torn_pending > 0:
		_torn_pending -= 1
		_eject_piece(context)
	var home := Vector2(context.player_cell)
	for i in _pieces.size():
		var piece: Dictionary = _pieces[i]
		match piece["state"]:
			Piece.ORBIT:
				piece["pos"] = home
			Piece.HUNT:
				_step_hunter(piece, delta, context)
			Piece.POSED:
				_step_chest(piece, delta, context)
			Piece.BITE:
				_step_bite(piece, delta, context)
			Piece.LOOSE:
				piece["pos"] = (piece["pos"] as Vector2).move_toward(piece["throw"], RECALL_SPEED * delta)
				_count_down(piece, delta)
			Piece.RETURN:
				_fly_home(piece, RETURN_SPEED, delta, home, false, context)
			Piece.RECALL:
				_fly_home(piece, RECALL_SPEED, delta, home, true, context)
		_leave_ashes(piece)
	_update_decoy(delta, context)
	_update_cages(delta, context)


## LE SILLAGE DE CENDRES : une pièce qui vole met le feu à chaque case qu'elle franchit. Le Retour de l'Empire
## en laisse autant, éveillé ou non, sur sa ligne : c'est son mur de flammes.
func _leave_ashes(piece: Dictionary) -> void:
	var state: int = piece["state"]
	if state == Piece.ORBIT or state == Piece.POSED or state == Piece.BITE:
		piece.erase("ash")
		return
	var seconds := ASH_SECONDS if _ashes else 0.0
	var ability: Ability = piece["ability"]
	if state == Piece.RECALL and ability != null:
		seconds = maxf(seconds, ability.recall_fire_seconds)
	if seconds <= 0.0:
		return
	var cell := Vector2i((piece["pos"] as Vector2).round())
	if piece.get("ash", Vector2i(-1, -1)) == cell:
		return
	piece["ash"] = cell
	_ignite_cells([cell], seconds)


func start_ashes() -> void:
	_ashes = true
	ashes_changed.emit(true)


func stop_ashes() -> void:
	if not _ashes:
		return
	_ashes = false
	ashes_changed.emit(false)


func ashes_burning() -> bool:
	return _ashes


func _count_down(piece: Dictionary, delta: float) -> void:
	piece["left"] = float(piece["left"]) - delta
	if float(piece["left"]) <= 0.0:
		piece["state"] = Piece.RETURN


## La première pièce en orbite part : un gantelet d'abord, le plastron n'en sort qu'en dernier.
func _eject_piece(context: CombatContext) -> void:
	for piece in _pieces:
		if piece["state"] != Piece.ORBIT:
			continue
		var angle := _rng.randf() * TAU
		piece["state"] = Piece.LOOSE
		piece["pos"] = Vector2(context.player_cell)
		piece["throw"] = piece["pos"] + Vector2.from_angle(angle) * LOOSE_THROW
		piece["left"] = ASH_RETURN if _ashes else PIECE_AUTO_RETURN
		_sync_orbit()
		piece_ejected.emit(context.player_cell)
		var blow := Ability.make({"id": "braise_eclat", "kind": Ability.Kind.BLAST,
			"element": stats.element, "damage": EJECT_DAMAGE, "radius": EJECT_RADIUS})
		_apply_area(blow, context.player_cell, context, null, false, false)
		return


func _nearest_creature(from: Vector2, context: CombatContext, reach: float = INF) -> int:
	var best := -1
	var best_distance := reach
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := from.distance_to(Vector2(context.enemy_cells[i]))
		if distance < best_distance:
			best_distance = distance
			best = i
	return best


func _cast_hunters(ability: Ability, context: CombatContext) -> bool:
	var home := Vector2(context.player_cell)
	if _nearest_creature(home, context, float(ability.range)) < 0:
		use_refused.emit("cible")
		return false
	var sent := 0
	for i in GAUNTLETS:
		var piece: Dictionary = _pieces[i]
		if piece["state"] == Piece.ORBIT:
			piece["state"] = Piece.HUNT
			piece["pos"] = home
			piece["left"] = ability.duration
			piece["timer"] = 0.0
			piece["ability"] = ability
			sent += 1
	if sent == 0:
		use_refused.emit("armure")
		return false
	_sync_orbit()
	hunters_cast.emit(context.player_cell)
	return true


func _step_hunter(piece: Dictionary, delta: float, context: CombatContext) -> void:
	_count_down(piece, delta)
	if piece["state"] != Piece.HUNT:
		return
	var prey := _nearest_creature(piece["pos"], context)
	if prey < 0:
		piece["state"] = Piece.RETURN
		return
	var at := Vector2(context.enemy_cells[prey])
	piece["pos"] = (piece["pos"] as Vector2).move_toward(at, HUNT_SPEED * delta)
	piece["timer"] = float(piece["timer"]) - delta
	if float(piece["timer"]) <= 0.0 and (piece["pos"] as Vector2).distance_to(at) <= HUNT_REACH:
		piece["timer"] = HUNT_GAP
		piece_struck.emit(context.enemy_cells[prey])
		var ability: Ability = piece["ability"]
		# Les Gantelets de l'Empereur crachent une gerbe de lave autour de la proie.
		if ability.radius > 0.0:
			gauntlet_splashed.emit(context.enemy_cells[prey], ability.radius)
			_apply_area(ability, context.enemy_cells[prey], context, null, false, true)
		else:
			_apply_damage(prey, ability, context, false, true)


func _cast_chest(ability: Ability, context: CombatContext) -> bool:
	var piece: Dictionary = _pieces[CHEST_PIECE]
	if piece["state"] != Piece.ORBIT:
		use_refused.emit("armure")
		return false
	piece["state"] = Piece.POSED
	piece["pos"] = Vector2(context.player_cell)
	piece["left"] = PIECE_AUTO_RETURN
	piece["ability"] = ability
	piece["prey"] = -1
	_sync_orbit()
	chest_posed.emit(context.player_cell)
	return true


func _step_chest(piece: Dictionary, delta: float, context: CombatContext) -> void:
	_count_down(piece, delta)
	if piece["state"] != Piece.POSED:
		return
	var at := Vector2i(piece["pos"])
	_forge_pull(piece, delta, at, context)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var gap: Vector2i = context.enemy_cells[i] - at
		if absi(gap.x) + absi(gap.y) > 1:
			continue
		var ability: Ability = piece["ability"]
		if context.bosses.has(i):
			chest_bit.emit(context.enemy_cells[i], 0.0)
			var bite := Ability.make({"id": ability.id, "kind": ability.kind,
				"element": ability.element, "damage": CHEST_BOSS_BITE})
			_apply_damage(i, bite, context, false, false)
			chest_spat.emit(context.enemy_cells[i])
			piece["state"] = Piece.RETURN
			return
		piece["state"] = Piece.BITE
		piece["prey"] = i
		piece["left"] = ability.hold_seconds
		piece["timer"] = 0.0
		piece["pos"] = Vector2(context.enemy_cells[i])
		enemy_staggered.emit(i, ability.hold_seconds)
		chest_bit.emit(context.enemy_cells[i], ability.hold_seconds)
		return


func _step_bite(piece: Dictionary, delta: float, context: CombatContext) -> void:
	var prey: int = piece["prey"]
	if not context.enemy_alive(prey):
		chest_spat.emit(Vector2i(piece["pos"]))
		_forge_blast(piece, context)
		piece["state"] = Piece.RETURN
		return
	piece["pos"] = Vector2(context.enemy_cells[prey])
	_forge_pull(piece, delta, context.enemy_cells[prey], context)
	piece["timer"] = float(piece["timer"]) - delta
	if float(piece["timer"]) <= 0.0:
		piece["timer"] = ZONE_TICK
		var ability: Ability = piece["ability"]
		var slice := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
			"damage": int(round(ability.damage * ZONE_TICK))})
		_apply_damage(prey, slice, context, false, false)
	piece["left"] = float(piece["left"]) - delta
	if float(piece["left"]) <= 0.0:
		chest_spat.emit(context.enemy_cells[prey])
		_forge_blast(piece, context)
		piece["state"] = Piece.RETURN


## LA FORGE IMPÉRIALE aspire vers elle ce qui est à `forge_pull` cases, une case à la fois.
func _forge_pull(piece: Dictionary, delta: float, at: Vector2i, context: CombatContext) -> void:
	var ability: Ability = piece["ability"]
	if ability == null or ability.forge_pull <= 0.0:
		return
	piece["pull"] = float(piece.get("pull", 0.0)) - delta
	if float(piece["pull"]) > 0.0:
		return
	piece["pull"] = FORGE_PULL_GAP
	forge_pulled.emit(at)
	_pull_toward(at, 1.0, ability.forge_pull, context)


## Elle recrache sa proie en explosant : un champignon de feu.
func _forge_blast(piece: Dictionary, context: CombatContext) -> void:
	var ability: Ability = piece["ability"]
	if ability == null or ability.forge_blast_damage <= 0:
		return
	var cell := Vector2i((piece["pos"] as Vector2).round())
	var blast := Ability.make({"id": ability.id + "_explosion", "kind": Ability.Kind.BLAST,
		"element": ability.element, "damage": ability.forge_blast_damage, "radius": ability.forge_blast_radius})
	forge_blew.emit(cell, ability.forge_blast_radius)
	_apply_area(blast, cell, context, null, false, true)


func _cast_recall(ability: Ability, context: CombatContext) -> bool:
	var called := 0
	for piece in _pieces:
		if piece["state"] == Piece.ORBIT or piece["state"] == Piece.RECALL:
			continue
		piece["state"] = Piece.RECALL
		piece["ability"] = ability
		piece["hit"] = {}
		called += 1
		piece_recalled.emit(Vector2i((piece["pos"] as Vector2).round()))
	if called == 0:
		use_refused.emit("armure")
		return false
	# Le Retour de l'Empire : l'onde ne part que si les trois pièces reviennent ensemble.
	_empire_wave = ability if ability.recall_wave_damage > 0 and called == PIECES_MAX else null
	recall_cast.emit(context.player_cell)
	return true


func _fly_home(piece: Dictionary, speed: float, delta: float, home: Vector2, strikes: bool,
		context: CombatContext) -> void:
	piece["pos"] = (piece["pos"] as Vector2).move_toward(home, speed * delta)
	if strikes:
		for i in context.enemy_cells.size():
			if piece["hit"].has(i) or not context.enemy_alive(i) or context.is_structure(i):
				continue
			if (piece["pos"] as Vector2).distance_to(Vector2(context.enemy_cells[i])) <= RECALL_REACH:
				piece["hit"][i] = true
				piece_struck.emit(context.enemy_cells[i])
				_apply_damage(i, piece["ability"], context, false, true)
	if (piece["pos"] as Vector2).distance_to(home) <= PIECE_HOME:
		piece["state"] = Piece.ORBIT
		_sync_orbit()
		piece_returned.emit(strikes)
		if strikes and _empire_wave != null and health.plates == PIECES_MAX:
			var ability := _empire_wave
			_empire_wave = null
			var wave := Ability.make({"id": ability.id + "_onde", "kind": Ability.Kind.BLAST,
				"element": ability.element, "damage": ability.recall_wave_damage,
				"radius": ability.recall_wave_radius})
			empire_wave.emit(context.player_cell, ability.recall_wave_radius)
			_apply_area(wave, context.player_cell, context, null, false, true)


## Les pièces en orbite sont les plaques de `Health` : c'est elles qui encaissent.
func _sync_orbit() -> void:
	var count := 0
	for piece in _pieces:
		if piece["state"] == Piece.ORBIT:
			count += 1
	health.plates = count


func _pose_decoy(cell: Vector2i, ability: Ability) -> void:
	_decoy = {"cell": cell, "left": ability.decoy_seconds, "ability": ability}
	decoy_field.emit(_field_from(cell))
	decoy_posed.emit(cell, ability.decoy_seconds)


func _update_decoy(delta: float, context: CombatContext) -> void:
	if _decoy.is_empty():
		return
	_decoy["left"] = float(_decoy["left"]) - delta
	if float(_decoy["left"]) > 0.0:
		return
	var ability: Ability = _decoy["ability"]
	var cell: Vector2i = _decoy["cell"]
	_decoy = {}
	decoy_field.emit(PackedInt32Array())
	var blast := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.damage, "radius": ability.decoy_radius, "cuts": ability.cuts})
	_apply_area(blast, cell, context, null, false, false)
	decoy_blew.emit(cell, ability.decoy_radius)


func _cast_cages(ability: Ability, context: CombatContext) -> bool:
	_caged.clear()
	var indices := []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		_caged[i] = true
		# Le boss ne se laisse pas enfermer : la cage éclate sur lui, et il prend le coup à la fin.
		if not context.bosses.has(i):
			indices.append(i)
			enemy_staggered.emit(i, ability.duration)
	_cage_left = ability.duration
	_cage_ability = ability
	cages_cast.emit(context.player_cell, indices, ability.duration)
	return true


func _update_cages(delta: float, context: CombatContext) -> void:
	if _cage_ability == null:
		return
	_cage_left -= delta
	if _cage_left > 0.0:
		return
	var ability := _cage_ability
	_cage_ability = null
	var cells := []
	for index: int in _caged.keys():
		if context.enemy_alive(index):
			cells.append(context.enemy_cells[index])
			_apply_damage(index, ability, context, false, false)
	_caged.clear()
	cages_crushed.emit(cells)
	# L'Empire des Cendres : chaque cage éclate en colonne de lave, et blesse ses voisins.
	if ability.cage_burst_damage > 0:
		var burst := Ability.make({"id": ability.id + "_colonne", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.cage_burst_damage,
			"radius": ability.cage_burst_radius})
		for cell: Vector2i in cells:
			cage_burst.emit(cell, ability.cage_burst_radius)
			_apply_area(burst, cell, context, null, false, false)


## Ce que le jeu dessine : où est chaque pièce, en cases, et ce qu'elle fait.
func pieces() -> Array[Dictionary]:
	return _pieces


## Ce que les pièces lancées ajoutent à son allure.
func armor_speed() -> float:
	# Le Dragon seul va plus vite dans le feu : les cendres de l'Empereur sont aussi des cases en feu.
	if stats.element == Element.Kind.INFERNO and _fire_cells.has(_dragon_cell):
		return stats.move_speed * INFERNO_SPEED
	if _pieces.is_empty():
		return 0.0
	return PIECE_SPEED_BONUS * float(PIECES_MAX - health.plates)


# --- Le Chevalier Écarlate ------------------------------------------------------------

func _add_cuts(index: int, count: int, may_open: bool = true) -> void:
	# La Lame affûtée : une de plus par coup, jusqu'à huit, et à huit elles s'ouvrent seules.
	var cap := KEEN_CUTS_MAX if _keen else CUTS_MAX
	if _keen and may_open:
		count += 1
	var total := mini(cap, int(_cuts.get(index, {}).get("count", 0)) + count)
	_cuts[index] = {"count": total, "left": CUT_SECONDS}
	enemy_cuts.emit(index, total)
	if _keen and may_open and total >= KEEN_CUTS_MAX and index not in _keen_pending:
		_keen_pending.append(index)


func start_keen() -> void:
	_keen = true
	keen_changed.emit(true)


func stop_keen() -> void:
	if not _keen:
		return
	_keen = false
	_keen_pending.clear()
	for index: int in _cuts.keys():
		if int(_cuts[index]["count"]) > CUTS_MAX:
			_cuts[index]["count"] = CUTS_MAX
			enemy_cuts.emit(index, CUTS_MAX)
	keen_changed.emit(false)


func keen() -> bool:
	return _keen


## Un ennemi arrivé au bout ouvre ses entailles de lui-même, à l'image suivante : jamais depuis `_apply_damage`.
func _open_keen_cuts(context: CombatContext) -> void:
	var opened := _keen_pending.duplicate()
	_keen_pending.clear()
	for index: int in opened:
		var count := cuts_on(index)
		if count <= 0 or not context.enemy_alive(index):
			continue
		_cuts.erase(index)
		enemy_cuts.emit(index, 0)
		keen_burst.emit(context.enemy_cells[index], count)
		cut_burst.emit(context.enemy_cells[index], count)
		var blow := Ability.make({"id": "ecarlate_affutee", "kind": Ability.Kind.SHEATHE,
			"element": stats.element, "damage": KEEN_CUT_DAMAGE * count})
		_apply_damage(index, blow, context, false, false)


func cuts_on(index: int) -> int:
	return int(_cuts.get(index, {}).get("count", 0))


func _cast_dash(ability: Ability, context: CombatContext) -> bool:
	if player_rooted():
		use_refused.emit("immobile")
		return false
	var from := context.player_cell
	var to := from
	var crossed: Array[Vector2i] = []
	for step in ability.range:
		var next: Vector2i = to + context.player_facing
		if not grid.is_floor_v(next):
			break
		to = next
		crossed.append(to)
	if to == from:
		use_refused.emit("mur")
		return false
	blink_performed.emit(from, to)
	dash_cut.emit(from, to)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i) and context.enemy_cells[i] in crossed:
			_apply_damage(i, ability, context, false, true)
			# Le Trait de l'étoile aveugle ce qu'il traverse.
			if ability.blind_seconds > 0.0:
				_blind(i, ability.blind_seconds, context)
	# Le Pas des Mille Lames : la lame fantôme repasse sur le même couloir.
	if ability.dash_echo_damage > 0:
		_dash_echo = {"left": ability.dash_echo_delay, "from": from, "to": to, "cells": crossed,
			"ability": Ability.make({"id": ability.id + "_echo", "kind": ability.kind,
				"element": ability.element, "damage": ability.dash_echo_damage,
				"cuts": ability.dash_echo_cuts})}
	return true


func _cast_guard(ability: Ability) -> bool:
	_guard = ability
	_parry_pending = false
	health.immune = true
	_immune_left = ability.duration
	guard_raised.emit(ability.duration)
	return true


func _cast_sheathe(ability: Ability, context: CombatContext) -> bool:
	var targets := []
	var cells := []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		if ability.is_ultimate:
			_add_cuts(i, ability.cuts, false)
		elif not _cuts.has(i) or not _in_reach(i, ability.range, context):
			continue
		targets.append(i)
		cells.append(context.enemy_cells[i])
	# Un fourreau qui claque sur rien ne coûte rien : l'ultime, lui, ne se refuse que sans proie.
	if targets.is_empty():
		use_refused.emit("cible")
		return false
	var seconds := ability.duration if ability.is_ultimate else SHEATHE_SILENCE
	_sheathe = {"left": seconds, "targets": targets, "ability": ability}
	sheathe_begun.emit(context.player_cell, cells, seconds, ability.is_ultimate)
	return true


func _in_reach(index: int, reach: int, context: CombatContext) -> bool:
	var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[index])
	return distance >= 0 and distance <= reach


func _update_blade(delta: float, context: CombatContext) -> void:
	_parry_lock = maxf(0.0, _parry_lock - delta)
	if _parry_pending and _guard != null and _guard.guard_all:
		# La Garde du Seigneur pare tout et riposte à chaque coup, une fois par `PARRY_LOCK`.
		_parry_pending = false
		if _parry_lock <= 0.0:
			_parry_lock = PARRY_LOCK
			guard_parried.emit(context.player_cell)
			_apply_area(_guard, context.player_cell, context)
	if _parry_pending:
		_parry_pending = false
		var answer := _guard
		_guard = null
		_immune_left = 0.0
		health.immune = false
		player_immunity_faded.emit()
		guard_parried.emit(context.player_cell)
		if answer != null:
			_apply_area(answer, context.player_cell, context)
	if not _keen_pending.is_empty():
		_open_keen_cuts(context)
	if not _dash_echo.is_empty():
		_dash_echo["left"] = float(_dash_echo["left"]) - delta
		if float(_dash_echo["left"]) <= 0.0:
			var echo: Dictionary = _dash_echo
			_dash_echo = {}
			dash_echoed.emit(echo["from"], echo["to"])
			for i in context.enemy_cells.size():
				if context.enemy_alive(i) and not context.is_structure(i) and context.enemy_cells[i] in echo["cells"]:
					_apply_damage(i, echo["ability"], context, false, true)
	# La Danse des pétales est un leurre comme celui du Roi de Braise, qui le tient avec ses pièces.
	if stats.element == Element.Kind.BLADE and _pieces.is_empty():
		_update_decoy(delta, context)
	for index: int in _cuts.keys():
		_cuts[index]["left"] = float(_cuts[index]["left"]) - delta
		if float(_cuts[index]["left"]) <= 0.0:
			_cuts.erase(index)
			enemy_cuts.emit(index, 0)
	if _sheathe.is_empty():
		return
	_sheathe["left"] = float(_sheathe["left"]) - delta
	if float(_sheathe["left"]) > 0.0:
		return
	var ability: Ability = _sheathe["ability"]
	var targets: Array = _sheathe["targets"]
	_sheathe = {}
	for index: int in targets:
		var count := cuts_on(index)
		if count <= 0 or not context.enemy_alive(index):
			continue
		_cuts.erase(index)
		enemy_cuts.emit(index, 0)
		cut_burst.emit(context.enemy_cells[index], count)
		var blow := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
			"damage": ability.cut_damage * count})
		var from: Vector2i = context.enemy_cells[index]
		_apply_damage(index, blow, context, false, false)
		# La Rengaine écarlate : les pétales-lames de l'éclat entaillent ses voisins.
		if ability.petal_cuts > 0:
			for other in _creatures_within(from, ability.petal_radius, context):
				if other != index and other not in targets:
					petals_flung.emit(from, context.enemy_cells[other])
					_add_cuts(other, ability.petal_cuts, false)
	sheathe_ended.emit(ability.is_ultimate)


# --- Le Geôlier ------------------------------------------------------------------------

func _add_shackle_hit(index: int, context: CombatContext) -> void:
	if not context.enemy_alive(index) or context.bosses.has(index):
		return
	var count := int(_shackle_hits.get(index, 0)) + 1
	if count < (ABYSS_SHACKLE_HITS if _abyss else SHACKLE_HITS):
		_shackle_hits[index] = count
		return
	_shackle_hits.erase(index)
	enemy_staggered.emit(index, SHACKLE_SECONDS)
	enemy_shackled.emit(index, SHACKLE_SECONDS)


## Le souffle fige ce qu'il touche, par les couloirs, comme ses dégâts. Un boss n'est pas figé.
## Un sort qui passe les haies (`pierces_walls`) fige à vol d'oiseau, comme ses dégâts.
func _freeze_around(ability: Ability, context: CombatContext, centre: Vector2i = Vector2i(-1, -1)) -> void:
	if centre == Vector2i(-1, -1):
		centre = context.player_cell
	var frozen := []
	var caught := _creatures_in_sky(centre, ability.radius, context) if ability.pierces_walls \
		else _creatures_within(centre, ability.radius, context)
	for i in caught:
		if context.bosses.has(i):
			continue
		frozen.append(i)
		enemy_staggered.emit(i, ability.stun_seconds)
	if not frozen.is_empty():
		enemies_frozen.emit(frozen, ability.stun_seconds)
		enemies_dazed.emit(frozen, ability.stun_seconds, ability)


## Le plus éloigné qu'on puisse ramener, par les couloirs. Il atterrit à une case du lanceur, sur
## son propre chemin : jamais sur la case du mage, et jamais de l'autre côté d'une haie.
func _cast_hook(ability: Ability, context: CombatContext) -> bool:
	# Les plus éloignés d'abord ; les Crochets de l'Abîme en prennent `hook_count` à la fois.
	var candidates := []
	for i in context.enemy_cells.size():
		if not _possessable(i, context):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance > 1 and distance <= ability.range:
			candidates.append(i)
	if candidates.is_empty():
		use_refused.emit("cible")
		return false
	candidates.sort_custom(func(a: int, b: int) -> bool:
		return Pathfinder.value_at(grid, context.player_field, context.enemy_cells[a]) \
			> Pathfinder.value_at(grid, context.player_field, context.enemy_cells[b]))
	candidates.resize(mini(candidates.size(), maxi(1, ability.hook_count)))
	var field := _field_from(context.player_cell)
	var landed := []
	for target: int in candidates:
		var from: Vector2i = context.enemy_cells[target]
		var to := from
		# Chacun s'arrête à une case du lanceur, ou juste avant celui qui y est déjà.
		while Pathfinder.value_at(grid, field, to) > 1:
			var next: Vector2i = Pathfinder.step_toward(grid, field, to) + to
			if next in landed:
				break
			to = next
		landed.append(to)
		context.enemy_cells[target] = to
		enemy_hooked.emit(target, from, to)
		enemy_staggered.emit(target, ability.stun_seconds)
		_apply_damage(target, ability, context, false, true)
	return true


func _cast_soul_chains(ability: Ability, context: CombatContext) -> bool:
	var near := _creatures_within(context.player_cell, float(ability.range), context)
	var field := _field_from(context.player_cell)
	near.sort_custom(func(a: int, b: int) -> bool:
		return Pathfinder.value_at(grid, field, context.enemy_cells[a]) \
			< Pathfinder.value_at(grid, field, context.enemy_cells[b]))
	near.resize(mini(near.size(), ability.bond_count))
	if near.is_empty():
		use_refused.emit("cible")
		return false
	_soul_chains = {"members": near, "left": ability.duration, "tick": 0.0, "ability": ability}
	for i: int in near:
		enemy_soaked.emit(i, ability.duration, ability.slow_factor)
	soul_chains_cast.emit(near, ability.duration)
	return true


func _cast_gaol(ability: Ability, context: CombatContext) -> bool:
	var members := []
	var held := []
	var centre := Vector2(context.player_cell)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		if centre.distance_to(Vector2(context.enemy_cells[i])) > ability.radius:
			continue
		members.append(i)
		if not context.bosses.has(i):
			held.append(i)
			enemy_staggered.emit(i, ability.duration)
	_gaol = {"members": members, "left": ability.duration, "tick": 0.0, "ability": ability}
	gaol_cast.emit(context.player_cell, held, ability.radius, ability.duration)
	return true


## Les chaînes et la Geôle rongent au rythme des zones : une usure, pas une rafale.
func _burn_members(state: Dictionary, delta: float, context: CombatContext) -> void:
	state["left"] = float(state["left"]) - delta
	state["tick"] = float(state["tick"]) - delta
	if float(state["tick"]) > 0.0:
		return
	state["tick"] = ZONE_TICK
	var ability: Ability = state["ability"]
	var slice := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
		"damage": int(round(ability.damage * ZONE_TICK))})
	for i: int in state["members"]:
		if context.enemy_alive(i):
			_apply_damage(i, slice, context, false, false)


func _update_gaoler(delta: float, context: CombatContext) -> void:
	for index in _held.keys():
		_held[index] = float(_held[index]) - delta
		if float(_held[index]) <= 0.0:
			_held.erase(index)
	if not _soul_chains.is_empty():
		_burn_members(_soul_chains, delta, context)
		if float(_soul_chains["left"]) <= 0.0:
			var chained: Ability = _soul_chains["ability"]
			var members: Array = _soul_chains["members"]
			_soul_chains = {}
			if chained.snap_damage > 0:
				_snap_chains(members, chained, context)
	if not _gaol.is_empty():
		_burn_members(_gaol, delta, context)
		var holding: Ability = _gaol["ability"]
		if holding.gaol_pull_gap > 0.0 and float(_gaol["left"]) > 0.0:
			_gaol["pull"] = float(_gaol.get("pull", holding.gaol_pull_gap)) - delta
			if float(_gaol["pull"]) <= 0.0:
				_gaol["pull"] = holding.gaol_pull_gap
				_drag_prisoners(_gaol["members"], context)
		if float(_gaol["left"]) <= 0.0:
			var cells := []
			for i: int in _gaol["members"]:
				if context.enemy_alive(i):
					cells.append(context.enemy_cells[i])
			var members: Array = _gaol["members"]
			_gaol = {}
			gaol_ended.emit(cells)
			# L'Abîme se referme : chaque prisonnier encore vivant prend le coup de mâchoire.
			if holding.gaol_end_damage > 0:
				abyss_closed.emit(cells)
				var jaw := Ability.make({"id": holding.id + "_machoire", "kind": Ability.Kind.BLAST,
					"element": holding.element, "damage": holding.gaol_end_damage})
				for i: int in members:
					if context.enemy_alive(i):
						_apply_damage(i, jaw, context, false, false)


## LE POIDS DES CHAÎNES : ce qui est sonné le reste ce temps-là dans le registre, pendant l'Éveil seulement.
func _note_held(index: int, seconds: float) -> void:
	if _abyss and seconds > 0.0:
		_held[index] = maxf(float(_held.get(index, 0.0)), seconds)


func start_abyss() -> void:
	_abyss = true
	abyss_changed.emit(true)


func stop_abyss() -> void:
	if not _abyss:
		return
	_abyss = false
	_held.clear()
	abyss_changed.emit(false)


func abyss_open() -> bool:
	return _abyss


func held(index: int) -> bool:
	return _held.has(index)


## Les Chaînes de l'Abîme se resserrent d'un coup en cédant : chaque proie est blessée et prise dans la glace.
func _snap_chains(members: Array, ability: Ability, context: CombatContext) -> void:
	var caught := []
	var snap := Ability.make({"id": ability.id + "_serre", "kind": ability.kind,
		"element": ability.element, "damage": ability.snap_damage})
	for i: int in members:
		if not context.enemy_alive(i):
			continue
		_apply_damage(i, snap, context, false, false)
		if context.enemy_alive(i) and not context.bosses.has(i):
			caught.append(i)
			enemy_staggered.emit(i, ability.snap_stun)
	if not caught.is_empty():
		chains_snapped.emit(caught, ability.snap_stun)


## L'Abîme tire chacun de ses prisonniers d'une case vers le Gardien, par les couloirs, jamais sur lui.
func _drag_prisoners(members: Array, context: CombatContext) -> void:
	var field := _field_from(context.player_cell)
	for i: int in members:
		if not context.enemy_alive(i) or context.bosses.has(i) or context.is_structure(i):
			continue
		var here: Vector2i = context.enemy_cells[i]
		if Pathfinder.value_at(grid, field, here) <= 1:
			continue
		var next: Vector2i = here + Pathfinder.step_toward(grid, field, here)
		if next == here:
			continue
		context.enemy_cells[i] = next
		enemy_pushed.emit(i, next)


## Ce que le jeu dessine : les ennemis enchaînés au Geôlier, et ceux que la Geôle cloue.
func soul_chain_members() -> Array:
	return [] if _soul_chains.is_empty() else _soul_chains["members"]


func gaol_members() -> Array:
	return [] if _gaol.is_empty() else _gaol["members"]


func _can_pay(ability: Ability) -> bool:
	return ability.self_cost <= 0 or health.current > ability.self_cost


# --- L'acier ----------------------------------------------------------------------

# --- Le Phénix (l'Éveil du Mage du Feu) ---------------------------------------------

func _pour_magma(ability: Ability, cell: Vector2i) -> void:
	var magma := Ability.make({
		"id": ability.id + "_magma", "display_name": ability.display_name,
		"kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": ability.magma_damage, "radius": ability.radius * 0.7,
		"duration": ability.magma_duration, "zone_style": "magma_peint", "flames": 0.5,
	})
	var id := _next_zone_id
	_next_zone_id += 1
	_zones.append({"id": id, "ability": magma, "cell": cell, "time_left": magma.duration, "tick": 0.0})
	zone_created.emit(id, magma, cell)


## LES COLONNES DE FEU : des piliers en cercle autour de lui. Un pilier qui tomberait dans une haie
## jaillit sur la case de sol voisine, ou pas du tout. Chaque ennemi n'est frappé qu'une fois.
func _cast_pillars(ability: Ability, context: CombatContext) -> bool:
	var cells: Array[Vector2i] = []
	var facing := Vector2(context.player_facing) if context.player_facing != Vector2i.ZERO else Vector2.DOWN
	for k in ability.pillar_count:
		var direction := facing.rotated(TAU * float(k) / float(maxi(1, ability.pillar_count)))
		var spot := context.player_cell + Vector2i((direction * ability.pillar_ring).round())
		if not grid.is_floor_v(spot):
			var moved := false
			for side: Vector2i in MazeGrid.NEIGHBORS:
				if grid.is_floor_v(spot + side) and not cells.has(spot + side) and spot + side != context.player_cell:
					spot += side
					moved = true
					break
			if not moved:
				continue
		if not cells.has(spot):
			cells.append(spot)
	if cells.is_empty():
		use_refused.emit("mur")
		return false
	var struck := {}
	for spot in cells:
		for i in _creatures_within(spot, ability.radius, context):
			struck[i] = true
	pillars_erupted.emit(cells, ability)
	for i: int in struck.keys():
		if context.enemy_alive(i):
			_apply_damage(i, ability, context)
	return true


## L'onde de la Renaissance, ou tout autre éclat posé par le jeu autour du mage.
func erupt(ability: Ability, context: CombatContext) -> void:
	_apply_area(ability, context.player_cell, context, null, false, false)


## La traînée de braises du Phénix : il en laisse une sur chaque case qu'il quitte, tant qu'elle
## dure. Une braise brûle ce qui s'y tient, une fois par seconde.
func start_embers(seconds: float, damage: int, life: float) -> void:
	_ember_left = seconds
	_ember_damage = damage
	_ember_life = life
	_ember_from = Vector2i(-9999, -9999)


func stop_embers() -> void:
	_ember_left = 0.0


func _update_phoenix(delta: float, context: CombatContext) -> void:
	for i in range(_echo_blasts.size() - 1, -1, -1):
		var echo: Dictionary = _echo_blasts[i]
		echo["time_left"] = float(echo["time_left"]) - delta
		if float(echo["time_left"]) > 0.0:
			continue
		_echo_blasts.remove_at(i)
		var source: Ability = echo["ability"]
		echo_blasted.emit(echo["cell"], source)
		_apply_area(Ability.make({"id": source.id + "_echo", "kind": Ability.Kind.BLAST,
			"element": source.element, "damage": source.echo_damage, "radius": source.radius}),
			echo["cell"], context, null, false, false)
	if _ember_left > 0.0:
		_ember_left = maxf(0.0, _ember_left - delta)
		if _ember_from != context.player_cell:
			if _ember_from.x > -9999 and grid.is_floor_v(_ember_from):
				_embers[_ember_from] = _ember_life
				ember_laid.emit(_ember_from, _ember_life)
			_ember_from = context.player_cell
	if _embers.is_empty():
		return
	_ember_tick -= delta
	var bite := _ember_tick <= 0.0
	if bite:
		_ember_tick += 1.0
	for cell: Vector2i in _embers.keys():
		var left: float = _embers[cell] - delta
		if left <= 0.0:
			_embers.erase(cell)
			continue
		_embers[cell] = left
		if not bite:
			continue
		for i in context.enemy_cells.size():
			if context.enemy_alive(i) and not context.is_structure(i) and context.enemy_cells[i] == cell:
				_apply_damage(i, Ability.make({"id": stats.id + "_braise", "kind": Ability.Kind.BLAST,
					"element": stats.element, "damage": _ember_damage}), context, false, false)


# --- Le Colosse (l'Éveil du Mage de la Terre) --------------------------------------

## Un même ennemi n'est piétiné qu'une fois par seconde au plus.
const TRAMPLE_LOCK := 1.0
## Le Rempart de vent ralentit ce qu'il repousse à cette part de son allure.
const GALE_SLOW_FACTOR := 0.5
## La première colonne de lave attend que le sol ait commencé de craquer.
const LAVA_DELAY := 0.5
## Les colonnes visent les ennemis à cette distance du mage, à vol d'oiseau ; au-delà, le hasard.
const LAVA_REACH := 9.0


## PIÉTINEMENT : il marche à travers les ennemis. Ce qu'il touche (sa case ou une voisine) est
## repoussé de `cells` cases et prend `damage`. Les boss et les repaires encaissent sans bouger.
## Le REMPART DE VENT du Souverain réemploie ce pas : sans dégâts, avec un verrou plus long et un
## ralentissement (`lock`, `slow`).
func start_trample(seconds: float, damage: int, cells: int, lock: float = TRAMPLE_LOCK,
		slow: float = 0.0) -> void:
	_trample_left = seconds
	_trample_damage = damage
	_trample_cells = cells
	_trample_lock = lock
	_trample_slow = slow
	_trample_locks.clear()
	_trample_from = Vector2i(-9999, -9999)


func stop_trample() -> void:
	_trample_left = 0.0


func trampling() -> bool:
	return _trample_left > 0.0


func _update_colossus(delta: float, context: CombatContext) -> void:
	for index in _trample_locks.keys():
		var left: float = _trample_locks[index] - delta
		if left <= 0.0:
			_trample_locks.erase(index)
		else:
			_trample_locks[index] = left
	if _trample_left > 0.0:
		_trample_left = maxf(0.0, _trample_left - delta)
		# Chaque case qu'il quitte garde la trace de son pas : le jeu y fend le sol.
		if context.player_cell != _trample_from:
			if _trample_from.x > -9999:
				colossus_step.emit(_trample_from)
			_trample_from = context.player_cell
		var field := PackedInt32Array()
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or _trample_locks.has(i):
				continue
			var offset: Vector2i = context.enemy_cells[i] - context.player_cell
			if absi(offset.x) + absi(offset.y) > 1:
				continue
			_trample_locks[i] = _trample_lock
			trampled.emit(i, context.enemy_cells[i])
			if not context.is_structure(i) and not context.bosses.has(i):
				if field.is_empty():
					field = _field_from(context.player_cell)
				_push_away(i, context, _trample_cells, field)
				if _trample_slow > 0.0:
					enemy_soaked.emit(i, _trample_slow, GALE_SLOW_FACTOR)
			if _trample_damage > 0:
				_apply_damage(i, Ability.make({"id": stats.id + "_pietinement", "kind": Ability.Kind.BLAST,
					"element": stats.element, "damage": _trample_damage}), context, false, false)
	for k in range(_lava.size() - 1, -1, -1):
		var column: Dictionary = _lava[k]
		column["time_left"] = float(column["time_left"]) - delta
		if float(column["time_left"]) > 0.0:
			continue
		_lava.remove_at(k)
		var ability: Ability = column["ability"]
		var cell := _lava_target(context)
		lava_column.emit(cell, ability)
		_apply_area(Ability.make({"id": ability.id + "_lave", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.lava_damage, "radius": ability.lava_radius}),
			cell, context, ability, false, false)


## La colonne jaillit sous un ennemi proche, tiré au sort ; sans personne à portée, sur une case
## libre autour du mage.
func _lava_target(context: CombatContext) -> Vector2i:
	var near: Array[Vector2i] = []
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and Vector2(context.enemy_cells[i] - context.player_cell).length() <= LAVA_REACH:
			near.append(context.enemy_cells[i])
	if not near.is_empty():
		return near[_rng.randi_range(0, near.size() - 1)]
	for _try in 12:
		var spot := context.player_cell + Vector2i(_rng.randi_range(-6, 6), _rng.randi_range(-6, 6))
		if grid.is_floor_v(spot) and spot != context.player_cell:
			return spot
	return context.player_cell


## LA FAILLE : le sol se fend dans les quatre directions à la fois, et chaque branche suit son couloir.
func _cast_cross(ability: Ability, context: CombatContext) -> bool:
	var plant := _plant_of(ability)
	var hit := {}
	var cast := false
	for facing: Vector2i in MazeGrid.NEIGHBORS:
		var path := _corridor_ahead(context.player_cell, facing, ability.range)
		if path.is_empty():
			continue
		cast = true
		var duration := float(path.size()) / maxf(1.0, ability.line_speed)
		line_erupted.emit(ability, path, duration)
		# Les quatre branches partagent leur liste de touchés : un ennemi au carrefour n'encaisse
		# la Faille qu'une fois.
		_lines.append({"ability": ability, "path": path, "index": 0,
			"step": duration / float(path.size()), "timer": 0.0, "hit": hit, "plant": plant})
	if not cast:
		use_refused.emit("mur")
	return cast


## Les `turret_volley - 1` ennemis les plus proches du cristal après `first`, à sa portée.
func _turret_volley(cell: Vector2i, first: int, ability: Ability, context: CombatContext) -> Array[int]:
	var field := _field_from(cell)
	var scored: Array = []
	for i in context.enemy_cells.size():
		if i == first or not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or distance > ability.range:
			continue
		scored.append([distance + (STRUCTURE_PENALTY if context.is_structure(i) else 0), i])
	scored.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	var out: Array[int] = []
	for entry: Array in scored.slice(0, ability.turret_volley - 1):
		out.append(int(entry[1]))
	return out


## L'ÉRUPTION : il ressort du sol dans un jet de roche et de lave qui projette tout autour.
func _erupt_at(blast: Ability, cell: Vector2i, escape: Ability, context: CombatContext) -> void:
	eruption_burst.emit(cell, escape)
	var field := _field_from(cell)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > blast.radius:
			continue
		if not context.is_structure(i) and not context.bosses.has(i):
			_push_away(i, context, escape.end_blast_push, field)
		_apply_damage(i, blast, context)


# --- Le Seigneur du Néant (l'Éveil du Sorcier des Ténèbres) --------------------------

## Un trou noir aspire tant de fois par seconde.
const HOLE_PULL_GAP := 0.25


## LE DOUBLE : son ombre répète, `delay` secondes après, chaque coup qui vise un ennemi, à `ratio` de sa
## force. Ni la fuite, ni l'Extra.
func start_double(seconds: float, delay: float, ratio: float) -> void:
	_double_left = seconds
	_double_delay = delay
	_double_ratio = ratio


func stop_double() -> void:
	_double_left = 0.0
	_doubles.clear()


func doubling() -> bool:
	return _double_left > 0.0


func _shadow_repeats(ability: Ability, context: CombatContext) -> void:
	if ability == stats.escape or ability.is_ultimate or ability.damage <= 0:
		return
	var target := find_target(ability, context)
	if target < 0:
		return
	_doubles.append({"index": target, "time_left": _double_delay, "ability": ability})


func _update_void(delta: float, context: CombatContext) -> void:
	if _double_left > 0.0:
		_double_left = maxf(0.0, _double_left - delta)
	for k in range(_doubles.size() - 1, -1, -1):
		var echo: Dictionary = _doubles[k]
		echo["time_left"] = float(echo["time_left"]) - delta
		if float(echo["time_left"]) > 0.0:
			continue
		_doubles.remove_at(k)
		var index := int(echo["index"])
		if not context.enemy_alive(index):
			continue
		var ability: Ability = echo["ability"]
		double_struck.emit(index, ability)
		_apply_damage(index, Ability.make({"id": ability.id + "_double", "kind": Ability.Kind.BLAST,
			"element": ability.element,
			"damage": maxi(1, int(round(float(ability.damage) * _double_ratio)))}), context, false, false)
	for k in range(_holes.size() - 1, -1, -1):
		var hole: Dictionary = _holes[k]
		var ability: Ability = hole["ability"]
		hole["time_left"] = float(hole["time_left"]) - delta
		hole["tick"] = float(hole["tick"]) - delta
		if float(hole["tick"]) <= 0.0:
			hole["tick"] = HOLE_PULL_GAP
			_pull_toward(hole["cell"], 0.0, ability.hole_pull, context)
		if float(hole["time_left"]) > 0.0:
			continue
		_holes.remove_at(k)
		var cell: Vector2i = hole["cell"]
		hole_collapsed.emit(cell, ability)
		_apply_area(Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
			"damage": ability.damage, "radius": ability.radius}), cell, context, ability)
		# La flaque empoisonnée de l'Implosion de base, là où le trou s'est effondré.
		if ability.residue_duration > 0.0:
			var residue := _residue_of(ability)
			var id := _next_zone_id
			_next_zone_id += 1
			_zones.append({"id": id, "ability": residue, "cell": cell,
				"time_left": residue.duration, "tick": 0.0})
			zone_created.emit(id, residue, cell)


## LE TROU NOIR s'ouvre sur la cible.
func _open_hole(ability: Ability, context: CombatContext) -> bool:
	var target := find_target(ability, context)
	if target < 0:
		use_refused.emit("cible")
		return false
	var cell: Vector2i = context.enemy_cells[target]
	_holes.append({"cell": cell, "time_left": ability.hole_seconds, "tick": 0.0, "ability": ability})
	hole_opened.emit(cell, ability.hole_seconds, ability)
	return true


## L'ÉCLIPSE : la nuit tombe, et tous les ennemis sont ralentis le temps qu'elle dure.
func _fall_eclipse(ability: Ability, context: CombatContext) -> void:
	eclipse_fell.emit(ability.eclipse_seconds)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			enemy_soaked.emit(i, ability.eclipse_seconds, ability.eclipse_slow)


# --- Le Maître des Légions (l'Éveil de l'Invocateur) --------------------------------

## LA LÉGION : tant qu'elle dure, toute créature invoquée naît éveillée (`legion` dans son
## dictionnaire), frappe à `ratio` de ses dégâts, et le plafond monte à `cap`. À la fin, les
## créatures encore là redeviennent ordinaires.
func start_legion(seconds: float, ratio: float, cap: int) -> void:
	_legion_left = seconds
	_legion_ratio = ratio
	_legion_cap = cap
	for summon in _summons:
		summon["legion"] = true
	legion_changed.emit(true)


func stop_legion() -> void:
	if _legion_left <= 0.0 and _legion_cap == 0:
		return
	_legion_left = 0.0
	_legion_cap = 0
	_legion_mark.clear()
	for summon in _summons:
		summon["legion"] = false
	legion_changed.emit(false)


func legion_active() -> bool:
	return _legion_left > 0.0


## Ce que le `Level` doit savoir d'une créature pour la dessiner : son apparence, sa taille, et si
## elle est de la Légion. Vide si elle n'existe plus.
func summon_info(id: int) -> Dictionary:
	for summon in _summons:
		if int(summon["id"]) == id:
			return {"legion": bool(summon.get("legion", false)),
				"scale": float(summon.get("scale", 1.0)), "look": str(summon.get("look", "")),
				"kind": str(summon["kind"])}
	return {}


## La proie marquée, si elle vit encore. -1 sinon.
func marked_prey() -> int:
	return int(_legion_mark.get("index", -1))


func _mark_prey(index: int, seconds: float) -> void:
	_legion_mark = {"index": index, "left": seconds}
	prey_marked.emit(index, seconds)


func _update_legion(delta: float, context: CombatContext) -> void:
	if _legion_left > 0.0:
		_legion_left = maxf(0.0, _legion_left - delta)
	if _legion_mark.is_empty():
		return
	_legion_mark["left"] = float(_legion_mark["left"]) - delta
	if float(_legion_mark["left"]) <= 0.0 or not context.enemy_alive(int(_legion_mark["index"])):
		_legion_mark.clear()


func _summon_cap() -> int:
	return maxi(MAX_SUMMONS, _legion_cap)


## Une créature naît : son dictionnaire, la Légion et ce que le sort lui donne.
func _spawn_summon(kind: String, cell: Vector2i, life: float, ability: Ability) -> Dictionary:
	var summon := {
		"id": _next_summon_id, "kind": kind,
		"position": Vector2(cell), "cell": cell,
		"time_left": life, "strike_in": 0.6,
		"facing": Vector2i.DOWN, "target": -1,
		"legion": _legion_left > 0.0,
		"scale": ability.summon_scale if ability != null else 1.0,
		"look": ability.summon_look if ability != null else "",
	}
	if ability != null and ability.summon_burst_damage > 0:
		summon["burst"] = {"damage": ability.summon_burst_damage, "radius": ability.summon_burst_radius,
			"element": ability.element}
	_next_summon_id += 1
	_summons.append(summon)
	summon_spawned.emit(int(summon["id"]), kind, summon["position"])
	return summon


## La créature s'en va (fin de vie ou place cédée) : un diablotin de la Nuée explose en partant.
func _summon_leaves(summon: Dictionary, context: CombatContext) -> void:
	summon_expired.emit(int(summon["id"]))
	if not summon.has("burst") or context == null:
		return
	var burst: Dictionary = summon["burst"]
	var cell := Vector2i((summon["position"] as Vector2).round())
	summon_burst.emit(int(summon["id"]), cell, float(burst["radius"]))
	_apply_area(Ability.make({"id": "legion_burst", "kind": Ability.Kind.BLAST,
		"element": int(burst["element"]), "damage": int(burst["damage"]),
		"radius": float(burst["radius"])}), cell, context, null, false, false)


func _trim_summons(context: CombatContext) -> void:
	while _summons.size() > _summon_cap():
		_summon_leaves(_summons.pop_front(), context)


## LA GARGOUILLE COLOSSALE tombe à côté de la proie la plus proche, sinon à côté du mage : le choc
## blesse et étourdit autour d'elle.
func _drop_cell(context: CombatContext) -> Vector2i:
	var prey := _closest_prey(1, context)
	if prey.is_empty():
		return _summon_spawn_cell(context, 0)
	return _rift_cell(context.enemy_cells[prey[0]])


func _summon_drop(summon: Dictionary, ability: Ability, context: CombatContext) -> void:
	var cell: Vector2i = summon["cell"]
	summon_dropped.emit(int(summon["id"]), cell, ability.summon_drop_radius)
	var shock := Ability.make({"id": ability.id + "_chute", "kind": Ability.Kind.BLAST,
		"element": ability.element, "damage": ability.summon_drop_damage,
		"radius": ability.summon_drop_radius, "stun_seconds": ability.summon_drop_stun})
	if ability.summon_drop_stun > 0.0:
		_freeze_around(shock, context, cell)
	_apply_area(shock, cell, context, ability)


## L'ÉCHANGE : le mage prend la place de sa créature au sol la plus éloignée (à deux cases au moins),
## et elle la sienne. Faux s'il n'y en a aucune : la fuite redevient alors un pas ordinaire.
func _swap_with_summon(context: CombatContext) -> bool:
	var best: Dictionary = {}
	var best_distance := 2.0
	for summon in _summons:
		if bool(SUMMON_KINDS[summon["kind"]]["flies"]):
			continue
		var cell := Vector2i((summon["position"] as Vector2).round())
		if not grid.is_floor_v(cell):
			continue
		var distance := Vector2(cell).distance_to(Vector2(context.player_cell))
		if distance >= best_distance:
			best_distance = distance
			best = summon
	if best.is_empty():
		return false
	var there := Vector2i((best["position"] as Vector2).round())
	best["position"] = Vector2(context.player_cell)
	best["cell"] = context.player_cell
	best.erase("next")
	summon_swapped.emit(int(best["id"]), context.player_cell, there)
	summon_moved.emit(int(best["id"]), best["position"], best["facing"])
	blink_performed.emit(context.player_cell, there)
	return true


## LE PASSAGE DU ROI-DRAGON : il survole la rangée du mage d'un bord à l'autre, par-dessus les
## haies (un ultime peut passer les murs, et ça se voit : son ombre traverse l'écran).
func _dragon_flyover(ability: Ability, context: CombatContext) -> void:
	dragon_flyover.emit(context.player_cell, ability.flyover_reach, ability.flyover_width)
	var blow := Ability.make({"id": ability.id + "_passage", "kind": Ability.Kind.BLAST,
		"element": Element.Kind.FIRE, "damage": ability.flyover_damage})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var offset: Vector2i = context.enemy_cells[i] - context.player_cell
		if absf(float(offset.y)) <= ability.flyover_width and absf(float(offset.x)) <= ability.flyover_reach:
			_apply_damage(i, blow, context, false)


# --- Le Souverain des Vents (l'Éveil du Mage de l'Air) -------------------------------

## Repousse d'autant de cases, sauf un repaire ou un boss. Zéro ne fait rien.
func _shove(index: int, cells: int, context: CombatContext) -> void:
	if cells <= 0 or not context.enemy_alive(index) or context.is_structure(index) or context.bosses.has(index):
		return
	_push_away(index, context, cells)


## Rapproche d'une case de `cell` les ennemis entre `inner` et `reach` cases de lui, par les couloirs.
func _pull_toward(cell: Vector2i, inner: float, reach: float, context: CombatContext) -> void:
	var field := _field_from(cell)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or context.bosses.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) <= inner or float(distance) > reach:
			continue
		var next: Vector2i = context.enemy_cells[i] + Pathfinder.step_toward(grid, field, context.enemy_cells[i])
		if next == context.enemy_cells[i]:
			continue
		context.enemy_cells[i] = next
		enemy_pushed.emit(i, next)


## L'ŒIL DE L'OURAGAN : une zone qui le suit, blesse et aspire. C'est une zone ordinaire, fabriquée ici.
func _open_eye(ability: Ability, context: CombatContext) -> void:
	_cast_zone(Ability.make({
		"id": ability.id + "_oeil", "display_name": ability.display_name,
		"kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": ability.eye_damage, "radius": ability.eye_radius, "duration": ability.eye_seconds,
		"zone_follows": true, "zone_pull": ability.eye_pull, "zone_style": "ouragan_peint",
	}), context)


# --- L'Avatar de la Tempête (l'Éveil du Mage de la Foudre) ---------------------------

## SURTENSION : tant qu'elle dure, chaque coup d'origine donne une charge, jusqu'à `charges`. La
## cinquième fait tomber la foudre du ciel sur la cible de l'attaque suivante.
func start_surge(seconds: float, charges: int, damage: int, radius: float) -> void:
	_surge_left = seconds
	_surge_max = charges
	_surge_damage = damage
	_surge_radius = radius
	_surge_charges = 0
	surge_changed.emit(0)


func stop_surge() -> void:
	_surge_left = 0.0
	_surge_charges = 0
	surge_changed.emit(0)


func surge_charges() -> int:
	return _surge_charges


func _release_surge(ability: Ability, context: CombatContext) -> void:
	var target := find_target(ability, context)
	if target < 0:
		return
	var cell: Vector2i = context.enemy_cells[target]
	_surge_charges = 0
	surge_changed.emit(0)
	surge_struck.emit(cell)
	_apply_area(Ability.make({"id": ability.id + "_surtension", "kind": Ability.Kind.BLAST,
		"element": ability.element, "damage": _surge_damage, "radius": _surge_radius}),
		cell, context, null, false, false)


func _update_tempest(delta: float, context: CombatContext) -> void:
	if _surge_left > 0.0:
		_surge_left = maxf(0.0, _surge_left - delta)
	for k in range(_wrath.size() - 1, -1, -1):
		var bolt: Dictionary = _wrath[k]
		bolt["time_left"] = float(bolt["time_left"]) - delta
		if float(bolt["time_left"]) > 0.0:
			continue
		_wrath.remove_at(k)
		var index := int(bolt["index"])
		if not context.enemy_alive(index):
			continue
		var ability: Ability = bolt["ability"]
		wrath_bolt.emit(context.enemy_cells[index], index)
		_apply_damage(index, Ability.make({"id": ability.id + "_colere", "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.wrath_damage}), context, false, false)


## LA COLÈRE DU CIEL : un éclair géant par ennemi à portée, du plus proche au plus loin.
func _summon_wrath(ability: Ability, context: CombatContext) -> void:
	var scored: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Vector2(context.enemy_cells[i] - context.player_cell).length()
		if distance <= ability.wrath_reach:
			scored.append([distance, i])
	scored.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	for k in scored.size():
		_wrath.append({"index": int(scored[k][1]), "ability": ability,
			"time_left": WRATH_DELAY + ability.wrath_gap * float(k)})


## Le premier éclair attend que le ciel se soit assombri.
const WRATH_DELAY := 0.6


## LE SAUT D'ÉCLAIR : il bondit d'ennemi en ennemi en les frappant, et réapparaît sur le dernier.
## Sans personne à portée, c'est une fuite ordinaire (faux).
func _hop(ability: Ability, context: CombatContext) -> bool:
	var hops: Array[int] = []
	var visited := {}
	var first := -1
	var best := ability.hop_range + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance < best:
			best = distance
			first = i
	if first < 0:
		return false
	hops.append(first)
	visited[first] = true
	while hops.size() < ability.hop_count:
		var next := _nearest_unvisited(hops[-1], visited, ability.hop_range, context)
		if next < 0:
			break
		visited[next] = true
		hops.append(next)
	var cells: Array = [context.player_cell]
	for i in hops:
		cells.append(context.enemy_cells[i])
	lightning_hopped.emit(cells)
	blink_performed.emit(context.player_cell, cells[-1])
	var strike := Ability.make({"id": ability.id + "_saut", "kind": Ability.Kind.BLAST,
		"element": ability.element, "damage": ability.hop_damage})
	for i in hops:
		_apply_damage(i, strike, context, false, false)
	return true


# --- Le Seigneur des Marées (l'Éveil du Mage de l'Eau) --------------------------------

## Le courant du Torrent : une petite zone par case, qui englue sans blesser.
func _lay_wake(ability: Ability, cells: Array) -> void:
	for cell: Vector2i in cells:
		var wake := Ability.make({
			"id": ability.id + "_courant", "display_name": ability.display_name,
			"kind": Ability.Kind.ZONE, "element": ability.element, "damage": 0, "radius": 0.6,
			"duration": ability.wake_seconds, "slow_duration": 1.5, "slow_factor": 0.5,
			"zone_style": "courant_peint",
		})
		var id := _next_zone_id
		_next_zone_id += 1
		_zones.append({"id": id, "ability": wake, "cell": cell, "time_left": wake.duration, "tick": 0.0})
		zone_created.emit(id, wake, cell)


## LE LÉVIATHAN : un serpent d'eau traverse le labyrinthe d'un bord à l'autre de l'écran, par-dessus
## les haies, dans une bande de rangées autour du mage. Il frappe chaque ennemi une fois, quand sa
## tête le dépasse. Il part du côté opposé à celui où regarde le mage, et file vers son regard.
func _cast_leviathan(ability: Ability, context: CombatContext) -> bool:
	var direction := -1 if context.player_facing.x < 0 else 1
	_leviathan = {"origin": context.player_cell, "direction": direction, "time": 0.0, "hit": {},
		"ability": ability}
	if ability.heal_self > 0:
		var healed := health.heal(ability.heal_self)
		if healed > 0:
			player_healed.emit(healed)
	leviathan_cast.emit(context.player_cell, ability, direction)
	return true


func _swim_leviathan(delta: float, context: CombatContext) -> void:
	var ability: Ability = _leviathan["ability"]
	_leviathan["time"] = float(_leviathan["time"]) + delta
	var origin: Vector2i = _leviathan["origin"]
	var direction := int(_leviathan["direction"])
	var reach := float(ability.range)
	var head := -reach + 2.0 * reach * clampf(float(_leviathan["time"]) / maxf(0.1, ability.duration), 0.0, 1.0)
	var hit: Dictionary = _leviathan["hit"]
	for i in context.enemy_cells.size():
		if hit.has(i) or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var offset: Vector2i = context.enemy_cells[i] - origin
		if absf(float(offset.y)) > ability.radius or absf(float(offset.x)) > reach:
			continue
		if float(offset.x * direction) > head:
			continue
		hit[i] = true
		_apply_damage(i, ability, context)
	if float(_leviathan["time"]) >= ability.duration:
		_leviathan = {}


# --- Le Chérubin ------------------------------------------------------------------

## NUL N'APPROCHE : chaque coup ouvre un œil sur l'ennemi. Il s'embrase quand cet ennemi arrive
## au contact, une fois, puis un délai passe avant qu'un nouvel œil ne s'ouvre sur lui.
func _add_eye(index: int, context: CombatContext) -> void:
	if not context.enemy_alive(index) or context.is_structure(index) or _eyes.has(index) \
			or _eye_locks.has(index):
		return
	_eyes[index] = true
	enemy_eyed.emit(index, true)


func eyes() -> Dictionary:
	return _eyes


func _update_cherubin(delta: float, context: CombatContext) -> void:
	for table: Dictionary in [_eye_locks, _veil_locks, _garden_locks, _sword_locks]:
		for index in table.keys():
			var left: float = table[index] - delta
			if left <= 0.0:
				table.erase(index)
			else:
				table[index] = left
	for index: int in _eyes.keys():
		if index >= context.enemy_cells.size() or not context.enemy_alive(index):
			_eyes.erase(index)
			enemy_eyed.emit(index, false)
			continue
		var cell: Vector2i = context.enemy_cells[index]
		if Vector2(cell - context.player_cell).length() > (THRONE_REACH if _throne else EYE_REACH):
			continue
		_eyes.erase(index)
		_eye_locks[index] = THRONE_EYE_LOCK if _throne else EYE_LOCK
		enemy_eyed.emit(index, false)
		eye_burst.emit(cell)
		_apply_damage(index, Ability.make({"id": stats.id + "_oeil", "kind": Ability.Kind.BLAST,
			"element": stats.element, "damage": THRONE_EYE_DAMAGE if _throne else EYE_DAMAGE}),
			context, false, false)
	if not _whirl.is_empty():
		_spin_whirl(delta, context)
	if _veil != null and _immune_left > 0.0:
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or context.is_structure(i) or context.bosses.has(i) \
					or _veil_locks.has(i):
				continue
			if Vector2(context.enemy_cells[i] - context.player_cell).length() > EYE_REACH:
				continue
			_veil_locks[i] = VEIL_LOCK
			if _push_away(i, context, _veil.repel_cells) > 0:
				veil_repelled.emit(context.enemy_cells[i])
	if not _garden.is_empty():
		_tend_garden(delta, context)


## Le GLAIVE TOURNOYANT. Relancer le remet à neuf : deux glaives doubleraient la cadence en silence.
func _cast_whirl(ability: Ability) -> bool:
	_whirl = {"left": ability.duration, "tick": 0.0, "ability": ability}
	whirl_started.emit(ability.duration, ability.radius)
	return true


func _spin_whirl(delta: float, context: CombatContext) -> void:
	var ability: Ability = _whirl["ability"]
	_whirl["left"] = float(_whirl["left"]) - delta
	_whirl["tick"] = float(_whirl["tick"]) - delta
	if float(_whirl["tick"]) <= 0.0:
		_whirl["tick"] = float(_whirl["tick"]) + ability.whirl_interval
		for i in _creatures_within(context.player_cell, ability.radius, context):
			var cell: Vector2i = context.enemy_cells[i]
			_apply_damage(i, ability, context)
			whirl_cut.emit(cell)
	if float(_whirl["left"]) <= 0.0:
		_whirl = {}


func whirling() -> bool:
	return not _whirl.is_empty()


## Les ROUES D'ÉZÉCHIEL : deux vagues, l'une vers l'ennemi le plus proche, l'autre dans l'autre
## sens. Elles suivent le couloir et tournent avec lui, sans jamais revenir sur leurs pas.
func _cast_wheels(ability: Ability, context: CombatContext) -> bool:
	if ability.wheel_count >= 4:
		return _cast_four_wheels(ability, context)
	var first: Array[Vector2i] = []
	var target := find_target(ability, context)
	if target >= 0:
		var route := trajectory(context.player_cell, context.enemy_cells[target])
		for i in range(1, mini(route.size(), ability.range + 1)):
			first.append(route[i])
	var facing := context.player_facing if context.player_facing != Vector2i.ZERO else Vector2i.DOWN
	if first.is_empty():
		first = _rolling_path(context.player_cell, facing, ability.range)
	var away := -(first[0] - context.player_cell) if not first.is_empty() else -facing
	var second := _rolling_path(context.player_cell, away, ability.range)
	if second.is_empty():
		for side: Vector2i in MazeGrid.NEIGHBORS:
			if first.is_empty() or side != first[0] - context.player_cell:
				second = _rolling_path(context.player_cell, side, ability.range)
				if not second.is_empty():
					break
	if first.is_empty() and second.is_empty():
		use_refused.emit("mur")
		return false
	for path: Array[Vector2i] in [first, second]:
		if path.is_empty():
			continue
		var duration := float(path.size()) / maxf(1.0, ability.wave_speed)
		_waves.append({"ability": ability, "path": path, "index": 0,
			"step": duration / float(path.size()), "timer": 0.0, "hit": {}})
		wave_launched.emit(ability, path, duration)
	return true


## LES ROUES DANS LES ROUES : une roue part dans chacune des quatre directions qui ne sont pas un mur.
func _cast_four_wheels(ability: Ability, context: CombatContext) -> bool:
	var launched := false
	for side: Vector2i in MazeGrid.NEIGHBORS:
		var path := _rolling_path(context.player_cell, side, ability.range)
		if path.is_empty():
			continue
		launched = true
		var duration := float(path.size()) / maxf(1.0, ability.wave_speed)
		_waves.append({"ability": ability, "path": path, "index": 0,
			"step": duration / float(path.size()), "timer": 0.0, "hit": {}})
		wave_launched.emit(ability, path, duration)
	if not launched:
		use_refused.emit("mur")
	return launched


## Un chemin qui suit le couloir : tout droit tant qu'il peut, et il tourne quand le couloir tourne.
func _rolling_path(start: Vector2i, direction: Vector2i, reach: int) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var cell := start
	var heading := direction
	var seen := {start: true}
	for _step in reach:
		var next := cell + heading
		if not grid.is_floor_v(next) or seen.has(next):
			var turned := false
			for side: Vector2i in MazeGrid.NEIGHBORS:
				if side == heading or side == -heading:
					continue
				if grid.is_floor_v(cell + side) and not seen.has(cell + side):
					heading = side
					next = cell + side
					turned = true
					break
			if not turned:
				break
		cell = next
		seen[cell] = true
		path.append(cell)
	return path


## LE JARDIN GARDÉ. Le cercle reste là où l'épée est plantée. Les boss n'en sont pas rejetés : ils
## y entrent, et brûlent à chaque seconde.
func _cast_garden(ability: Ability, context: CombatContext) -> bool:
	_garden = {"cell": context.player_cell, "left": ability.duration, "tick": 1.0, "ability": ability}
	_garden_locks.clear()
	if ability.heal_self > 0:
		var gained := health.heal(ability.heal_self)
		if gained > 0:
			player_healed.emit(gained)
	garden_planted.emit(context.player_cell, ability.radius, ability.duration)
	_tend_garden(0.0, context)
	return true


func garden() -> Dictionary:
	return _garden


## Tout ennemi dans le cercle en est rejeté à CHAQUE image, et ne brûle qu'une fois par délai : il
## ne peut pas avancer d'une case dedans en profitant de son verrou.
func _tend_garden(delta: float, context: CombatContext) -> void:
	var ability: Ability = _garden["ability"]
	var centre: Vector2i = _garden["cell"]
	_garden["left"] = float(_garden["left"]) - delta
	_garden["tick"] = float(_garden["tick"]) - delta
	var burn := float(_garden["tick"]) <= 0.0
	if burn:
		_garden["tick"] = float(_garden["tick"]) + 1.0
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var cell: Vector2i = context.enemy_cells[i]
		if Vector2(cell - centre).length() >= ability.radius:
			continue
		if context.bosses.has(i):
			if burn:
				_apply_damage(i, ability, context, false)
			continue
		var out := _garden_exit(cell, centre, ability.radius)
		if out != cell:
			context.enemy_cells[i] = out
			enemy_pushed.emit(i, out)
		if not _garden_locks.has(i):
			_garden_locks[i] = GARDEN_LOCK
			garden_repelled.emit(out)
			_apply_damage(i, ability, context, false)
	if ability.garden_sword_damage > 0:
		_swing_garden_sword(ability, centre, context)
	if float(_garden["left"]) <= 0.0:
		garden_ended.emit(centre)
		_garden = {}


## La case libre la plus proche HORS du cercle, par les couloirs : un rejet ne passe pas les haies.
func _garden_exit(from: Vector2i, centre: Vector2i, radius: float) -> Vector2i:
	var queue: Array[Vector2i] = [from]
	var seen := {from: true}
	var head := 0
	while head < queue.size() and head < 400:
		var cell := queue[head]
		head += 1
		if Vector2(cell - centre).length() >= radius and not grid.is_occupied(cell):
			return cell
		for side: Vector2i in MazeGrid.NEIGHBORS:
			var next: Vector2i = cell + side
			if grid.is_floor_v(next) and not seen.has(next):
				seen[next] = true
				queue.append(next)
	return from


# --- L'Archange du Ciel ------------------------------------------------------------

## La distance à vol d'oiseau, arrondie à la case : celle de son trait, Vue d'en haut.
func _sky_distance(from: Vector2i, to: Vector2i) -> int:
	return roundi(Vector2(to - from).length())


## L'ENVOL. Il s'élève, intouchable : c'est le JEU qui le laisse passer au-dessus des haies
## (`GridMover.phases`) et qui le repose sur la case de sol la plus proche avant `_land`.
func _cast_flight(ability: Ability) -> bool:
	if _flight != null:
		return false
	_flight = ability
	_flight_left = ability.duration
	health.immune = true
	flight_started.emit(ability.duration, ability)
	return true


func flying() -> bool:
	return _flight != null


## Ce que l'Envol fait de son allure. Le jeu le lit ; les bots n'utilisent aucune fuite.
func flight_speed() -> float:
	return _flight.flight_speed if _flight != null else 1.0


## Il retombe. `flight_ended` part d'abord : le jeu le repose sur le sol et met la case à jour,
## puis l'onde frappe autour de cette case.
func _land(context: CombatContext) -> void:
	var ability := _flight
	_flight = null
	_flight_left = 0.0
	health.immune = _immune_left > 0.0
	flight_ended.emit()
	flight_landed.emit(context.player_cell, ability)
	if ability.damage > 0 and ability.radius > 0.0:
		_apply_area(ability, context.player_cell, context)
	# L'Envol du dragon : le sol s'embrase là où il retombe.
	if ability.ground_fire > 0.0 and ability.radius > 0.0:
		_ignite_cells(_floor_within(context.player_cell, ability.radius), ability.ground_fire)
	# Le Vol du zéphyr rabat tout en retombant.
	if ability.end_blast_push > 0:
		var field := _field_from(context.player_cell)
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or context.is_structure(i) or context.bosses.has(i):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance >= 0 and float(distance) <= ability.radius:
				_push_away(i, context, ability.end_blast_push, field)


## Le Rempart le cloue sur place : le jeu et la simulation lisent tous deux cette réponse. Le Bastion du
## Colosse renvoie les coups lui aussi, mais le laisse marcher (`reflect_mobile`).
func player_rooted() -> bool:
	return _rampart != null and not _rampart.reflect_mobile


func plates_left() -> int:
	return health.plates


func _forge_plate() -> void:
	_forge_kills += 1
	if _forge_kills < PLATE_KILLS and not _forge:
		return
	_forge_kills = 0
	if health.plates < plate_cap():
		health.plates += 1
		plates_changed.emit(health.plates)


## La volée est UNE : un ennemi au contact ne prend pas les cinq lames, seulement un coup par
## passage. Sinon l'éventail, encore serré près du lanceur, ferait cinq fois ses dégâts.
func _cast_blades(ability: Ability, context: CombatContext) -> bool:
	var facing := Vector2(context.player_facing)
	if facing.length() < 0.01:
		facing = Vector2.DOWN
	var directions := []
	for i in ability.blade_count:
		if ability.blades_circle:
			directions.append(facing.rotated(TAU * float(i) / float(ability.blade_count)))
			continue
		var turn := (float(i) - float(ability.blade_count - 1) * 0.5) * BLADE_FAN
		directions.append(facing.rotated(deg_to_rad(turn)))
	_volleys.append({"from": Vector2(context.player_cell), "directions": directions, "time": 0.0,
		"hit": {}, "returning": false, "ability": ability})
	blades_thrown.emit(context.player_cell, directions, ability.range)
	return true


func _cast_anvil(ability: Ability, context: CombatContext) -> bool:
	if ability.anvil_drop_damage > 0:
		return _drop_anvil(ability, context)
	_anvil_wave(ability, context.player_cell)
	return true


## L'ENCLUME CÉLESTE tombe sur l'ennemi le plus proche par les couloirs, à portée ; sans proie, à ses pieds.
func _drop_anvil(ability: Ability, context: CombatContext) -> bool:
	var cell := context.player_cell
	var best := ability.range + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance < best:
			best = distance
			cell = context.enemy_cells[i]
	_anvil_drops.append({"cell": cell, "time_left": ANVIL_DROP_LEAD, "ability": ability})
	anvil_falling.emit(cell, ANVIL_DROP_LEAD, ability.anvil_drop_radius)
	return true


func _anvil_wave(ability: Ability, origin: Vector2i) -> void:
	var field := _field_from(origin)
	var links := []
	var seen := {origin: true}
	var front: Array[Vector2i] = [origin]
	for steps in range(1, ability.range + 1):
		var next_front: Array[Vector2i] = []
		for cell in front:
			for direction in MazeGrid.NEIGHBORS:
				var next: Vector2i = cell + direction
				if seen.has(next) or not grid.is_floor_v(next):
					continue
				seen[next] = true
				next_front.append(next)
				links.append({"from": cell, "to": next, "steps": steps})
		front = next_front
	_anvils.append({"field": field, "time": 0.0, "hit": {}, "ability": ability})
	anvil_struck.emit(origin, links)


func _update_steel(delta: float, context: CombatContext) -> void:
	_reflect_lock = maxf(0.0, _reflect_lock - delta)
	if _reflect_waiting and _rampart != null and _reflect_lock <= 0.0:
		var attacker := _nearest_in_reach(context.player_cell, REFLECT_REACH, context)
		if attacker >= 0:
			_reflect_lock = REFLECT_GAP
			rampart_reflected.emit(context.enemy_cells[attacker])
			var answer := Ability.make({"id": _rampart.id, "kind": Ability.Kind.BLAST,
				"element": _rampart.element, "damage": _rampart.reflect_damage})
			_apply_damage(attacker, answer, context, false, false)
	_reflect_waiting = false
	_update_volleys(delta, context)
	_update_anvils(delta, context)
	_update_forge(delta, context)
	_update_skies(delta, context)
	if _molten_left > 0.0:
		_molten_left = maxf(0.0, _molten_left - delta)
		if _molten_left <= 0.0:
			molten_ended.emit()


func _update_volleys(delta: float, context: CombatContext) -> void:
	for v in range(_volleys.size() - 1, -1, -1):
		var volley: Dictionary = _volleys[v]
		volley["time"] = float(volley["time"]) + delta
		var time: float = volley["time"]
		var ability: Ability = volley["ability"]
		if time >= BLADE_OUT and not bool(volley["returning"]) and not ability.blades_return:
			_volleys.remove_at(v)
			continue
		if time >= BLADE_OUT and not bool(volley["returning"]):
			volley["returning"] = true
			volley["hit"] = {}
		var reached: float = 1.0 - pow(1.0 - minf(time / BLADE_OUT, 1.0), 2.0)
		var back: float = clampf((time - BLADE_OUT) / BLADE_BACK, 0.0, 1.0)
		var hit: Dictionary = volley["hit"]
		for direction: Vector2 in volley["directions"]:
			var tip: Vector2 = Vector2(volley["from"]) + direction * float(ability.range) * reached
			var at := tip.lerp(Vector2(context.player_cell), back * back)
			for i in context.enemy_cells.size():
				if hit.has(i) or not context.enemy_alive(i):
					continue
				if Vector2(context.enemy_cells[i]).distance_to(at) <= BLADE_REACH:
					hit[i] = true
					var cell: Vector2i = context.enemy_cells[i]
					_apply_damage(i, ability, context)
					blade_cut.emit(cell)
		if time >= BLADE_OUT + BLADE_BACK:
			_volleys.remove_at(v)


func _update_anvils(delta: float, context: CombatContext) -> void:
	for a in range(_anvils.size() - 1, -1, -1):
		var anvil: Dictionary = _anvils[a]
		anvil["time"] = float(anvil["time"]) + delta
		var ability: Ability = anvil["ability"]
		var front: float = float(anvil["time"]) * ANVIL_SPEED
		var hit: Dictionary = anvil["hit"]
		for i in context.enemy_cells.size():
			if hit.has(i) or not context.enemy_alive(i):
				continue
			var steps := Pathfinder.value_at(grid, anvil["field"], context.enemy_cells[i])
			if steps < 0 or steps > ability.range or float(steps) > front:
				continue
			hit[i] = true
			_apply_damage(i, ability, context)
			if context.enemy_alive(i) and not context.is_structure(i):
				enemy_staggered.emit(i, ability.stun_seconds)
		if front > float(ability.range):
			_anvils.remove_at(a)


# --- La mort ----------------------------------------------------------------------

## Le coup de grâce : sous le seuil du sort, ou du trait s'il n'en a pas, l'ennemi est achevé.
## Les repaires n'ont pas de vie à prendre, seulement des murs à abattre.
func _sentence(index: int, ability: Ability, context: CombatContext) -> void:
	if not context.enemy_alive(index) or context.is_structure(index):
		return
	var life: Health = context.enemy_health[index]
	var below := ability.execute_below if ability.execute_below > 0.0 \
		else (HARVEST_BELOW if _harvest else SENTENCE_BELOW)
	if float(life.current) > float(life.maximum) * below:
		return
	enemy_sentenced.emit(index)
	enemy_damaged.emit(index, life.take(Damage.new(life.current, ability.element, "player")), ability)


func _gain_soul() -> void:
	if _souls < soul_cap():
		_souls += 1
		souls_changed.emit(_souls)


func _update_death(delta: float, context: CombatContext) -> void:
	for index in _marked.keys():
		_marked[index] = float(_marked[index]) - delta
		if float(_marked[index]) <= 0.0:
			_marked.erase(index)
	for i in range(_flying.size() - 1, -1, -1):
		var soul: Dictionary = _flying[i]
		soul["time_left"] = float(soul["time_left"]) - delta
		if float(soul["time_left"]) > 0.0:
			continue
		_flying.remove_at(i)
		var prey := int(soul["index"])
		if context.enemy_alive(prey):
			soul_struck.emit(context.enemy_cells[prey])
			_apply_damage(prey, soul["ability"], context)
	for i in range(_hour.size() - 1, -1, -1):
		var strike: Dictionary = _hour[i]
		strike["time_left"] = float(strike["time_left"]) - delta
		if float(strike["time_left"]) <= 0.0:
			_hour.remove_at(i)
			_strike_last_hour(int(strike["index"]), strike["ability"], context)


func _apply_zone_mark(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and float(distance) <= ability.radius:
			_marked[i] = ability.mark_seconds
			enemy_marked.emit(i, ability.mark_seconds)


## Une âme de base et toutes celles récoltées, une par proie, les plus proches d'abord. Sans
## proie à portée, le sort est refusé et les âmes restent : il ne se gaspille pas dans le vide.
func _cast_souls(ability: Ability, context: CombatContext) -> bool:
	var preys: Array[int] = []
	var distances := {}
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, context.player_field, context.enemy_cells[i])
		if distance >= 0 and distance <= ability.range:
			preys.append(i)
			distances[i] = distance
	if preys.is_empty():
		use_refused.emit("cible")
		return false
	preys.sort_custom(func(a: int, b: int) -> bool: return int(distances[a]) < int(distances[b]))
	for n in maxi(1, ability.souls_base) + _souls:
		var prey: int = preys[n % preys.size()]
		var path := trajectory(context.player_cell, context.enemy_cells[prey])
		var duration := float(path.size()) / SOUL_SPEED + float(n) * SOUL_GAP
		_flying.append({"index": prey, "time_left": duration, "ability": ability})
		soul_sent.emit(path, duration)
	_souls = 0
	souls_changed.emit(0)
	return true


func _cast_last_hour(ability: Ability, context: CombatContext) -> void:
	last_hour_cast.emit(context.player_cell)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			var across := float(context.enemy_cells[i].x) / float(maxi(1, grid.cols))
			_hour.append({"index": i, "ability": ability,
				"time_left": HOUR_DELAY + HOUR_SWEEP * across})
			# MINUIT : la faux revient de droite à gauche.
			if ability.hour_passes >= 2:
				_hour.append({"index": i, "ability": ability,
					"time_left": HOUR_DELAY + HOUR_SWEEP + HOUR_RETURN_GAP + HOUR_SWEEP * (1.0 - across)})


func _strike_last_hour(index: int, ability: Ability, context: CombatContext) -> void:
	if not context.enemy_alive(index):
		return
	var life: Health = context.enemy_health[index]
	last_hour_struck.emit(context.enemy_cells[index])
	var share := ceili(float(life.current) * HOUR_SHARE)
	enemy_damaged.emit(index, life.take(Damage.new(share, ability.element, "player")), ability)
	_sentence(index, ability, context)
	if not context.enemy_alive(index):
		_marked.erase(index)
		_gain_soul()
		enemy_killed.emit(index)


# --- Le Dragon des Abysses ---------------------------------------------------------
#
# Il met le feu au SOL. Ses cases en feu rongent ce qui s'y tient, le font aller plus vite, et
# une proie qui brûle le soigne quand il la mord. Tout se joue ici, pour que l'équilibrage voie
# les mêmes règles que le jeu.

func _ignite_cells(cells: Array, seconds: float) -> void:
	if _primal:
		seconds *= PRIMAL_FIRE_LONGER
	var lit := []
	for cell: Vector2i in cells:
		if not grid.is_floor_v(cell):
			continue
		_fire_cells[cell] = maxf(float(_fire_cells.get(cell, 0.0)), seconds)
		lit.append(cell)
	if not lit.is_empty():
		ground_ignited.emit(lit, seconds)


## La brûlure du Feu, réglée en dégâts par seconde au lieu d'une part du coup.
func _ignite(index: int, dps: int, seconds: float) -> void:
	if dps <= 0 or seconds <= 0.0:
		return
	var ticks := maxi(1, int(round(seconds / BURN_TICK)))
	_burning[index] = {"ticks": ticks, "timer": BURN_TICK, "damage": maxi(1, int(round(dps * BURN_TICK)))}
	enemy_burning.emit(index, ticks * BURN_TICK)


func _is_aflame(index: int, context: CombatContext) -> bool:
	return _burning.has(index) or _fire_cells.has(context.enemy_cells[index])


func fire_cells() -> Dictionary:
	return _fire_cells


func scales_up() -> bool:
	return _scales != null


func _update_dragon(delta: float, context: CombatContext) -> void:
	_dragon_cell = context.player_cell
	if not _primal_pending.is_empty():
		_burst_primal(context)
	if not _fire_cells.is_empty():
		var faded := []
		for cell: Vector2i in _fire_cells.keys():
			var left: float = float(_fire_cells[cell]) - delta
			if left <= 0.0:
				_fire_cells.erase(cell)
				faded.append(cell)
			else:
				_fire_cells[cell] = left
		if not faded.is_empty():
			ground_faded.emit(faded)
		_fire_tick -= delta
		if _fire_tick <= 0.0:
			_fire_tick = ZONE_TICK
			var slice := Ability.make({"id": "terre_brulee", "display_name": "Terre brûlée",
				"kind": Ability.Kind.ZONE, "element": Element.Kind.INFERNO,
				"damage": maxi(1, int(round((PRIMAL_FIRE_DAMAGE if _primal else FIRE_CELL_DAMAGE) * ZONE_TICK)))})
			for i in context.enemy_cells.size():
				if context.enemy_alive(i) and not context.is_structure(i) \
						and _fire_cells.has(context.enemy_cells[i]):
					_apply_damage(i, slice, context, false, false)
	if _scales != null:
		# Les écailles brûlent ce qui vient à son contact.
		_scales_tick -= delta
		if _scales_tick <= 0.0:
			_scales_tick = ZONE_TICK
			for i in _creatures_within(context.player_cell, 1.0, context):
				if not _burning.has(i):
					_ignite(i, _scales.burn_dps, FIRE_CELL_SECONDS)
		# Elles cèdent au premier coup, ou à l'échéance.
		if health.shield <= 0 or _shield_left <= 0.0:
			_burst_scales(context)
	if not _shadow.is_empty():
		for strike in _shadow.duplicate():
			strike["left"] = float(strike["left"]) - delta
			if float(strike["left"]) > 0.0:
				continue
			_shadow.erase(strike)
			var index: int = strike["index"]
			if not context.enemy_alive(index):
				continue
			var ability: Ability = strike["ability"]
			shadow_column.emit(context.enemy_cells[index], bool(strike["first"]))
			var column := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST,
				"element": ability.element, "damage": ability.damage, "radius": ability.meteor_radius})
			# Le Ciel en feu : un météore à rayon, dont le point d'impact reste en feu.
			if ability.meteor_radius > 0.0:
				var at: Vector2i = context.enemy_cells[index]
				_apply_area(column, at, context, null, false, true)
				_ignite_cells(_floor_within(at, ability.meteor_radius), ability.ground_fire)
			else:
				_apply_damage(index, column, context, false, true)
		if _shadow.is_empty():
			shadow_ended.emit()


## LE FEU PRIMORDIAL : chaque ennemi mort dans le feu éclate à l'image suivante, blesse ses voisins et
## enflamme les cases autour de lui. Une mort qu'il provoque dans le feu éclate à son tour.
func _burst_primal(context: CombatContext) -> void:
	var cells := _primal_pending.duplicate()
	_primal_pending.clear()
	var burst := Ability.make({"id": "feu_primordial", "kind": Ability.Kind.BLAST,
		"element": Element.Kind.INFERNO, "damage": PRIMAL_BURST_DAMAGE, "radius": PRIMAL_BURST_RADIUS})
	for cell: Vector2i in cells:
		primal_burst.emit(cell)
		_apply_area(burst, cell, context, null, false, false)
		var around := [cell]
		for side: Vector2i in MazeGrid.NEIGHBORS:
			around.append(cell + side)
		_ignite_cells(around, FIRE_CELL_SECONDS)


func start_primal() -> void:
	_primal = true
	primal_changed.emit(true)


func stop_primal() -> void:
	if not _primal:
		return
	_primal = false
	_primal_pending.clear()
	primal_changed.emit(false)


func primal() -> bool:
	return _primal


## Les cases de sol à `radius` d'une case, par les couloirs.
func _floor_within(centre: Vector2i, radius: float) -> Array:
	var field := _field_from(centre)
	var out := []
	var reach := int(ceil(radius))
	for dy in range(-reach, reach + 1):
		for dx in range(-reach, reach + 1):
			var cell := centre + Vector2i(dx, dy)
			if not grid.is_floor_v(cell):
				continue
			var distance := Pathfinder.value_at(grid, field, cell)
			if distance >= 0 and float(distance) <= radius:
				out.append(cell)
	return out


## Le Souffle infernal : un jet qui SUIT le couloir devant lui, comme la vague.
func _cast_breath(ability: Ability, context: CombatContext) -> bool:
	var facing := context.player_facing
	if facing == Vector2i.ZERO:
		facing = Vector2i.DOWN
	var path := _corridor_ahead(context.player_cell, facing, ability.range)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var cells := []
	var on_path := {}
	for cell in path:
		cells.append(cell)
		on_path[cell] = true
	# Le Souffle primordial déborde sur les cases qui bordent le couloir.
	if ability.breath_spill:
		for cell in path:
			for side: Vector2i in MazeGrid.NEIGHBORS:
				var edge: Vector2i = cell + side
				if grid.is_floor_v(edge) and not on_path.has(edge) and edge != context.player_cell:
					on_path[edge] = true
					cells.append(edge)
	breath_cast.emit(context.player_cell, cells, ability.ground_fire)
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and on_path.has(context.enemy_cells[i]):
			_apply_damage(i, ability, context)
	_ignite_cells(cells, ability.ground_fire)
	return true


## La Morsure : il bondit jusqu'au contact de l'ennemi le plus proche, par les couloirs.
func _cast_bite(ability: Ability, context: CombatContext) -> bool:
	var field := _field_from(context.player_cell)
	var target := -1
	var best := ability.range + 1
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best:
			best = distance
			target = i
	if target < 0:
		use_refused.emit("cible")
		return false
	if best > 1 and player_rooted():
		use_refused.emit("immobile")
		return false
	var prey: Vector2i = context.enemy_cells[target]
	var toward := _field_from(prey)
	var to := context.player_cell
	while Pathfinder.value_at(grid, toward, to) > 1:
		to = Pathfinder.step_toward(grid, toward, to) + to
	if to != context.player_cell:
		blink_performed.emit(context.player_cell, to)
	var devoured := _is_aflame(target, context)
	dragon_bit.emit(target, prey, devoured)
	_apply_damage(target, ability, context)
	# Le Dévoreur avale entière une proie en feu assez blessée ; jamais un boss.
	if devoured and ability.execute_below > 0.0 and context.enemy_alive(target) \
			and not context.bosses.has(target):
		var left: Health = context.enemy_health[target]
		if float(left.current) <= float(left.maximum) * ability.execute_below:
			_apply_damage(target, Ability.make({"id": ability.id + "_avale", "kind": ability.kind,
				"element": ability.element, "damage": left.current}), context, false, false)
	if devoured:
		var gained := health.heal(ability.bite_heal)
		if gained > 0:
			player_healed.emit(gained)
	return true


func _cast_scales(ability: Ability) -> bool:
	health.add_shield(ability.damage)
	_shield_left = ability.duration
	_scales = ability
	_scales_tick = 0.0
	player_shielded.emit(ability.damage, ability.duration)
	scales_raised.emit(ability.duration)
	return true


func _burst_scales(context: CombatContext) -> void:
	var ability := _scales
	_scales = null
	scales_burst.emit(context.player_cell, ability.shard_count, ability.radius)
	var shard := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST,
		"element": ability.element, "damage": ability.shard_damage})
	for i in _creatures_within(context.player_cell, ability.radius, context):
		_apply_damage(i, shard, context, false, true)


## Le Battement d'ailes : ce qui l'entoure est repoussé et prend feu, et lui recule d'un bond.
## Les boss brûlent, mais ne bougent pas.
func _cast_wingbeat(ability: Ability, context: CombatContext) -> bool:
	wings_beaten.emit(context.player_cell, ability.radius)
	for i in _creatures_within(context.player_cell, ability.radius, context):
		_apply_damage(i, ability, context)
		if not context.enemy_alive(i):
			continue
		_ignite(i, ability.burn_dps, ability.duration)
		if not context.bosses.has(i):
			_push_away(i, context, ability.blow_cells)
	if player_rooted():
		return true
	var back := -context.player_facing
	if back == Vector2i.ZERO:
		back = Vector2i.UP
	var to := context.player_cell
	for _step in ability.range:
		var next: Vector2i = to + back
		if not grid.is_floor_v(next) or grid.is_occupied(next):
			break
		to = next
	if to != context.player_cell:
		blink_performed.emit(context.player_cell, to)
	return true


## L'Ombre du Dragon : tout ce qui est à l'écran brûle, puis explose dans l'ordre où l'ombre passe.
func _cast_dragon_shadow(ability: Ability, context: CombatContext) -> bool:
	var direction := context.player_facing
	if direction == Vector2i.ZERO:
		direction = Vector2i.RIGHT
	var targets := _creatures_in_sky(context.player_cell, ability.radius, context)
	var axis := Vector2(direction)
	targets.sort_custom(func(a: int, b: int) -> bool:
		return Vector2(context.enemy_cells[a]).dot(axis) < Vector2(context.enemy_cells[b]).dot(axis))
	var cells := []
	var indices := []
	for k in targets.size():
		var i: int = targets[k]
		indices.append(i)
		cells.append(context.enemy_cells[i])
		_ignite(i, ability.burn_dps, ability.duration)
		_shadow.append({"index": i, "left": SHADOW_DELAY + SHADOW_GAP * k, "first": k == 0,
			"ability": ability})
	dragon_shadow_cast.emit(context.player_cell, direction, indices, SHADOW_DELAY)
	_ignite_cells(cells, ability.ground_fire)
	if targets.is_empty():
		shadow_ended.emit()
	return true


# --- Le Croupier des Enfers -----------------------------------------------------------
#
# Chaque sort tire au sort son résultat, avec `_rng` : la même graine rejoue la même partie, et
# l'équilibrage mesure le hasard comme le reste. Aucun tirage ne le laisse perdant.

## Pile double ses prochains coups ; le trait, lui, fait un critique de loin en loin.
func _gamble(index: int, power: int, ability: Ability, with_trait: bool, context: CombatContext) -> int:
	if _doubled_left > 0 and ability == stats.attack:
		_doubled_left -= 1
		power *= 2
		if _doubled_left == 0:
			doubled_spent.emit()
	if with_trait and _rng.randf() < LUCK_CHANCE * (HOUSE_LUCK if _house else 1.0):
		power *= LUCK_MULT
		lucky_hit.emit(index, context.enemy_cells[index])
		if _house:
			_payouts.append(context.enemy_cells[index])
	return power


func doubled_left() -> int:
	return _doubled_left


func traps() -> Array[Dictionary]:
	return _traps


## Les Dés pipés roulent dans le couloir devant lui, comme le Souffle du Dragon.
func _cast_dice(ability: Ability, context: CombatContext) -> bool:
	var facing := context.player_facing
	if facing == Vector2i.ZERO:
		facing = Vector2i.DOWN
	var path := _corridor_ahead(context.player_cell, facing, ability.range)
	if path.is_empty():
		use_refused.emit("mur")
		return false
	var first := _rng.randi_range(1, 6)
	var second := _rng.randi_range(1, 6)
	# Les Dés du Diable roulent un troisième dé : un double sonne toujours, un brelan fige et brûle.
	var third := _rng.randi_range(1, 6) if ability.dice_count > 2 else 0
	var double := first == second or (third > 0 and (third == first or third == second))
	var triple := third > 0 and first == second and second == third
	var cells := []
	var on_path := {}
	for cell in path:
		cells.append(cell)
		on_path[cell] = true
	dice_rolled.emit(context.player_cell, cells, first, second)
	if third > 0:
		devil_die.emit(context.player_cell, cells, third, triple)
	var roll := Ability.make({"id": ability.id, "display_name": ability.display_name, "kind": ability.kind,
		"element": ability.element, "damage": ability.damage * (first + second + third)})
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or not on_path.has(context.enemy_cells[i]):
			continue
		_apply_damage(i, roll, context)
		if double and context.enemy_alive(i) and not context.bosses.has(i) \
				and not context.is_structure(i):
			enemy_staggered.emit(i, ability.stun_seconds * (2.0 if triple else 1.0))
		if triple and context.enemy_alive(i):
			_ignite(i, maxi(10, ability.damage * 2), TRAP_BURN_SECONDS)
	return true


## La carte se pose sous lui. Au-delà de `trap_count`, la plus ancienne s'efface.
func _cast_trap(ability: Ability, context: CombatContext) -> bool:
	# La Table piégée : quatre cartes en croix autour de lui, d'un coup.
	if ability.trap_cross:
		for trap in _traps:
			trap_faded.emit(trap["cell"])
		_traps.clear()
		for side: Vector2i in MazeGrid.NEIGHBORS:
			var spot: Vector2i = context.player_cell + side
			if not grid.is_floor_v(spot):
				spot = context.player_cell + side * 2 if grid.is_floor_v(context.player_cell + side * 2) else context.player_cell
			if _traps.any(func(t: Dictionary) -> bool: return t["cell"] == spot):
				continue
			_traps.append({"cell": spot, "left": ability.duration, "ability": ability})
			trap_posed.emit(spot, ability.duration)
		return true
	for trap in _traps:
		if trap["cell"] == context.player_cell:
			trap["left"] = ability.duration
			trap_posed.emit(context.player_cell, ability.duration)
			return true
	while _traps.size() >= maxi(1, ability.trap_count):
		trap_faded.emit(_traps[0]["cell"])
		_traps.remove_at(0)
	_traps.append({"cell": context.player_cell, "left": ability.duration, "ability": ability})
	trap_posed.emit(context.player_cell, ability.duration)
	return true


func _flip_trap(trap: Dictionary, index: int, context: CombatContext) -> void:
	var ability: Ability = trap["ability"]
	var cell: Vector2i = trap["cell"]
	var suit := _rng.randi_range(0, 2)
	# Le Joker fait les trois figures à la fois.
	if ability.joker_chance > 0.0 and _rng.randf() < ability.joker_chance:
		suit = Suit.JOKER
	var targets: Array[int] = [index]
	if suit == Suit.THUNDER or suit == Suit.JOKER:
		var field := _field_from(cell)
		var near := _creatures_within(cell, float(TRAP_REACH), context)
		near.erase(index)
		near.sort_custom(func(a: int, b: int) -> bool:
			return Pathfinder.value_at(grid, field, context.enemy_cells[a]) \
				< Pathfinder.value_at(grid, field, context.enemy_cells[b]))
		for k in mini(TRAP_CHAIN, near.size()):
			targets.append(near[k])
	var cells := []
	for t in targets:
		cells.append(context.enemy_cells[t])
	trap_flipped.emit(cell, suit, cells)
	for t in targets:
		_apply_damage(t, ability, context)
		if not context.enemy_alive(t):
			continue
		if suit == Suit.FIRE or suit == Suit.JOKER:
			_ignite(t, ability.burn_dps, TRAP_BURN_SECONDS)
		if (suit == Suit.ICE or suit == Suit.JOKER) and not context.bosses.has(t):
			enemy_staggered.emit(t, ability.stun_seconds)


## Pile ou face : il gagne toujours quelque chose.
func _cast_coin(ability: Ability) -> bool:
	var face := _rng.randf() < 0.5
	coin_flipped.emit(face)
	# La Pièce truquée retombe sur la tranche : les deux faces à la fois.
	if ability.coin_both:
		_doubled_left = ability.doubled_hits
		face = true
	if face:
		health.immune = true
		_immune_left = maxf(_immune_left, ability.duration)
		player_made_immune.emit(ability.duration)
		var gained := health.heal(ability.coin_heal)
		if gained > 0:
			player_healed.emit(gained)
	else:
		_doubled_left = ability.doubled_hits
	return true


func _cast_roulette(ability: Ability, context: CombatContext) -> bool:
	var result := Slot.ZERO if _rng.randf() < ROULETTE_ZERO \
		else (Slot.RED if _rng.randf() < 0.5 else Slot.BLACK)
	_roulette = {"left": ROULETTE_SPIN, "result": result, "ability": ability,
		"spins": maxi(1, ability.roulette_spins)}
	roulette_spun.emit(context.player_cell, result, ROULETTE_SPIN)
	return true


func _update_croupier(delta: float, context: CombatContext) -> void:
	# ⚠️ Le Tour de passe-passe est un leurre comme celui du Roi de Braise, qui le tient avec ses pièces : sans
	# cette ligne, il ne s'éteignait jamais et les ennemis le cherchaient pour toujours.
	if stats.element == Element.Kind.LUCK and _pieces.is_empty():
		_update_decoy(delta, context)
	if not _payouts.is_empty():
		var paid := _payouts.duplicate()
		_payouts.clear()
		var chips := Ability.make({"id": "jetons", "kind": Ability.Kind.BLAST, "element": Element.Kind.LUCK,
			"damage": PAYOUT_DAMAGE, "radius": PAYOUT_RADIUS})
		for cell: Vector2i in paid:
			house_payout.emit(cell, PAYOUT_RADIUS)
			_apply_area(chips, cell, context, null, false, false)
	for trap in _traps.duplicate():
		trap["left"] = float(trap["left"]) - delta
		if float(trap["left"]) <= 0.0:
			_traps.erase(trap)
			trap_faded.emit(trap["cell"])
			continue
		for i in context.enemy_cells.size():
			if context.enemy_alive(i) and not context.is_structure(i) \
					and context.enemy_cells[i] == trap["cell"]:
				_traps.erase(trap)
				_flip_trap(trap, i, context)
				break
	if _roulette.is_empty():
		return
	_roulette["left"] = float(_roulette["left"]) - delta
	if float(_roulette["left"]) > 0.0:
		return
	var ability: Ability = _roulette["ability"]
	var result: int = _roulette["result"]
	var spins_left: int = int(_roulette.get("spins", 1)) - 1
	_roulette = {}
	# Le Grand Jeu : la roue repart aussitôt, avec un nouveau tirage.
	if spins_left > 0:
		var next := Slot.ZERO if _rng.randf() < ROULETTE_ZERO \
			else (Slot.RED if _rng.randf() < 0.5 else Slot.BLACK)
		_roulette = {"left": ROULETTE_SPIN, "result": next, "ability": ability, "spins": spins_left,
			"pending": true}
	var targets := _creatures_in_sky(context.player_cell, ability.radius, context)
	var cells := []
	for t in targets:
		cells.append(context.enemy_cells[t])
	roulette_landed.emit(result, cells)
	var hit := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"is_ultimate": true,
		"damage": ability.damage if result == Slot.ZERO else (ability.black_damage if result == Slot.BLACK else 0)})
	for t in targets:
		if result == Slot.RED:
			_ignite(t, ability.burn_dps, ability.duration)
			continue
		_apply_damage(t, hit, context, false, true)
		if result == Slot.BLACK and context.enemy_alive(t) and not context.bosses.has(t):
			enemy_staggered.emit(t, ability.stun_seconds)
	if bool(_roulette.get("pending", false)):
		_roulette.erase("pending")
		roulette_spun.emit(context.player_cell, int(_roulette["result"]), ROULETTE_SPIN)


## LA MAISON GAGNE TOUJOURS : tant qu'elle dure, le Coup de chance tombe plus souvent et paie des jetons.
func start_house() -> void:
	_house = true
	house_changed.emit(true)


func stop_house() -> void:
	if not _house:
		return
	_house = false
	_payouts.clear()
	house_changed.emit(false)


func house() -> bool:
	return _house


# --- L'Avide, Démon de la Faim ---------------------------------------------------------
#
# Chaque ennemi tué est une bouchée : il grandit et frappe plus fort. Il peut les garder, ou
# les recracher toutes d'un coup. Le jeu lit `bites()` pour sa taille, la simulation pour ses dégâts.

func bites() -> int:
	return _bites


func feasting() -> bool:
	return not _feast.is_empty()


func _gain_bite() -> void:
	_bite_decay = BITE_DECAY
	var cap := ENDLESS_BITES if _endless else BITES_MAX
	if _bites >= cap:
		return
	_bites = mini(cap, _bites + (ENDLESS_GAIN if _endless else 1))
	bites_changed.emit(_bites, true)


## LA FAIM SANS FOND : tant qu'elle dure, plus de bouchées, qui ne fondent plus. À la fin, il garde ce que sa
## forme de base peut tenir.
func start_endless() -> void:
	_endless = true
	endless_changed.emit(true)


func stop_endless() -> void:
	if not _endless:
		return
	_endless = false
	if _bites > BITES_MAX:
		_bites = BITES_MAX
		bites_changed.emit(_bites, false)
	endless_changed.emit(false)


func endless() -> bool:
	return _endless


## La faim : un coup plus fort par bouchée, sur le coup d'origine seulement.
func _hunger_bonus(power: int) -> int:
	return int(round(float(power) * (1.0 + BITE_DAMAGE * float(_bites))))


func _cast_gulf(ability: Ability, context: CombatContext) -> bool:
	var target := _nearest_in_reach(context.player_cell, ability.range, context)
	if target < 0 or context.is_structure(target):
		use_refused.emit("cible")
		return false
	var cell: Vector2i = context.enemy_cells[target]
	_gulf = {"cell": cell, "left": ability.duration, "pull": 0.0, "ability": ability}
	gulf_opened.emit(cell, ability.radius, ability.duration)
	return true


## Le Gouffre tire d'une case, à intervalles, tout ce qui est dans son rayon — par les couloirs.
func _pull_gulf(delta: float, context: CombatContext) -> void:
	var ability: Ability = _gulf["ability"]
	var centre: Vector2i = _gulf["cell"]
	_gulf["left"] = float(_gulf["left"]) - delta
	_gulf["pull"] = float(_gulf["pull"]) - delta
	if float(_gulf["pull"]) <= 0.0 and float(_gulf["left"]) > 0.0:
		_gulf["pull"] = GULF_PULL_GAP
		var field := _field_from(centre)
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or context.is_structure(i) or context.bosses.has(i):
				continue
			var cell: Vector2i = context.enemy_cells[i]
			var here := Pathfinder.value_at(grid, field, cell)
			if here <= 0 or float(here) > ability.radius:
				continue
			var next := Pathfinder.step_toward(grid, field, cell) + cell
			if grid.is_floor_v(next) and next != context.player_cell:
				context.enemy_cells[i] = next
				enemy_hauled.emit(i, next)
	if float(_gulf["left"]) > 0.0:
		return
	_gulf = {}
	var caught := _creatures_within(centre, GULF_BITE_RADIUS, context)
	var cells := []
	for i in caught:
		cells.append(context.enemy_cells[i])
	gulf_closed.emit(centre, cells)
	var bite := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.damage})
	for i in caught:
		_apply_damage(i, bite, context)


func _cast_devour(ability: Ability, context: CombatContext) -> bool:
	var target := _nearest_in_reach(context.player_cell, ability.range, context)
	if target < 0 or context.is_structure(target):
		use_refused.emit("cible")
		return false
	# Tout dévorer : les proies suivantes, les plus proches après la première.
	if ability.devour_count > 1:
		var field := _field_from(context.player_cell)
		var others := []
		for i in context.enemy_cells.size():
			if i == target or not context.enemy_alive(i) or context.is_structure(i):
				continue
			var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
			if distance >= 0 and distance <= ability.range:
				others.append(i)
		others.sort_custom(func(a: int, b: int) -> bool:
			return Pathfinder.value_at(grid, field, context.enemy_cells[a]) \
				< Pathfinder.value_at(grid, field, context.enemy_cells[b]))
		for k in mini(others.size(), ability.devour_count - 1):
			_devour_one(others[k], ability, context)
	_devour_one(target, ability, context)
	return true


func _devour_one(target: int, ability: Ability, context: CombatContext) -> void:
	var life: Health = context.enemy_health[target]
	var swallowed := not context.bosses.has(target) \
		and float(life.current) <= float(life.maximum) * ability.execute_below
	devoured.emit(target, context.enemy_cells[target], swallowed)
	if swallowed:
		var whole := Ability.make({"id": ability.id, "kind": ability.kind, "element": ability.element,
			"damage": life.current})
		_apply_damage(target, whole, context, false, false)
	else:
		_apply_damage(target, ability, context)
	if not context.enemy_alive(target):
		var gained := health.heal(ability.bite_heal)
		if gained > 0:
			player_healed.emit(gained)


## Une boule par bouchée, sur les ennemis les plus proches ; sans proie, droit devant lui.
func _cast_regurgitate(ability: Ability, context: CombatContext) -> bool:
	if _bites <= 0:
		use_refused.emit("faim")
		return false
	var count := _bites
	_bites = 0
	bites_changed.emit(0, false)
	var field := _field_from(context.player_cell)
	var prey: Array[int] = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance <= ability.range:
			prey.append(i)
	prey.sort_custom(func(a: int, b: int) -> bool:
		return Pathfinder.value_at(grid, field, context.enemy_cells[a]) \
			< Pathfinder.value_at(grid, field, context.enemy_cells[b]))
	var facing := context.player_facing if context.player_facing != Vector2i.ZERO else Vector2i.DOWN
	var ahead := _corridor_ahead(context.player_cell, facing, ability.range)
	var cells := []
	for k in count:
		if not prey.is_empty():
			cells.append(context.enemy_cells[prey[k % prey.size()]])
		elif not ahead.is_empty():
			cells.append(ahead[mini(ahead.size() - 1, k + 1)])
		else:
			cells.append(context.player_cell)
	regurgitated.emit(context.player_cell, cells)
	var ball := Ability.make({"id": ability.id, "kind": Ability.Kind.BLAST, "element": ability.element,
		"damage": ability.damage, "radius": ability.radius})
	for cell: Vector2i in cells:
		_apply_area(ball, cell, context)
	# Le Déluge de bile : chaque boule laisse une flaque d'acide, une seule par case.
	if ability.bile_seconds > 0.0:
		var bile := Ability.make({"id": ability.id + "_bile", "display_name": ability.display_name,
			"kind": Ability.Kind.ZONE, "element": ability.element, "damage": ability.bile_damage,
			"radius": ability.radius * 0.8, "duration": ability.bile_seconds, "zone_style": "bile_peinte"})
		var laid := {}
		for cell: Vector2i in cells:
			if laid.has(cell):
				continue
			laid[cell] = true
			var id := _next_zone_id
			_next_zone_id += 1
			_zones.append({"id": id, "ability": bile, "cell": cell, "time_left": bile.duration, "tick": 0.0})
			zone_created.emit(id, bile, cell)
	return true


## Le bond file droit devant jusqu'à une haie ; l'atterrissage sonne ce qui l'entoure, sauf un boss.
func _cast_leap(ability: Ability, context: CombatContext) -> bool:
	if player_rooted():
		use_refused.emit("immobile")
		return false
	var facing := context.player_facing if context.player_facing != Vector2i.ZERO else Vector2i.DOWN
	var to := context.player_cell
	for _step in ability.range:
		var next: Vector2i = to + facing
		if not grid.is_floor_v(next):
			break
		to = next
	if to == context.player_cell:
		use_refused.emit("mur")
		return false
	blink_performed.emit(context.player_cell, to)
	leap_landed.emit(to, ability.radius)
	for i in _creatures_within(to, ability.radius, context):
		# Le Bond du prédateur : la gueule du ventre mord en retombant.
		if ability.damage > 0:
			_apply_damage(i, ability, context)
		if context.enemy_alive(i) and not context.bosses.has(i):
			enemy_staggered.emit(i, ability.stun_seconds)
	return true


func _cast_feast(ability: Ability) -> bool:
	_feast = {"left": ability.duration, "gap": FEAST_FIRST, "eaten": {}, "heals": 0, "ability": ability}
	feast_started.emit(ability.duration)
	return true


func _update_avide(delta: float, context: CombatContext) -> void:
	if _bites > 0 and _feast.is_empty() and not _endless:
		_bite_decay -= delta
		if _bite_decay <= 0.0:
			_bite_decay = BITE_DECAY
			_bites -= 1
			bites_changed.emit(_bites, false)
	if not _gulf.is_empty():
		_pull_gulf(delta, context)
	if _feast.is_empty():
		return
	var ability: Ability = _feast["ability"]
	_feast["left"] = float(_feast["left"]) - delta
	_feast["gap"] = float(_feast["gap"]) - delta
	if float(_feast["gap"]) <= 0.0:
		_feast["gap"] = ability.feast_gap if ability.feast_gap > 0.0 else FEAST_GAP
		var eaten: Dictionary = _feast["eaten"]
		var best := -1
		var best_distance := INF
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i) or context.is_structure(i) or eaten.has(i):
				continue
			var distance := Vector2(context.enemy_cells[i] - context.player_cell).length()
			if distance <= ability.radius and distance < best_distance:
				best_distance = distance
				best = i
		if best >= 0:
			eaten[best] = true
			var cell: Vector2i = context.enemy_cells[best]
			_apply_damage(best, ability, context, false, true)
			var killed := not context.enemy_alive(best)
			feast_bite.emit(best, cell, killed)
			if killed and int(_feast["heals"]) < (ability.feast_heal_cap if ability.feast_heal_cap > 0 else FEAST_HEALS):
				var gained := health.heal(ability.bite_heal)
				if gained > 0:
					_feast["heals"] = int(_feast["heals"]) + 1
					player_healed.emit(gained)
	if float(_feast["left"]) <= 0.0:
		_feast = {}
		feast_ended.emit()


# --- Invocations ------------------------------------------------------------------

func _cast_summon(ability: Ability, context: CombatContext) -> bool:
	if not SUMMON_KINDS.has(ability.summon_id):
		push_error("Créature d'invocation inconnue : " + ability.summon_id)
		return false
	if ability.summon_portals > 0:
		return _tear_rifts(ability, context)
	for i in maxi(1, ability.summon_count):
		# Les créatures naissent autour du mage, chacune sur sa case praticable :
		# empilées sur la sienne, on ne verrait qu'une seule invocation.
		# La Gargouille colossale, elle, tombe du ciel à côté de la proie.
		var cell := _drop_cell(context) if ability.summon_drop_damage > 0 \
			else _summon_spawn_cell(context, i)
		var summon := _spawn_summon(ability.summon_id, cell, ability.duration, ability)
		if ability.summon_drop_damage > 0:
			_summon_drop(summon, ability, context)
	if ability.flyover_damage > 0:
		_dragon_flyover(ability, context)
	# La plus ancienne cède la place au-delà du plafond — jamais la nouvelle :
	# un sort qui échoue parce qu'on l'a déjà lancé se lit comme une panne.
	_trim_summons(context)
	# Le champ des proies est immédiatement rafraîchi : une créature qui reste
	# plantée une tierce de seconde à sa naissance a l'air cassée.
	_summon_field_timer = 0.0
	return true



## LA FAILLE DES TÉNÈBRES : des portes s'ouvrent SUR LES PROIES.
##
## L'ultime ne fait pas venir des créatures, il ouvre un ENDROIT. C'est ce qui le
## sépare de l'Invocateur, dont les bêtes naissent aux pieds du mage et doivent
## traverser le labyrinthe : ici le trajet est déjà fait, la porte s'ouvre au
## contact de ce qu'elle vient chasser.
##
## Une porte par créature, les plus proches d'abord, plafonnées à
## `summon_portals`. Autant de portes que d'ennemis viderait un stage tardif
## d'un seul geste — l'ultime cesserait d'être un coup pour devenir la fin de la
## partie.
##
## Les portes ne s'ouvrent PAS sur la case de la proie mais à côté : une ombre
## née sous les pieds d'un ennemi serait invisible, et deux sprites empilés ne
## disent ni qui frappe ni ce qui est frappé — la même règle que le refus du
## dernier pas des poursuivants.
func _tear_rifts(ability: Ability, context: CombatContext) -> bool:
	var prey := _closest_prey(ability.summon_portals, context)
	if prey.is_empty():
		# AUCUNE PROIE : le sort est refusé et ne coûte rien. Un ultime dépensé
		# dans un couloir vide serait un vol pur — il se gagne en quatre kills.
		use_refused.emit("cible")
		return false
	for index in prey:
		var door := _rift_cell(context.enemy_cells[index])
		rift_opened.emit(door)
		for i in maxi(1, ability.summon_count):
			var cell := _rift_spawn_cell(door, i)
			var summon := {
				"id": _next_summon_id, "kind": ability.summon_id,
				"position": Vector2(cell), "cell": cell,
				"time_left": ability.duration, "strike_in": 0.6,
				"facing": Vector2i.DOWN, "target": -1,
			}
			_next_summon_id += 1
			_summons.append(summon)
			summon_spawned.emit(int(summon["id"]), ability.summon_id, summon["position"])
	var cap := maxi(MAX_SUMMONS, ability.summon_cap)
	while _summons.size() > cap:
		var oldest: Dictionary = _summons.pop_front()
		summon_expired.emit(int(oldest["id"]))
	_summon_field_timer = 0.0
	return true


## Les N créatures vivantes les plus proches du mage, en distance de chemin.
##
## Les plus proches et non les plus faibles : le joueur lance son ultime en
## voyant une meute lui arriver dessus, et les portes doivent s'ouvrir sur CETTE
## meute-là. Un ciblage malin qui irait chercher le blessé à l'autre bout du
## labyrinthe se lirait comme un bug.
func _closest_prey(count: int, context: CombatContext) -> Array[int]:
	var field := _field_from(context.player_cell)
	var scored: Array = []
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0:
			continue
		scored.append({"index": i, "distance": distance})
	scored.sort_custom(func(a, b): return int(a["distance"]) < int(b["distance"]))
	var chosen: Array[int] = []
	for entry in scored:
		if chosen.size() >= maxi(1, count):
			break
		chosen.append(int(entry["index"]))
	return chosen


## La case de la porte : voisine de la proie, praticable. À défaut, la sienne —
## mieux vaut une porte mal placée qu'un ultime qui n'ouvre rien.
func _rift_cell(prey: Vector2i) -> Vector2i:
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(prey + step):
			return prey + step
	return prey


func _rift_spawn_cell(door: Vector2i, offset: int) -> Vector2i:
	var candidates: Array[Vector2i] = [door]
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(door + step):
			candidates.append(door + step)
	return candidates[offset % candidates.size()]


func _summon_spawn_cell(context: CombatContext, offset: int) -> Vector2i:
	var candidates: Array[Vector2i] = []
	for step in MazeGrid.NEIGHBORS:
		if grid.is_floor_v(context.player_cell + step):
			candidates.append(context.player_cell + step)
	if candidates.is_empty():
		return context.player_cell
	return candidates[offset % candidates.size()]


func _update_summons(delta: float, context: CombatContext) -> void:
	if _summons.is_empty():
		return
	_summon_field_timer -= delta
	if _summon_field_timer <= 0.0:
		_summon_field_timer = SUMMON_FIELD_REFRESH
		_refresh_summon_field(context)

	for i in range(_summons.size() - 1, -1, -1):
		var summon: Dictionary = _summons[i]
		summon["time_left"] = float(summon["time_left"]) - delta
		if float(summon["time_left"]) <= 0.0:
			_summons.remove_at(i)
			_summon_leaves(summon, context)
			continue
		summon["strike_in"] = maxf(0.0, float(summon["strike_in"]) - delta)
		var stats: Dictionary = SUMMON_KINDS[summon["kind"]]
		var target := _nearest_prey(summon, context)
		summon["target"] = target
		if target >= 0 and _try_strike(summon, stats, target, context):
			continue
		_advance_summon(summon, stats, target, delta, context)


func _update_summon_projectiles(delta: float, context: CombatContext) -> void:
	for i in range(_summon_projectiles.size() - 1, -1, -1):
		var shot: Dictionary = _summon_projectiles[i]
		shot["time_left"] = float(shot["time_left"]) - delta
		if float(shot["time_left"]) > 0.0:
			continue
		_summon_projectiles.remove_at(i)
		var target := int(shot["target"])
		if target < 0 or not context.enemy_alive(target):
			continue
		var ability: Ability = shot["ability"]
		summon_projectile_hit.emit(int(shot["id"]), target,
			context.enemy_cells[target], ability)
		if ability.radius > 0.0:
			_apply_area(ability, context.enemy_cells[target], context, null, false)
		else:
			_apply_damage(target, ability, context, false)


## La proie : l'ennemi vivant le plus proche. À VOL D'OISEAU pour le dragon qui
## vole, en distance de couloir pour les marcheurs — chacun sa géométrie.
func _nearest_prey(summon: Dictionary, context: CombatContext) -> int:
	# La proie MARQUÉE par le Maître des Légions passe avant toutes les autres.
	if not _legion_mark.is_empty() and context.enemy_alive(int(_legion_mark["index"])):
		return int(_legion_mark["index"])
	var best := -1
	var best_score := 1e9
	var position: Vector2 = summon["position"]
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var score := position.distance_to(Vector2(context.enemy_cells[i]))
		if score < best_score:
			best_score = score
			best = i
	return best


func _try_strike(summon: Dictionary, stats: Dictionary, target: int,
		context: CombatContext) -> bool:
	var reach := float(stats["reach"])
	var position: Vector2 = summon["position"]
	var distance := position.distance_to(Vector2(context.enemy_cells[target]))
	var min_reach := float(stats.get("min_reach", 0.0))
	if distance > reach or distance < min_reach:
		return false
	if float(summon["strike_in"]) > 0.0:
		return true
	summon["strike_in"] = float(stats["period"])
	if summon["kind"] == "dragon":
		var aim := Vector2(context.enemy_cells[target]) - position
		if absf(aim.x) > absf(aim.y):
			summon["facing"] = Vector2i.RIGHT if aim.x > 0.0 else Vector2i.LEFT
		else:
			summon["facing"] = Vector2i.DOWN if aim.y > 0.0 else Vector2i.UP
		summon_moved.emit(int(summon["id"]), position, summon["facing"])
	summon_struck.emit(int(summon["id"]), target)
	if summon["kind"] == "dragon":
		var ability := Ability.make({
			"id": "dragon_fire_breath", "display_name": "Souffle du dragon",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": _summon_damage(summon, stats), "projectile_speed": float(stats["projectile_speed"]),
			"projectile_scale": 1.65, "trail_density": 0.9, "flames": 1.15,
			"pierces_walls": true,
		})
		# La boule du Roi-Dragon embrasé explose : elle brûle aussi les voisins de sa cible.
		if str(summon.get("look", "")) == "dragon_eveil":
			ability.radius = ROYAL_FIREBALL_RADIUS
		var speed := PROJECTILE_SPEED * float(stats["projectile_speed"])
		var duration := maxf(0.12, distance / speed)
		_summon_projectiles.append({"id": int(summon["id"]), "target": target,
			"time_left": duration, "ability": ability})
		summon_projectile_launched.emit(int(summon["id"]), target, position,
			Vector2(context.enemy_cells[target]), duration, ability)
		return true
	# Les coups d'une créature ne déclenchent PAS de trait élémentaire : le
	# trait est la signature du mage, pas celle de ses bêtes — et un dragon qui
	# répandrait la brûlure du Feu brouillerait la lecture des personnages.
	var blow := Ability.make({
		"id": "summon_" + str(summon["kind"]), "kind": Ability.Kind.ZONE,
		"element": Element.Kind.SHADOW, "damage": _summon_damage(summon, stats),
	})
	_apply_damage(target, blow, context, false)
	# LE GAZ EMPOISONNE. C'est ce qui fait d'un souffle autre chose qu'une
	# morsure à distance : il ne compte pas sur le coup mais sur ce qu'il laisse,
	# et six ombres qui empoisonnent la même créature ne l'empoisonnent pas six
	# fois — la pose la plus récente remplace la précédente, comme une flaque.
	if stats.has("poison") and context.enemy_alive(target):
		_poisoned[target] = {"time_left": POISON_TICK * 6.0,
			"timer": POISON_TICK, "damage": int(stats["poison"])}
		enemy_poisoned.emit(target, POISON_TICK * 6.0)
	return true


## Les créatures de la Légion frappent plus fort.
func _summon_damage(summon: Dictionary, stats: Dictionary) -> int:
	var damage := float(stats["damage"])
	if bool(summon.get("legion", false)):
		damage *= _legion_ratio
	return int(round(damage))


func _advance_summon(summon: Dictionary, stats: Dictionary, target: int,
		delta: float, context: CombatContext) -> void:
	var position: Vector2 = summon["position"]
	var step := Vector2.ZERO
	if bool(stats["flies"]):
		# Le dragon ignore les murs : droit sur la proie, meme en diagonale.
		if target >= 0:
			step = (Vector2(context.enemy_cells[target]) - position)
			if float(stats.get("min_reach", 0.0)) > 0.0 and \
				position.distance_to(Vector2(context.enemy_cells[target])) < float(stats["min_reach"]):
				step = -step
	else:
		# Les marcheurs descendent le champ des proies, couloir par couloir.
		_walk_summon(summon, float(stats["speed"]) * delta, context)
		return
	if step.length() < 0.05:
		return
	step = step.normalized() * minf(float(stats["speed"]) * delta, step.length())
	summon["position"] = position + step
	if absf(step.x) > absf(step.y):
		summon["facing"] = Vector2i.RIGHT if step.x > 0.0 else Vector2i.LEFT
	elif step.y != 0.0:
		summon["facing"] = Vector2i.DOWN if step.y > 0.0 else Vector2i.UP
	summon_moved.emit(int(summon["id"]), summon["position"], summon["facing"])


## Un marcheur va au CENTRE de la case qu'il a choisie avant d'en choisir une autre.
##
## Il rechoisissait à chaque image depuis la case la plus proche : passé le milieu d'une
## case d'angle, il partait en diagonale à travers le coin de la haie, et chaque nouveau
## champ des proies pouvait le faire revenir sur ses pas au milieu d'un couloir.
func _walk_summon(summon: Dictionary, travel: float, context: CombatContext) -> void:
	var position: Vector2 = summon["position"]
	var heading := Vector2.ZERO
	# Deux passages au plus : ce qui reste du pas à l'arrivée sert sur la case suivante,
	# sans quoi une image longue ralentirait la créature.
	for _i in 2:
		if not summon.has("next") or position.is_equal_approx(Vector2(summon["next"])):
			var cell := Vector2i(position.round())
			var towards := Pathfinder.step_toward(grid, _summon_field, cell)
			if towards == Vector2i.ZERO:
				summon.erase("next")
				break
			summon["next"] = cell + towards
		var left: Vector2 = Vector2(summon["next"]) - position
		var moved := minf(travel, left.length())
		position = Vector2(summon["next"]) if moved >= left.length() \
			else position + left.normalized() * moved
		heading = left
		travel -= moved
		if travel <= 0.0:
			break
	if heading == Vector2.ZERO:
		return
	summon["position"] = position
	if absf(heading.x) > absf(heading.y):
		summon["facing"] = Vector2i.RIGHT if heading.x > 0.0 else Vector2i.LEFT
	else:
		summon["facing"] = Vector2i.DOWN if heading.y > 0.0 else Vector2i.UP
	summon_moved.emit(int(summon["id"]), position, summon["facing"])


func _refresh_summon_field(context: CombatContext) -> void:
	var sources: Array[Vector2i] = []
	for i in context.enemy_cells.size():
		if context.enemy_alive(i) and not context.is_structure(i):
			sources.append(context.enemy_cells[i])
	_summon_field = Pathfinder.distance_field(grid, sources) 		if not sources.is_empty() else PackedInt32Array()


## La créature au contact d'un ennemi, celle qu'il peut frapper. Vide s'il n'y en a pas.
func summon_in_reach(at: Vector2, contact: float) -> Dictionary:
	var best: Dictionary = {}
	var best_gap := contact
	for summon in _summons:
		if not SUMMON_HITS.has(str(summon["kind"])):
			continue
		var gap := at.distance_to(summon["position"] as Vector2)
		if gap < best_gap:
			best_gap = gap
			best = summon
	return best


## LES ENNEMIS FRAPPENT LES CRÉATURES, avec le même coup que contre le mage : armé au contact,
## porté à l'impact (`MeleeSwing`). Appelé par le `Level` et par `test_balance`, qui jouent donc
## la même règle.
##
## `foes[i]` : `position` (en cases), `free` (vivant, libre d'agir, et pas au contact du mage, qui
## passe toujours avant), `windup`, `cycle`, `boss`. Rend les gestes à montrer :
## `{"index", "event" ("started" ou "landed"), "toward"}`.
func defend_against_summons(delta: float, foes: Array, contact: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for index in foes.size():
		var foe: Dictionary = foes[index]
		if not _foe_swings.has(index):
			_foe_swings[index] = MeleeSwing.new()
		var swing: MeleeSwing = _foe_swings[index]
		var at: Vector2 = foe["position"]
		var prey := summon_in_reach(at, contact + MeleeSwing.REACH_MARGIN) \
			if bool(foe["free"]) else {}
		if prey.is_empty():
			swing.cancel()
			continue
		var gap := at.distance_to(prey["position"] as Vector2)
		var toward := _cardinal(prey["position"] as Vector2 - at)
		match swing.tick(delta, gap, contact, float(foe["windup"]), float(foe["cycle"])):
			MeleeSwing.Event.STARTED:
				events.append({"index": index, "event": "started", "toward": toward})
			MeleeSwing.Event.LANDED:
				events.append({"index": index, "event": "landed", "toward": toward})
				_wound_summon(prey, BOSS_BLOW if bool(foe.get("boss", false)) else 1)
	return events


func _wound_summon(summon: Dictionary, blow: int) -> void:
	if not summon.has("hits"):
		var hits := float(SUMMON_HITS[str(summon["kind"])]) * float(summon.get("scale", 1.0))
		if bool(summon.get("legion", false)):
			hits *= LEGION_HITS
		summon["hits"] = maxi(1, int(round(hits)))
		summon["hits_max"] = summon["hits"]
	summon["hits"] = int(summon["hits"]) - blow
	summon_hurt.emit(int(summon["id"]), maxi(0, int(summon["hits"])), int(summon["hits_max"]))
	if int(summon["hits"]) > 0:
		return
	_summons.erase(summon)
	summon_slain.emit(int(summon["id"]))
	_summon_leaves(summon, null)


static func _cardinal(gap: Vector2) -> Vector2i:
	if gap == Vector2.ZERO:
		return Vector2i.DOWN
	if absf(gap.x) >= absf(gap.y):
		return Vector2i(int(signf(gap.x)), 0)
	return Vector2i(0, int(signf(gap.y)))


## Le nombre de créatures encore en chasse — l'interface l'affiche.
func summon_count() -> int:
	return _summons.size()


# --- Dégâts ----------------------------------------------------------------------

## Deux freins, et il a fallu les SÉPARER.
##
## `with_trait` est faux pour les dégâts DÉRIVÉS — tick de brûlure, arc, écho.
## Sans lui, la brûlure rallumerait une brûlure et l'arc rebondirait d'ennemi en
## ennemi jusqu'au dernier : les traits ne se composent qu'avec le coup
## d'origine, jamais entre eux.
##
## `empowered` est faux pour les mêmes dégâts dérivés, mais PAS toujours en même
## temps que `with_trait`. Le cas qui a forcé la séparation : la Chaîne
## d'éclairs. C'est un sort qui chaîne DÉJÀ, donc son premier maillon ne doit
## pas déclencher en plus le trait de l'élément Foudre — sinon un arc
## supplémentaire part et une créature encaisse deux fois. Mais ce premier
## maillon, lui, doit bien profiter de l'exaltation du joueur. Un seul drapeau
## ne pouvait pas dire les deux.
func _apply_damage(index: int, ability: Ability, context: CombatContext,
		with_trait: bool = true, empowered: bool = true) -> void:
	if not context.enemy_alive(index):
		return
	# L'exaltation ne s'applique qu'au coup D'ORIGINE (`with_trait`), jamais aux
	# dégâts dérivés : sinon +10 s'ajouterait à chaque tic de brûlure, à chaque
	# arc et à chaque écho, et le bonus se multiplierait au lieu de s'ajouter.
	var power := ability.damage + (_empower_bonus if empowered else 0)
	if _marked.has(index):
		power = int(round(float(power) * (1.0 + MARK_BONUS)))
	if _sky_marks.has(index):
		power = int(round(float(power) * (1.0 + SKY_MARK_BONUS)))
	if _skies and ability.element == Element.Kind.SKY and not context.is_structure(index):
		_sky_marks[index] = SKY_MARK_SECONDS
	if _molten_left > 0.0:
		power = int(round(float(power) * MOLTEN_DAMAGE))
	var structure := context.is_structure(index)
	# SURTENSION : chaque coup d'origine de l'Avatar le charge.
	if with_trait and _surge_left > 0.0 and _surge_charges < _surge_max:
		_surge_charges += 1
		surge_changed.emit(_surge_charges)
	if empowered and not structure:
		power = int(round(float(power) * (1.0 + rage_bonus())))
	# LE POIDS DES CHAÎNES : ce qui ne peut plus fuir prend plus cher.
	if _abyss and not structure and _held.has(index):
		power = int(round(float(power) * (1.0 + ABYSS_HELD_BONUS)))
	# L'ÉBLOUISSEMENT : ce qu'il a aveuglé, il le frappe plus fort.
	if _dazzle_left > 0.0 and not structure and is_blinded(index):
		power = int(round(float(power) * (1.0 + DAZZLE_BONUS)))
		dazzle_struck.emit(context.enemy_cells[index])
	if stats.element == Element.Kind.LUCK and empowered and not structure:
		power = _gamble(index, power, ability, with_trait, context)
	if stats.element == Element.Kind.HUNGER and empowered and not structure:
		power = _hunger_bonus(power)
	# LE JUGEMENT DES HEURES : le coup ne porte pas, il s'accumule sur la créature jusqu'à midi.
	if _judgement_left > 0.0 and not structure:
		var total := int(_judgement_bank.get(index, 0)) + power
		_judgement_bank[index] = total
		judgement_stacked.emit(index, total)
		return
	if not structure:
		_blast_hits += 1
	var dealt := context.enemy_health[index].take(
		Damage.new(power, ability.element, "player"))
	enemy_damaged.emit(index, dealt, ability)
	# LE TRAIT SOLAIRE : un coup sur `blind_every` aveugle.
	if with_trait and ability.blind_every > 0 and not structure:
		_glare_count += 1
		if _glare_count % ability.blind_every == 0:
			_blind(index, ability.blind_seconds, context)
	if with_trait and dealt > 0 and ability.kind != Ability.Kind.ZONE \
			and not context.is_structure(index):
		_apply_trait(index, dealt, ability, context)
	if dealt > 0 and not _bond_relaying:
		_relay_bond(index, dealt, ability, context)
	if ability.cuts > 0 and dealt > 0 and context.enemy_alive(index) and not structure:
		_add_cuts(index, ability.cuts)
	if not context.enemy_health[index].is_alive():
		_marked.erase(index)
		_whispers.erase(index)
		_troubled.erase(index)
		_caged.erase(index)
		_cuts.erase(index)
		_shackle_hits.erase(index)
		if _primal and not structure and _is_aflame(index, context):
			_primal_pending.append(context.enemy_cells[index])
		var strings: Dictionary = _possessed.get(index, {})
		if _possessed.erase(index):
			enemy_possessed.emit(index, 0.0)
			if _contagious:
				_jumps_pending.append({"cell": context.enemy_cells[index],
					"left": float(strings["left"]), "strike": strings["strike"]})
		if not _ball.is_empty() and not structure:
			_bursts_pending.append(context.enemy_cells[index])
		if _star_marks.erase(index):
			enemy_star_marks.emit(index, 0)
		if ability.element == Element.Kind.DEATH:
			_gain_soul()
		if ability.element == Element.Kind.STEEL:
			_forge_plate()
		if stats.element == Element.Kind.HUNGER and not structure:
			_gain_bite()
		if _blood_left > 0.0 and not structure:
			_feed_blood(context.enemy_cells[index])
		enemy_killed.emit(index)


func _apply_trait(index: int, dealt: int, ability: Ability, context: CombatContext) -> void:
	match ability.element:
		Element.Kind.FIRE:
			if context.enemy_alive(index):
				var per_tick := maxi(1, int(round(dealt * BURN_RATIO / float(BURN_TICKS))))
				_burning[index] = {"ticks": BURN_TICKS, "timer": BURN_TICK, "damage": per_tick}
				enemy_burning.emit(index, BURN_TICKS * BURN_TICK)
		Element.Kind.WATER:
			if context.enemy_alive(index):
				enemy_soaked.emit(index, SOAK_DURATION, SOAK_FACTOR)
		Element.Kind.EARTH:
			if context.enemy_alive(index) and not _stagger_locks.has(index):
				_stagger_locks[index] = STAGGER_LOCK
				enemy_staggered.emit(index, STAGGER_DURATION)
		Element.Kind.SHADOW:
			if _leech_left <= 0.0:
				var gained := health.heal(LEECH_HEAL)
				if gained > 0:
					_leech_left = LEECH_LOCK
					player_healed.emit(gained)
		Element.Kind.THUNDER:
			_chain_to_neighbour(index, dealt, ability, context)
		Element.Kind.AIR:
			if context.enemy_alive(index):
				_push_away(index, context)
		Element.Kind.POISON:
			_add_venom(index, context)
		Element.Kind.LIGHT:
			_blind(index, GLARE_SECONDS, context)
		Element.Kind.DEATH:
			_sentence(index, ability, context)
		Element.Kind.STARS:
			_add_star_mark(index, ability, context)
		Element.Kind.CHARM:
			if ability == stats.attack or _contagious:
				_add_whisper(index, context)
		Element.Kind.COLDFIRE:
			if ability == stats.attack:
				_add_shackle_hit(index, context)
		Element.Kind.INFERNO:
			if ability == stats.attack and context.enemy_alive(index):
				_ignite_cells([context.enemy_cells[index]], FIRE_CELL_SECONDS)
		Element.Kind.SACRED:
			_add_eye(index, context)
		Element.Kind.STEEL:
			if _molten_left > 0.0 and ability == stats.attack and context.enemy_alive(index):
				_push_away(index, context, MOLTEN_PUSH)
		Element.Kind.TIME:
			if context.enemy_alive(index):
				enemy_soaked.emit(index, RETARD_DURATION, RETARD_FACTOR)
		Element.Kind.SUPREME:
			if context.enemy_alive(index):
				_echoes.append({"index": index, "time_left": ECHO_DELAY,
					"damage": maxi(1, int(round(dealt * ECHO_RATIO))), "ability": ability})
				# L'APOTHÉOSE : un second écho, un temps plus tard.
				if _double_echo_left > 0.0:
					_echoes.append({"index": index, "time_left": ECHO_DELAY * 2.0,
						"damage": maxi(1, int(round(dealt * ECHO_RATIO))), "ability": ability})
			# LA ROUE DES ÉLÉMENTS : le coup porte aussi le trait de l'orbe en tête (ou de celle qu'emportait le tir).
			var turned := _wheel_hit if _wheel_hit >= 0 else (_wheel_rank if _wheel_left > 0.0 else -1)
			if turned >= 0 and context.enemy_alive(index):
				_apply_trait(index, dealt, Ability.make({"id": ability.id + "_roue", "kind": ability.kind,
					"element": rank_element(turned)}), context)


## L'arc de foudre : le coup saute à l'ennemi vivant le plus proche DE LA
## VICTIME — pas du mage. C'est ce qui fait du mage de la Foudre le spécialiste
## des meutes : plus les poursuivants se serrent, plus il rend cher ce
## regroupement.
func _chain_to_neighbour(index: int, dealt: int, ability: Ability,
		context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid,
		[context.enemy_cells[index]] as Array[Vector2i])
	var best := -1
	var best_distance := CHAIN_RANGE + 1
	for i in context.enemy_cells.size():
		if i == index or not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance >= 0 and distance < best_distance:
			best_distance = distance
			best = i
	if best < 0:
		return
	chain_arced.emit(index, best)
	var arc := Ability.make({"id": ability.id + "_arc", "display_name": "Arc",
		"kind": ability.kind, "element": ability.element,
		"damage": maxi(1, int(round(dealt * CHAIN_RATIO)))})
	# Ni trait ni exaltation : c'est un dégât DÉRIVÉ du trait Foudre.
	_apply_damage(best, arc, context, false, false)


## La bourrasque : l'ennemi recule en SUIVANT le gradient de distance au mage —
## il est soufflé le long du couloir, jamais à travers une haie.
## LE GRAND SOUFFLE : tout ce qui entoure le mage part en arrière, et ce qui
## percute une paroi le paie.
##
## La projection réemploie le pas du souffle élémentaire, à ceci près qu'elle
## compte les cases RÉELLEMENT parcourues : une créature coincée contre la
## pierre après une seule case a été plaquée, et c'est là que le sort fait mal.
func _blow_away(ability: Ability, context: CombatContext) -> void:
	var field := Pathfinder.distance_field(grid, [context.player_cell] as Array[Vector2i])
	for index in context.enemy_cells.size():
		if not context.enemy_alive(index) or context.is_structure(index):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[index])
		if distance < 0 or float(distance) > ability.radius:
			continue
		var travelled := _push_away(index, context, ability.blow_cells)
		if travelled >= ability.blow_cells or ability.slam_damage <= 0:
			continue
		# Course écourtée : elle a rencontré un mur. Le choc est un coup
		# DÉRIVÉ — il ne redéclenche ni le trait de l'élément (qui pousserait
		# une seconde fois) ni l'exaltation, déjà comptée sur le souffle.
		var slam := Ability.make({
			"id": ability.id, "kind": Ability.Kind.BLAST,
			"element": ability.element, "damage": ability.slam_damage,
		})
		_apply_damage(index, slam, context, false, false)
		enemy_slammed.emit(index, context.enemy_cells[index])
		if ability.slam_stun > 0.0 and context.enemy_alive(index) and not context.bosses.has(index):
			enemy_staggered.emit(index, ability.slam_stun)


## `field` : le champ de distance d'où l'on pousse. Vide, c'est celui de l'IA, autour du mage.
func _push_away(index: int, context: CombatContext, cells: int = PUSH_CELLS,
		field: PackedInt32Array = PackedInt32Array()) -> int:
	var from := context.player_field if field.is_empty() else field
	var cell: Vector2i = context.enemy_cells[index]
	var travelled := 0
	for _step in cells:
		var best := cell
		var here := Pathfinder.value_at(grid, from, cell)
		for direction in MazeGrid.NEIGHBORS:
			var next: Vector2i = cell + direction
			if not grid.is_floor_v(next) or grid.is_occupied(next):
				continue
			var value := Pathfinder.value_at(grid, from, next)
			if value > here:
				here = value
				best = next
		if best == cell:
			break
		cell = best
		travelled += 1
	if cell == context.enemy_cells[index]:
		return 0
	context.enemy_cells[index] = cell
	enemy_pushed.emit(index, cell)
	return travelled



## L'ombre INSPIRE : elle ramène à elle ce qu'elle attrape.
##
## Miroir exact de `_push_away`, et c'est voulu — l'Air écarte, l'Ombre ramène.
## Deux éléments qui déplaceraient dans le même sens ne se distingueraient plus
## l'un de l'autre.
##
## ⚠️ Le champ est recalculé depuis `player_cell` et NON pris dans
## `context.player_field`, qui est celui de l'IA et date de 300 ms. Sur un
## déplacement d'ennemi, un tiers de seconde de retard ramène vers l'endroit où
## le mage ÉTAIT — le même piège qui avait faussé l'arrêt au corps à corps. Le
## cache d'une frame fait que ça ne coûte qu'un BFS par lancer.
func _haul_in(ability: Ability, context: CombatContext) -> void:
	var field := _field_from(context.player_cell)
	for i in context.enemy_cells.size():
		# Les REPAIRES ne bougent pas : une maison qu'on tire à soi n'a pas de
		# sens, et la déplacer sortirait le décor de sa case.
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var reach := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if reach < 0 or float(reach) > ability.pull_radius:
			continue
		var cell: Vector2i = context.enemy_cells[i]
		for _step in ability.pull_cells:
			var here := Pathfinder.value_at(grid, field, cell)
			# ON S'ARRÊTE SUR L'ANNEAU, pas au contact. `pull_min` vaut au moins
			# 1 — jamais sur la case du mage, deux sprites superposés et l'on ne
			# voit plus ni qui frappe ni où l'on est — mais un sort qui
			# rassemble a intérêt à s'arrêter plus loin encore : déposé au
			# contact, le poursuivant frappe dans la seconde.
			if here <= maxi(1, ability.pull_min):
				break
			var best := cell
			for direction in MazeGrid.NEIGHBORS:
				var next: Vector2i = cell + direction
				if not grid.is_floor_v(next) or grid.is_occupied(next):
					continue
				var value := Pathfinder.value_at(grid, field, next)
				if value >= 0 and value < here:
					here = value
					best = next
			if best == cell:
				break
			cell = best
		if cell != context.enemy_cells[i]:
			context.enemy_cells[i] = cell
			enemy_hauled.emit(i, cell)


func _update_burns(delta: float, context: CombatContext) -> void:
	for index in _burning.keys():
		if not context.enemy_alive(index):
			_burning.erase(index)
			continue
		var burn: Dictionary = _burning[index]
		burn["timer"] = float(burn["timer"]) - delta
		if float(burn["timer"]) > 0.0:
			continue
		burn["timer"] = BURN_TICK
		burn["ticks"] = int(burn["ticks"]) - 1
		var tick := Ability.make({"id": "burn", "display_name": "Brûlure",
			"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.FIRE,
			"damage": int(burn["damage"])})
		# Ni trait ni exaltation : un tic de brûlure n'est pas un coup porté.
		_apply_damage(index, tick, context, false, false)
		if int(burn["ticks"]) <= 0:
			_burning.erase(index)



## LE POISON RONGE LOIN DE SA SOURCE.
##
## Calqué sur la brûlure, à trois différences près, et ce sont elles qui en font
## un autre effet : il dure dix fois plus longtemps, il ne dépend pas du coup qui
## l'a posé, et il SUIT sa victime — une créature qui sort de l'ombre l'emporte
## avec elle. C'est ce qui distingue « ne reste pas là » de « tu y es passé ».
##
## Se reposer le RENOUVELLE plutôt que de s'ajouter : deux flaques d'ombre qui
## se chevaucheraient doubleraient la cadence en silence, comme deux nuages
## d'orage l'avaient déjà fait.
func _update_poisons(delta: float, context: CombatContext) -> void:
	for index in _poisoned.keys():
		if not context.enemy_alive(index):
			_poisoned.erase(index)
			continue
		var poison: Dictionary = _poisoned[index]
		poison["time_left"] = float(poison["time_left"]) - delta
		poison["timer"] = float(poison["timer"]) - delta
		if float(poison["timer"]) <= 0.0:
			poison["timer"] = POISON_TICK
			var tick := Ability.make({"id": "poison", "display_name": "Poison d'ombre",
				"kind": Ability.Kind.PROJECTILE, "element": Element.Kind.SHADOW,
				"damage": int(poison["damage"])})
			# NI TRAIT NI EXALTATION. Le trait de l'Ombre est la Ponction : un
			# poison qui le déclencherait soignerait le mage une fois par seconde
			# et par créature empoisonnée, sans qu'il ait rien à faire.
			_apply_damage(index, tick, context, false, false)
		if float(poison["time_left"]) <= 0.0:
			_poisoned.erase(index)


## L'ombre empoisonne CE QU'ELLE TOUCHE, une fois par passage.
##
## Même verrou que le givre et le piège : une zone tique deux fois par seconde,
## et sans verrou elle repose le poison à chaque tic — la durée annoncée ne
## voudrait plus rien dire.
func _apply_poison(ability: Ability, centre: Vector2i, context: CombatContext) -> void:
	var field := _field_from(centre)
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i) or _snare_locks.has(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		_snare_locks[i] = POISON_TICK
		_poisoned[i] = {"time_left": ability.poison_duration,
			"timer": POISON_TICK, "damage": maxi(1, ability.poison_damage)}
		enemy_poisoned.emit(i, ability.poison_duration)


## L'OMBRE QUE L'EXPLOSION LAISSE DERRIÈRE ELLE.
##
## Une zone dérivée, fabriquée comme les pics de la ligne de terre : le sort
## d'origine n'a pas à être une zone, il lui suffit d'en décrire une. Elle ne
## reprend PAS les dégâts de l'explosion — une flaque qui referait 34 par seconde
## serait le vrai sort, et l'explosion son décor.
func _residue_of(ability: Ability) -> Ability:
	return Ability.make({
		"id": ability.id + "_ombre", "display_name": ability.display_name,
		"kind": Ability.Kind.ZONE, "element": ability.element,
		"damage": 0, "radius": ability.radius,
		"duration": ability.residue_duration,
		"poison_duration": ability.poison_duration,
		"poison_damage": ability.poison_damage,
		"zone_style": "ombre",
	})


func _update_echoes(delta: float, context: CombatContext) -> void:
	for i in range(_echoes.size() - 1, -1, -1):
		_echoes[i]["time_left"] = float(_echoes[i]["time_left"]) - delta
		if float(_echoes[i]["time_left"]) > 0.0:
			continue
		var echo: Dictionary = _echoes[i]
		_echoes.remove_at(i)
		var source: Ability = echo["ability"]
		var index := int(echo["index"])
		# Une entrée « burn » n'est pas un écho : c'est la brûlure différée d'un
		# piège de zone, qui s'allume au moment où la créature est libérée.
		var burn_time := float(echo.get("burn", 0.0))
		if burn_time > 0.0:
			if context.enemy_alive(index):
				var ticks := maxi(1, int(round(burn_time / BURN_TICK)))
				var per_tick := maxi(1, int(round(source.damage * BURN_RATIO)))
				_burning[index] = {"ticks": ticks, "timer": BURN_TICK, "damage": per_tick}
				enemy_burning.emit(index, burn_time)
			continue
		var repeat := Ability.make({"id": source.id + "_echo", "display_name": "Écho",
			"kind": source.kind, "element": Element.Kind.SUPREME,
			"damage": int(echo["damage"])})
		# Ni trait ni exaltation : l'écho répète un coup, il n'en est pas un.
		_apply_damage(index, repeat, context, false, false)


## Explosions et zones : le rayon se mesure en DISTANCE DE CHEMIN, pas à vol
## d'oiseau. Une explosion qui traverse une haie pour toucher le couloir d'à côté
## serait incompréhensible dans un labyrinthe.
## `with_trait` à false quand le sort FAIT DÉJÀ ce que fait le trait de son
## élément. Le cas est né avec le Grand souffle : il projette de quatre cases,
## et le trait de l'Air en poussait deux de plus par-dessus. Les deux se
## cumulaient, donc la course réelle dépassait celle du sort et le choc contre
## la pierre se comptait de travers. Même raison que la Chaîne d'éclairs, qui ne
## déclenche pas l'arc de la Foudre.
func _apply_area(ability: Ability, centre: Vector2i, context: CombatContext,
		reported: Ability = null, with_trait: bool = true,
		empowered: bool = true) -> void:
	# UN ULTIME PASSE LES MURS. Ailleurs le rayon se mesure en distance de
	# chemin — une explosion ne doit pas traverser une haie. Ici on mesure à vol
	# d'oiseau : le souffle balaye le labyrinthe sans se soucier des couloirs.
	if ability.pierces_walls:
		for i in context.enemy_cells.size():
			if not context.enemy_alive(i):
				continue
			if Vector2(context.enemy_cells[i] - centre).length() > ability.radius:
				continue
			_apply_damage(i, ability, context, with_trait, empowered)
			if reported != null and context.enemy_alive(i):
				enemy_damaged.emit(i, 0, reported)
		return

	var field := Pathfinder.distance_field(grid, [centre] as Array[Vector2i])
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i):
			continue
		var distance := Pathfinder.value_at(grid, field, context.enemy_cells[i])
		if distance < 0 or float(distance) > ability.radius:
			continue
		if not _within_arc(ability, centre, context.enemy_cells[i], context):
			continue
		_apply_damage(i, ability, context, with_trait, empowered)
		if reported != null and context.enemy_alive(i):
			# La zone rapporte la compétence D'ORIGINE et non sa tranche : c'est
			# elle que l'interface et les effets doivent nommer.
			enemy_damaged.emit(i, 0, reported)


## La cible est-elle dans l'OUVERTURE du souffle ?
##
## Mesuré à vol d'oiseau depuis le lanceur, et non le long du couloir : une
## vague balaie ce qui est DEVANT, et le joueur juge « devant » à ce qu'il voit,
## pas à la topologie du labyrinthe.
func _within_arc(ability: Ability, centre: Vector2i, target: Vector2i,
		context: CombatContext) -> bool:
	if ability.arc <= 0.0 or ability.arc >= 360.0:
		return true
	var facing := Vector2(context.player_facing)
	if facing.length() < 0.01 or target == centre:
		return true
	var to_target := Vector2(target - centre)
	return absf(rad_to_deg(facing.angle_to(to_target))) <= ability.arc * 0.5


## Chemin case par case d'un projectile, du joueur à la cible : un BFS depuis la
## CIBLE puis une descente du gradient — le même mécanisme que la poursuite des
## ennemis, réutilisé tel quel.
func trajectory(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = [from]
	if from == to:
		return path
	var field := Pathfinder.distance_field(grid, [to] as Array[Vector2i])
	var current := from
	for _step in grid.cols * grid.rows:
		var direction := Pathfinder.step_toward(grid, field, current)
		if direction == Vector2i.ZERO:
			break
		current += direction
		path.append(current)
		if current == to:
			break
	return path


## Changer de forme ne reconstruit ni la santé, ni les projectiles, ni les recharges.
func change_form(next: CharacterStats) -> void:
	stats = next

func _cast_prism_move(ability: Ability, context: CombatContext) -> bool:
	if player_rooted():
		return false
	var target := -1
	var best := float(ability.range) + 1.0
	for i in context.enemy_cells.size():
		if not context.enemy_alive(i) or context.is_structure(i):
			continue
		var distance := Vector2(context.player_cell).distance_to(Vector2(context.enemy_cells[i]))
		if distance <= ability.range and distance < best:
			target = i
			best = distance
	if target < 0:
		use_refused.emit("cible")
		return false
	var prey := context.enemy_cells[target]
	var toward := prey - context.player_cell
	var approach := Vector2i(signi(toward.x), 0) if absi(toward.x) > absi(toward.y) else Vector2i(0, signi(toward.y))
	var facing := -approach
	if target < context.enemy_facings.size() and context.enemy_facings[target] != Vector2i.ZERO:
		facing = context.enemy_facings[target]
	var destination := prey - facing
	if ability.kind == Ability.Kind.COMET:
		destination = prey
	if not grid.is_floor_v(destination) or grid.is_occupied(destination):
		use_refused.emit("place")
		return false
	var from := context.player_cell
	context.player_cell = destination
	if ability.kind == Ability.Kind.COMET:
		comet_performed.emit(from, destination)
		_cast_blast(ability, context)
	else:
		blink_performed.emit(from, destination)
	return true


func grant_immunity(seconds: float) -> void:
	health.immune = true
	_immune_left = maxf(_immune_left, seconds)
	player_made_immune.emit(seconds)
