extends CrusherState

var _is_active: = false
var _is_player_detected: = false


func on_enter(params: StateParams) -> void:
	_is_active = false
	_is_player_detected = false

	rest_timer.timeout.connect(_on_rest_timer_timeout)
	rest_timer.start()


func on_exit(transition: Transition) -> void:
	rest_timer.stop()
	rest_timer.timeout.disconnect(_on_rest_timer_timeout)


func physics_process(delta: float) -> void:
	if _is_active and crusher_body.player_is_detected:
		state_machine.transition_to("Falling")


func _on_rest_timer_timeout() -> void:
	_is_active = true


func _on_player_detected() -> void:
	_is_player_detected = true


func _on_player_left() -> void:
	_is_player_detected = false
