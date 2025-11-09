@tool
extends BaseOption
## An option that allows a sliding value and type in the value

const KEY_HOLD_WAIT: float = 0.35
const KEY_HOLD_INTERVAL: float = 0.05

@export var value_min: float = 0
@export var value_max: float = 100.0
@export var value_step: float = 1.0

@onready var label: Label = %Label
@onready var h_slider: HSlider = %HSlider
@onready var spin_box: SpinBox = %SpinBox
@onready var range_linker: RangeLinker = %RangeLinker

var key_hold: float = 0.0
var hold_active: bool = false


func _ready():
	super()
	if not Engine.is_editor_hint():
		label.text = option_text
		
		h_slider.min_value = value_min
		h_slider.max_value = value_max
		h_slider.step = value_step
		
		# don't set spin box step so manual entry can be exact
		spin_box.min_value = value_min
		spin_box.max_value = value_max
		# disable right click menu
		var line_edit = spin_box.get_line_edit()
		line_edit.context_menu_enabled = false
		
		range_linker.value_changed.connect(_on_slider_value_changed.bind())
		_sync_value()


func _process(delta):
	if has_focus():
		if Input.is_action_just_pressed("ui_left"):
			h_slider.value -= h_slider.step
			key_hold = 0.0
			hold_active = false
		if Input.is_action_just_pressed("ui_right"):
			h_slider.value += h_slider.step
			key_hold = 0.0
			hold_active = false
		
		if Input.is_action_pressed("ui_left"):
			key_hold += delta
			if not hold_active:
				if key_hold > KEY_HOLD_WAIT:
					hold_active = true
					key_hold = 0.0
			elif key_hold > KEY_HOLD_INTERVAL:
				h_slider.value -= h_slider.step
				key_hold = 0.0
		
		if Input.is_action_pressed("ui_right"):
			key_hold += delta
			if not hold_active:
				if key_hold > KEY_HOLD_WAIT:
					hold_active = true
					key_hold = 0.0
			elif key_hold > KEY_HOLD_INTERVAL:
				h_slider.value += h_slider.step
				key_hold = 0.0


func _on_slider_value_changed(new_value: float):
	_set_value(new_value)


func _sync_value():
	range_linker.set_value(_get_value())
