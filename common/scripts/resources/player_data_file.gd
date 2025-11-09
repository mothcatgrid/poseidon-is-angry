class_name PlayerDataFile
extends SavedResource
## Player data file that is cloud synced. Should save all the player's progress,
## gameplay stats, and achievement progress. If one player needs to have multiple
## save games, those games should be saved as SaveGameFiles.

## All keys for achievements the player has unlocked.
@export var unlocked_achievements: Array[String] = []
## All the player stats mapped to their corresponding value.
@export var stats: Dictionary = {}


func apply():
	pass


#region file access
static func get_save_path() -> String:
	var path := ""
	# save as .res file in production to remove temptation to easily cheat
	var extension := ".tres" if Global.is_debug() or Global.force_tres else ".res"
	var save_name := "player_dat"
	path = 'user://' + save_name + extension
	return path
# TODO disable this and let the super method handle it once the static override bug is fixed
static func read() -> PlayerDataFile:
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
