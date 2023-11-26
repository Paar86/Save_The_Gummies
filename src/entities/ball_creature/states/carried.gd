extends State

@export var ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
	pass


func physics_process(delta: float) -> void:
	if not ball_creature.is_freeze_enabled():
		state_machine.transition_to("Air")
		return
