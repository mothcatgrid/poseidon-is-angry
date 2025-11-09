class_name BaseState
## Base state class for state machine, with methods intended to be overwritten.

## used automatically to signal the state machine this state is in
signal requested_state_change 

## string identifier for the state
var state_name: String


## Called when this state is first entered
func _on_enter(previous_state: BaseState):
	pass


## Generally called every frame or physics frame
func _on_update(delta: float):
	pass


## Called when leaving this state
func _on_exit(next_state: BaseState):
	pass


func change_to_state(new_state_name: String):
	requested_state_change.emit(new_state_name)
