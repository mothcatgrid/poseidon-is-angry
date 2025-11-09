class_name PoolEffect
extends Node3D
## This is a pooled special effect - add any sound or particle effect nodes as children.
## Use the effects pooler to create the effect.

signal was_reset(effect: PoolEffect, active: bool)


@export var effect_id: String ## Referenced to spawn the effect
@export var max_instances: int = -1 ## Maximum instances of the effect
@export var lazy: bool = true ## Instance a new effect only when needed - good for effects with high caps
@export var prioritize_new: bool = true ## Will force reset oldest live effect to create a new one if pool is already maxed out
@export var set_lifetime: float = 1.0 ## How long before the effect despawns automatically

@export_category("Visual Settings")
@export var max_player_distance: float = -1.0 ## Will not spawn effect if distance to player is greater than this.
@export var max_repeat_distance: float = -1.0 ## TODO Implement a check to prevent playing the same effect right next to another one
@export var randomize_z_rotation: bool = false
@export var fix_z_fighting: bool = false

var lifetime = 0.0
var life_timer = 0.0

## used by effects pool to make a linked list for grabbing oldest active effect
var next_effect: PoolEffect = null
var prev_effect: PoolEffect = null

var do_sound: bool = false ## used by effects pool to automatically prevent excessive repeated sounds
var is_active = false
var initial_audio_pitch = [] ## saves the initial pitch for each sound so it can add minor variance


func _ready():
	# Save initial pitch for pitch variance
	for child in self.get_children():
		if child is AudioStreamPlayer3D:
			initial_audio_pitch.append(child.pitch_scale)


func _physics_process(delta):
	life_timer += delta
	if life_timer >= lifetime:
		reset(false)


## Called to activate the node, or put it away in the pool
func reset(active):
	var audio_index = 0
	for child in self.get_children():
		if child is GPUParticles3D:
			child.restart()
			child.emitting = active
		if child is AudioStreamPlayer3D:
			if active and do_sound:
				child.pitch_scale = initial_audio_pitch[audio_index] + randf_range(-0.2, 0.2)
				child.play(0.0)
				audio_index += 1
			else:
				child.stop()
	
	if fix_z_fighting:
		global_position += global_basis.z * randf_range(-0.001, 0.001)
	
	if randomize_z_rotation:
		rotate(basis.z.normalized(), randf_range(0.0, PI))
	
	life_timer = 0.0
	lifetime = set_lifetime
	visible = active
	# Lifetime set to negative value means infinite
	set_physics_process(active and lifetime > 0.0)
	# Make sure to emit before setting is_active flag
	was_reset.emit(self, active)
	is_active = active


# since effects will often become children of random stuff, prevent themselves from 
# being deleted and reset instead
# NOTICE i dont know if this works just keeping in case it might
#func _notification(what: int) -> void:
	#match what:
		#NOTIFICATION_PREDELETE:
			#cancel_free()
			#reparent(Global.fx, false)
			#reset(false)
