class_name Enemy
extends Actor

## Poursuivant. Ne contient aucune logique de décision : il branche un EnemyAI
## sur le GridMover hérité d'Actor. Le mage et l'ennemi partagent donc exactement
## le même code de déplacement et de collision — ce qui a déjà été prouvé correct
## par tests/test_grid_mover.gd.
##
## Il porte en revanche ses POINTS DE VIE et sa barre. Le calcul des dégâts, lui,
## reste dans CombatSystem : l'ennemi ne fait qu'encaisser et le montrer.
##
## Les deux ennemis ont leur planche d'animation dessinée, au MÊME format que les
## mages — des bandes de six poses IDLE / WALK 1-4 / ATTACK décrites par un
## frames.json — et `Enemy` les joue exactement comme `Player` joue les siennes.
##
## Une différence tout de même : le gobelin est dessiné dans les quatre
## orientations, le spectre dans une seule. C'est cohérent avec ce qu'il est —
## il LÉVITE, face au joueur, il n'a ni dos ni profil. Sa planche ne déclare donc
## que « down », et la même bande sert aux quatre directions.

const ENEMIES_PATH := "res://assets/enemies/"

## Le rythme d'animation vient du BESTIAIRE : onze créatures ne peuvent pas
## partager une cadence. Le gobelin MARCHE — 8 poses/s, le pas colle au sol ; le
## spectre LÉVITE — à la même cadence il ne flotte pas, il grelotte, et son coup,
## une orbe chargée à bout de bras, demande le temps qu'on le voie venir.
## `repos` est le temps mort APRÈS un coup : sans lui, un ennemi collé au mage
## relance son geste à la frame près et l'animation devient un battement continu.

## L'état de l'IA se lit à la teinte : en poursuite l'ennemi s'éclaire et vire
## au rouge, en patrouille il s'éteint. Le joueur doit pouvoir dire d'un coup
## d'œil s'il a été repéré — sans cette information, la fuite devient du hasard.
const TINT_PATROL := Color(0.70, 0.74, 0.86)
const TINT_SEARCH := Color(1.0, 0.96, 0.92)
const TINT_CHASE := Color(1.35, 0.88, 0.84)
## Éclair blanc au moment du coup. Court : au-delà de 0,15 s il devient un
## clignotement permanent quand les coups s'enchaînent.
const HIT_FLASH := Color(2.4, 2.2, 2.2)
const HIT_FLASH_DURATION := 0.14

## Teintes des statuts élémentaires. Un statut doit se LIRE sur la créature :
## un ennemi trempé qui ralentit sans virer au bleu semblerait bugué, pas gêné.
const TINT_SOAK := Color(0.55, 0.75, 1.45)
const TINT_STAGGER := Color(1.5, 1.4, 1.0)
const TINT_FROZEN := Color(0.6, 1.3, 1.25)
const TINT_VENOM := Color(0.72, 1.42, 0.32)
const VENOM_DROP := Color("#b4f02a")
const VENOM_RIM := Color("#1e3a0c")
const VENOM_SHINE := Color("#f2ff9e")
const TINT_BLIND := Color(1.5, 1.45, 1.25)
const TINT_POSSESSED := Color(1.45, 0.75, 1.15)
const BLIND_STAR := Color("#ffcf5a")
const ASTRE_STAR := Color("#ffffff")
const ASTRE_RIM := Color("#0a1030")
const MARK_BELL := Color("#e6dfca")
const MARK_RIM := Color("#7a1414")
const BLIND_RIM := Color("#4a2f12")
const TINT_BURN := Color(1.6, 0.85, 0.55)
## Le poison d'ombre : SOMBRE et violacé, là où les autres statuts éclaircissent.
## Une créature empoisonnée doit avoir l'air éteinte, pas illuminée — et une
## teinte claire aurait été confondue avec la trempe sur un stage bleu.
const TINT_POISON := Color(0.62, 0.42, 0.82)
## Ralentissement d'un ennemi trempé — la MÊME valeur que CombatSystem.SOAK_FACTOR.
const SOAK_FACTOR := 0.62
## Coup porté au joueur : l'ennemi se jette en avant. Sans ce mouvement, un
## poursuivant arrêté à portée pendant le répit d'invulnérabilité a l'air figé —
## on croit à un bug alors qu'il frappe dans le vide. L'élan reste COURT : l'IA
## s'arrête à une case, un élan plus long lui ferait retraverser le mage et
## annulerait tout le bénéfice de cet arrêt.
## Cadence de marche maximale, en images par seconde. Voir `_update_desired`.
##
## VINGT-QUATRE, et non dix-huit. Le plafond a été relevé une fois que les
## planches ont eu de vraies foulées : à dix-huit, il BRIDAIT le gobelin, dont
## la marche redessinée demande 22 img/s pour que le pied colle au sol. Le
## dessin était bon et c'est le plafond qui faisait glisser — exactement
## l'inverse du diagnostic de départ.
##
## Vingt-quatre est aussi la cadence classique d'une animation dessinée : au-delà
## l'œil décroche et lit un grésillement, en deçà on voit les images. Les bêtes
## dont la planche demande plus — le minotaure en réclame 65 — restent bridées,
## et leur glissement se corrigera au dessin, pas ici.
const MAX_WALK_FPS := 24.0
const STRIKE_LUNGE := 0.18
## Flottement des créatures qui lévitent, en pixels du monde.
const HOVER_SPEED := 3.4
const HOVER_DEPTH := 2.0
const TINT_STRIKE := Color(1.9, 0.72, 0.62)
## Part de la teinte réellement appliquée. Ces couleurs ont été calibrées sur les
## anciennes poses uniques, sombres et désaturées. À pleine force sur les planches
## dessinées — gobelin vert vif, spectre violet — elles les repeignent : le
## gobelin en poursuite virait au rouge franc, on ne lisait plus un gobelin mais
## un démon. À 0,45 l'état reste parfaitement visible et le dessin survit.
const TINT_STRENGTH := 0.45

