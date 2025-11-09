@tool
extends BaseOption
## An option that allows value true or false

@onready var label: Label = %Label
@onready var checkbutton: CheckButton = %CheckButton


func _ready():
	super()
	if not Engine.is_editor_hint():
		label.text = option_text
		pressed.connect(_on_self_pressed.bind())
		_sync_value()


func _on_self_pressed():
	checkbutton.button_pressed = !checkbutton.button_pressed
	_set_value(checkbutton.button_pressed)


func _sync_value():
	checkbutton.button_pressed = _get_value()
