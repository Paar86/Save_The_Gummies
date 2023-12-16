extends State

@export var move_state: PlayerMoveState
@export var carry_state: PlayerCarryState


func on_enter(params: StateParams) -> void:
	carry_state.on_enter(params)

	state_machine.change_animation("carry_idle")


func on_exit(transition: Transition) -> void:
	carry_state.on_exit(transition)


func unhandled_input(event: InputEvent) -> void:
	carry_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	if not move_state.character.is_on_wall() and move_state.character.velocity.x != 0.0:
		state_machine.transition_to("CarryWalk")
		return

	carry_state.physics_process(delta)
