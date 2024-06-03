extends State

@export var ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
	ball_creature.freeze = true
	ball_creature.whistling_player = null


func on_exit(transition: Transition) -> void:
	ball_creature.freeze = false


func physics_process(delta: float) -> void:
	if not ball_creature.is_effect_active(Enums.effect.CRUSHED):
		state_machine.transition_to("Idle")
