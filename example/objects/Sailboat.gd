extends RigidBody3D
class_name Sailboat

var desired_direction
var is_active = false

func _ready():
	desired_direction = -get_global_transform().basis.z.normalized()
	pass

func _physics_process(delta):
	if is_active:
		if Input.is_action_pressed("forward"):
			apply_central_force(-global_basis.z * 50)
		if Input.is_action_pressed("left"):
			apply_torque(Vector3(0, 20, 0))
		if Input.is_action_pressed("right"):
			apply_torque(Vector3(0, -20, 0))