## Barre de vie, en fraction de case.
const BAR_WIDTH := 1.05
const BAR_HEIGHT := 0.13
const BAR_HEIGHT_ABOVE := 1.15

var ai: EnemyAI = null
## Renseigné par le Level à chaque recalcul d'IA (toutes les 300 ms).
var player_field := PackedInt32Array()
## Case du mage, elle renseignée à CHAQUE frame. Le champ de distances, vieux de
## 300 ms au pire, suffit pour choisir un chemin ; il ne suffit pas pour décider
## de s'arrêter net devant quelqu'un qui bouge.
var player_cell := Vector2i(-1, -1)
## Vers quelles gemmes courir, pour le Rat. Renseigné comme `player_field`.
var gem_field := PackedInt32Array()
## La gemme que porte le Rat.
var stolen: Gem = null
var health: Health = null
## Espèce, telle que la nomme le bestiaire.
var species := Bestiary.FALLBACK
## Tué : hors-jeu jusqu'à ce que la vague suivante le ramène. Le Level tient le
## chronomètre ; l'ennemi ne fait qu'obéir.
var dead := false

var _flash := 0.0
var _strike := 0.0
## Vers où part le coup, fixé au moment où il part. Un poursuivant arrêté à une
## case n'a plus de direction, et un tireur regarde rarement sa cible.
var _strike_facing := Vector2i.DOWN
var _strike_rest := 0.0
var _spit_cooldown := 0.0
var _marked_left := 0.0
var _astre_marks := 0
## La démarche d'un boss, posée par le Level à chaque image (`BossGait`).
var gait_factor := 1.0
var gait_hold := false
var gait_charge := Vector2i.ZERO
## Le geste d'un boss qui attaque de loin : il remplace le dessin et l'immobilise.
var _cast_strip: BossStrip = null
## Cadences de la planche jouée (voir SHEET_TUNING).
var _tuning: Dictionary = Bestiary.of(Bestiary.FALLBACK)

var _textures := {}
var _cell := Vector2(149.0, 112.0)
var _feet_y := 110.0
var _poses: Array = ["idle", "walk_1", "walk_2", "walk_3", "walk_4", "attack"]
## Dernière direction non nulle : l'ennemi garde sa pose quand il s'arrête.
var _facing: Vector2i = Vector2i.DOWN
var _walk_phase := 0.0
## Poses rangées par rôle, remplies au chargement par `_index_poses`.
var _walk_poses: Array[int] = []
var _attack_poses: Array[int] = []
var _idle_pose := 0
## Course du pied sur un cycle, en part de la hauteur — mesurée sur la planche
## par `tools/build_enemies.py`. Zéro pour les planches qui ne la portent pas.
var _foot_travel := 0.0
## Hauteur du corps dans la case, mesurée sur la planche.
var _body_height := 0.0
var _base_speed := 0.0
var _soak_left := 0.0
var _soak_factor := SOAK_FACTOR
var _stagger_left := 0.0
var _frozen_left := 0.0
var _venom_doses := 0
var _venom_left := 0.0
var _burn_left := 0.0
## Temps d'empoisonnement restant. Il dure DIX FOIS plus qu'une brûlure : sa
## teinte doit donc être discrète, sinon un stage entier vire au violet.
var _poison_left := 0.0


func setup_enemy(grid: MazeGrid, start_cell: Vector2i, speed: float, p_tile_size: int,
		detection_radius: int, p_species: String, max_health: int, rng_seed: int = 0) -> void:
	species = p_species if Bestiary.has(p_species) else Bestiary.FALLBACK
	_tuning = Bestiary.of(species)
	_load_sheet(Bestiary.sheet(species))
	# La stature vient de l'espèce : un golem doit dominer un serpent, sinon le
	# bestiaire ne se lit qu'aux couleurs. Les valeurs restent proches de celle
	# du mage (53 px) — une créature deux fois plus haute masquerait le couloir
	# devant elle, et le joueur ne verrait plus où il court.
	target_height = float(_tuning["height"])
	# Le CORPS garde sa taille à l'écran. Une case recalée change de remplissage, et
	# `height` donne la hauteur de la CASE : seule, elle ferait changer la créature.
	if _body_height > 0.0 and _tuning.has("body"):
		target_height = float(_tuning["body"]) * _cell.y / _body_height
	# Les planches sont calées sur les pieds — sur l'anneau de lumière pour le
	# spectre, qui lévite : l'ombre de contact se pose donc à l'origine du nœud.
	shadow_offset = 0.02
	shadow_radius = 0.26
	setup(grid, start_cell, speed, p_tile_size)
	_base_speed = speed
	mover.phases = phases()
	ai = EnemyAI.new(detection_radius, rng_seed)
	health = Health.new(max_health)


