class_name Awakening
extends RefCounted

## L'ÉVEIL D'UN MAGE (2026-11-07) : une minute sous sa forme transformée, puis dix secondes
## d'épuisement, et six kills avant le suivant. Sans la charge, le joueur l'avait demandé avec
## « 1 min et 10 s de recharge » : il aurait été éveillé six secondes sur sept, et l'Éveil serait
## devenu sa forme normale.
##
## Sans scène, comme `Transformation` d'Aël : le jeu le pilote, et une simulation le pourrait.
## La forme éveillée vient de `CharacterCatalog.awakening_of` ; le changement de forme passe par
## `form_changed`, que le GameManager applique au `Level` (le kit, les bandes, les icônes).
##
## Traits propres à chaque forme, portés ici parce qu'ils vivent et meurent avec l'Éveil :
## - RENAISSANCE : un coup mortel le relève une fois à 2 PV, intouchable, dans une explosion, et
##   met fin à l'Éveil ;
## - la TRAÎNÉE DE BRAISES qu'il laisse derrière lui (`CombatSystem.start_embers`) ;
## - MARÉE HAUTE (le Seigneur des Marées) : une coque d'eau qui encaisse un coup entier et se reforme
##   `SHELL_REGROW` secondes après avoir cédé. Elle vit dans le bouclier de `Health`, avec la Bulle.
## - PIÉTINEMENT (le Colosse) : il marche à travers les ennemis, les repousse de `TRAMPLE_CELLS` cases
##   et leur fait `TRAMPLE_DAMAGE` (`CombatSystem.start_trample`). Il grandit de `GROWTH`, que le
##   `Level` applique au sprite.
## - SURTENSION (l'Avatar de la Tempête) : chaque coup le charge, et la `SURGE_CHARGES`-ième fait tomber
##   la foudre du ciel sur la cible de l'attaque suivante (`CombatSystem.start_surge`).
## - LE PRIX DU SANG (l'Archidémon du Pacte) : sa vie coule d'1 PV toutes les `BLOOD_EVERY` s, jamais le
##   dernier, chaque kill la lui rend, et sa Rage est multipliée par `BLOOD_RAGE` (`CombatSystem.start_blood_price`).
## - LA DISCORDE CONTAGIEUSE (la Reine de la Discorde) : chaque coup trouble, et la possession d'un pantin mort
##   saute sur son plus proche voisin (`CombatSystem.start_contagion`).
## - LE SILLAGE DE CENDRES (l'Empereur des Cendres) : chaque pièce qui vole met le feu aux cases qu'elle
##   franchit, et une pièce arrachée revient deux fois plus vite (`CombatSystem.start_ashes`).
## - LA LAME AFFÛTÉE (le Seigneur Écarlate) : une entaille de plus par coup, huit au plus, et à huit elles
##   s'ouvrent seules (`CombatSystem.start_keen`).
## - LE POIDS DES CHAÎNES (le Gardien de l'Abîme) : entravé au deuxième coup, et ce qui est sonné prend
##   `ABYSS_HELD_BONUS` de dégâts en plus (`CombatSystem.start_abyss`).
## - LE FEU PRIMORDIAL (le Dragon Primordial) : ses cases en feu durent et rongent plus, et ce qui meurt dans le
##   feu explose en l'étendant (`CombatSystem.start_primal`).
## - LA MAISON GAGNE TOUJOURS (le Maître du Casino) : le Coup de chance tombe deux fois plus souvent, et chacun
##   paie une gerbe de jetons sur les voisins (`CombatSystem.start_house`).
## - LA FAIM SANS FOND (Faim Sans Fond) : huit bouchées, qui ne fondent plus, deux par kill
##   (`CombatSystem.start_endless`).
## - REMPART DE VENT (le Souverain des Vents) : le pas du Colosse sans dégâts. Un voisin est repoussé de
##   `GALE_CELLS` cases et ralenti `GALE_SLOW` s, une fois toutes les `GALE_LOCK` s.
## - LE DOUBLE (le Seigneur du Néant) : son ombre répète chaque coup visé à `DOUBLE_RATIO` de sa force,
##   `DOUBLE_DELAY` secondes après (`CombatSystem.start_double`).
## - LA LÉGION (le Maître des Légions) : ses créatures naissent éveillées, frappent à `LEGION_RATIO`,
##   et il en garde `LEGION_CAP` (`CombatSystem.start_legion`).
## - TEMPS ACCÉLÉRÉ (le Seigneur des Heures) : ses recharges courent à `HASTE_FACTOR` fois l'allure du
##   monde (`CombatSystem.start_haste`) ; sa marche plus rapide est dans sa forme.
## - LE MIASME (le Seigneur du Fléau) : une dose toutes les `MIASMA_EVERY` s à chaque créature collée à lui,
##   et le poison monte à `MIASMA_CAP` doses (`CombatSystem.start_miasma`).
## - LA ROUE DES ÉLÉMENTS (l'Archimage Primordial) : chaque coup porte le trait de l'orbe en tête (feu, eau,
##   terre, air), et son attaque fait tourner la roue (`CombatSystem.start_wheel`).
## - LA RÉCOLTE (le Faucheur des Âmes) : il achève plus haut, et ses âmes, jusqu'à six, frappent ce qui l'approche
##   (`CombatSystem.start_harvest`).
## - L'ÉBLOUISSEMENT (l'Étoile du Matin) : ce qu'il aveugle prend plus cher, et ce qui reste collé à lui finit
##   aveuglé (`CombatSystem.start_dazzle`).

