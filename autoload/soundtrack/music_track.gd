class_name MusicTrack
extends Resource
## For the framework this only serves as a way to keep track of songs that should be toggleable
## for streamers and content creators. It could be easily extended to add other attributes to
## music for dynamic soundtracks, etc.

## The ID used to access this track and request it to be played.
@export var track_id: String = ""
## In case a nice name of the track needs to be shown (ost, unlockable, etc).
@export var name: String = ""
## The actual audio stream to be played.
@export var stream: AudioStream
## Set to true if this song should be disabled for streamers/youtube videos.
@export var is_copyright_protected: bool = false
## An optional fallback track to be used if the current track is blocked due to copyright.
@export var fallback: MusicTrack