## Retour visuel d'un coup encaissé. Les points de vie ont déjà été retirés par
## le CombatSystem — ici on ne fait que le montrer.
func flash_hit() -> void:
	_flash = HIT_FLASH_DURATION
	queue_redraw()


## Ce monstre jette-t-il de loin, et à quelle portée ? 0 = il frappe au contact.
func throw_range() -> int:
	return int(_tuning.get("throw_range", 0))


## Le temps entre deux tirs — `ThrowSystem` s'en sert pour recharger ses tireurs.
func strike_cycle() -> float:
	return ThrowSystem.reload_of(_tuning)


## Tire-t-il des flèches, plutôt que des boules ?
func fires_arrows() -> bool:
	return bool(_tuning.get("arrow", false))


## Ne frappe-t-il QUE de loin ? Il s'arrête alors dès qu'il a sa ligne de tir, et
## son contact ne coûte rien.
func ranged_only() -> bool:
	return bool(_tuning.get("ranged_only", false))


## Sa frappe lointaine BALAIE-t-elle le couloir, au lieu de viser une case ?
func sweeps() -> bool:
	return bool(_tuning.get("sweep", false))


## Vole-t-il des gemmes ?
func is_thief() -> bool:
	return bool(_tuning.get("thief", false))


## Ne frappe-t-il jamais au contact, sans tirer pour autant ?
func harmless() -> bool:
	return bool(_tuning.get("harmless", false))


func phases() -> bool:
	return bool(_tuning.get("phases", false))


func is_boss() -> bool:
	return bool(_tuning.get("boss", false))


func is_casting() -> bool:
	return _cast_strip != null


## Joue le geste de loin d'un boss, de face. Il ne bouge pas tant que dure sa zone : on
## voit qui lance, et il reste une cible pour celui qui ne fuit pas.
func play_cast(strip: Texture2D, duration: float, strip_scale: float, strip_offset: Vector2) -> void:
	_end_cast()
	_cast_strip = BossStrip.new()
	_cast_strip.scale = Vector2.ONE * strip_scale
	_cast_strip.offset = strip_offset
	add_child(_cast_strip)
	_cast_strip.play(strip, duration)
	_cast_strip.finished.connect(_end_cast, CONNECT_ONE_SHOT)
	sprite.visible = false
	mover.desired_direction = Vector2i.ZERO


func _end_cast() -> void:
	if _cast_strip != null:
		_cast_strip.queue_free()
		_cast_strip = null
	sprite.visible = true


func uses_portals() -> bool:
	return not bool(_tuning.get("no_portals", false))


func spit_reach() -> int:
	return int(_tuning.get("spit_reach", 0))


func can_spit() -> bool:
	return spit_reach() > 0 and can_strike() and _spit_cooldown <= 0.0


## Le geste de la Vesse. Le nuage, lui, tombe dans `SporeClouds` au bout de l'armement.
func spit() -> void:
	strike()
	_spit_cooldown = float(_tuning["spit_reload"])


## Peut-il frapper MAINTENANT ? Le Level le demande avant de chercher une ligne
## de tir : inutile de calculer une visée pendant le repos qui suit un coup.
func can_strike() -> bool:
	return _strike <= 0.0 and _strike_rest <= 0.0


## Frappe le joueur. Ne retire AUCUN point de vie : c'est le Level qui constate
## le contact et le GameManager qui décide ce que ça coûte. Ici, on le montre.
func strike() -> void:
	if _strike <= 0.0 and _strike_rest <= 0.0:
		_strike = float(_tuning["strike"])
		_strike_rest = _strike + float(_tuning["repos"])
		_strike_facing = _toward_player()
	queue_redraw()


## La direction cardinale qui regarde le mage, sur l'axe où il est le plus loin.
func _toward_player() -> Vector2i:
	var gap := player_cell - mover.nearest_cell()
	if player_cell.x < 0 or gap == Vector2i.ZERO:
		return _facing
	if absi(gap.x) >= absi(gap.y):
		return Vector2i(signi(gap.x), 0)
	return Vector2i(0, signi(gap.y))


## La pose de coup est-elle à l'écran ? La FRAPPE se joue jusqu'au bout. Le REPOS,
## lui, cède la place à la marche si la créature repart : sinon elle glisse sur le
## sol, bras levé, jusqu'à la fin de son geste.
func _showing_strike() -> bool:
	if _strike_rest <= 0.0 or _attack_poses.is_empty():
		return false
	return _strike > 0.0 or mover == null or not mover.is_moving()