enum State { NORMAL, CHARGING, AWAKE, EXHAUSTED }

const CHARGE_TIME := 0.8
const DURATION := 60.0
const EXHAUST_TIME := 10.0
const KILLS := 6
const REBIRTH_HEALTH := 2
const REBIRTH_IMMUNITY := 1.5
const REBIRTH_DAMAGE := 40
const REBIRTH_RADIUS := 2.5
const EMBER_DAMAGE := 6
const EMBER_LIFE := 1.5
const SHELL_REGROW := 6.0
const TRAMPLE_DAMAGE := 15
const TRAMPLE_CELLS := 2
const GROWTH := 1.33
const SURGE_CHARGES := 5
const SURGE_DAMAGE := 40
const SURGE_RADIUS := 1.5
const GALE_CELLS := 2
const GALE_LOCK := 2.0
const GALE_SLOW := 1.0
const DOUBLE_DELAY := 0.25
const DOUBLE_RATIO := 0.5
const LEGION_RATIO := 1.5
const LEGION_CAP := 6
const HASTE_FACTOR := 1.5
## LE PRIX DU SANG (l'Archidémon du Pacte) : 1 PV coule toutes les `BLOOD_EVERY` s, et sa Rage est multipliée.
const BLOOD_EVERY := 8.0
const BLOOD_RAGE := 2.0
const MIASMA_EVERY := 1.0
const MIASMA_CAP := 5

signal changed(state: State)
## La forme à appliquer : l'éveillée au réveil, la forme de base à l'épuisement.
signal form_changed(next: CharacterStats)
## Il vient de renaître : le jeu en montre l'effet.
signal reborn
## Marée haute : la coque vient de se reformer, ou de céder.
signal shell_formed
signal shell_broken

var state := State.NORMAL
var left := 0.0
var charge := 0
var base: CharacterStats = null
var awakened: CharacterStats = null
var combat: CombatSystem = null
var health: Health = null
## La photo du monde que lit le combat : il en faut une pour l'onde de la Renaissance.
var context: CombatContext = null

var _reborn_used := false
var _health_seen := 0
var _minimum_before := 0
var _shell_up := false
var _shell_wait := 0.0


func _init(p_base: CharacterStats, p_awakened: CharacterStats, p_combat: CombatSystem,
		p_context: CombatContext) -> void:
	base = p_base
	awakened = p_awakened
	combat = p_combat
	context = p_context
	health = combat.health
	_health_seen = health.current
	health.damaged.connect(_on_damaged)
	health.healed.connect(_on_healed)


func dispose() -> void:
	if health.damaged.is_connected(_on_damaged):
		health.damaged.disconnect(_on_damaged)
	if health.healed.is_connected(_on_healed):
		health.healed.disconnect(_on_healed)


## `free` : en démo, l'Éveil ne demande aucun kill.
func can_begin(free := false) -> bool:
	return state == State.NORMAL and (free or charge >= KILLS)


func charge_ratio() -> float:
	return clampf(float(charge) / float(KILLS), 0.0, 1.0)


