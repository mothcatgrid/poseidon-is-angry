class_name SystemSettingsFile
extends SavedResource
## The system settings file is not cloud-synced. Things like display and 
## audio settings should be handled here. Anything else that a user would want
## to change between systems.

@export var master_volume: float = 50.0:
	set(value):
		master_volume = value
		_set_volume(Global.AUDIO_BUS_MASTER, value)

@export var sound_volume: float = 50.0:
	set(value):
		sound_volume = value
		_set_volume(Global.AUDIO_BUS_SOUND, value)

@export var music_volume: float = 50.0:
	set(value):
		music_volume = value
		_set_volume(Global.AUDIO_BUS_MUSIC, value)

@export var subtitles: bool = false:
	set(value):
		subtitles = value
		write()

@export var fullscreen: bool = true:
	set(value):
		fullscreen = value
		_update_window_mode()
		write()

@export var vsync: bool = true:
	set(value):
		vsync = value
		if vsync:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		else:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		write()

@export var resolution: Vector2i = Vector2i(1280, 720):
	set(value):
		resolution = value
		if not fullscreen and not Engine.is_embedded_in_editor(): # prevents flickering on scene change
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(resolution)
			Util.center_window()
		write()

@export var frame_limit: int = 0:
	set(value):
		frame_limit = value
		Engine.max_fps = frame_limit
		write()

@export var render_scale: int = 100:
	set(value):
		render_scale = value
		external_apply_required.emit("render_scale", render_scale)
		write()


func _set_volume(bus_name: String, new_volume: float):
	var actual_bus_volume = linear_to_db(new_volume / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), actual_bus_volume)
	write()


## Called by the fullscreen and borderless options to update the window accordingly
func _update_window_mode():
	Global.block_resolution_change = true
	if fullscreen and not Engine.is_embedded_in_editor():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		resolution = resolution
	Global.block_resolution_change = false


func apply():
	pass


#region file access
static func get_save_path() -> String:
	# saves to a file outside of the user's cloud synced folder
	var path = ""
	path = 'user://system_settings.tres'
	return path

# TODO disable this and let the super method handle it once the static override bug is fixed
static func read() -> SystemSettingsFile:
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
