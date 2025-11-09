class_name SavedResource
extends Resource
## Base class for things like settings, save games, etc. Meant to be overriden with
## the specific file path and any other features, but shares the save/load mechanism.
## The static read() and write() functions allow it to be easily accessed from anywhere.
## If you need multiple instances of a type of file, use external dynamic variables 
## like steam_user_id or a save game index, and use them in the get_save_path function.

## Emitted when an option that can't be changed in-resource needs to be applied
signal external_apply_required(identifier: String, value: Variant)

# TODO re-enable this once the bug with not being able to override static functions is fixed.
## Must be overridden with the path to load or save this file type.
#static func get_save_path() -> String:
	#return ""


# TODO re-enable this once the bug with not being able to override static functions is fixed.
## Will return the resource (if found) from the file at get_save_path()
#static func read() -> SavedResource:
	#var path = get_save_path()
	#if ResourceLoader.exists(path):
		#var save_file = ResourceLoader.load(path)
		#return save_file
	#else:
		#return null

# TODO re-enable this once the bug with not being able to override static functions is fixed.
## Will save this resource to a file at get_save_path().
#func write() -> void:
	#ResourceSaver.save(self, get_save_path())


## Called when the file is loaded to apply any settings or data to the running game.
func apply():
	pass
