extends Node
## Handles the background music and enables controlling it from anywhere. 

## A map of track_id -> music track resource.
var _track_map: Dictionary = {}

@onready var primary_player = $PrimaryTrackPlayer


func _ready():
	primary_player.finished.connect(_on_primary_player_finished.bind())
	process_mode = Node.PROCESS_MODE_ALWAYS
	# populate the dictionary
	#for track_path in Util.load_all_in_path("res://autoload/soundtrack/tracks/", ".tres"):
		#var music: MusicTrack = load(track_path)
		#_track_map[music.track_id] = music


func play_track(track_id: String) -> bool:
	var track: MusicTrack = _track_map.get(track_id, null)
	if track:
		if Global.game_settings.allow_copyright_music or not track.is_copyright_protected:
			primary_player.stream = track.stream
		elif track.fallback:
			primary_player.stream = track.fallback.stream
		else:
			return false
		primary_player.playing = true
		return true
	else:
		return false


func stop_music():
	primary_player.playing = false


func _on_primary_player_finished():
	pass
