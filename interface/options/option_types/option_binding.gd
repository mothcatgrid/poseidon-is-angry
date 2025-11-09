@tool
extends BaseOption
## An option that allows setting the keyboard or controller binding for an action

enum BindingType { KEYBOARD, JOYPAD }

@export var action: String = "" ## the input mapping action to rebind
@export var bind_type: BindingType = BindingType.KEYBOARD

@onready var label: Label = %Label
@onready var prompt: InputPrompt = %InputPrompt


func _ready():
	# bindings always the same id and type
	option_type = OptionType.GAME
	option_identifier = "bindings"
	
	if not Engine.is_editor_hint():
		label.text = option_text
		prompt.action = action
		pressed.connect(_on_self_pressed.bind())
		if bind_type == BindingType.KEYBOARD:
			prompt.type = InputPrompt.PromptType.KEYBOARD
			prompt.update_texture(Controls.DEVICE_KEYBOARD)
		else:
			prompt.type = InputPrompt.PromptType.CONTROLLER
			prompt.update_texture(Controls.DEVICE_XBOX_CONTROLLER)


func _on_self_pressed():
	if bind_type == BindingType.KEYBOARD:
		Events.keyboard_binding.emit(action)
	else:
		Events.joypad_binding.emit(action)
