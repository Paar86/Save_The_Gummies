extends State

@export var character: Goblin

var _alert_sfx: = preload(SfxResources.GOBLIN_ALERT)
@onready var _ready_to_attack_timer: Timer = $ReadyToAttackTimer

func on_enter(params: StateParams) -> void:
	state_machine.change_animation_speed_scale(0)
	character._reaction_symbol.show_symbol(Enums.reaction_symbol.EXCLAMATION)
	_ready_to_attack_timer.start()
	AudioStreamManager2D.play_sound(_alert_sfx, character)


func on_exit(transition: Transition) -> void:
	state_machine.change_animation_speed_scale(1)
	_ready_to_attack_timer.stop()


func propagate_effects(effects: Array[String]) -> void:
	if effects.has("stun"):
		state_machine.transition_to("Stunned")


func _on_ready_to_attack_timer_timeout() -> void:
	state_machine.transition_to("Attack")
