extends Control
## Handles a debug overlay that is always available. Should never be referenced
## directly, always self-contained or listening to signals when needed. Also handles
## console commands.
##
## To add a new console command, add its metadata to the command dictionary below,
## and make sure the callable is set. You can just point to a function anywhere, but
## often you'll want a wrapper function here to write an error properly to the console gui.

var COMMANDS = {
	'achieve': {
		'callable': cmd_achieve.bind(),
		'arg_count': 1,
		'help': 'arg1: An achievement ID to add to player data & Steam.'
	},
	'unachieve': {
		'callable': cmd_unachieve.bind(),
		'arg_count': 1,
		'help': 'arg1: An achievement ID to remove from player data & Steam.'
	},
	'game_set': {
		'callable': cmd_opt_set.bind(BaseOption.OptionType.GAME),
		'arg_count': 2,
		'help': 'arg1: A system setting property name to modify | arg2: The new property value'
	},
	'sys_set': {
		'callable': cmd_opt_set.bind(BaseOption.OptionType.SYSTEM),
		'arg_count': 2,
		'help': 'arg1: A system setting property name to modify | arg2: The new property value'
	},
	'play_track': {
		'callable': cmd_track.bind(true),
		'arg_count': 1,
		'help': 'arg1: The track id to play'
	},
	'stop_track': {
		'callable': cmd_track.bind('', false),
		'arg_count': 0,
		'help': 'Stops the current track playing'
	}
}

@onready var console_container: Control = %ConsoleContainer
@onready var console: LineEdit = %Console
@onready var console_msg: Label = %ConsoleLabel
@onready var debug_ui: Control = $DebugUI
@onready var tab_toggle: Button = %ToggleTabs
@onready var tab_container: TabContainer = %TabContainer


func _ready():
	#if not Global.is_debug():
		#self.visible = false
		#process_mode = Node.PROCESS_MODE_DISABLED
	process_mode = Node.PROCESS_MODE_ALWAYS
	toggle_debug_ui(false)
	tab_container.visible = false
	
	Controls.device_changed.connect(_on_input_device_changed)
	console.text_submitted.connect(_on_console_submit.bind())
	tab_toggle.pressed.connect(_on_toggle_tabs.bind())


func _process(_delta):
	%FPS.text = str(Engine.get_frames_per_second()) + ' FPS'


func _input(event):
	if Controls.is_input_valid_binding(event):
		$InputInfo.text = Controls.get_label_for_input(event, Controls.device)
		$InputPrompt.set_texture_to_input(event, Controls.device)



func toggle_debug_ui(enable: bool):
	debug_ui.visible = enable
	Controls.show_mouse = enable
	Global.block_player_input = enable
	if enable:
		console.grab_focus()


func _on_input_device_changed(device: String, device_index: int) -> void:
	$InputDeviceLabel.text = device


func _on_console_submit(string: String):
	console.clear()
	console_msg.text = ''
	
	var tokens = Array(string.split(' '))
	var command_string = tokens.pop_front()
	var command = COMMANDS.get(command_string, null)
	if command != null:
		if command['arg_count'] == tokens.size():
			var cmd_result = command['callable'].callv(tokens)
			if cmd_result != null:
				_message_console(str(cmd_result), Color.CYAN)
		else:
			_message_console('%s usage: %s' % [command_string, command['help']], Color.YELLOW)
	else:
		_message_console('Command "%s" not found.' % command_string, Color.YELLOW)


func _on_toggle_tabs():
	tab_container.visible = !tab_container.visible


func _message_console(msg: String, color: Color):
	console_msg.text = msg
	console_msg.modulate = color

#region === CONSOLE COMMANDS ===

func cmd_achieve(id: String):
	if Achievements.get_achievement(id) != null:
		Achievements._unlock_achievement(id)
	else:
		_message_console(id + " is not an achievement id", Color.RED)


func cmd_unachieve(id: String):
	if Achievements.get_achievement(id) != null:
		Achievements._remove_achievement(id)
	else:
		_message_console(id + " is not an achievement id", Color.RED)


func cmd_opt_set(property: String, value: Variant, location: BaseOption.OptionType):
	if location == BaseOption.OptionType.GAME:
		if property in Global.game_settings:
			var casted_value
			match typeof(Global.game_settings.get(property)):
				TYPE_BOOL:
					casted_value = bool(value)
				TYPE_INT:
					casted_value = int(value)
				TYPE_FLOAT:
					casted_value = float(value)
			Global.game_settings.set(property, casted_value)
		else:
			_message_console('No property "%s" in %s' % [property, "game settings"] , Color.RED)
	if location == BaseOption.OptionType.SYSTEM:
		if property in Global.system_settings:
			var casted_value
			match typeof(Global.system_settings.get(property)):
				TYPE_BOOL:
					casted_value = bool(value)
				TYPE_INT:
					casted_value = int(value)
				TYPE_FLOAT:
					casted_value = float(value)
			Global.system_settings.set(property, casted_value)
		else:
			_message_console('No property "%s" in %s' % [property, "system settings"] , Color.RED)


func cmd_track(track_id: String, play: bool):
	if play:
		SoundTrack.play_track(track_id)
		return "playing " + track_id
	else:
		SoundTrack.stop_music()
		return "music stopped"

#endregion
