extends State

@export var ball_creature: BallCreature


func on_enter(params: StateParams) -> void:
#	var animation_name = "looking_around"
#	var animation = ball_creature.animation_player.get_animation(animation_name)
#	animation.loop_mode = Animation.LOOP_LINEAR

	ball_creature.animation_player.play("looking_around_stressed")


func on_exit() -> void:
#	var animation_name = "looking_around"
#	var animation = ball_creature.animation_player.get_animation(animation_name)
#	animation.loop_mode = Animation.LOOP_NONE

	ball_creature.animation_player.play("RESET")


func physics_process(delta: float) -> void:
	if not ball_creature.is_freeze_enabled():
		state_machine.transition_to("Air")
		return
