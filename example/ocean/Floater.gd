extends Node3D
class_name Floater

var depth_before_submerged = 1.0
@onready var ocean = get_node("../../Ocean")

var last_position = Vector3()
var floater_count = 0

@export var water_drag = 0.99
@export var water_angular_drag = 0.5

@export var enabled = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent_weight = get_parent().mass
	# How many floater children does the parent have?
	for c in get_parent().get_children():
		if c.get_script() == get_script():
			floater_count += 1

func _physics_process(delta):
	if not enabled:
		return
	
	var world_coord_offset = global_position - get_parent().global_position
		
	var wave = ocean.get_wave(global_position.x, global_position.z)
	var wave_height = wave.y / 2.0
	var height = global_position.y
	
	if height < wave_height:
		var buoyancy = clamp((wave_height - height) / depth_before_submerged, 0, 1) * 2
		get_parent().apply_force(world_coord_offset, Vector3(0, 9.8 * buoyancy, 0))
		get_parent().apply_central_force(buoyancy * -get_parent().linear_velocity * water_drag)
		get_parent().apply_torque(buoyancy * -get_parent().angular_velocity * water_angular_drag)
	if $Marker: $Marker.position.y = wave_height
