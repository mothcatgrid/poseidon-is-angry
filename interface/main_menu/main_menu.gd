extends Control

@onready var new_game_button = %NewGame
@onready var continue_button = %Continue
@onready var options_button = %Options
@onready var quit_button = %Quit
@onready var language_select = %LanguageButton
@onready var language_panel = %LanguagePanel
@onready var language_button_list = %LanguageButtonList
@onready var options_menu = %OptionsMenu


func _ready():
	# connect primary functions
	new_game_button.pressed.connect(_on_new_game_button_pressed.bind())
	continue_button.pressed.connect(_on_continue_button_pressed.bind())
	quit_button.pressed.connect(_on_quit_button_pressed.bind())
	language_panel.visibility_changed.connect(_on_language_visility_changed.bind())
	quit_button.pressed.connect(get_tree().quit.bind())
	# connect all language buttons
	for child in language_button_list.get_children():
		child.pressed.connect(_on_language_chosen.bind(child.name))
	# start the main menu music
	#Soundtrack.play_music(load("res://audio/music/Maple-Leaf-Rag.ogg"))
	# fix visibility
	$MainMenuVBox.visible = true
	language_panel.visible = false
	new_game_button.grab_focus()
	# mouse
	Controls.show_mouse = true


func _on_new_game_button_pressed():
	get_tree().change_scene_to_packed(load("res://stages/test_stage/test_stage.tscn"))


func _on_continue_button_pressed():
	get_tree().change_scene_to_packed(load("res://stages/test_stage/test_stage.tscn"))


func _on_quit_button_pressed():
	pass


func _on_language_chosen(locale: String):
	Global.game_settings.language_override = locale
	_update_button_toggle()


func _on_language_visility_changed():
	if language_panel.visible:
		_update_button_toggle()

func _update_button_toggle():
	for child in language_button_list.get_children():
		child.button_pressed = child.name == TranslationServer.get_locale()
