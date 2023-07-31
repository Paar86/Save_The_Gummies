extends State

const THROW_STRENGTH: = 450.0

@export var move_state: PlayerMoveState
# How long until aim arrow is shown
@onready var to_aim_timer: Timer = $ToAimTimer

var can_throw: = false


func physics_process(delta: float) -> void:
	move_state.physics_process(delta)


func on_enter(params: StateParams) -> void:
	move_state.character.pickup_transform.set_deferred("remote_path", move_state.character.hold_object.get_path())
	move_state.max_speed = move_state.MAX_RUN_SPEED * 0.5


func on_exit() -> void:
	move_state.max_speed = move_state.MAX_RUN_SPEED


func unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action"):
		can_throw = true
		to_aim_timer.start()

	if event.is_action_released("action") and can_throw:
		var thrown_object = move_state.character.hold_object
		move_state.character.hold_object = null
		move_state.character.pickup_transform.set_deferred("remote_path", null)
		thrown_object.set_deferred("freeze", false)
		thrown_object.call_deferred("apply_central_impulse", move_state.character.aim_direction * THROW_STRENGTH)
		state_machine.transition_to("Idle")
		Events.player_aiming_called_off.emit()
		to_aim_timer.stop()
		can_throw = false
		return


func on_to_aim_timer_timeout() -> void:
	Events.player_aiming_requested.emit()
