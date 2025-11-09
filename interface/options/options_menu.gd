extends Control


func _ready():
	self.visible = true
	for child in get_children():
		child.visible = false
