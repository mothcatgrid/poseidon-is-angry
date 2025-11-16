extends RigidBody3D

@export var player_controlled: bool = false

func _physics_process(delta):
	if player_controlled:
		if Input.is_action_pressed("forward"):
			apply_central_force(-global_basis.z * 50)
		if Input.is_action_pressed("left"):
			apply_torque(Vector3(0, 300, 0))
		if Input.is_action_pressed("right"):
			apply_torque(Vector3(0, -300, 0))
