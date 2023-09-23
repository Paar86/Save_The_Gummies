extends State

@export var move_state: PlayerMoveState
@export var carry_state: PlayerCarryState


func on_enter(params: StateParams) -> void:
	carry_state.on_enter(params)
	state_machine.change_animation("carry_walk")


func on_exit() -> void:
	carry_state.on_exit()


func unhandled_input(event: InputEvent) -> void:
	carry_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	var movement_speed_scale: float = abs(move_state.character.velocity.x) / move_state.MAX_RUN_SPEED_DEFAULT
	state_machine.change_animation_speed_scale(movement_speed_scale)

	if move_state.character.velocity.x == 0.0:
		state_machine.transition_to("CarryIdle")
		return

	carry_state.physics_process(delta)