## Statuts élémentaires, appliqués par le Level sur signal du CombatSystem.
## Le ralentissement le plus FORT gagne : un ennemi déjà trempé qui entre dans
## un cercle glacé doit ralentir davantage, pas voir son givre écrasé par la
## trempe qui traînait.
func soak(duration: float, factor: float = SOAK_FACTOR) -> void:
	if duration >= _soak_left or factor < _soak_factor:
		_soak_factor = minf(_soak_factor, factor) if _soak_left > 0.0 else factor
	_soak_left = maxf(_soak_left, duration)


func is_staggered() -> bool:
	return _stagger_left > 0.0


func stagger(duration: float) -> void:
	_stagger_left = maxf(_stagger_left, duration)
	# L'arrêt est IMMÉDIAT, pas au prochain choix de case : un ébranlement qui
	# laisse finir le pas en cours arrive une demi-case trop tard.
	mover.desired_direction = Vector2i.ZERO


## Figé par l'Arrêt du temps : la teinte dit que ce n'est pas un simple ébranlement.
func time_freeze(duration: float) -> void:
	_frozen_left = maxf(_frozen_left, duration)


## Il erre sans chercher le mage, et le Level ne le laisse plus frapper.
func blind(duration: float) -> void:
	if ai != null:
		ai.blind_left = maxf(ai.blind_left, duration)
	flash_hit()
	queue_redraw()


## Les étoiles du trait de l'Ange des Étoiles : elles tournent autour de lui jusqu'à l'explosion.
func set_star_marks(count: int) -> void:
	_astre_marks = count
	queue_redraw()


## La marque du Glas : une petite cloche au-dessus de lui, tant qu'il prend plus de dégâts.
func mark(duration: float) -> void:
	_marked_left = maxf(_marked_left, duration)
	queue_redraw()


## Retourné par la Démone. Zéro le libère : un mort ne doit pas revenir possédé.
func possess(duration: float) -> void:
	if ai != null:
		ai.possess(duration)
		if duration <= 0.0:
			ai.possess_field = PackedInt32Array()
	if duration > 0.0:
		flash_hit()


func is_blinded() -> bool:
	return ai != null and ai.blind_left > 0.0


## Les doses de venin : on doit les lire d'un coup d'œil, sans chiffre.
func set_venom(doses: int, duration: float) -> void:
	_venom_doses = doses
	_venom_left = duration
	queue_redraw()


func burn_glow(duration: float) -> void:
	_burn_left = maxf(_burn_left, duration)


func poison_glow(duration: float) -> void:
	_poison_left = maxf(_poison_left, duration)


func _update_desired(delta: float) -> void:
	if ai == null:
		return
	_strike = maxf(0.0, _strike - delta)
	_strike_rest = maxf(0.0, _strike_rest - delta)
	_spit_cooldown = maxf(0.0, _spit_cooldown - delta)
	if _astre_marks > 0:
		queue_redraw()
	if _marked_left > 0.0:
		_marked_left = maxf(0.0, _marked_left - delta)
		queue_redraw()
	_soak_left = maxf(0.0, _soak_left - delta)
	_stagger_left = maxf(0.0, _stagger_left - delta)
	_frozen_left = maxf(0.0, _frozen_left - delta)
	if _venom_doses > 0:
		_venom_left -= delta
		if _venom_left <= 0.0:
			_venom_doses = 0
		queue_redraw()
	_burn_left = maxf(0.0, _burn_left - delta)
	_poison_left = maxf(0.0, _poison_left - delta)
	_flash = maxf(0.0, _flash - delta)
	mover.speed = _base_speed * gait_factor * (_soak_factor if _soak_left > 0.0 else 1.0)
	if _soak_left <= 0.0:
		_soak_factor = SOAK_FACTOR
	if _stagger_left > 0.0:
		mover.desired_direction = Vector2i.ZERO
		# L'éclair passe aussi sur une créature ébranlée. Tous les coups du mage de
		# la Terre ébranlent : sans ça, aucun n'aurait d'éclair.
		if _flash > 0.0:
			set_tint(HIT_FLASH)
		else:
			_show_state(TINT_FROZEN if _frozen_left > 0.0 else TINT_STAGGER)
		return
	if _cast_strip != null:
		mover.desired_direction = Vector2i.ZERO
		return
	if gait_charge != Vector2i.ZERO or gait_hold:
		mover.desired_direction = gait_charge
		return
	var step := _next_step(delta)
	# Le DERNIER pas est refusé : celui qui ferait monter l'ennemi sur la case du
	# mage. Deux sprites superposés, on ne voit plus ni qui frappe ni où l'on est
	# — alors qu'un poursuivant arrêté à une case, arme levée, raconte la même
	# menace en lisible. Le refus se fait ici et non dans EnemyAI parce qu'il
	# demande la position du mage À LA FRAME PRÈS : avec le champ de distances,
	# vieux de 300 ms, l'ennemi restait plané un tiers de seconde après le départ
	# du mage — et ce tiers de seconde suffit à ne plus jamais le rattraper.
	if step != Vector2i.ZERO and mover.decision_cell() + step == player_cell:
		step = Vector2i.ZERO
	# Le tireur pur s'arrête dès qu'il a sa ligne.
	if ranged_only() and ThrowSystem.in_line(
			mover.grid, mover.decision_cell(), player_cell, throw_range()):
		step = Vector2i.ZERO
	# Le larcin et le crachat se font à l'arrêt. La Vesse reste aussi à distance de crachat.
	if (is_thief() or spit_reach() > 0) and _strike > 0.0:
		step = Vector2i.ZERO
	if spit_reach() > 0 and CreatureRules.in_spit_reach(
			mover.grid, player_field, mover.decision_cell(), spit_reach()):
		step = Vector2i.ZERO
	mover.desired_direction = step

	# L'éclair n'est PAS atténué : TINT_STRENGTH protège le dessin d'une teinte qui
	# dure, alors que celle-ci ne tient que 0,14 s et doit se voir d'un coup.
	if _flash > 0.0:
		set_tint(HIT_FLASH)
		return
	if _strike > 0.0:
		_show_state(TINT_STRIKE)
		return
	# Brûlure et trempe passent AVANT les teintes d'état : un statut est une
	# information de combat, l'état de l'IA n'est qu'une ambiance.
	if ai.possess_left > 0.0:
		_show_state(TINT_POSSESSED)
		return
	if is_blinded():
		_show_state(TINT_BLIND)
		queue_redraw()
		return
	# LE VENIN VERDIT À CHAQUE DOSE, en pulsant lentement. Il passe devant les autres :
	# c'est toute la lecture du Mage de la Peste.
	if _venom_doses > 0:
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.005)
		_show_state(TINT_CHASE.lerp(TINT_VENOM, (float(_venom_doses) - pulse * 0.4) / 3.0))
		return
	if _burn_left > 0.0:
		var flicker := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.02)
		_show_state(TINT_BURN.lerp(HIT_FLASH, 0.25 * flicker))
		return
	if _soak_left > 0.0:
		_show_state(TINT_SOAK)
		return
	# LE POISON VIENT APRÈS LA TREMPE, et non avant comme la brûlure. Il dure
	# quinze secondes : passer devant les autres statuts reviendrait à masquer,
	# tout ce temps-là, ce que la créature est en train de subir d'autre.
	if _poison_left > 0.0:
		var seep := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.004)
		_show_state(TINT_POISON.lerp(TINT_CHASE, 0.30 * seep))
		return
	match ai.state:
		EnemyAI.State.CHASE:
			_show_state(TINT_CHASE)
		EnemyAI.State.SEARCH:
			_show_state(TINT_SEARCH)
		_:
			_show_state(TINT_PATROL)


