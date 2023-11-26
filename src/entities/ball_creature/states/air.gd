extends State

@export var ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
	ball_creature.ignore_following = true


func on_exit() -> void:
	ball_creature.ignore_following = false


func physics_process(delta: float) -> void:
	if ball_creature.is_freeze_enabled():
		state_machine.transition_to("Carried")
		return

	if ball_creature.is_on_floor:
		state_machine.transition_to("Idle")
		return
