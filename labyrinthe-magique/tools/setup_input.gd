extends SceneTree

## Outil ponctuel : écrit l'InputMap dans project.godot.
##   godot --headless --path . --script res://tools/setup_input.gd
##
## Écrit par code plutôt qu'à la main : le format sérialisé des InputEvent dans
## project.godot est verbeux et change entre versions de Godot. Le générer via
## l'API garantit qu'il est toujours valide.
##
## Touches physiques (physical_keycode) et non logiques : ZQSD sur clavier AZERTY
## tombe automatiquement au bon endroit sans configuration.

const ACTIONS := {
	"move_up":    {"keys": [KEY_W, KEY_UP],    "axis": [JOY_AXIS_LEFT_Y, -1.0]},
	"move_down":  {"keys": [KEY_S, KEY_DOWN],  "axis": [JOY_AXIS_LEFT_Y, 1.0]},
	"move_left":  {"keys": [KEY_A, KEY_LEFT],  "axis": [JOY_AXIS_LEFT_X, -1.0]},
	"move_right": {"keys": [KEY_D, KEY_RIGHT], "axis": [JOY_AXIS_LEFT_X, 1.0]},
	"teleport":   {"keys": [KEY_SPACE],        "buttons": [JOY_BUTTON_A]},
	"pause":      {"keys": [KEY_ESCAPE],       "buttons": [JOY_BUTTON_START]},
	"restart":    {"keys": [KEY_R],            "buttons": [JOY_BUTTON_Y]},
}


func _init() -> void:
	for action_name in ACTIONS:
		var spec: Dictionary = ACTIONS[action_name]
		var events: Array = []

		for keycode in spec.get("keys", []):
			var key_event := InputEventKey.new()
			key_event.physical_keycode = keycode
			events.append(key_event)

		if spec.has("axis"):
			var motion := InputEventJoypadMotion.new()
			motion.axis = spec["axis"][0]
			motion.axis_value = spec["axis"][1]
			events.append(motion)

		for button in spec.get("buttons", []):
			var button_event := InputEventJoypadButton.new()
			button_event.button_index = button
			events.append(button_event)

		ProjectSettings.set_setting("input/" + action_name, {"deadzone": 0.25, "events": events})

	# Permet de tester le joystick tactile à la souris sur desktop (`-- --touch`).
	ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", true)

	var err := ProjectSettings.save()
	print("InputMap écrit dans project.godot -> ", error_string(err))
	quit(0 if err == OK else 1)
