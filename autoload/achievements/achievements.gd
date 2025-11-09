extends Control
## This is the achievement manager that should be listening for any activity needed to track achievements
## as well as submitting that information where it needs to go, like to the SteamIntegration. It doubles
## as a UI component so it can show achievement notifications between scene changes, independent of gameplay.
##
## Achievements don't need to be linked to steam and they can be used to simply track unlocks or progress
## towards internal game rewards as well, but they are player data level, not per save game.

## Allows the rest of the game to react to an achievement being unlocked.
signal achievement_unlocked(achievement_id: String)
signal achievement_removed(achievement_id: String)

# Maps an achievement ID to the achievement resource. 
var _achievement_map: Dictionary = {}
# Map a stat key to an achievement, for checking if unlocked
var _stat_player_achieve_map: Dictionary = {}
var _stat_game_achieve_map: Dictionary = {}
# Queue to let multiple achievements in a short time play out
var _anim_queue = []

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	# populate the dictionaries
	for ach_path in Util.load_all_in_path("res://autoload/achievements/", ".tres"):
		var ach: AchievementResource = load(ach_path)
		_achievement_map[ach.id] = ach
		# add unachieved to quick lookup dictionary
		if not is_achieved(ach.id):
			# double check any unachieved values to verify still not earned
			if not _is_goal_achieved(ach):
				if ach.stat_location == Stats.Location.PLAYER_DATA:
					if _stat_player_achieve_map.has(ach.stat):
						_stat_player_achieve_map[ach.stat].append(ach)
					else:
						_stat_player_achieve_map[ach.stat] = [ach]
				elif ach.stat_location == Stats.Location.CURRENT_SAVE:
					if _stat_game_achieve_map.has(ach.stat):
						_stat_game_achieve_map[ach.stat].append(ach)
					else:
						_stat_game_achieve_map[ach.stat] = [ach]
			else:
				# goal met just didn't record achievement, record again
				_unlock_achievement(ach.id)
	Events.player_stat_updated.connect(_on_player_stat_updated)
	Events.game_stat_updated.connect(_on_game_stat_updated)
	anim_player.animation_finished.connect(_on_anim_player_complete.bind())


## Check if the specific achievement is unlocked.
func is_achieved(id: String) -> bool:
	return id in Global.player_data.unlocked_achievements


## Get the full achievement information from the key
func get_achievement(id: String) -> AchievementResource:
	return _achievement_map.get(id, null)


# check for achievements unlocked in the player data scope
func _on_player_stat_updated(key: Stats.Key, value: Variant):
	for ach: AchievementResource in _stat_player_achieve_map.get(key, []):
		if int(value) >= ach.goal_value:
			_unlock_achievement(ach.id)


# check for achievements unlocked in the save game scope
func _on_game_stat_updated(key: Stats.Key, value: Variant):
	for ach: AchievementResource in _stat_game_achieve_map.get(key, []):
		if int(value) >= ach.goal_value:
			_unlock_achievement(ach.id)


# independently test an achievement for its achieve condition outside of stat change events
func _is_goal_achieved(achievement: AchievementResource) -> bool:
	match achievement.stat_location:
		Stats.Location.PLAYER_DATA:
			return int(Global.player_data.stats.get(achievement.stat, 0)) >= achievement.goal_value
		Stats.Location.CURRENT_SAVE:
			return int(Global.save_game.stats.get(achievement.stat, 0)) >= achievement.goal_value
		_:
			return false


func _unlock_achievement(id: String):
	if not is_achieved(id):
		Global.player_data.unlocked_achievements.append(id)
		Global.player_data.write()
		achievement_unlocked.emit(id)
		# these maps are used for testing completion so just remove
		_stat_player_achieve_map.erase(id)
		_stat_game_achieve_map.erase(id)
		if _achievement_map[id].notify:
			if not anim_player.is_playing():
				_play_achievement(id)
			else:
				_anim_queue.append(id)


# for debugging
func _remove_achievement(id: String):
	if is_achieved(id):
		var index = Global.player_data.unlocked_achievements.find(id)
		if index != -1:
			Global.player_data.unlocked_achievements.remove_at(index)
			Global.player_data.write()
			achievement_removed.emit(id)


# Plays the in-game visual notification for achievement
func _play_achievement(id: String):
	var ach: AchievementResource = _achievement_map[id]
	%AchieveTitle.text = ach.title
	%AchieveTexture.texture = ach.achieved_icon
	%AchieveDesc.text = ach.description
	anim_player.play("OnUnlockAchievement")


func _on_anim_player_complete(_anim_name):
	if _anim_queue.size() > 0:
		_play_achievement(_anim_queue.pop_front())
