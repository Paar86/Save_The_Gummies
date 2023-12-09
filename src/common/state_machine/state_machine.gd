class_name StateMachine extends Node

@export var initial_state: State = null
@export var animated_sprite: AnimatedSprite2D = null

var current_state: State = null
var _states: Array[State] = []


func _ready() -> void:
	await owner.ready

	_states.assign(find_children("*", "State"))
	for state in _states:
		state.state_machine = self

	assert(initial_state, "No initial state defined!")
	transition_to(initial_state.state_name)


func _unhandled_input(event: InputEvent) -> void:
	current_state.unhandled_input(event)


func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)


func transition_to(state_name: String, params: StateParams = null) -> void:
	var desired_states = _states.filter(func (state: State): return state.state_name == state_name)
	if (desired_states.size() == 0):
		return

	var desired_state := desired_states.pop_front() as State
	if current_state and !current_state.states_for_transition.has(desired_state):
		assert(false, "State '%s' cannot transition to a state '%s'" % [current_state.state_name, desired_state.state_name])
		return

	# There is no state at the beginning so nothing can "exit"
	if current_state:
		current_state.on_exit()

	current_state = desired_state
	current_state.on_enter(params)


func change_animation(animation_name: String) -> void:
	if not animated_sprite:
		return

	if animated_sprite.animation == animation_name:
		return

	animated_sprite.play(animation_name)
	animated_sprite.speed_scale = 1.0


func change_animation_speed_scale(scale: float) -> void:
	if not animated_sprite:
		return

	animated_sprite.speed_scale = scale
