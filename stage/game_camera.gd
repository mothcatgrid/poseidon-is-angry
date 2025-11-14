extends Node3D

func _process(delta: float) -> void:
	global_position = Util.delta_lerp(global_position, Global.player_boat.global_position, 1.0, delta)
	global_rotation = Util.delta_lerp(global_rotation, Global.player_boat.global_rotation, 1.0, delta)
