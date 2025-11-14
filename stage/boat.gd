extends RigidBody3D

var input_force: float = 750.0
var height: float = 4.0
var floater_array: Array = []
var floater_force: float = 0.0

var input_vector: Vector2 = Vector2.ZERO


func _ready():
	Global.player_boat = self
	for child in %Floaters.get_children():
		floater_array.append(child)
		child.floater_height = height
	
	# set center of mass to position between all floaters
	var sum_vectors = Vector3.ZERO
	for floater in floater_array:
		sum_vectors += floater.position
	center_of_mass = (sum_vectors / floater_array.size()) + Vector3(0.0, height * -0.5, 0.0)
	floater_force = mass * mass


func _physics_process(delta: float) -> void:
	linear_damp = clamp(linear_velocity.y * 0.5, 0.0, 4.0)
	for floater in floater_array:
		apply_force(Vector3.UP * pow(floater.submerge_prop, 3) * floater_force, floater.global_position - global_position)
	
	apply_central_force(basis.z * input_vector.y * input_force)
	apply_torque(Vector3.UP * sign(input_vector.x) * input_force * 3.0)


func _unhandled_input(event: InputEvent) -> void:
	input_vector = Input.get_vector("move_right", "move_left", "move_down", "move_up")
