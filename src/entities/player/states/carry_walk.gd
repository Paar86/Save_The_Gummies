extends State

@export var move_state: PlayerMoveState
@export var carry_state: PlayerCarryState


func on_enter(params: StateParams) -> void:
	carry_state.on_enter(params)
	state_machine.change_animation("carry_walk")


func on_exit(transition: Transition) -> void:
	carry_state.on_exit(transition)


func unhandled_input(event: InputEvent) -> void:
	carry_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	var real_velocity = move_state.character.get_real_velocity()
	var movement_speed_scale: float = abs(real_velocity.length()) / move_state.MAX_RUN_SPEED_DEFAULT
	state_machine.change_animation_speed_scale(movement_speed_scale)

	if move_state.character.velocity_primary.length() == 0.0:
		state_machine.transition_to("CarryIdle")
		return

	carry_state.physics_process(delta)