func _next_step(delta: float) -> Vector2i:
	var from := mover.decision_cell()
	if is_thief():
		return ai.decide_thief(mover.grid, from, mover.direction, gem_field, player_field,
			stolen != null, delta)
	if phases():
		return ai.decide_phasing(mover.grid, from, mover.direction, player_field, player_cell,
			float(_tuning["phase_reach"]), delta)
	return ai.decide(mover.grid, from, mover.direction, player_field, delta)


## Teinte d'état, atténuée (voir TINT_STRENGTH).
func _show_state(color: Color) -> void:
	set_tint(Color.WHITE.lerp(color, TINT_STRENGTH))


## Tué. On ne LIBÈRE pas le nœud : la vague suivante le réutilise tel quel, ce
## qui évite de recréer un ennemi et de reconnecter son IA toutes les dix
## secondes — et garde l'index stable, sur lequel repose tout le ciblage.
func set_dead(value: bool) -> void:
	dead = value
	visible = not value
	set_process(not value)
	if value:
		_end_cast()
		# La direction demandée est effacée : sans ça, l'ennemi repartirait à sa
		# réapparition dans le sens où il courait au moment de sa mort.
		mover.desired_direction = Vector2i.ZERO


## Réapparition, ailleurs sur la carte, PV pleins. L'IA repart en patrouille :
## elle vient de perdre le joueur de vue, elle ne peut pas savoir où il est passé.
func revive_at(cell: Vector2i) -> void:
	mover.teleport_to(cell)
	snap_to_mover()
	if ai != null:
		ai.state = EnemyAI.State.PATROL
	if health != null:
		health.current = health.maximum
		health.shield = 0
	_flash = 0.0
	_strike = 0.0
	_strike_rest = 0.0
	_spit_cooldown = 0.0
	_soak_left = 0.0
	_stagger_left = 0.0
	_burn_left = 0.0
	_poison_left = 0.0
	_venom_doses = 0
	if _base_speed > 0.0:
		mover.speed = _base_speed
	set_dead(false)


func _load_sheet(sheet_id: String) -> void:
	var folder := ENEMIES_PATH + sheet_id + "/"
	var text := FileAccess.get_file_as_string(folder + "frames.json")
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		push_error("Descripteur d'animation introuvable pour « %s »" % sheet_id)
		return
	var data: Dictionary = parsed
	var cell: Array = data["cell"]
	_cell = Vector2(float(cell[0]), float(cell[1]))
	_feet_y = float(data["feet_y"])
	_poses = data["poses"]
	_foot_travel = float(data.get("foot_travel", 0.0))
	_body_height = float(data.get("body_height", 0.0))
	_index_poses()

	_textures.clear()
	for direction in data["directions"]:
		var texture_2d: Texture2D = load(folder + str(direction) + ".png")
		if texture_2d != null:
			_textures[str(direction)] = texture_2d


