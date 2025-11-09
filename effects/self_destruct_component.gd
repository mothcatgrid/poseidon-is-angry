class_name SelfDestruct
extends Node3D
## Add as a child of a node to destroy after given time

@export var lifetime : float = 1.0

var _timer

func _ready():
	# Set up timer for self destruct
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(lifetime)
	_timer.start()


func set_lifetime(new_lifetime: float):
	_timer.start(new_lifetime)


func _on_Timer_timeout():
	self.queue_free()
