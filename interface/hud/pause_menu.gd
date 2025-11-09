extends Control

@onready var pause_root: Control = %PauseRoot
@onready var resume_button: Button = %ResumeButton
@onready var quit_button: Button = %QuitButton

## separate than get_tree.paused since other things can pause the tree
var pause_active: bool = false


func _ready():
	resume_button.pressed.connect(set_paused.bind(false))
	quit_button.pressed.connect(Util.quit_to_menu.bind(get_tree()))
	visible = true
	pause_root.visible = false


func pause_toggled():
	if not pause_active:
		set_paused(true)
		resume_button.grab_focus()
	elif pause_root.visible:
		set_paused(false)


func set_paused(value: bool):
	get_tree().paused = value
	pause_root.visible = value
	pause_active = value
	Controls.show_mouse = value
