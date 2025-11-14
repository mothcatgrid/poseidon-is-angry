@tool
extends Node3D

@export var wave_amplitude: float = 3.0:
	set(value):
		wave_amplitude = value
		if get_node_or_null("Water"):
			$Water.get_active_material(0).set_shader_parameter("amplitude", value)

@export var wave_frequency: float = 0.2:
	set(value):
		wave_frequency = value
		if get_node_or_null("Water"):
			$Water.get_active_material(0).set_shader_parameter("frequency", value)

@export var wave_speed: float = 0.2:
	set(value):
		wave_speed = value
		if get_node_or_null("Water"):
			$Water.get_active_material(0).set_shader_parameter("speed", value)

var time: float = 0.0


func _ready():
	Global.ocean = self


func _process(delta: float) -> void:
	time += delta
	$Water.get_active_material(0).set_shader_parameter("time", time)


func get_ocean_height(point: Vector3) -> float:
	var surface_position = Vector3(point.x, 0.0, point.z)
	var time_speed = time * wave_speed
	#return sin((point.x * wave_frequency) + time) * wave_amplitude
	return (sin((point.x * wave_frequency) + time_speed) + cos((point.x * wave_frequency * 0.5) - time_speed)) * wave_amplitude;
