extends MeshInstance3D

func _physics_process(delta: float) -> void:
	global_position.y = Global.ocean.get_ocean_height(global_position)
