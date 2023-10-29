extends State

@export var move_state: PlayerMoveState


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("walk")


func unhandled_input(event: InputEvent) -> void:
	move_state.unhandled_input(event)


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)

	var real_velocity = move_state.character.get_real_velocity()
	var movement_speed_scale: float = abs(real_velocity.length()) / move_state.max_speed
	state_machine.change_animation_speed_scale(movement_speed_scale)

	if not move_state.character.is_on_floor():
		state_machine.transition_to("Air")
		return

	if move_state.character.velocity_primary.x == 0.0:
		state_machine.transition_to("Idle")
		return

