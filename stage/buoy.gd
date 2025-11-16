@tool
extends MeshInstance3D

var ocean

func _ready():
	ocean = get_node("../Ocean")


func _physics_process(delta: float) -> void:
	global_position.y = ocean.get_wave(global_position.x, global_position.z).y
