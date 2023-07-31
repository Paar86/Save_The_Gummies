extends State

@export var move_state: PlayerMoveState


func unhandled_input(event: InputEvent) -> void:
	move_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)

	if not move_state.character.is_on_floor():
		state_machine.transition_to("Air")
		return

	if move_state.character.velocity.x == 0.0:
		state_machine.transition_to("Idle")
		return

