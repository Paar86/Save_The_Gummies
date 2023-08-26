extends State

@export var move_state: GoblinMoveState = null
@onready var stun_timer: Timer = $StunTimer


func on_enter(params: StateParams) -> void:
	state_machine.change_animation("stunned")
	stun_timer.start()
	move_state.horizontal_speed_scale = 0.0
	move_state.character.toggle_hurtbox_collider(false)


func on_exit() -> void:
	stun_timer.stop()
	move_state.horizontal_speed_scale = 1.0
	move_state.character.toggle_hurtbox_collider(true)


func on_stun_timer_timeout() -> void:
	state_machine.transition_to("Idle")
