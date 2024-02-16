extends CrusherState


func on_enter(params: StateParams) -> void:
	rest_timer.timeout.connect(_on_rest_timer_timeout)
	rest_timer.start()


func on_exit(transition: Transition) -> void:
	rest_timer.stop()
	rest_timer.timeout.disconnect(_on_rest_timer_timeout)


func _on_rest_timer_timeout() -> void:
	state_machine.transition_to("Reverting")
