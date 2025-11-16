extends Node3D

@export var follow: Node3D

func _process(delta: float) -> void:
	global_position = Util.delta_lerp(global_position, follow.global_position, 2.0, delta)
	global_basis = global_basis.slerp(follow.global_basis, delta).get_rotation_quaternion()
