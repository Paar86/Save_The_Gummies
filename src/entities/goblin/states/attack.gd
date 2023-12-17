extends State

@export var move_state: GoblinMoveState
var _attack_sfx: Resource = preload(SfxResources.GOBLIN_ATTACK)

@onready var _attack_timer: Timer = $AttackTimer


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("walk")
	move_state.horizontal_speed = move_state.HORIZONTAL_SPEED_DEFAULT * 4
	move_state.can_attack = false
	_attack_timer.start()
	AudioStreamManager2D.play_sound(_attack_sfx, move_state.character)


func on_exit(transition: Transition) -> void:
	move_state.horizontal_speed = move_state.HORIZONTAL_SPEED_DEFAULT
	_attack_timer.stop()

	if not move_state.can_attack:
		move_state.can_attack_timer.start()


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)


func propagate_effects(effects: Array[String]) -> void:
	move_state.propagate_effects(effects)


func on_attack_timer_timeout() -> void:
	state_machine.transition_to("Idle")
