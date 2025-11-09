class_name InputPrompt
extends TextureRect
## Shows the correct button texture for the action specified. It can automatically match the
## current input device or always show keyboard or joypad specifically (mainly for rebinding menu)

enum PromptType { AUTO, KEYBOARD, CONTROLLER }

const BASE_PATH = "res://interface/textures/input_prompts/"

@export var type: PromptType = PromptType.AUTO
@export var action: String = ""
	#set(val):
		#action = val
		#update_texture(Controls.device)
	#get:
		#return action


func _ready():
	Controls.keyboard_input_changed.connect(_action_input_changed.bind())
	Controls.joypad_input_changed.connect(_action_input_changed.bind())
	Controls.device_changed.connect(_on_device_changed.bind())
	update_texture(Controls.device)


# update the texture to match our action for a specified device
func update_texture(device: String):
	if action != "":
		if type in [PromptType.AUTO, PromptType.KEYBOARD] and device == Controls.DEVICE_KEYBOARD:
			set_texture_to_input(Controls.get_keyboard_input_for_action(action), device)
		elif type in [PromptType.AUTO, PromptType.CONTROLLER]:
			# xbox input prompts are the default unless it is PS or Switch controller
			var joypad_name = device
			if not joypad_name in [
				Controls.DEVICE_XBOX_CONTROLLER, 
				Controls.DEVICE_PLAYSTATION_CONTROLLER, 
				Controls.DEVICE_SWITCH_CONTROLLER,
			]:
				joypad_name = Controls.DEVICE_XBOX_CONTROLLER
			set_texture_to_input(Controls.get_joypad_input_for_action(action), joypad_name)


## Set the texture to match a specific input event if the texture exists
func set_texture_to_input(input: InputEvent, device: String):
	if Controls.is_input_valid_binding(input):
		# get rid of modifier part of input
		var mutable_input = input.duplicate()
		if mutable_input is InputEventWithModifiers:
			mutable_input.shift_pressed = false
			mutable_input.ctrl_pressed = false
			mutable_input.meta_pressed = false
			mutable_input.alt_pressed = false
		
		# grab correct texture
		var label = Controls.get_label_for_input(mutable_input, device).to_snake_case()
		var path = ""
		
		if mutable_input is InputEventKey:
			path = "%skeyboard/kb_%s.png" % [BASE_PATH, label]
		elif mutable_input is InputEventMouseButton:
			path = "%skeyboard/%s.png" % [BASE_PATH, label]
		elif mutable_input is InputEventJoypadButton or InputEventJoypadMotion:
			path = "%s%s/%s_%s.png" % [BASE_PATH, device, device, label]
		if ResourceLoader.exists(path):
			texture = load(path)


## Called whenever a key is rebound
func _action_input_changed(rebound_action: String, _input: InputEvent):
	# the update_texture method automatically pulls the action so no need to use the args
	if rebound_action == action:
		update_texture(Controls.device)


## Called when the user's input changes to a different device
func _on_device_changed(device: String, device_index: int):
	update_texture(device)
