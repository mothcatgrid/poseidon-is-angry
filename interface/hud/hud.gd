class_name HUD
extends CanvasLayer
## The HUD should manage the state of the in-game UI
## Pause buttons, inventory screens, etc

@onready var pause_menu = %PauseMenu


func _ready():
	self.visible = true
	Global.hud = self
	Controls.show_mouse = false
	
	if not Global.is_debug():
		$Root/Debug.visible = false


# No real reason to update on _process
func _physics_process(delta):
	pass


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause_menu.pause_toggled()
