extends Node
class_name RangeLinker

@export_node_path("Range") var range_1_path
@export_node_path("Range") var range_2_path

@onready var range_1: Range = get_node(range_1_path)
@onready var range_2: Range = get_node(range_2_path)

signal value_changed


func _ready():
	range_1.value_changed.connect(_on_range_value_changed.bind())
	range_2.value_changed.connect(_on_range_value_changed.bind())


func set_value(new_value):
	range_1.value = new_value
	range_2.value = new_value


func _on_range_value_changed(value):
	if range_1.value != value:
		range_1.value = value
	if range_2.value != value:
		range_2.value = value
	value_changed.emit(value)
