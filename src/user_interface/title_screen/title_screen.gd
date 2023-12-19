extends CanvasLayer


func _on_play_button_up() -> void:
	Events.change_level_requested.emit()
