class_name Stats
extends Node
## Contains constants and static functions to simplify tracking various player stats.
## The stats themselves are saved in player data and save game files. Some fairly inexpensive
## checks and signals will be done every time a stat changes, so 


## Used to distinguish between the two locations for a single stat.
enum Location {
	PLAYER_DATA,
	CURRENT_SAVE
}

## All of the different stats that can be tracked.
enum Key {
	WIN_COUNT,
	DISTANCE_TRAVELED,
	DID_THING
}


## Set the stat to a specific value.
static func set_stat(key: Stats.Key, value: Variant) -> void:
	Global.player_data.stats[key] = value
	Events.player_stat_updated.emit(key, value)
	if Global.save_game:
		Global.save_game.stats[key] = value
		Events.game_stat_updated.emit(key, value)


## Adds the value to the current stat count, or initializes if not yet.
static func add_stat(key: Stats.Key, value: Variant) -> void:
	var existing = get_stat(key)
	if existing != null:
		if typeof(existing) == typeof(value):
			set_stat(key, existing + value)
		else:
			push_error("Value type mismatch on adding %s to stat key %s" % 
					[type_string(typeof(value)), Key.keys()[key]])
	else:
		set_stat(key, value)


## Retrieve the value of the given stat from given location, returns null if the stat is not found.
static func get_stat(key: Stats.Key, location: Location = Location.PLAYER_DATA) -> Variant:
	match location:
		Location.PLAYER_DATA:
			return Global.player_data.stats.get(key, null)
		Location.CURRENT_SAVE:
			if Global.save_game:
				return Global.save_game.stats.get(key, null)
	return null