func awake() -> bool:
	return state == State.AWAKE


## Pendant le geste d'Éveil, le mage ne lance rien.
func can_act() -> bool:
	return state != State.CHARGING


func begin(free := false) -> bool:
	if not can_begin(free):
		return false
	if not free:
		charge = 0
	_change(State.CHARGING, CHARGE_TIME)
	return true


## Le joueur le quitte, ou la Renaissance y met fin.
func finish() -> void:
	if state == State.CHARGING or state == State.AWAKE:
		_change(State.EXHAUSTED, EXHAUST_TIME)


func kill() -> void:
	if state == State.NORMAL:
		charge = mini(charge + 1, KILLS)


func update(delta: float) -> void:
	var elapsed := maxf(0.0, delta)
	if state == State.AWAKE and base.id == CharacterCatalog.WATER:
		_tend_shell(elapsed)
	var remaining := elapsed
	while state != State.NORMAL and remaining >= left:
		remaining -= left
		match state:
			State.CHARGING:
				_change(State.AWAKE, DURATION)
			State.AWAKE:
				_change(State.EXHAUSTED, EXHAUST_TIME)
			State.EXHAUSTED:
				_change(State.NORMAL, 0.0)
	if state != State.NORMAL:
		left -= remaining


func _change(next: State, seconds: float) -> void:
	var before := state
	state = next
	left = seconds
	if next == State.AWAKE:
		if base.id == CharacterCatalog.FIRE:
			_reborn_used = false
			_minimum_before = health.minimum_current
			# Le coup qui devrait le tuer le laisse à 1 PV : `_on_damaged` le relève ensuite.
			health.minimum_current = maxi(1, health.minimum_current)
			_health_seen = health.current
			combat.start_embers(DURATION, EMBER_DAMAGE, EMBER_LIFE)
		elif base.id == CharacterCatalog.WATER:
			_shell_up = false
			_shell_wait = 0.0
			_tend_shell(0.0)
		elif base.id == CharacterCatalog.EARTH:
			combat.start_trample(DURATION, TRAMPLE_DAMAGE, TRAMPLE_CELLS)
		elif base.id == CharacterCatalog.THUNDER:
			combat.start_surge(DURATION, SURGE_CHARGES, SURGE_DAMAGE, SURGE_RADIUS)
		elif base.id == CharacterCatalog.AIR:
			combat.start_trample(DURATION, 0, GALE_CELLS, GALE_LOCK, GALE_SLOW)
		elif base.id == CharacterCatalog.SHADOW:
			combat.start_double(DURATION, DOUBLE_DELAY, DOUBLE_RATIO)
		elif base.id == CharacterCatalog.INVOCATEUR:
			combat.start_legion(DURATION, LEGION_RATIO, LEGION_CAP)
		elif base.id == CharacterCatalog.CHRONO:
			combat.start_haste(DURATION, HASTE_FACTOR)
		elif base.id == CharacterCatalog.PESTE:
			combat.start_miasma(DURATION, MIASMA_EVERY, MIASMA_CAP)
		elif base.id == CharacterCatalog.SUPREME:
			combat.start_wheel(DURATION)
		elif base.id == CharacterCatalog.DEMON:
			combat.start_blood_price(DURATION, BLOOD_EVERY, BLOOD_RAGE)
		elif base.id == CharacterCatalog.DISCORDE:
			combat.start_contagion()
		elif base.id == CharacterCatalog.BRAISE:
			combat.start_ashes()
		elif base.id == CharacterCatalog.ECARLATE:
			combat.start_keen()
		elif base.id == CharacterCatalog.GEOLIER:
			combat.start_abyss()
		elif base.id == CharacterCatalog.DRAGON:
			combat.start_primal()
		elif base.id == CharacterCatalog.CROUPIER:
			combat.start_house()
		elif base.id == CharacterCatalog.AVIDE:
			combat.start_endless()
		elif base.id == CharacterCatalog.LUMIERE:
			combat.start_dazzle(DURATION)
		elif base.id == CharacterCatalog.MORT:
			combat.start_harvest()
		elif base.id == CharacterCatalog.ETOILES:
			combat.start_firmament()
		elif base.id == CharacterCatalog.ACIER:
			combat.start_forge()
		elif base.id == CharacterCatalog.CHERUBIN:
			combat.start_throne()
		elif base.id == CharacterCatalog.CIEL:
			combat.start_skies()
		form_changed.emit(awakened)
	elif before == State.AWAKE or (before == State.CHARGING and next == State.EXHAUSTED):
		if before == State.AWAKE:
			if base.id == CharacterCatalog.FIRE:
				health.minimum_current = _minimum_before
				combat.stop_embers()
			if base.id == CharacterCatalog.EARTH or base.id == CharacterCatalog.AIR:
				combat.stop_trample()
			if base.id == CharacterCatalog.THUNDER:
				combat.stop_surge()
			if base.id == CharacterCatalog.SHADOW:
				combat.stop_double()
			if base.id == CharacterCatalog.INVOCATEUR:
				combat.stop_legion()
			if base.id == CharacterCatalog.CHRONO:
				combat.stop_haste()
			if base.id == CharacterCatalog.PESTE:
				combat.stop_miasma()
			if base.id == CharacterCatalog.SUPREME:
				combat.stop_wheel()
			if base.id == CharacterCatalog.DEMON:
				combat.stop_blood_price()
			if base.id == CharacterCatalog.DISCORDE:
				combat.stop_contagion()
			if base.id == CharacterCatalog.BRAISE:
				combat.stop_ashes()
			if base.id == CharacterCatalog.ECARLATE:
				combat.stop_keen()
			if base.id == CharacterCatalog.GEOLIER:
				combat.stop_abyss()
			if base.id == CharacterCatalog.DRAGON:
				combat.stop_primal()
			if base.id == CharacterCatalog.CROUPIER:
				combat.stop_house()
			if base.id == CharacterCatalog.AVIDE:
				combat.stop_endless()
			if base.id == CharacterCatalog.LUMIERE:
				combat.stop_dazzle()
			if base.id == CharacterCatalog.MORT:
				combat.stop_harvest()
			if base.id == CharacterCatalog.ETOILES:
				combat.stop_firmament()
			if base.id == CharacterCatalog.ACIER:
				combat.stop_forge()
			if base.id == CharacterCatalog.CHERUBIN:
				combat.stop_throne()
			if base.id == CharacterCatalog.CIEL:
				combat.stop_skies()
			if base.id == CharacterCatalog.WATER and _shell_up:
				# La coque s'en va avec l'Éveil ; une Bulle encore en place garde le reste.
				health.shield = maxi(0, health.shield - 1)
				_shell_up = false
				shell_broken.emit()
		form_changed.emit(base)
	changed.emit(state)


