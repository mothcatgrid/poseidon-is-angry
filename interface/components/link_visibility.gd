class_name LinkVisibility
extends Control

@export var source: Control
@export var target: Control


func _ready():
	source.visibility_changed.connect(_on_source_visibility_changed.bind())


func _on_source_visibility_changed():
	target.visible = source.visible
