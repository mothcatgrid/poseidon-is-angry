class_name SaveGameFile
extends SavedResource
## Save game resource that is cloud synced for game progress. Use the init_save_game
## function in global to create or load.

## Set when created, and used to identify this file when chosen for loading.
@export var index: int = -1:
	set(value):
		index = value
		write()
## Timestamp of the last time modified, automatically set.
@export var timestamp: int = 0
## All the player's stats for this save mapped to their corresponding value.
@export var stats: Dictionary = {}


func apply():
	pass


#region file access
static func get_save_path() -> String:
	var path := ""
	# save as .res file in production to remove temptation to easily cheat
	var extension := ".tres" if Global.is_debug() or Global.force_tres else ".res"
	var save_name := "savegame_" + str(Global._save_game_index)
	path = 'user://' + save_name + extension
	return path

# TODO disable this and let the super method handle it once the static override bug is fixed
static func read() -> SaveGameFile:
	var path = get_save_path()
	if ResourceLoader.exists(path):
		var save_file = ResourceLoader.load(path)
		return save_file
	else:
		return null

# TODO disable this and let the super method handle it once the static override bug is fixed
func write() -> void:
	timestamp = int(Time.get_unix_time_from_system())
	ResourceSaver.save(self, get_save_path())
#endregion
