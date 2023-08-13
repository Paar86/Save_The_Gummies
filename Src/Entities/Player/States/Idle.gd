extends State

@export var move_state: PlayerMoveState


func on_enter(params: StateParams) -> void:
	if params && params.is_jump_buffered:
		var new_params := StateParams.new()
		new_params.initiated_jumping = true
		state_machine.transition_to("Air", new_params)
		return

	state_machine.change_animation("idle")


func unhandled_input(event: InputEvent) -> void:
	move_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)

	if not move_state.character.is_on_floor():
		state_machine.transition_to("Air")
		return

	if not move_state.character.is_on_wall() and move_state.character.velocity.x != 0.0:
		state_machine.transition_to("Run")
		return
