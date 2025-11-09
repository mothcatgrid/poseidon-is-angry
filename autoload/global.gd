extends Node
## The global autoload should manage gameplay-related globally accessible features,
## as well as access to all the different settings. It also interfaces settings to
## the current scene tree, for example letting the FOV setting target the actual camera.

signal game_setting_changed ## Emitted when a game setting changed internally, so options menu can update
signal system_setting_changed ## Emitted when a system setting changed internally, so options menu can update

enum DebugMode { MATCH_BUILD, FORCE_DEBUG, FORCE_RELEASE }

const AUDIO_BUS_MASTER = "Master"
const AUDIO_BUS_SOUND = "Sound"
const AUDIO_BUS_MUSIC = "Music"
# TODO Find a better way to get these
const RESOLUTIONS = [
		["CUSTOM", Vector2i(0,0)],
		["5120 x 1440", Vector2i(5120, 1440)],
		["3840 x 2160", Vector2i(3840, 2160)],
		["3440 x 1440", Vector2i(3440, 1440)],
		["2560 x 1600", Vector2i(2560, 1600)],
		["2560 x 1440", Vector2i(2560, 1440)],
		["1920 x 1200", Vector2i(1920, 1200)],
		["1920 x 1080", Vector2i(1920, 1080)],
		["1600 x 900", Vector2i(1600, 900)],
		["1440 x 900", Vector2i(1440, 900)],
		["1366 x 768", Vector2i(1366, 768)],
		["1280 x 800", Vector2i(1280, 800)],
		["1280 x 720", Vector2i(1280, 720)],
		["1024 x 768", Vector2i(1024, 768)],
	]

@export var debug_mode: DebugMode = DebugMode.MATCH_BUILD
## If enabled, save files will be in .tres format even if in release mode
@export var force_tres: bool = false

## Required to prevent resolution option changes being overwritten when the window resizes.
var block_resolution_change: bool = false 
## Set this when the player is interacting with a menu or something in-game
var block_player_input: bool = false
# ATTENTION These are global references to important objects. Whenver the scene changes, 
# they will become dangling pointers to freed objects. Ideally try to use accessor
# functions or signals instead of accessing these directly, otherwise check if_instance_valid
var hud: HUD = null
var fx: EffectsPool = null
# these should always be present, no need to check for null on access
var game_settings: GameSettingsFile = null
var system_settings: SystemSettingsFile = null
var player_data: PlayerDataFile = null
# check for null when accessing from autoloads, main menus, etc.
var save_game: SaveGameFile = null
# Only meant to be accessed by SaveGameFile - use init_save_game and then just read/write to save_game
var _save_game_index: int = 0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioServer.set_bus_layout(load("res://default_bus_layout.tres"))
	# prevents game from quitting until we handle notification - see _notification override
	get_tree().set_auto_accept_quit(false)
	var loaded_game_settings = GameSettingsFile.read()
	game_settings = loaded_game_settings if loaded_game_settings != null else GameSettingsFile.new()
	game_settings.external_apply_required.connect(_apply_external_game_setting.bind())
	game_settings.apply()
	
	var loaded_sys_settings = SystemSettingsFile.read()
	system_settings = loaded_sys_settings if loaded_sys_settings != null else SystemSettingsFile.new()
	system_settings.external_apply_required.connect(_apply_external_system_setting.bind())
	system_settings.apply()
	get_tree().root.size_changed.connect(_on_window_size_changed.bind())
	
	var loaded_player_data = PlayerDataFile.read()
	player_data = loaded_player_data if loaded_player_data != null else PlayerDataFile.new()
	player_data.apply()


func _input(event):
	# always listen for fullscreen toggle button
	if event.is_action_pressed("toggle_fullscreen", false):
		system_settings.fullscreen = !system_settings.fullscreen
		system_setting_changed.emit('fullscreen')


## Returns is_debug_build unless overridden in the global autoload scene export parameter.
func is_debug() -> bool:
	match debug_mode:
		DebugMode.FORCE_DEBUG:
			return true
		DebugMode.FORCE_RELEASE:
			return false
		_:
			return OS.is_debug_build()


## Call this to load or create a save file at the given index. 
func init_save_game(index: int):
	_save_game_index = index
	if save_game != null:
		# do any cleanup for game that was already loaded
		for connection in save_game.external_apply_required.get_connections():
			save_game.external_apply_required.disconnect(connection['callable'])
	# either load the existing save or create a new one
	var loaded_save = SaveGameFile.read()
	save_game = loaded_save if loaded_save != null else SaveGameFile.new()
	save_game.external_apply_required.connect(_apply_external_game_setting.bind())
	save_game.index = index
	save_game.apply()


## Call this to populate a list of games to choose from, then use init_save_game
## with the chosen save game's index.
func get_saved_games() -> Array[SaveGameFile]:
	var save_paths = null
	var save_games = []
	save_paths = Util.load_all_in_path("user://", "save_game", true)
	for path in save_paths:
		var loaded_save = load(path)
		if loaded_save is SaveGameFile:
			save_games.append(loaded_save)
	return save_games


func get_resolution_choices() -> Array:
	var res_choices = []
	var screen_size = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
	for res in RESOLUTIONS:
		if res[1].x <= screen_size.x and res[1].y <= screen_size.y:
			res_choices.append(res)
	return res_choices


func _get_window_res():
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		return "%sx%s" % [DisplayServer.window_get_size_with_decorations().x, DisplayServer.window_get_size_with_decorations().y]
	else:
		return "%sx%s" % [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y]


func _on_window_size_changed():
	if not block_resolution_change and system_settings.fullscreen == false:
		system_settings.resolution = get_tree().root.get_size()


func _apply_external_system_setting(setting: String, value: Variant):
	match setting:
		"render_scale":
			get_tree().root.scaling_3d_scale = float(value) / 100.0


func _apply_external_game_setting(setting: String, value: Variant):
	match setting:
		#"fov":
			#if camera != null:
				#camera.desired_fov = value
		pass


func _apply_external_save_game(setting: String, value: Variant):
	pass


# always save player data before quitting
func _notification(what: int):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		player_data.write()
		get_tree().quit()
