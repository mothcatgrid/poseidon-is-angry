@tool
class_name ResolutionChoice
extends OptionChoice

func _ready():
	super()
	if not Engine.is_editor_hint():
		get_tree().root.size_changed.connect(_on_window_size_changed.bind())
		choice_button.set_item_disabled(0, true)

func _on_window_size_changed():
	_sync_value()


func _sync_value():
	super()
	choice_button.selected = 0
	choice_button.disabled = DisplayServer.window_get_mode() in [
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, 
		DisplayServer.WINDOW_MODE_FULLSCREEN
	]
	choice_button.set_item_text(0, Global._get_window_res())
