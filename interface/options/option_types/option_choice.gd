@tool
class_name OptionChoice
extends BaseOption
## An option that allows choosing one of a series of choices. Provide the method 
## name located in the Global autoload that returns an array of tuples, where index 
## 0 is the label and index 1 is the value of the choice.

@export var get_choices_method: String = ""

## choices should be an array, index 0 is text, index 1 is option value
var choices = null

@onready var label: Label = %Label
@onready var choice_button: OptionButton = %ChoiceButton


func _ready():
	super()
	if not Engine.is_editor_hint():
		label.text = option_text
		generate_choices()
		choice_button.item_selected.connect(_on_choice_selected.bind())
		_sync_value()


func generate_choices():
	if Global.has_method(get_choices_method):
		choices = Global.call(get_choices_method)
	else:
		push_error("Could not find method " + get_choices_method + " in Global")
	for choice in choices:
		choice_button.add_item(choice[0])


func _on_choice_selected(item: int):
	_access_setting(option_identifier, choices[item][1])


func _sync_value():
	var choice_values_only = choices.map(func(choice): return choice[1])
	choice_button.selected = choice_button.get_item_index(choice_values_only.find(_get_value()))
