class_name FloatingTextEffect
extends PoolEffect

var velocity: Vector3 = Vector3.ZERO


func reset(active):
	super(active)
	if active:
		velocity = Vector3(randf_range(-1.0, 1.0), randf_range(2.0, 3.0), randf_range(-1.0, 1.0))


func set_text(text: String):
	$Label3D.text = text


func _physics_process(delta):
	super(delta)
	self.global_position += velocity * delta
	velocity.y -= 4.0 * delta