## Redéfinit la mise en place d'Actor : une seule image découpée en poses
## (hframes), pas de pieds séparés — ils sont dessinés dans la planche.
func _apply_visual() -> void:
	if sprite == null or _textures.is_empty():
		return
	foot_left.visible = false
	foot_right.visible = false
	var factor := target_height / _cell.y
	_sprite_scale = Vector2(factor, factor)
	sprite.scale = _sprite_scale
	sprite.region_enabled = false
	sprite.vframes = 1
	sprite.hframes = maxi(1, _poses.size())
	# Aucun miroir : les planches qui ont un profil dessinent les DEUX côtés,
	# celles qui n'en ont pas se voient pareil de partout.
	sprite.flip_h = false
	# Les pieds tombent sur l'origine du nœud, là où le Level pose l'ennemi et
	# où Actor dessine son ombre de contact.
	sprite.offset = Vector2(0.0, _cell.y * 0.5 - _feet_y)
	_apply_frame()


func _direction_key() -> String:
	var shown := _strike_facing if _showing_strike() else _facing
	if shown == Vector2i.UP:
		return "up"
	if shown == Vector2i.LEFT:
		return "left"
	if shown == Vector2i.RIGHT:
		return "right"
	return "down"


func _apply_frame() -> void:
	# Repli sur « down » : une planche à orientation unique ne déclare que
	# celle-là, et c'est elle qui sert aux quatre directions.
	var wanted: Texture2D = _textures.get(_direction_key(), _textures.get("down"))
	if wanted == null:
		return
	if sprite.texture != wanted:
		sprite.texture = wanted
	# La pose de coup prime sur la marche, et dure ce que dure `_strike` : le
	# même chronomètre porte déjà l'élan en avant et la teinte, tout reste en
	# phase sans second compteur à tenir.
	var index := _idle_pose
	if _showing_strike():
		# LE COUP SE DÉROULE SUR TOUT LE GESTE, frappe ET repos.
		#
		# Il s'étalait d'abord sur la seule FRAPPE, ce qui semblait juste : le
		# geste dans le temps exact où il fait mal. À l'usage c'est illisible —
		# huit images dans les 0,22 s de frappe d'un gobelin font 36 images par
		# seconde, deux fois la cadence d'une animation dessinée. On voyait un
		# tressaillement, pas un coup de massue.
		#
		# Le REPOS fait partie du geste : c'est le bras qui revient. En comptant
		# les deux, le gobelin tombe à 16 img/s et le golem à 8. La frappe, elle,
		# fait toujours mal au même instant — ce sont deux choses différentes, et
		# les confondre était l'erreur.
		#
		# ET IL ARRIVE À SON IMPACT AU MOMENT OÙ LE COUP TOUCHE : l'armement occupe
		# les images qui précèdent `impact_pose`, le reste du geste les suivantes.
		var span := maxf(0.001, float(_tuning["strike"]) + float(_tuning["repos"]))
		var elapsed := span - _strike_rest
		var windup := minf(Bestiary.windup(species), span * 0.9)
		var count := _attack_poses.size()
		var impact := clampi(Bestiary.impact_pose(species) - 1, 0, count - 1)
		var position_in_gesture: float
		if elapsed < windup:
			position_in_gesture = elapsed / windup * float(impact)
		else:
			position_in_gesture = float(impact) \
				+ (elapsed - windup) / (span - windup) * float(count - impact)
		index = _attack_poses[clampi(int(position_in_gesture), 0, count - 1)]
	elif mover != null and mover.is_moving() and not _walk_poses.is_empty():
		index = _walk_poses[int(_walk_phase) % _walk_poses.size()]
	sprite.frame = clampi(index, 0, _poses.size() - 1)


## Range les poses par RÔLE, une fois pour toutes au chargement.
##
## Le rôle se lit dans le NOM, et c'est ce qui permet aux planches à six poses
## et à celles à seize de se jouer par le même code : on ne compte plus les
## cases (« tout sauf la première et la dernière »), on lit ce qu'elles disent
## être. Une planche qui dessine huit pas et huit poses de coup n'a donc rien à
## déclarer de plus que ses noms.
func _index_poses() -> void:
	_walk_poses.clear()
	_attack_poses.clear()
	_idle_pose = 0
	for i in _poses.size():
		var name := str(_poses[i])
		if name.begins_with("walk"):
			_walk_poses.append(i)
		elif name.begins_with("attack"):
			_attack_poses.append(i)
		elif name == "idle":
			_idle_pose = i


