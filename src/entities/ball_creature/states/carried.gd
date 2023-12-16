extends State

@export var ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
	ball_creature.animation_player.play("looking_around_stressed")


func on_exit(transition: Transition) -> void:
	ball_creature.animation_player.play("RESET")


func physics_process(delta: float) -> void:
	if not ball_creature.is_freeze_enabled():
		state_machine.transition_to("Air")
		return
