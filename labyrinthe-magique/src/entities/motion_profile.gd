class_name MotionProfile
extends RefCounted

## Le gabarit d'animation : ce qu'un personnage joue en plus de sa planche, à 60 images
## par seconde. Il se déclare par la clé `motion` de `frames.json`, et tout y est
## facultatif. Sans cette clé, `Player` garde son ancien comportement.
##
## Purement visuel : ni la position de la grille, ni les collisions, ni les dégâts n'en
## dépendent. `test_balance` ne le voit donc pas.

## Durée de chaque image d'attaque, en millisecondes. Elles ne durent pas le même temps,
## c'est ce qui donne le punch : le coup part vite, l'impact et la fin du geste se tiennent.
const ATTACK_MS: Array[int] = [17, 33, 17, 67, 50, 67, 33, 33]
## L'image où la lame arrive devant le personnage.
const IMPACT_POSE := 3

var attack_ms: Array[int] = ATTACK_MS.duplicate()
var impact_pose := IMPACT_POSE
## Rebond de la course, en unités de jeu : bas aux appuis, haut au passage.
var bob := 2.0
## Écrasement à chaque appui, en fraction de la hauteur.
var squash := 0.05
## De profil : le même rebond qu'en haut et en bas, le corps restant droit.
var side_bob := 2.0
var side_squash := 0.05
## Décalage du rebond de profil sur le cycle, de 0 à 1. Il dépend de l'ordre des images : le
## corps doit être au plus bas quand les pieds sont au plus écartés.
var side_phase := 0.0
## Penchée de la silhouette pendant le coup, en radians. Jamais pendant la course de profil.
var strike_lean := 0.126
## Poussée vers l'avant à l'impact, en cases.
var lunge := 0.16
## L'à-coup du départ, de l'arrêt et du demi-tour.
var kick := 1.3
## La poussière sous les pieds, aux appuis et aux à-coups.
var dust := true
## L'arc de lame à l'impact. Transparent : pas d'arc.
var slash_color := Color("#dff4ff")
## Un coup sur deux, l'arc part dans l'autre sens : deux coups de suite se croisent en X.
var slash_alternate := false


## Null quand le personnage n'a pas de clé `motion` : c'est ce qui laisse les autres intacts.
static func from_data(data: Variant) -> MotionProfile:
	if not data is Dictionary:
		return null
	var profile := MotionProfile.new()
	var values: Dictionary = data
	if values.has("attack_ms"):
		profile.attack_ms.clear()
		for ms: Variant in values["attack_ms"]:
			profile.attack_ms.append(int(ms))
	profile.impact_pose = int(values.get("impact_pose", profile.impact_pose))
	profile.bob = float(values.get("bob", profile.bob))
	profile.squash = float(values.get("squash", profile.squash))
	profile.side_bob = float(values.get("side_bob", profile.side_bob))
	profile.side_squash = float(values.get("side_squash", profile.side_squash))
	profile.side_phase = float(values.get("side_phase", profile.side_phase))
	profile.strike_lean = float(values.get("strike_lean", profile.strike_lean))
	profile.lunge = float(values.get("lunge", profile.lunge))
	profile.kick = float(values.get("kick", profile.kick))
	profile.dust = bool(values.get("dust", profile.dust))
	profile.slash_alternate = bool(values.get("slash_alternate", false))
	if values.has("slash_color"):
		profile.slash_color = Color(str(values["slash_color"]))
	return profile


func attack_duration() -> float:
	var total := 0
	for ms in attack_ms:
		total += ms
	return float(total) / 1000.0


## Le numéro de l'image d'attaque, `elapsed` secondes après le début du geste.
func attack_pose(elapsed: float) -> int:
	var reached := 0.0
	for i in attack_ms.size():
		reached += float(attack_ms[i]) / 1000.0
		if elapsed < reached:
			return i
	return attack_ms.size() - 1


## L'instant où commence l'image d'impact.
func impact_time() -> float:
	var total := 0
	for i in mini(impact_pose, attack_ms.size()):
		total += attack_ms[i]
	return float(total) / 1000.0


## L'arc de lame part une image AVANT l'impact : il a alors rejoint l'épée quand elle arrive
## devant, au lieu de la suivre de loin.
func slash_time() -> float:
	var total := 0
	for i in mini(maxi(0, impact_pose - 1), attack_ms.size()):
		total += attack_ms[i]
	return float(total) / 1000.0


## La poussée de 0 à 1 : nulle avant l'impact, immédiate à l'impact, puis elle revient
## doucement. Un retour aussi vite que l'aller se lirait comme un tremblement.
func lunge_at(elapsed: float) -> float:
	var since := elapsed - impact_time()
	if since < 0.0:
		return 0.0
	var back := clampf(since / maxf(0.001, attack_duration() - impact_time()), 0.0, 1.0)
	return pow(1.0 - back, 2.0)


## L'élévation du corps sur le cycle de course, `cycle` allant de 0 à 1. Deux appuis par
## cycle, aux images 1 et 5, et le corps est au plus bas sur chacun.
func bob_at(cycle: float, sideways: bool = false) -> float:
	if sideways:
		return absf(sin((cycle - side_phase) * TAU)) * side_bob
	return absf(sin(cycle * TAU)) * bob


## L'écrasement sur le même cycle : positif à l'appui, négatif (étiré) au passage.
func squash_at(cycle: float, sideways: bool = false) -> float:
	if sideways:
		return cos((cycle - side_phase) * TAU * 2.0) * side_squash
	return cos(cycle * TAU * 2.0) * squash
