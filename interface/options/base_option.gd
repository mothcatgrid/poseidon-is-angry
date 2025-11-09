@tool
class_name BaseOption
extends Button
## A wrapper for any options, allows communicating any selections the 
## player has made through signals and easily adding new options.

enum OptionType { SYSTEM, GAME }

@export var option_text: String = "":
	set(val):
		%Label.text = val
		option_text = val
	get:
		return option_text

@export var option_identifier: String = ""
@export var option_type: OptionType


func _ready():
	if not Engine.is_editor_hint():
		Global.game_setting_changed.connect(_on_game_setting_changed.bind())
		Global.system_setting_changed.connect(_on_system_setting_changed.bind())
		## this will both sync the UI option with the setting as well as apply the setting
		_set_value(_get_value())


func _set_value(new_value) -> void:
	_access_setting(option_identifier, new_value)


func _get_value() -> Variant:
	return _access_setting(option_identifier)


## Set a setting to a given value. Leave value null to get the current setting value instead
func _access_setting(property: String, value: Variant = null) -> Variant:
	match option_type:
		OptionType.SYSTEM:
			if property in Global.system_settings:
				if value != null:
					Global.system_settings.set(property, value)
				else:
					return Global.system_settings.get(property)
			else:
				push_error("Could not find system setting: " + property)
		OptionType.GAME:
			if property in Global.game_settings:
				if value != null:
					Global.game_settings.set(property, value)
				else:
					return Global.game_settings.get(property)
			else:
				push_error("Could not find game setting: " + property)
	return null


## a game setting changed internally so check if this option needs to sync with it
func _on_game_setting_changed(setting_id: String):
	if setting_id == option_identifier:
		_sync_value()


## a system setting changed internally so check if this option needs to sync with it
func _on_system_setting_changed(setting_id: String):
	if setting_id == option_identifier:
		_sync_value()


## meant to be overriden to make the UI element sync to the current settings value
func _sync_value():
	pass