## Redéfinit l'animation procédurale d'Actor.
func _animate(delta: float) -> void:
	if sprite == null:
		return
	if mover.direction != Vector2i.ZERO:
		_facing = mover.direction
		# LA CADENCE VIENT DE LA DISTANCE, quand la bête a des jambes.
		#
		# Une cadence en images par seconde ne peut pas suivre : elle est réglée
		# pour une vitesse et un nombre d'images donnés, et les deux changent.
		# Le passage de quatre à huit images de marche a doublé la durée d'un
		# cycle sans toucher au `walk_fps` — le pied se posait donc deux fois
		# moins souvent pour la même distance, et la créature patinait. Une
		# créature ralentie par une trempe patinait de la même façon, dans
		# l'autre sens.
		#
		# En liant la phase à la distance PARCOURUE, le pied se pose toujours au
		# même endroit du sol quelle que soit la vitesse, le ralentissement ou le
		# nombre d'images de la planche. `stride` dit combien de cases couvre un
		# cycle complet — une foulée de gobelin n'est pas celle d'un minotaure.
		#
		# Ce qui FLOTTE garde sa cadence en secondes : un spectre n'a pas de pied
		# à poser, son ondulation ne doit rien à la distance.
		# LA FOULÉE VIENT DU DESSIN, quand la planche la mesure.
		#
		# `foot_travel` dit de combien le pied avance sur un cycle, en part de la
		# hauteur de la bête. Deux fois cette course, converti en cases, donne la
		# distance qu'un cycle complet doit couvrir pour que le pied reste collé
		# au sol — c'est de l'arithmétique, pas un réglage.
		#
		# Le `stride` du bestiaire reste le repli pour les planches d'avant, qui
		# ne portent pas la mesure.
		var stride := float(_tuning.get("stride", 0.0))
		if _foot_travel > 0.0:
			stride = 2.0 * _foot_travel * float(_tuning["height"]) / float(tile_size)
		if stride > 0.0 and not _walk_poses.is_empty():
			var cadence := mover.speed * float(_walk_poses.size()) / stride
			# ⚠️ PLAFONNÉE, et il faut dire pourquoi plutôt que de le cacher.
			#
			# La cadence qui collerait vraiment le pied au sol se calcule
			# exactement — et elle demande 51 images par seconde pour le gobelin,
			# 65 pour le minotaure. À ce rythme on ne voit plus une démarche mais
			# un tremblement.
			#
			# La cause n'est pas ici : leurs planches ne font avancer le pied que
			# d'un cinquième de leur hauteur, là où le sol défile de deux fois
			# plus. Tant que le dessin ne fait pas de plus grands pas, il RESTERA
			# un glissement — on choisit seulement le moins laid des deux défauts,
			# glisser un peu plutôt que grésiller.
			_walk_phase += delta * minf(cadence, MAX_WALK_FPS)
		else:
			_walk_phase += delta * float(_tuning["walk_fps"])
	else:
		# À l'arrêt, retour à la pose de repos plutôt qu'un pas figé en l'air.
		_walk_phase = 0.0
	_apply_frame()
	_animate_body(delta)


## La respiration à l'arrêt, et le flottement de ce qui ne touche pas le sol. Les
## pieds dessinés restent posés et l'ombre aussi : c'est l'écart entre les deux qui
## fait lire la lévitation.
func _animate_body(delta: float) -> void:
	if mover.is_moving():
		sprite.scale = _sprite_scale
		_life_time += delta
	else:
		_breathe(delta)
	sprite.position.y = 0.0
	if bool(_tuning.get("hover", false)):
		sprite.position.y = (sin(_life_time * HOVER_SPEED) - 1.0) * HOVER_DEPTH


func _process(delta: float) -> void:
	super(delta)
	if sprite == null or mover == null:
		return
	# Élan du coup : un aller-retour rapide vers la cible. Pas dans le sens de la
	# marche : le poursuivant qui frappe est arrêté à une case, sa direction est
	# nulle, et l'élan n'aurait jamais lieu.
	if _strike > 0.0:
		# Le bout de l'élan tombe sur l'impact : le corps arrive avec l'arme.
		var total := maxf(0.01, float(_tuning["strike"]))
		var elapsed := total - _strike
		var windup := minf(Bestiary.windup(species), total * 0.9)
		var phase := 0.5 * elapsed / windup if elapsed < windup \
			else 0.5 + 0.5 * (elapsed - windup) / (total - windup)
		var lunge := sin(phase * PI) * tile_size * STRIKE_LUNGE
		position += Vector2(_strike_facing) * lunge


func _draw() -> void:
	super()
	if health == null or dead:
		return
	_draw_venom()
	_draw_blind()
	_draw_mark()
	_draw_star_marks()
	# La barre ne s'affiche qu'une fois le premier coup porté : au complet, elle
	# n'apprend rien et met un bandeau rouge au-dessus de chaque ennemi de la
	# carte, ce qui noie l'information au moment où elle compte.
	var ratio := health.ratio()
	# Le boss a sa grande barre, en haut de l'écran.
	if ratio >= 1.0 or is_boss():
		return

	var width := tile_size * BAR_WIDTH
	var height := tile_size * BAR_HEIGHT
	var origin := Vector2(-width * 0.5, -tile_size * BAR_HEIGHT_ABOVE)
	draw_rect(Rect2(origin - Vector2(1.0, 1.0), Vector2(width + 2.0, height + 2.0)),
		Color(0.02, 0.03, 0.06, 0.85))
	draw_rect(Rect2(origin, Vector2(width, height)), Color(0.28, 0.06, 0.08, 0.95))
	# Du rouge au jaune quand il ne reste presque rien : le joueur doit savoir
	# qu'un dernier coup suffit, c'est ce qui décide s'il reste ou s'il fuit.
	var fill := Color("#e0463a").lerp(Color("#ffd15a"), clampf(1.0 - ratio * 2.0, 0.0, 1.0))
	draw_rect(Rect2(origin, Vector2(width * ratio, height)), fill)
	draw_rect(Rect2(origin, Vector2(width, height)), Color(0.85, 0.9, 1.0, 0.35), false, 1.0)


