extends CanvasLayer


func _on_continue_button_up() -> void:
	Events.pause_level.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Events.pause_level.emit()
