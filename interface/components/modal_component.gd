class_name ModalComponent
extends Control

@export var activator_root: Control
@export var activator: BaseButton
@export var modal: Control
@export var modal_initial_focus: Control
@export var modal_close: BaseButton


func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	activator.pressed.connect(_on_activator_pressed.bind())
	if modal_close:
		modal_close.pressed.connect(_close_modal.bind())


func _unhandled_input(event):
	if event.is_action_pressed('ui_cancel'):
		if modal.visible:
			_close_modal()
			accept_event()


func _on_activator_pressed():
	modal.visible = true
	if modal_initial_focus:
		modal_initial_focus.grab_focus()
	activator_root.visible = false


func _close_modal():
	modal.visible = false
	activator_root.visible = true
	activator.grab_focus()