## Une à trois gouttes au-dessus de la barre de vie, et des bulles qui montent du corps.
func _draw_venom() -> void:
	if _venom_doses <= 0:
		return
	var drop := tile_size * 0.075
	# À droite de la barre : les chiffres de dégâts montent au-dessus et les cacheraient.
	var y := -tile_size * BAR_HEIGHT_ABOVE + tile_size * BAR_HEIGHT * 0.5
	var left := tile_size * BAR_WIDTH * 0.5 + drop * 1.8
	var clock := float(Time.get_ticks_msec()) * 0.001
	for i in _venom_doses:
		var x := left + float(i) * drop * 2.5
		var tip := Vector2(x, y - drop * 1.9)
		var points := PackedVector2Array([tip, Vector2(x - drop * 0.8, y - drop * 0.3),
			Vector2(x + drop * 0.8, y - drop * 0.3)])
		draw_circle(Vector2(x, y), drop + 1.0, VENOM_RIM)
		draw_colored_polygon(points, VENOM_RIM)
		draw_circle(Vector2(x, y), drop, VENOM_DROP)
		draw_circle(Vector2(x - drop * 0.25, y - drop * 0.25), drop * 0.3, VENOM_SHINE)
	# Une bulle par dose sur les côtés du corps. À trois doses, il en sort sans arrêt.
	for i in _venom_doses * 2:
		var life := fmod(clock * 0.8 + float(i) * 0.37, 1.0)
		var side := -1.0 if i % 2 == 0 else 1.0
		var at := Vector2(side * tile_size * (0.28 + 0.1 * sin(float(i) * 2.3)),
			-tile_size * (0.25 + life * 0.85))
		var radius := tile_size * 0.05 * (0.6 + life * 0.7)
		var alpha := (1.0 - life) * 0.95
		draw_circle(at, radius, Color(VENOM_DROP, alpha))
		draw_arc(at, radius, 0.0, TAU, 10, Color(VENOM_RIM, alpha), 1.0)


func _draw_star_marks() -> void:
	var clock := float(Time.get_ticks_msec()) * 0.0025
	for i in _astre_marks:
		var angle := clock + float(i) * TAU / float(_astre_marks)
		var at := Vector2(cos(angle) * tile_size * 0.42, -tile_size * 0.55 + sin(angle) * tile_size * 0.14)
		var star := PackedVector2Array()
		for point in 8:
			var length := tile_size * (0.1 if point % 2 == 0 else 0.03)
			star.append(at + Vector2.from_angle(float(point) * TAU / 8.0) * length)
		draw_colored_polygon(star, ASTRE_STAR)
		star.append(star[0])
		draw_polyline(star, ASTRE_RIM, 1.0)


func _draw_mark() -> void:
	if _marked_left <= 0.0:
		return
	var at := Vector2(0.0, -tile_size * (BAR_HEIGHT_ABOVE + 0.32))
	var span := tile_size * 0.13
	var bell := PackedVector2Array([at + Vector2(-span * 0.45, -span), at + Vector2(span * 0.45, -span),
		at + Vector2(span * 0.7, span * 0.4), at + Vector2(span, span * 0.8),
		at + Vector2(-span, span * 0.8), at + Vector2(-span * 0.7, span * 0.4)])
	draw_colored_polygon(bell, MARK_BELL)
	bell.append(bell[0])
	draw_polyline(bell, MARK_RIM, 1.5)
	draw_circle(at + Vector2(0.0, span), span * 0.25, MARK_RIM)


## Trois étoiles d'or tournent au-dessus de la barre de vie. Elles s'éteignent une à une
## juste avant qu'il reprenne la poursuite.
func _draw_blind() -> void:
	if not is_blinded() or ai.possess_left > 0.0:
		return
	var lit := mini(3, ceili(ai.blind_left / 0.3))
	var clock := float(Time.get_ticks_msec()) * 0.004
	var centre := Vector2(0.0, -tile_size * (BAR_HEIGHT_ABOVE + 0.2))
	var span := tile_size * 0.05
	for i in lit:
		var angle := clock + float(i) * TAU / 3.0
		var at := centre + Vector2(cos(angle) * tile_size * 0.3, sin(angle) * tile_size * 0.1)
		var star := PackedVector2Array()
		for point in 8:
			var length := span * (2.0 if point % 2 == 0 else 0.7)
			star.append(at + Vector2.from_angle(float(point) * TAU / 8.0 + 0.4) * length)
		star.append(star[0])
		draw_colored_polygon(star, BLIND_STAR)
		draw_polyline(star, BLIND_RIM, 1.0)
