class_name GameSettingsFile
extends SavedResource
## Save game resource that is cloud synced. Use for game settings, key bindings,
## and anything else that the user would always want to keep regardless of device.

@export var language_override: String = "":
	set(value):
		language_override = value
		TranslationServer.set_locale(value)
		write()

@export var mouse_sensitivity: float = 50.0:
	set(value):
		mouse_sensitivity = value
		write()

@export var look_sensitivity: float = 3.0:
	set(value):
		look_sensitivity = value
		write()

@export var bindings: String = "{}":
	set(value):
		bindings = value
		write()

@export var fov: float = 90.0:
	set(value):
		fov = value
		external_apply_required.emit("fov", fov)
		write()

@export var crouch_toggle: bool = true:
	set(value):
		crouch_toggle = value
		write()

@export var allow_copyright_music: bool = true:
	set(value):
		allow_copyright_music = value
		write()


func apply():
	TranslationServer.set_locale(language_override)
	Controls.deserialize_inputs_for_actions(bindings)


#region file access
static func get_save_path() -> String:
	var path := ""
	var extension := ".tres"
	path = 'user://settings' + extension
	return path

# TODO disable this and let the super method handle it once the static override bug is fixed
static func read() -> GameSettingsFile:
	var path = get_save_path()
	if ResourceLoader.exists(path):
		var save_file = ResourceLoader.load(path)
		return save_file
	else:
		return null

# TODO disable this and let the super method handle it once the static override bug is fixed
func write() -> void:
	ResourceSaver.save(self, get_save_path())
#endregion
