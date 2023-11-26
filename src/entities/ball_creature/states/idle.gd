extends State

@export var ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
	pass


func physics_process(delta: float) -> void:
	if not ball_creature.is_on_floor:
		state_machine.transition_to("Air")
		return

	if not ball_creature.sleeping:
		state_machine.transition_to("Rolling")
		return
