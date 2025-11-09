extends Control
## Listens for input when activated then send the request to 

var keyboard_listen: bool = false
var joypad_listen: bool = false
var action: String = ""


func _ready():
	Events.keyboard_binding.connect(_on_keyboard_binding.bind())
	Events.joypad_binding.connect(_on_joypad_binding.bind())


func _input(event: InputEvent):
	if visible:
		if event.is_action("binding_cancel"):
			_done()
			accept_event()
		elif Controls.is_input_valid_binding(event):
			if keyboard_listen:
				Controls.set_keyboard_input_for_action(action, event)
				_done()
				accept_event()
			if joypad_listen:
				Controls.set_joypad_input_for_action(action, event)
				_done()
				accept_event()


func _on_keyboard_binding(new_action: String):
	action = new_action
	keyboard_listen = true
	visible = true


func _on_joypad_binding(new_action: String):
	action = new_action
	joypad_listen = true
	visible = true


func _done():
	Global.game_settings.bindings = Controls.serialize_inputs_for_actions(Actions.ALL)
	visible = false
	action = ""
	keyboard_listen = false
	joypad_listen = false
