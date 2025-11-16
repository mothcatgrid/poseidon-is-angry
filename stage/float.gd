@tool
extends Node3D

@export var top: Node3D
@export var bot: Node3D
@export var particle: GPUParticles3D

@export var floater_height: float = 4.0:
	set(value):
		if top and bot:
			top.position.y = value * 0.5
			bot.position.y = value * -0.5
		floater_height = value

var is_submerged: bool = false
var submerge_prop: float = 0.0

func _ready() -> void:
	if not Engine.is_editor_hint():
		particle.emitting = true

# the float provides a water level reading - 0 means not touching any water, 1 means fully submerged
# place the float at each corner of the vessel
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		var bot_submerged = bot.global_position.y - Global.ocean.get_wave(global_position.x, global_position.z).y
		submerge_prop = clamp(abs(bot_submerged) / floater_height, 0.0, 1.0) if bot_submerged < 0.0 else 0.0
		particle.amount_ratio = submerge_prop
