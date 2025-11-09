class_name StateMachine
## Generic state machine that should fit any use case

signal state_changed(state_name: String)

var subject: Variant
var current_state: BaseState = null
var next_state_name: String = ""
var states = {} ## state name string -> state object instance
var machine_name: String


func _init(assigned_subject, sm_name):
	subject = assigned_subject
	machine_name = sm_name


## Add a new state to the machine, subscribe to signals
func add_state(state: BaseState):
	states[state.state_name] = state
	state.requested_state_change.connect(_set_requested_state.bind())


## Run update function for the active state
func update_machine(delta):
	if current_state:
		current_state._on_update(delta)
	if next_state_name != "":
		set_state(next_state_name)


## Performs the transition from current to next state
func set_state(new_state_name: String):
	var next_state = states[new_state_name]
	if current_state:
		current_state._on_exit(next_state)
	next_state._on_enter(current_state)
	current_state = next_state
	state_changed.emit(current_state.state_name)
	next_state_name = ""


## Return the name of the current state
func get_active_state():
	return current_state.state_name


## Return the names of all states in this machine
func get_all_states():
	return states.keys()


## Simply tracks the next state name so the transition can occur in order
func _set_requested_state(requested_state_name: String):
	next_state_name = requested_state_name