## La coque cède quand le bouclier tombe à zéro, et revient `SHELL_REGROW` secondes plus tard. Le
## bouclier est lu à chaque image : un coup, la fin d'une Bulle ou n'importe quoi d'autre peut le vider.
func _tend_shell(delta: float) -> void:
	if _shell_up:
		if health.shield <= 0:
			_shell_up = false
			_shell_wait = SHELL_REGROW
			shell_broken.emit()
		return
	_shell_wait -= delta
	if _shell_wait <= 0.0:
		health.add_shield(1)
		_shell_up = true
		shell_formed.emit()


func shell_up() -> bool:
	return _shell_up


func _on_damaged(amount: int, remaining: int) -> void:
	var before := _health_seen
	_health_seen = remaining
	if base.id != CharacterCatalog.FIRE or state != State.AWAKE or _reborn_used:
		return
	# Mortel : le coup aurait vidé ses PV, et il en a bien pris (une plaque ou un bouclier
	# qui encaisse tout laisse `remaining` égal à `before`).
	if before - amount <= 0 and remaining < before:
		_rebirth()


func _on_healed(_amount: int, remaining: int) -> void:
	_health_seen = remaining


## RENAISSANCE : relevé à 2 PV, intouchable, et l'onde part. L'Éveil s'achève.
func _rebirth() -> void:
	_reborn_used = true
	var missing := REBIRTH_HEALTH - health.current
	if missing > 0:
		health.heal(missing)
	_health_seen = health.current
	combat.grant_immunity(REBIRTH_IMMUNITY)
	if context != null:
		combat.erupt(Ability.make({"id": base.id + "_renaissance", "kind": Ability.Kind.BLAST,
			"element": base.element, "damage": REBIRTH_DAMAGE, "radius": REBIRTH_RADIUS}), context)
	reborn.emit()
	finish()
