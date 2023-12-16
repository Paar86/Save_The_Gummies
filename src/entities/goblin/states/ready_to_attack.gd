extends State

@export var character: Goblin

var _alert_sfx: = preload(SfxResources.GOBLIN_ALERT)
@onready var _exclamation_mark_timer: Timer = $ExclamationMarkTimer

func on_enter(params: StateParams) -> void:
	state_machine.change_animation_speed_scale(0)
	character.exclamation_mark.show()
	_exclamation_mark_timer.start()
	AudioStreamManager2D.play_sound(_alert_sfx, character)


func on_exit(transition: Transition) -> void:
	state_machine.change_animation_speed_scale(1)
	character.exclamation_mark.hide()
	_exclamation_mark_timer.stop()


func propagate_effects(effects: Array[String]) -> void:
	if effects.has("stun"):
		state_machine.transition_to("Stunned")


func on_exclamation_mark_timer_timeout() -> void:
	state_machine.transition_to("Attack")
