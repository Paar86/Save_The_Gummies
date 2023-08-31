extends State

@export var move_state: GoblinMoveState
@onready var attack_timer: Timer = $AttackTimer


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("walk")
	move_state.horizontal_speed_scale = 4
	move_state.can_attack = false
	attack_timer.start()


func on_exit() -> void:
	move_state.horizontal_speed_scale = 1
	attack_timer.stop()


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)


func propagate_effects(effects: Array[String]) -> void:
	move_state.propagate_effects(effects)


func on_attack_timer_timeout() -> void:
	state_machine.transition_to("Idle")
