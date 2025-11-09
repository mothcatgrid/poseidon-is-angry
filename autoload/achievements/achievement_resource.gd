class_name AchievementResource
extends Resource
## Create an achievement resource for any achievement, and point it to a stat_id
## to track the value. Set the goal value and everything else is handled automatically.

## The ID used to reference the achievement
@export var id = ""
## The ID of the stat (Stats autoload) to read for completion
@export var stat: Stats.Key
## Achievement will unlock once the stat meets/exceeds this value. Stats do not 
## need to be ints, but they will be cast to int and then compared to goal_value.
@export var goal_value: int = 0
## The location of the stat to read
@export var stat_location: Stats.Location = Stats.Location.PLAYER_DATA
## Should match the achievement's api_name defined in SteamWorks.
@export var steam_api_name = ""

# NOTE The following settings only used if the achievement is visible in-game.
@export_group("In-Game")
## Should in-game notification appear
@export var notify: bool = false
## The display name for this achievement.
@export var title: String = ""
## The description for this achievement.
@export var description: String = ""
## 256x256 texture in full color shown when achieved.
@export var achieved_icon: Texture2D
## 256x256 grayscale texture shown when locked/hidden.
@export var unachieved_icon: Texture2D
