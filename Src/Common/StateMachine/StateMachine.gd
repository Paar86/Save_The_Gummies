class_name StateMachine extends Node

@export var initial_state: State = null

var states: Array[State] = []
var current_state: State = null


func _ready() -> void:
	states.assign(find_children("*", "State"))
	for state in states:
		state.state_machine = self

	assert(initial_state, "No initial state defined!")
	transition_to(initial_state.state_name)


func _unhandled_input(event: InputEvent) -> void:
	current_state.unhandled_input(event)


func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)


func transition_to(state_name: String, params: StateParams = null) -> void:
	var desired_states = states.filter(func (state: State): return state.state_name == state_name)
	if (desired_states.size() == 0):
		return

	var desired_state := desired_states.pop_front() as State
	if current_state and !current_state.states_for_transition.has(desired_state):
		push_error("State '%s' cannot transition to a state '%s'" % [current_state.state_name, desired_state.state_name])
		return

	# There is no state at the beginning so nothing can "exit"
	if current_state:
		current_state.on_exit()

	current_state = desired_state
	current_state.on_enter(params)
