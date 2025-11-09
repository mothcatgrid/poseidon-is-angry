class_name EffectsPool
extends Node3D
## Pooling node for all the special FX. This allows configuration of max number of each type of 
## effect playing at once. You can freely spawn effects as needed and if the pool can't handle it, 
## it just won't appear. Effects are created as children of this effects pool.

var _pooled_effects = {}


func _ready():
	Global.fx = self
	# Automatically load in from the pooleffects folder, all the effects and their config
	for effect_path in Util.load_all_in_path("res://effects/", ".tscn", true):
		# Make an instance of the effect to access its settings
		var effect_scene = load(effect_path)
		var effect_instance: PoolEffect = effect_scene.instantiate()
		var id = effect_instance.effect_id
		_pooled_effects[id] = {}
		_pooled_effects[id]['scene'] = effect_scene
		_pooled_effects[id]['max_instances'] = effect_instance.max_instances
		_pooled_effects[id]['lazy'] = effect_instance.lazy
		_pooled_effects[id]['prioritize_new'] = effect_instance.prioritize_new
		_pooled_effects[id]['max_player_distance'] = effect_instance.max_player_distance
		_pooled_effects[id]['pool'] = []
		_pooled_effects[id]['inactive'] = []
		_pooled_effects[id]['oldest_effect'] = null
		_pooled_effects[id]['newest_effect'] = null
		_pooled_effects[id]['sound_played_frames_ago'] = 99
		effect_instance.queue_free()
	# Create the instances of effects
	for key in _pooled_effects.keys():
		if _pooled_effects[key]['lazy'] == false:
			for i in range(_pooled_effects[key]['max_instances']):
				_instance_effect(key)
		else:
			# At least start off every effect with 1 to reduce stutters
			_instance_effect(key)


## Call to spawn a special effect somewhere
func spawn_effect(effect_name: String, spawn_position: Vector3, spawn_normal: Vector3, args: Dictionary = {}) -> PoolEffect:
	var dict = _pooled_effects[effect_name]
	var effect_instance = null
	
	# Do not even attempt to spawn if over distance
	if dict['max_player_distance'] > 0.0:
		if Global.get_player_pos().distance_to(spawn_position) > dict['max_player_distance']:
			return null
	
	# Attempt to grab next inactive effect
	if dict['inactive'].size() > 0:
		effect_instance = dict['inactive'].pop_back()
	else:
		# Create a new inactive one if needed and allowed
		if dict['lazy'] == true and (dict['pool'].size() < dict['max_instances'] or dict['max_instances'] == -1):
			_instance_effect(effect_name)
		# Deactivate the oldest one if needed and allows
		elif dict['prioritize_new'] and dict['oldest_effect'] != null:
			dict['oldest_effect'].reset(false)
		# Attempt to grab inactive one more time, now that it might have a new entry
		if dict['inactive'].size() > 0:
			effect_instance = dict['inactive'].pop_back()
	
	# Kick off the effect instance
	if effect_instance != null:
		effect_instance.global_position = spawn_position
		Util.fixed_look_at(effect_instance, spawn_position + spawn_normal)
		for arg in args.keys():
			effect_instance.set(arg, args[arg])
		
		# Play the sound if it was played > 1 frames ago
		if dict['sound_played_frames_ago'] > 1:
			dict['sound_played_frames_ago'] = 0
			effect_instance.do_sound = true
		else:
			effect_instance.do_sound = false
		
		effect_instance.reset(true)
	return effect_instance


## Call to create a new instance of the effect
func _instance_effect(effect_id: String) -> PoolEffect:
	var inst: PoolEffect = _pooled_effects[effect_id]['scene'].instantiate()
	inst.name = effect_id + str(_pooled_effects[effect_id]['pool'].size())
	add_child(inst)
	_pooled_effects[effect_id]['pool'].append(inst)
	_pooled_effects[effect_id]['inactive'].append(inst)
	inst.was_reset.connect(_on_effect_reset.bind())
	inst.reset(false)
	return inst


func _physics_process(delta):
	for effect_key in _pooled_effects.keys():
		_pooled_effects[effect_key]['sound_played_frames_ago'] += 1


func _on_effect_reset(effect: PoolEffect, active: bool):
	var dict = _pooled_effects[effect.effect_id]
	if active and not effect.is_active:
		# Activating instance - add to front of linked list
		if dict['oldest_effect'] == null:
			dict['oldest_effect'] = effect
		else:
			dict['newest_effect'].next_effect = effect
			effect.prev_effect = dict['newest_effect']
		dict['newest_effect'] = effect
	elif not active and effect.is_active:
		# Deactivating instance - remove from linked list
		if effect.prev_effect:
			effect.prev_effect.next_effect = effect.next_effect
		if effect.next_effect:
			effect.next_effect.prev_effect = effect.prev_effect
		if dict['newest_effect'] == effect:
			dict['newest_effect'] = effect.prev_effect
		if dict['oldest_effect'] == effect:
			dict['oldest_effect'] = effect.next_effect
		effect.next_effect = null
		effect.prev_effect = null
		
		_pooled_effects[effect.effect_id]["inactive"].append(effect)
